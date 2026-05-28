# Odoo Module Generator - Version 16.0

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  ODOO 16.0 MODULE GENERATION PATTERNS                                        ║
║  Version: 16.0.X.X.X | attrs={} para visibilidad                            ║
║  states en botones | OWL 1.x para componentes JS                            ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

## __manifest__.py Template (v16)

```python
# -*- coding: utf-8 -*-
{
    'name': '{Module Title}',
    'version': '16.0.1.0.0',
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
        # ORDER IS CRITICAL
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

## Vista Form (v16) — usa attrs={}

```xml
<record id="view_my_model_form" model="ir.ui.view">
    <field name="name">my.model.form</field>
    <field name="model">my.model</field>
    <field name="arch" type="xml">
        <form string="My Model">
            <header>
                <!-- v16: states en botones -->
                <button name="action_confirm" type="object"
                    string="Confirmar" class="btn-primary"
                    states="draft"/>
                <button name="action_cancel" type="object"
                    string="Cancelar"
                    states="draft,confirmed"/>
                <field name="state" widget="statusbar"
                    statusbar_visible="draft,confirmed,done"/>
            </header>
            <sheet>
                <group>
                    <group>
                        <field name="name"/>
                        <!-- v16: attrs para visibilidad/requerido -->
                        <field name="partner_id"
                            attrs="{'required': [('state', '=', 'confirmed')]}"/>
                        <field name="date"/>
                    </group>
                    <group>
                        <field name="user_id"/>
                        <!-- v16: attrs invisible con domain list -->
                        <field name="amount_total"
                            attrs="{'invisible': [('state', '=', 'draft')]}"/>
                    </group>
                </group>
                <notebook>
                    <page string="Líneas">
                        <field name="line_ids">
                            <tree editable="bottom">
                                <field name="sequence" widget="handle"/>
                                <field name="name"/>
                                <field name="quantity"/>
                                <field name="price_unit"/>
                                <field name="amount"/>
                            </tree>
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

## Vista Tree/List (v16)

```xml
<record id="view_my_model_tree" model="ir.ui.view">
    <field name="name">my.model.tree</field>
    <field name="model">my.model</field>
    <field name="arch" type="xml">
        <tree string="My Models" decoration-info="state == 'draft'"
              decoration-success="state == 'done'"
              decoration-danger="state == 'cancel'">
            <field name="name"/>
            <field name="partner_id"/>
            <field name="date"/>
            <field name="amount_total" sum="Total"/>
            <field name="state"/>
        </tree>
    </field>
</record>
```

## Vista Search (v16)

```xml
<record id="view_my_model_search" model="ir.ui.view">
    <field name="name">my.model.search</field>
    <field name="model">my.model</field>
    <field name="arch" type="xml">
        <search>
            <field name="name" string="Nombre/Ref" filter_domain="
                ['|', ('name', 'ilike', self), ('ref', 'ilike', self)]"/>
            <field name="partner_id"/>
            <filter name="my_records" string="Mis Registros"
                domain="[('user_id', '=', uid)]"/>
            <filter name="draft" string="Borrador"
                domain="[('state', '=', 'draft')]"/>
            <separator/>
            <filter name="date_today" string="Hoy"
                domain="[('date', '=', context_today().strftime('%Y-%m-%d'))]"/>
            <group expand="0" string="Agrupar por">
                <filter name="group_partner" string="Cliente"
                    context="{'group_by': 'partner_id'}"/>
                <filter name="group_state" string="Estado"
                    context="{'group_by': 'state'}"/>
                <filter name="group_date" string="Fecha"
                    context="{'group_by': 'date:month'}"/>
            </group>
        </search>
    </field>
</record>
```

## Action y Menú

```xml
<record id="action_my_model" model="ir.actions.act_window">
    <field name="name">My Models</field>
    <field name="res_model">my.model</field>
    <field name="view_mode">tree,form</field>
    <field name="context">{'search_default_my_records': 1}</field>
    <field name="help" type="html">
        <p class="o_view_nocontent_smiling_face">
            Crea tu primer registro
        </p>
    </field>
</record>

<menuitem id="menu_my_module_root"
    name="Mi Módulo"
    sequence="10"/>
<menuitem id="menu_my_model"
    name="My Models"
    parent="menu_my_module_root"
    action="action_my_model"
    sequence="10"/>
```

## Estructura de Carpetas

```
my_module/
├── __init__.py
├── __manifest__.py
├── models/
│   ├── __init__.py
│   └── my_model.py
├── views/
│   ├── my_model_views.xml
│   └── menuitems.xml
├── security/
│   ├── my_module_security.xml
│   └── ir.model.access.csv
├── data/
│   └── my_model_data.xml       (datos iniciales opcionales)
├── wizard/
│   ├── __init__.py
│   └── my_wizard.py
└── static/
    └── src/
        └── (componentes OWL si necesario)
```
