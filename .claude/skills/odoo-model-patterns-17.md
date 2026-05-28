# Odoo 17.0 Model Patterns

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  ODOO 17.0 ORM PATTERNS                                                      ║
║  Python 3.10 | Type hints opcionales | SQL() disponible (no obligatorio)     ║
║  _sql_constraints lista | OWL 2.x                                            ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

## Características de v17

| Feature | Odoo 17.0 |
|---------|-----------|
| Type hints | Opcionales |
| Raw SQL | String legacy o SQL() (ambos válidos) |
| SQL() builder | **Disponible, no obligatorio** |
| X2many commands | `Command` class (recomendado) |
| SQL constraints | `_sql_constraints = [...]` lista |
| OWL | 2.x |
| Python | 3.10 |

## Modelo Básico v17

```python
from odoo import api, fields, models
from odoo.exceptions import ValidationError, UserError
from odoo.tools import SQL  # Disponible desde v17


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
    def _compute_amount_total(self):
        for rec in self:
            rec.amount_total = sum(rec.line_ids.mapped('amount'))

    @api.constrains('date_start', 'date_end')
    def _check_dates(self):
        for rec in self:
            if rec.date_start and rec.date_end and rec.date_start > rec.date_end:
                raise ValidationError("La fecha fin debe ser posterior a la de inicio.")

    def action_confirm(self):
        self.write({'state': 'confirmed'})

    def action_cancel(self):
        for rec in self:
            if rec.state == 'done':
                raise UserError("No se puede cancelar un registro hecho.")
        self.write({'state': 'cancel'})
```

## SQL en v17 — Dos estilos válidos

```python
from odoo.tools import SQL

def get_summary_data(self):
    # ESTILO 1: SQL() builder (recomendado, preparado para v19)
    self.env.cr.execute(SQL(
        """
        SELECT partner_id, COUNT(id) as total, SUM(amount_total) as amount
        FROM my_model
        WHERE company_id = %s AND state = %s
        GROUP BY partner_id
        """,
        self.env.company.id, 'confirmed'
    ))

    # ESTILO 2: String legacy (también válido en v17)
    self.env.cr.execute("""
        SELECT partner_id, COUNT(id) as total
        FROM my_model
        WHERE company_id = %s AND state = %s
        GROUP BY partner_id
    """, [self.env.company.id, 'confirmed'])

    return self.env.cr.dictfetchall()
```

## Onchange v17

```python
@api.onchange('partner_id')
def _onchange_partner_id(self):
    if self.partner_id:
        self.user_id = self.partner_id.user_id
```

## CRUD Overrides v17

```python
@api.model_create_multi
def create(self, vals_list):
    for vals in vals_list:
        if not vals.get('ref'):
            vals['ref'] = self.env['ir.sequence'].next_by_code('my.model')
    return super().create(vals_list)

def write(self, vals):
    if 'state' in vals and vals['state'] == 'confirmed':
        for rec in self:
            if not rec.line_ids:
                raise UserError("Debe tener al menos una línea.")
    return super().write(vals)

def unlink(self):
    for rec in self:
        if rec.state != 'draft':
            raise UserError("Solo se pueden eliminar registros en borrador.")
    return super().unlink()
```
