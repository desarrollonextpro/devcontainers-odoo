# Odoo Module Generator - Version 17.0

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  ODOO 17.0 MODULE GENERATION PATTERNS                                        ║
║  Version: 17.0.X.X.X | invisible/readonly directos (sin attrs={})           ║
║  Sin states en botones | OWL 2.x para componentes JS                         ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

## __manifest__.py Template (v17)

```python
# -*- coding: utf-8 -*-
{
    'name': '{Module Title}',
    'version': '17.0.1.0.0',
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

## Vista Form (v17) — expresiones directas, SIN attrs

```xml
<record id="view_my_model_form" model="ir.ui.view">
    <field name="name">my.model.form</field>
    <field name="model">my.model</field>
    <field name="arch" type="xml">
        <form string="My Model">
            <header>
                <!-- v17: invisible en lugar de states -->
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
                        <!-- v17: required/invisible directos -->
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

## Vista List (v17) — `list` en lugar de `tree`

```xml
<record id="view_my_model_list" model="ir.ui.view">
    <field name="name">my.model.list</field>
    <field name="model">my.model</field>
    <field name="arch" type="xml">
        <!-- v17: se puede usar "list" o "tree" (ambos válidos) -->
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

## Vista Search (v17)

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
