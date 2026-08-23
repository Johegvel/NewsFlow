# Informe consolidado de cambios — Flews / NewsFlow

## 1. Identificación

| Campo | Valor |
| --- | --- |
| Proyecto | Flews / NewsFlow |
| Fecha del informe | 23 de agosto de 2026 |
| Rama local | `main` |
| Commit base | `d1aeb7b94478b6e3462059b698e820c759579424` (`Deploy`) |
| Commit de implementación | `149b541b5c2ec09fcf3b2e1fa71393af1d03552c` |
| Mensaje | `feat: complete Flews app and secure deployment` |
| Alcance del commit | 83 archivos; 5.403 líneas añadidas y 2.139 eliminadas |
| Estado remoto | Commit local creado; sin `push` ni despliegue |

Este documento resume el trabajo realizado para actualizar el backend Rails, completar el frontend Flutter conforme al diseño de Flews, corregir interacciones, añadir datos de demostración y preparar un pipeline de despliegue seguro.

## 2. Reglas técnicas respetadas

Antes de modificar el proyecto se revisó `precaucion/Consideraciones.md`. Las decisiones adoptadas mantienen:

- Clean Architecture en Flutter mediante las capas `core`, `domain`, `data` y `presentation`.
- El fallback de producción de `ApiConstants`, sin fijar permanentemente una URL local.
- Los permisos Android de red requeridos para compilaciones release.
- Los tests Rails dentro de `backend/test`, fuera de `app/models`.
- La configuración de producción con `prepared_statements: false` y `sslmode: require` para Supabase.
- Las gemas `rss` y `rexml` necesarias en Ruby 3.4.
- El arranque de Puma como comando principal del contenedor.

## 3. Backend Rails

### 3.1. Autenticación y sesión

- Se consolidó la autenticación con contraseña mediante `has_secure_password`.
- `POST /api/v1/auth/login` valida correo y contraseña y devuelve un JWT junto al usuario.
- `POST /api/v1/auth/register` normaliza el correo, valida campos y contraseña mínima, evita duplicados y devuelve una sesión completa.
- `GET /api/v1/auth/me` valida la sesión Bearer vigente.
- Se centralizó la lectura del token y el usuario autenticado en `ApplicationController`.
- Los endpoints protegidos dejaron de confiar en un `user_id` enviado por el cliente y operan con `current_user`.
- Los intereses del usuario se consultan y actualizan exclusivamente para la sesión autenticada.

Archivos principales:

- `backend/app/controllers/api/v1/auth_controller.rb`
- `backend/app/controllers/application_controller.rb`
- `backend/app/controllers/api/v1/user_interests_controller.rb`
- `backend/app/models/user.rb`

### 3.2. Publicaciones y permisos editoriales

- El feed soporta filtros separados para noticias y críticas.
- Las respuestas de publicaciones incluyen usuario, comunidad, fecha, conteos y estado de interacción del lector.
- Los usuarios regulares solo pueden crear publicaciones de tipo `critique`.
- La creación de noticias oficiales permanece reservada al motor curador.
- Se añadieron `viewer_reaction_id` y `viewer_saved_post_id` para que Flutter pueda representar y revertir interacciones.
- Los conteos de comentarios y reacciones se calculan en consultas agrupadas para evitar consultas repetidas por cada publicación.

### 3.3. Guardados

Se corrigió el error `FormatException: null` que aparecía en Publicaciones Guardadas.

La causa era un contrato inconsistente: Rails devolvía únicamente los campos de `saved_posts`, mientras Flutter esperaba una publicación anidada completa.

Cambios aplicados:

- `GET /api/v1/users/:user_id/saved_posts` y `GET /api/v1/me/saved_posts` devuelven el objeto `post` completo.
- La respuesta contiene `id`, `user_id`, `post_id`, `created_at` y la publicación serializada.
- Crear un guardado es idempotente: una repetición devuelve el registro existente sin duplicarlo.
- `DELETE /api/v1/saved_posts/:id` elimina únicamente un guardado perteneciente al usuario autenticado.
- El post anidado conserva `viewer_saved_post_id`, permitiendo mostrar el marcador activo.

### 3.4. Reacciones

- Crear una reacción devuelve su identificador y es idempotente por usuario y publicación.
- `DELETE /api/v1/reactions/:id` permite retirar la reacción.
- El backend impide que un usuario elimine reacciones ajenas.
- Las respuestas del feed incluyen el identificador de la reacción actual y el conteo total.

### 3.5. Noticias leídas y estadísticas

Se incorporó seguimiento persistente de lectura mediante la tabla `post_reads`.

- Cada combinación `user_id + post_id` es única.
- `POST /api/v1/posts/:post_id/post_reads` registra una lectura una sola vez.
- El registro respeta la preferencia `reading_history_enabled`.
- `GET /api/v1/me/profile` devuelve:
  - noticias leídas;
  - críticas publicadas;
  - publicaciones guardadas.
- `DELETE /api/v1/me/read_history` elimina únicamente el historial del usuario autenticado.

### 3.6. Preferencias de usuario

Se añadió la tabla `user_preferences`, con un registro único por usuario y estos campos:

- `reading_history_enabled`;
- `personalization_enabled`;
- `morning_digest_enabled`;
- `curation_alerts_enabled`.

Endpoints incorporados:

- `GET /api/v1/me/preferences`;
- `PATCH /api/v1/me/preferences`.

Si el usuario todavía no tiene preferencias, el backend crea automáticamente un registro con valores seguros por defecto.

### 3.7. Migración y esquema

Se añadió:

- `backend/db/migrate/20260823143000_create_post_reads_and_user_preferences.rb`;
- modelos `PostRead` y `UserPreference`;
- asociaciones con `User` y `Post`;
- índices únicos y claves foráneas;
- actualización de `backend/db/schema.rb`;
- actualización equivalente de `backend/db/supabase_schema.sql`.

La migración fue ejecutada correctamente en las bases locales de desarrollo y pruebas.

### 3.8. Datos de demostración

Las semillas fueron reorganizadas para ser idempotentes y seguras:

- Se mantienen siete comunidades y siete intereses.
- El usuario curador se crea con una contraseña aleatoria si no existe una configurada.
- Los datos demo se separaron en `backend/db/seeds/demo_data.rb`.
- Desarrollo y pruebas cargan automáticamente los datos demo.
- Producción no carga usuarios ni contenido demo salvo que `LOAD_DEMO_DATA=true` sea definido deliberadamente.
- Se incluyen dos usuarios demo, siete noticias, tres críticas, comentarios, reacciones, guardados e intereses.
- Ejecutar `db:seed` varias veces no genera duplicados.

Credenciales exclusivamente locales:

- `demo1@flews.app`;
- `demo2@flews.app`;
- contraseña por defecto: `FlewsDemo2026!`, reemplazable con `FLEWS_DEMO_PASSWORD`.

### 3.9. Ingesta y scraping

El motor de ingesta fue reforzado para operar de manera más predecible:

- Adaptadores para Hacker News y feeds RSS/Atom.
- Fuentes configuradas para tecnología, ciencia, salud, gastronomía, deportes, ciberseguridad y negocios.
- Límite de cuatro noticias por fuente y doce por comunidad en cada ejecución.
- Umbrales de puntos, comentarios y antigüedad en Hacker News.
- Detección de duplicados por título normalizado y enlace canónico.
- Bot curador creado con contraseña aleatoria segura.
- Cliente HTTP con `open_timeout`, `read_timeout`, User-Agent y hasta tres redirecciones.
- Manejo de respuestas HTTP no exitosas sin detener toda la ingesta.
- Resumen final de publicaciones creadas por comunidad.
- Tarea disponible: `bin/rails news:fetch_trending`.

## 4. Frontend Flutter

### 4.1. Sistema visual basado en Figma

Se completaron las pantallas principales siguiendo el archivo Figma de Flews:

- splash;
- inicio de sesión y registro;
- feed de noticias;
- tribuna de críticas;
- detalle de publicación;
- creación de crítica;
- publicaciones guardadas;
- perfil;
- avisos flotantes;
- configuración de cuenta;
- preferencias de notificaciones;
- transparencia editorial.

Sistema visual aplicado:

- fondo `#0B0E14`;
- superficie `#131823`;
- bordes `#1E2638`;
- acento ámbar `#FFB800`;
- fuente de interfaz Geist;
- fuente editorial Instrument Serif.

Los archivos de las fuentes se añadieron localmente en `frontend/assets/fonts/` y se registraron en `pubspec.yaml`.

### 4.2. Componentes compartidos

Se añadieron o actualizaron:

- `FlewsBottomNavigation`;
- `FlewsSectionSwitcher`;
- `FlewsEmptyState`;
- `FlewsNotificationHelper`;
- tema global `AppTheme`;
- formateadores editoriales y de fechas;
- utilidades para insignias de comunidad e iniciales.

Se corrigió un error donde la navegación inferior se expandía verticalmente, ocupaba el `Scaffold` y ocultaba el feed. La barra ahora conserva una altura de 66 píxeles y se mantiene al final de la pantalla.

### 4.3. Sesión local

- Flutter guarda JWT y usuario como una sesión completa en `SharedPreferences`.
- El splash restaura la sesión antes de decidir entre Auth y Home.
- Se elimina el formato de sesión legado al guardar o cerrar sesión.
- Cerrar sesión borra tanto el usuario como el token.
- El modo de acceso demo depende de `ENABLE_DEMO_LOGIN=true` y no se activa por defecto en producción.

### 4.4. Contrato API y Clean Architecture

Se ampliaron las capas `domain`, `data` y `presentation` sin introducir dependencias de UI en el dominio.

Nuevos elementos principales:

- `AuthSessionModel`;
- `ProfileStatsEntity` y `ProfileStatsModel`;
- `UserPreferencesEntity` y `UserPreferencesModel`;
- `ProfileRepository` y `ProfileRepositoryImpl`;
- nuevos métodos remotos para perfil, preferencias, lectura, reacciones y guardados.

Las consultas de publicaciones autenticadas envían el token Bearer para recibir el estado del lector.

### 4.5. Guardar y dejar de guardar

- El botón de marcador consulta el estado real recibido desde Rails.
- Cuando una noticia está guardada, usa icono lleno, borde y color ámbar.
- Un segundo toque elimina el guardado.
- La pantalla de Guardados se actualiza al regresar del detalle.
- Flutter valida que la API incluya la publicación completa y muestra un error útil si el contrato vuelve a romperse.

### 4.6. Me gusta / Relevante

- El botón conserva su estado activo.
- Un segundo toque elimina la reacción.
- El icono cambia entre contorno y relleno.
- El conteo se actualiza inmediatamente después de la respuesta del servidor.
- La publicación se vuelve a consultar al abrir el detalle para sincronizar el estado vigente.

### 4.7. Lecturas y perfil

- Abrir el detalle de una noticia registra la lectura sin bloquear la visualización.
- Las críticas no incrementan el contador de noticias leídas.
- Una noticia solo suma una vez por usuario.
- El perfil consume estadísticas persistentes del backend.
- Los contadores muestran lecturas, críticas y guardados reales.

### 4.8. Configuración

La sección se adaptó a la referencia visual entregada y ahora ofrece navegación funcional:

1. **Configuración de Cuenta**
   - activar o desactivar historial de lectura;
   - activar o desactivar personalización;
   - borrar el historial con confirmación.
2. **Preferencias de Notificaciones**
   - síntesis matutina;
   - alertas de curación.
3. **Transparencia Editorial**
   - fuentes identificables;
   - neutralidad y contexto;
   - criterios de curación;
   - correcciones y reportes.

El Panel de Moderación permanece disponible en una sección separada de herramientas editoriales.

Las preferencias de notificación se almacenan en la cuenta. El envío efectivo de notificaciones push requiere integrar posteriormente un proveedor móvil y solicitar permisos al dispositivo.

### 4.9. Correcciones responsive

- Se validaron las vistas a `390 × 844`.
- Se corrigieron desbordamientos en tarjetas de críticas y encabezado del perfil.
- Las filas de configuración usan superficies `Material` para mostrar correctamente las respuestas táctiles.
- La navegación inferior ya no ocupa el contenido principal.
- Las vistas principales utilizan `ResponsiveContainer` para escritorio y web.

## 5. Pruebas y evidencia

### 5.1. Backend

Resultado final:

```text
18 tests
80 assertions
0 failures
0 errors
0 skips
```

Cobertura añadida:

- autenticación y JWT;
- autorización de `auth/me`;
- restricción de publicación a críticas;
- creación de críticas autenticadas;
- guardados con publicación completa;
- idempotencia y eliminación de guardados y reacciones;
- lectura única;
- preferencias persistentes;
- borrado del historial;
- semillas completas e idempotentes;
- ingesta y deduplicación;
- parsing de RSS.

### 5.2. Frontend

Resultado final:

```text
flutter analyze --no-pub: sin problemas
12 tests: aprobados
```

Cobertura añadida:

- persistencia/restauración de sesión;
- parsing de metadatos editoriales y críticas;
- contrato de autenticación Rails;
- envío de JWT en peticiones protegidas;
- parsing del estado de guardados y reacciones;
- detección de respuestas incompletas;
- login y registro en viewport móvil;
- navegación inferior y altura correcta;
- tarjetas sin overflow;
- presencia de las tres opciones funcionales de configuración.

### 5.3. Prueba HTTP local

Con backend y frontend locales se verificó:

- login demo: `200`;
- `GET /api/v1/me/profile`: `200`;
- `GET /api/v1/me/preferences`: `200`;
- guardados autenticados: `200`;
- feed de noticias: `200`;
- guardados con publicaciones completas: verdadero;
- estado `viewer_saved_post_id` coherente con el registro: verdadero.

## 6. Pipeline de despliegue

### 6.1. Copia preventiva

Antes de modificar el workflow se creó una copia privada fuera del repositorio:

```text
/Users/johanvelozruilova/Documents/deploy_backend_backup_2026-08-23_before-security.yml
```

- checksum SHA-256 verificado contra el original;
- permisos `600`;
- no forma parte del commit.

### 6.2. Seguridad aplicada

El workflow anterior contenía valores sensibles de fallback. El nuevo `.github/workflows/deploy_backend.yml`:

- no contiene credenciales de producción;
- exige secretos de GitHub Actions;
- valida que estén definidos antes de construir;
- escribe variables en archivos temporales privados del runner;
- evita imprimir los valores;
- limita permisos del workflow a lectura del repositorio;
- usa el entorno `production`;
- evita despliegues simultáneos mediante `concurrency`.

La credencial de Supabase que estuvo versionada debe considerarse comprometida y cambiarse antes del próximo push a `main`.

### 6.3. Flujo automatizado nuevo

1. Checkout.
2. PostgreSQL 16 temporal.
3. Ruby 3.4.10 y caché de Bundler.
4. `bin/rails db:prepare`.
5. Suite Rails completa.
6. Cloud Build y publicación de la imagen.
7. Configuración de `flews-backend-migrate`.
8. Ejecución de `rails db:migrate` mediante Cloud Run Job.
9. Despliegue del servicio únicamente si la migración termina correctamente.
10. Smoke test contra `/up` con reintentos.

Las migraciones no se ejecutan al iniciar cada contenedor; esto evita carreras cuando Cloud Run crea varias instancias.

Cloud Build se envía con `--async` y el workflow consulta su estado mediante
`gcloud builds describe`. Esto evita un falso fallo del CLI cuando la cuenta de servicio
puede crear y consultar builds, pero no leer el bucket predeterminado de logs. El polling
tiene un límite de 20 minutos y no amplía permisos.

El pipeline comprueba que la cuenta de servicio de despliegue pueda leer la imagen antes
de crear el Job de migración, pero no modifica IAM. El administrador de Google Cloud debe
conceder manualmente `roles/artifactregistry.reader`, limitado al repositorio `gcr.io`.
Este permiso permite resolver y descargar la imagen, sin conceder escritura sobre
artefactos ni administración del proyecto.

### 6.4. Credenciales y despliegue transitorio

Para permitir el primer despliegue sin volver a guardar credenciales en GitHub, el
workflow reutiliza temporalmente la configuración privada del servicio Cloud Run que ya
está desplegado:

1. se autentica exclusivamente con `GCP_SA_KEY`;
2. deriva el proyecto desde la cuenta de servicio;
3. consulta el entorno vigente de `flews-backend` sin imprimirlo;
4. genera archivos privados dentro de `RUNNER_TEMP` para la migración y el servicio;
5. elimina esos archivos aunque el job falle.

Este mecanismo requiere que el servicio actual contenga `SECRET_KEY_BASE` y
`DATABASE_URL` como valores de entorno. Hasta disponer de una conexión de migración
dedicada, la misma `DATABASE_URL` se utiliza para el Job de Cloud Run.

### 6.5. Secretos definitivos recomendados

| Nombre | Estado conocido |
| --- | --- |
| `GCP_SA_KEY` | Configurado en GitHub Actions |
| `GCP_PROJECT_ID` | Pendiente; el modo transitorio lo deriva de `GCP_SA_KEY` |
| `GCP_REGION` | Pendiente; existe fallback no sensible `us-central1` |
| `SECRET_KEY_BASE` | Pendiente; actualmente se recupera desde Cloud Run y debe rotarse |
| `DATABASE_URL` | Pendiente; actualmente se recupera desde Cloud Run |
| `MIGRATION_DATABASE_URL` | Pendiente; conexión directa o Session Pooler, puerto `5432` |

No se deben copiar valores reales en archivos del repositorio ni en este informe.

## 7. Ejecución local

### Backend

```bash
cd backend
brew services start postgresql@18
mise exec ruby@3.4.10 -- bin/rails db:prepare db:seed
mise exec ruby@3.4.10 -- bin/rails server -b 127.0.0.1 -p 3000
```

### Frontend web conectado al backend local

```bash
cd frontend
flutter run -d web-server \
  --web-hostname 127.0.0.1 \
  --web-port 8082 \
  --dart-define=API_URL=http://127.0.0.1:3000/api/v1 \
  --dart-define=ENABLE_DEMO_LOGIN=true
```

## 8. Estado al cierre

### Completado

- Backend local funcional.
- Login JWT funcional.
- Scraping/ingesta funcional y probado.
- Datos demo disponibles.
- Frontend implementado y responsive.
- Guardados y reacciones reversibles.
- Lecturas y estadísticas persistentes.
- Configuración funcional.
- Suites automatizadas aprobadas.
- Workflow de despliegue seguro preparado.
- Commit local de implementación creado.

### Pendiente antes del despliegue

1. Identificar al responsable o recuperar acceso administrativo de Supabase.
2. Cambiar la contraseña de la base de datos expuesta anteriormente.
3. Crear `DATABASE_URL` y `MIGRATION_DATABASE_URL` nuevas.
4. Generar un `SECRET_KEY_BASE` nuevo.
5. Configurar los secretos restantes en GitHub Actions.
6. Revisar permisos de la cuenta de servicio para Cloud Build, Cloud Run Service y Cloud Run Jobs.
7. Ejecutar `git push origin main` únicamente cuando los secretos estén listos.
8. Supervisar el workflow, la migración y el smoke test.
9. Definir el canal de distribución del frontend Flutter web/móvil.
10. Integrar un proveedor de notificaciones push si se requiere envío real.

## 9. Consideraciones Git

- El commit funcional es `149b541b5c2ec09fcf3b2e1fa71393af1d03552c`.
- No se realizó push.
- `frontend/android/local.properties` permanece modificado solo en el equipo local y fue excluido del commit por contener rutas específicas del entorno.
- `.mise.toml` fija Ruby `3.4.10` y Flutter `3.47.0` para reproducibilidad.

Para consultar el inventario exacto de los 83 archivos del commit:

```bash
git show --name-status 149b541
```
