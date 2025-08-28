# Jenkins VM con Terraform - Guía Completa para Principiantes DevOps

Esta es tu introducción completa al mundo de **Infrastructure as Code (IaC)**, **CI/CD** y **automatización de infraestructura**. En este proyecto aprenderás a crear, configurar y usar Jenkins desde cero, mientras automatizas todo el proceso con Terraform.

## 📚 ¿Qué vas a aprender?

- **Infrastructure as Code (IaC)**: Crear infraestructura con código
- **Jenkins**: Qué es, cómo instalarlo y configurarlo desde cero
- **Pipelines**: Automatizar tareas con Jenkinsfiles
- **Google Cloud Platform**: Crear VMs, reglas de firewall y gestionar recursos
- **Terraform**: Crear y gestionar infraestructura de forma declarativa
- **DevOps**: Principios y mejores prácticas

---

## 🎯 ¿Qué construiremos exactamente?

Al final de esta guía tendrás:

### 🖥️ **Una Máquina Virtual en Google Cloud con:**
- **Sistema Operativo**: Ubuntu 22.04 LTS
- **Tipo**: e2-small (elegible para Free Tier de GCP)
- **Disco**: 20GB SSD estándar
- **Red**: IP pública con acceso controlado por firewall
- **Memoria**: 1GB de swap adicional para mejor rendimiento
- **Java**: OpenJDK 17 (requerido para Jenkins)
- **Jenkins**: Instalado y configurado automáticamente

### 🔒 **Seguridad configurada:**
- **Firewall**: Solo tu IP puede acceder (SSH puerto 22, Jenkins puerto 8080)
- **OS Login**: Autenticación segura con cuentas de Google
- **Service Account**: Identidad dedicada para la VM con permisos mínimos
- **Credenciales**: Gestión segura de llaves de acceso

### 🚀 **Pipeline automatizado que:**
- Instala Terraform automáticamente
- Valida la configuración antes de aplicar
- Muestra exactamente qué se va a crear/cambiar
- **Requiere aprobación manual** antes de crear recursos
- Guarda los resultados para referencia futura

---

## 📁 Estructura Completa del Proyecto

```
jenkins/terraform-jenkins-vm/
├── Jenkinsfile              # 🔄 Pipeline que ejecuta Terraform
├── main.tf                  # 🏗️  Infraestructura principal (VM, firewall, etc.)
├── variables.tf             # ⚙️  Parámetros configurables
├── output.tf               # 📤 Información que se muestra al final
├── startup.sh              # 🚀 Script que instala Jenkins en la VM
└── terraform.tfvars        # 💾 Valores específicos de tu proyecto
```

### 📝 **¿Qué hace cada archivo?**

| Archivo | Propósito | ¿Qué contiene? |
|---------|-----------|----------------|
| `Jenkinsfile` | Define el pipeline de CI/CD | Pasos para instalar Terraform, validar código, crear infraestructura |
| `main.tf` | Configuración de infraestructura | VM, firewall, service account, startup script |
| `variables.tf` | Parámetros del proyecto | ID del proyecto, región, tipo de VM, etc. |
| `output.tf` | Resultados finales | URL de Jenkins, IP de la VM, comandos SSH |
| `startup.sh` | Script de inicialización | Comandos que se ejecutan cuando arranca la VM |
| `terraform.tfvars` | Valores personalizados | Tus datos específicos (proyecto, región, etc.) |

---

## 🧠 Conceptos Fundamentales Que Debes Conocer

### 🤖 **¿Qué es Jenkins?**
Jenkins es una plataforma de **automatización** que permite:
- **Integración Continua (CI)**: Ejecutar tests automáticamente cuando cambias código
- **Entrega Continua (CD)**: Desplegar aplicaciones automáticamente
- **Automatización**: Ejecutar cualquier tarea repetitiva (backups, reportes, etc.)

**Ejemplo práctico**: Imagina que desarrollas una app. Cada vez que subes código nuevo a Git, Jenkins puede:
1. Descargar el código automáticamente
2. Ejecutar todas las pruebas
3. Si todo está bien, desplegar a producción
4. Notificarte por email/Slack del resultado

### 🏗️ **¿Qué es Infrastructure as Code (IaC)?**
Es escribir la configuración de tu infraestructura (servidores, redes, bases de datos) como **código**, no hacerlo manualmente.

**Ventajas**:
- **Reproducible**: Puedes crear la misma infraestructura 100 veces
- **Versionado**: Controlas cambios con Git
- **Documentado**: El código ES la documentación
- **Colaborativo**: Todo el equipo puede revisar y aprobar cambios

### ⚡ **¿Qué es un Pipeline?**
Es una **secuencia de pasos automatizados** que se ejecutan en orden. Como una receta de cocina, pero para infraestructura o código.

**Nuestro Pipeline**:
1. 📥 Descargar código del repositorio
2. 🔧 Instalar herramientas necesarias (Terraform)
3. ✅ Validar que la configuración sea correcta
4. 📋 Mostrar qué se va a crear/cambiar
5. ⏸️ **PARAR y pedir aprobación humana**
6. 🚀 Crear la infraestructura
7. 📊 Mostrar resultados finales

---

## 🔧 Prerrequisitos Detallados

### 1. **Google Cloud Platform (GCP)**

#### ¿Por qué GCP?
- **Free Tier generoso**: $300 en créditos + recursos siempre gratuitos
- **e2-small gratuita**: 744 horas/mes de VM pequeña gratis
- **Fácil de usar**: Interface intuitiva y buena documentación

#### Configuración paso a paso:

1. **Crear proyecto**:
   ```bash
   # Desde Cloud Shell o tu terminal local
   gcloud projects create tu-proyecto-devops-2024 --name="DevOps Learning Hub"
   gcloud config set project tu-proyecto-devops-2024
   ```

2. **Habilitar APIs necesarias**:
   ```bash
   gcloud services enable compute.googleapis.com
   gcloud services enable iam.googleapis.com
   ```

3. **Crear Service Account**:
   ```bash
   # Crear la service account
   gcloud iam service-accounts create jenkins-terraform-sa \
     --display-name="Jenkins Terraform Service Account"

   # Asignar roles necesarios
   gcloud projects add-iam-policy-binding tu-proyecto-devops-2024 \
     --member="serviceAccount:jenkins-terraform-sa@tu-proyecto-devops-2024.iam.gserviceaccount.com" \
     --role="roles/compute.admin"

   gcloud projects add-iam-policy-binding tu-proyecto-devops-2024 \
     --member="serviceAccount:jenkins-terraform-sa@tu-proyecto-devops-2024.iam.gserviceaccount.com" \
     --role="roles/iam.serviceAccountUser"
   ```

4. **Descargar clave JSON**:
   ```bash
   gcloud iam service-accounts keys create ~/jenkins-sa-key.json \
     --iam-account=jenkins-terraform-sa@tu-proyecto-devops-2024.iam.gserviceaccount.com
   ```

### 2. **Jenkins (¡Lo instalaremos juntos!)**

No necesitas Jenkins preinstalado. **Este proyecto creará Jenkins automáticamente**, pero necesitas entender qué es y cómo funciona.

---

## 🚀 Instalación y Configuración Paso a Paso

### Fase 1: Preparar el Entorno

#### 1. **Configurar `terraform.tfvars`**

Este archivo contiene TUS datos específicos:

```hcl
# Tu proyecto de GCP (cámbialo por el tuyo)
project_id = "tu-proyecto-devops-2024"

# Región donde crear la VM (us-central1 tiene Free Tier)
region = "us-central1"
zone = "us-central1-a"

# Prefijo para nombrar todos los recursos
name_prefix = "mi-jenkins"

# Email de la service account que creaste
caller_sa_email = "jenkins-terraform-sa@tu-proyecto-devops-2024.iam.gserviceaccount.com"

# Etiquetas para organizar recursos
env = "desarrollo"
owner = "tu-nombre"

# (Opcional) Especificar IPs permitidas. Si lo dejas vacío, solo tu IP actual
# allowed_ip_ranges = ["203.0.113.1/32", "198.51.100.0/24"]
allowed_ip_ranges = []
```

#### 2. **¿Qué hace este archivo?**
- **`project_id`**: Le dice a Terraform EN QUÉ proyecto de GCP trabajar
- **`region/zone`**: DÓNDE geográficamente crear la VM (importante para latencia y costos)
- **`name_prefix`**: Como llamar a todos los recursos (VM se llamará `mi-jenkins-vm`)
- **`caller_sa_email`**: QUÉ identidad usar para crear recursos
- **`allowed_ip_ranges`**: QUIÉN puede acceder a Jenkins (si vacío, solo tú)

### Fase 2: Configurar Jenkins (Primera vez)

#### ¿Qué es Jenkins y por qué lo necesitamos?

Jenkins es nuestro **"robot de automatización"**. En lugar de ejecutar comandos manualmente, Jenkins puede:
- Ejecutar Terraform por nosotros
- Registrar todo lo que hace
- Pedirnos confirmación antes de cambios importantes
- Ejecutar en horarios programados
- Notificarnos de resultados

#### 1. **Instalar Jenkins localmente (temporal)**

Necesitamos Jenkins funcionando para crear nuestro Jenkins definitivo en GCP. Es como usar una escalera para construir una escalera más grande.

**Opción A: Docker (Recomendado)**
```bash
# Crear directorio para datos de Jenkins
mkdir ~/jenkins_home

# Ejecutar Jenkins en Docker
docker run -d \
  --name jenkins-temporal \
  -p 8080:8080 -p 50000:50000 \
  -v ~/jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts
```

**Opción B: Instalación directa en Ubuntu/Debian**
```bash
# Instalar Java
sudo apt update
sudo apt install fontconfig openjdk-17-jre

# Añadir repositorio de Jenkins
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Instalar Jenkins
sudo apt-get update
sudo apt-get install jenkins
```

#### 2. **Configuración inicial de Jenkins**

1. **Acceder a Jenkins**:
   - Abre tu navegador en `http://localhost:8080`
   - Espera 2-3 minutos a que Jenkins arranque completamente

2. **Obtener password inicial**:
   ```bash
   # Si instalaste con Docker:
   docker exec jenkins-temporal cat /var/jenkins_home/secrets/initialAdminPassword
   
   # Si instalaste directamente:
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```

3. **Setup Wizard**:
   - **Página 1**: Pega el password inicial
   - **Página 2**: Selecciona **"Install suggested plugins"**
   - **Página 3**: Crea usuario admin:
     ```
     Username: admin
     Password: [tu-password-seguro]
     Full name: DevOps Admin
     Email: tu-email@ejemplo.com
     ```
   - **Página 4**: URL de Jenkins (deja por defecto)

#### 3. **Instalar plugins necesarios**

Una vez en Jenkins:

1. Ve a `Manage Jenkins` → `Plugins` → `Available plugins`
2. Busca e instala:
   - **Pipeline**: Para crear pipelines como código
   - **Git**: Para conectar con repositorios Git
   - **Credentials Binding**: Para manejar secretos de forma segura
   - **Blue Ocean** (opcional): Interface moderna para pipelines

3. Reinicia Jenkins: `Manage Jenkins` → `Restart`

#### 4. **Configurar credenciales de GCP**

Este es el paso MÁS IMPORTANTE para la seguridad:

1. `Manage Jenkins` → `Credentials` → `System` → `Global credentials`
2. Click en `Add Credentials`
3. Configura así:
   ```
   Kind: Secret file
   Scope: Global
   File: [Sube el archivo jenkins-sa-key.json que descargaste]
   ID: gcp-service-account-key
   Description: GCP Service Account para Terraform
   ```

#### ⚠️ **¿Por qué este método es seguro?**
- El archivo JSON NUNCA se almacena en texto plano
- Jenkins lo encripta automáticamente
- Solo se desencripta durante la ejecución del pipeline
- No aparece en logs ni historial

### Fase 3: Crear el Pipeline

#### 1. **¿Qué es un Pipeline?**

Un Pipeline es como una **receta automatizada** que le dice a Jenkins exactamente qué hacer y en qué orden. Nuestro pipeline:

```
[Código] → [Validar] → [Planificar] → [¿Aprobar?] → [Aplicar] → [Mostrar resultados]
```

#### 2. **Crear el Pipeline Job**

1. En la página principal de Jenkins, click `New Item`
2. Configura:
   ```
   Name: terraform-jenkins-vm
   Type: Pipeline
   ```
3. En la configuración del pipeline:
   ```
   Definition: Pipeline script from SCM
   SCM: Git
   Repository URL: https://github.com/tu-usuario/tu-repo.git
   Branch: */main
   Script Path: jenkins/terraform-jenkins-vm/Jenkinsfile
   ```

#### 3. **¿Cómo funciona nuestro Jenkinsfile?**

Vamos a analizar CADA parte del Jenkinsfile para que entiendas exactamente qué hace:

```groovy
pipeline {
  agent any  // ← Ejecuta en cualquier "worker" disponible
```
**¿Qué significa?** Jenkins puede tener múltiples "workers" (computadoras que ejecutan tareas). `agent any` significa "usa cualquiera que esté disponible".

```groovy
  options {
    timestamps()  // ← Muestra hora exacta de cada paso
  }
```
**¿Por qué?** En producción necesitas saber CUÁNDO pasó cada cosa para debugging.

```groovy
  environment {
    TF_IN_AUTOMATION = 'true'  // ← Le dice a Terraform "estás en un robot"
    TF_INPUT = '0'             // ← "No pidas input del usuario"
  }
```
**¿Qué logra?** Terraform se comporta diferente en automatización vs manual. Estas variables le dicen que no espere input humano.

#### **Stage 1: Checkout del código**
```groovy
stage('Checkout') {
  steps { checkout scm }
}
```
**¿Qué hace?** Descarga la última versión del código desde Git.
**¿Por qué necesario?** Jenkins necesita los archivos .tf para saber qué crear.

#### **Stage 2: Instalar Terraform**
```groovy
stage('Terraform CLI') {
  steps {
    sh '''
      TF_DIR="$WORKSPACE/.tf-bin"
      TF_BIN="$TF_DIR/terraform"
      VER="1.6.6"
      
      mkdir -p "$TF_DIR"
      if [ ! -x "$TF_BIN" ]; then
        curl -fsSLO "https://releases.hashicorp.com/terraform/${VER}/terraform_${VER}_linux_amd64.zip"
        # ... código de descompresión ...
        chmod +x "$TF_DIR/terraform"
      fi
    '''
  }
}
```

**¿Qué hace?**
1. **Verifica** si Terraform ya está instalado
2. Si no, **descarga** la versión exacta 1.6.6 desde HashiCorp
3. **Descomprime** usando diferentes métodos (unzip, jar, python) según lo que esté disponible
4. **Hace ejecutable** el binario de Terraform

**¿Por qué versión específica?** En producción NUNCA uses "latest". Siempre versiones específicas para reproducibilidad.

**¿Por qué múltiples métodos de descompresión?** Diferentes distribuciones de Linux tienen diferentes herramientas. Esto asegura compatibilidad.

#### **Stage 3: Inicializar y Validar**
```groovy
stage('Init & Validate') {
  steps {
    dir('jenkins/terraform-jenkins-vm') {  // ← Cambia al directorio correcto
      withCredentials([file(credentialsId: 'gcp-service-account-key', variable: 'GOOGLE_CLOUD_KEYFILE_JSON')]) {
        sh '''
          export GOOGLE_APPLICATION_CREDENTIALS="$GOOGLE_CLOUD_KEYFILE_JSON"
          terraform init -input=false -upgrade
          terraform validate
        '''
      }
    }
  }
}
```

**¿Qué hace `terraform init`?**
- Descarga el provider de Google Cloud
- Verifica que todos los módulos estén disponibles
- Prepara el directorio para trabajar con Terraform

**¿Qué hace `terraform validate`?**
- Verifica sintaxis de archivos .tf
- Confirma que las referencias entre recursos son correctas
- Se asegura que las variables requeridas estén definidas

**¿Por qué `withCredentials`?**
- Desencripta temporalmente el archivo JSON de GCP
- Lo hace disponible SOLO durante este stage
- Después lo elimina de memoria automáticamente

#### **Stage 4: Plan (¡El más importante!)**
```groovy
stage('Plan') {
  steps {
    sh '''
      terraform plan -input=false -out=tfplan -compact-warnings
    '''
  }
}
```

**¿Qué hace `terraform plan`?**
1. **Compara** el estado actual de GCP con lo que describes en los archivos .tf
2. **Calcula** exactamente qué necesita crear, modificar o eliminar
3. **Guarda** ese plan en un archivo (`tfplan`) para uso posterior
4. **Muestra** un resumen detallado en la consola

**¿Qué verás en el plan?**
```
Terraform will perform the following actions:

  # google_compute_instance.vm will be created
  + resource "google_compute_instance" "vm" {
      + boot_disk              = [
          + {
              + device_name = "persistent-disk-0"
              + disk_id     = (known after apply)
              + size        = 20
              + type        = "pd-standard"
            },
        ]
      + machine_type           = "e2-small"
      + name                   = "mi-jenkins-vm"
      + zone                   = "us-central1-a"
    }

Plan: 5 to add, 0 to change, 0 to destroy.
```

#### **Stage 5: Aprobación Manual (¡CRÍTICO!)**
```groovy
stage('Manual Approval') {
  steps {
    timeout(time: 15, unit: 'MINUTES') {
      input message: '¿Aplicar los cambios de Terraform?', ok: 'Aplicar'
    }
  }
}
```

**¿Por qué este stage es CRÍTICO?**
- **Previene errores costosos**: Un humano siempre revisa antes de gastar dinero
- **Seguridad**: Nadie puede crear recursos sin aprobación explícita
- **Aprendizaje**: Fuerzas a leer y entender qué va a pasar

**¿Cómo funciona?**
1. El pipeline se **DETIENE** aquí
2. Recibes una **notificación** (email/Slack si configurado)
3. Puedes **revisar** el plan en los logs
4. **Decides**: ¿Proceder o abortar?
5. Si no respondes en 15 minutos, se **cancela automáticamente**

#### **Stage 6: Aplicar Cambios**
```groovy
stage('Apply') {
  steps {
    sh '''
      terraform apply -input=false -auto-approve tfplan
    '''
  }
}
```

**¿Qué hace?**
- **Ejecuta** exactamente el plan previamente generado
- **No** puede hacer cambios diferentes (usa el archivo `tfplan`)
- **Registra** todo el proceso para debugging
- **Actualiza** el estado de Terraform

**¿Por qué `auto-approve`?**
- Ya aprobaste manualmente en el stage anterior
- Usar el archivo `tfplan` garantiza que no hay sorpresas

#### **Stage 7: Post-procesamiento**
```groovy
post {
  always {
    sh '''
      terraform output -json > tf-outputs.json || true
    '''
    archiveArtifacts artifacts: 'tf-outputs.json', onlyIfSuccessful: false, fingerprint: true
  }
}
```

**¿Qué hace `terraform output`?**
- Extrae información importante (IP de la VM, URL de Jenkins, etc.)
- Lo guarda en formato JSON para uso posterior

**¿Qué hace `archiveArtifacts`?**
- **Guarda** los resultados dentro de Jenkins
- **Siempre** disponible para descargar, incluso si algo falla
- **Versionado**: Puedes comparar outputs entre ejecuciones

---

## 🏗️ Infraestructura Creada con Terraform - Explicación Detallada

### ¿Qué recursos se crean exactamente?

#### 1. **Máquina Virtual (google_compute_instance)**

```hcl
resource "google_compute_instance" "vm" {
  name         = "${var.name_prefix}-vm"    # ← "mi-jenkins-vm"
  project      = var.project_id             # ← Tu proyecto GCP
  zone         = var.zone                   # ← "us-central1-a"
  machine_type = var.machine_type           # ← "e2-small"
  tags         = ["ssh", "jenkins"]         # ← Para reglas de firewall
```

**¿Qué significa cada configuración?**

- **`name`**: Como se llama la VM en GCP (aparecerá en la consola)
- **`zone`**: Ubicación física del servidor (afecta latencia y disponibilidad)
- **`machine_type`**: Especificaciones de hardware:
  ```
  e2-small = 2 vCPUs shared + 2GB RAM
  ¿Suficiente para Jenkins? ¡Sí! Con la swap que agregamos
  ¿Costo? ~$13/mes (pero Free Tier te da 744 horas gratis)
  ```
- **`tags`**: "Etiquetas" que permiten aplicar reglas de firewall

#### **Disco de arranque:**
```hcl
boot_disk {
  initialize_params {
    image = var.boot_image        # ← "ubuntu-os-cloud/ubuntu-2204-lts"
    size  = var.boot_disk_gb      # ← 20GB
    type  = "pd-standard"         # ← SSD estándar (más barato)
  }
}
```

**¿Por qué Ubuntu 22.04 LTS?**
- **LTS**: Long Term Support (5 años de actualizaciones de seguridad)
- **Estabilidad**: Versión probada y confiable
- **Compatibilidad**: Jenkins funciona perfectamente
- **Documentación**: Mucha información disponible

**¿Por qué 20GB?**
- **Sistema base**: ~5GB
- **Java + Jenkins**: ~3GB
- **Logs**: ~2GB
- **Espacio libre**: 10GB para tus proyectos

#### **Red y IP pública:**
```hcl
network_interface {
  subnetwork = local.default_subnet_self_link  # ← Red "default" de GCP
  access_config {}                             # ← IP pública efímera
}
```

**¿Qué es una IP efímera?**
- **Gratuita**: No pagas extra por la IP
- **Cambia**: Si apagas la VM, puede cambiar la IP
- **Suficiente**: Para desarrollo y aprendizaje es perfecta

#### **Script de inicialización (¡Lo más interesante!):**
```hcl
metadata_startup_script = <<-EOT
  #!/usr/bin/env bash
  set -euxo pipefail                    # ← Modo estricto
  export DEBIAN_FRONTEND=noninteractive # ← No pedir input del usuario
```

**¿Qué hace este script? (¡Es fascinante!)**

**Paso 1: Crear memoria swap**
```bash
if [ ! -f /swapfile ]; then
  fallocate -l 1G /swapfile           # ← Crear archivo de 1GB
  chmod 600 /swapfile                 # ← Solo root puede leerlo
  mkswap /swapfile                    # ← Formatearlo como swap
  swapon /swapfile                    # ← Activarlo inmediatamente
  echo '/swapfile none swap sw 0 0' >> /etc/fstab  # ← Activar al reiniciar
fi
```

**¿Por qué swap?**
- **Jenkins** consume mucha RAM al arrancar
- **e2-small** tiene solo 2GB de RAM
- **1GB de swap** previene errores de "out of memory"

**Paso 2: Configurar timeouts de systemd**
```bash
mkdir -p /etc/systemd/system/jenkins.service.d
cat >/etc/systemd/system/jenkins.service.d/override.conf <<'OVR'
[Service]
TimeoutStartSec=15min    # ← Jenkins puede tardar hasta 15 min en arrancar
RestartSec=5s           # ← Si falla, reintentar en 5 segundos
OVR
systemctl daemon-reload
```

**¿Por qué esto?**
- **Jenkins tarda**: Especialmente en VMs pequeñas
- **Por defecto**: systemd mata procesos que tardan >90 segundos
- **Sin esto**: Jenkins se mata antes de arrancar completamente

**Paso 3: Instalar Jenkins (¡El proceso completo!)**
```bash
if ! dpkg -s jenkins >/dev/null 2>&1; then  # ← Solo si no está instalado
  apt-get update
  apt-get install -y fontconfig openjdk-17-jre curl gnupg
  
  # Añadir clave de Jenkins
  curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
    | tee /usr/share/keyrings/jenkins-keyring.asc >/dev/null
  
  # Añadir repositorio
  echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
    > /etc/apt/sources.list.d/jenkins.list
  
  # Instalar Jenkins
  apt-get update
  apt-get install -y jenkins
fi

systemctl enable --now jenkins  # ← Arrancar y habilitar arranque automático
```

**¿Por qué este proceso?**
1. **Repositorio oficial**: Siempre la versión más actual y segura
2. **Verificación de firma**: La clave GPG asegura que el paquete no está alterado
3. **Idempotencia**: Si ejecutas el script 100 veces, el resultado es el mismo
4. **Java 17**: Versión LTS recomendada para Jenkins

#### 2. **Service Account (Identidad de la VM)**

```hcl
resource "google_service_account" "vm_sa" {
  account_id   = "${var.name_prefix}-vm-sa"
  display_name = "SA for VM"
}
```

**¿Qué es una Service Account?**
- Es como un "usuario robot" para la VM
- Tiene permisos específicos (no todos)
- Más seguro que usar tu cuenta personal

**¿Qué permisos tiene?**
```hcl
scopes = [
  "https://www.googleapis.com/auth/logging.write",      # ← Escribir logs
  "https://www.googleapis.com/auth/monitoring.write",   # ← Escribir métricas
]
```

**¿Por qué estos permisos?**
- **logging.write**: Jenkins puede enviar logs a Cloud Logging (debugging)
- **monitoring.write**: Métricas de performance a Cloud Monitoring
- **NO tiene**: Permisos para crear/eliminar otros recursos

#### 3. **Reglas de Firewall (¡Seguridad!)**

**Regla SSH (puerto 22):**
```hcl
resource "google_compute_firewall" "allow_ssh" {
  name      = "${var.name_prefix}-allow-ssh"
  network   = "projects/${var.project_id}/global/networks/default"
  direction = "INGRESS"                    # ← Tráfico entrante
  
  allow {
    protocol = "tcp"
    ports    = ["22"]                      # ← Solo puerto SSH
  }
  
  source_ranges = local.effective_allowlist  # ← Solo TU IP
  target_tags   = ["ssh"]                    # ← Solo VMs con tag "ssh"
}
```

**Regla Jenkins (puerto 8080):**
```hcl
resource "google_compute_firewall" "allow_jenkins_8080" {
  # Similar pero para puerto 8080 y tag "jenkins"
}
```

**¿Cómo funciona la detección automática de IP?**
```hcl
data "http" "my_ip" {
  url = "https://api.ipify.org"  # ← Servicio que devuelve tu IP pública
}

locals {
  my_ip_cidr = "${chomp(data.http.my_ip.response_body)}/32"
  effective_allowlist = length(var.allowed_ip_ranges) > 0 ? var.allowed_ip_ranges : [local.my_ip_cidr]
}
```

**¿Qué significa esto?**
1. **`data "http"`**: Terraform hace una petición HTTP a ipify.org
2. **`chomp()`**: Elimina saltos de línea del resultado
3. **`/32`**: Significa "exactamente esta IP" (no un rango)
4. **`effective_allowlist`**: Si NO especificas IPs, usa la tuya automáticamente

**¿Por qué es genial?**
- **Automático**: No necesitas saber tu IP
- **Seguro**: Solo tú puedes acceder
- **Flexible**: Puedes especificar IPs manualmente si quieres

---

## 🎮 Ejecutando el Pipeline - Paso a Paso

### 1. **Ejecutar por Primera Vez**

1. **Ir al Pipeline**: En Jenkins, click en `terraform-jenkins-vm`
2. **Iniciar**: Click en `Build Now`
3. **Observar**: El pipeline comenzará automáticamente

### 2. **¿Qué verás en cada Stage?**

#### **Stage: Checkout**
```
Started by user admin
Running in Durability level: MAX_SURVIVABILITY
[Pipeline] Start of Pipeline
[Pipeline] node
[Pipeline] {
[Pipeline] stage
[Pipeline] { (Checkout)
[Pipeline] git
Cloning the remote Git repository
Commit message: "Add Terraform Jenkins VM configuration"
```

**¿Qué significa?** Jenkins descargó exitosamente el código del repositorio.

#### **Stage: Terraform CLI**
```
[Pipeline] { (Terraform CLI)
[Pipeline] sh
+ TF_DIR=/var/jenkins_home/workspace/terraform-jenkins-vm/.tf-bin
+ mkdir -p /var/jenkins_home/workspace/terraform-jenkins-vm/.tf-bin
+ '[' '!' -x /var/jenkins_home/workspace/terraform-jenkins-vm/.tf-bin/terraform ']'
+ curl -fsSLO https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
+ unzip -o terraform_1.6.6_linux_amd64.zip -d /var/jenkins_home/workspace/terraform-jenkins-vm/.tf-bin
Archive:  terraform_1.6.6_linux_amd64.zip
  inflating: terraform
+ chmod +x /var/jenkins_home/workspace/terraform-jenkins-vm/.tf-bin/terraform
+ export PATH=/var/jenkins_home/workspace/terraform-jenkins-vm/.tf-bin:PATH
+ terraform -version
Terraform v1.6.6
```

**¿Qué significa?** Terraform se instaló correctamente y está listo para usar.

#### **Stage: Init & Validate**
```
[Pipeline] { (Init & Validate)
[Pipeline] dir
Running in /var/jenkins_home/workspace/terraform-jenkins-vm/jenkins/terraform-jenkins-vm
[Pipeline] {
[Pipeline] withCredentials
Masking supported pattern matches of $GOOGLE_CLOUD_KEYFILE_JSON
[Pipeline] {
[Pipeline] sh
+ export GOOGLE_APPLICATION_CREDENTIALS=****
+ terraform init -input=false -upgrade

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/google versions matching "~> 5.0"...
- Installing hashicorp/google v5.10.0...
- Installed hashicorp/google v5.10.0 (signed by HashiCorp)

Terraform has been successfully initialized!

+ terraform validate
Success! The configuration is valid.
```

**¿Qué significa?**
- **Credentials masking**: Jenkins oculta el archivo JSON por seguridad
- **Provider installation**: Descargó el plugin de Google Cloud v5.10.0
- **Validation success**: Todos los archivos .tf son correctos

#### **Stage: Plan**
```
[Pipeline] { (Plan)
[Pipeline] sh
+ terraform plan -input=false -out=tfplan -compact-warnings

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # google_compute_firewall.allow_jenkins_8080 will be created
  + resource "google_compute_firewall" "allow_jenkins_8080" {
      + creation_timestamp = (known after apply)
      + destination_ranges = (known after apply)
      + direction          = "INGRESS"
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "mi-jenkins-allow-jenkins-8080"
      + network            = "projects/tu-proyecto-devops-2024/global/networks/default"
      + priority           = 1000
      + project            = "tu-proyecto-devops-2024"
      + self_link          = (known after apply)
      + source_ranges      = [
          + "203.0.113.45/32",  # ← Tu IP detectada automáticamente
        ]
      + target_tags        = [
          + "jenkins",
        ]

      + allow {
          + ports    = [
              + "8080",
            ]
          + protocol = "tcp"
        }
    }

  # google_compute_firewall.allow_ssh will be created
  + resource "google_compute_firewall" "allow_ssh" {
      + creation_timestamp = (known after apply)
      + destination_ranges = (known after apply)
      + direction          = "INGRESS"
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "mi-jenkins-allow-ssh"
      + network            = "projects/tu-proyecto-devops-2024/global/networks/default"
      + priority           = 1000
      + project            = "tu-proyecto-devops-2024"
      + self_link          = (known after apply)
      + source_ranges      = [
          + "203.0.113.45/32",  # ← Tu IP detectada automáticamente
        ]
      + target_tags        = [
          + "ssh",
        ]

      + allow {
          + ports    = [
              + "22",
            ]
          + protocol = "tcp"
        }
    }

  # google_compute_instance.vm will be created
  + resource "google_compute_instance" "vm" {
      + can_ip_forward       = false
      + cpu_platform         = (known after apply)
      + current_status       = (known after apply)
      + deletion_protection  = false
      + guest_accelerator    = (known after apply)
      + id                   = (known after apply)
      + instance_id          = (known after apply)
      + label_fingerprint    = (known after apply)
      + machine_type         = "e2-small"
      + metadata_fingerprint = (known after apply)
      + name                 = "mi-jenkins-vm"
      + project              = "tu-proyecto-devops-2024"
      + self_link            = (known after apply)
      + tags                 = [
          + "jenkins",
          + "ssh",
        ]
      + tags_fingerprint     = (known after apply)
      + zone                 = "us-central1-a"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = "READ_WRITE"
          + source      = (known after apply)

          + initialize_params {
              + image  = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
              + size   = 20
              + type   = "pd-standard"
            }
        }

      + network_interface {
          + name               = (known after apply)
          + network            = (known after apply)
          + network_ip         = (known after apply)
          + subnetwork         = "projects/tu-proyecto-devops-2024/regions/us-central1/subnetworks/default"
          + subnetwork_project = (known after apply)

          + access_config {
              + nat_ip       = (known after apply)
              + network_tier = (known after apply)
            }
        }

      + service_account {
          + email  = (known after apply)
          + scopes = [
              + "https://www.googleapis.com/auth/logging.write",
              + "https://www.googleapis.com/auth/monitoring.write",
            ]
        }
    }

  # google_project_service.compute will be created
  + resource "google_project_service" "compute" {
      + disable_on_destroy = false
      + id                 = (known after apply)
      + project            = "tu-proyecto-devops-2024"
      + service            = "compute.googleapis.com"
    }

  # google_service_account.vm_sa will be created
  + resource "google_service_account" "vm_sa" {
      + account_id   = "mi-jenkins-vm-sa"
      + display_name = "SA for VM"
      + email        = (known after apply)
      + id           = (known after apply)
      + name         = (known after apply)
      + project      = "tu-proyecto-devops-2024"
      + unique_id    = (known after apply)
    }

  # google_service_account_iam_binding.vm_sa_user will be created
  + resource "google_service_account_iam_binding" "vm_sa_user" {
      + etag               = (known after apply)
      + id                 = (known after apply)
      + members            = [
          + "serviceAccount:jenkins-terraform-sa@tu-proyecto-devops-2024.iam.gserviceaccount.com",
        ]
      + role               = "roles/iam.serviceAccountUser"
      + service_account_id = (known after apply)
    }

Plan: 6 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + external_ip    = (known after apply)
  + instance_name  = "mi-jenkins-vm"
  + jenkins_url    = (known after apply)
  + ssh_example    = "gcloud compute ssh mi-jenkins-vm --zone us-central1-a"

Saved the plan to: tfplan
```

**🎯 ¡ESTE ES EL MOMENTO MÁS IMPORTANTE!**

**¿Qué debes revisar en el plan?**

1. **Recursos a crear (Plan: 6 to add)**:
   - ✅ 1 VM (e2-small, Ubuntu 22.04, 20GB)
   - ✅ 1 Service Account para la VM
   - ✅ 2 reglas de firewall (SSH + Jenkins)
   - ✅ 1 permiso IAM
   - ✅ 1 habilitación de API

2. **Configuraciones clave**:
   - ✅ `machine_type = "e2-small"` (Free Tier eligible)
   - ✅ `source_ranges = ["TU-IP/32"]` (Solo tu IP)
   - ✅ `zone = "us-central1-a"` (Free Tier region)

3. **Costos estimados**:
   - VM e2-small: ~$13/mes (¡pero 744 horas gratis con Free Tier!)
   - Disco 20GB: ~$0.80/mes
   - IP pública: $0 (efímera)
   - **Total**: ~$14/mes, pero GRATIS con Free Tier por ~30 días

#### **Stage: Manual Approval**
```
[Pipeline] { (Manual Approval)
[Pipeline] timeout
Timeout set to expire in 15 min 0 sec
[Pipeline] {
[Pipeline] input
¿Aplicar los cambios de Terraform?
Proceed or Abort
```

**¡AQUÍ ES DONDE TÚ DECIDES!**

**¿Cómo evaluar si proceder?**

✅ **PROCEDE si ves**:
- Plan muestra exactamente 6 recursos
- machine_type es "e2-small"
- source_ranges es tu IP o las que especificaste
- No hay destrucciones inesperadas

❌ **ABORTA si ves**:
- Recursos inesperados (bases de datos, load balancers costosos)
- machine_type diferente a e2-small
- source_ranges con "0.0.0.0/0" (acceso mundial)
- Cambios en recursos que no deberían cambiar

**Para proceder**: Click `Aplicar`
**Para abortar**: Click `Abort` o espera 15 minutos

#### **Stage: Apply**
```
[Pipeline] { (Apply)
[Pipeline] sh
+ terraform apply -input=false -auto-approve tfplan

google_project_service.compute: Creating...
google_service_account.vm_sa: Creating...
google_project_service.compute: Still creating... [10s elapsed]
google_service_account.vm_sa: Creation complete after 4s [id=projects/tu-proyecto-devops-2024/serviceAccounts/mi-jenkins-vm-sa@tu-proyecto-devops-2024.iam.gserviceaccount.com]
google_service_account_iam_binding.vm_sa_user: Creating...
google_project_service.compute: Still creating... [20s elapsed]
google_service_account_iam_binding.vm_sa_user: Creation complete after 8s
google_project_service.compute: Creation complete after 28s [id=tu-proyecto-devops-2024/compute.googleapis.com]
google_compute_firewall.allow_ssh: Creating...
google_compute_firewall.allow_jenkins_8080: Creating...
google_compute_instance.vm: Creating...
google_compute_firewall.allow_ssh: Creation complete after 6s [id=projects/tu-proyecto-devops-2024/global/firewalls/mi-jenkins-allow-ssh]
google_compute_firewall.allow_jenkins_8080: Creation complete after 7s [id=projects/tu-proyecto-devops-2024/global/firewalls/mi-jenkins-allow-jenkins-8080]
google_compute_instance.vm: Still creating... [10s elapsed]
google_compute_instance.vm: Creation complete after 18s [id=projects/tu-proyecto-devops-2024/zones/us-central1-a/instances/mi-jenkins-vm]

Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

external_ip = "34.123.45.67"
instance_name = "mi-jenkins-vm"
jenkins_url = "http://34.123.45.67:8080"
ssh_example = "gcloud compute ssh mi-jenkins-vm --zone us-central1-a"
```

**🎉 ¡ÉXITO! ¿Qué pasó?**

1. **28 segundos**: Habilitar Compute Engine API
2. **4 segundos**: Crear Service Account
3. **8 segundos**: Asignar permisos IAM
4. **6-7 segundos**: Crear reglas de firewall
5. **18 segundos**: ¡Crear la VM!

**Total**: ~65 segundos para crear toda la infraestructura.

---

## 🔍 Verificación y Acceso a Jenkins

### 1. **Verificar que la VM está funcionando**

```bash
# Desde tu terminal local
gcloud compute instances list --filter="name:mi-jenkins-vm"

NAME           ZONE           MACHINE_TYPE  PREEMPTIBLE  INTERNAL_IP    EXTERNAL_IP    STATUS
mi-jenkins-vm  us-central1-a  e2-small                   10.128.0.2     34.123.45.67   RUNNING
```

### 2. **Conectarse por SSH**

```bash
# Usar OS Login (recomendado)
gcloud compute ssh mi-jenkins-vm --zone us-central1-a

# Una vez conectado, verificar Jenkins
sudo systemctl status jenkins
```

**¿Qué deberías ver?**
```
● jenkins.service - LSB: Start Jenkins at boot time
     Loaded: loaded (/etc/init.d/jenkins; generated)
     Active: active (running) since Thu 2024-01-15 10:30:45 UTC; 5min ago
       Docs: man:systemd-sysv-generator(8)
    Process: 1234 ExecStart=/etc/init.d/jenkins start (code=exited, status=0/SUCCESS)
      Tasks: 45 (limit: 2339)
     Memory: 512.5M
        CPU: 45.231s
     CGroup: /system.slice/jenkins.service
             └─1456 /usr/bin/java -Djava.awt.headless=true -jar /usr/share/jenkins/jenkins.war
```

### 3. **Obtener contraseña inicial de Jenkins**

```bash
# Desde SSH en la VM
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# Salida ejemplo:
f4d8e7c9b1a2345678901234567890ab
```

### 4. **Acceder a Jenkins por primera vez**

1. **Abrir navegador**: `http://34.123.45.67:8080` (usa TU IP)
2. **Pegar contraseña**: La que obtuviste arriba
3. **Setup wizard**: Igual que antes, pero ahora en GCP

---

## 🧪 Configuración Final de Jenkins en la VM

### 1. **Configurar Jenkins para gestión remota**

Una vez en Jenkins de la VM:

1. **Instalar plugins adicionales**:
   - **Blue Ocean**: Interface moderna
   - **Pipeline Stage View**: Visualización de stages
   - **Build Timeout**: Prevenir builds infinitos
   - **Timestamper**: Ya instalado, pero verificar

2. **Configurar credenciales** (importante):
   - Añadir la MISMA credencial GCP que usaste localmente
   - ID: `gcp-service-account-key`
   - Archivo: jenkins-sa-key.json

3. **Configurar seguridad**:
   - `Manage Jenkins` → `Configure Global Security`
   - **Authorization**: Matrix-based security
   - **Admin user**: Tu usuario con todos los permisos

### 2. **Crear pipeline recursivo (¡Inception!)**

Ahora puedes crear un pipeline EN LA VM que gestione infraestructura adicional:

```groovy
pipeline {
  agent any
  stages {
    stage('Deploy App Infrastructure') {
      steps {
        // Crear más VMs, bases de datos, etc.
        sh 'terraform apply -auto-approve app-infrastructure/'
      }
    }
  }
}
```

---

## 🔧 Personalización y Configuraciones Avanzadas

### 1. **Modificar variables para tu caso**

#### **Cambiar tipo de máquina:**
```hcl
# En terraform.tfvars
machine_type = "e2-medium"  # Más potencia (4GB RAM)
# Costo: ~$25/mes, pero mejor performance
```

#### **Añadir múltiples IPs permitidas:**
```hcl
# En terraform.tfvars
allowed_ip_ranges = [
  "203.0.113.1/32",      # Tu casa
  "198.51.100.0/24",     # Tu oficina (toda la red)
  "172.16.0.5/32"        # Tu VPN
]
```

#### **Cambiar región:**
```hcl
# En terraform.tfvars
region = "europe-west1"  # Bélgica (más cerca de Europa)
zone = "europe-west1-b"
```

### 2. **Extender el startup script**

```bash
# Añadir al final del startup script
# Instalar Docker para Jenkins
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker jenkins

# Instalar herramientas adicionales
apt-get install -y git vim htop tree

# Configurar timezone
timedatectl set-timezone America/Santiago
```

### 3. **Configurar SSL/HTTPS**

```hcl
# Añadir a main.tf
resource "google_compute_global_address" "jenkins_ip" {
  name = "${var.name_prefix}-jenkins-ip"
}

resource "google_compute_firewall" "allow_https" {
  name = "${var.name_prefix}-allow-https"
  # ... configuración para puerto 443
}
```

---

## 🚨 Troubleshooting - Problemas Comunes

### **Error: "Quota exceeded"**
```
Error: Error creating instance: googleapi: Error 403: Quota exceeded
```

**Causas**:
- No tienes Free Tier activo
- Ya usaste tu cuota de VMs
- Región sin Free Tier

**Soluciones**:
```bash
# Verificar cuotas
gcloud compute project-info describe --project=TU-PROYECTO

# Cambiar a región con Free Tier
region = "us-central1"  # Iowa
region = "us-east1"     # South Carolina  
region = "us-west1"     # Oregon
```

### **Error: "API not enabled"**
```
Error: Error creating instance: googleapi: Error 403: Compute Engine API has not been used
```

**Solución**:
```bash
gcloud services enable compute.googleapis.com --project=TU-PROYECTO
```

### **Error: "Permission denied"**
```
Error: Error creating instance: googleapi: Error 403: Required 'compute.instances.create' permission
```

**Solución**: Verificar permisos de Service Account:
```bash
gcloud projects get-iam-policy TU-PROYECTO \
  --flatten="bindings[].members" \
  --format="table(bindings.role)" \
  --filter="bindings.members:jenkins-terraform-sa@TU-PROYECTO.iam.gserviceaccount.com"
```

### **Jenkins no responde en puerto 8080**

**Pasos de debugging**:

1. **Verificar estado de la VM**:
   ```bash
   gcloud compute instances describe mi-jenkins-vm --zone=us-central1-a
   ```

2. **Conectar por SSH y verificar**:
   ```bash
   gcloud compute ssh mi-jenkins-vm --zone=us-central1-a
   
   # ¿Jenkins está corriendo?
   sudo systemctl status jenkins
   
   # ¿Está escuchando en puerto 8080?
   sudo netstat -tlnp | grep :8080
   
   # ¿Hay errores en los logs?
   sudo journalctl -u jenkins --no-pager -l
   ```

3. **Verificar startup script**:
   ```bash
   # ¿Se ejecutó el startup script?
   sudo cat /var/log/syslog | grep startup-script
   
   # ¿Hay swap configurada?
   swapon -s
   
   # ¿Java está instalado?
   java -version
   ```

### **Firewall bloqueando acceso**

**Verificar reglas de firewall**:
```bash
gcloud compute firewall-rules list --filter="name:mi-jenkins"

NAME                        DIRECTION  PRIORITY  ALLOW   DENY    DISABLED
mi-jenkins-allow-jenkins-8080  INGRESS    1000      tcp:8080        False
mi-jenkins-allow-ssh          INGRESS    1000      tcp:22          False
```

**Verificar tu IP actual**:
```bash
curl -s https://api.ipify.org
# ¿Es la misma que aparece en source_ranges del firewall?
```

### **Jenkins tarda mucho en arrancar**

Es **NORMAL**. En una VM e2-small, Jenkins puede tardar:
- **2-5 minutos**: Arranque inicial
- **10-15 minutos**: Primera instalación completa
- **1-2 minutos**: Arranques posteriores

**Monitorear progreso**:
```bash
# Logs en tiempo real
sudo tail -f /var/log/jenkins/jenkins.log

# CPU y memoria
htop

# Procesos Java
ps aux | grep java
```

---

## 💰 Gestión de Costos y Free Tier

### **¿Cuánto cuesta exactamente?**

#### **Con Free Tier (primeros 12 meses)**:
- **VM e2-small**: 744 horas/mes GRATIS (24/7 por un mes completo)
- **Disco persistente**: 30GB GRATIS (tenemos 20GB)
- **IP pública efímera**: $0
- **Tráfico saliente**: 1GB/mes GRATIS
- **Total**: $0/mes durante Free Tier

#### **Sin Free Tier**:
- **VM e2-small**: $13.07/mes (us-central1)
- **Disco 20GB**: $0.80/mes
- **IP pública efímera**: $0
- **Total**: ~$14/mes

#### **Optimizaciones de costo**:

1. **Usar preemptible VMs** (70% descuento):
```hcl
# En main.tf
resource "google_compute_instance" "vm" {
  # ... otras configuraciones
  scheduling {
    preemptible = true
    automatic_restart = false
    on_host_maintenance = "TERMINATE"
  }
}
```

2. **Programar apagado nocturno**:
```bash
# Crontab en la VM
0 22 * * * sudo shutdown -h now    # Apagar a las 22:00
0 8 * * 1-5 gcloud compute instances start mi-jenkins-vm --zone us-central1-a  # Encender L-V 8:00
```

3. **Usar discos más pequeños**:
```hcl
boot_disk_gb = 10  # Mínimo para Ubuntu + Jenkins
```

### **Monitorear costos**

```bash
# Billing desde CLI
gcloud billing accounts list
gcloud billing budgets list --billing-account=ACCOUNT-ID

# Ver costos actuales
gcloud billing accounts get-iam-policy ACCOUNT-ID
```

---

## 🧹 Limpieza y Eliminación de Recursos

### **¿Cuándo eliminar recursos?**

- **Desarrollo terminado**: Ya no necesitas Jenkins
- **Fin de mes**: Evitar costos del siguiente ciclo
- **Experimentación**: Probar diferentes configuraciones

### **Opción 1: Pipeline de Destroy**

Crear un pipeline específico para eliminar:

```groovy
// Jenkinsfile-destroy
pipeline {
  agent any
  stages {
    stage('Destroy Confirmation') {
      steps {
        timeout(time: 5, unit: 'MINUTES') {
          input message: '¿ELIMINAR TODOS LOS RECURSOS? Esta acción NO se puede deshacer', ok: 'ELIMINAR TODO'
        }
      }
    }
    stage('Terraform Destroy') {
      steps {
        sh '''
          export PATH="$WORKSPACE/.tf-bin:$PATH"
          terraform destroy -auto-approve
        '''
      }
    }
  }
}
```

### **Opción 2: Manual desde CLI**

```bash
# Desde tu máquina local
cd jenkins/terraform-jenkins-vm
terraform destroy

# Te mostrará qué va a eliminar:
Plan: 0 to add, 0 to change, 6 to destroy.

# Confirma escribiendo: yes
```

### **Opción 3: Desde GCP Console**

1. **VM**: `Compute Engine` → `VM instances` → Seleccionar → `Delete`
2. **Firewall**: `VPC network` → `Firewall` → Seleccionar reglas → `Delete`
3. **Service Account**: `IAM & Admin` → `Service Accounts` → Delete

**⚠️ Orden importante**: Elimina la VM primero, luego firewall, después service accounts.

---

## 🚀 Siguientes Pasos y Proyectos Avanzados

### **1. Infraestructura Multi-Tier**

```hcl
# Añadir base de datos
resource "google_sql_database_instance" "postgres" {
  name             = "${var.name_prefix}-postgres"
  database_version = "POSTGRES_14"
  region           = var.region

  settings {
    tier = "db-f1-micro"  # Free Tier eligible
  }
}

# Añadir Load Balancer
resource "google_compute_global_forwarding_rule" "lb" {
  name       = "${var.name_prefix}-lb"
  target     = google_compute_target_http_proxy.lb.id
  port_range = "80"
}
```

### **2. Multi-Environment (Dev/Staging/Prod)**

```
terraform/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   └── terraform.tfvars
│   ├── staging/
│   │   ├── main.tf
│   │   └── terraform.tfvars
│   └── prod/
│       ├── main.tf
│       └── terraform.tfvars
└── modules/
    └── jenkins-vm/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

### **3. Monitoreo y Alertas**

```hcl
# Cloud Monitoring
resource "google_monitoring_alert_policy" "high_cpu" {
  display_name = "Jenkins VM High CPU"
  conditions {
    display_name = "CPU usage"
    condition_threshold {
      filter          = "resource.type=\"gce_instance\" resource.labels.instance_name=\"${google_compute_instance.vm.name}\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0.8
      duration        = "300s"
    }
  }
}
```

### **4. Backup Automatizado**

```hcl
# Snapshots automáticos
resource "google_compute_resource_policy" "backup" {
  name   = "${var.name_prefix}-backup-policy"
  region = var.region
  
  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "04:00"
      }
    }
    retention_policy {
      max_retention_days = 7
    }
  }
}
```

### **5. CI/CD Completo**

Pipeline que incluya:
- **Testing**: Terraform validate, plan, security scan
- **Staging**: Deploy a entorno de pruebas
- **Production**: Deploy con aprobación manual
- **Rollback**: Capacidad de volver a versión anterior

```groovy
pipeline {
  agent any
  parameters {
    choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'prod'], description: 'Target environment')
    booleanParam(name: 'DESTROY', defaultValue: false, description: 'Destroy infrastructure instead of deploy')
  }
  
  stages {
    stage('Test') {
      steps {
        sh '''
          terraform fmt -check=true
          terraform validate
          tflint
        '''
      }
    }
    
    stage('Security Scan') {
      steps {
        sh 'checkov -f main.tf'
      }
    }
    
    stage('Plan') {
      steps {
        sh '''
          cd environments/${ENVIRONMENT}
          terraform plan -out=tfplan
        '''
      }
    }
    
    stage('Deploy to Staging') {
      when { params.ENVIRONMENT == 'staging' }
      steps {
        sh 'terraform apply -auto-approve tfplan'
      }
    }
    
    stage('Production Approval') {
      when { params.ENVIRONMENT == 'prod' }
      steps {
        timeout(time: 30, unit: 'MINUTES') {
          input message: 'Deploy to PRODUCTION?', ok: 'Deploy'
        }
      }
    }
    
    stage('Deploy to Production') {
      when { params.ENVIRONMENT == 'prod' }
      steps {
        sh 'terraform apply -auto-approve tfplan'
      }
    }
  }
}
```

---

## 📚 Recursos de Aprendizaje y Referencias

### **Documentación Oficial**

1. **Terraform**:
   - [Getting Started Guide](https://learn.hashicorp.com/terraform)
   - [Google Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
   - [Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

2. **Jenkins**:
   - [Jenkins User Handbook](https://www.jenkins.io/doc/book/)
   - [Pipeline Syntax Reference](https://www.jenkins.io/doc/book/pipeline/syntax/)
   - [Plugin Index](https://plugins.jenkins.io/)

3. **Google Cloud Platform**:
   - [GCP Free Tier](https://cloud.google.com/free)
   - [Compute Engine Documentation](https://cloud.google.com/compute/docs)
   - [Best Practices for Compute Engine](https://cloud.google.com/compute/docs/best-practices)

### **Herramientas Útiles**

#### **Terraform Tools**:
```bash
# Formatear código automáticamente
terraform fmt

# Validar sintaxis
terraform validate

# Linter para mejores prácticas
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# Security scanner
pip install checkov
checkov -f main.tf
```

#### **Monitoreo y Debugging**:
```bash
# Ver logs detallados de Terraform
export TF_LOG=DEBUG
terraform apply

# Ver costos estimados
terraform plan -out=tfplan
terraform show -json tfplan | jq '.planned_values.root_module.resources'

# Analizar dependencias
terraform graph | dot -Tpng > graph.png
```

#### **Mejores Prácticas de Seguridad**:

1. **Nunca hardcodear secretos**:
   ```hcl
   # ❌ MAL
   admin_password = "mi-password-secreto"
   
   # ✅ BIEN
   admin_password = var.admin_password
   ```

2. **Usar remote state**:
   ```hcl
   terraform {
     backend "gcs" {
       bucket = "tu-proyecto-terraform-state"
       prefix = "jenkins-vm"
     }
   }
   ```

3. **Rotación de credenciales**:
   ```bash
   # Rotar service account key cada 90 días
   gcloud iam service-accounts keys create new-key.json \
     --iam-account=jenkins-terraform-sa@proyecto.iam.gserviceaccount.com
   
   # Actualizar credencial en Jenkins
   # Eliminar clave antigua
   gcloud iam service-accounts keys delete KEY-ID \
     --iam-account=jenkins-terraform-sa@proyecto.iam.gserviceaccount.com
   ```

### **Comandos Útiles de Referencia**

#### **GCP CLI (gcloud)**:
```bash
# Listar proyectos
gcloud projects list

# Cambiar proyecto activo
gcloud config set project TU-PROYECTO

# Ver configuración actual
gcloud config list

# Listar VMs
gcloud compute instances list

# Conectar por SSH
gcloud compute ssh NOMBRE-VM --zone=ZONA

# Ver logs de startup script
gcloud compute instances get-serial-port-output NOMBRE-VM --zone=ZONA

# Detener VM (para ahorrar costos)
gcloud compute instances stop NOMBRE-VM --zone=ZONA

# Iniciar VM
gcloud compute instances start NOMBRE-VM --zone=ZONA
```

#### **Terraform CLI**:
```bash
# Inicializar directorio
terraform init

# Ver cambios planeados
terraform plan

# Aplicar cambios
terraform apply

# Mostrar estado actual
terraform show

# Listar recursos
terraform state list

# Ver outputs
terraform output

# Importar recursos existentes
terraform import google_compute_instance.vm projects/PROYECTO/zones/ZONA/instances/NOMBRE

# Destruir todo
terraform destroy
```

#### **Jenkins CLI (desde SSH)**:
```bash
# Reiniciar Jenkins
sudo systemctl restart jenkins

# Ver logs
sudo journalctl -u jenkins -f

# Cambiar configuración
sudo nano /etc/default/jenkins

# Ver procesos Java
ps aux | grep java

# Verificar puerto
sudo netstat -tlnp | grep :8080

# Espacio en disco
df -h
du -sh /var/lib/jenkins/
```

---

## 🎓 Ejercicios Prácticos para Aprender

### **Ejercicio 1: Modificar la VM**

**Objetivo**: Cambiar el tipo de máquina y añadir más disco.

**Pasos**:
1. Modifica `terraform.tfvars`:
   ```hcl
   machine_type = "e2-medium"
   boot_disk_gb = 30
   ```

2. Ejecuta el pipeline
3. **Pregunta**: ¿Qué muestra el plan? ¿Se destruye la VM?
4. **Respuesta esperada**: Terraform debe mostrar que necesita **detener y modificar** la VM, no recrearla.

### **Ejercicio 2: Añadir una segunda VM**

**Objetivo**: Crear un "worker node" adicional.

**En main.tf añade**:
```hcl
resource "google_compute_instance" "worker" {
  name         = "${var.name_prefix}-worker"
  machine_type = "e2-micro"  # Más pequeña
  zone         = var.zone
  
  boot_disk {
    initialize_params {
      image = var.boot_image
      size  = 10
    }
  }
  
  network_interface {
    subnetwork = local.default_subnet_self_link
    # Sin access_config = sin IP pública
  }
  
  # Sin startup script = solo Ubuntu base
  
  service_account {
    email  = google_service_account.vm_sa.email
    scopes = ["cloud-platform"]
  }
}
```

**Pregunta**: ¿Por qué no tiene IP pública? ¿Cómo accederías a ella?

### **Ejercicio 3: Implementar HTTPS**

**Objetivo**: Configurar Jenkins con SSL usando Let's Encrypt.

**Modificar startup script**:
```bash
# Añadir al final del startup script
apt-get install -y nginx certbot python3-certbot-nginx

# Configurar nginx como proxy reverso
cat >/etc/nginx/sites-available/jenkins <<'EOF'
server {
    listen 80;
    server_name jenkins.tu-dominio.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

ln -s /etc/nginx/sites-available/jenkins /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

# Obtener certificado SSL (requiere dominio real)
# certbot --nginx -d jenkins.tu-dominio.com
```

### **Ejercicio 4: Backup Automatizado**

**Objetivo**: Crear snapshots automáticos del disco.

**Añadir a main.tf**:
```hcl
resource "google_compute_resource_policy" "daily_backup" {
  name   = "${var.name_prefix}-daily-backup"
  region = var.region
  
  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "04:00"
      }
    }
    retention_policy {
      max_retention_days    = 7
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }
  }
}

resource "google_compute_disk_resource_policy_attachment" "backup_attachment" {
  name = google_compute_resource_policy.daily_backup.name
  disk = google_compute_instance.vm.name
  zone = var.zone
}
```

### **Ejercicio 5: Monitoreo Básico**

**Objetivo**: Configurar alertas cuando la VM tenga problemas.

**Crear alertas**:
```hcl
resource "google_monitoring_alert_policy" "vm_down" {
  display_name = "${var.name_prefix} VM Down"
  combiner     = "OR"
  
  conditions {
    display_name = "VM Instance Down"
    
    condition_threshold {
      filter         = "resource.type=\"gce_instance\" AND resource.labels.instance_name=\"${google_compute_instance.vm.name}\""
      comparison     = "COMPARISON_LT"
      threshold_value = 1
      duration       = "300s"
      
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }
  
  notification_channels = [google_monitoring_notification_channel.email.name]
}

resource "google_monitoring_notification_channel" "email" {
  display_name = "Email Notification"
  type         = "email"
  
  labels = {
    email_address = var.alert_email
  }
}
```

---

## 🐛 Debugging Avanzado

### **Terraform Debugging**

#### **Ver estado interno**:
```bash
# Estado completo
terraform show

# Estado de un recurso específico
terraform state show google_compute_instance.vm

# Dependencias entre recursos
terraform graph

# Logs detallados
export TF_LOG=DEBUG
terraform apply
```

#### **Problemas comunes de estado**:
```bash
# Estado corrupto
terraform state pull > backup.tfstate
terraform state push backup.tfstate

# Recurso creado manualmente, importar a Terraform
terraform import google_compute_instance.vm projects/PROYECTO/zones/ZONA/instances/NOMBRE

# Eliminar recurso del estado (sin eliminar el recurso real)
terraform state rm google_compute_instance.vm
```

### **Jenkins Debugging**

#### **Logs detallados**:
```bash
# Jenkins logs
sudo tail -f /var/log/jenkins/jenkins.log

# System logs
sudo journalctl -u jenkins -f

# Startup script logs
sudo cat /var/log/syslog | grep startup-script

# Ver configuración de Jenkins
sudo cat /etc/default/jenkins
```

#### **Problemas de performance**:
```bash
# Memoria y CPU
free -h
htop

# Espacio en disco
df -h
du -sh /var/lib/jenkins/

# Procesos que consumen recursos
ps aux --sort=-%cpu | head
ps aux --sort=-%mem | head

# Conexiones de red
sudo netstat -tulnp | grep :8080
```

### **GCP Debugging**

#### **Logs de la VM**:
```bash
# Serial console (útil si SSH no funciona)
gcloud compute instances get-serial-port-output mi-jenkins-vm --zone=us-central1-a

# Logs de Cloud Logging
gcloud logging read "resource.type=gce_instance AND resource.labels.instance_name=mi-jenkins-vm" --limit=50

# Métricas de CPU/Memory
gcloud compute instances describe mi-jenkins-vm --zone=us-central1-a --format="get(cpuPlatform,status,machineType)"
```

---

## 🏆 Proyecto Final: Jenkins Production-Ready

### **Objetivo**: Crear un Jenkins enterprise-grade

**Características que implementarás**:

1. **High Availability**:
   - Jenkins master + 2 worker nodes
   - Load balancer con health checks
   - Persistent storage compartido

2. **Security**:
   - HTTPS con certificados válidos
   - Firewall restrictivo por roles
   - Secrets management con Secret Manager

3. **Backup & Recovery**:
   - Snapshots automáticos
   - Backup de configuración a Cloud Storage
   - Procedimiento de disaster recovery

4. **Monitoring**:
   - Métricas custom de Jenkins
   - Alertas por email/Slack
   - Dashboards en Cloud Monitoring

5. **CI/CD Pipeline**:
   - Multi-environment (dev/staging/prod)
   - Automated testing
   - Security scanning
   - Rollback capabilities

**Estructura del proyecto final**:
```
jenkins-production/
├── terraform/
│   ├── modules/
│   │   ├── jenkins-master/
│   │   ├── jenkins-worker/
│   │   ├── load-balancer/
│   │   ├── monitoring/
│   │   └── backup/
│   └── environments/
│       ├── dev/
│       ├── staging/
│       └── prod/
├── jenkins/
│   ├── jobs/
│   ├── pipeline-libraries/
│   └── configurations/
├── monitoring/
│   ├── dashboards/
│   └── alerts/
└── docs/
    ├── runbooks/
    └── architecture/
```

---

## 📖 Conclusión

¡Felicidades! Has completado una introducción comprensiva al mundo de DevOps, Infrastructure as Code, y CI/CD. 

### **¿Qué has aprendido?**

✅ **Infrastructure as Code**: Crear infraestructura con código reproducible
✅ **Jenkins**: Instalar, configurar y usar para automatización
✅ **Pipelines**: Crear workflows automatizados seguros
✅ **Google Cloud Platform**: Gestionar recursos cloud de forma eficiente
✅ **Terraform**: Herramienta líder para IaC
✅ **Seguridad**: Mejores prácticas para credenciales y acceso
✅ **Troubleshooting**: Identificar y resolver problemas comunes
✅ **Costos**: Optimizar gastos cloud

### **¿Qué sigue?**

1. **Profundizar en Terraform**: Modules, remote state, workspaces
2. **Jenkins avanzado**: Shared libraries, distributed builds
3. **Conteneurización**: Docker, Kubernetes
4. **Monitoring**: Prometheus, Grafana, observabilidad
5. **Otros clouds**: AWS, Azure, multi-cloud
6. **GitOps**: ArgoCD, Flux para Kubernetes

### **Recursos para seguir aprendiendo**:

- **Libros**: "Terraform: Up & Running", "The Phoenix Project"
- **Cursos**: HashiCorp certifications, Jenkins certifications
- **Práctica**: Contribuir a proyectos open source
- **Comunidad**: DevOps meetups, conferencias

### **¡Tu feedback es importante!**

- ¿Qué parte fue más difícil de entender?
- ¿Qué ejemplos adicionales te gustaría ver?
- ¿Qué temas quieres profundizar?

**¡Ahora tienes las herramientas para automatizar cualquier infraestructura! 🚀**

---

## 📞 Soporte y Contacto

### **Si tienes problemas**:

1. **Revisa la sección Troubleshooting** de este README
2. **Verifica logs** de Jenkins y Terraform
3. **Busca en la documentación oficial**
4. **Crea un issue** en el repositorio con:
   - Descripción del problema
   - Logs completos
   - Configuración utilizada
   - Pasos para reproducir

### **Para contribuir**:

1. **Fork** el repositorio
2. **Crea una branch** para tu feature/fix
3. **Añade tests** si es necesario
4. **Envía un Pull Request** con descripción detallada

---

**¡Happy DevOps! 🎉**
