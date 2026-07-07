# SchoolBite Brand Guide

SchoolBite usa a Osi y Ra como identidad visual oficial. La ilustracion fuente
es `schoolbite_osi_ra_official.png` y debe tratarse como referencia canonica.

## Personalidad de Osi

Osi es un pastor aleman sable con uniforme verde SchoolBite y gorra verde con
huella. Representa pedidos, entregas y acompanamiento a las familias.

- Alegre, servicial y cercano.
- Transmite rapidez, orden y confianza.
- Puede aparecer en pedidos, entregas, confirmaciones y estados positivos.
- Frases sugeridas: "Tu pedido esta en buenas patas", "Todo listo para
  entregar" y "Gracias por usar SchoolBite".

## Personalidad de Ra

Ra es un gato blanco con uniforme de chef. Sus ojos siempre deben mantener
heterocromia: ojo izquierdo azul y ojo derecho amarillo. Representa cocina,
preparacion y cuidado en los alimentos.

- Tranquilo, amable y cuidadoso.
- Transmite calidad, calma y cocina organizada.
- Puede aparecer en produccion, cocina, menus y bienvenida.
- Frases sugeridas: "Cocinamos con amor para ti", "Hoy cocinaremos algo
  delicioso" y "Nos vemos manana".

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

Cuando se agregue una fuente de marca, debe conectarse desde el theme central y
no desde widgets individuales.

## Reglas de uso de las mascotas

- No generar nuevas mascotas ni reinterpretar el estilo.
- No usar personajes alternativos.
- Osi siempre es el encargado de pedidos y entregas.
- Ra siempre es el encargado de cocina.
- Ra siempre debe mantener ojo izquierdo azul y ojo derecho amarillo.
- No deformar, estirar ni recolorear las mascotas.
- No usar el poster completo como icono, avatar o miniatura operativa.
- `osi.png`, `ra.png`, `osi_splash.png`, `ra_splash.png`,
  `osi_delivery.png` y `ra_cooking.png` deben ser recortes limpios de mascota.
- Usar las mascotas en splash, landing, about, empty states, loading y mensajes
  amigables.
- No abusar de mensajes de mascota en pantallas operativas.

## Organizacion de assets

Cada proyecto mantiene su propia carpeta:

```text
assets/branding/
  schoolbite_osi_ra_official.png
  osi.png
  ra.png
  osi_splash.png
  ra_splash.png
  osi_delivery.png
  ra_cooking.png
  logo_schoolbite.png
```

Todas las referencias de UI deben pasar por `BrandAssets`, ubicado en:

```text
lib/branding/brand_assets.dart
```

Los recortes actuales salen de la ilustracion oficial. Cuando existan exports
definitivos, reemplazar archivos conservando los mismos nombres para no tocar
widgets ni logica.
