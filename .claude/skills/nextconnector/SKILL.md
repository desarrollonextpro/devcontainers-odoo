---
name: nextconnector
description: >-
  Arquitectura y convenciones del "Next Conector" (módulos nextconnector_*, Odoo 19), la
  integración que sincroniza Odoo con un ERP externo (SAP Business One) vía cola de trabajos.
  Úsala al desarrollar, depurar o extender cualquier módulo nextconnector_* (contactos, productos,
  ventas, facturas, stock, pagos, POS, RRHH, helpdesk) o la sincronización con SAP B1.
---

# Next Conector (nextconnector_*) — Odoo ↔ SAP Business One

Suite propia de NextPro que sincroniza maestros y transacciones entre Odoo y un **ERP externo
(SAP B1)** mediante una **cola de sincronización** y automatizaciones. Repo:
`github.com/desarrollonextpro/nextconnector` (rama **`19.0`**). Ruta local:
`/workspace/custom-addons/nextconnector/`. Serie de versión: **`19.0.1.x`**.

> Existe un gemelo `/workspace/custom-addons/nextconnector_ci/` con los **mismos 16 módulos y
> versiones idénticas** (manifests iguales). Es un **mirror** (arranque de BD de test / CI), **no**
> otra versión funcional. No lo edites como si fuera distinto; trabaja en `nextconnector`.

## Mapa de módulos (16)

**Base y UI:**
- `nextconnector_base` (19.0.1.3.0, depends `base`, `base_automation`) — núcleo: control tower, cola
  de sync, logs. Es la dependencia de todos los demás.
- `nextconnector_dashboard` (19.0.1.3.0) — Control Tower + UI del Sync Log.

**Maestros:** `nextconnector_contacts`, `nextconnector_products`, `nextconnector_product_stock`,
`nextconnector_product_pricelist`.

**Transacciones:** `nextconnector_sale_order`, `nextconnector_purchase_order`,
`nextconnector_account_move`, `nextconnector_account`, `nextconnector_account_payment`,
`nextconnector_stock_picking`, `nextconnector_pos_order`, `nextconnector_pos_payment`.

**Otros dominios:** `nextconnector_hr`, `nextconnector_helpdesk_ticket`.

Cada satélite depende de `nextconnector_base` + su módulo Odoo (`sale`, `account`, `stock`,
`point_of_sale`, `hr`, `helpdesk`, …). La base y los módulos "core" van en `19.0.1.3.0`; varios
satélites aún en `19.0.1.1.1`/`1.1.2` (versionado por módulo, una sola línea `19.0.1.x`).

## Convenciones al trabajar aquí
- **Idioma de commits**: español (repo de cliente). **Sin `Co-Authored-By`** (los commits los firma
  `NextPro Dev <claude.desarrollo@nextpro.pe>`). Ver [[commits-sin-coautor]].
- **Bump del manifest** del/los módulo(s) tocado(s) al hacer un cambio.
- **Rama base = `19.0`** (rama única; no hay ramas de feature en este repo). Antes de trabajar,
  `git fetch` y comparar con `origin/19.0`. **Pedir autorización antes de push** ([[pedir-autorizacion-push]]).
- Cambios de cola/sync: respetar el patrón de `nextconnector_base` (no reinventar la cola;
  reutilizar sus modelos/automatizaciones). Para tests, usar los tags del módulo.

## Portabilidad a otras versiones del conector
La edición en disco es v19. Ediciones para Odoo 17/18 (si existen) vivirían en ramas/repos
paralelos. Al crear la skill del conector en otro contenedor, ajustar la serie de versión
(`<v>.0.1.x`) y verificar dependencias core que cambian entre versiones.

## Pendiente de enriquecer (vía `/aprendizaje-continuo`)
Este es un *starter* a nivel de arquitectura/manifests. Detalles a documentar cuando aparezcan en
sesiones reales: nombres de los modelos de cola y de mapeo, endpoints/credenciales SAP B1, formato de
los payloads, y gotchas de sincronización. Cuando aprendas algo reutilizable del conector, propón
añadirlo aquí.
