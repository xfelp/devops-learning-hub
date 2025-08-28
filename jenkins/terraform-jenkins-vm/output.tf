output "instance_name" {
  description = "Nombre de la instancia"
  value       = google_compute_instance.vm.name
}

output "instance_self_link" {
  description = "Self link de la instancia"
  value       = google_compute_instance.vm.self_link
}

output "external_ip" {
  description = "IP pública (si se asignó access_config)"
  value       = try(google_compute_instance.vm.network_interface[0].access_config[0].nat_ip, null)
}

output "jenkins_url" {
  description = "URL para acceder a Jenkins (cuando esté instalado)"
  value       = try(format("http://%s:8080", google_compute_instance.vm.network_interface[0].access_config[0].nat_ip), null)
}

output "ssh_example" {
  description = "Comando SSH sugerido (OS Login habilitado)"
  value       = "gcloud compute ssh ${google_compute_instance.vm.name} --zone ${var.zone}"
}
