# SchoolBite Landing

Landing comercial Flutter Web para vender el piloto de SchoolBite.

## Rutas

- `/`
- `/demo`
- `/pricing`
- `/contact`

## Correr

```bash
flutter pub get
flutter run -d chrome
```

## Build web

```bash
flutter build web --release
```

## Configuracion comercial

Los botones "Probar demo para padres" y "Probar panel de soda" leen sus URLs
desde:

```text
lib/config/commercial_config.dart
```

Valores locales:

- `PARENT_DEMO_URL`: `http://127.0.0.1:8102`
- `ADMIN_DEMO_URL`: `http://127.0.0.1:8103`

Para cambiar a Vercel sin tocar widgets:

```bash
flutter build web --release \
  --dart-define=PARENT_DEMO_URL=https://schoolbite-parent.vercel.app \
  --dart-define=ADMIN_DEMO_URL=https://schoolbite-admin.vercel.app
```

Variables opcionales:

- `CONTACT_EMAIL`
- `WHATSAPP_URL`
- `MONTHLY_PRICE`

## Vercel

Root Directory:

```text
schoolbite_landing
```

Build Command:

```bash
bash vercel_build.sh
```

Output Directory:

```bash
build/web
```

Variables de entorno recomendadas:

```text
PARENT_DEMO_URL=https://schoolbite-parent.vercel.app
ADMIN_DEMO_URL=https://schoolbite-admin.vercel.app
WHATSAPP_URL=https://wa.me/50600000000
CONTACT_EMAIL=hola@schoolbite.app
MONTHLY_PRICE=₡39.900
```

El script usa Flutter `3.32.7`, habilita Web, instala dependencias y pasa
`PARENT_DEMO_URL` / `ADMIN_DEMO_URL` como `--dart-define`.
