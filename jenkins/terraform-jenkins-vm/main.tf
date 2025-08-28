#############################################
# Proveedores y versiones requeridas
#############################################
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
  }
}

#############################################
# Provider de Google
#############################################
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

#############################################
# Detección automática de tu IP pública
# (se usa si allowed_ip_ranges está vacío)
#############################################
data "http" "my_ip" {
  url             = "https://api.ipify.org"
  request_headers = { Accept = "text/plain" }
}

locals {
  # IP del ejecutor /32 (quita saltos con chomp)
  my_ip_cidr = "${chomp(data.http.my_ip.response_body)}/32"

  # Si NO defines allowed_ip_ranges, se usa la IP detectada.
  effective_allowlist = length(var.allowed_ip_ranges) > 0 ? var.allowed_ip_ranges : [local.my_ip_cidr]

  # Subred "default" en la región (VPC auto). Cadena literal (no hace llamadas previas).
  default_subnet_self_link = "projects/${var.project_id}/regions/${var.region}/subnetworks/default"
}

#############################################
# Habilitar Compute API (no apagar al destruir)
#############################################
resource "google_project_service" "compute" {
  project            = var.project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

#############################################
# Cuenta de servicio para la VM
#############################################
resource "google_service_account" "vm_sa" {
  account_id   = "${var.name_prefix}-vm-sa"
  display_name = "SA for VM"
}

# Permitir que la SA que corre Terraform use la SA de la VM
resource "google_service_account_iam_binding" "vm_sa_user" {
  service_account_id = google_service_account.vm_sa.name
  role               = "roles/iam.serviceAccountUser"
  members            = ["serviceAccount:${var.caller_sa_email}"]
}

#############################################
# Instancia (e2-small) con IP pública y startup script
#############################################
resource "google_compute_instance" "vm" {
  name         = "${var.name_prefix}-vm"
  project      = var.project_id
  zone         = var.zone
  machine_type = var.machine_type # por default: e2-small
  tags         = ["ssh", "jenkins"]

  # Permite detener la VM para aplicar cambios (resize/metadata)
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.boot_image
      size  = var.boot_disk_gb
      type  = "pd-standard" # Free Tier friendly
    }
  }

  network_interface {
    subnetwork = local.default_subnet_self_link
    access_config {} # ✅ IP pública efímera
  }

  # OS Login (recomendado)
  metadata = {
    enable-oslogin = "TRUE"
  }

  # Startup script idempotente:
  # - Crea swap (1GB) si no existe
  # - Aumenta timeout de systemd (evita "start operation timed out")
  # - Instala Jenkins si no está; si ya está, solo lo habilita/arranca
  metadata_startup_script = <<-EOT
    #!/usr/bin/env bash
    set -euxo pipefail
    export DEBIAN_FRONTEND=noninteractive

    # 1) Swap 1GB si no existe
    if [ ! -f /swapfile ]; then
      fallocate -l 1G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=1024
      chmod 600 /swapfile
      mkswap /swapfile
      swapon /swapfile
      grep -q '/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
    fi

    # 2) Aumentar timeout de systemd para Jenkins
    mkdir -p /etc/systemd/system/jenkins.service.d
    cat >/etc/systemd/system/jenkins.service.d/override.conf <<'OVR'
    [Service]
    TimeoutStartSec=15min
    RestartSec=5s
    OVR
    systemctl daemon-reload || true

    # 3) Instalar Jenkins (idempotente)
    if ! dpkg -s jenkins >/dev/null 2>&1; then
      apt-get update
      apt-get install -y fontconfig openjdk-17-jre curl gnupg
      curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
        | tee /usr/share/keyrings/jenkins-keyring.asc >/dev/null
      echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
        > /etc/apt/sources.list.d/jenkins.list
      apt-get update
      apt-get install -y jenkins
    fi

    systemctl enable --now jenkins
  EOT

  service_account {
    email = google_service_account.vm_sa.email
    scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
    ]
  }

  labels = {
    env   = var.env
    owner = var.owner
  }

  depends_on = [
    google_project_service.compute,
    google_service_account_iam_binding.vm_sa_user
  ]
}

#############################################
# Firewalls (SSH 22 y Jenkins 8080)
# Usa allowlist efectiva (tu IP /32 por defecto)
#############################################
resource "google_compute_firewall" "allow_ssh" {
  name      = "${var.name_prefix}-allow-ssh"
  project   = var.project_id
  network   = "projects/${var.project_id}/global/networks/default"
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = local.effective_allowlist
  target_tags   = ["ssh"]

  depends_on = [google_project_service.compute]
}

resource "google_compute_firewall" "allow_jenkins_8080" {
  name      = "${var.name_prefix}-allow-jenkins-8080"
  project   = var.project_id
  network   = "projects/${var.project_id}/global/networks/default"
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = local.effective_allowlist
  target_tags   = ["jenkins"]

  depends_on = [google_project_service.compute]
}
