terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Habilitar la API de Compute (si es proyecto nuevo)
resource "google_project_service" "compute" {
  project = var.project_id
  service = "compute.googleapis.com"
}

# Cuenta de servicio dedicada para la VM (buena práctica)
resource "google_service_account" "vm_sa" {
  account_id   = "${var.name_prefix}-vm-sa"
  display_name = "SA for VM"
}

# Subred "default" explícita en la región dada (VPC en modo automático)
locals {
  default_subnet_self_link = "projects/${var.project_id}/regions/${var.region}/subnetworks/default"
}

# ==========================
#   VM Free Tier friendly
# ==========================
resource "google_compute_instance" "vm" {
  name         = "${var.name_prefix}-vm"
  project      = var.project_id
  zone         = var.zone
  machine_type = var.machine_type  # e2-micro recomendado para Free Tier
  tags         = ["ssh"]

  # Disco de arranque dentro del Free Tier (HDD estándar)
  boot_disk {
    initialize_params {
      image = var.boot_image             # p.ej. ubuntu-os-cloud/ubuntu-2204-lts
      size  = var.boot_disk_gb           # <= 30 GB para Free Tier
      type  = "pd-standard"              # HDD (no pd-balanced / no SSD)
    }
  }

  # Red por defecto SIN IP pública (no hay access_config {})
  network_interface {
    subnetwork = local.default_subnet_self_link
    # access_config {}  # <- INTENCIONALMENTE OMITIDO para evitar IP pública y costos
  }

  # OS Login habilitado (recomendado). Si usas IAP, conéctate con --tunnel-through-iap.
  metadata = {
    enable-oslogin = "TRUE"
  }

  # Cuenta de servicio con scopes mínimos (sin cloud-platform)
  service_account {
    email  = google_service_account.vm_sa.email
    scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write"
    ]
  }

  labels = {
    env   = var.env
    owner = var.owner
  }

  depends_on = [google_project_service.compute]
}
