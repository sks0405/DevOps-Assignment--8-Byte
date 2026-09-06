# DevOps Assignment - 

This project sets up a small AWS environment for running a containerized Python Flask application.
Terraform is used to create the infrastructure and GitHub Actions is used to test, scan, build and deploy the application.
The main goal was to keep the setup simple enough to understand and maintain while still following common DevOps practices.

 Project Structure - 
 
├── application/
│   ├── app.py
│   ├── Dockerfile
│   ├── requirements.txt
│   └── tests/
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── backend.tf
│   ├── versions.tf
│   └── modules/
│       ├── networking/
│       ├── security/
│       ├── compute/
│       ├── rds/
│       └── alb/
│
└── .github/
    └── workflows/
        └── ci.yaml

# Application - 

The application is a small Flask service running on port `8080`.
It provides two endpoints:
* `/` - returns a simple application message
* `/health` - returns the application health status

The application is packaged as a Docker image so that the same image can be used across environments.

# Infrastructure - 

The AWS infrastructure is created using Terraform.

The setup includes:

* VPC
* Public and private subnets across two Availability Zones
* Internet Gateway
* Application Load Balancer
* EC2 instance for running the application
* PostgreSQL RDS instance
* Security groups
* Terraform remote state in S3

Terraform is split into modules so that networking, security, compute, database and load balancer resources can be maintained separately.

The basic architecture is:

```text
                    Internet
                       |
                       v
              Application Load
                  Balancer
                       |
                       v
                     EC2
                       |
                 Docker Container
                       |
                       v
                  Flask App
                       |
                       v
                 RDS PostgreSQL
```

Setting Up the Infrastructure

### 1. Configure AWS credentials

Configure AWS credentials locally before running Terraform.

For example:

```bash
aws configure
```

The IAM identity used for Terraform should have permission to create the required resources.

### 2. Configure Terraform variables

Create a local `terraform.tfvars` file inside the `terraform` directory.

Example:

```hcl
aws_region    = "ap-south-1"
project_name  = "devops-assignment"
environment   = "staging"
vpc_cidr      = "10.0.0.0/16"
app_port      = 8080
instance_type = "t3.micro"

db_password = "CHANGE_ME"
```

The actual `terraform.tfvars` file is not committed to Git because it contains sensitive information.

### 3. Initialize Terraform

```bash
cd terraform
terraform init
```

### 4. Check the configuration

```bash
terraform fmt -recursive
terraform validate
```

### 5. Review the changes

```bash
terraform plan
```

Always review the plan before applying infrastructure changes.

### 6. Create the infrastructure

```bash
terraform apply
```

Terraform will create the AWS resources and display the configured outputs after a successful deployment.

## CI/CD Pipeline

GitHub Actions is used for the application pipeline.

The pipeline runs when code is pushed to `main` or when a pull request is opened against `main`.

The current flow is:

```text
Pull Request / Push
        |
        v
      Tests
        |
        v
   Docker Build
        |
        v
    Trivy Scan
        |
        v
 Docker Image Push
        |
        v
 Deploy to Staging
        |
        v
 Production Approval
```

### Tests

Python dependencies are installed and the unit and integration tests are executed using `pytest`.

### Docker Build

A multi-stage Dockerfile is used to build the application image.

The final image contains only what is required to run the application, rather than the complete build environment.

### Security Scan

Trivy is used to scan the Docker image for vulnerabilities.

The pipeline checks for HIGH and CRITICAL vulnerabilities.

### Docker Registry

After the tests and security checks pass, the Docker image is pushed to Docker Hub.

The image is tagged using the Git commit SHA. This makes it possible to identify exactly which application version was deployed.

### Deployment

The deployment stage connects to the AWS EC2 instance and runs the Docker image there.

The EC2 instance is responsible for running the application container. The GitHub Actions Ubuntu runner is only used temporarily to execute the pipeline.

## Security Considerations

A few basic security measures have been included in the setup.

### Security Groups

The ALB accepts HTTP traffic from the internet.

The application EC2 security group allows application traffic only from the ALB security group instead of allowing port `8080` from the entire internet.

The RDS security group allows PostgreSQL traffic only from the application security group.

This keeps the database from being directly accessible from the internet.

### Secrets

Sensitive values such as the database password, Docker Hub credentials and deployment SSH key are not stored directly in the Git repository.

Terraform variables containing secrets are kept in the local `terraform.tfvars` file, which is excluded using `.gitignore`.

GitHub Actions credentials are stored as GitHub repository secrets.

Examples include:

```text
DOCKERHUB_USERNAME
DOCKERHUB_TOKEN
EC2_HOST
EC2_SSH_KEY
SLACK_WEBHOOK_URL
```

The values themselves are never committed to the repository.

### Docker Image Scanning

Trivy is included in the CI pipeline to identify known vulnerabilities in the Docker image before it is pushed and deployed.

## Backup Strategy

RDS automated backups are enabled with a retention period of 7 days.

This provides a recovery option in case data needs to be restored after an accidental change or failure.

The Terraform configuration also keeps the database private and prevents direct public access.

For a production environment, I would additionally consider longer backup retention and a separate backup strategy depending on the application's recovery requirements.

## Cost Optimization

The infrastructure is intentionally kept small because this is a development/staging assignment.

The main cost considerations are:

* Using `t3.micro` for the application EC2 instance.
* Using a small `db.t3.micro` RDS instance.
* Keeping RDS storage limited to the expected workload.
* Avoiding unnecessary high-end instances.
* Using a single application instance for this small workload.
* Using Terraform so resources can be easily removed when they are no longer required.

For a real production system, instance sizing and availability requirements would be reviewed based on actual traffic and performance metrics.

## Monitoring and logging
Monitoring and logging are currently being worked on as part of the assignment. The plan is to monitor the infrastructure and application using AWS CloudWatch and dashboards.
The monitoring setup will cover EC2 CPU, memory and disk utilization, along with application health and availability. 
Application-level metrics such as request count, error rate and response latency will also be monitored where applicable. RDS metrics such as CPU utilization, 
database connections and storage usage will be tracked to identify potential database-related issues

## Cleaning Up

When the environment is no longer required, Terraform can be used to remove the resources:

terraform destroy

The destroy plan should always be reviewed before confirming the operation.

## Notes

This project focuses on demonstrating the DevOps workflow rather than building a complex application.

The application itself is intentionally simple. The main focus is on infrastructure provisioning, containerization, CI/CD, security checks, deployment and operational practices.
