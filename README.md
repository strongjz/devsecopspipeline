DevSecOps Container Pipeline Demo 

Austin AWS Meetup 28.05.2020

### Overview 

* Github Repo
* AWS ECR - Image Scanning - CVE
* AWS Codepipeline/Build - CI/CD
* AWS ECR - Immutable Tags 
* Run Time Security - Falco
* Logging - FireLens 
* Alerting - Cloudwatch
* Auditing - Cloudtrail 

### Github Repo

Signed Commits Setup

* GPG Key
* Keybase
* Github Account 

You can use this tutorial to setup gpg keys and use them with Git
https://github.com/pstadler/keybase-gpg-github

Developer workflow
https://3musketeers.io/about/

Using Make, Docker and docker-compose, the developer local workflow can match the workflow the CI/CD pipeline runs
and workflow others will uses. It helps solves the "works on my machine" syndrome. 

Kind - Kubernetes in Docker 

Allows Developers to run local Kubernetes clusters and test before pushing. 

https://kind.sigs.k8s.io/

### CVE Image Scanning - AWS ECR 

List out images in ECR 
    
    aws ecr list-images --repository-name golang_example 
    
Scans can be ran on push or manually

    aws ecr start-image-scan --repository-name golang_example --image-id imageTag=0.0.10 --region us-west-2

Retrieve findings 

    aws ecr describe-image-scan-findings --repository-name golang_example --image-id imageTag=0.0.10 --region us-west-2


https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-scanning.html

### CI/CD - AWS Codepipeline/Build 

Stages for Code pipeline 

Build - Build golang example applications, in a docker container and stores it in the AWS ECR

Invoke - Runs the Go Report Static Code analysis

Test - runs any tests in the golang example applications

Deploy - deploys the application via Code build, aws eks cli and kubectl 


### Immutable Tags And CVE Scanning - AWS ECR 

When enabled on a Repository, images tags can not be overwritten 

     2020-05-24 19:43:28 ⌚  strongjz-macbook in ~/Documents/code/go/src/github.com/strongjz/devsecopspipeline
    ± |master U:2 ✗| → docker tag nginx AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/golang_example:0.0.7
    
     2020-05-24 19:44:43 ⌚  strongjz-macbook in ~/Documents/code/go/src/github.com/strongjz/devsecopspipeline
    ± |master U:2 ✗| → docker push AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/golang_example:0.0.7
    The push refers to repository [AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/golang_example]
    6c7de695ede3: Pushed 
    2f4accd375d9: Pushed 
    ffc9b21953f4: Pushed 
    [DEPRECATION NOTICE] registry v2 schema1 support will be removed in an upcoming release. Please contact admins of the AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com registry NOW to avoid future disruption. More information at https://docs.docker.com/registry/spec/deprecated-schema-v1/
    tag invalid: The image tag '0.0.7' already exists in the 'golang_example' repository and cannot be overwritten because the repository is immutable.


https://www.youtube.com/watch?v=y6NI_K96DRs


### Run Time Security - Falco

Falco is Container Native Runtime Security

"Falco is a behavioral activity monitor designed to detect anomalous activity in your applications. Falco audits a 
system at the most fundamental level, the kernel. Falco then enriches this data with other input streams such as 
container runtime metrics, and Kubernetes metrics. Falco lets you continuously monitor and detect container, 
application, host, and network activity—all in one place—from one source of data, with one set of rules."

Falco Demo Repo
https://github.com/falcosecurity/evolution/tree/master/examples/nodejs-bad-rest-api

This Demo runs a poorly configured NodeJS server and will generate a Falco alert when the server attempts to run a bash shell

    falco          | 22:26:53.536628076: Warning Shell spawned in a container other than entrypoint (user=root container_id=6f339b8aeb0a container_name=express_server shell=bash parent=sh cmdline=bash )


### Logging - FireLens 

"FireLens gives you a simplified interface to filter logs at source, add useful metadata and send logs to almost any 
destination. You can now stream logs directly to Amazon CloudWatch, Amazon Kinesis Data Firehose destinations such as 
Amazon Elasticsearch, Amazon S3, Amazon Kinesis Data Streams and partner tools. Using Amazon ECS task definition 
parameters, you can select destinations and optionally define filters for additional control and FireLens will ingest 
logs to target destinations."

Fluentbit images are available here 
https://github.com/aws/amazon-cloudwatch-logs-for-fluent-bit

### Alerting - Cloudwatch

*Credits and Thank you to* 

@rnzsgh https://github.com/rnzsgh/eks-workshop-sample-api-service-go

Sysdig Blog Falco EKS deployment https://sysdig.com/blog/multi-cluster-security-firelens/

Issues with Docker and Code build https://github.com/aws/aws-codebuild-docker-images/issues/164

Ubuntu Packer Build https://github.com/draios/sysdig-workshop-infra

EKS AMI Build https://github.com/strongjz/amazon-eks-ami

