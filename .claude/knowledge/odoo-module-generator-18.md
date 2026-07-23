# Odoo Module Generator - Version 18.0

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  ODOO 18.0 MODULE GENERATION PATTERNS                                        ║
║  Version: 18.0.X.X.X | invisible/readonly directos (sin attrs={})           ║
║  Sin states en botones | OWL 2.x | Python 3.12                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

## __manifest__.py Template (v18)

```python
# -*- coding: utf-8 -*-
{
    'name': '{Module Title}',
    'version': '18.0.1.0.0',
    'category': '{Category}',
    'summary': '{Short description}',
    'description': """
{Detailed description}
    """,
    'author': '{Author}',
    'website': '{Website}',
    'license': 'LGPL-3',
    'depends': ['base', 'mail'],
    'data': [
        'security/{module_name}_security.xml',
        'security/ir.model.access.csv',
        'views/{model_name}_views.xml',
        'views/menuitems.xml',
    ],
    'assets': {
        'web.assets_backend': [
            '{module_name}/static/src/**/*.js',
            '{module_name}/static/src/**/*.xml',
            '{module_name}/static/src/**/*.scss',
        ],
    },
    'installable': True,
    'auto_install': False,
    'application': False,
}
```

## Vista Form (v18) — expresiones directas, SIN attrs

```xml
<record id="view_my_model_form" model="ir.ui.view">
    <field name="name">my.model.form</field>
    <field name="model">my.model</field>
    <field name="arch" type="xml">
        <form string="My Model">
            <header>
                <!-- v18: invisible en lugar de states -->
                <button name="action_confirm" type="object"
                    string="Confirmar" class="btn-primary"
                    invisible="state != 'draft'"/>
                <button name="action_cancel" type="object"
                    string="Cancelar"
                    invisible="state not in ['draft', 'confirmed']"/>
                <field name="state" widget="statusbar"
                    statusbar_visible="draft,confirmed,done"/>
            </header>
            <sheet>
                <group>
                    <group>
                        <field name="name"/>
                        <!-- v18: required/invisible/readonly directos -->
                        <field name="partner_id"
                            required="state == 'confirmed'"/>
                        <field name="date"/>
                    </group>
                    <group>
                        <field name="user_id"/>
                        <field name="amount_total"
                            invisible="state == 'draft'"/>
                    </group>
                </group>
                <notebook>
                    <page string="Líneas">
                        <field name="line_ids">
                            <list editable="bottom">
                                <field name="sequence" widget="handle"/>
                                <field name="name"/>
                                <field name="quantity"/>
                                <field name="price_unit"/>
                                <field name="amount"/>
                            </list>
                        </field>
                    </page>
                    <page string="Notas">
                        <field name="notes" placeholder="Notas internas..."/>
                    </page>
                </notebook>
            </sheet>
            <chatter/>
        </form>
    </field>
</record>
```

## Vista List (v18) — `list` en lugar de `tree`

```xml
<record id="view_my_model_list" model="ir.ui.view">
    <field name="name">my.model.list</field>
    <field name="model">my.model</field>
    <field name="arch" type="xml">
        <!-- v18: usar "list" (tree también funciona pero list es el estándar) -->
        <list string="My Models"
              decoration-info="state == 'draft'"
              decoration-success="state == 'done'"
              decoration-danger="state == 'cancel'">
            <field name="name"/>
            <field name="partner_id"/>
            <field name="date"/>
            <field name="amount_total" sum="Total"/>
            <field name="state"/>
        </list>
    </field>
</record>
```

## Vista Search (v18)

```xml
<record id="view_my_model_search" model="ir.ui.view">
    <field name="name">my.model.search</field>
    <field name="model">my.model</field>
    <field name="arch" type="xml">
        <search>
            <field name="name" string="Nombre/Ref"
                filter_domain="['|', ('name', 'ilike', self), ('ref', 'ilike', self)]"/>
            <field name="partner_id"/>
            <filter name="my_records" string="Mis Registros"
                domain="[('user_id', '=', uid)]"/>
            <filter name="draft" string="Borrador"
                domain="[('state', '=', 'draft')]"/>
            <group expand="0" string="Agrupar por">
                <filter name="group_partner" string="Cliente"
                    context="{'group_by': 'partner_id'}"/>
                <filter name="group_state" string="Estado"
                    context="{'group_by': 'state'}"/>
            </group>
        </search>
    </field>
</record>
```

## Herencia de modelo (v18)

```python
from odoo import fields, models


class ResPartner(models.Model):
    _inherit = 'res.partner'

    # Extender modelo existente con nuevos campos
    custom_field = fields.Char(string='Campo Custom')
    category_ids_custom = fields.Many2many(
        'partner.category',
        string='Categorías Extra',
    )
```

## Herencia de vista (v18)

```xml
<record id="view_partner_form_inherit_my_module" model="ir.ui.view">
    <field name="name">res.partner.form.inherit.my_module</field>
    <field name="model">res.partner</field>
    <field name="inherit_id" ref="base.view_partner_form"/>
    <field name="arch" type="xml">
        <!-- Agregar campo después de otro campo existente -->
        <field name="phone" position="after">
            <field name="custom_field"/>
        </field>
    </field>
</record>
```

## Wizard (v18)

```python
from odoo import api, fields, models
from odoo.exceptions import UserError


class MyWizard(models.TransientModel):
    _name = 'my.wizard'
    _description = 'Asistente de proceso'

    record_ids = fields.Many2many(
        'my.model',
        string='Registros a procesar',
    )
    reason = fields.Text(string='Motivo', required=True)
    date_process = fields.Date(
        string='Fecha de proceso',
        default=fields.Date.today,
        required=True,
    )

    @api.model
    def default_get(self, fields_list: list[str]) -> dict:
        result = super().default_get(fields_list)
        active_ids = self.env.context.get('active_ids', [])
        if active_ids:
            result['record_ids'] = active_ids
        return result

    def action_process(self) -> dict:
        if not self.record_ids:
            raise UserError("Seleccione al menos un registro.")
        self.record_ids.write({
            'state': 'confirmed',
            'date': self.date_process,
        })
        return {'type': 'ir.actions.act_window_close'}
```

## Estructura de directorios (v18)

```
my_module/
├── __init__.py
├── __manifest__.py
├── models/
│   ├── __init__.py
│   ├── my_model.py
│   └── my_model_line.py
├── views/
│   ├── my_model_views.xml
│   └── menuitems.xml
├── wizards/
│   ├── __init__.py
│   ├── my_wizard.py
│   └── my_wizard_views.xml
├── security/
│   ├── my_module_security.xml
│   └── ir.model.access.csv
├── data/
│   └── my_module_data.xml
├── report/
│   ├── my_report.xml
│   └── my_report_template.xml
└── static/
    └── src/
        ├── js/
        ├── xml/
        └── scss/
```
