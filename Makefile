OUTPUT ?= golang_example
REGISTRY ?= strongjz
NAME=houston
IMAGE ?= golang_example-$(NAME)

GOLANG_VERSION ?= 1.13.5
AWS_REGION ?= us-west-2
AWS_DEFAULT_REGION ?= us-west-2
NODE_ROLE_NAME ?= node-group-1
DB_HOST ?= db
DB_USER ?= postgres
DB_NAME ?= pqgotest
DB_PORT ?= 5432
MY_NODE_NAME ?= test
MY_POD_IP ?= 1.1.1.1
PORT ?= 8080
VERSION=$(shell cat VERSION.txt)
EKS_KUBECTL_ROLE_NAME ?= devsecops-codebuild
EKS_CLUSTER_NAME ?= devsecops
REPO_INFO ?= $(shell git config --get remote.origin.url)
COMMIT_SHA ?= git-$(shell git rev-parse --short HEAD)
ACCOUNT_ID ?=$(shell aws sts get-caller-identity --query Account --output text)

export

.PHONY: test clean install

aws_account:
	echo ${ACCOUNT_ID}

pretty:
	go fmt

test:
	go test

clean:
	rm -f $(OUTPUT)

install:
	env GIT_TERMINAL_PROMPT=1 go get -d -v .

build: install
	go build -o $(OUTPUT) main.go

run: install
	go run main.go

go_report: 
	rm -rf goreporter/
	git clone https://github.com/qax-os/goreporter.git && \
	cd goreporter/ && \
	go mod init github.com/360EntSecGroup-Skylar/goreporter && \
	go build && \
	ls -la
	chmod u+x ./goreporter
	cd ..
	./goreporter/goreporter -p . -f html

go_sec: 
	go get -u github.com/securego/gosec/v2/cmd/gosec
	GO111MODULE=on gosec -fmt=json -out=security.json -stdout .

test_local:
	curl localhost:8080/ 
	curl localhost:8080/data
	
compose_up:
	docker-compose up

docker_build:
	docker build -t $(shell aws sts get-caller-identity --query Account --output text).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE):$(VERSION) .

ecr_auth:
	docker login --username AWS -p $(shell aws ecr get-login-password --region $(AWS_REGION) ) $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com


docker_push: ecr_auth docker_build
	docker push $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE):$(VERSION)

ecr_scan:
	aws ecr start-image-scan --repository-name $(IMAGE) --image-id imageTag=$(VERSION)

ecr_scan_findings:
	aws ecr describe-image-scan-findings --repository-name $(IMAGE) --image-id imageTag=$(VERSION)

docker_run:
	docker run --env-file=.env -it --rm -p 8080:8080 -p 8090:8090 $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE):$(VERSION)

cluster:
	eksctl create cluster -f eks-config.yml

cluster_iam: 
	eksctl create iamidentitymapping --cluster devsecops --arn arn:aws:iam::$(ACCOUNT_ID):role/devsecops-$(NAME)-codebuild   --username admin \
  --group system:masters

kube_update:
	aws eks update-kubeconfig --name "${EKS_CLUSTER_NAME}" --region ${AWS_REGION}

kube_deploy: kube_update
	awk -v IMAGE="$(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE):$(VERSION)" '{sub(/CONTAINERIMAGE/, IMAGE); print> "app.yml"}' app.yml
	kubectl apply -f app.yml

clean_cluster:
	eksctl delete cluster -f eks-config.yml

helm_update:
	helm repo add stable https://charts.helm.sh/stable && \
	helm repo update
	
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
	helm install -f falco falcosecurity/falco

deploy-fluent-iam:
	aws iam create-policy --policy-name EKS-CloudWatchLogs-"${EKS_CLUSTER_NAME}" --policy-document file://./fluent-bit/aws/iam_role_policy.json || true
	aws iam attach-role-policy --role-name $(NODE_ROLE_NAME) --policy-arn `aws iam list-policies | jq -r '.[][] | select(.PolicyName == "EKS-CloudWatchLogs-${EKS_CLUSTER_NAME}") | .Arn'` || true 
	
deploy-fluent-bit:
	kubectl apply -f fluent-bit/kubernetes/

falco_clean: clean-fluent-bit clean-falco

clean-fluent-bit:
	kubectl delete -f fluent-bit/kubernetes/

clean-falco:
	helm del falco
