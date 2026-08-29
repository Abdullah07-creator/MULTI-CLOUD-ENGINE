🌐 Multi-Cloud Production Architecture & Disaster Recovery Engine
An enterprise-grade, dual-cloud deployment engine designed for zero-downtime high availability. Provisioned declaratively via Terraform across AWS (Primary) and GCP (Secondary), the system features automated vulnerability scanning, immutable container publishing, and active NGINX reverse-proxy health routing for dynamic failover

Repository Structure

multi-cloud-engine/
├── .github/
│   └── workflows/
│       └── deploy.yml          
├── app/
│   ├── app.py                
│   ├── Dockerfile              
│   └── requirements.txt       
├── nginx/
│   └── nginx.conf              
├── terraform/
│   ├── aws_primary.tf         
│   ├── gcp_secondary.tf        
│   ├── providers.tf            
│   └── variables.tf       
└── README.md    

Provision Infrastructure via Terraform

cd terraform

terraform init

terraform apply -auto-approve

Key Features & Technical Highlights

Multi-Provider IaC (Terraform): Declarative multi-cloud provisioning managing AWS EC2 resources (us-east-2) and GCP Cloud Run services (us-central1) within a unified .tfstate dependency graph.

Cost-Optimized Serverless Secondary: Utilizes serverless GCP Cloud Run as a secondary target to scale down to 0 instances when idle, avoiding continuous compute costs while guaranteeing instant failover readiness.

Active Proxy Failover (NGINX): Local reverse proxy configured with upstream passive health checks (max_fails=1, fail_timeout=2s), fast timeouts (proxy_connect_timeout 2s), and TLS Server Name Indication (proxy_ssl_server_name on;) for seamless SNI handshake routing to Google Cloud Run[cite: 1, 5].

Unified CI/CD Pipeline: GitHub Actions workflow executing Trivy vulnerability scanning, building container images tagged dynamically with Git commit SHAs (${{ github.sha }}), and pushing verified artifacts to GitHub Container Registry (GHCR)
