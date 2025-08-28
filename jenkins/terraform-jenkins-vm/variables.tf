variable "project_id" {
  description = "ID del proyecto GCP"
  type        = string
  default     = "devops-learning-hub"
}

variable "region" {
  description = "Región por defecto"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Zona por defecto"
  type        = string
  default     = "us-central1-a"
}

variable "name_prefix" {
  description = "Prefijo para nombrar recursos"
  type        = string
  default     = "demo"
}

variable "machine_type" {
  description = "Tipo de máquina"
  type        = string
  default     = "e2-small" # ← ya en e2-small
}

variable "boot_image" {
  description = "Imagen del disco de arranque (family LTS recomendada)"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2204-lts"
}

variable "boot_disk_gb" {
  description = "Tamaño del disco de arranque en GB"
  type        = number
  default     = 20
  validation {
    condition     = var.boot_disk_gb >= 10
    error_message = "boot_disk_gb debe ser >= 10 GB."
  }
}

variable "env" {
  description = "Etiqueta de entorno (dev, intg, prod, etc.)"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Etiqueta de propietario"
  type        = string
  default     = "devops-learning-hub-user"
}

variable "jenkins_admin_password" {
  description = "Password del admin de Jenkins (si decides usarla en el futuro)"
  type        = string
  sensitive   = true
  default     = "" # no se usa en este ejemplo
}

variable "allowed_ip_ranges" {
  description = "Rangos CIDR permitidos. Si está vacío, se usa la IP pública del ejecutor (/32)."
  type        = list(string)
  default     = []
}

variable "caller_sa_email" {
  description = "SA que ejecuta Terraform (quien aplica el plan)."
  type        = string
  default     = "jenkins-terraform-sa@devops-learning-hub.iam.gserviceaccount.com"
}
