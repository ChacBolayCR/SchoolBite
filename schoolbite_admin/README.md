# SchoolBite Admin

Panel demo Flutter Web para la soda escolar.

## Incluye

- Entrada demo como soda.
- Dos modos: Administrador y Operacion.
- Dashboard ejecutivo con KPIs, ventanas de pedido y actividad reciente.
- Vista Pedidos con cards responsivas, filtros y acciones administrativas.
- Vista Produccion con cantidades agrupadas por tipo, opcion y ciclo.
- Vista Entregas para cobrar, validar pago y marcar entregas por estudiante y seccion.
- Vista Pagos para confirmar pendientes, validar SINPE demo y controlar reembolsos.
- CRUD basico de menu con precios por ciclo, disponibilidad y stock.
- Pedido en soda para ventas directas de mostrador.
- Base visual para importar menu mensual desde Excel `.xlsx`.
- Restricciones alimenticias visibles en Produccion, Entregas y Pedidos.

## Datos mock

Sprint 1 usa `shared_preferences`. En local y en despliegues separados, cada app conserva su propio mock local. El panel admin trae pedidos demo propios para simular pedidos entrantes y demostrar cambios de estado, pagos, KPIs y pendientes.

El panel usa `schoolbite.orders.v4` y una base de pedidos ficticia con 40 pedidos. Si el Preview de Codex muestra datos anteriores, recargar con cache limpia o reiniciar el servidor estatico despues de `flutter build web --release`.

La notificacion "Nuevo pedido recibido" es una simulacion visual basada en los
pedidos locales recientes. La notificacion real entre la app de padres y admin
requiere Firebase/Supabase en la siguiente fase.

## Nota sobre Preview de Codex

El Preview de Codex puede conservar `shared_preferences`/local storage de builds anteriores o abrirse con menos ancho que una ventana normal de navegador. En ese caso la vista Pedidos cambia automaticamente de tabla horizontal a tarjetas responsivas para evitar traslapes. Para una demo comercial, abrir Flutter Web en una ventana de escritorio amplia muestra la tabla completa con acciones visibles; si se ven datos viejos, limpiar almacenamiento del sitio o usar una ventana/incognito.

## Flujo operativo

- Administrador ve Dashboard, Produccion, Entregas, Pagos, Menu y Acerca de.
- Operacion ve solo Produccion, Entregas y Pagos.
- Padres pueden pedir desayuno hasta las 8:00 AM.
- Padres pueden pedir almuerzo hasta las 10:30 AM.
- Merienda queda como ventana configurable.
- La soda trabaja por cantidades agrupadas, no pedido por pedido.
- Produccion muestra totales por opcion y ciclo.
- Entregas muestra estudiantes por seccion y permite resolver pago sin cambiar de pantalla.
- Pagos se controla por separado.
- Observaciones y etiquetas permiten pedidos personalizados.
- Restricciones alimenticias quedan visibles para preparacion y entrega.
- Pedido en soda entra al mismo flujo: Produccion, Entregas, Pagos y Dashboard.
- Si se cancela un pedido pendiente, el pago queda cancelado.
- Si se cancela un pedido pagado, queda como reembolso pendiente.

## Controles de pedidos

En escritorio cada fila muestra controles visibles para:

- Estado de entrega: Pendiente, Entregado, Cancelado.
- Estado del pago: Pendiente, En validacion, Pagado, Cancelado.
- Reembolso pendiente: aparece cuando se cancela un pedido ya pagado.
- Metodo de pago: Efectivo, SINPE Movil, Tarjeta, Saldo o No definido.

Los cambios actualizan el repositorio mock, las cards y los KPIs del dashboard.
Los pagos pagados quedan bloqueados visualmente con chip de metodo y estado confirmado; no se muestra un selector generico de pago.

## Secciones del panel

- Dashboard: resumen ejecutivo para venta y operacion diaria.
- Pedidos: gestion administrativa de pedidos, entregas y cobro.
- Produccion: hoja visual de cantidades por opcion/ciclo y personalizados.
- Entregas: entrega por aula/seccion con badge de personalizados y acciones de pago.
- Pagos: control de pendientes, validaciones y reembolsos.
- Menu: CRUD demo de opciones del dia e importacion mensual mock desde Excel.
- Acerca de: version demo, desarrollador, licencia y contacto.

Formato futuro del Excel mensual:

```text
Fecha | Tipo comida | Opcion | Nombre plato | Descripcion | Precio Preescolar | Precio I Ciclo | Precio II Ciclo | Personalizaciones permitidas
2026-07-08 | Desayuno | Opcion 1 | Pinto con huevo | Pinto, huevo y fruta | 1500 | 1800 | 2000 | Sin queso; Sin natilla; Sin salchicha
```

En esta demo no se implementa parser real; la UI deja validacion mock y el punto
de entrada listo para conectar lectura `.xlsx`.

Los pagos son simulados para demo comercial. La integracion real con SINPE, tarjeta o saldo se implementara en fases posteriores.

## Rutas

- `/`
- `/dashboard`
- `/orders`
- `/production`
- `/deliveries`
- `/payments`
- `/menu`
- `/settings`

## Correr

```bash
flutter pub get
flutter run -d chrome
```

## Build web

```bash
flutter build web --release
```

## Vercel

Build command:

```bash
flutter build web --release
```

Output directory:

```bash
build/web
```
