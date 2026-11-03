---
layout: home

hero:
  name: "Layout Management"
  text: "Tables and forms users lay out themselves and save as variants."
  image:
    src: /favicon.png
    alt: abap2UI5
  actions:
    - theme: brand
      text: Get started
      link: /guide
    - theme: alt
      text: GitHub
      link: https://github.com/abap2UI5-addons/layout-management
    - theme: alt
      text: All addons
      link: https://abap2ui5-addons.github.io/

features:
  - title: "Generic table and simple form rendering from your data via RTTI"
  - title: "Layout popup: visible columns or fields, order, labels and sorting"
  - title: "Generic mode: hide, reorder and relabel the controls of any view by id"
  - title: "Layout variants persisted in z2ui5_t_11 and z2ui5_t_12 per app (handle01 to handle04)"
  - title: "Default layout loaded automatically at startup"
  - title: "Authorization hook z2ui5_if_layo_auth for shared layouts and deletions"
---

## What it does

layout-management renders an internal table or a structure as a table or a simple form with a settings button. In the layout popup the user picks the visible columns or fields, their order, labels and sorting, and saves the result as a layout variant in the tables z2ui5_t_11 and z2ui5_t_12; the default variant is loaded automatically at the next start. A generic mode personalizes the controls of any view built with the view builder. Use it when you want ALV-like layouts in abap2UI5 apps without building them; other addons such as popups build on it.

## Requirements

- abap2UI5
- ABAP Cloud (S/4 Public Cloud, BTP ABAP Environment), S/4 Private Cloud or On-Premise, or NetWeaver 7.50 or higher
- NetWeaver 7.02 - 7.40 with the downported branch 702

## Installation

With [abapGit](https://abapgit.org), from [the repository](https://github.com/abap2UI5-addons/layout-management):

- Install with abapGit in this order: 1. abap2UI5, 2. this repository from the branch that fits your system
- Branch main for ABAP Cloud, S/4HANA and NetWeaver 7.50 or higher; branch 702 for NetWeaver 7.02 - 7.40
- Contains classes and the tables z2ui5_t_11 and z2ui5_t_12 for the layout variants
- Start a sample like any abap2UI5 app, e.g. ?app_start=z2ui5_cl_layo_sample_01

The [Guide](/guide) has every step.

## A first app

```abap
" in check_on_init( ) - once
mo_layout = z2ui5_cl_layo_manager=>factory_generic( handle01 = `ZCL_MY_APP`
                                                    handle02 = `MAIN_VIEW` ).
mo_layout->register( id = `inpName` label = `Name` ).
mo_layout->register( id = `btnSave` label = `Save` ).
mo_layout->register( id = `lstNotes` label = `Notes` label_attr = `headerText` ).

" in the view - the settings button, then the layout applied to the XML
z2ui5_cl_layo_pop=>render_layout_function( xml    = header
                                           client = client
                                           layout = mo_layout ).
...
client->view_display( z2ui5_cl_layo_xml_builder=>xml_apply_layout( i_xml    = view->stringify( )
                                                                     i_layout = mo_layout ) ).
```

## Links

- [abap2UI5-addons/popups](https://github.com/abap2UI5-addons/popups)
- [abap2UI5](https://github.com/abap2UI5/abap2UI5)
- [The repository](https://github.com/abap2UI5-addons/layout-management) - issues and pull requests welcome
