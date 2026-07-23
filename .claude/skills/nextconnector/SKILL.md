---
name: nextconnector
description: >-
  Arquitectura y convenciones del "Next Conector" (módulos nextconnector_*, Odoo 18), la
  integración que sincroniza Odoo con un ERP externo (SAP Business One) vía cola de trabajos.
  Úsala al desarrollar, depurar o extender cualquier módulo nextconnector_* (contactos, productos,
  ventas, facturas, stock, pagos, POS, RRHH, helpdesk) o la sincronización con SAP B1.
---

# Next Conector (nextconnector_*) — Odoo ↔ SAP Business One

Suite propia de NextPro que sincroniza maestros y transacciones entre Odoo y un **ERP externo
(SAP B1)** mediante una **cola de sincronización** y automatizaciones. Repo:
`github.com/desarrollonextpro/nextconnector` (rama **`18.0`**). Serie de versión: **`18.0.1.x`**.

> En este contenedor v18 el conector está **clonado dentro de varios clientes** de
> `/workspace/custom-addons/`: `andes/nextconnector`, `evi-dji/nextconnector`,
> `icon-supply/nextconnector`, `proriego/nextconnector`, `uysa/nextconnector` (esta última con
> remoto **SSH** `git@github.com:...`; el resto con HTTPS). Son checkouts del **mismo repo** en la
> rama `18.0`; trabaja sobre el checkout que corresponde a la instancia/`.conf` objetivo y mantén
> los demás sincronizados si aplica.

## Mapa de módulos
La suite se organiza en familias (los nombres exactos y versiones por módulo se leen del
`__manifest__.py` de cada uno — **serie `18.0.1.x`**):

- **Base y UI:** `nextconnector_base` (núcleo: control tower, cola de sync, logs; dependencia de
  todos los demás), `nextconnector_dashboard` (Control Tower + UI del Sync Log).
- **Maestros:** `nextconnector_contacts`, `nextconnector_products`, `nextconnector_product_stock`,
  `nextconnector_product_pricelist`.
- **Transacciones:** `nextconnector_sale_order`, `nextconnector_purchase_order`,
  `nextconnector_account_move`, `nextconnector_account`, `nextconnector_account_payment`,
  `nextconnector_stock_picking`, `nextconnector_pos_order`, `nextconnector_pos_payment`.
- **Otros dominios:** `nextconnector_hr`, `nextconnector_helpdesk_ticket`.

Cada satélite depende de `nextconnector_base` + su módulo Odoo (`sale`, `account`, `stock`,
`point_of_sale`, `hr`, `helpdesk`, …). Verifica en el `__manifest__.py` de cada módulo qué módulos
existen realmente en el checkout de la rama `18.0` (pueden variar respecto a v19) antes de asumir.

## Convenciones al trabajar aquí
- **Idioma de commits**: español (repo de cliente). **Sin `Co-Authored-By`**. Ver [[commits-sin-coautor]].
- **Bump del manifest** del/los módulo(s) tocado(s) al hacer un cambio.
- **Rama base = `18.0`** (rama por versión). Antes de trabajar, `git fetch` y comparar con
  `origin/18.0`. **Pedir autorización antes de push** ([[pedir-autorizacion-push]]).
- Cambios de cola/sync: respetar el patrón de `nextconnector_base` (no reinventar la cola;
  reutilizar sus modelos/automatizaciones). Para tests, usar los tags del módulo.

## Portabilidad a otras versiones del conector
La edición en disco es v18 (rama `18.0`). Ediciones para otras versiones de Odoo viven en las
ramas homónimas del mismo repo (`16.0`, `17.0`, `19.0`…). Al portar, ajustar la serie de versión
(`<v>.0.1.x`) y verificar las dependencias core que cambian entre versiones.

## Pendiente de enriquecer (vía `/aprendizaje-continuo`)
Este es un *starter* a nivel de arquitectura/manifests. Detalles a documentar cuando aparezcan en
sesiones reales: nombres de los modelos de cola y de mapeo, endpoints/credenciales SAP B1, formato de
los payloads, y gotchas de sincronización. Cuando aprendas algo reutilizable del conector, propón
añadirlo aquí.
