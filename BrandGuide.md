# SchoolBite Brand Guide

Sprint RC2 congela el branding oficial de SchoolBite antes del despliegue en
Vercel. Osi y Ra son las unicas mascotas oficiales del producto.

## Assets Oficiales

Los archivos oficiales son:

```text
logo_schoolbite.png
osi.png
ra.png
osi_delivery.png
ra_cooking.png
osi_thumb.png
ra_thumb.png
```

No se deben reinterpretar, recrear con IA, recolorear ni cambiar expresiones.
Todas las referencias de UI deben pasar por `BrandAssets`.

## Personalidad de Osi

Osi es un pastor aleman sable con uniforme verde SchoolBite y gorra verde con
huella. Representa pedidos, entregas y acompanamiento a las familias.

- Alegre, servicial y cercano.
- Transmite rapidez, orden y confianza.
- Puede aparecer en pedidos, entregas, confirmaciones y estados positivos.
- Frases sugeridas: "Tu pedido esta en buenas patas", "Todo listo" y "Gracias
  por usar SchoolBite".

## Personalidad de Ra

Ra es un gato blanco con uniforme de chef. Sus ojos siempre deben mantener
heterocromia: ojo izquierdo azul y ojo derecho amarillo. Representa cocina,
preparacion y cuidado en los alimentos.

- Tranquilo, amable y cuidadoso.
- Transmite calidad, calma y cocina organizada.
- Puede aparecer en produccion, cocina, menus y validaciones SINPE.
- Frases sugeridas: "Cocinamos con amor para ti", "Hoy cocinaremos algo
  delicioso" y "La soda lo validara en pocos minutos".

## Colores oficiales

- Verde SchoolBite: `#166534`
- Verde accion: `#10B981`
- Verde oscuro texto: `#052E2B`
- Naranja SchoolBite: `#F97316`
- Amarillo calido: `#FACC15`
- Fondo calido: `#FFFDF8`
- Azul oscuro soporte: `#082F49`
- Texto secundario: `#64748B`
- Error/alerta: `#DC2626`

## Tipografia utilizada

Las apps Flutter usan la tipografia del sistema con Material 3.

- Titulos: peso 800-900, alto contraste.
- Texto operativo: peso 600-700 cuando requiere escaneo rapido.
- Texto secundario: color `#64748B` y tamanos moderados.

## Reglas de uso

- No usar personajes alternativos.
- No usar iconos temporales como sustitutos de Osi, Ra o el logo.
- Osi siempre es el encargado de pedidos y entregas.
- Ra siempre es el encargado de cocina.
- Ra siempre debe mantener ojo izquierdo azul y ojo derecho amarillo.
- No deformar, estirar, recortar agresivamente ni recolorear las ilustraciones.
- No usar posters antiguos ni composiciones temporales como iconos.
- Usar `osi_thumb.png` y `ra_thumb.png` para tamanos pequenos.
- Usar `osi_delivery.png` para confirmaciones de pedido o entrega.
- Usar `ra_cooking.png` para cocina, SINPE y mensajes de validacion.
- Usar `logo_schoolbite.png` para favicon, PWA, manifest, app icon y marca.

## Organizacion

Cada proyecto mantiene su propia carpeta:

```text
assets/branding/
  logo_schoolbite.png
  osi.png
  ra.png
  osi_delivery.png
  ra_cooking.png
  osi_thumb.png
  ra_thumb.png
```

El punto unico de referencia es:

```text
lib/branding/brand_assets.dart
```
