---
title: Select-options or abap-cloud-gui?
description: When to use the select-options of layout-management and when abap-cloud-gui - two addons of abap2UI5 that both have select-options and variants.
---

# Select-options or abap-cloud-gui?

Both addons have select-options and variants. They are built for different
apps.

**The select-options of layout-management** (`z2ui5_cl_layo_filter`) are a building
block for an abap2UI5 app you build yourself: your own view, your own table -
and a filter for it. The filter fields come from a table or your data, at
runtime; your app does the rest.

**[abap-cloud-gui](https://abap2ui5-addons.github.io/abap-cloud-gui/)** is an
app that works like a classic report: a selection screen with `PARAMETERS`,
`SELECT-OPTIONS`, radio buttons, blocks and event blocks, then a list or an
ALV - written like a report, or converted from one with report2UI5.

| Question | Use |
|---|---|
| Do I build the UI5 app myself and only need filters? | select-options |
| Are the filter fields known only at runtime (any table)? | select-options |
| Do I filter a table the user already sees? | select-options, as a popup |
| Does the app work like a report (selection, then output)? | abap-cloud-gui |
| Do I need `MODIF ID`, `AT SELECTION-SCREEN`, radio buttons, F4? | abap-cloud-gui |
| Does the report exist already in SAP GUI? | abap-cloud-gui, converted with report2UI5 |

Typical for the select-options: data browsers, generic table apps, list apps
with a Filter button. Typical for abap-cloud-gui: evaluations, mass changes,
admin and tool reports - whatever is a Z report with a transaction today.

::: info Formerly range-filter
The select-options were the addon `range-filter` (before that
`selection-screen`) until they moved into layout-management in 2026-11. The
classes are named `z2ui5_cl_layo_*` now, the table `z2ui5_t_13` kept its name;
the [guide](./guide#coming-from-range-filter-or-popups) says what changes for an
installation.
:::
