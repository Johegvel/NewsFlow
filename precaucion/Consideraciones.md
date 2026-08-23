# 🛡️ Guía de Precaución y Consideraciones Técnicas de Escalabilidad — Flews (NewsFlow)

Este documento es una **guía crítica de preservación y escalabilidad** para cualquier desarrollador, líder técnico o colaborador que trabaje en el repositorio de **Flews**. Aquí se detallan los componentes intocables que garantizan la estabilidad del sistema y las mejores prácticas para extender la arquitectura sin introducir fallos en producción.

---

## 📌 Tabla de Contenidos
1. [Frontend (Flutter) — Reglas Críticas e Intocables](#1-frontend-flutter--reglas-críticas-e-intocables)
2. [Frontend (Flutter) — Directrices de Escalabilidad](#2-frontend-flutter--directrices-de-escalabilidad)
3. [Backend (Ruby on Rails 8) — Reglas Críticas e Intocables](#3-backend-ruby-on-rails-8--reglas-críticas-e-intocables)
4. [Backend (Ruby on Rails 8) — Directrices de Escalabilidad](#4-backend-ruby-on-rails-8--directrices-de-escalabilidad)
5. [Infraestructura & Nube (Google Cloud Run + Supabase)](#5-infraestructura--nube-google-cloud-run--supabase)
6. [Flujo de Trabajo Git & Colaboración](#6-flujo-de-trabajo-git--colaboración)

---

## 1. Frontend (Flutter) — Reglas Críticas e Intocables

### 🚫 Lo que NUNCA se debe romper o modificar sin precaución:

### 1.1. Arquitectura Modular (Clean Architecture)
* **Estructura de Directorios:** El código está estrictamente organizado en 4 capas dentro de `frontend/lib/`:
  * `core/`: Configuración global, constantes (`api_constants.dart`), tema (`app_theme.dart`) y widgets transversales (`ResponsiveContainer`, `FlewsAppBarTitle`, `FlewsNotificationHelper`).
  * `domain/`: Entidades puras (`entities/`) y contratos abstractos (`repositories/`). **Nunca importar librerías de UI o paquetes de terceros en esta capa**.
  * `data/`: Modelos serializables (`models/`), fuentes de datos (`datasources/`) e implementaciones de repositorios (`repositories_impl/`).
  * `presentation/`: Vistas agrupadas por funcionalidad (`splash/`, `auth/`, `home/`, `post_detail/`, `create_critique/`, `saved_posts/`, `moderation/`).
* ⚠️ **Peligro:** **No volver a crear carpetas planas en la raíz de `lib/`** como `lib/screens/`, `lib/models/` o `lib/services/`. Si se crea un nuevo modelo o servicio, debe respetar la estructura de Clean Architecture.

### 1.2. Permisos de Android para Compilación Release (`AndroidManifest.xml`)
* En `frontend/android/app/src/main/AndroidManifest.xml`, los permisos:
  ```xml
  <uses-permission android:name="android.permission.INTERNET"/>
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
  ```
  **Son obligatorios**. Si se eliminan, el APK en modo release (`flutter build apk --release`) fallará con el error `ClientException with SocketFailed host lookup` al intentar conectar con Cloud Run.

### 1.3. Enlace de la API en Producción (`api_constants.dart`)
* La constante `baseUrl` debe mantener su fallback dinámico:
  ```dart
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://flews-backend-388073050451.us-central1.run.app/api/v1',
  );
  ```
  * ⚠️ **Peligro:** No hardcodear `http://localhost:3000` o `http://10.0.2.2:3000` de forma fija, ya que dejará inservibles los APKs y despliegues web en producción.

### 1.4. Sistema de Diseño Visual (Dark Editorial)
* **Paleta de Colores:** Fondo `#0B0E14`, Superficie `#161B22`, Acentos `#FFB800` (Ámbar), Texto primario `#FFFFFF`, Texto secundario `#8B949E`.
* **Identidad del Logotipo:** El logotipo de Flews debe renderizarse **sin halos brillantes artificiales ni bordes con sombra pesada** (`boxShadow` excesivos) que generen contraste brusco con el fondo oscuro.
* **Contención Web / Responsive:** Todas las pantallas deben envolverse en [`ResponsiveContainer`](file:///c:/Users/xhcg2/OneDrive/Escritorio/X/Proyectos_personales/NewsFlow/frontend/lib/core/widgets/responsive_container.dart) para evitar que las vistas se deformen en pantallas panorámicas de escritorio.

---

## 2. Frontend (Flutter) — Directrices de Escalabilidad

Para agregar nuevas características al cliente móvil/web:

1. **Flujo de Creación de Features (Clean Flow):**
   * Paso 1: Definir la entidad inmutable en `lib/domain/entities/nueva_entidad.dart`.
   * Paso 2: Crear el contrato abstracto en `lib/domain/repositories/nuevo_repository.dart`.
   * Paso 3: Crear el modelo con métodos `fromJson`/`toJson` en `lib/data/models/nuevo_model.dart`.
   * Paso 4: Añadir las llamadas HTTP en `lib/data/datasources/remote_api_datasource.dart`.
   * Paso 5: Implementar el repositorio en `lib/data/repositories_impl/nuevo_repository_impl.dart`.
   * Paso 6: Registrar la dependencia en `lib/service_locator.dart`.
   * Paso 7: Crear la vista en `lib/presentation/screens/nueva_feature/`.
2. **Paginación en Feeds:**
   * Al crecer el volumen de noticias, implementar paginación mediante parámetros `page` y `limit` en `fetchPosts` y controlarla en los `ScrollController` de las vistas.
3. **Manejo de Estado a Futuro:**
   * Si la complejidad de la aplicación aumenta, se recomienda migrar los `StatefulWidget` locales a **BLoC** o **Riverpod**, manteniendo intacta la capa de `domain/` y `data/`.

---

## 3. Backend (Ruby on Rails 8) — Reglas Críticas e Intocables

### 🚫 Lo que NUNCA se debe romper o modificar sin precaución:

### 3.1. Archivos de Test dentro de `app/models/` (Zeitwerk Loader)
* ⚠️ **PELIGRO CRÍTICO:** **Nunca colocar archivos terminados en `_test.rb` dentro de `backend/app/models/`**.
  * En modo producción (`RAILS_ENV=production`), Zeitwerk ejecuta `eager_load_all`. Si encuentra un archivo de prueba en `app/models/`, intentará cargar `test_helper`, el cual no existe en la imagen Docker de producción (`BUNDLE_WITHOUT="development:test"`), provocando el colapso inmediato del contenedor (`LoadError: cannot load such file -- test_helper`).
  * Todos los tests deben residir exclusivamente en `backend/test/`.

### 3.2. Configuración de Conexión a Base de Datos (`database.yml`)
* En `backend/config/database.yml`, el bloque de producción debe conservar estrictamente:
  ```yaml
  production:
    url: <%= ENV["DATABASE_URL"] %>
    prepared_statements: false
    sslmode: require
  ```
  * ⚠️ **Peligro:** `prepared_statements: false` es **estrictamente obligatorio** para Supabase cuando se utiliza el puerto PgBouncer en Transaction Mode (`6543`). Si se activa `prepared_statements: true`, PostgreSQL arrojará errores de prepared statement duplicado.

### 3.3. Configuración de Docker y Cloud Build
* **`.dockerignore`:** **NUNCA agregar `Dockerfile` a `.dockerignore`**. Si el Dockerfile se ignora, Google Cloud Build recurrirá a un Buildpack genérico que fallará al arrancar Rails.
* **`Dockerfile` CMD:** Debe ejecutar Puma directamente mediante:
  ```dockerfile
  CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
  ```
* **Permisos del Contenedor:** La directiva `chmod -R a+rX "${BUNDLE_PATH}" && chown -R rails:rails /rails "${BUNDLE_PATH}"` es vital para que el usuario sin privilegios (`rails:1000`) pueda ejecutar las gemas instaladas por `root`.

### 3.4. Gemas en Ruby 3.4
* Ruby 3.4 eliminó las gemas `rss` y `rexml` de las gemas por defecto del lenguaje. Por tanto, `gem "rss"` y `gem "rexml"` deben permanecer siempre presentes en el `backend/Gemfile` y sincronizadas en `backend/Gemfile.lock` para que el motor de ingesta funcione.

---

## 4. Backend (Ruby on Rails 8) — Directrices de Escalabilidad

1. **Ingesta Inteligente de Noticias ($0 Costo):**
   * El motor de noticias se encuentra en `backend/app/services/news_ingestion/`.
   * Para añadir una nueva fuente de información, basta con heredar de `BaseSource` en `sources/` e implementarla en `IngestionManager`.
   * La ejecución periódica debe realizarse mediante Google Cloud Scheduler invocando un endpoint seguro o ejecutando `rails news:fetch_trending` vía Cloud Tasks / Worker.
2. **Protección del Feed Curado:**
   * Los usuarios regulares no pueden publicar noticias directamente en el feed oficial; este privilegio está reservado para el motor de curaduría (`bot@flews.app`).
   * Los usuarios aportan valor a través de la sección de **Críticas y Análisis** (`post_type: :critique`), donde citan noticias existentes para abrir debates constructivos.
3. **Escalado Horizontal:**
   * La aplicación en Cloud Run es completamente stateless (sin estado local). Al utilizar `memory_store` y conexiones agrupadas con Supabase Pooler, puede escalar de 1 a 50 instancias concurrentes en segundos sin saturar conexiones a la base de datos.

---

## 5. Infraestructura & Nube (Google Cloud Run + Supabase)

### 5.1. Variables de Entorno en Cloud Run
El servicio `flews-backend` en Cloud Run opera con las siguientes variables indispensables:
* `RAILS_ENV`: `production`
* `SECRET_KEY_BASE`: Clave criptográfica de 128 caracteres para sesiones y tokens.
* `DATABASE_URL`: Cadena de conexión al pooler de Supabase con `sslmode=require`.
* `RAILS_SERVE_STATIC_FILES`: `true`
* `RAILS_LOG_TO_STDOUT`: `true`
* `RAILS_MAX_THREADS`: `5` (óptimo para instancias de 512MiB).

### 5.2. Esquema DDL de Supabase (`supabase_schema.sql`)
* Si se reinicia o clona la base de datos, el archivo [`backend/db/supabase_schema.sql`](file:///c:/Users/xhcg2/OneDrive/Escritorio/X/Proyectos_personales/NewsFlow/backend/db/supabase_schema.sql) contiene la estructura completa con 10 tablas, claves foráneas en cascada, índices de alto rendimiento y comunidades iniciales.
* Puede ejecutarse directamente desde el SQL Editor de Supabase o mediante:
  ```bash
  psql "<DATABASE_URL_PORT_5432>" -f backend/db/supabase_schema.sql
  ```

---

## 6. Despliegue Automatizado (CI/CD) & Colaboración

### 6.1. Despliegue Automático al Backend con Commit
* **El backend se despliega automáticamente a Google Cloud Run:**
  Para desplegar cualquier cambio realizado en el backend (`backend/**`), **solo se requiere hacer commit y push a la rama `main`**.
* El flujo de trabajo automatizado de GitHub Actions ([`.github/workflows/deploy_backend.yml`](file:///c:/Users/xhcg2/OneDrive/Escritorio/X/Proyectos_personales/NewsFlow/.github/workflows/deploy_backend.yml)) detecta los cambios en `backend/`, compila la imagen en Google Cloud Build y actualiza el servicio de Google Cloud Run en tiempo real sin requerir comandos manuales en la consola.

### 6.2. Gestión de Commits y Ramas
1. Cada nueva funcionalidad debe desarrollarse en ramas descriptivas (`feature/nombre-feature` o `fix/descripcion-bug`).
2. Antes de fusionar o hacer push a `main`, verificar que `flutter analyze` pase con 0 errores en el frontend.
3. **Archivos Ignorados Sensibles:** Mantener siempre en `.gitignore`: `.env`, `master.key`, `credentials.yml.enc`, `storage/`, `tmp/`, `.dart_tool/`, `android/local.properties`.

---
*Documento redactado para el equipo de desarrollo de Flews. Mantener este archivo actualizado ante cualquier cambio de infraestructura o arquitectura.*
