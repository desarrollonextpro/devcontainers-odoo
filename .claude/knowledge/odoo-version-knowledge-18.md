# Odoo 18.0 Version Knowledge

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  ODOO 18.0 KNOWLEDGE BASE                                                    ║
║  Python 3.12 | OWL 2.x | Sin attrs={} | Sin states en botones               ║
║  SQL() recomendado | _sql_constraints lista | match/case disponible          ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

## Version Overview

| Aspect | Details |
|--------|---------|
| Release Date | October 2024 |
| Python | 3.12 |
| PostgreSQL | 14-17 |
| Frontend | OWL 2.x |
| Status | Stable |

## Python 3.12 en Odoo 18

```python
# match/case disponible en v18 (Python 3.12)
def process_by_state(self):
    for rec in self:
        match rec.state:
            case 'draft':
                rec._prepare_draft()
            case 'confirmed':
                rec._process_confirmed()
            case 'done' | 'cancel':
                rec._archive_record()
            case _:
                raise UserError(f"Estado desconocido: {rec.state}")

# f-strings mejorados en Python 3.12
message = f"Procesando {len(self)} registros de {self.company_id.name!r}"

# Exception groups (Python 3.11+)
# try:
#     ...
# except* ValidationError as eg:
#     ...
```

## SQL() builder — Recomendado en v18

```python
from odoo.tools import SQL

# v18: SQL() es la forma recomendada (preparándose para v19 donde será obligatorio)
def get_summary_data(self):
    self.env.cr.execute(SQL(
        """
        SELECT partner_id, COUNT(id) as total, SUM(amount_total) as amount
        FROM my_model
        WHERE company_id = %s AND state = %s
        GROUP BY partner_id
        ORDER BY amount DESC
        """,
        self.env.company.id, 'confirmed'
    ))
    return self.env.cr.dictfetchall()

# También válido en v18 (legacy)
def get_data_legacy(self):
    self.env.cr.execute("""
        SELECT id FROM my_model WHERE state = %s
    """, ['confirmed'])
    return self.env.cr.fetchall()

# NOTA: en v19 SQL() será OBLIGATORIO — adoptar el estilo nuevo desde ya
```

## SQL Constraints — Lista en v18

```python
# v18 CORRECTO - lista con tuplas (igual que v16/v17)
_sql_constraints = [
    ('name_uniq', 'UNIQUE(name, company_id)',
     'El nombre debe ser único por empresa.'),
    ('check_amount', 'CHECK(amount >= 0)',
     'El importe no puede ser negativo.'),
]

# NOTA: v19 cambiará a models.Constraint() — NO usar en v18
```

## Vistas — Misma sintaxis que v17 (sin attrs)

```xml
<!-- v18 CORRECTO — igual que v17, expresiones directas -->
<field name="partner_id"
    invisible="state == 'draft'"
    required="state != 'draft'"
    readonly="state == 'done'"/>

<!-- botones sin states -->
<button name="action_confirm" type="object"
    string="Confirmar" class="btn-primary"
    invisible="state != 'draft'"/>

<!-- NUNCA usar en v18 (eliminado en v17) -->
<!-- <field name="x" attrs="{'invisible': [...]}" /> -->
<!-- <button states="draft"/> -->
```

## Novedades principales de v18

- **Spreadsheet**: mejoras significativas, nuevas funciones y conectores
- **eCommerce**: rediseño completo, mejor rendimiento
- **Knowledge**: módulo de documentación maduro
- **Discuss**: mejoras en chat y canales
- **Manufacturing**: mejor planificación y WIP
- **Accounting**: nuevas herramientas de cumplimiento fiscal
- **HR**: ciclos de evaluación mejorados
- **Python 3.12**: match/case, f-strings mejorados, mejor rendimiento

## Breaking changes de v17 → v18

```python
# v18: Algunos módulos renombrados o refactorizados
# - 'account_reports' mejorado
# - Cambios en OCA compatibility

# Python 3.12: deprecaciones antiguas removidas
# - No usar 'distutils' (eliminado en 3.12)
# - No usar 'asynchat', 'asyncore' (eliminados en 3.12)
# - 'cgi', 'cgitb' deprecados

# v18: type hints opcionales pero recomendados para IDE support
def compute_amount(self) -> None:
    for rec in self:
        rec.amount_total = sum(rec.line_ids.mapped('amount'))
```

## Type hints opcionales en v18

```python
# v18: type hints son opcionales pero mejoran el IDE support
from odoo import api, fields, models
from odoo.exceptions import ValidationError

class SaleOrder(models.Model):
    _inherit = 'sale.order'

    # Con type hints (recomendado en v18)
    def _compute_total(self) -> None:
        for order in self:
            order.amount_total = sum(
                line.price_total for line in order.order_line
            )

    @api.model
    def create_from_api(self, vals: dict) -> 'SaleOrder':
        return self.create(vals)

    # Sin type hints (también válido en v18)
    def action_confirm(self):
        return super().action_confirm()
```

## Novedades de acceso a registros en v18

```python
# v18: with_context más usado para modelos multi-company
records = self.env['my.model'].with_context(
    allowed_company_ids=[self.env.company.id]
).search([('state', '=', 'active')])

# v18: sudo() más preciso
record.with_user(self.env.user).sudo().write({'state': 'done'})
```
