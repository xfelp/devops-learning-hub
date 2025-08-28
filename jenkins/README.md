# 🚀 DevOps Jenkins + Terraform Automation Pipeline

![Jenkins](https://img.shields.io/badge/Jenkins-D24939?style=for-the-badge&logo=jenkins&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-623CE4?style=for-the-badge&logo=terraform&logoColor=white)
![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Pipeline](https://img.shields.io/badge/CI%2FCD-Pipeline-orange?style=for-the-badge)
![Level](https://img.shields.io/badge/Nivel-Principiante-green?style=for-the-badge)

> 🎯 **Objetivo**: Automatiza el despliegue de infraestructura con Jenkins y Terraform. Crea pipelines CI/CD completos para Infrastructure as Code en Google Cloud Platform.

---

## 📋 Prerequisites - Requisitos Previos

### ✅ **Conocimientos Necesarios:**
- 🔧 Terraform básico ([completar lab anterior](https://github.com/xfelp/devops-learning-hub/tree/main/terraform))
- 🐧 Línea de comandos (Bash/PowerShell)
- 📦 Git básico
- ☁️ Google Cloud Platform conceptos

### 🛠️ **Herramientas Requeridas:**
- Una cuenta de Google Cloud con **facturación activa**
- Permisos de **owner/editor** en el proyecto GCP
- Git instalado en tu máquina local
- Google Cloud SDK (gcloud) configurado
- Terraform instalado localmente

### 💰 **Estimación de Costos:**
- VM Jenkins (e2-medium): ~$24/mes (⚠️ **Recuerda destruir después del lab**)
- IP pública estática: ~$1.46/mes
- Almacenamiento: <$1/mes
- **Total estimado**: ~$26/mes durante el lab

---

## 📖 ¿Qué aprenderás?

Al completar este lab habrás dominado:
- 🔄 **CI/CD para Infraestructura**: Pipelines automatizados con Jenkins
- 🏗️ **Infrastructure as Code**: Terraform en entornos de producción
- 📦 **GitOps**: Git como fuente para tu infraestructura
- 🔐 **DevOps Security**: Service Accounts y gestión segura de credenciales
- 📊 **Pipeline as Code**: Jenkinsfile y configuración declarativa
- 🚀 **Automatización Completa**: Desde push hasta deploy sin intervención manual

## ⏱️ Tiempo estimado: 2-3 horas

---

## 📂 Estructura del Proyecto

```
📁 jenkins/
├── 📁 terraform-jenkins-vm/           # Código para crear VM Jenkins
│   ├── 📄 main.tf                    # Configuración principal
│   ├── 📄 variables.tf               # Variables personalizables
│   ├── 📄 outputs.tf                 # URLs y credenciales
│   ├── 📄 startup-script.sh          # Script de instalación Jenkins
│   ├── 📄 firewall.tf                # Reglas de red
│   └── 📄 service-account.tf         # Permisos para Jenkins
├── 📁 terraform-sample-infra/        # Infraestructura de ejemplo a desplegar
│   ├── 📄 main.tf                    # VM de prueba + red
│   ├── 📄 variables.tf               # Variables del proyecto
│   └── 📄 outputs.tf                 # Información de recursos creados
├── 📁 jenkins-pipeline/
│   ├── 📄 Jenkinsfile                # Pipeline como código
│   └── 📄 job-config.xml             # Configuración del job
├── 📁 scripts/
│   ├── 📄 configure-jenkins.sh       # Script post-instalación
│   └── 📄 setup-credentials.sh       # Configurar credenciales GCP
└── 📄 README.md                      # Esta guía
```

> 📝 **¿Qué hace cada directorio?**
> - `terraform-jenkins-vm/`: Crea la VM donde se ejecutará Jenkins
> - `terraform-sample-infra/`: Infraestructura de ejemplo que Jenkins desplegará
> - `jenkins-pipeline/`: Definición del pipeline automatizado
> - `scripts/`: Scripts de utilidad para configuración

---

## 📥 Clonar el Repositorio

<details>
<summary><strong>🪟 Windows (PowerShell)</strong></summary>

```powershell
# Clonar el repositorio
git clone https://github.com/xfelp/devops-learning-hub.git
cd devops-learning-hub

# Verificar estructura
Get-ChildItem -Recurse -Name
```
</details>

<details>
<summary><strong>🐧 Linux/macOS</strong></summary>

```bash
# Clonar el repositorio
git clone https://github.com/xfelp/devops-learning-hub.git
cd devops-learning-hub

# Verificar estructura
find . -type f -name "*.tf" -o -name "*.sh" | head -10
```
</details>

---

## 🔐 Configuración Inicial GCP

### 1. Configurar Proyecto

<details>
<summary><strong>🪟 Windows (PowerShell)</strong></summary>

```powershell
# Configurar proyecto activo
gcloud config set project <TU_PROJECT_ID>

# Habilitar APIs necesarias
gcloud services enable compute.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com

# Verificar configuración
gcloud config list
gcloud auth list
```
</details>

<details>
<summary><strong>🐧 Linux/macOS</strong></summary>

```bash
# Configurar proyecto activo
gcloud config set project <TU_PROJECT_ID>

# Habilitar APIs necesarias
gcloud services enable compute.googleapis.com \
                     iam.googleapis.com \
                     cloudresourcemanager.googleapis.com

# Verificar configuración
gcloud config list
gcloud auth list
```
</details>

### 2. Crear Service Account para Jenkins

<details>
<summary><strong>🪟 Windows (PowerShell)</strong></summary>

```powershell
# Variables
$PROJECT_ID = "<TU_PROJECT_ID>"
$SA_NAME = "jenkins-terraform-sa"

# Crear Service Account
gcloud iam service-accounts create $SA_NAME `
  --display-name="Jenkins Terraform Service Account" `
  --description="SA for Jenkins to manage Terraform deployments"

# Asignar roles necesarios
$SA_EMAIL = "$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com"

gcloud projects add-iam-policy-binding $PROJECT_ID `
  --member="serviceAccount:$SA_EMAIL" `
  --role="roles/compute.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID `
  --member="serviceAccount:$SA_EMAIL" `
  --role="roles/iam.serviceAccountAdmin"

gcloud projects add-iam-policy-binding $PROJECT_ID `
  --member="serviceAccount:$SA_EMAIL" `
  --role="roles/storage.admin"

# Crear y descargar clave JSON
gcloud iam service-accounts keys create "$HOME\jenkins-sa-key.json" `
  --iam-account="$SA_EMAIL"

Write-Host "✅ Service Account creado: $SA_EMAIL"
Write-Host "🔑 Clave guardada en: $HOME\jenkins-sa-key.json"
```
</details>

<details>
<summary><strong>🐧 Linux/macOS</strong></summary>

```bash
# Variables
PROJECT_ID="<TU_PROJECT_ID>"
SA_NAME="jenkins-terraform-sa"

# Crear Service Account
gcloud iam service-accounts create $SA_NAME \
  --display-name="Jenkins Terraform Service Account" \
  --description="SA for Jenkins to manage Terraform deployments"

# Asignar roles necesarios
SA_EMAIL="$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SA_EMAIL" \
  --role="roles/compute.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SA_EMAIL" \
  --role="roles/iam.serviceAccountAdmin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SA_EMAIL" \
  --role="roles/storage.admin"

# Crear y descargar clave JSON
gcloud iam service-accounts keys create ~/jenkins-sa-key.json \
  --iam-account="$SA_EMAIL"

echo "✅ Service Account creado: $SA_EMAIL"
echo "🔑 Clave guardada en: ~/jenkins-sa-key.json"

# LE decimos a terraform dodne esto JSON
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/jenkins-sa-key.json"
test -f "$GOOGLE_APPLICATION_CREDENTIALS" && echo "OK JSON: $GOOGLE_APPLICATION_CREDENTIALS" || echo "NO EXISTE"


```
</details>

> ⚠️ **Importante**: Guarda la ruta del archivo `jenkins-sa-key.json` - lo necesitarás más adelante.

---

## 🚀 Paso 1: Desplegar VM Jenkins

### 1.1 Configurar Variables

Crea el archivo `terraform.tfvars` en el directorio `terraform-jenkins-vm/`:

<details>
<summary><strong>🪟 Windows (PowerShell)</strong></summary>

```powershell
# Navegar al directorio
cd terraform-jenkins-vm

# Crear archivo de variables
@"
project_id = "<TU_PROJECT_ID>"
region     = "us-central1"
zone       = "us-central1-a"
jenkins_admin_password = "admin123!@#"
allowed_ip_ranges = ["0.0.0.0/0"]  # ⚠️ Restrictigar en producción
"@ | Out-File -FilePath "terraform.tfvars" -Encoding UTF8

# Verificar contenido
Get-Content terraform.tfvars
```
</details>

<details>
<summary><strong>🐧 Linux/macOS</strong></summary>

```bash
# Navegar al directorio
cd terraform-jenkins-vm

# Crear archivo de variables
cat > terraform.tfvars << EOF
project_id = "<TU_PROJECT_ID>"
region     = "us-central1"
zone       = "us-central1-a"
jenkins_admin_password = "admin123!@#"
allowed_ip_ranges = ["0.0.0.0/0"]  # ⚠️ Restringir en producción
EOF

# Verificar contenido
cat terraform.tfvars
```
</details>

### 1.2 Desplegar Jenkins VM

<details>
<summary><strong>🪟 Windows (PowerShell)</strong></summary>

```powershell
# Inicializar Terraform
terraform init -upgrade

# Ver plan de ejecución
terraform plan

# Aplicar cambios (esto toma ~5-10 minutos)
terraform apply -auto-approve

# Obtener información de acceso
terraform output
```
</details>

<details>
<summary><strong>🐧 Linux/macOS</strong></summary>

```bash
# Inicializar Terraform
terraform init -upgrade

# Ver plan de ejecución
terraform plan

# Aplicar cambios (esto toma ~5-10 minutos)
terraform apply -auto-approve

# Obtener información de acceso
terraform output
```
</details>

### 1.3 Verificar Instalación

**📝 Outputs esperados:**
```
jenkins_url = "http://34.123.45.67:8080"
jenkins_initial_password = "abc123def456"
ssh_command = "gcloud compute ssh jenkins-vm --zone us-central1-a"
```

**🌐 Acceder a Jenkins:**

1. Abre la URL en tu navegador: `http://[JENKINS_IP]:8080`
2. Espera 3-5 minutos mientras Jenkins termina de instalarse
3. Usa la contraseña inicial del output

> ⏰ **¿Jenkins no responde?** Es normal. El startup script tarda ~5-10 minutos en instalar todo. Puedes verificar el progreso con SSH.

---

## 🔧 Paso 2: Configurar Jenkins

### 2.1 Setup Inicial de Jenkins

1. **🌐 Accede a Jenkins** usando la URL del output
2. **🔓 Unlock Jenkins** con la contraseña inicial
3. **📦 Install Plugins**: Selecciona "Install suggested plugins"
4. **👤 Create Admin User**:
   - Username: `admin`
   - Password: El que configuraste en `terraform.tfvars`
   - Email: tu email
5. **🔗 Instance Configuration**: Usar la URL sugerida

### 2.2 Instalar Plugins Necesarios

**Dashboard → Manage Jenkins → Manage Plugins → Available**

Instalar estos plugins:
- ✅ **Git Pipeline**
- ✅ **Google Compute Engine**
- ✅ **Pipeline: Stage View**
- ✅ **Blue Ocean** (opcional, para UI moderna)
- ✅ **Slack Notification** (opcional)

### 2.3 Configurar Credenciales GCP

**Dashboard → Manage Jenkins → Manage Credentials → Global → Add Credentials**

1. **Kind**: `Secret file`
2. **File**: Sube tu `jenkins-sa-key.json`
3. **ID**: `gcp-service-account-key`
4. **Description**: `GCP Service Account for Terraform`

<details>
<summary><strong>🪟 Windows - Ubicar archivo de clave</strong></summary>

```powershell
# El archivo debería estar en:
Write-Host "Buscar archivo en: $HOME\jenkins-sa-key.json"

# Si no lo encuentras:
gcloud iam service-accounts keys list --iam-account="jenkins-terraform-sa@<TU_PROJECT_ID>.iam.gserviceaccount.com"
```
</details>

<details>
<summary><strong>🐧 Linux - Ubicar archivo de clave</strong></summary>

```bash
# El archivo debería estar en:
echo "Buscar archivo en: ~/jenkins-sa-key.json"
ls -la ~/jenkins-sa-key.json

# Si no lo encuentras:
gcloud iam service-accounts keys list --iam-account="jenkins-terraform-sa@<TU_PROJECT_ID>.iam.gserviceaccount.com"
```
</details>

---

## 🏗️ Paso 3: Crear Tu Primer Pipeline

### 3.1 Crear Nuevo Job

1. **Dashboard → New Item**
2. **Name**: `terraform-infrastructure-pipeline`
3. **Type**: `Pipeline`
4. **OK**

### 3.2 Configurar Pipeline

**En la configuración del job:**

1. **General**: 
   - ✅ GitHub project: `https://github.com/tu-usuario/devops-jenkins-terraform-pipeline`

2. **Build Triggers**:
   - ✅ GitHub hook trigger for GITScm polling

3. **Pipeline**:
   - **Definition**: `Pipeline script from SCM`
   - **SCM**: `Git`
   - **Repository URL**: `https://github.com/tu-usuario/devops-jenkins-terraform-pipeline.git`
   - **Branch**: `*/main`
   - **Script Path**: `jenkins-pipeline/Jenkinsfile`

4. **Save**

### 3.3 Probar Pipeline

**🚀 Ejecutar primera vez:**

1. **Build Now** en el dashboard del job
2. Ver logs en **Console Output**
3. El pipeline debería ejecutar estas etapas:
   - ✅ Checkout código
   - ✅ Terraform Plan
   - ⏸️ Manual Approval
   - ✅ Terraform Apply
   - ✅ Post-deployment validation

---

## 📊 Paso 4: Entender el Pipeline

### 4.1 Anatomía del Jenkinsfile

```groovy
pipeline {
    agent any  // Ejecutar en cualquier nodo disponible
    
    environment {
        // Variables de entorno globales
        GOOGLE_APPLICATION_CREDENTIALS = credentials('gcp-service-account-key')
        TF_VAR_project_id = "${PROJECT_ID}"
    }
    
    stages {
        stage('🔄 Checkout') {
            steps {
                // Descargar código del repositorio
                git branch: 'main', url: "${GIT_URL}"
            }
        }
        
        stage('🔍 Terraform Plan') {
            steps {
                dir('terraform-sample-infra') {
                    // Planificar cambios SIN aplicarlos
                    sh 'terraform init'
                    sh 'terraform plan -out=tfplan'
                }
            }
        }
        
        stage('⏸️ Manual Approval') {
            steps {
                // Pausa para revisión humana
                input message: '🚀 Deploy infrastructure?', ok: 'Deploy'
            }
        }
        
        stage('🚀 Terraform Apply') {
            steps {
                dir('terraform-sample-infra') {
                    // Aplicar cambios reales
                    sh 'terraform apply tfplan'
                }
            }
        }
    }
}
```

### 4.2 ¿Qué Infraestructura se Despliega?

El pipeline despliega automáticamente:

- 🖥️ **VM de prueba** (e2-micro)
- 🌐 **Red personalizada** con firewall rules
- 🔐 **Service account** dedicado
- 🏷️ **Labels** para organización

---

## 🔄 Paso 5: GitOps en Acción

### 5.1 Configurar GitHub Webhook

**En tu repositorio GitHub:**

1. **Settings → Webhooks → Add webhook**
2. **Payload URL**: `http://[JENKINS_IP]:8080/github-webhook/`
3. **Content type**: `application/json`
4. **Events**: `Just the push event`
5. **Active**: ✅

### 5.2 Flujo GitOps Completo

```bash
# 1. Hacer cambios en infraestructura
git clone https://github.com/tu-usuario/devops-jenkins-terraform-pipeline.git
cd devops-jenkins-terraform-pipeline

# 2. Modificar terraform-sample-infra/variables.tf
# Por ejemplo, cambiar el machine_type

# 3. Commit y push
git add .
git commit -m "feat: upgrade VM to e2-small"
git push origin main

# 4. 🎉 Jenkins detecta el push automáticamente
# 5. 🔄 Ejecuta el pipeline sin intervención
# 6. ⏸️ Te pide aprobación para deploy
# 7. 🚀 Despliega los cambios
```

---

## 🧪 Experimentos Recomendados

### **Experimento 1: Modificar Infraestructura**
```hcl
# En terraform-sample-infra/variables.tf
variable "machine_type" {
  default = "e2-small"  # Cambiar de e2-micro
}

variable "disk_size" {
  default = 30  # Aumentar disco
}
```

### **Experimento 2: Agregar Notificaciones**
```groovy
// En Jenkinsfile, agregar en post:
post {
    success {
        mail to: 'tu-email@ejemplo.com',
             subject: "✅ Deploy Success: ${env.JOB_NAME}",
             body: "Infrastructure deployed successfully!"
    }
}
```

### **Experimento 3: Multi-Environment**
```bash
# Crear branches para diferentes entornos
git checkout -b development
git checkout -b staging
git checkout -b production

# Configurar pipelines separados para cada branch
```

---

## 💰 Limpieza y Gestión de Costos

### ⚠️ Importante: Destruir Recursos

**🗑️ Destruir infraestructura desplegada por Jenkins:**

<details>
<summary><strong>🪟 Windows (PowerShell)</strong></summary>

```powershell
# 1. Destruir la infraestructura sample (desde Jenkins o manual)
cd terraform-sample-infra
terraform destroy -auto-approve

# 2. Destruir la VM Jenkins
cd ..\terraform-jenkins-vm
terraform destroy -auto-approve

# 3. Limpiar Service Account (opcional)
gcloud iam service-accounts delete jenkins-terraform-sa@<TU_PROJECT_ID>.iam.gserviceaccount.com --quiet

# 4. Verificar que todo se eliminó
gcloud compute instances list
gcloud compute disks list
```
</details>

<details>
<summary><strong>🐧 Linux/macOS</strong></summary>

```bash
# 1. Destruir la infraestructura sample (desde Jenkins o manual)
cd terraform-sample-infra
terraform destroy -auto-approve

# 2. Destruir la VM Jenkins
cd ../terraform-jenkins-vm
terraform destroy -auto-approve

# 3. Limpiar Service Account (opcional)
gcloud iam service-accounts delete jenkins-terraform-sa@<TU_PROJECT_ID>.iam.gserviceaccount.com --quiet

# 4. Verificar que todo se eliminó
gcloud compute instances list
gcloud compute disks list
```
</details>

> 💡 **Tip de Costos**: La VM Jenkins (e2-medium) cuesta ~$24/mes. Si no la usas activamente, destrúyela y recréala cuando necesites hacer labs.

---

## 🔧 Troubleshooting

### ❌ Jenkins no inicia

**🔍 Problema**: La página Jenkins no carga después de 10 minutos

**✅ Solución**:
```bash
# SSH a la VM Jenkins
gcloud compute ssh jenkins-vm --zone us-central1-a

# Verificar estado de Jenkins
sudo systemctl status jenkins

# Ver logs de instalación
sudo tail -f /var/log/jenkins/jenkins.log

# Reiniciar si es necesario
sudo systemctl restart jenkins
```

### ❌ Pipeline falla con "terraform: command not found"

**🔍 Problema**: Terraform no se instaló correctamente en Jenkins

**✅ Solución**:
```bash
# SSH a Jenkins VM
gcloud compute ssh jenkins-vm --zone us-central1-a

# Verificar instalación
which terraform
terraform version

# Reinstalar si es necesario
curl -LO https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
sudo unzip terraform_1.6.0_linux_amd64.zip -d /usr/local/bin/
```

### ❌ Error "Access denied" en pipeline

**🔍 Problema**: Service Account no tiene permisos suficientes

**✅ Solución**:
```bash
# Verificar roles del SA
gcloud projects get-iam-policy <TU_PROJECT_ID> \
  --flatten="bindings[].members" \
  --filter="bindings.members:jenkins-terraform-sa@<TU_PROJECT_ID>.iam.gserviceaccount.com"

# Agregar rol faltante (ejemplo)
gcloud projects add-iam-policy-binding <TU_PROJECT_ID> \
  --member="serviceAccount:jenkins-terraform-sa@<TU_PROJECT_ID>.iam.gserviceaccount.com" \
  --role="roles/compute.admin"
```

### ❌ GitHub webhook no funciona

**🔍 Problema**: Push no dispara pipeline automáticamente

**✅ Solución**:
1. Verificar que Jenkins sea accesible desde internet
2. En GitHub: Settings → Webhooks → Ver "Recent Deliveries"
3. URL correcta: `http://[EXTERNAL_IP]:8080/github-webhook/`
4. Verificar firewall: puerto 8080 debe estar abierto

---

## 📚 Recursos para Seguir Aprendiendo

### 🎓 **Conceptos Avanzados**:
- 📖 [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- ☁️ [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- 🔐 [GCP IAM Best Practices](https://cloud.google.com/iam/docs/best-practices)
- 🚀 [GitOps Principles](https://opengitops.dev/)

### 🛠️ **Herramientas Complementarias**:
- **Monitoring**: Prometheus + Grafana
- **Security**: HashiCorp Vault
- **Testing**: Terratest
- **Multi-Cloud**: Terraform Cloud

### 🚀 **Próximos Labs Sugeridos**:
1. **Kubernetes + Terraform**: Deploy GKE clusters
2. **Multi-Environment**: Dev/Staging/Prod pipelines
3. **Advanced Security**: Vault integration
4. **Monitoring Stack**: Observability completa
5. **Multi-Cloud**: AWS + Azure support

### 💬 **Comunidad y Soporte**:
- 🐛 **Issues**: Repórtalos en este repositorio
- 💬 **Discussions**: Comparte experiencias
- 📧 **Contacto**: devops-learning@tudominio.com
- 🎥 **Videos**: Canal de YouTube próximamente

---

## 🎉 ¡Felicidades!

Si completaste este lab, ahora dominas:

- ✅ **CI/CD para Infraestructura**: Pipelines automatizados reales
- ✅ **Jenkins Profesional**: Configuración y administración
- ✅ **Terraform Avanzado**: State management y automatización
- ✅ **GitOps**: Flujo completo desde código hasta producción
- ✅ **Google Cloud**: IAM, networking, y compute avanzado
- ✅ **DevOps Best Practices**: Security, monitoring, y compliance

**🏆 ¡Eres oficialmente un DevOps Engineer intermedio!**

---

## 🤝 Contribuciones

**Tipos de contribuciones bienvenidas:**
- 🐛 **Bug fixes**: Corrección de errores
- 📝 **Documentation**: Mejoras en explicaciones
- 🚀 **Features**: Nuevas funcionalidades
- 🧪 **Examples**: Casos de uso adicionales
- 🎨 **UI/UX**: Mejoras en scripts y outputs

**¿Cómo contribuir?**
1. Fork del repositorio
2. Crear feature branch
3. Hacer cambios
4. Testing completo
5. Pull request con descripción detallada

---

<div align="center">

**⭐ Si este proyecto te ayudó en tu carrera DevOps, dale una estrella ⭐**


[⬆️ Volver al inicio](#-devops-jenkins--terraform-automation-pipeline)

</div>
