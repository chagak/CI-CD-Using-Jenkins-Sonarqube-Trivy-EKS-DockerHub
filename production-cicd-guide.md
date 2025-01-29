# Production CI/CD Pipeline Setup Guide

## Phase 1: Infrastructure Setup

### 1. Network Configuration
```bash
# Create VPC with private/public subnets
aws ec2 create-vpc --cidr-block 10.0.0.0/16
# Set up NAT Gateway, Internet Gateway
# Configure route tables for private/public subnets
```

### 2. Security Setup
```bash
# Create KMS keys for encryption
aws kms create-key --description "CI/CD Pipeline Key"

# Set up AWS Secrets Manager for credentials
aws secretsmanager create-secret \
    --name "prod/cicd/credentials" \
    --secret-string "your-secrets-here"
```

### 3. EKS Cluster
```bash
eksctl create cluster \
    --name prod-cluster \
    --version 1.27 \
    --region us-west-2 \
    --nodegroup-name prod-nodes \
    --node-type t3.large \
    --nodes-min 3 \
    --nodes-max 7 \
    --with-oidc \
    --ssh-access \
    --ssh-public-key your-key \
    --managed \
    --asg-access \
    --external-dns-access \
    --full-ecr-access \
    --node-private-networking
```

### 4. EC2 Instances
- Jenkins: t3.large (min)
- SonarQube: t3.large (min)
Both with:
  - EBS volumes with encryption
  - IAM roles for service access
  - Placement in private subnets

## Phase 2: Tools Installation

### 1. Jenkins Setup
```bash
# Install required packages
sudo yum update -y
sudo yum install java-11-amazon-corretto-headless docker git -y

# Install Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum install jenkins -y

# Configure Jenkins security
sudo mkdir /var/lib/jenkins/init.groovy.d/
# Add security initialization scripts
```

### 2. SonarQube Setup
```bash
# Install PostgreSQL
sudo yum install postgresql postgresql-server -y
sudo postgresql-setup initdb

# Install SonarQube
sudo yum install unzip
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.x.zip
sudo unzip sonarqube-9.x.zip -d /opt
```

### 3. ArgoCD on EKS
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

## Phase 3: Security Hardening

### 1. Network Security
```bash
# Jenkins Security Group
aws ec2 create-security-group \
    --group-name jenkins-sg \
    --description "Jenkins Security Group"

# Allow only necessary ports
aws ec2 authorize-security-group-ingress \
    --group-id sg-xxx \
    --protocol tcp \
    --port 8080 \
    --cidr your-ip-range
```

### 2. IAM Policies
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:DescribeCluster",
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage"
            ],
            "Resource": "*"
        }
    ]
}
```

## Phase 4: Pipeline Configuration

### 1. Create Jenkinsfile
```groovy
pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "your-repo/app:${BUILD_NUMBER}"
        KUBE_CONFIG = credentials('eks-config')
    }
    stages {
        stage('Test') {
            parallel {
                stage('Unit Tests') { steps { ... } }
                stage('Integration Tests') { steps { ... } }
            }
        }
        stage('SonarQube Analysis') { ... }
        stage('Security Scan') { ... }
        stage('Build and Push') { ... }
        stage('Deploy to EKS') { ... }
    }
    post {
        always {
            junit '**/test-results/*.xml'
            cleanWs()
        }
    }
}
```

### 2. ArgoCD Application
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: production-app
spec:
  project: default
  source:
    repoURL: your-git-repo
    targetRevision: HEAD
    path: k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## Phase 5: Monitoring and Maintenance

### 1. Set up Monitoring
```bash
# Install Prometheus Operator
kubectl create namespace monitoring
helm install prometheus-stack prometheus-community/kube-prometheus-stack \
    --namespace monitoring

# Configure AlertManager
kubectl apply -f alertmanager-config.yaml
```

### 2. Backup Configuration
```bash
# Jenkins backup
aws s3 sync /var/lib/jenkins/ s3://backup-bucket/jenkins/

# Database backup
pg_dump sonarqube > backup.sql
aws s3 cp backup.sql s3://backup-bucket/sonarqube/
```

## Phase 6: Pipeline Testing & Validation

1. Test complete pipeline flow
2. Verify security configurations
3. Test failure scenarios
4. Validate monitoring alerts
5. Verify backup/restore procedures

## Best Practices

1. Use separate environments (dev/staging/prod)
2. Implement automated rollbacks
3. Use infrastructure as code
4. Regular security audits
5. Maintain detailed documentation
6. Implement proper logging
7. Regular backup testing
8. Disaster recovery plan
