# SchoolBite

Demo comercial funcional para digitalizar sodas escolares.

SchoolBite esta evolucionando hacia un sistema integral para sodas escolares:
pedidos desde app de padres, pedidos en mostrador, control de pagos, produccion
agrupada, entregas por seccion, menu mensual y futura caja/facturacion.

Sprint actual usa datos mock persistentes y arquitectura preparada para Firebase
o Supabase en una fase posterior.

## Proyectos

```text
schoolbite/
  schoolbite_landing/  Landing comercial Flutter Web
  schoolbite_parent/   App Flutter para padres: Web y Android
  schoolbite_admin/    Panel Flutter Web para soda
```

## Demo Sprint 1

- Landing premium con CTA comercial.
- Entrada demo para padre y soda.
- CRUD basico de hijos.
- Menu del dia con precios por ciclo.
- Pedido guarda el precio final calculado al crearse.
- Pedidos, estados y pagos.
- Dashboard con KPIs y tabla de pedidos.
- CRUD basico de menu por fecha.
- Restricciones alimenticias por estudiante.
- Pedido en soda para ventas de mostrador.
- Base visual para importacion de menu mensual desde Excel.
- Repositorios mock con interfaces preparadas para Firebase.

## Sincronizacion demo

Sprint 1 usa `shared_preferences` como repositorio mock persistente. En Web esto equivale a almacenamiento local del navegador. Para una presentacion en internet con parent y admin en dominios separados, la sincronizacion real debe pasar a Firebase Firestore o Supabase en Sprint 2.

Importante: en local y en despliegues separados, cada app tiene su propio mock local. El admin trae pedidos mock propios y permite cambiar estados para demostrar el flujo administrativo. Para una demo real padre -> soda en tiempo real se requiere Sprint 2 con Firebase o Supabase.

La notificacion visual "Nuevo pedido recibido" del admin es simulada con datos
locales. La notificacion real entre Parent y Admin requiere Firebase/Supabase.

El contrato de datos ya incluye `sodaId`, `parentId`, `childId`, `dailyMenuId`, estados de pedido y estados de pago para migrar a backend sin redisenar la UI.

## Preview de Codex

La demo compila y corre como Flutter Web normal. En el Preview de Codex puede quedar cache local de builds o datos anteriores si el servidor estatico no se reinicia o si el navegador conserva `shared_preferences`. Para una presentacion limpia:

```bash
flutter build web --release
```

Luego servir nuevamente cada carpeta `build/web` o refrescar el navegador con cache limpia. El admin usa la llave mock `schoolbite.orders.v2` para evitar cargar datos personales de pruebas anteriores.

## Configuracion comercial en landing

La landing usa `CommercialConfig` en
`schoolbite_landing/lib/config/commercial_config.dart`.

Valores locales por defecto:

- Padre: `http://127.0.0.1:8102`
- Soda: `http://127.0.0.1:8103`

Para Vercel se pueden cambiar al compilar con `--dart-define`:

```bash
flutter build web --release \
  --dart-define=PARENT_DEMO_URL=https://schoolbite-parent.vercel.app \
  --dart-define=ADMIN_DEMO_URL=https://schoolbite-admin.vercel.app
```

## Correr localmente

Desde cada proyecto:

```bash
flutter pub get
flutter run -d chrome
```

## Build web

```bash
flutter build web --release
```

## APK Android

La app padre puede compilar APK:

```bash
cd schoolbite_parent
flutter pub get
flutter build apk --release
```

## Deploy en Vercel

El repositorio es un monorepo. Crear tres proyectos Vercel desde:

```text
https://github.com/ChacBolayCR/SchoolBite
```

Orden recomendado de despliegue:

1. SchoolBite Parent
2. SchoolBite Admin
3. SchoolBite Landing

Configuracion por proyecto:

| Proyecto Vercel | Root Directory | Build Command | Output Directory |
| --- | --- | --- | --- |
| SchoolBite Parent | `schoolbite_parent` | `bash vercel_build.sh` | `build/web` |
| SchoolBite Admin | `schoolbite_admin` | `bash vercel_build.sh` | `build/web` |
| SchoolBite Landing | `schoolbite_landing` | `bash vercel_build.sh` | `build/web` |

Cada carpeta incluye su propio `vercel.json` con rewrite a `index.html` para
rutas Flutter Web.

Los scripts descargan Flutter `3.32.7` en cache de Vercel y ejecutan:

```bash
flutter config --enable-web
flutter pub get
flutter build web --release
```

Variables de entorno requeridas en SchoolBite Landing:

```text
PARENT_DEMO_URL=https://schoolbite-parent.vercel.app
ADMIN_DEMO_URL=https://schoolbite-admin.vercel.app
```

Variables comerciales opcionales:

- `CONTACT_EMAIL`
- `WHATSAPP_URL`
- `MONTHLY_PRICE`

## Sprint 2 sugerido

- `FirebaseOrderRepository`
- `FirebaseMenuRepository`
- `FirebaseChildRepository`
- Autenticacion demo por escuela/soda.
- Realtime listener para que padre y soda sincronicen entre dominios.
- Roles `parent` y `sodaAdmin`.
- Importador real de Excel mensual.
- Caja, facturacion e integraciones de pago en fases posteriores.
