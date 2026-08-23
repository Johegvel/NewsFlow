# Frontend Flews: implementación basada en Figma

## Alcance implementado

El frontend Flutter sigue el archivo de Figma `Ln3TFM45If429lEN0qPeSv` y cubre:

- Splash (`2:8`).
- Inicio de sesión y registro (`2:26`).
- Noticias curadas (`2:62`).
- Tribuna de críticas (`2:137`).
- Detalle de publicación (`2:205`).
- Creación de crítica (`2:380`).
- Publicaciones guardadas (`2:419`).
- Perfil (`2:488`).
- Avisos flotantes (`2:562`).
- Configuración de cuenta, preferencias de notificaciones y transparencia editorial.

## Interacciones y perfil

- Guardar y marcar como relevante son acciones reversibles: el botón conserva su estado y un segundo toque elimina la interacción.
- El listado de guardados recibe la publicación completa, incluido su estado para el usuario autenticado.
- Una noticia se cuenta como leída al abrir su detalle y solo suma una vez por usuario.
- El perfil consulta estadísticas persistentes de lecturas, críticas y guardados.
- Las preferencias de privacidad, personalización y notificaciones se guardan en la cuenta.

La implementación conserva Clean Architecture: el tema, los formateadores y los widgets compartidos están en `lib/core/`; las pantallas permanecen dentro de `lib/presentation/screens/`.

## Sistema visual

- Fondo: `#0B0E14`.
- Superficie editorial: `#131823` (valor del archivo de Figma y del tema existente).
- Bordes: `#1E2638`.
- Acento: `#FFB800`.
- Texto secundario: `#94A3B8`.
- Interfaz: Geist, incluida como recurso local.
- Titulares: Instrument Serif, incluida como recurso local.

## Ejecutar el frontend

Producción (usa el fallback seguro de `ApiConstants`):

```bash
cd frontend
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8080
```

Backend local:

```bash
cd backend
brew services start postgresql@18
mise exec ruby@3.4.10 -- bin/rails db:prepare db:seed
mise exec ruby@3.4.10 -- bin/rails server -b 127.0.0.1 -p 3000
```

En una segunda terminal:

```bash
cd frontend
flutter run -d web-server \
  --web-hostname 127.0.0.1 \
  --web-port 8080 \
  --dart-define=API_URL=http://127.0.0.1:3000/api/v1
```

Si el backend local fue preparado con los datos de `backend/db/seeds/demo_data.rb`, se pueden mostrar los accesos rápidos con:

```bash
--dart-define=ENABLE_DEMO_LOGIN=true
```

Este modo usa las cuentas `demo1@flews.app` y `demo2@flews.app`, con la contraseña definida por `FLEWS_DEMO_PASSWORD` (fallback local: `FlewsDemo2026!`). No debe activarse en un build público si esas cuentas no fueron creadas de forma deliberada.

## Verificación

```bash
cd frontend
flutter analyze --no-pub
flutter test --no-pub
```

Las pruebas incluyen autenticación/JWT, persistencia de sesión, parsing editorial, navegación inferior y validación de desbordamientos a `390x844`.

Después de incorporar nuevas migraciones del repositorio, ejecutar siempre `bin/rails db:migrate` antes de iniciar el backend.
