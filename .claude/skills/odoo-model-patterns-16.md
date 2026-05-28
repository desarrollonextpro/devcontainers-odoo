# Odoo 16.0 Model Patterns

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  ODOO 16.0 ORM PATTERNS                                                      ║
║  Python 3.10 | Type hints opcionales | Sin SQL() builder                     ║
║  _sql_constraints como lista | OWL 1.x                                       ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

## Características de v16

| Feature | Odoo 16.0 |
|---------|-----------|
| Type hints | Opcionales |
| Raw SQL | String directo con params |
| SQL() builder | **No disponible** |
| X2many commands | `Command` class (recomendado) o tuplas legacy |
| SQL constraints | `_sql_constraints = [...]` lista |
| OWL | 1.x |
| Python | 3.10 |

## Modelo Básico

```python
from odoo import api, fields, models
from odoo.exceptions import ValidationError, UserError


class MyModel(models.Model):
    _name = 'my.model'
    _description = 'Mi Modelo'
    _order = 'date desc, name'
    _rec_name = 'name'

    # Identificación
    name = fields.Char(string='Nombre', required=True)
    ref = fields.Char(string='Referencia', copy=False)

    # Estado
    state = fields.Selection([
        ('draft', 'Borrador'),
        ('confirmed', 'Confirmado'),
        ('done', 'Hecho'),
        ('cancel', 'Cancelado'),
    ], default='draft', tracking=True)

    # Fechas
    date = fields.Date(default=fields.Date.today)
    date_start = fields.Datetime()
    date_end = fields.Datetime()

    # Relaciones
    partner_id = fields.Many2one('res.partner', string='Cliente', required=True)
    company_id = fields.Many2one('res.company', default=lambda self: self.env.company)
    user_id = fields.Many2one('res.users', default=lambda self: self.env.user)
    line_ids = fields.One2many('my.model.line', 'model_id', string='Líneas')
    tag_ids = fields.Many2many('my.model.tag', string='Etiquetas')

    # Campos computed
    amount_total = fields.Float(compute='_compute_amount_total', store=True)

    # Constraints SQL
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

## Raw SQL en v16 — Sin SQL() builder

```python
def get_summary_data(self):
    # v16 CORRECTO - string con params como lista
    self.env.cr.execute("""
        SELECT
            m.partner_id,
            COUNT(m.id) as total,
            SUM(m.amount_total) as amount
        FROM my_model m
        WHERE m.company_id = %s
          AND m.state = %s
          AND m.date >= %s
        GROUP BY m.partner_id
    """, [self.env.company.id, 'confirmed', fields.Date.today()])

    return self.env.cr.dictfetchall()

# Para un solo registro
def get_record_data(self, record_id):
    self.env.cr.execute(
        "SELECT id, name, state FROM my_model WHERE id = %s",
        [record_id]
    )
    return self.env.cr.fetchone()
```

## Onchange en v16

```python
@api.onchange('partner_id')
def _onchange_partner_id(self):
    if self.partner_id:
        self.user_id = self.partner_id.user_id
        # Retornar warning si es necesario
        return {
            'warning': {
                'title': 'Atención',
                'message': f'Cambiado a cliente: {self.partner_id.name}',
            }
        }
    else:
        self.user_id = False
```

## CRUD Overrides

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

## Many2many con Command (v16+)

```python
from odoo import Command

# Reemplazar todos
record.write({'tag_ids': [Command.set([1, 2, 3])]})

# Agregar uno
record.write({'tag_ids': [Command.link(tag.id)]})

# Quitar uno (sin eliminar)
record.write({'tag_ids': [Command.unlink(tag.id)]})

# Crear y vincular
record.write({'tag_ids': [Command.create({'name': 'Nueva Etiqueta'})]})

# Sintaxis legacy (también válida en v16)
record.write({'tag_ids': [(6, 0, [1, 2, 3])]})
```
