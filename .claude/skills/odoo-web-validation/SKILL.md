---
name: odoo-web-validation
description: >-
  Valida visual y funcionalmente desarrollos web de Odoo (vistas, componentes OWL, estilos,
  flujos). Levanta/verifica el Odoo vivo, lo navega con el navegador de Playwright MCP (login,
  clic, scroll), toma screenshots, detecta overflow/solapamiento de elementos, y corre los
  tests nativos de navegador (Hoot o QUnit según la sub-versión 17.0) y tours. Úsala cuando haya
  que "revisar cómo se ve", "validar el flujo/estilos", "tomar una captura", comprobar que nada
  se desborde ni se sobreponga, o correr tests de frontend/OWL.
---

# Validación web de Odoo (visual + funcional)

Esta skill cubre lo que los tests nativos por sí solos no dan: **conducir el navegador** contra el
Odoo vivo para revisar UI/estilos/flujos, más los tests automatizados de frontend.

**Versión de este contenedor: Odoo 17.0.** ⚠️ **Odoo 17.0 está a caballo entre dos generaciones de
framework.** El release actual de la serie 17.0 usa **Hoot** + URL `/odoo` + `<list>`, pero algunos
snapshots **tempranos** de 17.0 (como el que puede haberse clonado aquí) aún usan **QUnit** + `/web`
+ `<tree>`. **Detecta cuál corre tu fuente antes de asumir** (ver §C).

## Requisitos (ya provistos por el dev container)
- **Playwright MCP** — servidor MCP `playwright` declarado en `/workspace/.mcp.json`. Da las
  herramientas `mcp__playwright__*` (navegar, clic, escribir, snapshot del DOM, screenshot,
  evaluar JS). Requiere **Node ≥20** y `@playwright/mcp` (instalados por el Dockerfile). Reutiliza
  `/usr/bin/chromium` (headless, `--no-sandbox`). Si el servidor MCP no aparece, hay que **rebuild
  del contenedor + recargar Claude Code**.
- **chromium** en `/usr/bin/chromium` (tests nativos de Odoo) y **websocket-client** en el venv.
- Screenshots del MCP se guardan en `/tmp/playwright-mcp/` (leíbles con Read).

---

## A. Conducir el Odoo vivo con Playwright MCP

1. **Asegura que Odoo está sirviendo.** Comprueba salud:
   ```bash
   curl -s -o /dev/null -w "%{http_code}" http://localhost:8069/web/health   # 200 = arriba
   ```
   Si no responde, levántalo con la `.conf` de la instancia objetivo. Ejecutar en background:
   ```bash
   /workspace/.venv/bin/python /workspace/odoo.17.0/odoo-bin -c <conf> &
   ```
   > Odoo escucha internamente en `8069`; el puerto publicado hacia el host es `7569` (docker-compose),
   > pero dentro del contenedor y para Playwright MCP siempre usas `localhost:8069`.
2. **Navega y loguéate** con las herramientas del MCP (`mcp__playwright__browser_navigate`, `_type`,
   `_click`). URL: `http://localhost:8069/odoo` (releases 17.0 actuales) **o** `/web` (snapshots
   tempranos). Si `/odoo` da 404, usa `/web`. Credenciales según la instancia. Login estándar Odoo:
   campo `login`, campo `password`, botón submit.
3. **Interactúa**: clic en menús, scroll, abre el formulario/vista objetivo. Usa el `snapshot`
   del MCP (árbol de accesibilidad) para localizar elementos de forma estable antes de clicar.
4. **Captura**: `mcp__playwright__browser_take_screenshot` (full page o de un elemento). Luego
   `Read` la imagen de `/tmp/playwright-mcp/` para revisarla, o pásala al usuario.

> El navegador es headless: las capturas funcionan igual. Para "ver" un estado, siempre screenshot.

---

## B. Chequeo automático de overflow / solapamiento

Ejecuta este snippet con `mcp__playwright__browser_evaluate` (recibe una función y devuelve JSON).
Detecta 3 problemas: contenido que desborda su caja, elementos que se salen del viewport, y
controles interactivos que se solapan (>60% de área). Cota el coste a 400 elementos.

```js
() => {
  const vw = document.documentElement.clientWidth;
  const sel = el => el.id ? '#'+el.id
    : el.tagName.toLowerCase() + (typeof el.className==='string' && el.className.trim()
        ? '.'+el.className.trim().split(/\s+/).slice(0,2).join('.') : '');
  const vis = el => { const s=getComputedStyle(el);
    return s.display!=='none' && s.visibility!=='hidden' && el.offsetParent!==null; };
  const els = [...document.querySelectorAll('body *')].filter(vis).slice(0, 400);
  const out = { url: location.href, viewport: vw, horizontalOverflow: [], viewportOverflow: [], overlaps: [] };
  for (const el of els) {
    const s = getComputedStyle(el);
    if (el.scrollWidth - el.clientWidth > 2 && !/(auto|scroll)/.test(s.overflowX))
      out.horizontalOverflow.push({ el: sel(el), scrollWidth: el.scrollWidth, clientWidth: el.clientWidth });
    const r = el.getBoundingClientRect();
    if (r.width > 0 && (r.right > vw + 2 || r.left < -2))
      out.viewportOverflow.push({ el: sel(el), left: Math.round(r.left), right: Math.round(r.right) });
  }
  const ctrl = els.filter(el => /^(BUTTON|A|INPUT|SELECT|TEXTAREA|LABEL)$/.test(el.tagName)).slice(0, 150);
  for (let i=0;i<ctrl.length;i++) for (let j=i+1;j<ctrl.length;j++) {
    const a=ctrl[i], b=ctrl[j]; if (a.contains(b)||b.contains(a)) continue;
    const ra=a.getBoundingClientRect(), rb=b.getBoundingClientRect();
    if (!ra.width||!rb.width) continue;
    const ox=Math.max(0,Math.min(ra.right,rb.right)-Math.max(ra.left,rb.left));
    const oy=Math.max(0,Math.min(ra.bottom,rb.bottom)-Math.max(ra.top,rb.top));
    if (ox*oy > 0.6*Math.min(ra.width*ra.height, rb.width*rb.height))
      out.overlaps.push({ a: sel(a), b: sel(b) });
  }
  out.counts = { ho: out.horizontalOverflow.length, vo: out.viewportOverflow.length, ov: out.overlaps.length };
  return out;
}
```
Interpretación: `viewportOverflow` = algo se sale a la derecha (scroll horizontal indeseado);
`horizontalOverflow` = texto/tabla que desborda su contenedor sin scroll; `overlaps` = botones/campos
encimados. Revisa además a ojo con una screenshot: el snippet es heurístico, no sustituye la vista.

---

## C. Tests nativos de frontend (Hoot **o** QUnit — DETECTA primero)

Odoo 17.0 puede traer Hoot o QUnit según la sub-versión clonada. **Detecta cuál** antes de escribir tests:
```bash
ls /workspace/odoo.17.0/addons/web/static/lib/hoot 2>/dev/null && echo "HOOT" || echo "QUNIT"
```

**Si HOOT** (releases 17.0 actuales; igual que v18/v19):
- Bundle en el `__manifest__.py`: `"web.assets_unit_tests": ["<módulo>/static/tests/**/*"]`.
- Correr sobre BD aislada (sin demo):
  ```bash
  /workspace/.venv/bin/python /workspace/odoo.17.0/odoo-bin -c <conf> -d <db_test> \
    --test-enable --test-tags '/web:WebSuite.test_unit_desktop[@<módulo>]' --stop-after-init
  ```
- Patrones Hoot: `mountWithCleanup(...)`, `defineMailModels()`, `contains(...)`, `onRpc(...)`.
- **Estilos/layout en Hoot**: `expect(selector).toHaveStyle({...})` / `not.toHaveStyle(...)`.

**Si QUNIT** (snapshots tempranos de 17.0):
- Bundle `web.qunit_suite_tests` (runtime en `web.tests`); helpers en `web.test_utils`.
- Correr con `--test-tags '/web'` (o los tags del módulo). Sin `toHaveStyle`: valida estilo con
  `getBoundingClientRect`/`getComputedStyle` dentro del test, o con las §A/§B (navegar + overflow).

**Tours** (funcionan en ambos casos con chromium): `HttpCase.start_tour` / `browser_js`
lanzan chromium headless (Odoo pasa `--no-sandbox`/`--disable-dev-shm-usage`) y guardan screenshots
automáticos al fallar un paso.

---

## Gotchas
- Usa **BD de test aislada** para los tests (`-i <módulo> --without-demo=all`), no la BD de trabajo.
- Evita en el `addons_path` de test los módulos con QWeb roto que revientan el bundle.
- Si el MCP `playwright` no está disponible (Node <20 / sin rebuild), cae a: chromium headless directo
  (`chromium --headless --no-sandbox --screenshot=out.png --window-size=1280,900 <url>`) para una
  captura simple, o a los tours nativos. Documenta la limitación en vez de fingir que validaste.
