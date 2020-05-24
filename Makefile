OUTPUT ?= golang_example
REGISTRY ?= strongjz
IMAGE ?= golang_example
VERSION ?= 0.0.5
AWS_PROFILE ?= contino-static
AWS_REGION ?= us-west-2
NODE_ROLE_NAME ?= ng-1

include .env
export

.PHONY: test clean install

pretty:
	go fmt

test:
	go test ./...

clean:
	rm -f $(OUTPUT)

install:
	env GIT_TERMINAL_PROMPT=1 go get -d -v .

build: install
	go build -o $(OUTPUT) main.go

run: install
	go run main.go

compose_up:
	docker-compose up

docker_build:
	docker build -t $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE):$(VERSION) .

ecr_auth:
	$(eval $(aws ecr get-login --no-include-email))

docker_push: ecr_auth
	docker push $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE):$(VERSION)

docker_run:
	docker run --env-file=.env -it --rm -p 8080:8080 -p 8090:8090 $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE):$(VERSION)

cluster:
	eksctl create cluster -f eks-config.yml

helm_update:
	helm repo update && \
	helm repo add stable https://kubernetes-charts.storage.googleapis.com/

prom: helm_update
	kubectl apply -f namespace_prometheus.yml && \
	helm install prometheus stable/prometheus \
        --namespace prometheus \
        --set alertmanager.persistentVolume.storageClass="gp2",server.persistentVolume.storageClass="gp2"

falco:
	git clone git@github.com:sysdiglabs/falco-aws-firelens-integration.git && \
	cd falco-aws-firelens-integration/eks && \
	make

check:
	terraform -v  >/dev/null 2>&1 || echo "Terraform not installed" || exit 1 && \
	aws --version  >/dev/null 2>&1 || echo "AWS not installed" || exit 1 && \
	helm version  >/dev/null 2>&1 || echo "Helm not installed" || exit 1 && \
	eksctl version >/dev/null 2>&1 || echo "eksctl not installed" || exit 1 && \
	kubectl --help >/dev/null 2>&1 || echo "kubectl not installed" || exit 1


tf_clean:
	cd terraform/ && \
	rm -rf .terraform \
	rm -rf plan.out

tf_init:
	cd terraform/ && \
	terraform init

tf_get:
	cd terraform/ && \
	terraform get

tf_plan:
	cd terraform/ && \
	terraform plan -out=plan.out

tf_apply:
	cd terraform/ && \
	terraform apply -auto-approve

tf_destroy:
	cd terraform/ && \
	terraform destroy

falco_deploy: deploy-fluent-bit deploy-falco

deploy-falco:
	helm install falco --set falco.jsonOutput=true --set image.tag=0.17.1 stable/falco

deploy-fluent-bit:
	aws iam create-policy --policy-name EKS-CloudWatchLogs --policy-document file://./fluent-bit/aws/iam_role_policy.json
	aws iam attach-role-policy --role-name $(NODE_ROLE_NAME) --policy-arn `aws iam list-policies | jq -r '.[][] | select(.PolicyName == "EKS-CloudWatchLogs") | .Arn'`
	kubectl apply -f fluent-bit/kubernetes/

falco_clean: clean-fluent-bit clean-falco

clean-fluent-bit:
	kubectl delete -f fluent-bit/kubernetes/

clean-falco:
	helm del falco