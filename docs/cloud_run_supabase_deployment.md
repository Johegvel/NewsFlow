# Guía de Despliegue: Ruby on Rails en Google Cloud Run + Supabase (PostgreSQL)

Esta guía detalla los pasos y comandos exactos para desplegar el backend de **Flews** en **Google Cloud Run** utilizando **Supabase** como base de datos PostgreSQL en la nube ($0 costo operativo).

---

## 📋 Arquitectura de Despliegue

```
┌────────────────────────┐         HTTPS          ┌───────────────────────────┐
│     App Flutter        │ ─────────────────────> │     Google Cloud Run      │
│  (Móvil / Web Client)  │                        │  (Backend Rails en Docker)│
└────────────────────────┘                        └─────────────┬─────────────┘
                                                                │
                                                                │ SSL (Port 5432 / 6543)
                                                                ▼
                                                  ┌───────────────────────────┐
                                                  │     Supabase Database     │
                                                  │    (PostgreSQL 16 Cloud)  │
                                                  └───────────────────────────┘
```

---

## 🗄️ PASO 1: Configurar Supabase (Base de Datos PostgreSQL)

1. Ingresa a [https://supabase.com](https://supabase.com) e inicia sesión con tu cuenta de GitHub.
2. Haz clic en **"New Project"**.
   * **Name:** `flews-backend`
   * **Database Password:** Define una contraseña segura (guárdala bien, la usaremos en `DATABASE_URL`).
   * **Region:** Selecciona la más cercana (ej. `us-east-1` Norte de Virginia o `sa-east-1` São Paulo).
   * **Pricing Plan:** Free ($0/mes).
3. Una vez creado el proyecto, ve a:
   * **Project Settings** (icono de engranaje) ➔ **Database**.
   * Baja hasta la sección **"Connection string"** ➔ Pestaña **"URI"** o **"Connection Pooler"**.
4. Copia dos cadenas de conexión:
   * `DATABASE_URL`: conexión Pooler/Transaction en puerto `6543`, usada por el servicio Rails.
   * `MIGRATION_DATABASE_URL`: conexión directa o Session Pooler en puerto `5432`, usada únicamente por el Job de migraciones.

   Tendrán un formato como este:
   ```text
   postgresql://postgres.[PROJECT_REF]:[TU_CONTRASEÑA]@aws-0-[REGION].pooler.supabase.com:5432/postgres?sslmode=require
   ```

> Si una credencial de Supabase fue incluida alguna vez en un archivo versionado, cambia la contraseña de la base antes de desplegar y actualiza ambos secretos.

---

## 🔐 PASO 2: Generar la Clave Secreta de Rails (`SECRET_KEY_BASE`)

Genera una clave secreta segura para producción ejecutando en tu terminal local:

```bash
# En powershell o bash:
python -c "import secrets; print(secrets.token_hex(64))"
```
*(Guarda el valor generado de 128 caracteres, será tu `SECRET_KEY_BASE`).*

---

## ☁️ PASO 3: Desplegar en Google Cloud Run

Tienes **dos métodos** para desplegar:

### 🌟 Opción A: GitHub Actions con migración controlada

#### Modo transitorio: reutilizar la configuración vigente

Mientras se crean y rotan los secretos definitivos, el workflow puede desplegar con el
`GCP_SA_KEY` ya configurado. La cuenta de servicio identifica el proyecto y el runner
recupera `SECRET_KEY_BASE` y `DATABASE_URL` directamente del servicio Cloud Run vigente.
Los valores se escriben con permisos privados dentro de `RUNNER_TEMP`, no se imprimen y
se eliminan al finalizar el job.

Este modo exige que `flews-backend` ya exista y tenga ambas variables configuradas como
valores de entorno. La misma `DATABASE_URL` se utiliza temporalmente para el servicio y
para el Job de migración.

> Este mecanismo evita volver a versionar credenciales, pero no reemplaza la rotación
> pendiente. La configuración recomendada a largo plazo es la siguiente.

#### Configuración definitiva recomendada

Configura estos secretos en **GitHub → Settings → Secrets and variables → Actions**:

| Secreto | Uso |
| :--- | :--- |
| `GCP_PROJECT_ID` | ID del proyecto de Google Cloud. |
| `GCP_REGION` | Región de Cloud Run, por ejemplo `us-central1`. Es opcional; el fallback no sensible es `us-central1`. |
| `GCP_SA_KEY` | JSON de la cuenta de servicio utilizada por GitHub Actions. |
| `SECRET_KEY_BASE` | Clave Rails de 128 caracteres. |
| `DATABASE_URL` | URL Pooler de ejecución, normalmente puerto `6543`. |
| `MIGRATION_DATABASE_URL` | URL directa/Session Pooler, puerto `5432`. |

El workflow [`.github/workflows/deploy_backend.yml`](../.github/workflows/deploy_backend.yml) se activa con cambios en `backend/**` o en el propio workflow sobre `main`, o manualmente mediante `workflow_dispatch`. El orden es:

1. Levantar PostgreSQL 16 y ejecutar toda la suite Rails.
2. Construir y publicar la imagen únicamente si las pruebas pasan.
3. Actualizar y ejecutar el Job `flews-backend-migrate` con `bin/rails db:migrate`.
4. Desplegar la nueva revisión del servicio solo si la migración termina correctamente.
5. Consultar `/up`; cualquier respuesta no exitosa marca el workflow como fallido.

Las migraciones no se ejecutan desde `docker-entrypoint`, evitando carreras cuando Cloud Run inicia varias instancias.

---

### 💻 Opción B: Despliegue mediante Google Cloud Shell / CLI (`gcloud`)

Si prefieres usar la terminal o Google Cloud Shell:

```bash
# 1. Iniciar sesión y fijar tu proyecto de Google Cloud:
gcloud auth login
gcloud config set project [TU_PROJECT_ID_GCP]

# 2. Habilitar las APIs requeridas:
gcloud services enable run.googleapis.com cloudbuild.googleapis.com artifactregistry.googleapis.com

# 3. Compilar y desplegar directamente desde la carpeta backend:
cd backend

gcloud run deploy flews-backend \
  --source . \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars="RAILS_ENV=production,SECRET_KEY_BASE=[TU_SECRET_KEY_BASE],DATABASE_URL=[TU_SUPABASE_DATABASE_URL],RAILS_SERVE_STATIC_FILES=true,RAILS_LOG_TO_STDOUT=true"
```

---

## 📱 PASO 4: Conectar la App Flutter a Cloud Run

Una vez obtengas tu URL pública de Cloud Run, compila Flutter con `API_URL`. No reemplaces el fallback seguro del archivo de constantes:

📁 [`frontend/lib/core/constants/api_constants.dart`](file:///c:/Users/xhcg2/OneDrive/Escritorio/X/Proyectos_personales/NewsFlow/frontend/lib/core/constants/api_constants.dart):

```bash
flutter build web \
  --dart-define=API_URL=https://flews-backend-xxxxxx-uc.a.run.app/api/v1
```

---

## 🩺 Verificación del Despliegue

Puedes verificar el estado en tiempo real abriendo en el navegador:
* `https://[TU-URL-CLOUD-RUN]/api/v1/health` ➔ `{"status": "ok"}`
* `https://[TU-URL-CLOUD-RUN]/api/v1/posts?filter=news` ➔ Lista de noticias curadas.
