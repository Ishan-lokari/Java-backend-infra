
#create vpc
module "vpc_network" {
  source  = "terraform-google-modules/network/google//modules/vpc"
  version = "~> 18.1"

  project_id   = var.project_id
  network_name = var.network_name

  shared_vpc_host = false
}


# subnet creation subnet-01 (10.10.0.0/24) and subnet-02 (10.20.0.0/24)
module "vpc" {
  source  = "terraform-google-modules/network/google//modules/subnets"
  version = "~> 18.0"

  project_id   = var.project_id
  network_name = module.vpc_network.network_name

  subnets = [
    {
      subnet_name           = "subnet-01"
      subnet_ip             = "10.10.0.0/24"
      subnet_region         = "asia-south1"
      subnet_private_access = true
      description           = "This subnet is only for deployment of code"
    },
    {
      subnet_name           = "subnet-02"
      subnet_ip             = "10.20.0.0/24"
      subnet_region         = "asia-south1"
      subnet_private_access = true
      description           = "This subnet has the backend and db vm"
    }
  ]
}

#firewall rules for jenkins-vm , backend-vm and db-vm 

module "firewall_rules" {
  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  project_id   = var.project_id
  network_name = module.vpc_network.network_name

  rules = [
    # ingress traffic to backend from jenkins
    {
      name                    = "allow-jenkins-backend"
      description             = null
      direction               = "INGRESS"
      priority                = null
      destination_ranges      = null
      source_ranges           = ["10.10.0.0/24"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = ["backend-vm"]
      target_service_accounts = null
      allow = [{
        protocol = "tcp"
        ports    = ["22", "80"]
        }, {
        protocol = "icmp"
        ports    = null
      }]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
    # ingress traffic to db from backend
    {
      name                    = "allow-backend-db"
      description             = null
      direction               = "INGRESS"
      priority                = null
      destination_ranges      = null
      source_ranges           = ["10.20.0.0/24"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = ["db-vm"]
      target_service_accounts = null
      allow = [{
        protocol = "tcp"
        ports    = ["22", "3000", "3306"]
        }, {
        protocol = "icmp"
        ports    = null
      }]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },

    #iap ssh for all vms
    {
      name                    = "allow-iap-ssh"
      description             = null
      direction               = "INGRESS"
      priority                = null
      destination_ranges      = null
      source_ranges           = ["35.235.240.0/20"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = ["jenkins-vm", "backend-vm", "db-vm"]
      target_service_accounts = null
      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
    # ingress traffic to backend from loadbalancer
    {
      name                    = "allow-lb-backend"
      description             = null
      direction               = "INGRESS"
      priority                = null
      destination_ranges      = null
      source_ranges           = ["130.211.0.0/22", "35.191.0.0/16"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = ["backend-vm"]
      target_service_accounts = null
      allow = [{
        protocol = "tcp"
        ports    = ["80"]
        }, {
        protocol = "icmp"
        ports    = null
      }]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    } ,
    
    #allow port 8080 for jenkins from anywhere
    {
      name                    = "allow-jenkins"
      description             = null
      direction               = "INGRESS"
      priority                = null
      destination_ranges      = null
      source_ranges           = ["0.0.0.0/0"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = ["jenkins-vm"]
      target_service_accounts = null
      allow = [{
        protocol = "tcp"
        ports    = ["8080"]
      }]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    }
  ]
}

#default route for nat
resource "google_compute_route" "gcp_internet_route" {
  name             = "vpc-internet-route"
  dest_range       = "0.0.0.0/0"
  network          = module.vpc_network.network_name
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
  project          = var.project_id
}





## cloud router and cloud nat for subnet-02
module "cloud_nat" {
  source  = "terraform-google-modules/cloud-nat/google"
  version = "~> 5.0"

  project_id = var.project_id
  region     = "asia-south1"
  name       = "nat-subnet-02"
  network    = module.vpc_network.network_name

  create_router = true
  router        = "router-asia-south1"

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetworks = [
    {
      name                    = module.vpc.subnets["asia-south1/subnet-02"].id
      source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE"]

      secondary_ip_range_names = []
    }
  ]
}


#artifact registry for storing of the java application docker image
resource "google_artifact_registry_repository" "backend" {
  location      = var.artifact_registry_location
  repository_id = var.artifact_registry_name
  format        = var.artifact_registry_format
  project       = var.project_id
}