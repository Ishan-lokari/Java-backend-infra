output "vpc" {
  value       = module.vpc_network.network_name
  description = "name of the vpc created"
}

output "subnet_1" {
  value       = module.vpc.subnets["asia-south1/subnet-01"].id
  description = "Returns the full resource ID path for subnet-01"
}

output "subnet_2" {
  value       = module.vpc.subnets["asia-south1/subnet-02"].id
  description = "Returns the full resource ID path for subnet-02"
}

output "rules" {
  value       = module.firewall_rules.firewall_rules
  description = "rules created for the subnets"
}

output "artifact_registry_url" {
  value       = "${var.artifact_registry_location}-docker.pkg.dev/${var.project_id}/${var.artifact_registry_name}"
  description = "url of the artifact registry"
}