variable "aws_region" {
  type        = string
  default     = "us-east-2"
  description = "primary aws cloud region "

}

variable "gcp_region" {
  type        = string
  default     = "us-central1"
  description = "secondary gcp cloud region "

}

variable "gcp_project_id" {
  type        = string
  default     = "multi-cloud-demo-project"
  description = "google cloud project id"


}