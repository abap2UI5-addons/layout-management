[![ABAP_STANDARD](https://github.com/abap2UI5-addons/layout-variant-management/actions/workflows/ABAP_STANDARD.yaml/badge.svg)](https://github.com/abap2UI5-addons/layout-variant-management/actions/workflows/ABAP_STANDARD.yaml)
[![ABAP_CLOUD](https://github.com/abap2UI5-addons/layout-variant-management/actions/workflows/ABAP_CLOUD.yaml/badge.svg)](https://github.com/abap2UI5-addons/layout-variant-management/actions/workflows/ABAP_CLOUD.yaml)
<br>
[![auto_rename](https://github.com/abap2UI5-addons/layout-variant-management/actions/workflows/rename_test.yaml/badge.svg)](https://github.com/abap2UI5-addons/layout-variant-management/actions/workflows/rename_test.yaml)

# layout-management
An addon for customizable table and form layouts with persistent variant management.

#### Key Features
- **Generic Output** - Universal table and form rendering
- **Layout Customization** - Flexible customization of table and form outputs  
- **Variant Persistence** - Save layout variants to database
- **Auto-Loading** - Load default layouts automatically at startup
  
#### Compatibility
* S/4 Public Cloud and BTP ABAP Environment (ABAP for Cloud)
* S/4 Private Cloud or On-Premise (ABAP for Cloud, Standard ABAP)
* R/3 NetWeaver AS ABAP 7.50 or higher (Standard ABAP)

#### Dependencies
* [abap2UI5](https://github.com/abap2UI5/abap2UI5) - nothing else: the addon does not need the abap2UI5 extension ([abap2UI5/frontend](https://github.com/abap2UI5/frontend)). Its views are built with the core's generic builder `z2ui5_cl_ui5_view_builder`, and the few utilities it needs live in its own class `z2ui5_cl_layo_util`.

#### Breaking Change - `z2ui5_cl_layo_xml_builder`
`xml_build_table` and `xml_build_simple_form` take the node to render into as a `z2ui5_cl_ui5_view_builder` (parameter `i_xml`) instead of the legacy `z2ui5_cl_xml_view` of the extension. Build your view with the builder and declare the namespaces the layout may write on its root (`View` or `FragmentDefinition`):

```abap
DATA(view) = z2ui5_cl_ui5_view_builder=>factory(
    )->ele( n = `View` ns = `mvc`
        )->a( n = `xmlns`        v = `sap.m`
        )->a( n = `xmlns:mvc`    v = `sap.ui.core.mvc`
        )->a( n = `xmlns:core`   v = `sap.ui.core`
        )->a( n = `xmlns:form`   v = `sap.ui.layout.form`
        )->a( n = `xmlns:layout` v = `sap.ui.layout`
        )->a( n = `xmlns:mchart` v = `sap.suite.ui.microchart`
        )->a( n = `xmlns:si`     v = `sap.suite.ui.commons.statusindicator` ).

DATA(page) = view->ele( `Shell`
    )->ele( `Page`
        )->a( n = `title` v = `Layout` ).

z2ui5_cl_layo_xml_builder=>xml_build_table( i_data   = REF #( mt_table )
                                            i_xml    = page
                                            i_client = client
                                            i_layout = mo_layout ).

client->view_display( view->stringify( ) ).
```

`xml_build_table` needs `core`, `mchart` and `si`; `xml_build_simple_form` additionally `form` and `layout`. The samples in `src/01` show both.

#### Demo

###### Tables
<img width="700" alt="Google Chrome 2024-09-09 12 14 58" src="https://github.com/user-attachments/assets/5e5f9291-3817-4a66-a886-cd0ac0c6e175">
<img width="700" height="341" alt="image" src="https://github.com/user-attachments/assets/fb2347d8-3ef9-4c33-aaf0-4af419f993b7" />

###### Forms
<img width="700" height="403" alt="image" src="https://github.com/user-attachments/assets/ec161092-7a99-4b99-be36-41866d1a3735" />
<img width="700" height="941" alt="image" src="https://github.com/user-attachments/assets/ec24438e-110c-4061-b7b1-49ab61c98760" />

###### Charts & Indicators
<img width="700" height="367" alt="image" src="https://github.com/user-attachments/assets/023d07da-bf62-44e4-8b6f-e05608150bf8" />
<img width="700" height="427" alt="image" src="https://github.com/user-attachments/assets/75eedb06-6c24-48c3-b0ab-f0a66dbd625e" />


###### Persistence
<img width="700" alt="Google Chrome 2024-09-09 12 15 32" src="https://github.com/user-attachments/assets/d7f39663-d864-4737-89e4-8e925e54bc2d">

#### Contribution & Support
We welcome contributions! Whether you're:
- 🐛 Fixing bugs
- ✨ Adding new features  
- 📚 Improving documentation
- 🧪 Writing tests

Please feel free to open a pull request or issue.
