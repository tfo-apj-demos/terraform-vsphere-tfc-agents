variable "organization" {
  description = "The Terraform Cloud organization name."
  type        = string
}

variable "agent_count" {
  description = "Number of Terraform agents to deploy."
  type = number
  default = 3
}