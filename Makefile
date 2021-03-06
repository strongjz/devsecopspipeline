OUTPUT ?= golang_example
REGISTRY ?= strongjz
IMAGE ?= golang_example-atlanta
GOLANG_VERSION ?= 1.13.5
AWS_REGION ?= us-west-2
NODE_ROLE_NAME ?= ng-1
DB_HOST ?= db
DB_USER ?= postgres
DB_NAME ?= pqgotest
DB_PORT ?= 5432
MY_NODE_NAME ?= test
MY_POD_IP ?= 1.1.1.1
PORT ?= 8080
FILE=VERSION.txt
VERSION=`cat $(FILE)`
EKS_KUBECTL_ROLE_NAME ?= devsecops-atlanta-codebuild
EKS_CLUSTER_NAME ?= atlanta-devsecops

export

.PHONY: test clean install

go_version:
	echo ${GOLANG_VERSION}

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

go_report: go_version
	go get -u github.com/360EntSecGroup-Skylar/goreporter && \
	goreporter -p . -f html

compose_up:
	docker-compose up

docker_build:
	docker build -t $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE):$(VERSION) .

ecr_auth:
	$(shell aws ecr get-login --no-include-email)

docker_push: ecr_auth
	docker push $(ACCOUNT_IDACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE):$(VERSION)

ecr_scan:
	aws ecr start-image-scan --repository-name $(IMAGE) --image-id imageTag=$(VERSION)

ecr_scan_findings:
	aws ecr describe-image-scan-findings --repository-name $(IMAGE) --image-id imageTag=$(VERSION)

docker_run:
	docker run --env-file=.env -it --rm -p 8080:8080 -p 8090:8090 $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE):$(VERSION)

cluster:
	eksctl create cluster -f eks-config.yml

kube_update:
	aws eks update-kubeconfig --name "${EKS_CLUSTER_NAME}"

kube_deploy:
	kubectl apply -f app.yml

clean_cluster:
	eksctl delete cluster -f eks-config.yml

helm_update:
	helm repo update && \
	helm repo add stable https://kubernetes-charts.storage.googleapis.com/

prom: helm_update
	kubectl apply -f namespace_prometheus.yml && \
	helm install prometheus stable/prometheus \
        --namespace prometheus \
        --set alertmanager.persistentVolume.storageClass="gp2",server.persistentVolume.storageClass="gp2"

check:
	terraform -v  >/dev/null 2>&1 || echo "Terraform not installed" || exit 1 && \
	aws --version  >/dev/null 2>&1 || echo "AWS not installed" || exit 1 && \
	helm version  >/dev/null 2>&1 || echo "Helm not installed" || exit 1 && \
	eksctl version >/dev/null 2>&1 || echo "eksctl not installed" || exit 1 && \
	kubectl --help >/dev/null 2>&1 || echo "kubectl not installed" || exit 1

codebuild:
	./scripts/codebuild.sh -i ubuntu:latest -a .

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
	helm repo add falcosecurity https://falcosecurity.github.io/charts; \
	helm repo update; \
	helm install falco --set falco.jsonOutput=true --set image.tag=0.24.0 falcosecurity/falco

deploy-fluent-bit:
	aws iam create-policy --policy-name EKS-CloudWatchLogs-"${EKS_CLUSTER_NAME}" --policy-document file://./fluent-bit/aws/iam_role_policy.json
	aws iam attach-role-policy --role-name $(NODE_ROLE_NAME) --policy-arn `aws iam list-policies | jq -r '.[][] | select(.PolicyName == "EKS-CloudWatchLogs-${EKS_CLUSTER_NAME}") | .Arn'`
	kubectl apply -f fluent-bit/kubernetes/

falco_clean: clean-fluent-bit clean-falco

clean-fluent-bit:
	kubectl delete -f fluent-bit/kubernetes/

clean-falco:
	helm del falco