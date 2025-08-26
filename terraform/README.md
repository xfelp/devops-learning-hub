# 🚀 GCP Terraform Lab — Paso a Paso

![Terraform](https://img.shields.io/badge/Terraform-623CE4?style=for-the-badge&logo=terraform&logoColor=white)
![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![Beginner Friendly](https://img.shields.io/badge/Nivel-Principiante-green?style=for-the-badge)

> 🎯 **Objetivo**: Crea tu primera VM en Google Cloud con Terraform desde cero. Tutorial paso a paso para principiantes, manteniéndote dentro del **Free Tier**.

## 📖 ¿Qué aprenderás?

Al completar este lab habrás aprendido:
- 🏗️ **Infrastructure as Code (IaC)**: Qué es y por qué es importante
- 🔧 **Terraform básico**: Comandos esenciales (`init`, `plan`, `apply`, `destroy`)
- ☁️ **Google Cloud Platform**: Configuración de proyectos, APIs y permisos
- 🔐 **Service Accounts**: Autenticación segura para automatización
- 💰 **Gestión de costos**: Cómo evitar cargos no deseados

## ⏱️ Tiempo estimado: 30-45 minutos

---

## 📋 Requisitos Previos

- ✅ Una cuenta de Google Cloud con **facturación activa** en el proyecto
- 🔑 Permisos de `owner/editor` en el proyecto o capacidad de habilitar APIs y conceder roles
- 📦 Git instalado en tu sistema

---

## 🛠️ Instalación de Herramientas

### 2.1 Google Cloud SDK (gcloud)

📚 **Guía oficial**: https://cloud.google.com/sdk/docs/install-sdk?hl=es-419

#### Windows
- Descarga e instala el **instalador .exe** (agrega `gcloud` al PATH automáticamente)

#### Ubuntu
- Instala el paquete `google-cloud-cli` o usa el script oficial
```bash
  curl -sSL https://sdk.cloud.google.com | bash
  exec -l $SHELL
  gcloud version
  gcloud init
```

**✅ Verificación de instalación:**
```bash
gcloud version
```

### 2.2 Terraform

<details>
<summary><strong>🪟 Windows (Recomendado con Chocolatey)</strong></summary>

#### 2.2.1 Instalar Chocolatey
Ejecuta **PowerShell como Administrador**:
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; `
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

#### 2.2.2 Instalar Terraform
Ejecuta **PowerShell como Administrador**:
```powershell
choco install terraform -y
```

#### 📌 Alternativas Windows:
- **Scoop**: `scoop install terraform`
- **Manual**: Descarga ZIP oficial y agrega la carpeta al PATH
</details>

<details>
<summary><strong>🐧 Ubuntu</strong></summary>

📚 **Guía oficial**: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

O usar los repositorios oficiales de HashiCorp con `apt`.

```bash
sudo apt-get update && sudo apt-get install -y gnupg ca-certificates curl && \
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(. /etc/os-release && echo $VERSION_CODENAME) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null && \
sudo apt-get update && sudo apt-get install -y terraform && \
terraform -version
```

</details>

**✅ Verificación de instalación:**
```bash
terraform -version
```

---

## 📥 Clonar el Repositorio

En Windows, verifica que te encuentres autentificado en github.com, y luego ejecuta el siguiente comando por powershell:

```powershell
git clone https://github.com/xfelp/devops-learning-hub.git
```

En Ubuntu, sigue las siguientes indicaciones:

Recuerda usar la clave SSH que creamos en el laboratorio anterior para el login de github.

Lista tus claves públicas (la que termina en .pub es la que se sube a GitHub)
```bash
ls -l ~/.ssh/*.pub
```

Inicia el agente (si no está corriendo) y agrega tu clave privada
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519    # o ~/.ssh/id_rsa si esa es tu clave
```

```bash
git clone git@github.com:xfelp/devops-learning-hub.git
```

### 📂 Estructura del Proyecto

```
📁 devops-learning-hub-terraform-vm/
├── 📄 main.tf          # Configuración principal de recursos
├── 📄 variables.tf     # Variables parametrizables
├── 📄 outputs.tf       # Información que mostrar después del deploy
└── 📄 README.md        # Esta guía
```

> 📝 **¿Qué hace cada archivo?**
> - `main.tf`: Define QUÉ recursos crear (VM, Service Account, APIs)
> - `variables.tf`: Define parámetros personalizables (región, tamaño de disco, etc.)
> - `outputs.tf`: Muestra información útil después del deploy (nombre de VM, comando SSH)

---

## 🔐 Autenticación para Terraform

### 🎯 Opción A — Cuenta de Servicio (Recomendado)

<details>
<summary><strong>🪟 Windows (PowerShell)</strong></summary>

```powershell
# Recuerda estar logeado en tu cuenta de GCP, lo puedes hacer mediante el siguiente comando:
gcloud auth login
# Se abria una pestaña de tu navegador para que ingreses las credenciales.

# 1️⃣ Configurar proyecto activo
gcloud config set project <TU_PROJECT_ID>

# 2️⃣ Crear Service Account
gcloud iam service-accounts create terraform-sa --display-name "Terraform Service Account"

# 3️⃣ Crear la llave JSON 
gcloud iam service-accounts keys create "$HOME\terraform-sa.json" `
  --iam-account "terraform-sa@<TU_PROJECT_ID>.iam.gserviceaccount.com"

# 4️⃣ Asignar roles mínimos

$SA="serviceAccount:terraform-sa@<TU_PROJECT_ID>.iam.gserviceaccount.com"
$PROJECT="<TU_PROJECT_ID>"
gcloud projects add-iam-policy-binding $PROJECT --member=$SA --role=roles/compute.admin
gcloud projects add-iam-policy-binding $PROJECT --member=$SA --role=roles/iam.serviceAccountAdmin
gcloud projects add-iam-policy-binding $PROJECT --member=$SA --role=roles/serviceusage.serviceUsageAdmin

# 5️⃣ Configurar variable de entorno (sesión actual)

$env:GOOGLE_APPLICATION_CREDENTIALS="$HOME\terraform-sa.json"

# 6️⃣ Configurar variable de entorno (permanente)
[System.Environment]::SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS","$HOME\terraform-sa.json","User")
```
</details>

<details>
<summary><strong>🐧 Ubuntu</strong></summary>

```bash
# Verificar si se encuentra logeado a GCP (se abria una pestaña para que ingrese las credenciales)
gcloud auth login

# 1️⃣ Configurar proyecto activo
gcloud config set project <TU_PROJECT_ID>

# 2️⃣ Crear Service Account
gcloud iam service-accounts create terraform-sa --display-name "Terraform Service Account"

# 3️⃣ Crear la llave JSON
gcloud iam service-accounts keys create ~/terraform-sa.json \
  --iam-account "terraform-sa@<TU_PROJECT_ID>.iam.gserviceaccount.com"

# 4️⃣ Configurar variable de entorno (sesión actual)
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/terraform-sa.json"

# 5️⃣ Configurar variable de entorno (permanente)
echo 'export GOOGLE_APPLICATION_CREDENTIALS="$HOME/terraform-sa.json"' >> ~/.bashrc && source ~/.bashrc
```
</details>

---

## 🔧 Habilitar APIs del Proyecto

**⚠️ Ejecutar una sola vez:**

En windows:
```Windows powershell
gcloud config set project <TU_PROJECT_ID>
gcloud services enable `
  cloudresourcemanager.googleapis.com `
  serviceusage.googleapis.com `
  iam.googleapis.com `
  compute.googleapis.com
```
En Ubuntu:
```Ubuntu bash
gcloud services enable cloudresourcemanager.googleapis.com serviceusage.googleapis.com iam.googleapis.com compute.googleapis.com
```


> ⏰ **Importante**: Espera 1-2 minutos para que las APIs se propaguen antes del `terraform apply`.

---

## 🚀 Desplegar la Infraestructura

### 6.1 Configurar Variables (Opcional)

Puedes personalizar la configuración creando un archivo `terraform.tfvars`:

```hcl
# terraform.tfvars
project_id = "tu-project-id-aqui"
region     = "us-central1"        # Free Tier: us-central1, us-east1, us-west1
zone       = "us-central1-a"
name_prefix = "mi-lab"            # Prefijo para recursos
```

> 💡 **Regiones Free Tier**: Usa `us-central1`, `us-east1`, o `us-west1` para aprovechar el Free Tier

### 6.2 Ejecutar Terraform

```bash
# 1️⃣ Inicializar Terraform (descarga provider de GCP)
terraform init -upgrade

# 2️⃣ Ver el plan de ejecución (qué recursos se crearán)
terraform plan

# 3️⃣ Aplicar cambios (crear la VM)
terraform apply -auto-approve
```

> 📝 **¿Qué hace cada comando?**
> - `terraform init`: Descarga el provider de Google Cloud y prepara el directorio
> - `terraform plan`: Muestra qué recursos se crearán/modificarán SIN hacer cambios
> - `terraform apply`: Ejecuta los cambios reales en Google Cloud

### 6.3 Información Creada

Después del `apply` verás información como:
```
Outputs:
instance_name = "demo-vm"
ssh_example = "gcloud compute ssh demo-vm --zone us-central1-a"
external_ip = null
```

### 6.4 Conectarse a la VM

```bash
# Usando el comando que aparece en los outputs
gcloud compute ssh demo-vm --zone us-central1-a

# O usando IAP (si no hay IP pública)
gcloud compute ssh demo-vm --zone us-central1-a --tunnel-through-iap
```

### 6.2 Verificar la VM Creada

```bash
terraform state list
```

✅ **Resultado esperado**: Debe listar varios recursos:
- `google_compute_instance.vm`
- `google_service_account.vm_sa` 
- `google_project_service.compute`

### 6.3 Ver detalles de la VM

```bash
# Ver toda la información de la VM
terraform show

# Ver solo los outputs
terraform output
```

---

## 🔍 ¿Qué recursos se crean exactamente?

Este lab crea varios recursos optimizados para **Free Tier**:

### 1. 🖥️ **VM (e2-micro)**
- **Tipo**: `e2-micro` (Free Tier incluye 744h/mes)
- **SO**: Ubuntu 22.04 LTS
- **Disco**: 20 GB HDD estándar (Free Tier incluye 30 GB)
- **Red**: Sin IP pública (evita costos de IP estática)

### 2. 🔐 **Service Account**
- Cuenta dedicada para la VM (buena práctica de seguridad)
- Permisos mínimos (solo logging y monitoring)

### 3. 🌐 **API de Compute**
- Se habilita automáticamente si es proyecto nuevo

### 4. 🏷️ **Labels y Metadata**
- `env: dev`, `owner: devops-learning-hub-user`
- OS Login habilitado para SSH seguro

> 💡 **¿Por qué no tiene IP pública?**
> - Las IPs públicas tienen costo (~$1.46/mes)
> - Usamos IAP para conectarnos de forma gratuita y segura
> - En producción, esto es una mejor práctica de seguridad

---

## 💰 Limpieza (Evitar Costos)

**🗑️ Destruir todos los recursos:**
```bash
terraform destroy -auto-approve
```

**🔍 Verificar que se destruyó todo:**
```bash
terraform state list
```
> Debe estar vacío después del destroy

> 💡 **Costos estimados si olvidas destruir:**
> - VM e2-micro: $0 (dentro del Free Tier)
> - Disco 20GB: ~$0.80/mes
> - **Total estimado**: <$1/mes (muy bajo, pero mejor destruir)

> ⚠️ **Importante**: En producción, NUNCA uses `-auto-approve` sin revisar el plan primero

---

## 🔧 Troubleshooting

### ❌ Error: `Error creating Instance: googleapi: Error 403: Access Not Configured`

**🔍 Problema**: La API de Compute Engine no está habilitada

**✅ Solución**:
```bash
gcloud services enable compute.googleapis.com
```
> ⏰ Espera 1-2 minutos y vuelve a ejecutar `terraform apply`

### ❌ Error: `Error: project_id is required`

**🔍 Problema**: No especificaste el ID del proyecto

**✅ Solución**: Crea un archivo `terraform.tfvars`:
```hcl
project_id = "tu-project-id-real"
```

### ❌ Error: VM se crea pero no puedes conectarte

**🔍 Problema**: La VM no tiene IP pública y IAP podría no estar configurado

**✅ Solución**: Usa IAP para conectarte:
```bash
# Habilitar IAP
gcloud services enable iap.googleapis.com

# Conectarse via IAP
gcloud compute ssh demo-vm --zone us-central1-a --tunnel-through-iap
```

### ❌ Error: `choco: command not found`

**🔍 Problema**: Chocolatey no está en el PATH

**✅ Solución**:
1. Agrega `C:\ProgramData\chocolatey\bin` al PATH del sistema
2. Abre una nueva consola/PowerShell

---

## 📚 Recursos Adicionales

### 🎓 Para seguir aprendiendo:
- 📖 [Documentación oficial de Terraform](https://developer.hashicorp.com/terraform/docs)
- ☁️ [Google Cloud Terraform Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- 🆓 [Google Cloud Free Tier](https://cloud.google.com/free)
- 🎬 [Terraform en 20 minutos (video)](https://www.youtube.com/watch?v=tomUWcQ0P3k)

### 🚀 Próximos pasos sugeridos:
1. **📝 Modificar variables**: Cambia el `machine_type` a `e2-small` y aplica los cambios
2. **🌐 Agregar IP pública**: Descomenta `access_config {}` en `main.tf`
3. **💾 Disco adicional**: Agrega un `google_compute_disk` resource
4. **🔥 Firewall rules**: Permitir HTTP/HTTPS traffic
5. **📦 Startup script**: Instalar software al crear la VM
6. **🏗️ Módulos**: Convertir este código en un módulo reutilizable

### 🧪 Experimentos recomendados:
```hcl
# En terraform.tfvars, prueba cambiar:
machine_type = "e2-small"      # Más potente (sale del Free Tier)
boot_disk_gb = 30              # Disco más grande
name_prefix = "mi-experimento" # Cambiar nombres
```

Luego ejecuta:
```bash
terraform plan  # Ver qué cambiará
terraform apply # Aplicar cambios
```

### 💬 ¿Tienes preguntas?
- 🐛 Reporta issues en este repositorio
- 💬 Únete a nuestro canal de Discord: [DevOps desde 0](https://discord.gg/frkCdSPN)

---

## 🎉 ¡Felicidades!

Si llegaste hasta aquí, acabas de:
- ✅ Crear tu primera infraestructura con código
- ✅ Aprender los comandos básicos de Terraform  
- ✅ Configurar Google Cloud de forma programática
- ✅ Implementar buenas prácticas de seguridad con Service Accounts

**🏆 ¡Eres oficialmente un Terraform beginner!**

---

## 🤝 Contribuciones

¿Encontraste un error o tienes una mejora? ¡Abre un issue o envía un pull request!

**Tipos de contribuciones bienvenidas:**
- 🐛 Corrección de errores
- 📝 Mejoras en documentación
- 🔧 Optimizaciones de código
- 🎓 Ejemplos adicionales

---


<div align="center">
  
**⭐ Si este proyecto te ayudó, dale una estrella en GitHub ⭐**


</div>
