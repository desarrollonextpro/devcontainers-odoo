# Odoo OWL 2.x Components — Odoo 17.0

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  OWL 2.x PATTERNS — ODOO 17.0 / 18.0                                        ║
║  useState, useEnv, useService, hooks modernos                                ║
║  onWillStart, onMounted, onWillUnmount                                       ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

## Componente Básico OWL 2.x

```javascript
/** @odoo-module **/
import { Component, useState, useRef, onMounted, onWillUnmount } from "@odoo/owl";
import { registry } from "@web/core/registry";
import { useService } from "@web/core/utils/hooks";

class MyWidget extends Component {
    setup() {
        this.orm = useService("orm");
        this.notification = useService("notification");
        this.action = useService("action");

        this.state = useState({
            isLoading: false,
            value: this.props.value || "",
            records: [],
        });

        this.inputRef = useRef("myInput");

        onMounted(() => {
            // DOM disponible
            if (this.inputRef.el) {
                this.inputRef.el.focus();
            }
        });

        onWillUnmount(() => {
            // Cleanup si es necesario
        });
    }

    async onButtonClick() {
        this.state.isLoading = true;
        try {
            const result = await this.orm.call(
                "my.model",
                "my_method",
                [[this.props.recordId]],
                {}
            );
            this.notification.add("Operación exitosa", { type: "success" });
        } catch (error) {
            this.notification.add("Error en operación", { type: "danger" });
        } finally {
            this.state.isLoading = false;
        }
    }
}

MyWidget.template = "my_module.MyWidget";
MyWidget.props = {
    value: { type: String, optional: true },
    recordId: { type: Number, optional: true },
    onChange: { type: Function, optional: true },
};
```

## ORM Service (v17) — reemplaza RPC directo

```javascript
/** @odoo-module **/
import { Component, useState, onWillStart } from "@odoo/owl";
import { useService } from "@web/core/utils/hooks";

class MyDataComponent extends Component {
    setup() {
        this.orm = useService("orm");

        this.state = useState({
            records: [],
            isLoading: true,
        });

        onWillStart(async () => {
            await this.loadRecords();
        });
    }

    async loadRecords() {
        // v17: orm.searchRead (más limpio que RPC directo)
        this.state.records = await this.orm.searchRead(
            "my.model",
            [["state", "=", "confirmed"]],
            ["name", "partner_id", "amount_total"],
            { limit: 20, order: "date desc" }
        );
        this.state.isLoading = false;
    }

    async createRecord(values) {
        const id = await this.orm.create("my.model", [values]);
        await this.loadRecords();
        return id;
    }

    async updateRecord(id, values) {
        await this.orm.write("my.model", [id], values);
        await this.loadRecords();
    }

    async deleteRecord(id) {
        await this.orm.unlink("my.model", [id]);
        await this.loadRecords();
    }
}
```

## Template XML (OWL 2.x)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<templates xml:space="preserve">
    <!-- v17+: sin owl="1" en el t-name -->
    <t t-name="my_module.MyWidget">
        <div class="o_my_widget">
            <t t-if="state.isLoading">
                <span class="fa fa-spinner fa-spin me-1"/>
                <span>Cargando...</span>
            </t>
            <t t-else="">
                <div class="d-flex align-items-center gap-2">
                    <input t-ref="myInput"
                        class="o_input"
                        t-att-value="state.value"
                        t-on-input="ev => state.value = ev.target.value"/>
                    <button class="btn btn-primary btn-sm"
                        t-on-click="onButtonClick">
                        Guardar
                    </button>
                </div>
                <ul class="list-group mt-2">
                    <t t-foreach="state.records" t-as="record" t-key="record.id">
                        <li class="list-group-item d-flex justify-content-between">
                            <span t-esc="record.name"/>
                            <span class="badge bg-primary" t-esc="record.amount_total"/>
                        </li>
                    </t>
                </ul>
            </t>
        </div>
    </t>
</templates>
```

## Field Widget Personalizado (v17)

```javascript
/** @odoo-module **/
import { registry } from "@web/core/registry";
import { standardFieldProps } from "@web/views/fields/standard_field_props";
import { Component, useState } from "@odoo/owl";

class StarRatingField extends Component {
    setup() {
        this.state = useState({ hovered: 0 });
    }

    setRating(value) {
        this.props.update(value);
    }

    get stars() {
        return [1, 2, 3, 4, 5];
    }
}

StarRatingField.template = "my_module.StarRatingField";
StarRatingField.props = {
    ...standardFieldProps,
};
StarRatingField.supportedTypes = ["integer"];

registry.category("fields").add("star_rating", StarRatingField);
```

## Diferencias OWL 1.x (v16) vs OWL 2.x (v17+)

| Aspecto | OWL 1.x (v16) | OWL 2.x (v17+) |
|---------|--------------|----------------|
| Template attr | `owl="1"` obligatorio | Sin `owl="1"` |
| RPC | `useService("rpc")` + URL | `useService("orm")` |
| Buscar records | `rpc("/web/dataset/call_kw", ...)` | `orm.searchRead(...)` |
| Crear records | `rpc` con method `create` | `orm.create(...)` |
