# SchoolBite Parent

App demo para padres. Funciona en Flutter Web y Android.

## Incluye

- Entrada demo como Laura Mendez.
- Hijo inicial: Sofia Ramirez Lopez, Prekinder, seccion PK-A.
- CRUD basico de hijos.
- Menu del dia con desayuno, almuerzo y merienda.
- Precio calculado segun ciclo.
- Pedido guarda el precio final al crearse.
- Pedidos activos, historial, estado de entrega y estado de pago.
- Ciclo inferido automaticamente por grado/seccion.
- Restricciones alimenticias / notas importantes por hijo.
- Observaciones con etiquetas rapidas segun el plato seleccionado.
- Flujo visual de pago demo: SINPE, tarjeta o pago en soda.

## Flujo demo

- Desayuno se pide hasta las 8:00 AM.
- Almuerzo se pide hasta las 10:30 AM.
- Merienda queda como ventana configurable.
- Cada pedido permite seleccionar estudiante, tipo de comida, opcion, ver plato real y precio.
- Si el estudiante tiene restricciones alimenticias, se muestra una alerta antes
  de confirmar el pedido y la nota queda guardada en el pedido.
- Observaciones dependen del menu seleccionado. Por ejemplo, pancakes muestra sin miel, sin mantequilla, fruta aparte o sin sirope.
- Siempre se permite Otro con detalle libre de hasta 100 caracteres.
- Los pedidos personalizados se muestran con badge en el historial.
- SINPE deja el pago en validacion.
- Tarjeta simula pago exitoso.
- Pagar en soda deja el pedido pendiente de pago.

## Rutas

- `/`
- `/home`
- `/children`
- `/menu`
- `/orders`
- `/profile`

## Correr

```bash
flutter pub get
flutter run -d chrome
```

## Build web

```bash
flutter build web --release
```

## APK Android

```bash
flutter pub get
flutter build apk --release
```

## Datos mock

Sprint 1 usa `shared_preferences`. En local y en despliegues separados, la app de padres conserva su propio mock local. La sincronizacion real padre -> soda queda para Sprint 2 con Firebase o Supabase.

## Vercel

Build command:

```bash
flutter build web --release
```

Output directory:

```bash
build/web
```
