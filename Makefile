OUTPUT ?= golang_example
REGISTRY ?= strongjz
IMAGE ?= golang_example
VERSION ?= 0.0.4
AWS_PROFILE ?= contino
AWS_REGION ?= us-west-2
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
	go get .

build: install
	go build -o $(OUTPUT) main.go

run: install
	go run main.go

compose_up:
	docker-compose up

docker_build:
	docker build -t $(REGISTRY)/$(IMAGE):$(VERSION) .

docker_run:
	docker run --env-file=.env -it --rm -p 8080:8080 -p 8090:8090 $(REGISTRY)/$(IMAGE):$(VERSION)

docker_push: docker_build
	docker push $(REGISTRY)/$(IMAGE):$(VERSION); \
	git tag -a $(VERSION); \
	git push origin --tags

cluster:
	eksctl create cluster \
    --name austin-devsecops \
    --version 1.16 \
    --region $(AWS_REGION) \
    --nodegroup-name standard-workers \
    --node-type m4.medium \
    --nodes 3 \
    --nodes-min 1 \
    --nodes-max 4 \
    --ssh-access \
    --ssh-public-key id_rsa.pub \
    --managed

prom:
	kubectl create namespace prometheus &&
	helm install prometheus stable/prometheus \
        --namespace prometheus \
        --set alertmanager.persistentVolume.storageClass="gp2",server.persistentVolume.storageClass="gp2"

falco:
	git clone git@github.com:sysdiglabs/falco-aws-firelens-integration.git &&
	cd eks && make

.PHONY: get plan apply

check:
	terraform -v  >/dev/null 2>&1 || echo "Terraform not installed" || exit 1

clean:
	rm -rf .terraform
	rm -rf plan.out

get:
	terraform get

plan:
	terraform plan -out=plan.out

apply:
	terraform apply -auto-approve

destroy:
	terraform destroy
