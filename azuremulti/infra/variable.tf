variable "environment" {
  description = "The environment for the deployment"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "The location (region) where the resources will be deployed"
  type        = string
  default     = "East US"
}

variable "instance_count" {
  description = "This is the count of the no. of instances I need"
  type = number
}
