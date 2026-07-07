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

## URLs de demo

Los botones "Probar como padre" y "Probar como soda" leen sus URLs desde:

```text
lib/config/demo_links_config.dart
```

Valores locales:

- `parentDemoUrl`: `http://127.0.0.1:8102`
- `adminDemoUrl`: `http://127.0.0.1:8103`

Para cambiar a Vercel sin tocar widgets:

```bash
flutter build web --release \
  --dart-define=SCHOOLBITE_PARENT_DEMO_URL=https://schoolbite-parent.vercel.app \
  --dart-define=SCHOOLBITE_ADMIN_DEMO_URL=https://schoolbite-admin.vercel.app
```

## Vercel

Build command:

```bash
flutter build web --release --dart-define=SCHOOLBITE_PARENT_DEMO_URL=https://schoolbite-parent.vercel.app --dart-define=SCHOOLBITE_ADMIN_DEMO_URL=https://schoolbite-admin.vercel.app
```

Output directory:

```bash
build/web
```
