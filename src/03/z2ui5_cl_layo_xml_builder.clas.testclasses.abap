" the apps a table is rendered for: the client binds the table and the
" layout as their public attributes
CLASS ltcl_app DEFINITION FINAL FOR TESTING.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_row,
        vbeln    TYPE c LENGTH 10,
        matnr    TYPE c LENGTH 18,
        menge    TYPE p LENGTH 13 DECIMALS 3,
        meins    TYPE c LENGTH 3,
        icon     TYPE z2ui5_xml_s_icon,
        tag      TYPE z2ui5_xml_s_generictag,
        progress TYPE z2ui5_xml_s_progressind,
        radial   TYPE z2ui5_xml_s_radialchart,
        status   TYPE z2ui5_xml_s_statusind,
        selkz    TYPE abap_bool,
      END OF ty_s_row.

    DATA mt_data   TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.
    DATA mv_search TYPE string.
    DATA mo_layout TYPE REF TO z2ui5_cl_layo_manager.
ENDCLASS.

CLASS ltcl_app IMPLEMENTATION.
  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.
ENDCLASS.

" the cell controls: the structures of this addon, and structures of an
" app's own that name some components differently (SIZE) and carry more
" (COLOR, PRESS) - mapped by rollname
CLASS ltcl_app_cells DEFINITION FINAL FOR TESTING.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_own_icon,
        src         TYPE string,
        size        TYPE string,
        color       TYPE string,
        press       TYPE string,
        press_value TYPE string,
      END OF ty_s_own_icon.
    TYPES:
      BEGIN OF ty_s_own_radial,
        size         TYPE string,
        percentage   TYPE i,
        valuecolor   TYPE string,
        hideonnodata TYPE abap_bool,
      END OF ty_s_own_radial.
    TYPES:
      BEGIN OF ty_s_own_color,
        color TYPE string,
      END OF ty_s_own_color.
    TYPES:
      BEGIN OF ty_s_row,
        matnr      TYPE c LENGTH 18,
        switch     TYPE z2ui5_xml_s_switch,
        input      TYPE z2ui5_xml_s_input,
        button     TYPE z2ui5_xml_s_button,
        own_icon   TYPE ty_s_own_icon,
        own_radial TYPE ty_s_own_radial,
        icon       TYPE z2ui5_xml_s_icon,
        cell_color TYPE ty_s_own_color,
      END OF ty_s_row.

    DATA mt_data   TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.
    DATA mo_layout TYPE REF TO z2ui5_cl_layo_manager.
ENDCLASS.

CLASS ltcl_app_cells IMPLEMENTATION.
  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_xml_builder DEFINITION DEFERRED.
CLASS z2ui5_cl_layo_xml_builder DEFINITION LOCAL FRIENDS ltcl_xml_builder.

CLASS ltcl_xml_builder DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS cell_plain_name FOR TESTING.
    METHODS cell_namespaced_name FOR TESTING.
    METHODS icon_namespaced_name FOR TESTING.
    METHODS cell_alpha_digit_type FOR TESTING.
    METHODS cell_numc_namespaced FOR TESTING.
    METHODS cell_conversion_switched_off FOR TESTING.
    METHODS cell_other_exit_plain FOR TESTING.
    METHODS require_on_control FOR TESTING.
    METHODS require_only_with_digits FOR TESTING.
    METHODS table_unchanged FOR TESTING.
    METHODS table_unchanged_options FOR TESTING.
    METHODS cell_control_by_rollname FOR TESTING.
    METHODS col_sort_header FOR TESTING.
    METHODS col_sort_event FOR TESTING.
    METHODS col_sort_other_layout FOR TESTING.
    METHODS row_color FOR TESTING.
    METHODS row_color_path FOR TESTING.
    METHODS sel_event FOR TESTING.
    METHODS switch_input_button FOR TESTING.
    METHODS own_structures FOR TESTING.
    METHODS sub_col_controls FOR TESTING.
    METHODS table_without_toolbar FOR TESTING.
    METHODS grid_span_beside_ref_field FOR TESTING.

    DATA mo_app    TYPE REF TO ltcl_app.
    DATA mi_client TYPE REF TO z2ui5_if_client.
    DATA mo_action TYPE REF TO z2ui5_cl_ui5_action.

    METHODS setup.

    "! a client of the framework for the app
    METHODS client_for
      IMPORTING
        app TYPE REF TO z2ui5_if_app.

    "! the table with the parameters every caller had so far
    METHODS render_table
      IMPORTING
        i_options     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result) TYPE string.

    "! the cells app with its layout, rendered
    METHODS render_cells
      IMPORTING
        i_sub_col_controls TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result)      TYPE string.

    "! the table as it was rendered before the table options - the output
    "! every existing caller keeps
    METHODS golden_default
      RETURNING
        VALUE(result) TYPE string.

    METHODS golden_options
      RETURNING
        VALUE(result) TYPE string.
ENDCLASS.


CLASS ltcl_xml_builder IMPLEMENTATION.

  METHOD cell_plain_name.

    cl_abap_unit_assert=>assert_equals(
        exp = `{MATNR}`
        act = z2ui5_cl_layo_xml_builder=>table_value_formatter( VALUE #( fname = `MATNR` ) ) ).

  ENDMETHOD.

  METHOD cell_namespaced_name.

    " the model writes /CWM/XCWMAT as a level of the row - a relative path,
    " never {/CWM/XCWMAT}, which UI5 reads from the model root
    cl_abap_unit_assert=>assert_equals(
        exp = `{CWM/XCWMAT}`
        act = z2ui5_cl_layo_xml_builder=>table_value_formatter( VALUE #( fname = `/CWM/XCWMAT` ) ) ).

  ENDMETHOD.

  METHOD icon_namespaced_name.

    " the table case renders bindings only - it reads nothing from the client
    DATA client TYPE REF TO z2ui5_if_client.

    DATA position TYPE z2ui5_cl_layo_manager=>ty_s_positions.
    position-fname = `/CWM/ICON`.
    DATA(view) = z2ui5_cl_ui5_view_builder=>factory( ).

    z2ui5_cl_layo_xml_builder=>xml_build_icon( i_client = client
                                               i_layout = REF #( position )
                                               i_xml    = view ).

    DATA(xml) = view->stringify( ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*src="{CWM/ICON/SRC}"*`
                                         act = xml ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*size="{CWM/ICON/ICON_SIZE}"*`
                                         act = xml ).

  ENDMETHOD.

  METHOD cell_alpha_digit_type.

    " ALPHA on a CHAR column: the browser strips and pads the zeros
    cl_abap_unit_assert=>assert_equals(
        exp = `{path:'VBELN',type:'LayoDigitString',constraints:{isDigitSequence:true,maxLength:10}}`
        act = z2ui5_cl_layo_xml_builder=>table_value_formatter( VALUE #( fname    = `VBELN`
                                                                         convexit = `ALPHA`
                                                                         digits   = 10 ) ) ).

  ENDMETHOD.

  METHOD cell_numc_namespaced.

    cl_abap_unit_assert=>assert_equals(
        exp = `{path:'CWM/NR',type:'LayoDigitString',constraints:{isDigitSequence:true,maxLength:8}}`
        act = z2ui5_cl_layo_xml_builder=>table_value_formatter( VALUE #( fname    = `/CWM/NR`
                                                                         convexit = `NUMC`
                                                                         digits   = 8 ) ) ).

  ENDMETHOD.

  METHOD cell_conversion_switched_off.

    " the user switched the conversion off in the layout popup
    cl_abap_unit_assert=>assert_equals(
        exp = `{VBELN}`
        act = z2ui5_cl_layo_xml_builder=>table_value_formatter( VALUE #( fname       = `VBELN`
                                                                         convexit    = `ALPHA`
                                                                         digits      = 10
                                                                         no_convexit = abap_true ) ) ).

  ENDMETHOD.

  METHOD cell_other_exit_plain.

    " CUNIT, MATN1, ... stay a conversion in ABAP - a plain binding
    cl_abap_unit_assert=>assert_equals(
        exp = `{MATNR}`
        act = z2ui5_cl_layo_xml_builder=>table_value_formatter( VALUE #( fname    = `MATNR`
                                                                         convexit = `MATN1` ) ) ).

  ENDMETHOD.

  METHOD require_on_control.

    DATA(view) = z2ui5_cl_ui5_view_builder=>factory( ).
    DATA(table) = view->ele( `Table` ).

    z2ui5_cl_layo_xml_builder=>set_digit_type_require( table ).

    DATA(xml) = view->stringify( ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*xmlns:core="sap.ui.core"*`
                                         act = xml ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*core:require="{LayoDigitString:*sap/ui/model/odata/type/String*}"*`
                                         act = xml ).

  ENDMETHOD.

  METHOD require_only_with_digits.

    DATA(layout) = NEW z2ui5_cl_layo_manager( ).
    layout->ms_layout-t_layout = VALUE #( ( fname = `MATNR` convexit = `MATN1` )
                                          ( fname = `VBELN` convexit = `ALPHA` digits = 10 no_convexit = abap_true ) ).

    cl_abap_unit_assert=>assert_false( z2ui5_cl_layo_xml_builder=>check_digit_type( layout ) ).

    layout->ms_layout-t_layout[ 2 ]-no_convexit = abap_false.

    cl_abap_unit_assert=>assert_true( z2ui5_cl_layo_xml_builder=>check_digit_type( layout ) ).

  ENDMETHOD.

  METHOD setup.

    mo_app = NEW #( ).
    mo_app->mt_data = VALUE #( ( vbeln = `4711` matnr = `M1` menge = 1 meins = `ST` ) ).

    mo_app->mo_layout = NEW #( ).
    mo_app->mo_layout->ms_layout-s_head-guid = `GUID1`.
    mo_app->mo_layout->ms_layout-t_layout = VALUE #(
        ( fname = `VBELN` rollname = `VBELN` visible = abap_true tlabel = `Order` convexit = `ALPHA` digits = 10
          t_sub_col = VALUE #( ( fname = `MATNR` ) ( fname = `MENGE` ) ( fname = `ICON` ) ) )
        ( fname = `MATNR` rollname = `MATNR` visible = abap_true tlabel = `Material` )
        ( fname = `MENGE` rollname = `MENGE` visible = abap_true tlabel = `Qty` reference_field = `MEINS` )
        ( fname = `MEINS` rollname = `MEINS` tlabel = `Unit` )
        ( fname = `ICON` rollname = `Z2UI5_XML_S_ICON` visible = abap_true tlabel = `Icon`
          t_sub_col = VALUE #( ( fname = `MATNR` ) ) )
        ( fname = `TAG` rollname = `Z2UI5_XML_S_GENERICTAG` tlabel = `Tag` )
        ( fname = `PROGRESS` rollname = `Z2UI5_XML_S_PROGRESSIND` tlabel = `Progress` )
        ( fname = `RADIAL` rollname = `Z2UI5_XML_S_RADIALCHART` tlabel = `Radial` )
        ( fname = `STATUS` rollname = `Z2UI5_XML_S_STATUSIND` tlabel = `Status` )
        ( fname = `SELKZ` rollname = `XSDBOOLEAN` tlabel = `Sel` ) ).

    client_for( mo_app ).

  ENDMETHOD.

  METHOD client_for.

    mo_action = NEW #( val = NEW z2ui5_cl_ui5_handler( val = `` ) ).
    mo_action->mo_app->mo_app = app.
    mi_client = NEW z2ui5_cl_ui5_client( action = mo_action ).

  ENDMETHOD.

  METHOD render_table.

    DATA(view) = z2ui5_cl_ui5_view_builder=>factory( ).

    IF i_options = abap_false.
      z2ui5_cl_layo_xml_builder=>xml_build_table( i_data   = REF #( mo_app->mt_data )
                                                  i_xml    = view
                                                  i_client = mi_client
                                                  i_layout = mo_app->mo_layout ).
    ELSE.
      z2ui5_cl_layo_xml_builder=>xml_build_table( i_data             = REF #( mo_app->mt_data )
                                                  i_xml              = view
                                                  i_client           = mi_client
                                                  i_layout           = mo_app->mo_layout
                                                  i_search_value     = REF #( mo_app->mv_search )
                                                  i_growingthreshold = `50`
                                                  i_headertext       = `Orders`
                                                  i_sel_mode         = `MultiSelect`
                                                  i_sel_bind_to      = `SELKZ`
                                                  i_col_type         = `Active`
                                                  i_col_bind_to      = `VBELN` ).
    ENDIF.

    result = view->stringify( ).

  ENDMETHOD.

  METHOD render_cells.

    DATA(app) = NEW ltcl_app_cells( ).
    app->mt_data = VALUE #( ( matnr = `M1` ) ).
    app->mo_layout = NEW #( ).
    app->mo_layout->ms_layout-s_head-guid = `GUID2`.
    app->mo_layout->ms_layout-t_layout = VALUE #(
        ( fname = `MATNR` rollname = `MATNR` tlabel = `Material`
          t_sub_col = VALUE #( ( fname = `SWITCH` ) ( fname = `ICON` ) ) )
        ( fname = `SWITCH` rollname = `Z2UI5_XML_S_SWITCH` tlabel = `Switch` )
        ( fname = `INPUT` rollname = `Z2UI5_XML_S_INPUT` tlabel = `Input` )
        ( fname = `BUTTON` rollname = `Z2UI5_XML_S_BUTTON` tlabel = `Button`
          t_sub_col = VALUE #( ( fname = `MATNR` ) ) )
        ( fname = `OWN_ICON` rollname = `TY_S_OWN_ICON` tlabel = `Own icon` )
        ( fname = `OWN_RADIAL` rollname = `TY_S_OWN_RADIAL` tlabel = `Own radial` )
        ( fname = `ICON` rollname = `Z2UI5_XML_S_ICON` tlabel = `Icon` ) ).

    client_for( app ).

    DATA(view) = z2ui5_cl_ui5_view_builder=>factory( ).

    z2ui5_cl_layo_xml_builder=>xml_build_table(
        i_data             = REF #( app->mt_data )
        i_xml              = view
        i_client           = mi_client
        i_layout           = app->mo_layout
        i_sub_col_controls = i_sub_col_controls
        i_t_cell_control   = VALUE #(
            ( rollname = `TY_S_OWN_ICON` control = z2ui5_cl_layo_xml_builder=>cs_cell_control-icon )
            ( rollname = `TY_S_OWN_RAD*` control = z2ui5_cl_layo_xml_builder=>cs_cell_control-radial_chart ) ) ).

    result = view->stringify( ).

  ENDMETHOD.

  METHOD table_unchanged.

    cl_abap_unit_assert=>assert_equals( exp = golden_default( )
                                        act = render_table( ) ).

  ENDMETHOD.

  METHOD table_unchanged_options.

    cl_abap_unit_assert=>assert_equals( exp = golden_options( )
                                        act = render_table( abap_true ) ).

  ENDMETHOD.

  METHOD cell_control_by_rollname.

    " the built-in patterns
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_cl_layo_xml_builder=>cs_cell_control-icon
                                        act = z2ui5_cl_layo_xml_builder=>cell_control( `Z2UI5_XML_S_ICON` ) ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_cl_layo_xml_builder=>cs_cell_control-switch
                                        act = z2ui5_cl_layo_xml_builder=>cell_control( `ZMY_XML_S_SWITCH` ) ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_cl_layo_xml_builder=>cs_cell_control-text
                                        act = z2ui5_cl_layo_xml_builder=>cell_control( `MATNR` ) ).

    " the app's entries first - a rollname of its own, a namespace, and a
    " built-in one drawn as text instead
    DATA(t_cell_control) = VALUE z2ui5_cl_layo_xml_builder=>ty_t_cell_control(
        ( rollname = `/ABC/S_SWITCH` control = z2ui5_cl_layo_xml_builder=>cs_cell_control-switch )
        ( rollname = `Z2UI5_XML_S_ICON` control = z2ui5_cl_layo_xml_builder=>cs_cell_control-text ) ).

    cl_abap_unit_assert=>assert_equals( exp = z2ui5_cl_layo_xml_builder=>cs_cell_control-switch
                                        act = z2ui5_cl_layo_xml_builder=>cell_control(
                                                  rollname       = `/ABC/S_SWITCH`
                                                  t_cell_control = t_cell_control ) ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_cl_layo_xml_builder=>cs_cell_control-text
                                        act = z2ui5_cl_layo_xml_builder=>cell_control(
                                                  rollname       = `Z2UI5_XML_S_ICON`
                                                  t_cell_control = t_cell_control ) ).

  ENDMETHOD.

  METHOD col_sort_header.

    DATA(view) = z2ui5_cl_ui5_view_builder=>factory( ).
    z2ui5_cl_layo_xml_builder=>xml_build_table( i_data           = REF #( mo_app->mt_data )
                                                i_xml            = view
                                                i_client         = mi_client
                                                i_layout         = mo_app->mo_layout
                                                i_col_sort       = abap_true
                                                i_col_sort_class = `myColSort` ).
    DATA(xml) = view->stringify( ).

    " the standard sort icon, bound to the sorting of the layout
    cl_abap_unit_assert=>assert_char_cp(
        exp = `*<Column *sortIndicator="{= ${/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/0/SORTING} === 'ASCENDING' ? 'Ascending' : ${/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/0/SORTING} === 'DESCENDING' ? 'Descending' : 'None' }"*`
        act = xml ).
    " the header is a link that sends the layout and the column
    cl_abap_unit_assert=>assert_char_cp(
        exp = `*<Link text="Order" wrapping="true" press=".eB(['LAYO_COLUMN_SORT'], 'GUID1', 'VBELN')" class="myColSort"/></Column>*`
        act = xml ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*<Link text="Qty" *`
                                         act = xml ).
    " no plain header is left
    cl_abap_unit_assert=>assert_false( xsdbool( xml CS `<Text text="Order"/>` ) ).

  ENDMETHOD.

  METHOD col_sort_event.

    " the order of the rows is sort( )'s business - and the transpiled
    " runtime drops its dynamic SORT BY (sortorder): checked here is what
    " the event does to the layout
    mo_app->mo_layout->ms_layout-t_layout[ fname = `VBELN` ]-sorting = `ASCENDING`.

    mo_action->ms_actual-event       = z2ui5_cl_layo_xml_builder=>cv_event_column_sort.
    mo_action->ms_actual-t_event_arg = VALUE #( ( `GUID1` ) ( `MATNR` ) ).

    " the popup's event handler takes it as well - and opens no popup
    z2ui5_cl_layo_pop=>on_event_layout( client = mi_client
                                        layout = mo_app->mo_layout
                                        data   = REF #( mo_app->mt_data ) ).

    cl_abap_unit_assert=>assert_equals( exp = `ASCENDING`
                                        act = mo_app->mo_layout->ms_layout-t_layout[ fname = `MATNR` ]-sorting ).
    " sorted by the column clicked last only
    cl_abap_unit_assert=>assert_initial( mo_app->mo_layout->ms_layout-t_layout[ fname = `VBELN` ]-sorting ).
    cl_abap_unit_assert=>assert_initial( mo_action->ms_next-o_app_call ).

    " the second click: descending
    cl_abap_unit_assert=>assert_true( z2ui5_cl_layo_xml_builder=>on_event_column_sort(
                                          client = mi_client
                                          layout = mo_app->mo_layout
                                          data   = REF #( mo_app->mt_data ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = `DESCENDING`
                                        act = mo_app->mo_layout->ms_layout-t_layout[ fname = `MATNR` ]-sorting ).

    " the third: no sorting
    z2ui5_cl_layo_xml_builder=>on_event_column_sort( client = mi_client
                                                     layout = mo_app->mo_layout
                                                     data   = REF #( mo_app->mt_data ) ).
    cl_abap_unit_assert=>assert_initial( mo_app->mo_layout->ms_layout-t_layout[ fname = `MATNR` ]-sorting ).

  ENDMETHOD.

  METHOD col_sort_other_layout.

    " the column sort of another table, and an unknown column
    mo_action->ms_actual-event       = z2ui5_cl_layo_xml_builder=>cv_event_column_sort.
    mo_action->ms_actual-t_event_arg = VALUE #( ( `GUID2` ) ( `MATNR` ) ).

    cl_abap_unit_assert=>assert_false( z2ui5_cl_layo_xml_builder=>on_event_column_sort(
                                           client = mi_client
                                           layout = mo_app->mo_layout ) ).

    mo_action->ms_actual-t_event_arg = VALUE #( ( `GUID1` ) ( `NOPE` ) ).

    cl_abap_unit_assert=>assert_false( z2ui5_cl_layo_xml_builder=>on_event_column_sort(
                                           client = mi_client
                                           layout = mo_app->mo_layout ) ).
    cl_abap_unit_assert=>assert_false( mo_app->mo_layout->toggle_sorting( `NOPE` ) ).

  ENDMETHOD.

  METHOD row_color.

    DATA(view) = z2ui5_cl_ui5_view_builder=>factory( ).
    z2ui5_cl_layo_xml_builder=>xml_build_table( i_data      = REF #( mo_app->mt_data )
                                                i_xml       = view
                                                i_client    = mi_client
                                                i_layout    = mo_app->mo_layout
                                                i_row_color = `CELL_COLOR-COLOR` ).

    " on the row, before its cells
    cl_abap_unit_assert=>assert_char_cp(
        exp = `*<ColumnListItem *><customData><core:CustomData xmlns:core="sap.ui.core" key="color" value="{CELL_COLOR/COLOR}" writeToDom="true"/></customData><cells>*`
        act = view->stringify( ) ).

  ENDMETHOD.

  METHOD row_color_path.

    cl_abap_unit_assert=>assert_equals( exp = `{COLOR}`
                                        act = z2ui5_cl_layo_xml_builder=>row_color_binding( `COLOR` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `{ABC/COLOR/KEY}`
                                        act = z2ui5_cl_layo_xml_builder=>row_color_binding( `/ABC/COLOR-KEY` ) ).

  ENDMETHOD.

  METHOD sel_event.

    DATA(view) = z2ui5_cl_ui5_view_builder=>factory( ).
    z2ui5_cl_layo_xml_builder=>xml_build_table( i_data      = REF #( mo_app->mt_data )
                                                i_xml       = view
                                                i_client    = mi_client
                                                i_layout    = mo_app->mo_layout
                                                i_sel_event = `ROW_SELECT` ).

    cl_abap_unit_assert=>assert_char_cp( exp = `*selectionChange=".eB(['ROW_SELECT'])"*`
                                         act = view->stringify( ) ).

  ENDMETHOD.

  METHOD switch_input_button.

    DATA(xml) = render_cells( ).

    cl_abap_unit_assert=>assert_char_cp(
        exp = `*<Switch state="{SWITCH/STATE}" customTextOn="{SWITCH/CUSTOMTEXTON}" customTextOff="{SWITCH/CUSTOMTEXTOFF}" enabled="{SWITCH/ENABLED}" type="{= ${SWITCH/TYPE} || 'Default' }" change=".eB([${SWITCH/CHANGE}], ${SWITCH/CHANGE_VALUE})"/>*`
        act = xml ).
    cl_abap_unit_assert=>assert_char_cp(
        exp = `*<Input value="{INPUT/VALUE}" placeholder="{INPUT/PLACEHOLDER}" enabled="{INPUT/ENABLED}" editable="{INPUT/EDITABLE}" visible="{INPUT/VISIBLE}"/>*`
        act = xml ).
    cl_abap_unit_assert=>assert_char_cp(
        exp = `*<Button text="{BUTTON/TEXT}" icon="{BUTTON/ICON}" type="{= ${BUTTON/TYPE} || 'Default' }" press=".eB([${BUTTON/PRESS}], ${BUTTON/PRESS_VALUE})"/>*`
        act = xml ).
    " without i_sub_col_controls a control column shows the control only
    cl_abap_unit_assert=>assert_false( xsdbool( xml CS `<VBox` ) ).

  ENDMETHOD.

  METHOD grid_span_beside_ref_field.

    " a value span the reference field takes up completely is still a span
    " of 1 - XL0 or S0 is none the grid takes
    DATA(position) = VALUE z2ui5_cl_layo_manager=>ty_s_positions( reference_field = `WAERS`
                                                                  grid_value_xl   = `1`
                                                                  grid_value_l    = `4`
                                                                  grid_value_m    = `1`
                                                                  grid_value_s    = `2` ).

    DATA(grid_layout) = z2ui5_cl_layo_xml_builder=>get_grid_layout( REF #( position ) ).

    cl_abap_unit_assert=>assert_equals( exp = `XL1 L3 M1 S1`
                                        act = grid_layout-value ).
    cl_abap_unit_assert=>assert_equals( exp = `XL1 L1 M1 S2`
                                        act = grid_layout-ref_field ).

  ENDMETHOD.

  METHOD own_structures.

    DATA(xml) = render_cells( ).

    " SIZE instead of ICON_SIZE, and COLOR and PRESS because the structure has them
    cl_abap_unit_assert=>assert_char_cp(
        exp = `*<core:Icon src="{OWN_ICON/SRC}" size="{OWN_ICON/SIZE}" color="{OWN_ICON/COLOR}" press=".eB([${OWN_ICON/PRESS}], ${OWN_ICON/PRESS_VALUE})"/>*`
        act = xml ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*<mchart:RadialMicroChart size="{OWN_RADIAL/SIZE}" percentage="{OWN_RADIAL/PERCENTAGE}"*`
                                         act = xml ).
    " the structure of this addon as before
    cl_abap_unit_assert=>assert_char_cp( exp = `*<core:Icon src="{ICON/SRC}" size="{ICON/ICON_SIZE}"/>*`
                                         act = xml ).

  ENDMETHOD.

  METHOD sub_col_controls.

    DATA(xml) = render_cells( abap_true ).

    " a text column with control subcolumns: its value, then the controls
    cl_abap_unit_assert=>assert_char_cp(
        exp = `*<cells><VBox><ObjectIdentifier text="{MATNR}"/><Switch *<core:Icon src="{ICON/SRC}" size="{ICON/ICON_SIZE}"/></VBox>*`
        act = xml ).
    " a control column with a text subcolumn: the control, then the text
    cl_abap_unit_assert=>assert_char_cp(
        exp = `*<VBox><Button *"/><ObjectIdentifier text="Material: {MATNR}"/></VBox>*`
        act = xml ).
    " the text of the subcolumns leaves the controls out
    cl_abap_unit_assert=>assert_false( xsdbool( xml CS `Switch: ` ) ).

  ENDMETHOD.

  METHOD table_without_toolbar.

    DATA(view) = z2ui5_cl_ui5_view_builder=>factory( ).
    z2ui5_cl_layo_xml_builder=>xml_build_table( i_data         = REF #( mo_app->mt_data )
                                                i_xml          = view
                                                i_client       = mi_client
                                                i_layout       = mo_app->mo_layout
                                                i_search_value = REF #( mo_app->mv_search )
                                                i_headertext   = `Orders`
                                                i_toolbar      = abap_false ).

    " the default table without its toolbar - no title, no search field, no
    " settings button - and the header text on the table itself
    DATA(exp) = replace( val  = golden_default( )
                         sub  = `<headerToolbar><OverflowToolbar><ToolbarSpacer/><Button icon="sap-icon://action-settings" press=".eB(['GUID1'])"/></OverflowToolbar></headerToolbar>`
                         with = `` ).
    exp = replace( val  = exp
                   sub  = `core:require="{LayoDigitString:'sap/ui/model/odata/type/String'}">`
                   with = `core:require="{LayoDigitString:'sap/ui/model/odata/type/String'}" headerText="Orders">` ).

    cl_abap_unit_assert=>assert_equals( exp = exp
                                        act = view->stringify( ) ).

  ENDMETHOD.

  METHOD golden_default.

    result = `<Table growing="false" growingThreshold="" width="auto" mode="None" items="{/MT_DATA}" sel`
          && `ectionChange=".eB(['SELECTION_CHANGE'])" xmlns:core="sap.ui.core" core:require="{LayoDigit`
          && `String:'sap/ui/model/odata/type/String'}"><headerToolbar><OverflowToolbar><ToolbarSpacer/>`
          && `<Button icon="sap-icon://action-settings" press=".eB(['GUID1'])"/></OverflowToolbar></head`
          && `erToolbar><columns><Column visible="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/0/VISIBLE}" mergeDuplic`
          && `ates="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/0/MERGE}" width="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/0/WID`
          && `TH}"><Text text="Order"/></Column><Column visible="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/1/VISIBL`
          && `E}" mergeDuplicates="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/1/MERGE}" width="{/MO_LAYOUT/MS_LAYOUT`
          && `/T_LAYOUT/1/WIDTH}"><Text text="Material"/></Column><Column visible="{/MO_LAYOUT/MS_LAYOUT`
          && `/T_LAYOUT/2/VISIBLE}" mergeDuplicates="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/2/MERGE}" width="{/M`
          && `O_LAYOUT/MS_LAYOUT/T_LAYOUT/2/WIDTH}"><Text text="Qty"/></Column><Column visible="{/MO_LAY`
          && `OUT/MS_LAYOUT/T_LAYOUT/3/VISIBLE}" mergeDuplicates="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/3/MERGE`
          && `}" width="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/3/WIDTH}"><Text text="Unit"/></Column><Column vis`
          && `ible="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/4/VISIBLE}" mergeDuplicates="{/MO_LAYOUT/MS_LAYOUT/T_`
          && `LAYOUT/4/MERGE}" width="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/4/WIDTH}"><Text text="Icon"/></Colu`
          && `mn><Column visible="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/5/VISIBLE}" mergeDuplicates="{/MO_LAYOU`
          && `T/MS_LAYOUT/T_LAYOUT/5/MERGE}" width="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/5/WIDTH}"><Text text=`
          && `"Tag"/></Column><Column visible="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/6/VISIBLE}" mergeDuplicate`
          && `s="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/6/MERGE}" width="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/6/WIDTH}`
          && `"><Text text="Progress"/></Column><Column visible="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/7/VISIBL`
          && `E}" mergeDuplicates="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/7/MERGE}" width="{/MO_LAYOUT/MS_LAYOUT`
          && `/T_LAYOUT/7/WIDTH}"><Text text="Radial"/></Column><Column visible="{/MO_LAYOUT/MS_LAYOUT/T`
          && `_LAYOUT/8/VISIBLE}" mergeDuplicates="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/8/MERGE}" width="{/MO_`
          && `LAYOUT/MS_LAYOUT/T_LAYOUT/8/WIDTH}"><Text text="Status"/></Column><Column visible="{/MO_LA`
          && `YOUT/MS_LAYOUT/T_LAYOUT/9/VISIBLE}" mergeDuplicates="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/9/MERG`
          && `E}" width="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/9/WIDTH}"><Text text="Sel"/></Column></columns><`
          && `items><ColumnListItem vAlign="Middle" selected="" type="Inactive" press=".eB(['ROW_SELECT'`
          && `])"><cells><ObjectIdentifier title="{path:'VBELN',type:'LayoDigitString',constraints:{isDi`
          && `gitSequence:true,maxLength:10}}" text="Material: {MATNR}&#xD;&#xA;Qty: {MENGE} {MEINS}&#xD`
          && `;&#xA;Icon: {ICON}"/><ObjectIdentifier text="{MATNR}"/><ObjectIdentifier text="{MENGE} {ME`
          && `INS}"/><ObjectIdentifier text="{MEINS}"/><core:Icon src="{ICON/SRC}" size="{ICON/ICON_SIZE`
          && `}"/><GenericTag text="{TAG/TEXT}" design="{TAG/DESIGN}" status="{TAG/STATUS}"/><ProgressIn`
          && `dicator class="sapUiSmallMarginBottom" percentValue="{PROGRESS/PERCENTVALUE}" displayValue`
          && `="{PROGRESS/DISPLAYVALUE}" showValue="{PROGRESS/SHOWVALUE}" state="{PROGRESS/STATE}"/><mch`
          && `art:RadialMicroChart size="{RADIAL/RADIALMICROCHART_SIZE}" percentage="{RADIAL/PERCENTAGE}`
          && `" valueColor="{RADIAL/VALUECOLOR}" hideOnNoData="{RADIAL/HIDEONNODATA}"/><si:StatusIndicat`
          && `or class="{STATUS/CLASS}" size="{STATUS/STATUSINDICATOR_SIZE}" value="{STATUS/VALUE}"><si:`
          && `propertyThresholds><si:PropertyThreshold fillColor="Good" toValue="{STATUS/FILLCOLOR_GOOD}`
          && `"/><si:PropertyThreshold fillColor="Critical" toValue="{STATUS/FILLCOLOR_CRITICAL}"/><si:P`
          && `ropertyThreshold fillColor="Error" toValue="{STATUS/FILLCOLOR_ERROR}"/></si:propertyThresh`
          && `olds><si:ShapeGroup><si:LibraryShape shapeId="{STATUS/SHAPEID}"/></si:ShapeGroup></si:Stat`
          && `usIndicator><ObjectIdentifier text="{SELKZ}"/></cells></ColumnListItem></items></Table>`.

  ENDMETHOD.

  METHOD golden_options.

    result = `<Table growing="true" growingThreshold="50" width="auto" mode="MultiSelect" items="{/MT_DA`
          && `TA}" selectionChange=".eB(['SELECTION_CHANGE'])" xmlns:core="sap.ui.core" core:require="{L`
          && `ayoDigitString:'sap/ui/model/odata/type/String'}"><headerToolbar><OverflowToolbar><Title t`
          && `ext="Orders" level="H2"/><ToolbarSpacer/><SearchField value="{/MV_SEARCH}" search=".eB(['S`
          && `EARCH'])" change=".eB(['SEARCH'])" id="SEARCH" width="17.5rem"/><Button icon="sap-icon://a`
          && `ction-settings" press=".eB(['GUID1'])"/></OverflowToolbar></headerToolbar><columns><Column`
          && ` visible="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/0/VISIBLE}" mergeDuplicates="{/MO_LAYOUT/MS_LAYOU`
          && `T/T_LAYOUT/0/MERGE}" width="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/0/WIDTH}"><Text text="Order"/><`
          && `/Column><Column visible="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/1/VISIBLE}" mergeDuplicates="{/MO_`
          && `LAYOUT/MS_LAYOUT/T_LAYOUT/1/MERGE}" width="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/1/WIDTH}"><Text `
          && `text="Material"/></Column><Column visible="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/2/VISIBLE}" merg`
          && `eDuplicates="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/2/MERGE}" width="{/MO_LAYOUT/MS_LAYOUT/T_LAYOU`
          && `T/2/WIDTH}"><Text text="Qty"/></Column><Column visible="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/3/V`
          && `ISIBLE}" mergeDuplicates="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/3/MERGE}" width="{/MO_LAYOUT/MS_L`
          && `AYOUT/T_LAYOUT/3/WIDTH}"><Text text="Unit"/></Column><Column visible="{/MO_LAYOUT/MS_LAYOU`
          && `T/T_LAYOUT/4/VISIBLE}" mergeDuplicates="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/4/MERGE}" width="{/`
          && `MO_LAYOUT/MS_LAYOUT/T_LAYOUT/4/WIDTH}"><Text text="Icon"/></Column><Column visible="{/MO_L`
          && `AYOUT/MS_LAYOUT/T_LAYOUT/5/VISIBLE}" mergeDuplicates="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/5/MER`
          && `GE}" width="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/5/WIDTH}"><Text text="Tag"/></Column><Column vi`
          && `sible="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/6/VISIBLE}" mergeDuplicates="{/MO_LAYOUT/MS_LAYOUT/T`
          && `_LAYOUT/6/MERGE}" width="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/6/WIDTH}"><Text text="Progress"/><`
          && `/Column><Column visible="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/7/VISIBLE}" mergeDuplicates="{/MO_`
          && `LAYOUT/MS_LAYOUT/T_LAYOUT/7/MERGE}" width="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/7/WIDTH}"><Text `
          && `text="Radial"/></Column><Column visible="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/8/VISIBLE}" mergeD`
          && `uplicates="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/8/MERGE}" width="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/`
          && `8/WIDTH}"><Text text="Status"/></Column><Column visible="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/9/`
          && `VISIBLE}" mergeDuplicates="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/9/MERGE}" width="{/MO_LAYOUT/MS_`
          && `LAYOUT/T_LAYOUT/9/WIDTH}"><Text text="Sel"/></Column></columns><items><ColumnListItem vAli`
          && `gn="Middle" selected="{SELKZ}" type="Active" press=".eB(['ROW_SELECT'], ${VBELN})"><cells>`
          && `<ObjectIdentifier title="{path:'VBELN',type:'LayoDigitString',constraints:{isDigitSequence`
          && `:true,maxLength:10}}" text="Material: {MATNR}&#xD;&#xA;Qty: {MENGE} {MEINS}&#xD;&#xA;Icon:`
          && ` {ICON}"/><ObjectIdentifier text="{MATNR}"/><ObjectIdentifier text="{MENGE} {MEINS}"/><Obj`
          && `ectIdentifier text="{MEINS}"/><core:Icon src="{ICON/SRC}" size="{ICON/ICON_SIZE}"/><Generi`
          && `cTag text="{TAG/TEXT}" design="{TAG/DESIGN}" status="{TAG/STATUS}"/><ProgressIndicator cla`
          && `ss="sapUiSmallMarginBottom" percentValue="{PROGRESS/PERCENTVALUE}" displayValue="{PROGRESS`
          && `/DISPLAYVALUE}" showValue="{PROGRESS/SHOWVALUE}" state="{PROGRESS/STATE}"/><mchart:RadialM`
          && `icroChart size="{RADIAL/RADIALMICROCHART_SIZE}" percentage="{RADIAL/PERCENTAGE}" valueColo`
          && `r="{RADIAL/VALUECOLOR}" hideOnNoData="{RADIAL/HIDEONNODATA}"/><si:StatusIndicator class="{`
          && `STATUS/CLASS}" size="{STATUS/STATUSINDICATOR_SIZE}" value="{STATUS/VALUE}"><si:propertyThr`
          && `esholds><si:PropertyThreshold fillColor="Good" toValue="{STATUS/FILLCOLOR_GOOD}"/><si:Prop`
          && `ertyThreshold fillColor="Critical" toValue="{STATUS/FILLCOLOR_CRITICAL}"/><si:PropertyThre`
          && `shold fillColor="Error" toValue="{STATUS/FILLCOLOR_ERROR}"/></si:propertyThresholds><si:Sh`
          && `apeGroup><si:LibraryShape shapeId="{STATUS/SHAPEID}"/></si:ShapeGroup></si:StatusIndicator`
          && `><ObjectIdentifier text="{SELKZ}"/></cells></ColumnListItem></items></Table>`.

  ENDMETHOD.

ENDCLASS.
