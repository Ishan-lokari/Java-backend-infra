variable "name" {
  type        = string
  default     = "jenkins-vm"
  description = "name of my vm with jenkins installed"
}

variable "project_id" {
  type        = string
  description = "my project id"
}

variable "machine_type" {
  type        = string
  description = "the machine type used by my vm "

}
variable "zone" {
  type        = string
  description = "my project region"
}


