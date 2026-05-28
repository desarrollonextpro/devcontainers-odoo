# Odoo 16.0 Version Knowledge

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  ODOO 16.0 KNOWLEDGE BASE                                                    ║
║  Python 3.10 | PostgreSQL 14/15 | OWL 1.x                                   ║
║  Vista attrs={} | _sql_constraints lista | Sin SQL() builder                 ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

## Version Overview

| Aspect | Details |
|--------|---------|
| Release Date | October 2022 |
| Python | 3.10 |
| PostgreSQL | 12, 13, 14, 15 |
| Frontend | OWL 1.x |
| Status | Stable / LTS |

## Sintaxis de Vistas — CRITICAL para v16

En v16 se usan `attrs` para visibilidad/requerido. En v17+ esto cambia completamente.

```xml
<!-- v16 CORRECTO - attrs con domain -->
<field name="partner_id"
    attrs="{'invisible': [('state', '=', 'draft')],
            'required': [('state', '=', 'confirmed')]}"/>

<!-- v16 CORRECTO - states en botones -->
<button name="action_confirm" type="object"
    string="Confirm"
    states="draft"/>

<!-- v17+ (NO usar en v16) -->
<field name="partner_id" invisible="state == 'draft'"/>
```

## SQL Queries — v16 usa strings directos

```python
# v16 CORRECTO - string directo con params como lista/tupla
self.env.cr.execute(
    "SELECT id, name FROM my_model WHERE state = %s AND company_id = %s",
    [state, self.env.company.id]
)
results = self.env.cr.fetchall()

# v16 - NO existe SQL() builder (disponible desde v17)
# NO usar: from odoo.tools import SQL
```

## SQL Constraints — Lista en v16/17/18

```python
class MyModel(models.Model):
    _name = 'my.model'

    # v16/17/18 CORRECTO
    _sql_constraints = [
        ('name_uniq', 'UNIQUE(name, company_id)',
         'El nombre debe ser único por empresa.'),
        ('check_amount', 'CHECK(amount >= 0)',
         'El importe no puede ser negativo.'),
    ]

    # v19 usa models.Constraint() - NO disponible en v16
```

## Novedades principales de v16

- **Spreadsheet**: integración nativa con módulo `documents_spreadsheet`
- **eCommerce mejorado**: nuevo diseño frontend
- **Accounting**: mejoras en conciliación bancaria
- **Website**: rediseño completo del constructor de páginas
- **IoT**: soporte mejorado para dispositivos
- **Barcode**: nuevo módulo de gestión

## Breaking changes de v15 → v16

```python
# Módulos renombrados
# v15: sale_management → v16: sale
# v15: account_accountant → v16: account

# API changes en res.partner
# v16: campo 'display_name' es computed
partner.display_name  # 'Empresa, Contacto'

# Vistas: _name obligatorio en arch raíz en algunos casos
```

## Campos Many2many — Command class disponible desde v14

```python
from odoo import Command

# v16 RECOMENDADO - Command class
record.write({
    'tag_ids': [Command.set([1, 2, 3])],  # Reemplaza (6, 0, ids)
    'line_ids': [Command.create({'name': 'New'})],  # Reemplaza (0, 0, vals)
    'user_ids': [Command.link(user.id)],  # Reemplaza (4, id)
    'product_ids': [Command.unlink(product.id)],  # Reemplaza (3, id)
})

# v16 también acepta sintaxis legacy (backwards compatible)
record.write({'tag_ids': [(6, 0, [1, 2, 3])]})
```

## Patrones de Seguridad v16

```xml
<!-- ir.model.access.csv -->
id,name,model_id:id,group_id:id,perm_read,perm_write,perm_create,perm_unlink
access_my_model_user,my.model user,model_my_model,base.group_user,1,0,0,0
access_my_model_manager,my.model manager,model_my_model,my_module.group_manager,1,1,1,1
```

```xml
<!-- Record rules -->
<record id="my_model_own_rule" model="ir.rule">
    <field name="name">My Model: Own Records</field>
    <field name="model_id" ref="model_my_model"/>
    <field name="domain_force">[('user_id', '=', user.id)]</field>
    <field name="groups" eval="[(4, ref('base.group_user'))]"/>
</record>
```
