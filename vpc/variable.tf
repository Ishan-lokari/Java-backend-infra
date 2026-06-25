variable "project_id" {
  type        = string
  description = "my project id"
}

variable "region" {
  type        = string
  description = "my project region"
}

variable "network_name" {
  type        = string
  description = "vpc name"

}

variable "artifact_registry_name" {
  type        = string
  description = "name of the artifact registry repository"
}

variable "artifact_registry_location" {
  type        = string
  description = "location of the artifact registry repository"
}

variable "artifact_registry_format" {
  type        = string
  description = "format of the artifact registry repository"
}