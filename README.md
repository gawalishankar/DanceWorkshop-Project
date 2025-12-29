# Dance Workshop Project – AWS ECS Deployment (DevOps)

This repository contains a PHP + MySQL web application deployed on **AWS ECS (Fargate)** using **Docker, Amazon ECR, RDS, ALB, and GitHub Actions CI**.

---

## Architecture

GitHub → GitHub Actions (CI) → Amazon ECR → Amazon ECS (Fargate) → Application Load Balancer  
Database → Amazon RDS (MySQL)

---

## Prerequisites

- AWS Account
- IAM User with permissions for ECS, ECR, RDS, EC2, ELB, IAM, CloudWatch
- AWS CLI installed
- Docker installed
- Git installed

Configure AWS CLI:
```bash
aws configure
````

---

## Step 1: Clone Repository

```bash
git clone https://github.com/gawalishankar/Dance-Workshop-Project.git
cd Dance-Workshop-Project
```

---

## Step 2: Dockerize the Application

Ensure `Dockerfile` exists in the project root.

Build and test locally:

```bash
docker build -t dance-workshop .
docker run -d -p 8080:80 dance-workshop
```

Verify in browser:

```
http://localhost:8080
```

---

## Step 3: Create Amazon ECR Repository

```bash
aws ecr create-repository \
--repository-name dance-workshop \
--region us-east-2
```

Login to ECR:

```bash
aws ecr get-login-password --region ap-south-1 \
| docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.us-east-2.amazonaws.com
```

---

## Step 4: Push Image to ECR (Manual Test)

```bash
docker tag dance-workshop:latest <AWS_ACCOUNT_ID>.dkr.ecr.us-east-2.amazonaws.com/dance-workshop:latest
docker push <AWS_ACCOUNT_ID>.dkr.ecr.us-east-2.amazonaws.com/dance-workshop:latest
```

---

## Step 5: Setup GitHub Actions CI

Add GitHub Secrets:

* AWS_ACCESS_KEY_ID
* AWS_SECRET_ACCESS_KEY
* AWS_REGION
* AWS_ACCOUNT_ID
* ECR_REPOSITORY

Push code to `main` branch to trigger CI.

Verify image in:

```
AWS Console → ECR → Images
```

---

## Step 6: Create RDS MySQL Database

* Engine: MySQL
* DB Name: danceworkshop
* Username: admin
* Password: strong password
* Public access: No
* VPC: Same as ECS

Ensure security group allows:

```
Inbound 3306 from ECS security group
```

---

## Step 7: Import Database Using S3 and EC2

Upload SQL file to S3:

```bash
aws s3 cp danceworkshop.sql s3://<bucket-name>/
```

Launch EC2 with IAM role:

* Policy: AmazonS3ReadOnlyAccess

Install MySQL client:

```bash
sudo yum install mysql -y
```

Download SQL file:

```bash
aws s3 cp s3://<bucket-name>/dance.sql .
```

Import to RDS:

```bash
mysql -h <RDS-ENDPOINT> -u admin -p danceworkshop < dance.sql
```

Terminate EC2 after import.

---

## Step 8: Create ECS Cluster

AWS Console:

```
ECS → Clusters → Create Cluster → Fargate
```

Cluster name:

```
dance-workshop-cluster
```

---

## Step 9: Create IAM Role for ECS Task

Create role:

* Trusted entity: ECS
* Policy: AmazonECSTaskExecutionRolePolicy

Role name:

```
ecsTaskExecutionRole
```

---

## Step 10: Create ECS Task Definition

* Launch type: Fargate
* CPU: 256
* Memory: 512
* Network mode: awsvpc
* Container port: 80
* Image: ECR image URI
* Environment variables:

```
DB_HOST
DB_NAME
DB_USER
DB_PASS
```

Register task definition.

---

## Step 11: Create Application Load Balancer

* Type: Application Load Balancer
* Scheme: Internet-facing
* Listener: HTTP 80
* Target type: IP

---

## Step 12: Create ECS Service

* Cluster: dance-workshop-cluster
* Launch type: Fargate
* Desired tasks: 2
* Auto-assign public IP: ENABLED
* Attach ALB and target group
* Container port: 80

---

## Step 13: Access Application

Get ALB DNS:

```
EC2 → Load Balancers → DNS Name
```

Open in browser:

```
http://<ALB-DNS>
```

---

## Step 14: Logs & Monitoring

View logs:

```
CloudWatch → Log Groups → /ecs/dance-workshop
```

---

## Cleanup (Cost Saving)

```bash
Scale ECS service to 0
Delete ALB
Stop or delete RDS
Delete ECR images
```

---
