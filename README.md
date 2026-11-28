# layout-management

[![abap2UI5-addons](https://img.shields.io/badge/abap2UI5--addons-library-1873b4)](https://github.com/abap2UI5-addons)
[![ABAP](https://img.shields.io/badge/ABAP-Cloud%20%7C%20Standard%20%E2%89%A5%207.50%20%7C%207.02-blue)](#installation)
[![abap2UI5](https://img.shields.io/badge/requires-abap2UI5-blue)](https://github.com/abap2UI5/abap2UI5)
[![License](https://img.shields.io/github/license/abap2UI5-addons/layout-management)](LICENSE)
<br>
[![CI](https://img.shields.io/github/actions/workflow/status/abap2UI5-addons/layout-management/ci.yaml?branch=main&label=CI)](https://github.com/abap2UI5-addons/layout-management/actions/workflows/ci.yaml)
[![ABAP 7.02](https://img.shields.io/github/actions/workflow/status/abap2UI5-addons/layout-management/ci-702.yaml?branch=main&label=ABAP%207.02)](https://github.com/abap2UI5-addons/layout-management/actions/workflows/ci-702.yaml)
[![check-abap2UI5](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fabap2UI5-addons%2Flayout-management%2Fbadges%2Fcheck-abap2ui5.json)](https://github.com/abap2UI5-addons/layout-management/actions/workflows/ci.yaml)
[![abap2UI5](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fabap2UI5-addons%2Flayout-management%2Fbadges%2Fabap2ui5.json)](https://github.com/abap2UI5-addons/layout-management/actions/workflows/ci.yaml)

**Tables and forms in your abap2UI5 apps that users can lay out themselves - and save as variants.**
You hand over an internal table or a structure; layout-management renders it
as a table or a simple form with a settings button. There the user picks the
visible columns or fields, their order, labels and sorting, and saves the
result as a layout variant in the database - the default variant is loaded
automatically the next time the app starts. The same for what the user
selects: select-options for every field of a table, with the selection saved
as a variant. For developers of abap2UI5 apps who want ALV-like layouts and
selection variants without building them.

> Part of [abap2UI5-addons](https://github.com/abap2UI5-addons) - addons and apps for [abap2UI5](https://github.com/abap2UI5/abap2UI5), installed with [abapGit](https://abapgit.org). Documentation: [abap2ui5-addons.github.io/layout-management](https://abap2ui5-addons.github.io/layout-management/).

## Why

Users are used to ALV layouts: hide a column, move it, sort, save the setup
and get it back tomorrow. In a hand-written UI5 view every column is fixed in
the code, and each app would have to build layout dialogs and their
persistence on its own.

layout-management does that once. It builds the table or form from your data
via RTTI, offers the layout popup, and stores the variants per app in its own
tables (`z2ui5_t_11`, `z2ui5_t_12`). Other addons build on it - for example
the value and search helps of
[abap2UI5-addons/popups](https://github.com/abap2UI5-addons/popups), the data
browser [abap2UI5-addons/se16n](https://github.com/abap2UI5-addons/se16n) and
[abap2UI5-addons/table-maintenance](https://github.com/abap2UI5-addons/table-maintenance).

The selection is the other half of what a report gets for free in SAP GUI:
`SELECT-OPTIONS` and their variants. The select-options here
(`z2ui5_cl_layo_filter`, `z2ui5_cl_layo_pop_*`) are built from a table name or
your data, render inline in your page or as a filter popup, and keep their
variants in the table `z2ui5_t_13`. They were the addon
[range-filter](https://github.com/abap2UI5-addons/range-filter) until 2026-11,
and the two range popups were part of
[popups](https://github.com/abap2UI5-addons/popups) - see
[Coming from range-filter or popups](#coming-from-range-filter-or-popups).

## Installation

**Requirements**

- ABAP Cloud (S/4 Public Cloud, BTP ABAP Environment), S/4 Private Cloud or
  On-Premise, or SAP NetWeaver AS ABAP 7.50 or higher; NetWeaver 7.02 with the
  downported branch `702`
- [abap2UI5](https://github.com/abap2UI5/abap2UI5) - nothing else

Earlier versions also needed [abap2UI5-ext](https://github.com/abap2UI5/abap2UI5-ext)
for the legacy `z2ui5_cl_util`; this one carries its own utility class
(`z2ui5_cl_layo_context`). A system that has abap2UI5-ext keeps it - nothing
collides - and can drop it once no other code of its own uses it.

**Steps** - with [abapGit](https://abapgit.org), in this order:

1. [abap2UI5](https://github.com/abap2UI5/abap2UI5)
2. this repository, from the branch that fits your system - classes, the
   two tables `z2ui5_t_11` / `z2ui5_t_12` for the layout variants and the
   table `z2ui5_t_13` for the selection variants:

| System | Branch to pull |
|---|---|
| ABAP Cloud, S/4HANA, NetWeaver 7.50 or higher | `main` |
| NetWeaver 7.02 - 7.40 | `702` (downported automatically from `main`) |

**Start** - run a sample like any abap2UI5 app, e.g.
`?app_start=z2ui5_cl_layo_sample_01` for a table with icons, charts and
indicators. All samples are listed under [Samples](#samples).

### Coming from range-filter or popups

The select-options of
[abap2UI5-addons/range-filter](https://github.com/abap2UI5-addons/range-filter)
live here now, under this addon's names, and the two range popups of
[abap2UI5-addons/popups](https://github.com/abap2UI5-addons/popups) are merged
into them - each popup exists once:

| Before | Now |
|---|---|
| `z2ui5_cl_sel_multisel` (range-filter) | `z2ui5_cl_layo_filter` |
| `z2ui5_cl_sel_multisel_pop` (range-filter), `z2ui5_cl_popup_get_ranges` (popups) | `z2ui5_cl_layo_pop_filter` - `factory( filter )` without, `factory_by_data( )` with selection variants |
| `z2ui5_cl_sel_range_pop` (range-filter), `z2ui5_cl_popup_get_range` (popups) | `z2ui5_cl_layo_pop_range` |
| `z2ui5_cl_sel_var_pop_read`, `z2ui5_cl_sel_var_pop_save` | `z2ui5_cl_layo_pop_varread`, `z2ui5_cl_layo_pop_varsave` |
| `z2ui5_cl_sel_var_db` | `z2ui5_cl_layo_var_db` |
| `z2ui5_cl_sel_context`, `z2ui5_cx_sel_error` | `z2ui5_cl_layo_context`, `z2ui5_cx_layo_error` - the same methods (`filter_get_sql_where( )`, `filter_itab( )`, ...) |
| `z2ui5_cl_sel_sample_01`, `_02` | `z2ui5_cl_layo_sample_08`, `_09` |

A caller replaces the class name and nothing else: `factory( )`, `result( )`
and its components `check_confirmed`, `t_filter` and `t_range` are the same.
The two popups of popups no longer implement `z2ui5_if_popup_result`.

The table `z2ui5_t_13` keeps its name, so the saved selection variants stay.
In a system that has range-filter installed, remove the range-filter
repository from abapGit **without uninstalling it** - an uninstall deletes
`z2ui5_t_13` and the variants in it -, move `z2ui5_t_13` to the package of
`src/02`, pull this repository, and delete the `z2ui5_cl_sel_*` classes once
nothing of your own uses them.

### Parallel installation (namespace rename)

To run a second copy next to the original in the same system, rename it the
way abap2UI5 itself is renamed: run the workflow **build-rename** (Actions →
build-rename → Run workflow) with the name your abap2UI5 installation was
renamed to - e.g. `ZMYUI5` or `/CA2UI5/`. It pushes the branch `rename_<name>`, in
which every object and every reference to abap2UI5 and to the addons this one
needs carries that name; pull it with abapGit. Rename abap2UI5 and every addon
of the installation with the same name.

## Usage

Create a layout manager for your data, let `z2ui5_cl_layo_xml_builder` render
it into your view and pass the events on to `z2ui5_cl_layo_pop` - it opens the
layout popup when the user presses the settings button:

```abap
" DATA mt_table  TYPE ty_t_table.                    " your rows
" DATA mo_layout TYPE REF TO z2ui5_cl_layo_manager.

METHOD z2ui5_if_app~main.

  IF client->check_on_init( ).
    mo_layout = z2ui5_cl_layo_manager=>factory( control  = z2ui5_cl_layo_manager=>m_table
                                                data     = REF #( mt_table )
                                                handle01 = `ZCL_MY_APP` ).
    render( client ).

  ELSEIF client->check_on_navigated( ).
    " back from the layout popup - take over the chosen layout (on any other
    " navigation, e.g. a restored draft, take_over( ) does nothing)
    z2ui5_cl_layo_pop=>take_over( client = client layout = mo_layout ).
    render( client ).

  ELSE.
    z2ui5_cl_layo_pop=>on_event_layout( client = client
                                        layout = mo_layout ).
  ENDIF.

ENDMETHOD.

METHOD render.
  " view = z2ui5_cl_ui5_view_builder=>factory( ) ... page = view->...->ele( `Page` )
  z2ui5_cl_layo_xml_builder=>xml_build_table( i_data   = REF #( mt_table )
                                              i_xml    = page
                                              i_client = client
                                              i_layout = mo_layout ).
  client->view_display( view->stringify( ) ).
ENDMETHOD.
```

- `control` is `z2ui5_cl_layo_manager=>m_table` for a table; for a form, use
  `z2ui5_cl_layo_manager=>ui_simpleform`, pass a structure and render it with
  `z2ui5_cl_layo_xml_builder=>xml_build_simple_form( )`.
- `handle01` to `handle04` are the keys the variants are saved under - e.g.
  the app class and the table name.
- `z2ui5_cl_layo_pop=>take_over( )` copies the layout back from the popup
  when it is the layout passed (same control and handles), so an app with a
  form and a table layout calls it for both. It returns `abap_true` when the
  view has to be rendered again: the popup changed what the view is built
  from (subcolumns), or the roundtrip is no return from the popup at all (a
  restored draft); otherwise the changed model alone shows the change
  (samples 02 to 05).

The samples below are complete apps, `z2ui5_cl_layo_sample_03` is the table
above with the namespaces of the view.

### The table after a roundtrip

The layout keeps a data reference to your table (`factory( data = REF #( mt_table ) )`).
Between two roundtrips abap2UI5 serializes the app into its draft, and a data
reference comes back pointing at a **copy** of the table, not at your
attribute. Hand the table over again in every roundtrip before the layout
works on it - pass it to `sort( )`, `set_selkz( )` and `data_conversion( )`,
or call `set_data( )` once:

```abap
mo_layout->sort( data = REF #( mt_table ) ).
```

### Conversion exits

`data_conversion( output = abap_true )` runs the conversion exits of the
columns over the data for the screen, `data_conversion( output = abap_false )`
back - two calls of a function module per cell and roundtrip. Two of them the
browser does itself: `z2ui5_cl_layo_xml_builder` binds a column with the
conversion exit ALPHA on a CHAR type, and a NUMC column with ALPHA, with the
UI5 type `sap.ui.model.odata.type.String` and `isDigitSequence` -
`000000004711` is shown as `4711`, a value with letters as it is. The data
stays internal:

- NUMC columns are never converted in ABAP - there is no conversion routine
  for them, the view formats them.
- ALPHA columns of CHAR type are still converted by `data_conversion( )`,
  unless the app says that its view formats them - set it once after
  `factory( )`:

  ```abap
  mo_layout->mv_alpha_in_browser = abap_true.
  ```

  Not for an editable ALPHA column: the type refuses a letter in an input,
  so such a column needs the conversion in ABAP.
- Every other exit (`CUNIT`, `MATN1`, ...) is converted by
  `data_conversion( )` as before, and a column whose conversion the user
  switched off in the layout popup is shown as it is.

A view of its own gets the same with `z2ui5_cl_layo_manager=>digit_type( )`
(is the column one of them), `digit_type_binding( )` (its binding) and
`digit_type_require( )` (the `core:require` of the type on the control or a
parent - on UI5 1.71 a type named in a binding is resolved only when its
module is loaded already).

### Table options - header sort, row colour, cell controls

`xml_build_table( )` takes a few optional parameters on top of the ones
above. Each one is off by default: a call without them renders the table
exactly as before.

```abap
z2ui5_cl_layo_xml_builder=>xml_build_table(
    i_data             = REF #( mt_table )
    i_xml              = page
    i_client           = client
    i_layout           = mo_layout
    i_col_sort         = abap_true                " sort by a click on a column header
    i_row_color        = `CELL_COLOR-COLOR`       " data-color on every row
    i_sub_col_controls = abap_true                " controls as subcolumns, stacked in a VBox
    i_t_cell_control   = VALUE #(                 " rollnames of the app -> cell control
        ( rollname = `ZMY_S_TRAFFIC_LIGHT` control = z2ui5_cl_layo_xml_builder=>cs_cell_control-icon )
        ( rollname = `ZMY_*_TOGGLE`        control = z2ui5_cl_layo_xml_builder=>cs_cell_control-switch ) ) ).
```

- **Sorting by the column header** - `i_col_sort = abap_true` makes the
  header of every column a link. A click sorts the table by that column
  through the layout - none, ascending, descending, none again; the column
  clicked last is the only sorted one - and the column shows the order with
  the standard sort icon of `sap.m.Column` (`sortIndicator`, UI5 1.61),
  bound to the layout, so no new view is needed. The event is
  `z2ui5_cl_layo_xml_builder=>cv_event_column_sort`; `on_event_layout( )`
  handles it when it gets the table:

  ```abap
  z2ui5_cl_layo_pop=>on_event_layout( client = client
                                      layout = mo_layout
                                      data   = REF #( mt_table ) ).
  ```

  or, next to other handling, `z2ui5_cl_layo_xml_builder=>on_event_column_sort( )`
  with the same parameters (`abap_true` when it was the event). The sort
  order is saved with the layout like one chosen in the popup. The links
  look like links; `i_col_sort_class` puts a style class of the app on them
  for an app that styles them itself. No CSS comes with the table.
- **Without toolbar** - `i_toolbar = abap_false` leaves the header toolbar
  out: no layout settings button, no search field (`i_search_value` is
  ignored), and `i_headertext` becomes the `headerText` of the table instead
  of a title in the toolbar. For a table whose layout the user does not
  change, or whose settings button sits somewhere else (e.g. a
  `z2ui5_cl_layo_pop=>render_layout_function( )` of the app's own toolbar).
- **Row colour** - `i_row_color` names the field of the row that carries a
  colour key, relative to the row (`COLOR`, or `CELL_COLOR-COLOR` for a
  component of a structured column). Every row gets it as custom data written
  to the DOM - `<tr data-color="red_1">` - and the app's CSS gives the key
  its colour, e.g. `tr[data-color="red_1"] > td { background-color: #FFEAF4; }`.
  The field has to be a string (`writeToDom` writes nothing else).
- **Cell controls** - a column whose rollname (its data element, or for a
  structured column its structure type) is one of the structures below is
  drawn as that control instead of text. The cells bind the components of
  the row; a component the structure does not have is left out, so an
  app's own structure may carry fewer of them:

  | Structure | Control | Components |
  |---|---|---|
  | `z2ui5_xml_s_icon` | `sap.ui.core.Icon` | `SRC`, `ICON_SIZE` (or `SIZE`), and `COLOR`, `PRESS`, `PRESS_VALUE` when the structure has them |
  | `z2ui5_xml_s_generictag` | `sap.m.GenericTag` | `TEXT`, `DESIGN`, `STATUS` |
  | `z2ui5_xml_s_progressind` | `sap.m.ProgressIndicator` | `PERCENTVALUE`, `DISPLAYVALUE`, `SHOWVALUE`, `STATE` |
  | `z2ui5_xml_s_radialchart` | `sap.suite.ui.microchart.RadialMicroChart` | `RADIALMICROCHART_SIZE` (or `SIZE`), `PERCENTAGE`, `VALUECOLOR`, `HIDEONNODATA` |
  | `z2ui5_xml_s_statusind` | `sap.suite.ui.commons.statusindicator.StatusIndicator` | `CLASS`, `STATUSINDICATOR_SIZE` (or `SIZE`), `VALUE`, `FILLCOLOR_GOOD` / `_CRITICAL` / `_ERROR`, `SHAPEID` |
  | `z2ui5_xml_s_switch` | `sap.m.Switch` | `STATE`, `CUSTOMTEXTON`, `CUSTOMTEXTOFF`, `ENABLED`, `TYPE`, `CHANGE` / `CHANGE_VALUE` |
  | `z2ui5_xml_s_input` | `sap.m.Input` | `VALUE`, `PLACEHOLDER`, `ENABLED`, `EDITABLE`, `VISIBLE` |
  | `z2ui5_xml_s_button` | `sap.m.Button` | `TEXT`, `ICON`, `TYPE`, `PRESS` / `PRESS_VALUE` |

  `PRESS` / `CHANGE` hold the **name of the event** of the row and
  `PRESS_VALUE` / `CHANGE_VALUE` its argument - the click sends
  `get( )-event = <PRESS>` and `get_event_arg( ) = <PRESS_VALUE>`. A
  button `TYPE` such as `Critical` or `Success` needs UI5 1.73; on 1.71 the
  value is rejected and the view fails to render. An empty `TYPE` renders
  `Default`. An `Input` cell is bound to the row, so what
  the user types travels back with the table.
- **Cell controls of the app** - the controls are found by the rollname
  pattern `*_XML_S_ICON`, `*_XML_S_SWITCH`, ... (any namespace). An app with
  structures of its own maps them in `i_t_cell_control`: `rollname` is a
  pattern (`CP`), `control` one of `z2ui5_cl_layo_xml_builder=>cs_cell_control`
  (`cs_cell_control-text` draws a matching column as text). The app's
  entries are checked first.
- **Several controls in one cell** - `i_sub_col_controls = abap_true`: a
  subcolumn (chosen in the layout popup) that is a cell control is drawn as
  that control below the value of the column, and a control column shows its
  text subcolumns below the control; a cell with more than one control
  stacks them in a `VBox`. Without it a control column shows the control
  only, and every subcolumn is text.
- `i_sel_event` - the event of `selectionChange`, `SELECTION_CHANGE` when it
  is empty.

### Any view - the generic mode

For a view that is neither a table nor a form, the generic mode personalizes
the controls of the view itself: the user hides them, moves them inside the
aggregation they sit in (the buttons of a toolbar, the inputs of a box) and
renames them. Register the controls by their `id`, build the view as usual
and pass the finished XML through `xml_apply_layout( )`:

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

- A hidden control gets `visible="false"`; a `Label` directly in front of it
  whose `labelFor` names it is hidden, moved and renamed with it.
- Reordering stays inside the parent aggregation: the registered controls
  swap the places they occupy there, every other child keeps its position,
  nothing moves into another container.
- A renamed control gets its text written into `text`, `title`, `header`,
  `headerText`, `label` or `placeholder` - whichever it has - or into the
  attribute named with `label_attr`.
- `register_by_xml( xml = ... prefix = ... )` registers every control of a
  view whose id starts with the prefix, with the label the view carries.
- Navigation back from the popup, events and variants work as for a table
  (`z2ui5_cl_layo_sample_06`). The tables and forms of the other modes are
  unchanged and can sit in the same view.

The XML handling is `z2ui5_cl_layo_xml_tree` - no dependency on the framework
or the database, covered by ABAP Unit tests.

### Popup to select rows

`z2ui5_cl_layo_pop_w_sel` shows any table in a popup to pick rows from, with
the settings button of a layout table: the user chooses, orders and sizes the
columns, sets a sorting and saves the layout - it is offered again the next
time. Single select confirms with the first click, `i_multiselect = abap_true`
shows check boxes and an OK button; a search keeps what was selected before.

```abap
" in an event handler
client->nav_app_call( z2ui5_cl_layo_pop_w_sel=>factory( i_tab         = mt_tab
                                                        i_title       = `Select Products`
                                                        i_multiselect = abap_true ) ).

" back in check_on_navigated( ) - catch only the cast: on a restored draft
" get_app_prev( ) is the app itself
TRY.
    DATA(result) = CAST z2ui5_cl_layo_pop_w_sel( client->get_app_prev( ) )->result( ).
    IF result-check_confirmed = abap_true.
      ASSIGN result-table->* TO <selected>.   " a table of the type of mt_tab
    ENDIF.
  CATCH cx_sy_move_cast_error.
ENDTRY.
```

- `result-table` holds the selected rows in the order of `i_tab`,
  `result-row` the first of them; `nav_app_leave( )` hands the same table to
  the calling app as `r_data`, with the event `i_event_confirmed` (or
  `i_event_canceled` on cancel) when given.
- Without `i_handle01` to `i_handle04` the layouts are saved under the name of
  the popup class and the type name of the line of `i_tab`; pass handles to
  keep them apart per app.
- `i_tab` may also be a table of an elementary type (`string_table`), its
  column is `TAB_LINE`.

### Copy layouts

Hand saved layouts on to other handles - for example from one app and
warehouse to another - with `copy_layouts( )` instead of writing the layout
tables yourself:

```abap
DATA(heads) = z2ui5_cl_layo_manager=>copy_layouts( VALUE #(
    ( guid = ls_head-guid  handle01 = ls_head-handle01  handle02 = ls_head-handle02
      handle03 = `NEW_APP` handle04 = `0002` ) ) ).
```

Every copy gets new guids for head and positions and keeps name, control,
screen format, user and default flag; a copied default demotes the defaults of
its new scope. The copies are checked with `z2ui5_if_layo_auth` like a save in
the popup (`check_auth = abap_false` for an admin tool that checks itself), one
LUW, committed - unless `iv_commit = abap_false`, then the caller commits (see
[Commits](#commits)); `z2ui5_cx_layo_error` and nothing written when an
original is missing, a copy is not authorized or the database refuses it.

### Select layouts by ranges

`select_layouts( )` reads the layouts of one exact set of handles, as the
layout popup offers them. A tool that copies or migrates layouts reads them by
ranges with `select_layouts_by_range( )` instead - every parameter is an
optional range (`guid`, `layout`, `control`, `handle01` to `handle04`,
`format`, `uname`), an empty one selects everything:

```abap
DATA handle03 TYPE z2ui5_cl_layo_manager=>ty_r_handle.
DATA handle04 TYPE z2ui5_cl_layo_manager=>ty_r_handle.
handle03 = VALUE #( ( sign = `I` option = `CP` low = `MY_APP*` ) ).
handle04 = VALUE #( ( sign = `I` option = `EQ` low = `0001` ) ).

DATA(heads) = z2ui5_cl_layo_manager=>select_layouts_by_range( handle03   = handle03
                                                              handle04   = handle04
                                                              all_users  = abap_true
                                                              check_auth = abap_false ).

z2ui5_cl_layo_manager=>copy_layouts( t_copy     = VALUE #( FOR h IN heads
                                                           ( guid     = h-guid
                                                             handle01 = h-handle01
                                                             handle02 = h-handle02
                                                             handle03 = `MY_NEW_APP`
                                                             handle04 = `0002` ) )
                                     check_auth = abap_false ).
```

- Without `all_users` it returns the user's own and the shared layouts, as
  the popup does. With `all_users = abap_true` other users' personal layouts
  come too - each of them only when `z2ui5_if_layo_auth` allows the action
  `READ_OTHERS`, which the shipped default does not; `check_auth = abap_false`
  skips the check, for an admin tool that checks itself.
- The heads come as saved, ordered by guid - without the screen format
  fallback and the default demotion of `select_layouts( )`.

### Select-options with variants

Select-options for every field of a database table, inline in your page
(condensed from `z2ui5_cl_layo_sample_08`):

```abap
" DATA mo_multiselect TYPE REF TO z2ui5_cl_layo_filter.

METHOD z2ui5_if_app~main.

  IF client->check_on_init( ).
    mo_multiselect = z2ui5_cl_layo_filter=>factory_by_name( val       = `T100`
                                                             s_variant = VALUE #( handle01 = `ZMY_APP` ) ).
    view_display( ).    " calls mo_multiselect->set_output( client = client view = lo_panel )
    RETURN.
  ENDIF.

  " range popups, Clear, Load and Save variant are handled here
  IF mo_multiselect->main( client ).
    RETURN.
  ENDIF.

  " a restored draft or a return from another app: show the view again
  IF client->check_on_navigated( ).
    view_display( ).
    RETURN.
  ENDIF.

  IF client->check_on_event( `GO` ).
    read_data( ).
  ENDIF.

ENDMETHOD.

METHOD read_data.

  " only a field of the table goes into the WHERE clause
  DATA lt_filter LIKE mo_multiselect->ms_result-t_filter.
  DATA(lt_comp) = z2ui5_cl_layo_context=>rtti_get_t_attri_by_table_name( `T100` ).
  LOOP AT mo_multiselect->ms_result-t_filter INTO DATA(ls_filter).
    IF line_exists( lt_comp[ name = ls_filter-name ] ).
      INSERT ls_filter INTO TABLE lt_filter.
    ENDIF.
  ENDLOOP.

  DATA(lv_where) = z2ui5_cl_layo_context=>filter_get_sql_where( lt_filter ).
  SELECT FROM t100 FIELDS * WHERE (lv_where) INTO TABLE @mt_t100 UP TO 100 ROWS.

ENDMETHOD.
```

The select-options are bound to the view, so `ms_result-t_filter` - field
names included - comes back from the browser. Keep only the names that are
fields of your table before they go into the dynamic `WHERE`, as above and as
`z2ui5_cl_layo_sample_08` does. `filter_get_sql_where` itself already drops
every name that is not a plain identifier, so a forged name cannot add a
condition or a subquery; but a name that is no column of your table makes the
`SELECT` raise a `CX_SY_DYNAMIC_OSQL_*` exception - a short dump unless you
catch it - and any other column of the table could be filtered on, not only
the ones you offer.

As a filter popup over an internal table (condensed from
`z2ui5_cl_layo_sample_09`):

```abap
" on init
mo_variant = z2ui5_cl_layo_pop_filter=>factory_by_data( data        = mt_table
                                                         var_handle1 = `ZMY_APP` ).
" on the Filter button
client->nav_app_call( mo_variant ).

" back in your app - check_on_nav_back( ) is true only on the return from
" the popup; on a restored draft (check_on_navigated( ) alone) show the view
IF client->check_on_nav_back( ).
  DATA(lo_filter) = CAST z2ui5_cl_layo_pop_filter( client->get_app_prev( ) ).
  IF lo_filter->result( )-check_confirmed = abap_true.
    z2ui5_cl_layo_context=>filter_itab( EXPORTING filter = lo_filter->result( )-t_filter
                                        CHANGING  val    = mt_table ).
  ENDIF.
ENDIF.
```

| Class | Purpose |
|---|---|
| `z2ui5_cl_layo_filter` | select-options for a table name (`factory_by_name`), for data (`factory_by_data`) or for a filter (`factory_by_filter`); renders into your view with `set_output( )`, handles its events in `main( )` |
| `z2ui5_cl_layo_pop_filter` | the same as a popup app; returns the filter with `result( )` |
| `z2ui5_cl_layo_pop_range` | the popup that edits the ranges of one field (opened by the two above) |
| `z2ui5_cl_layo_pop_varread`, `z2ui5_cl_layo_pop_varsave` | popups to load (and delete) and save a variant |
| `z2ui5_cl_layo_var_db` | variant persistence in table `z2ui5_t_13` |
| `z2ui5_cl_layo_context` | the helpers: `filter_get_sql_where( )`, `filter_itab( )`, RTTI |

The select-options are a building block for an app you build yourself. For
an app that works like a classic report - a selection screen with
`PARAMETERS`, `SELECT-OPTIONS`, radio buttons and event blocks, then a list
or an ALV - use
[abap2UI5-addons/abap-cloud-gui](https://github.com/abap2UI5-addons/abap-cloud-gui);
[Select-options or abap-cloud-gui?](https://abap2ui5-addons.github.io/layout-management/which)
compares the two.

## Features

* **Generic Output** - Universal table and form rendering
* **Selection Popup** - Pick one or several rows of any table in a popup with a layout
* **Layout Customization** - Flexible customization of table and form outputs
* **Any View** - Hide, reorder within the parent aggregation and relabel the controls of any view built with the view builder (generic mode)
* **Conversion in the Browser** - ALPHA and NUMC columns are formatted by UI5, the data stays internal
* **Table Options** - Sort by a click on the column header, a colour key on every row, switches, inputs and buttons in cells, several controls in one cell, cell controls of the app's own structures
* **Variant Persistence** - Save layout variants to database
* **Auto-Loading** - Load default layouts automatically at startup
* **Select and Copy** - Read layouts by ranges, also of every user, and copy them under other handles
* **Authorization Hook** - Shared layouts and deletions can be restricted with `z2ui5_if_layo_auth`; by default every user may save and delete shared layouts
* **Select-Options** - For every field of a database table or an internal table, with the ranges entered in a popup - inline in your page or as a filter popup
* **Selection Variants** - Saved, loaded and deleted per app, optionally per user, with a default; saving over an existing variant asks first, and only the user's own variants can be deleted

## Samples

| Sample | Shows |
|---|---|
| `z2ui5_cl_layo_sample_01` | Table with icons, tags, progress indicators, radial charts and status indicators, sorted by a click on a column header |
| `z2ui5_cl_layo_sample_02` | Simple form with the same field types |
| `z2ui5_cl_layo_sample_03` | Table from a database table |
| `z2ui5_cl_layo_sample_04` | Simple form from a database record |
| `z2ui5_cl_layo_sample_05` | Table and form with two layouts on one page |
| `z2ui5_cl_layo_sample_06` | Generic mode: a page with a panel of inputs, a toolbar and a list, personalized by control id |
| `z2ui5_cl_layo_sample_07` | Popup to select several rows of a table, with a layout the user arranges and saves |
| `z2ui5_cl_layo_sample_08` | Select-options for table `T100` inline in the page, result read with a dynamic `WHERE` |
| `z2ui5_cl_layo_sample_09` | Filter popup over an internal table |

## Demo

### Tables
<img width="700" alt="Table output with layout customization popup" src="https://github.com/user-attachments/assets/5e5f9291-3817-4a66-a886-cd0ac0c6e175">
<img width="700" height="241" alt="Table output rendered with a customized layout" src="https://github.com/user-attachments/assets/fb2347d8-3ef9-4c33-aaf0-4af419f993b7" />

### Forms
<img width="700" height="203" alt="Simple form output rendered with a customized layout" src="https://github.com/user-attachments/assets/ec161092-7a99-4b99-be36-41866d1a3735" />
<img width="700" height="441" alt="Form layout customization popup with label and value spans" src="https://github.com/user-attachments/assets/ec24438e-110c-4061-b7b1-49ab61c98760" />

### Charts & Indicators
<img width="700" height="167" alt="Table with chart and indicator columns" src="https://github.com/user-attachments/assets/023d07da-bf62-44e4-8b6f-e05608150bf8" />
<img width="700" height="227" alt="Form with progress indicator, radial chart and status indicator" src="https://github.com/user-attachments/assets/75eedb06-6c24-48c3-b0ab-f0a66dbd625e" />

### Persistence
<img width="700" alt="Popup for saving and selecting persisted layout variants" src="https://github.com/user-attachments/assets/d7f39663-d864-4737-89e4-8e925e54bc2d">

### Select-options
<img width="600" alt="Select-options of a database table inline in the page" src="https://github.com/user-attachments/assets/47eb179e-c563-402d-907f-58ac77b43941" />
<img width="600" alt="Filter popup with the select-options of an internal table" src="https://github.com/user-attachments/assets/f5c76993-9ad4-46a0-81df-2586ec2c21cf" />
<img width="600" alt="Range popup of one select-option" src="https://github.com/user-attachments/assets/84c4fa61-a95a-4232-b7c1-0f9d3105e20d" />

## Commits

The abap2UI5 addons (layout-management, popups, table-maintenance) share one
commit model:

- **The addon commits only in its own apps.** A popup or app of the addon
  that saves on a button of its own runs in a roundtrip of its own and ends
  its own LUW - `COMMIT WORK AND WAIT`, or `ROLLBACK WORK` on failure.
- **A library method commits only with `iv_commit = abap_true`.** Every
  public method that writes on behalf of its caller takes
  `iv_commit TYPE abap_bool DEFAULT abap_true`. The default keeps the old
  behaviour: the method ends with `COMMIT WORK AND WAIT` - and so commits
  whatever the caller has open at that moment as well. With
  `iv_commit = abap_false` it neither commits nor rolls back: its writes join
  the caller's LUW, and the caller commits them once, together with its own
  changes.
- **On failure the method raises its exception.** With
  `iv_commit = abap_false` it never runs `ROLLBACK WORK` - whatever it wrote
  before the failure is still in the caller's LUW, and the caller decides,
  normally with `ROLLBACK WORK`. With `iv_commit = abap_true` it fails as it
  always did (the table below).
- **The caller must commit.** abap2UI5 runs `ROLLBACK WORK` before and after
  `main( )` of a stateless app, so what an app writes - itself, or through a
  method called with `iv_commit = abap_false` - is lost unless the app commits
  it in the same roundtrip.

In this addon:

| Where | Commits | On failure with `iv_commit = abap_true` |
|---|---|---|
| `z2ui5_cl_layo_manager=>copy_layouts( )` - library | with `iv_commit = abap_true` (default) | `ROLLBACK WORK`, then `z2ui5_cx_layo_error` |
| Layout popup `z2ui5_cl_layo_pop` - Save and Delete | always, its own app | `ROLLBACK WORK` and a message toast |

A missing original or a copy `z2ui5_if_layo_auth` refuses is found before the
first write: `copy_layouts( )` raises with nothing written, in both modes. A
tool that copies layouts as part of a larger change commits once:

```abap
TRY.
    " ... the tool's own database changes
    z2ui5_cl_layo_manager=>copy_layouts( t_copy     = lt_copy
                                         check_auth = abap_false
                                         iv_commit  = abap_false ).
    COMMIT WORK AND WAIT.
  CATCH z2ui5_cx_layo_error INTO DATA(lx).
    ROLLBACK WORK.
    client->message_box_display( text = lx->get_text( ) type = `error` ).
ENDTRY.
```

## Security

This library persists layout variants to its own database tables. Who may
write what is decided in one place, the interface `z2ui5_if_layo_auth`.

Ownership of the variants:

* A layout saved with **User specific** belongs to the user who saved it; one saved without it is **shared** and is offered to every user.
* The layout popup lists the user's own layouts and the shared ones - never another user's personal layout.
* Saving never takes a layout away from anybody: saving another user's layout, or saving a shared layout as user specific, stores a new layout of the user's own under the same name and leaves the original as it was. A shared layout saved again as shared is updated for everybody.

### Authorization concept

Before every write the popup asks `z2ui5_cl_layo_auth=>check( action = ... head = ... )`
with one of the actions of `z2ui5_if_layo_auth=>cs_action`:

| Action | Asked when | Shipped default |
|---|---|---|
| `SAVE_OWN` | a user specific layout is saved (`head-uname` = the user) | allowed |
| `SAVE_SHARED` | a shared layout is saved, new or updated (`head-uname` empty) | allowed |
| `DELETE` | a layout is deleted - `head` is read from the database, `uname` is its owner | allowed for the owner and for shared layouts, never another user's personal layout |
| `READ_OTHERS` | `select_layouts_by_range( all_users = abap_true )` reads another user's personal layout - `uname` is its owner; a refused one is left out | refused - the popup never shows another user's personal layout |

The decision goes to, in this order:

1. an instance set with `z2ui5_cl_layo_auth=>set_instance( )` - for tests, or
   for an installation that wants to choose the class itself;
2. the one class in the system that implements `z2ui5_if_layo_auth` - found
   by its interface, the way abap2UI5 finds its user exit (the first by name
   if there are several, so keep it to one);
3. `z2ui5_cl_layo_auth` itself, the default above.

Without an implementation of its own the system behaves as before the hook
existed: every user may save and delete his own and the shared layouts. A
denial of an implementation ends in a message toast and nothing is written;
when a shared save is denied, the save popup starts on **User specific**.

The addon ships no authorization object on purpose: an `AUTHORITY-CHECK`
against an object that does not exist in the customer system is always
refused, and the right object differs per installation. To restrict shared
layouts to key users, implement the interface with your own object:

```abap
CLASS zcl_my_layo_auth DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_layo_auth.
ENDCLASS.

CLASS zcl_my_layo_auth IMPLEMENTATION.
  METHOD z2ui5_if_layo_auth~check_authorized.
    CASE action.
      WHEN z2ui5_if_layo_auth=>cs_action-save_own.
        result = xsdbool( head-uname = sy-uname ).
      WHEN z2ui5_if_layo_auth=>cs_action-save_shared
        OR z2ui5_if_layo_auth=>cs_action-delete.
        " head-handle01 .. 04 say which app and table the layout belongs to
        AUTHORITY-CHECK OBJECT 'Z_LAYOUT' ID 'ACTVT' FIELD '02'.
        result = xsdbool( sy-subrc = 0 OR ( action = z2ui5_if_layo_auth=>cs_action-delete
                                            AND head-uname = sy-uname ) ).
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
```

Shared layouts written before an implementation existed, or by another tool,
stay in table `z2ui5_t_11` (positions in `z2ui5_t_12`).

The selection variants (`z2ui5_t_13`) are not covered by `z2ui5_if_layo_auth`.
Every user may save a variant, user specific or shared; a user deletes only
variants of their own, and a shared one cannot be deleted in the popup at
all - the table does not say who saved it.

## Development

```bash
npm ci
npm run check           # all gates below, as in CI
npm run lint            # abaplint, Standard ABAP (v750)
npm run check:cloud     # abaplint, ABAP Cloud
npm run check:abap2ui5  # abap2UI5-linter over apps and views
npm run rename          # namespace rename check
npm run unit            # ABAP Unit tests on abap2UI5's transpiled Node runtime
npm run downport        # downport the source to 7.02 syntax
npm run site            # the GitHub Pages site (VitePress) into build/site
npm run site:dev        # the same with the VitePress dev server
```

## Contributing

Issues and pull requests are welcome - whether you're fixing bugs, adding new
functionality, or improving documentation. Read
[CONTRIBUTING.md](CONTRIBUTING.md) first.

## License

MIT - see [LICENSE](LICENSE).
