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

    TYPES temp1_6e95141e6c TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.
DATA mt_data   TYPE temp1_6e95141e6c.
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

    TYPES temp2_03c362f023 TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.
DATA mt_data   TYPE temp2_03c362f023.
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

    DATA temp1 TYPE z2ui5_cl_layo_manager=>ty_s_positions.
    CLEAR temp1.
    temp1-fname = `MATNR`.
    cl_abap_unit_assert=>assert_equals(
        exp = `{MATNR}`
        act = z2ui5_cl_layo_xml_builder=>table_value_formatter( temp1 ) ).

  ENDMETHOD.

  METHOD cell_namespaced_name.

    " the model writes /CWM/XCWMAT as a level of the row - a relative path,
    " never {/CWM/XCWMAT}, which UI5 reads from the model root
    DATA temp2 TYPE z2ui5_cl_layo_manager=>ty_s_positions.
    CLEAR temp2.
    temp2-fname = `/CWM/XCWMAT`.
    cl_abap_unit_assert=>assert_equals(
        exp = `{CWM/XCWMAT}`
        act = z2ui5_cl_layo_xml_builder=>table_value_formatter( temp2 ) ).

  ENDMETHOD.

  METHOD icon_namespaced_name.

    " the table case renders bindings only - it reads nothing from the client
    DATA client TYPE REF TO z2ui5_if_client.

    DATA position TYPE z2ui5_cl_layo_manager=>ty_s_positions.
    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA temp3 LIKE REF TO position.
    DATA xml TYPE string.
    position-fname = `/CWM/ICON`.

    view = z2ui5_cl_ui5_view_builder=>factory( ).


    GET REFERENCE OF position INTO temp3.
z2ui5_cl_layo_xml_builder=>xml_build_icon( i_client = client
                                               i_layout = temp3
                                               i_xml    = view ).


    xml = view->stringify( ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*src="{CWM/ICON/SRC}"*`
                                         act = xml ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*size="{CWM/ICON/ICON_SIZE}"*`
                                         act = xml ).

  ENDMETHOD.

  METHOD cell_alpha_digit_type.

    " ALPHA on a CHAR column: the browser strips and pads the zeros
    DATA temp4 TYPE z2ui5_cl_layo_manager=>ty_s_positions.
    CLEAR temp4.
    temp4-fname = `VBELN`.
    temp4-convexit = `ALPHA`.
    temp4-digits = 10.
    cl_abap_unit_assert=>assert_equals(
        exp = `{path:'VBELN',type:'LayoDigitString',constraints:{isDigitSequence:true,maxLength:10}}`
        act = z2ui5_cl_layo_xml_builder=>table_value_formatter( temp4 ) ).

  ENDMETHOD.

  METHOD cell_numc_namespaced.

    DATA temp5 TYPE z2ui5_cl_layo_manager=>ty_s_positions.
    CLEAR temp5.
    temp5-fname = `/CWM/NR`.
    temp5-convexit = `NUMC`.
    temp5-digits = 8.
    cl_abap_unit_assert=>assert_equals(
        exp = `{path:'CWM/NR',type:'LayoDigitString',constraints:{isDigitSequence:true,maxLength:8}}`
        act = z2ui5_cl_layo_xml_builder=>table_value_formatter( temp5 ) ).

  ENDMETHOD.

  METHOD cell_conversion_switched_off.

    " the user switched the conversion off in the layout popup
    DATA temp6 TYPE z2ui5_cl_layo_manager=>ty_s_positions.
    CLEAR temp6.
    temp6-fname = `VBELN`.
    temp6-convexit = `ALPHA`.
    temp6-digits = 10.
    temp6-no_convexit = abap_true.
    cl_abap_unit_assert=>assert_equals(
        exp = `{VBELN}`
        act = z2ui5_cl_layo_xml_builder=>table_value_formatter( temp6 ) ).

  ENDMETHOD.

  METHOD cell_other_exit_plain.

    " CUNIT, MATN1, ... stay a conversion in ABAP - a plain binding
    DATA temp7 TYPE z2ui5_cl_layo_manager=>ty_s_positions.
    CLEAR temp7.
    temp7-fname = `MATNR`.
    temp7-convexit = `MATN1`.
    cl_abap_unit_assert=>assert_equals(
        exp = `{MATNR}`
        act = z2ui5_cl_layo_xml_builder=>table_value_formatter( temp7 ) ).

  ENDMETHOD.

  METHOD require_on_control.

    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA table TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA xml TYPE string.
    view = z2ui5_cl_ui5_view_builder=>factory( ).

    table = view->ele( `Table` ).

    z2ui5_cl_layo_xml_builder=>set_digit_type_require( table ).


    xml = view->stringify( ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*xmlns:core="sap.ui.core"*`
                                         act = xml ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*core:require="{LayoDigitString:*sap/ui/model/odata/type/String*}"*`
                                         act = xml ).

  ENDMETHOD.

  METHOD require_only_with_digits.

    DATA layout TYPE REF TO z2ui5_cl_layo_manager.
    DATA temp8 TYPE z2ui5_cl_layo_manager=>ty_t_positions.
    DATA temp9 LIKE LINE OF temp8.
    FIELD-SYMBOLS <temp10> LIKE LINE OF layout->ms_layout-t_layout.
    DATA temp11 LIKE sy-tabix.
    CREATE OBJECT layout TYPE z2ui5_cl_layo_manager.

    CLEAR temp8.

    CLEAR temp9.
    temp9-fname = `MATNR`.
    temp9-convexit = `MATN1`.
    INSERT temp9 INTO TABLE temp8.
    CLEAR temp9.
    temp9-fname = `VBELN`.
    temp9-convexit = `ALPHA`.
    temp9-digits = 10.
    temp9-no_convexit = abap_true.
    INSERT temp9 INTO TABLE temp8.
    layout->ms_layout-t_layout = temp8.

    cl_abap_unit_assert=>assert_false( z2ui5_cl_layo_xml_builder=>check_digit_type( layout ) ).



    temp11 = sy-tabix.
    READ TABLE layout->ms_layout-t_layout INDEX 2 ASSIGNING <temp10>.
    sy-tabix = temp11.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    <temp10>-no_convexit = abap_false.

    cl_abap_unit_assert=>assert_true( z2ui5_cl_layo_xml_builder=>check_digit_type( layout ) ).

  ENDMETHOD.

  METHOD setup.
    DATA temp12 LIKE mo_app->mt_data.
    DATA temp13 LIKE LINE OF temp12.
    DATA temp14 TYPE z2ui5_cl_layo_manager=>ty_t_positions.
    DATA temp15 LIKE LINE OF temp14.
    DATA temp1 TYPE z2ui5_cl_layo_manager=>ty_t_sub_columns.
    DATA temp2 LIKE LINE OF temp1.
    DATA temp3 TYPE z2ui5_cl_layo_manager=>ty_t_sub_columns.
    DATA temp4 LIKE LINE OF temp3.

    CREATE OBJECT mo_app.

    CLEAR temp12.

    temp13-vbeln = `4711`.
    temp13-matnr = `M1`.
    temp13-menge = 1.
    temp13-meins = `ST`.
    INSERT temp13 INTO TABLE temp12.
    mo_app->mt_data = temp12.

    CREATE OBJECT mo_app->mo_layout.
    mo_app->mo_layout->ms_layout-s_head-guid = `GUID1`.

    CLEAR temp14.

    CLEAR temp15.
    temp15-fname = `VBELN`.
    temp15-rollname = `VBELN`.
    temp15-visible = abap_true.
    temp15-tlabel = `Order`.
    temp15-convexit = `ALPHA`.
    temp15-digits = 10.

    CLEAR temp1.

    temp2-fname = `MATNR`.
    INSERT temp2 INTO TABLE temp1.
    temp2-fname = `MENGE`.
    INSERT temp2 INTO TABLE temp1.
    temp2-fname = `ICON`.
    INSERT temp2 INTO TABLE temp1.
    temp15-t_sub_col = temp1.
    INSERT temp15 INTO TABLE temp14.
    CLEAR temp15.
    temp15-fname = `MATNR`.
    temp15-rollname = `MATNR`.
    temp15-visible = abap_true.
    temp15-tlabel = `Material`.
    INSERT temp15 INTO TABLE temp14.
    CLEAR temp15.
    temp15-fname = `MENGE`.
    temp15-rollname = `MENGE`.
    temp15-visible = abap_true.
    temp15-tlabel = `Qty`.
    temp15-reference_field = `MEINS`.
    INSERT temp15 INTO TABLE temp14.
    CLEAR temp15.
    temp15-fname = `MEINS`.
    temp15-rollname = `MEINS`.
    temp15-tlabel = `Unit`.
    INSERT temp15 INTO TABLE temp14.
    CLEAR temp15.
    temp15-fname = `ICON`.
    temp15-rollname = `Z2UI5_XML_S_ICON`.
    temp15-visible = abap_true.
    temp15-tlabel = `Icon`.

    CLEAR temp3.

    temp4-fname = `MATNR`.
    INSERT temp4 INTO TABLE temp3.
    temp15-t_sub_col = temp3.
    INSERT temp15 INTO TABLE temp14.
    CLEAR temp15.
    temp15-fname = `TAG`.
    temp15-rollname = `Z2UI5_XML_S_GENERICTAG`.
    temp15-tlabel = `Tag`.
    INSERT temp15 INTO TABLE temp14.
    CLEAR temp15.
    temp15-fname = `PROGRESS`.
    temp15-rollname = `Z2UI5_XML_S_PROGRESSIND`.
    temp15-tlabel = `Progress`.
    INSERT temp15 INTO TABLE temp14.
    CLEAR temp15.
    temp15-fname = `RADIAL`.
    temp15-rollname = `Z2UI5_XML_S_RADIALCHART`.
    temp15-tlabel = `Radial`.
    INSERT temp15 INTO TABLE temp14.
    CLEAR temp15.
    temp15-fname = `STATUS`.
    temp15-rollname = `Z2UI5_XML_S_STATUSIND`.
    temp15-tlabel = `Status`.
    INSERT temp15 INTO TABLE temp14.
    CLEAR temp15.
    temp15-fname = `SELKZ`.
    temp15-rollname = `XSDBOOLEAN`.
    temp15-tlabel = `Sel`.
    INSERT temp15 INTO TABLE temp14.
    mo_app->mo_layout->ms_layout-t_layout = temp14.

    client_for( mo_app ).

  ENDMETHOD.

  METHOD client_for.

    DATA temp5 TYPE REF TO z2ui5_cl_ui5_handler.
    CREATE OBJECT temp5 TYPE z2ui5_cl_ui5_handler EXPORTING val = ``.
    CREATE OBJECT mo_action EXPORTING val = temp5.
    mo_action->mo_app->mo_app = app.
    CREATE OBJECT mi_client TYPE z2ui5_cl_ui5_client EXPORTING action = mo_action.

  ENDMETHOD.

  METHOD render_table.

    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
      DATA temp16 LIKE REF TO mo_app->mt_data.
      DATA temp17 LIKE REF TO mo_app->mv_search.
DATA temp6 LIKE REF TO mo_app->mt_data.
    view = z2ui5_cl_ui5_view_builder=>factory( ).

    IF i_options = abap_false.

      GET REFERENCE OF mo_app->mt_data INTO temp16.
z2ui5_cl_layo_xml_builder=>xml_build_table( i_data   = temp16
                                                  i_xml    = view
                                                  i_client = mi_client
                                                  i_layout = mo_app->mo_layout ).
    ELSE.

      GET REFERENCE OF mo_app->mv_search INTO temp17.

GET REFERENCE OF mo_app->mt_data INTO temp6.
z2ui5_cl_layo_xml_builder=>xml_build_table( i_data             = temp6
                                                  i_xml              = view
                                                  i_client           = mi_client
                                                  i_layout           = mo_app->mo_layout
                                                  i_search_value     = temp17
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

    DATA app TYPE REF TO ltcl_app_cells.
    DATA temp18 LIKE app->mt_data.
    DATA temp19 LIKE LINE OF temp18.
    DATA temp20 TYPE z2ui5_cl_layo_manager=>ty_t_positions.
    DATA temp21 LIKE LINE OF temp20.
    DATA temp7 TYPE z2ui5_cl_layo_manager=>ty_t_sub_columns.
    DATA temp8 LIKE LINE OF temp7.
    DATA temp9 TYPE z2ui5_cl_layo_manager=>ty_t_sub_columns.
    DATA temp10 LIKE LINE OF temp9.
    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA temp22 LIKE REF TO app->mt_data.
DATA temp11 TYPE z2ui5_cl_layo_xml_builder=>ty_t_cell_control.
DATA temp12 LIKE LINE OF temp11.
    CREATE OBJECT app TYPE ltcl_app_cells.

    CLEAR temp18.

    temp19-matnr = `M1`.
    INSERT temp19 INTO TABLE temp18.
    app->mt_data = temp18.
    CREATE OBJECT app->mo_layout.
    app->mo_layout->ms_layout-s_head-guid = `GUID2`.

    CLEAR temp20.

    CLEAR temp21.
    temp21-fname = `MATNR`.
    temp21-rollname = `MATNR`.
    temp21-tlabel = `Material`.

    CLEAR temp7.

    temp8-fname = `SWITCH`.
    INSERT temp8 INTO TABLE temp7.
    temp8-fname = `ICON`.
    INSERT temp8 INTO TABLE temp7.
    temp21-t_sub_col = temp7.
    INSERT temp21 INTO TABLE temp20.
    CLEAR temp21.
    temp21-fname = `SWITCH`.
    temp21-rollname = `Z2UI5_XML_S_SWITCH`.
    temp21-tlabel = `Switch`.
    INSERT temp21 INTO TABLE temp20.
    CLEAR temp21.
    temp21-fname = `INPUT`.
    temp21-rollname = `Z2UI5_XML_S_INPUT`.
    temp21-tlabel = `Input`.
    INSERT temp21 INTO TABLE temp20.
    CLEAR temp21.
    temp21-fname = `BUTTON`.
    temp21-rollname = `Z2UI5_XML_S_BUTTON`.
    temp21-tlabel = `Button`.

    CLEAR temp9.

    temp10-fname = `MATNR`.
    INSERT temp10 INTO TABLE temp9.
    temp21-t_sub_col = temp9.
    INSERT temp21 INTO TABLE temp20.
    CLEAR temp21.
    temp21-fname = `OWN_ICON`.
    temp21-rollname = `TY_S_OWN_ICON`.
    temp21-tlabel = `Own icon`.
    INSERT temp21 INTO TABLE temp20.
    CLEAR temp21.
    temp21-fname = `OWN_RADIAL`.
    temp21-rollname = `TY_S_OWN_RADIAL`.
    temp21-tlabel = `Own radial`.
    INSERT temp21 INTO TABLE temp20.
    CLEAR temp21.
    temp21-fname = `ICON`.
    temp21-rollname = `Z2UI5_XML_S_ICON`.
    temp21-tlabel = `Icon`.
    INSERT temp21 INTO TABLE temp20.
    app->mo_layout->ms_layout-t_layout = temp20.

    client_for( app ).


    view = z2ui5_cl_ui5_view_builder=>factory( ).


    GET REFERENCE OF app->mt_data INTO temp22.

CLEAR temp11.

temp12-rollname = `TY_S_OWN_ICON`.
temp12-control = z2ui5_cl_layo_xml_builder=>cs_cell_control-icon.
INSERT temp12 INTO TABLE temp11.
temp12-rollname = `TY_S_OWN_RAD*`.
temp12-control = z2ui5_cl_layo_xml_builder=>cs_cell_control-radial_chart.
INSERT temp12 INTO TABLE temp11.
z2ui5_cl_layo_xml_builder=>xml_build_table(
        i_data             = temp22
        i_xml              = view
        i_client           = mi_client
        i_layout           = app->mo_layout
        i_sub_col_controls = i_sub_col_controls
        i_t_cell_control   = temp11 ).

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
    DATA temp23 TYPE z2ui5_cl_layo_xml_builder=>ty_t_cell_control.
    DATA temp24 LIKE LINE OF temp23.
    DATA t_cell_control LIKE temp23.

    " the built-in patterns
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_cl_layo_xml_builder=>cs_cell_control-icon
                                        act = z2ui5_cl_layo_xml_builder=>cell_control( `Z2UI5_XML_S_ICON` ) ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_cl_layo_xml_builder=>cs_cell_control-switch
                                        act = z2ui5_cl_layo_xml_builder=>cell_control( `ZMY_XML_S_SWITCH` ) ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_cl_layo_xml_builder=>cs_cell_control-text
                                        act = z2ui5_cl_layo_xml_builder=>cell_control( `MATNR` ) ).

    " the app's entries first - a rollname of its own, a namespace, and a
    " built-in one drawn as text instead

    CLEAR temp23.

    temp24-rollname = `/ABC/S_SWITCH`.
    temp24-control = z2ui5_cl_layo_xml_builder=>cs_cell_control-switch.
    INSERT temp24 INTO TABLE temp23.
    temp24-rollname = `Z2UI5_XML_S_ICON`.
    temp24-control = z2ui5_cl_layo_xml_builder=>cs_cell_control-text.
    INSERT temp24 INTO TABLE temp23.

    t_cell_control = temp23.

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

    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA temp25 LIKE REF TO mo_app->mt_data.
    DATA xml TYPE string.
    DATA temp1 TYPE xsdboolean.
    view = z2ui5_cl_ui5_view_builder=>factory( ).

    GET REFERENCE OF mo_app->mt_data INTO temp25.
z2ui5_cl_layo_xml_builder=>xml_build_table( i_data           = temp25
                                                i_xml            = view
                                                i_client         = mi_client
                                                i_layout         = mo_app->mo_layout
                                                i_col_sort       = abap_true
                                                i_col_sort_class = `myColSort` ).

    xml = view->stringify( ).

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

    temp1 = boolc( xml CS `<Text text="Order"/>` ).
    cl_abap_unit_assert=>assert_false( temp1 ).

  ENDMETHOD.

  METHOD col_sort_event.

    " the order of the rows is sort( )'s business - and the transpiled
    " runtime drops its dynamic SORT BY (sortorder): checked here is what
    " the event does to the layout
    FIELD-SYMBOLS <temp26> LIKE LINE OF mo_app->mo_layout->ms_layout-t_layout.
    DATA temp27 LIKE sy-tabix.
    DATA temp28 TYPE string_table.
    DATA temp30 LIKE REF TO mo_app->mt_data.
    FIELD-SYMBOLS <temp31> LIKE LINE OF mo_app->mo_layout->ms_layout-t_layout.
    DATA temp32 LIKE sy-tabix.
    FIELD-SYMBOLS <temp33> LIKE LINE OF mo_app->mo_layout->ms_layout-t_layout.
    DATA temp34 LIKE sy-tabix.
    DATA temp35 LIKE REF TO mo_app->mt_data.
    FIELD-SYMBOLS <temp36> LIKE LINE OF mo_app->mo_layout->ms_layout-t_layout.
    DATA temp37 LIKE sy-tabix.
    DATA temp38 LIKE REF TO mo_app->mt_data.
    FIELD-SYMBOLS <temp39> LIKE LINE OF mo_app->mo_layout->ms_layout-t_layout.
    DATA temp40 LIKE sy-tabix.
    temp27 = sy-tabix.
    READ TABLE mo_app->mo_layout->ms_layout-t_layout WITH KEY fname = `VBELN` ASSIGNING <temp26>.
    sy-tabix = temp27.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    <temp26>-sorting = `ASCENDING`.

    mo_action->ms_actual-event       = z2ui5_cl_layo_xml_builder=>cv_event_column_sort.

    CLEAR temp28.
    INSERT `GUID1` INTO TABLE temp28.
    INSERT `MATNR` INTO TABLE temp28.
    mo_action->ms_actual-t_event_arg = temp28.

    " the popup's event handler takes it as well - and opens no popup

    GET REFERENCE OF mo_app->mt_data INTO temp30.
z2ui5_cl_layo_pop=>on_event_layout( client = mi_client
                                        layout = mo_app->mo_layout
                                        data   = temp30 ).



    temp32 = sy-tabix.
    READ TABLE mo_app->mo_layout->ms_layout-t_layout WITH KEY fname = `MATNR` ASSIGNING <temp31>.
    sy-tabix = temp32.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `ASCENDING`
                                        act = <temp31>-sorting ).
    " sorted by the column clicked last only


    temp34 = sy-tabix.
    READ TABLE mo_app->mo_layout->ms_layout-t_layout WITH KEY fname = `VBELN` ASSIGNING <temp33>.
    sy-tabix = temp34.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_initial( <temp33>-sorting ).
    cl_abap_unit_assert=>assert_initial( mo_action->ms_next-o_app_call ).

    " the second click: descending

    GET REFERENCE OF mo_app->mt_data INTO temp35.
cl_abap_unit_assert=>assert_true( z2ui5_cl_layo_xml_builder=>on_event_column_sort(
                                          client = mi_client
                                          layout = mo_app->mo_layout
                                          data   = temp35 ) ).


    temp37 = sy-tabix.
    READ TABLE mo_app->mo_layout->ms_layout-t_layout WITH KEY fname = `MATNR` ASSIGNING <temp36>.
    sy-tabix = temp37.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `DESCENDING`
                                        act = <temp36>-sorting ).

    " the third: no sorting

    GET REFERENCE OF mo_app->mt_data INTO temp38.
z2ui5_cl_layo_xml_builder=>on_event_column_sort( client = mi_client
                                                     layout = mo_app->mo_layout
                                                     data   = temp38 ).


    temp40 = sy-tabix.
    READ TABLE mo_app->mo_layout->ms_layout-t_layout WITH KEY fname = `MATNR` ASSIGNING <temp39>.
    sy-tabix = temp40.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_initial( <temp39>-sorting ).

  ENDMETHOD.

  METHOD col_sort_other_layout.
    DATA temp41 TYPE string_table.
    DATA temp43 TYPE string_table.

    " the column sort of another table, and an unknown column
    mo_action->ms_actual-event       = z2ui5_cl_layo_xml_builder=>cv_event_column_sort.

    CLEAR temp41.
    INSERT `GUID2` INTO TABLE temp41.
    INSERT `MATNR` INTO TABLE temp41.
    mo_action->ms_actual-t_event_arg = temp41.

    cl_abap_unit_assert=>assert_false( z2ui5_cl_layo_xml_builder=>on_event_column_sort(
                                           client = mi_client
                                           layout = mo_app->mo_layout ) ).


    CLEAR temp43.
    INSERT `GUID1` INTO TABLE temp43.
    INSERT `NOPE` INTO TABLE temp43.
    mo_action->ms_actual-t_event_arg = temp43.

    cl_abap_unit_assert=>assert_false( z2ui5_cl_layo_xml_builder=>on_event_column_sort(
                                           client = mi_client
                                           layout = mo_app->mo_layout ) ).
    cl_abap_unit_assert=>assert_false( mo_app->mo_layout->toggle_sorting( `NOPE` ) ).

  ENDMETHOD.

  METHOD row_color.

    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA temp45 LIKE REF TO mo_app->mt_data.
    view = z2ui5_cl_ui5_view_builder=>factory( ).

    GET REFERENCE OF mo_app->mt_data INTO temp45.
z2ui5_cl_layo_xml_builder=>xml_build_table( i_data      = temp45
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

    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA temp46 LIKE REF TO mo_app->mt_data.
    view = z2ui5_cl_ui5_view_builder=>factory( ).

    GET REFERENCE OF mo_app->mt_data INTO temp46.
z2ui5_cl_layo_xml_builder=>xml_build_table( i_data      = temp46
                                                i_xml       = view
                                                i_client    = mi_client
                                                i_layout    = mo_app->mo_layout
                                                i_sel_event = `ROW_SELECT` ).

    cl_abap_unit_assert=>assert_char_cp( exp = `*selectionChange=".eB(['ROW_SELECT'])"*`
                                         act = view->stringify( ) ).

  ENDMETHOD.

  METHOD switch_input_button.

    DATA xml TYPE string.
    DATA temp2 TYPE xsdboolean.
    xml = render_cells( ).

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

    temp2 = boolc( xml CS `<VBox` ).
    cl_abap_unit_assert=>assert_false( temp2 ).

  ENDMETHOD.

  METHOD grid_span_beside_ref_field.

    " a value span the reference field takes up completely is still a span
    " of 1 - XL0 or S0 is none the grid takes
    DATA temp47 TYPE z2ui5_cl_layo_manager=>ty_s_positions.
    DATA position LIKE temp47.
    DATA temp48 LIKE REF TO position.
DATA grid_layout TYPE z2ui5_cl_layo_xml_builder=>ty_s_grid_layout.
    CLEAR temp47.
    temp47-reference_field = `WAERS`.
    temp47-grid_value_xl = `1`.
    temp47-grid_value_l = `4`.
    temp47-grid_value_m = `1`.
    temp47-grid_value_s = `2`.

    position = temp47.


    GET REFERENCE OF position INTO temp48.

grid_layout = z2ui5_cl_layo_xml_builder=>get_grid_layout( temp48 ).

    cl_abap_unit_assert=>assert_equals( exp = `XL1 L3 M1 S1`
                                        act = grid_layout-value ).
    cl_abap_unit_assert=>assert_equals( exp = `XL1 L1 M1 S2`
                                        act = grid_layout-ref_field ).

  ENDMETHOD.

  METHOD own_structures.

    DATA xml TYPE string.
    xml = render_cells( ).

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

    DATA xml TYPE string.
    DATA temp3 TYPE xsdboolean.
    xml = render_cells( abap_true ).

    " a text column with control subcolumns: its value, then the controls
    cl_abap_unit_assert=>assert_char_cp(
        exp = `*<cells><VBox><ObjectIdentifier text="{MATNR}"/><Switch *<core:Icon src="{ICON/SRC}" size="{ICON/ICON_SIZE}"/></VBox>*`
        act = xml ).
    " a control column with a text subcolumn: the control, then the text
    cl_abap_unit_assert=>assert_char_cp(
        exp = `*<VBox><Button *"/><ObjectIdentifier text="Material: {MATNR}"/></VBox>*`
        act = xml ).
    " the text of the subcolumns leaves the controls out

    temp3 = boolc( xml CS `Switch: ` ).
    cl_abap_unit_assert=>assert_false( temp3 ).

  ENDMETHOD.

  METHOD table_without_toolbar.

    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA temp49 LIKE REF TO mo_app->mv_search.
DATA temp13 LIKE REF TO mo_app->mt_data.
    DATA exp TYPE string.
    view = z2ui5_cl_ui5_view_builder=>factory( ).

    GET REFERENCE OF mo_app->mv_search INTO temp49.

GET REFERENCE OF mo_app->mt_data INTO temp13.
z2ui5_cl_layo_xml_builder=>xml_build_table( i_data         = temp13
                                                i_xml          = view
                                                i_client       = mi_client
                                                i_layout       = mo_app->mo_layout
                                                i_search_value = temp49
                                                i_headertext   = `Orders`
                                                i_toolbar      = abap_false ).

    " the default table without its toolbar - no title, no search field, no
    " settings button - and the header text on the table itself

    exp = replace( val  = golden_default( )
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
