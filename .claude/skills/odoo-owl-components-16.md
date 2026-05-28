# Odoo OWL 1.x Components — Odoo 16.0

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  OWL 1.x PATTERNS — ODOO 16.0                                                ║
║  useState, useRef, useEnv básicos                                            ║
║  NOTA: v17+ usa OWL 2.x con hooks diferentes                                ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

## Componente Básico OWL 1.x

```javascript
/** @odoo-module **/
import { Component, useState, useRef } from "@odoo/owl";
import { registry } from "@web/core/registry";

class MyWidget extends Component {
    setup() {
        this.state = useState({
            isLoading: false,
            value: this.props.value || "",
        });
        this.inputRef = useRef("myInput");
    }

    onButtonClick() {
        this.state.isLoading = true;
        // lógica...
        this.state.isLoading = false;
    }

    get displayValue() {
        return this.state.value.toUpperCase();
    }
}

MyWidget.template = "my_module.MyWidget";
MyWidget.props = {
    value: { type: String, optional: true },
    onChange: { type: Function, optional: true },
};

// Registrar como widget de campo
registry.category("fields").add("my_widget", MyWidget);
```

## Template XML (OWL 1.x)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<templates xml:space="preserve">
    <t t-name="my_module.MyWidget" owl="1">
        <div class="o_my_widget">
            <t t-if="state.isLoading">
                <span class="fa fa-spinner fa-spin"/>
            </t>
            <t t-else="">
                <input t-ref="myInput"
                    t-att-value="state.value"
                    t-on-input="ev => state.value = ev.target.value"
                    class="o_input"/>
                <button t-on-click="onButtonClick"
                    class="btn btn-primary btn-sm">
                    <t t-esc="displayValue"/>
                </button>
            </t>
        </div>
    </t>
</templates>
```

## Componente con RPC (v16)

```javascript
/** @odoo-module **/
import { Component, useState, onWillStart } from "@odoo/owl";
import { useService } from "@web/core/utils/hooks";

class MyDataComponent extends Component {
    setup() {
        this.rpc = useService("rpc");
        this.notification = useService("notification");

        this.state = useState({
            records: [],
            isLoading: true,
        });

        onWillStart(async () => {
            await this.loadData();
        });
    }

    async loadData() {
        try {
            const result = await this.rpc("/web/dataset/call_kw", {
                model: "my.model",
                method: "search_read",
                args: [[["state", "=", "confirmed"]]],
                kwargs: {
                    fields: ["name", "partner_id", "amount_total"],
                    limit: 20,
                },
            });
            this.state.records = result;
        } catch (error) {
            this.notification.add("Error al cargar datos", { type: "danger" });
        } finally {
            this.state.isLoading = false;
        }
    }
}

MyDataComponent.template = "my_module.MyDataComponent";
```

## Field Widget Personalizado (v16)

```javascript
/** @odoo-module **/
import { registry } from "@web/core/registry";
import { standardFieldProps } from "@web/views/fields/standard_field_props";
import { Component } from "@odoo/owl";

class ColorPickerField extends Component {
    get colors() {
        return ["#FF0000", "#00FF00", "#0000FF", "#FFFF00", "#FF00FF"];
    }

    selectColor(color) {
        this.props.update(color);
    }
}

ColorPickerField.template = "my_module.ColorPickerField";
ColorPickerField.props = {
    ...standardFieldProps,
};

registry.category("fields").add("color_picker", ColorPickerField);
```

## Registrar en assets (manifest)

```python
'assets': {
    'web.assets_backend': [
        'my_module/static/src/components/my_widget/my_widget.js',
        'my_module/static/src/components/my_widget/my_widget.xml',
        'my_module/static/src/components/my_widget/my_widget.scss',
    ],
},
```

## Diferencias con OWL 2.x (v17+)

| Aspecto | OWL 1.x (v16) | OWL 2.x (v17+) |
|---------|--------------|----------------|
| Estado | `useState({})` | `useState({})` (igual) |
| Ciclo de vida | `onWillStart`, `onMounted` | `onWillStart`, `onMounted` (igual) |
| Refs | `useRef("name")` → `this.ref.el` | `useRef("name")` (similar) |
| Template attr | `owl="1"` en `<t t-name>` | Sin `owl="1"` necesario |
| Component class | Sí hereda de `Component` | Sí hereda de `Component` |
| Hooks propios | Básicos | `useComponent`, más hooks |
