![ABAP](https://img.shields.io/badge/ABAP-NW%207.02%20%E2%86%92%20Cloud-blue)
[![namespace](https://img.shields.io/badge/namespace-z2ui5__cl__layo-blue)](abaplint.jsonc)
[![dependency](https://img.shields.io/badge/dependency-abap2UI5-blue)](https://github.com/abap2UI5/abap2UI5)
[![abap2UI5](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fabap2UI5-addons%2Flayout-management%2Fbadges%2Fabap2ui5.json)](https://github.com/abap2UI5-addons/layout-management/actions/workflows/check-abap2ui5.yaml)
<br><br>
[![abap-standard](https://github.com/abap2UI5-addons/layout-management/actions/workflows/abap-standard.yaml/badge.svg)](https://github.com/abap2UI5-addons/layout-management/actions/workflows/abap-standard.yaml)
[![abap-cloud](https://github.com/abap2UI5-addons/layout-management/actions/workflows/abap-cloud.yaml/badge.svg)](https://github.com/abap2UI5-addons/layout-management/actions/workflows/abap-cloud.yaml)
[![abap-702](https://github.com/abap2UI5-addons/layout-management/actions/workflows/abap-702.yaml/badge.svg)](https://github.com/abap2UI5-addons/layout-management/actions/workflows/abap-702.yaml)
<br>
[![check-abap2UI5](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fabap2UI5-addons%2Flayout-management%2Fbadges%2Fcheck-abap2ui5.json)](https://github.com/abap2UI5-addons/layout-management/actions/workflows/check-abap2ui5.yaml)
[![check-rename](https://github.com/abap2UI5-addons/layout-management/actions/workflows/check-rename.yaml/badge.svg)](https://github.com/abap2UI5-addons/layout-management/actions/workflows/check-rename.yaml)
<br>
[![publish-702](https://github.com/abap2UI5-addons/layout-management/actions/workflows/publish-702.yaml/badge.svg)](https://github.com/abap2UI5-addons/layout-management/actions/workflows/publish-702.yaml)

# layout-management
An addon for customizable table and form layouts with persistent variant management.

#### Key Features
* **Generic Output** - Universal table and form rendering
* **Layout Customization** - Flexible customization of table and form outputs
* **Variant Persistence** - Save layout variants to database
* **Auto-Loading** - Load default layouts automatically at startup

#### Compatibility
* S/4 Public Cloud and BTP ABAP Environment (ABAP for Cloud)
* S/4 Private Cloud or On-Premise (ABAP for Cloud, Standard ABAP)
* SAP NetWeaver AS ABAP 7.50 or higher (Standard ABAP)

#### Security
This library persists layout variants to its own database tables and has no authorization check of its own for who may create, edit or read layouts. Add your own checks if that matters in your scenario.

#### Dependencies
* [abap2UI5](https://github.com/abap2UI5/abap2UI5)

#### Demo

###### Tables
<img width="700" alt="Table output with layout customization popup" src="https://github.com/user-attachments/assets/5e5f9291-3817-4a66-a886-cd0ac0c6e175">
<img width="700" height="241" alt="Table output rendered with a customized layout" src="https://github.com/user-attachments/assets/fb2347d8-3ef9-4c33-aaf0-4af419f993b7" />

###### Forms
<img width="700" height="203" alt="Simple form output rendered with a customized layout" src="https://github.com/user-attachments/assets/ec161092-7a99-4b99-be36-41866d1a3735" />
<img width="700" height="441" alt="Form layout customization popup with label and value spans" src="https://github.com/user-attachments/assets/ec24438e-110c-4061-b7b1-49ab61c98760" />

###### Charts & Indicators
<img width="700" height="167" alt="Table with chart and indicator columns" src="https://github.com/user-attachments/assets/023d07da-bf62-44e4-8b6f-e05608150bf8" />
<img width="700" height="227" alt="Form with progress indicator, radial chart and status indicator" src="https://github.com/user-attachments/assets/75eedb06-6c24-48c3-b0ab-f0a66dbd625e" />


###### Persistence
<img width="700" alt="Popup for saving and selecting persisted layout variants" src="https://github.com/user-attachments/assets/d7f39663-d864-4737-89e4-8e925e54bc2d">

#### Contribution & Support
Pull requests are welcome! Whether you're fixing bugs, adding new functionality, or improving documentation, your contributions are highly appreciated. If you encounter any issues, feel free to open an issue.
