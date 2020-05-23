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

### Github Repo

Signed Commits Setup

* GPG Key
* Keybase
* Github Account 

Setup Keys 
https://github.com/pstadler/keybase-gpg-github

https://3musketeers.io/about/

### CVE Image Scanning - AWS ECR 

Scans can be ran on push or manually

    aws ecr start-image-scan --repository-name name --image-id imageTag=tag_name --region us-east-2

Retrieve findings 

    aws ecr describe-image-scan-findings --repository-name name --image-id imageTag=tag_name --region us-east-2


https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-scanning.html

### CI/CD - AWS Codepipeline/Build 

Stages for Code pipeline 

Build - Build golang example applications, in a docker container and stores it in the AWS ECR

Test - runs any tests in the golang example applications

Deploy - deploys 


### Immutable Tags - AWS ECR 

### Run Time Security - Falco

### Logging - FireLens 

### Alerting - Cloudwatch

Credits and Thank you to 

@rnzsgh https://github.com/rnzsgh/eks-workshop-sample-api-service-go

Sysdig Blog Falco EKS deployment https://sysdig.com/blog/multi-cluster-security-firelens/
