# Odoo 17.0 Version Knowledge

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  ODOO 17.0 KNOWLEDGE BASE                                                    ║
║  Python 3.10 | OWL 2.x | Sin attrs={} | Sin states en botones               ║
║  SQL() disponible | _sql_constraints lista | Nueva UI                         ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

## Version Overview

| Aspect | Details |
|--------|---------|
| Release Date | October 2023 |
| Python | 3.10, 3.11 |
| PostgreSQL | 12-16 |
| Frontend | OWL 2.x |
| Status | Stable |

## BREAKING: attrs={} ELIMINADO en v17

Este es el cambio más importante al migrar de v16 a v17.

```xml
<!-- v16 (NO usar en v17) -->
<field name="partner_id"
    attrs="{'invisible': [('state', '=', 'draft')],
            'required': [('state', '!=', 'draft')]}"/>

<!-- v17 CORRECTO - expresiones Python directas -->
<field name="partner_id"
    invisible="state == 'draft'"
    required="state != 'draft'"/>

<!-- v17 - operadores lógicos en expresiones -->
<field name="amount"
    invisible="state not in ['confirmed', 'done']"
    readonly="state == 'done'"/>
```

## BREAKING: states en botones ELIMINADO en v17

```xml
<!-- v16 (NO usar en v17) -->
<button name="action_confirm" type="object"
    string="Confirmar"
    states="draft"/>

<!-- v17 CORRECTO -->
<button name="action_confirm" type="object"
    string="Confirmar"
    invisible="state != 'draft'"/>
```

## SQL() builder disponible (opcional) en v17

```python
from odoo.tools import SQL

# v17 - SQL() disponible pero no obligatorio
# Ambos estilos son válidos en v17/18

# Estilo nuevo con SQL() (recomendado para queries complejas)
self.env.cr.execute(SQL(
    "SELECT id FROM my_model WHERE state = %s AND company_id = %s",
    'confirmed', self.env.company.id
))

# Estilo legacy (también válido en v17)
self.env.cr.execute(
    "SELECT id FROM my_model WHERE state = %s AND company_id = %s",
    ['confirmed', self.env.company.id]
)

# v19 hará SQL() OBLIGATORIO - mejor adoptar el estilo nuevo desde ya
```

## SQL Constraints — Lista en v16/17/18

```python
# v17/18 CORRECTO - lista con tuplas
_sql_constraints = [
    ('name_uniq', 'UNIQUE(name, company_id)',
     'El nombre debe ser único por empresa.'),
    ('check_amount', 'CHECK(amount >= 0)',
     'El importe no puede ser negativo.'),
]

# v19 cambiará a models.Constraint() - NO usar en v17
```

## Novedades principales de v17

- **Nueva UI**: diseño renovado, mejor usabilidad
- **Spreadsheet**: mejorado con nuevas funciones
- **Accounting**: nuevas herramientas de conciliación
- **Website Builder**: nuevo editor de páginas más flexible
- **OWL 2.x**: componentes JS más potentes
- **Studio**: mejoras en el constructor de vistas

## Breaking changes de v16 → v17

```xml
<!-- ELIMINADO en v17: attrs={} -->
<!-- ELIMINADO en v17: states en fields/buttons -->
<!-- ELIMINADO en v17: groups attr en views (usar access rules) -->

<!-- v17: Nueva sintaxis de decoradores en vistas de lista -->
<tree decoration-info="state == 'draft'"
      decoration-success="state == 'done'"
      decoration-danger="state == 'cancel'">
```

```python
# v17: Método _get_report_values reemplazado por _get_report_filename
# v17: Cambios en la API de mail.thread
```

## Campos computed — sin cambios de v16

```python
# Igual que v16, sin cambios en v17
@api.depends('line_ids.amount')
def _compute_amount_total(self):
    for rec in self:
        rec.amount_total = sum(rec.line_ids.mapped('amount'))
```
