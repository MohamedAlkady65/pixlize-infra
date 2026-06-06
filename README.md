# Pixlize — AWS Infrastructure & DevOps

> **Learning Project** — Built to practice AWS and DevOps hands-on. The infrastructure is intentionally provisioned using **AWS CLI + Bash scripts** instead of Terraform or CDK, so every API call, every resource dependency, and every AWS concept is learned directly — not hidden behind an abstraction layer.

---

## Demo

<!-- Add a screen recording or video walkthrough here -->
> **Video:** _(coming soon — application walkthrough and deployment demo)_

---

## Architecture Diagram

<!-- Replace with your actual AWS architecture diagram image -->
> **Diagram:** _(coming soon)_
>
> ![Architecture Diagram](./docs/architecture.png)

---

## Table of Contents

- [Prerequisites & Deployment](#prerequisites--deployment)
- [About This Project](#about-this-project)
- [Application Overview](#application-overview)
  - [What Is Pixlize?](#what-is-pixlize)
  - [Repositories](#repositories)
  - [Tech Stack](#tech-stack)
  - [End-to-End Data Flow](#end-to-end-data-flow)
  - [Processing Operations](#processing-operations)
  - [Database Schema](#database-schema)
- [Docker & Containerization](#docker--containerization)
- [AWS Infrastructure](#aws-infrastructure)
  - [Region & Environments](#region--environments)
  - [Networking — VPC](#networking--vpc)
  - [Security Groups](#security-groups)
  - [Compute — EC2 & Auto Scaling](#compute--ec2--auto-scaling)
  - [Load Balancing — NLB](#load-balancing--nlb)
  - [Database — RDS](#database--rds)
  - [Storage — S3](#storage--s3)
  - [Messaging — SQS & SNS](#messaging--sqs--sns)
  - [Serverless — Lambda](#serverless--lambda)
  - [CDN — CloudFront](#cdn--cloudfront)
  - [DNS — Route53](#dns--route53)
  - [Certificates — ACM](#certificates--acm)
  - [Secrets & Config](#secrets--config)
  - [IAM Roles](#iam-roles)
- [CI/CD Pipeline](#cicd-pipeline)
  - [Pipeline Flow](#pipeline-flow)
  - [Backend Pipeline](#backend-pipeline)
  - [Frontend Pipeline](#frontend-pipeline)
  - [Lambda Pipeline](#lambda-pipeline)
  - [Deployment Order](#deployment-order)
- [Key Architectural Patterns](#key-architectural-patterns)
- [A Note on Production Readiness](#a-note-on-production-readiness)
- [Skills Demonstrated](#skills-demonstrated)

---

## Prerequisites & Deployment

### Prerequisites

- **AWS CLI** installed and configured (`aws configure`)
- **AWS user / IAM role** with permissions to all services used by the scripts:
  - EC2, VPC, ELB, Auto Scaling
  - RDS, S3, SQS, SNS, Lambda
  - CloudFront, Route53, ACM
  - IAM, STS
  - CodeBuild, CodeDeploy, CodePipeline, CodeConnections
  - Secrets Manager, SSM Parameter Store
  - CloudWatch

> The deploying user must have sufficient permissions to create and manage all of the above services.

### Deploy

```bash
# 1. Navigate to the scripts directory
cd scripts

# 2. Make the deploy script executable
chmod +x ./deploy.sh

# 3. Run for your target environment (prod | dev | staging | qc)
./deploy.sh "$env"

```

The script provisions the entire stack in the correct dependency order. It is fully idempotent: re-running it on an existing environment is safe and will skip resources that already exist.

---

## About This Project

Pixlize is a **learning project** built by a backend engineer to gain hands-on experience with AWS and DevOps. The application — an async image processing platform — is the vehicle for practicing real-world infrastructure patterns. The focus is on the **infrastructure and CI/CD**, not the application logic.

The backend (NestJS), frontend (React), and Lambda (Python) are **vibe coded**  they exist purely to provide a realistic, working application to deploy and operate on AWS. The real work and learning is entirely in the infrastructure and DevOps layer.

**Why AWS CLI instead of Terraform?**
Terraform and CDK are great for production teams, but they abstract away the underlying API calls. Using AWS CLI directly forces you to understand what each resource actually does, what parameters it needs, in what order things must be created, and how services depend on each other. This is far more educational for someone learning AWS from scratch.

---

## Application Overview

### What Is Pixlize?

Pixlize is an async image processing SaaS. Users upload images, submit processing jobs (filter, crop, rotate, compress, convert format), and receive real-time notifications when their processed images are ready — all without blocking the UI.

**User Flow:**
1. Register or log in
2. Upload an image (JPEG, PNG, WebP, GIF, BMP, TIFF)
3. Select an image and choose a processing operation
4. Configure parameters (filter type, crop coordinates, rotation angle, etc.)
5. Submit the job and watch real-time status updates via WebSocket
6. View and download the processed result from the gallery

### Repositories

| Repository | Purpose | Link |
|------------|---------|------|
| `pixlize-back` | NestJS REST API + WebSocket server | [github.com/MohamedAlkady65/pixlize-back](https://github.com/MohamedAlkady65/pixlize-back) |
| `pixlize-front` | React SPA (user interface) | [github.com/MohamedAlkady65/pixlize-front](https://github.com/MohamedAlkady65/pixlize-front) |
| `lambda` | Python image processor (AWS Lambda) | [github.com/MohamedAlkady65/pixlize-lambda](https://github.com/MohamedAlkady65/pixlize-lambda) |
| `pixlize-infra` | This repo — all AWS infrastructure scripts | [github.com/MohamedAlkady65/pixlize-infra](https://github.com/MohamedAlkady65/pixlize-infra) |

### Tech Stack

| Layer | Technology |
|-------|-----------|
| **Backend** | Node.js 20, NestJS 10, TypeORM, MySQL, Socket.io, JWT, Multer, AWS SDK v3 |
| **Frontend** | React 18, TypeScript, Vite 5, Tailwind CSS, Zustand, Socket.io client, Axios |
| **Lambda** | Python 3.12, Pillow (PIL) 10, boto3 |
| **Infrastructure** | Bash scripting, AWS CLI, Docker |

### End-to-End Data Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          Complete Request Lifecycle                          │
└─────────────────────────────────────────────────────────────────────────────┘

 User Browser
     │
     │  1. Login / Register → JWT token returned
     │
     │  2. Upload image (multipart/form-data)
     ▼
 CloudFront ──► NLB (TLS 443) ──► Backend EC2 (Docker, port 3000)
                                        │
                                        │  3. Store image metadata in MySQL (RDS)
                                        │  4. Upload original file to S3
                                        │  5. Send job message to SQS
                                        │     { jobId, userId, operation, params, sourceS3Key }
                                        │
                                        ▼
                                      SQS Queue
                                        │
                                        │  6. SQS triggers Lambda (event source mapping)
                                        ▼
                                   Lambda (Python)
                                        │
                                        │  7. Download source image from S3
                                        │  8. Process image (Pillow)
                                        │  9. Upload result to S3
                                        │     key: {userId}/{jobId}-result.{format}
                                        │  10. Publish to SNS
                                        │      { type: JOB_COMPLETED | JOB_FAILED, jobId, ... }
                                        ▼
                                    SNS Topic
                                        │
                                        │  11. HTTPS delivery to backend webhook
                                        │      POST /webhooks/sns
                                        ▼
                               Backend EC2 (Docker)
                                        │
                                        │  12. Update job status in MySQL
                                        │  13. Broadcast via Socket.io
                                        │      event: job:completed | job:failed
                                        ▼
                                  User Browser
                                        │
                                        │  14. UI updates in real time
                                        │  15. Fetch processed image via CloudFront CDN
                                        ▼
                              CloudFront (bucket.pixlize.*)
                                        │
                                        └──► S3 (private bucket, OAC)
```

### Processing Operations

| Operation | Parameters | Description |
|-----------|-----------|-------------|
| `filter` | type (grayscale/blur/sharpen/brightness/contrast), value (0–10) | Apply image filters |
| `crop` | x, y, width, height (pixels) | Crop to a region |
| `rotate` | angle (0–360 degrees) | Rotate clockwise |
| `compress` | quality (1–100%) | JPEG/WebP quality compression |
| `convert` | format (jpeg/png/webp/gif/bmp/tiff) | Format conversion |

### Database Schema

```
users
  id, email, password (bcrypt), createdAt, updatedAt

images
  id, userId, s3Key, filename, format, mimeType, sizeBytes,
  type (original | processed), createdAt

jobs
  id, userId, sourceImageId, resultImageId, operation,
  params (JSON), status (PENDING → PROCESSING → DONE | FAILED),
  errorMessage, createdAt, updatedAt
```

---

## Docker & Containerization

All three application components are containerized. EC2 instances run the application entirely inside Docker containers

---

## AWS Infrastructure

> **Note:** The infrastructure decisions in this project are made to maximize **learning exposure** across as many AWS services and patterns as possible — not to be a production-ready, cost-optimized, or highly-available system. Some choices would be made differently in a real production environment.

### AWS Services Used

| # | Service | Purpose |
|---|---------|---------|
| 1 | **VPC** | Isolated network with public, private, and isolated subnets |
| 2 | **EC2** | Compute for backend and frontend (via Auto Scaling Groups) |
| 3 | **Auto Scaling** | Manages EC2 instance lifecycle and launch templates |
| 4 | **Elastic Load Balancing (NLB)** | TLS termination and traffic distribution to EC2 instances |
| 5 | **RDS (MySQL)** | Relational database for users, images, and jobs |
| 6 | **S3** | Object storage for user images and CI/CD pipeline artifacts |
| 7 | **Lambda** | Serverless image processing triggered by SQS |
| 8 | **SQS** | Message queue for async job dispatch from backend to Lambda |
| 9 | **SNS** | Pub/sub notifications from Lambda back to the backend webhook |
| 10 | **CloudFront** | CDN for frontend delivery and private S3 image serving |
| 11 | **Route53** | DNS hosted zone and alias records for all domains |
| 12 | **ACM** | TLS certificates for NLB listeners and CloudFront distributions |
| 13 | **IAM** | Roles and least-privilege policies for every service |
| 14 | **Secrets Manager** | Encrypted storage for DB password and JWT secret |
| 15 | **SSM Parameter Store** | App config injection into EC2 instances at boot |
| 16 | **CodePipeline** | Orchestrates the CI/CD pipeline for each repo |
| 17 | **CodeBuild** | Builds Docker images and Lambda packages |
| 18 | **CodeDeploy** | Deploys to EC2 (in-place) and Lambda (blue/green) |
| 19 | **CodeConnections** | GitHub OAuth integration for pipeline source stage |
| 20 | **CloudWatch Logs** | Build and application logs from CodeBuild and Lambda |

### Region & Environments

- **Region:** `eu-west-3` (Paris)
- **Availability Zones:** `eu-west-3a`, `eu-west-3b`
- **Environments:** `dev`, `staging`, `qc`, `prod`
- **Naming convention:** All resources are prefixed `pixlize-{env}-*` (e.g., `pixlize-prod-vpc`)
- **Deployment:** A single `deploy.sh` provisions the entire stack in the correct dependency order

### Networking — VPC

```
VPC: 10.0.0.0/16  (pixlize-{env}-vpc)
│
├── Public Subnets (internet-facing via IGW)
│   ├── public-1  10.0.1.0/24  eu-west-3a  ← NLBs, NAT Gateway
│   └── public-2  10.0.2.0/24  eu-west-3b  ← NLBs
│
├── Private Subnets (outbound via NAT)
│   ├── private-1  10.0.3.0/24  eu-west-3a  ← EC2 (backend, frontend ASG)
│   └── private-2  10.0.4.0/24  eu-west-3b  ← EC2 (backend, frontend ASG)
│
└── Isolated Subnets (no internet access)
    ├── private-3  10.0.5.0/24  eu-west-3a  ← RDS subnet group
    └── private-4  10.0.6.0/24  eu-west-3b  ← RDS subnet group

Gateways:
  Internet Gateway (IGW) — pixlize-{env}-igw
  NAT Gateway            — pixlize-{env}-nat  (in public-1, Elastic IP allocated)

Route Tables:
  public-route-table      → 0.0.0.0/0 via IGW  (attached to public-1, public-2)
  private-nat-route-table → 0.0.0.0/0 via NAT  (attached to private-1, private-2)
  private-route-table     → no internet route   (attached to private-3, private-4)
```

### Security Groups

| Security Group | Inbound Rule | Notes |
|---------------|-------------|-------|
| `{prefix}-app-back-end` | TCP 80 from `0.0.0.0/0` | Backend EC2 instances; NLB forwards here |
| `{prefix}-load-balancer-back-end` | TCP 443 from `0.0.0.0/0` | Backend NLB; terminates TLS |
| `{prefix}-app-front-end` | TCP 80 from `0.0.0.0/0` | Front EC2 instances; NLB forwards here |
| `{prefix}-load-balancer-front-end` | TCP 443 from CloudFront prefix list `pl-75b1541c` | Frontend NLB; only CloudFront IPs |
| `{prefix}-db` | TCP 3306 from `{prefix}-app-back-end` SG | RDS MySQL; backend only, no public access |

The frontend security groups use the managed AWS CloudFront IP prefix list, ensuring the NLB and EC2 instances only accept traffic originating from CloudFront edge nodes.

### Compute — EC2 & Auto Scaling

Two Auto Scaling Groups manage EC2 instances for backend and frontend independently.

| Property | Backend | Frontend |
|----------|---------|---------|
| AMI | `ami-0be40a46b4111e7f5` (Ubuntu) | same |
| Instance type | `t2.medium` | `t2.medium` |
| Subnets | `private-1`, `private-2` | `private-1`, `private-2` |
| Min / Max / Desired | 1 / 1 / 5 | 1 / 1 / 3 |
| Health check grace | 600 seconds | 600 seconds |
| Security group | `app-back-end` | `app-front-end` |

**Launch Template configuration:**
- Root volume: 15 GB gp3
- EC2 key pairs stored in `~/{app}_key_pairs/`

**User Data (runs on first boot):**
1. Installs AWS CLI, Docker, Ruby 3.2, CodeDeploy agent
2. Fetches DB credentials and JWT secret from **Secrets Manager**
3. Fetches app config from **SSM Parameter Store**
4. Substitutes values and writes `.env` file to disk
5. CodeDeploy agent starts and waits for pipeline deployments

### Load Balancing — NLB

Two Network Load Balancers sit in public subnets and terminate TLS before forwarding traffic to EC2.

| Property | Value |
|----------|-------|
| Type | Network Load Balancer (internet-facing) |
| Listener port | 443 (TLS) |
| SSL policy | `ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09` |
| Target protocol | TCP port 80 |
| Health check interval | 10 seconds |
| Healthy threshold | 2 consecutive successes |
| Unhealthy threshold | 4 consecutive failures |

- **Backend NLB** (`{prefix}-back-elb`) — forwards to backend EC2 target group
- **Frontend NLB** (`{prefix}-front-elb`) — forwards to frontend EC2 target group
- NLB DNS names are registered in Route53 as alias A records

### Database — RDS

| Property | Value |
|----------|-------|
| Engine | MySQL |
| Instance class | `db.t3.micro` |
| Storage | 20 GB gp3 |
| Database name | `pixlize_{env}_db` |
| Master username | `admin` |
| Password | Auto-generated, stored in **Secrets Manager** |
| Subnets | `private-3`, `private-4` (isolated — no internet route) |
| Security group | `{prefix}-db` (inbound from backend SG only) |
| Public access | Disabled |

The master password is never set manually — AWS generates it and stores it in Secrets Manager. The user data script on EC2 retrieves it at boot time.

### Storage — S3

| Bucket | Purpose |
|--------|---------|
| `pixlize-{env}-app-bucket-{account_id}` | User images (originals + processed results) |
| `pixlize-{env}-app-back-pipeline-bucket-{account_id}` | CodePipeline artifacts — backend |
| `pixlize-{env}-app-front-pipeline-bucket-{account_id}` | CodePipeline artifacts — frontend |
| `pixlize-{env}-app-lambda-pipeline-bucket-{account_id}` | CodePipeline artifacts — Lambda |

- All buckets: **public access fully blocked**
- App bucket: accessible only via CloudFront with **Origin Access Control (OAC, SigV4)** — no direct S3 URLs exposed to users

### Messaging — SQS & SNS

**SQS Queue** — `pixlize-{env}-app-queue`
- Backend sends a job message when a user submits a processing request
- Message format: `{ jobId, userId, operation, params, sourceS3Key }`
- Lambda consumes messages via event source mapping (SQS trigger)

**SNS Topic** — `pixlize-{env}-app-topic`
- Lambda publishes job completion or failure events
- One HTTPS subscription: delivers to `POST https://api.pixlize.{domain}/webhooks/sns`
- Backend verifies the SNS subscription handshake, then processes incoming notifications

**Async flow:**
```
Backend ──SQS──► Lambda ──SNS──► Backend webhook ──Socket.io──► Frontend
```

### Serverless — Lambda

| Property | Value |
|----------|-------|
| Runtime | Python 3.12 |
| Handler | `handler.lambda_handler` |
| Trigger | SQS event source mapping (`pixlize-{env}-app-queue`) |
| Alias | `live` (CodeDeploy manages traffic shifting between versions) |
| Deployment | Blue/Green via CodeDeploy Lambda (`LambdaAllAtOnce`) |

**Environment variables injected at creation:**
- `S3_BUCKET_NAME` — image storage bucket
- `SNS_TOPIC_ARN` — notification topic
- `MY_AWS_REGION` — AWS region

**Processing pipeline (per SQS message):**
1. Download source image from S3
2. Apply operation using Pillow (PIL)
3. Upload result to S3 at `{userId}/{jobId}-result.{format}`
4. Publish success or failure notification to SNS

**Image operations implemented in Python:**
- `filter` — grayscale (L→RGB), Gaussian blur, sharpen, brightness/contrast via `ImageEnhance`
- `crop` — coordinate clamping to image bounds
- `rotate` — clockwise rotation with auto-expand
- `compress` — JPEG/WebP quality encoding (1–100)
- `convert` — format conversion with RGBA→RGB flattening (white background) for JPEG/BMP

### CDN — CloudFront

Two distributions serve different origins:

**Distribution 1 — Frontend (`pixlize.{domain}`)**
- Origin: Frontend NLB (`front.pixlize.{domain}`) over HTTPS
- Viewer protocol: Redirect HTTP → HTTPS
- Cache TTL: min 0s / default 300s / max 3600s
- Allowed methods: GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE
- ACM certificate in `us-east-1` (CloudFront requirement)
- The NLB's security group only accepts traffic from the CloudFront managed prefix list (`pl-75b1541c`), so the NLB is not reachable directly from the internet

**Distribution 2 — S3 Images (`bucket.pixlize.{domain}`)**
- Origin: S3 bucket (private)
- Origin Access Control (OAC) with SigV4 signing — CloudFront signs requests to S3
- S3 bucket policy grants read access only to this distribution's ARN
- Users receive `bucket.pixlize.{domain}/...` URLs — never raw S3 URLs
- ACM certificate in `us-east-1`

### DNS — Route53

**Hosted Zone:** `alkady.link`

| Record | Type | Target |
|--------|------|--------|
| `api.pixlize.{domain}` | A (Alias) | Backend NLB |
| `front.pixlize.{domain}` | A (Alias) | Frontend NLB (CloudFront origin, not public-facing) |
| `pixlize.{domain}` | A (Alias) | CloudFront — frontend distribution |
| `bucket.pixlize.{domain}` | A (Alias) | CloudFront — S3 distribution |

**Environment domains:**
- Prod: `pixlize.alkady.link`, `api.pixlize.alkady.link`, `bucket.pixlize.alkady.link`
- Dev: `pixlize.dev.alkady.link`, `api.pixlize.dev.alkady.link`, `bucket.pixlize.dev.alkady.link`
- Staging: `pixlize.staging.alkady.link`, `api.pixlize.staging.alkady.link`, `bucket.pixlize.staging.alkady.link`
- QC: `pixlize.qc.alkady.link`, `api.pixlize.qc.alkady.link`, `bucket.pixlize.qc.alkady.link`

Certificate validation CNAME records are also automatically created in Route53 during ACM provisioning.

### Certificates — ACM

| Certificate Domain | Region | Used By |
|-------------------|--------|---------|
| `api.pixlize.{domain}` | `eu-west-3` | Backend NLB TLS listener |
| `front.pixlize.{domain}` | `eu-west-3` | Frontend NLB TLS listener |
| `pixlize.{domain}` | `us-east-1` | CloudFront frontend distribution |
| `bucket.pixlize.{domain}` | `us-east-1` | CloudFront S3 distribution |

All certificates use **DNS validation** — the deploy script retrieves the CNAME record from ACM and creates it in Route53 automatically, then polls until the certificate reaches `ISSUED` status.

### Secrets & Config

**AWS Secrets Manager** (encrypted, versioned):
- `{prefix}-app-db-secret` — RDS master password (auto-generated by AWS)
- `{prefix}-app-back-jwt-secret` — JWT signing secret (64-byte random hex, generated at deploy time)

**SSM Parameter Store** (String type, rebuilt each deploy):

*Backend config parameter* (`{prefix}-app-back-config`):
```
ENV=production
PORT=3000
DB_USER=<from Secrets Manager>
DB_PASS=<from Secrets Manager>
DB_HOST=<RDS endpoint>
DB_PORT=3306
DB_NAME=pixlize_prod_db
JWT_SECRET=<from Secrets Manager>
AWS_REGION=eu-west-3
S3_BUCKET_NAME=pixlize-prod-app-bucket-{account_id}
SQS_QUEUE_URL=https://sqs.eu-west-3.amazonaws.com/...
FRONTEND_URL=https://pixlize.alkady.link
CLOUD_FRONT_BUCKET_URL=https://bucket.pixlize.alkady.link
```

*Frontend config parameter* (`{prefix}-app-front-config`):
```
APP_ENV=production
APP_API_URL=https://api.pixlize.alkady.link
APP_WS_URL=https://api.pixlize.alkady.link
```

No secrets are hardcoded anywhere in the scripts or application code.

### IAM Roles

12 IAM roles are created with the principle of least privilege. Each service gets its own role with only the permissions it needs.

| Role | Trust Principal | Key Permissions |
|------|----------------|-----------------|
| `{prefix}-app-lambda-role` | `lambda.amazonaws.com` | S3 read/write (app bucket), SQS consume, SNS publish, CloudWatch logs |
| `{prefix}-app-back-instance-role` | `ec2.amazonaws.com` | Secrets Manager get (DB + JWT secrets), SSM get (backend config), S3 full (app + pipeline buckets), SQS send |
| `{prefix}-app-front-instance-role` | `ec2.amazonaws.com` | SSM get (frontend config), S3 get (pipeline bucket) |
| `{prefix}-app-back-codebuild-role` | `codebuild.amazonaws.com` | CloudWatch Logs, S3 get/put (backend pipeline bucket) |
| `{prefix}-app-front-codebuild-role` | `codebuild.amazonaws.com` | CloudWatch Logs, S3 get/put (frontend pipeline bucket) |
| `{prefix}-app-lambda-codebuild-role` | `codebuild.amazonaws.com` | CloudWatch Logs, S3 get/put, Lambda update-function-code + publish version |
| `{prefix}-app-back-codedeploy-...-role` | `codedeploy.amazonaws.com` | `AWSCodeDeployRole` managed policy |
| `{prefix}-app-front-codedeploy-...-role` | `codedeploy.amazonaws.com` | `AWSCodeDeployRole` managed policy |
| `{prefix}-app-lambda-codedeploy-...-role` | `codedeploy.amazonaws.com` | `AWSCodeDeployRoleForLambda` + S3 get |
| `{prefix}-app-back-codepipeline-role` | `codepipeline.amazonaws.com` | S3 artifacts, CodeConnections, CodeBuild start, CodeDeploy create-deployment |
| `{prefix}-app-front-codepipeline-role` | `codepipeline.amazonaws.com` | same pattern as backend |
| `{prefix}-app-lambda-codepipeline-role` | `codepipeline.amazonaws.com` | same pattern as backend |

---

## CI/CD Pipeline

Three fully automated pipelines deploy backend, frontend, and Lambda independently. Pushing to `main` in any repo triggers its pipeline automatically.

### Pipeline Flow

```
Developer pushes to main branch
        │
        ▼
   GitHub (source)
        │
        ▼
  CodePipeline (orchestrator)
        │
        ├──► Stage 1: Source
        │     └── CodeStar Connection pulls repo, creates SourceOutput artifact
        │
        ├──► Stage 2: Build (CodeBuild)
        │     └── Builds Docker image or Lambda zip, creates BuildOutput artifact
        │
        └──► Stage 3: Deploy (CodeDeploy)
              └── Deploys to EC2 ASG (in-place) or Lambda (blue/green)
```

**GitHub Integration:**
- AWS CodeConnections (`pixlize-app-github-connection`) authenticates with GitHub via OAuth
- Triggers automatically on push to `main` branch in each repository
- Execution mode: `QUEUED` (queues concurrent triggers, doesn't cancel)

### Backend Pipeline

**CodeBuild** (`{prefix}-app-back-codebuild`):
- Runtime: `amazonlinux-x86_64-standard:6.0`, `BUILD_GENERAL1_MEDIUM`
- Reads `buildspec.yml` from repo root
- Builds Docker image from `node:20-alpine`
- Saves image as `app-image.tar`
- Outputs: `app-image.tar`, `appspec.yml`, `deploy_scripts/*`
- Logs to CloudWatch: `/aws/codebuild/{prefix}-app-back-codebuild`

**CodeDeploy** (`{prefix}-app-back-codedeploy-application`):
- Compute platform: EC2/On-premises
- Deployment type: IN_PLACE
- Config: `CodeDeployDefault.OneAtATime`
- Target: `{prefix}-back-asg` (Auto Scaling Group)
- Lifecycle hooks:
  - `BeforeInstall` — waits for user data completion
  - `AfterInstall` — runs `docker load < app-image.tar`
  - `ApplicationStart` — runs container: `docker run -d --env-file .env -p 80:3000`
  - `ApplicationStop` — stops and removes running container

### Frontend Pipeline

**CodeBuild** (`{prefix}-app-front-codebuild`):
- Same runtime configuration as backend
- Multi-stage Docker build:
  - Stage 1: `node` → `npm run build` → `/dist` (Vite production build)
  - Stage 2: `nginx:alpine` → serves `/dist` with SPA fallback routing

**CodeDeploy** (`{prefix}-app-front-codedeploy-application`):
- Identical lifecycle pattern to backend
- Container runs Nginx on port 80

### Lambda Pipeline

**CodeBuild** (`{prefix}-app-lambda-codebuild`):
- Uses `python:3.12` Docker image as build environment
- `build.sh` installs dependencies and extracts compiled Lambda code
- Zips output as `function.zip`
- Directly calls `aws lambda update-function-code` to push the zip
- Publishes a new Lambda version
- Environment variables injected: `FUNCTION_NAME`, `FUNCTION_ALIAS=live`
- Generates `appspec.yml` for traffic shifting

**CodeDeploy** (`{prefix}-app-lambda-codedeploy-application`):
- Compute platform: Lambda
- Deployment type: BLUE/GREEN
- Config: `CodeDeployDefault.LambdaAllAtOnce`
- Traffic control: WITH_TRAFFIC_CONTROL
- Shifts Lambda alias `live` from current version to new published version atomically

### Deployment Order

The single `deploy.sh` script provisions the full stack in this exact order (each step depends on the previous):

```
 1.  VPC + Subnets + Route Tables + IGW + NAT Gateway
 2.  Security Groups
 3.  RDS MySQL instance + subnet group
 4.  IAM Roles (all 12 roles and instance profiles)
 5.  S3 Buckets (app + 3 pipeline buckets)
 6.  SQS Queue
 7.  SNS Topic
 8.  Lambda function (initial dummy deploy) + SQS event source mapping
 9.  SSM Parameters + Secrets Manager secrets
10.  EC2 Key Pairs + Launch Templates (with user data)
11.  Network Load Balancers + Target Groups
12.  Route53 Hosted Zone + DNS A records (NLB aliases)
13.  ACM Certificates + DNS validation (CNAME in Route53, poll until ISSUED)
14.  NLB Listeners (TLS 443, attach certificates)
15.  Auto Scaling Groups
16.  GitHub CodeConnection (OAuth handshake)
17.  CodeBuild Projects
18.  CodeDeploy Applications + Deployment Groups
19.  CodePipelines (triggers first run automatically)
20.  SNS HTTPS Subscription → backend webhook
21.  CloudFront Distributions (frontend + S3 bucket)
```

---

## A Note on Production Readiness

The infrastructure decisions in this project are made to maximize **learning exposure** across as many AWS services and patterns as possible — not to be a production-ready, cost-optimized, or highly-available system. Some choices would be made differently in a real production environment.

---

## Skills Demonstrated

- **Bash scripting** — writing idempotent infrastructure automation scripts to provision and manage AWS resources
- **AWS CLI** — direct, hands-on experience with 20+ AWS services via CLI (not abstracted by Terraform or CDK); understanding of API parameters, resource dependencies, and ordering
- **Docker & containerization** — multi-stage builds, container lifecycle management via CodeDeploy hooks, Docker as a build environment for Lambda packaging
- **Networking** — VPC design, subnet tiering (public/private/isolated), NAT gateway routing, Internet Gateway, route tables, security group chaining
- **CI/CD pipeline design** — full GitHub → CodePipeline → CodeBuild → CodeDeploy pipelines for EC2 (in-place) and Lambda (blue/green) across 3 independent repos
- **Security** — IAM least-privilege roles per service, Secrets Manager for sensitive values, SSM Parameter Store for config, CloudFront prefix list lockdown, IMDSv2 enforcement, private subnet placement for compute and database
- **Serverless** — Lambda runtime, SQS event source mapping, Blue/Green deployment via CodeDeploy Lambda, alias traffic shifting
- **CDN & DNS** — CloudFront origin types (ALB, S3 OAC), viewer protocol policies, cache behaviors, Route53 alias records, ACM certificate automation with DNS validation
- **Multi-environment infrastructure** — dev / staging / qc / prod from a single codebase using config file sourcing
