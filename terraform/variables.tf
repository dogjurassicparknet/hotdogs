variable "project_id" {
  description = "Google Cloud Project ID"
}

variable "region" {
  description = "Google Cloud Region"
}

variable "num_nodes" {
  description = "Number of nodes in the GKE cluster"
  type        = number
  default     = 1
}
