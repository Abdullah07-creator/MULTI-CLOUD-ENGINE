🌐 Multi-Cloud Production Architecture & Disaster Recovery Engine
An enterprise-grade, dual-cloud deployment engine designed for zero-downtime high availability. Provisioned declaratively via Terraform across AWS (Primary) and GCP (Secondary), the system features automated vulnerability scanning, immutable container publishing, and active NGINX reverse-proxy health routing for dynamic failover
Repository Structure
Plaintext
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
