# Odoo 18.0 Model Patterns

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  ODOO 18.0 ORM PATTERNS                                                      ║
║  Python 3.12 | Type hints opcionales | SQL() recomendado                    ║
║  _sql_constraints lista | OWL 2.x | match/case disponible                   ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

## Características de v18

| Feature | Odoo 18.0 |
|---------|-----------|
| Type hints | Opcionales (recomendados) |
| Raw SQL | SQL() recomendado; string legacy también válido |
| SQL() builder | **Disponible y recomendado** |
| X2many commands | `Command` class (recomendado) |
| SQL constraints | `_sql_constraints = [...]` lista |
| OWL | 2.x |
| Python | 3.12 |
| match/case | Disponible |

## Modelo Básico v18

```python
from odoo import api, fields, models
from odoo.exceptions import ValidationError, UserError
from odoo.tools import SQL  # Recomendado en v18


class MyModel(models.Model):
    _name = 'my.model'
    _description = 'Mi Modelo'
    _order = 'date desc, name'

    name = fields.Char(string='Nombre', required=True)
    ref = fields.Char(string='Referencia', copy=False)

    state = fields.Selection([
        ('draft', 'Borrador'),
        ('confirmed', 'Confirmado'),
        ('done', 'Hecho'),
        ('cancel', 'Cancelado'),
    ], default='draft', tracking=True)

    date = fields.Date(default=fields.Date.today)
    partner_id = fields.Many2one('res.partner', string='Cliente', required=True)
    company_id = fields.Many2one('res.company', default=lambda self: self.env.company)
    user_id = fields.Many2one('res.users', default=lambda self: self.env.user)
    line_ids = fields.One2many('my.model.line', 'model_id', string='Líneas')
    tag_ids = fields.Many2many('my.model.tag', string='Etiquetas')
    amount_total = fields.Float(compute='_compute_amount_total', store=True)

    _sql_constraints = [
        ('name_company_uniq', 'UNIQUE(name, company_id)',
         'El nombre debe ser único por empresa.'),
    ]

    @api.depends('line_ids.amount')
    def _compute_amount_total(self) -> None:
        for rec in self:
            rec.amount_total = sum(rec.line_ids.mapped('amount'))

    @api.constrains('date_start', 'date_end')
    def _check_dates(self) -> None:
        for rec in self:
            if rec.date_start and rec.date_end and rec.date_start > rec.date_end:
                raise ValidationError("La fecha fin debe ser posterior a la de inicio.")

    def action_confirm(self) -> None:
        self.write({'state': 'confirmed'})

    def action_cancel(self) -> None:
        for rec in self:
            if rec.state == 'done':
                raise UserError("No se puede cancelar un registro hecho.")
        self.write({'state': 'cancel'})
```

## SQL en v18 — SQL() recomendado

```python
from odoo.tools import SQL

def get_summary_data(self):
    # RECOMENDADO en v18: SQL() builder
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

# También válido en v18 (pero preparar migración a SQL())
def get_data_legacy(self):
    self.env.cr.execute("""
        SELECT partner_id, COUNT(id) as total
        FROM my_model
        WHERE company_id = %s AND state = %s
        GROUP BY partner_id
    """, [self.env.company.id, 'confirmed'])
    return self.env.cr.dictfetchall()
```

## match/case en v18 (Python 3.12)

```python
def process_state_action(self) -> None:
    for rec in self:
        match rec.state:
            case 'draft':
                rec._validate_draft_requirements()
            case 'confirmed':
                rec._send_confirmation_email()
            case 'done':
                rec._close_related_activities()
            case 'cancel':
                rec._refund_payments()
            case _:
                raise UserError(f"Estado no manejado: {rec.state}")
```

## Onchange v18

```python
@api.onchange('partner_id')
def _onchange_partner_id(self) -> None:
    if self.partner_id:
        self.user_id = self.partner_id.user_id
        if self.partner_id.property_payment_term_id:
            self.payment_term_id = self.partner_id.property_payment_term_id
```

## CRUD Overrides v18

```python
@api.model_create_multi
def create(self, vals_list: list[dict]) -> 'MyModel':
    for vals in vals_list:
        if not vals.get('ref'):
            vals['ref'] = self.env['ir.sequence'].next_by_code('my.model')
    return super().create(vals_list)

def write(self, vals: dict) -> bool:
    if 'state' in vals and vals['state'] == 'confirmed':
        for rec in self:
            if not rec.line_ids:
                raise UserError("Debe tener al menos una línea.")
    return super().write(vals)

def unlink(self) -> bool:
    for rec in self:
        if rec.state != 'draft':
            raise UserError("Solo se pueden eliminar registros en borrador.")
    return super().unlink()
```

## Command para Many2many (v18)

```python
from odoo import Command

# Recomendado en v18
def assign_tags(self, tag_ids: list[int]) -> None:
    self.write({
        'tag_ids': [Command.set(tag_ids)]
    })

def add_tag(self, tag_id: int) -> None:
    self.write({
        'tag_ids': [Command.link(tag_id)]
    })

def remove_tag(self, tag_id: int) -> None:
    self.write({
        'tag_ids': [Command.unlink(tag_id)]
    })
```

## Búsquedas eficientes en v18

```python
# v18: domain expressions claras
def get_pending_records(self) -> 'MyModel':
    return self.search([
        ('state', 'in', ['draft', 'confirmed']),
        ('date', '<=', fields.Date.today()),
        ('company_id', '=', self.env.company.id),
    ])

# v18: with_context para multi-company
def get_all_company_records(self) -> 'MyModel':
    return self.with_context(
        allowed_company_ids=self.env.user.company_ids.ids
    ).search([('state', '=', 'active')])
```
