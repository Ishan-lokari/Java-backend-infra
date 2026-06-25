variable "backend_name" {
    type = string
  default = "backend-vm"
  description = "name of my backend vm  "
}

variable "db_name" {
    type = string
  default = "db-vm"
  description = "name of my db vm"
}

variable "project_id" {
  type = string
  default = "ishan-project-493907"
  description = "my project id"
}

variable "machine_type" {
    type = string
    description = "the machine type used by my vm "
  
}
variable "zone" {
  type = string
  description = "my project region"
  default = "asia-south1-a"
}


variable "service_account_email" {
  description = "service account for accessing the values from secret manager"
}

variable "backend_group_name" {
  type = string
  description = "unmanaged backend group name"
  default = "backend-unmanaged-group"
}

variable "app_port" {
  type = number
  description = "application port"
  default = 80
}

variable "lb_name" {
  type = string
  description = "my lb name"
  default = "backend-lb"
}