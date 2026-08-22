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
4. Copia tu cadena de conexión `DATABASE_URL`. Tendrá un formato como este:
   ```text
   postgresql://postgres.[PROJECT_REF]:[TU_CONTRASEÑA]@aws-0-[REGION].pooler.supabase.com:5432/postgres?sslmode=require
   ```

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

Tienes **dos métodos sencillos** para desplegar:

### 🌟 Opción A: Despliegue Automático desde la Consola de Google Cloud (Recomendada)

1. Ingresa a [Google Cloud Console - Cloud Run](https://console.cloud.google.com/run).
2. Haz clic en **"Crear Servicio" (Create Service)**:
   * **Nombre del servicio:** `flews-backend`
   * **Región:** Selecciona la misma región de tu Supabase (ej. `us-central1` o `us-east1`).
   * **Implementación:** Marca *"Implementar continuamente nuevas revisiones desde un repositorio de código fuente"* ➔ Haz clic en **"Configurar Cloud Build"**.
   * Selecciona tu repositorio de GitHub `NewsFlow` y rama `main`.
   * **Tipo de compilación:** Selecciona **Dockerfile** (Ruta del Dockerfile: `/backend/Dockerfile`).
   * **Autenticación:** Marca **"Permitir invocaciones no autenticadas"** (para que la app móvil y web puedan consultar las APIs públicas).
3. En la sección inferior **"Variables de entorno y secretos" (Environment Variables)**, añade las siguientes:

| Variable | Valor |
| :--- | :--- |
| `RAILS_ENV` | `production` |
| `DATABASE_URL` | `postgresql://postgres.[PROJECT_REF]:[PASSWORD]@aws-0-[REGION].pooler.supabase.com:5432/postgres?sslmode=require` |
| `SECRET_KEY_BASE` | `[Tu clave de 128 caracteres generada en el Paso 2]` |
| `RAILS_SERVE_STATIC_FILES` | `true` |
| `RAILS_LOG_TO_STDOUT` | `true` |

4. Haz clic en **"Crear" (Create)**.
5. Cloud Build compilará el Dockerfile, creará las tablas automáticamente mediante `bin/rails db:prepare` (configurado en `docker-entrypoint`) y te otorgará una **URL pública HTTPS**, por ejemplo:
   ```text
   https://flews-backend-xxxxxx-uc.a.run.app
   ```

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

Una vez obtengas tu URL pública de Cloud Run (ej. `https://flews-backend-xxxxxx-uc.a.run.app`), conéctala en la aplicación móvil editando el archivo de constantes:

📁 [`frontend/lib/core/constants/api_constants.dart`](file:///c:/Users/xhcg2/OneDrive/Escritorio/X/Proyectos_personales/NewsFlow/frontend/lib/core/constants/api_constants.dart):

```dart
class ApiConstants {
  // Producción en Google Cloud Run:
  static const String baseUrl = 'https://flews-backend-xxxxxx-uc.a.run.app/api/v1';

  // Endpoints:
  static const String posts = '$baseUrl/posts';
  static const String communities = '$baseUrl/communities';
  static const String auth = '$baseUrl/auth';
  static const String reports = '$baseUrl/reports';
}
```

---

## 🩺 Verificación del Despliegue

Puedes verificar el estado en tiempo real abriendo en el navegador:
* `https://[TU-URL-CLOUD-RUN]/api/v1/health` ➔ `{"status": "ok"}`
* `https://[TU-URL-CLOUD-RUN]/api/v1/posts?filter=news` ➔ Lista de noticias curadas.
