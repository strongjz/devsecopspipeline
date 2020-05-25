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



### Run Time Security - Falco

### Logging - FireLens 

### Alerting - Cloudwatch




Credits and Thank you to 

@rnzsgh https://github.com/rnzsgh/eks-workshop-sample-api-service-go

Sysdig Blog Falco EKS deployment https://sysdig.com/blog/multi-cluster-security-firelens/

Issues with Docker and Code build https://github.com/aws/aws-codebuild-docker-images/issues/164

Packer Build https://github.com/draios/sysdig-workshop-infra

EKS AMI Build https://github.com/strongjz/amazon-eks-ami

