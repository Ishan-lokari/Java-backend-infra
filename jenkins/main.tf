data "terraform_remote_state" "vpc_data" {
  backend = "local"

  config = {
    path = "../vpc/terraform.tfstate"
  }
}

#creating jenkins vm for deployment 
resource "google_compute_instance" "default" {
  name         = var.name
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project_id

  tags = ["jenkins-vm"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-13"
      size = 20
      labels = {
        my_label = "value"
      }
    }
  }



  network_interface {
    subnetwork = data.terraform_remote_state.vpc_data.outputs.subnet_1

    access_config {

    }
  }


  metadata = {
    foo = "jenkins-vm"
  }

  metadata_startup_script = file("${path.module}/jenkins.sh")




}



