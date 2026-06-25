output "backend_vm_internal_ip" {
  value = google_compute_instance.backend.network_interface[0].network_ip
}

output "db_vm_internal_ip" {
  value = google_compute_instance.db.network_interface[0].network_ip
}

output "lb_ip" {
  value = module.gce-lb-http.external_ip
}