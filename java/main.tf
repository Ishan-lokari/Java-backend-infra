data "terraform_remote_state" "vpc_data" {
  backend = "local"

  config = {
    path = "../vpc/terraform.tfstate"
  }
}

#backend vm creation with docker setup
resource "google_compute_instance" "backend" {
  name                      = var.backend_name
  machine_type              = var.machine_type
  zone                      = var.zone
  project                   = var.project_id
  allow_stopping_for_update = true

  tags = [var.backend_name]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    subnetwork = data.terraform_remote_state.vpc_data.outputs.subnet_2
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = file("${path.module}/docker.sh")
}


#db vm creation with mysql setup
resource "google_compute_instance" "db" {
  name                      = var.db_name
  machine_type              = var.machine_type
  zone                      = var.zone
  project                   = var.project_id
  allow_stopping_for_update = true

  tags = [var.db_name]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    subnetwork = data.terraform_remote_state.vpc_data.outputs.subnet_2
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = file("${path.module}/mysql.sh")
}

#backend-group for attaching backend vm to lb

resource "google_compute_instance_group" "backend" {
  name    = var.backend_group_name
  zone    = var.zone
  project = var.project_id

  instances = [google_compute_instance.backend.self_link]

  named_port {
    name = "http"
    port = var.app_port
  }
}

#load balancer for my backend service public facing

module "gce-lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google"
  version = "~> 9.0"

  project     = var.project_id
  name        = var.lb_name
  target_tags = [var.backend_name]

  backends = {
    default = {
      port        = var.app_port
      protocol    = "HTTP"
      port_name   = "http"
      timeout_sec = 10
      enable_cdn  = false

      health_check = {
        request_path = "/health"
        port         = var.app_port
      }

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      groups = [
        {
          group = google_compute_instance_group.backend.self_link
        }
      ]

      iap_config = {
        enable = false
      }

    }
  }
}
