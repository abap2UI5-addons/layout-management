CLASS ltcl_pop_w_sel DEFINITION DEFERRED.
CLASS z2ui5_cl_layo_pop_w_sel DEFINITION LOCAL FRIENDS ltcl_pop_w_sel.

CLASS ltcl_pop_w_sel DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_s_row,
        product  TYPE string,
        quantity TYPE i,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.

    METHODS rows
      RETURNING
        VALUE(result) TYPE ty_t_row.

    "! the popup as factory( ) builds it, with a layout of the given columns
    "! instead of the one z2ui5_cl_layo_manager=>factory( ) reads - that one
    "! needs the DDIC, which the transpiled runtime does not have
    METHODS new_cut
      IMPORTING
        !tab          TYPE STANDARD TABLE
        multiselect   TYPE abap_bool OPTIONAL
        !columns      TYPE string_table
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_layo_pop_w_sel.

    "! set the selection flag of the row with this id among the rows on screen
    METHODS select_on_screen
      IMPORTING
        cut    TYPE REF TO z2ui5_cl_layo_pop_w_sel
        row_id TYPE i.

    METHODS default_handles FOR TESTING.
    METHODS explicit_handles_kept FOR TESTING.
    METHODS result_typed FOR TESTING.
    METHODS multi_keeps_sel_over_search FOR TESTING.
    METHODS single_row_pressed FOR TESTING.
    METHODS single_selection_replaced FOR TESTING.
    METHODS elementary_line FOR TESTING.
ENDCLASS.


CLASS ltcl_pop_w_sel IMPLEMENTATION.

  METHOD rows.

    DATA temp1 TYPE ltcl_pop_w_sel=>ty_t_row.
    DATA temp2 LIKE LINE OF temp1.
    CLEAR temp1.

    temp2-product = `Table 1`.
    temp2-quantity = 10.
    INSERT temp2 INTO TABLE temp1.
    temp2-product = `Chair 2`.
    temp2-quantity = 20.
    INSERT temp2 INTO TABLE temp1.
    temp2-product = `Sofa 3`.
    temp2-quantity = 30.
    INSERT temp2 INTO TABLE temp1.
    temp2-product = `Lamp 4`.
    temp2-quantity = 40.
    INSERT temp2 INTO TABLE temp1.
    result = temp1.

  ENDMETHOD.

  METHOD new_cut.
    DATA column LIKE LINE OF columns.
      DATA temp3 TYPE z2ui5_cl_layo_manager=>ty_s_positions.

    CREATE OBJECT result.
    result->multiselect = multiselect.
    result->set_input( tab ).

    CREATE OBJECT result->mo_layout.

    LOOP AT columns INTO column.

      CLEAR temp3.
      temp3-fname = column.
      temp3-visible = abap_true.
      INSERT temp3 INTO TABLE result->mo_layout->ms_layout-t_layout.
    ENDLOOP.

  ENDMETHOD.

  METHOD select_on_screen.

    FIELD-SYMBOLS <tab>    TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row>    TYPE any.
    FIELD-SYMBOLS <row_id> TYPE any.
    FIELD-SYMBOLS <selkz>  TYPE any.

    ASSIGN cut->mr_out->* TO <tab>.
    LOOP AT <tab> ASSIGNING <row>.
      ASSIGN COMPONENT `ZZROW_ID` OF STRUCTURE <row> TO <row_id>.
      cl_abap_unit_assert=>assert_subrc( ).
      IF <row_id> = row_id.
        ASSIGN COMPONENT `ZZSELKZ` OF STRUCTURE <row> TO <selkz>.
        cl_abap_unit_assert=>assert_subrc( ).
        <selkz> = abap_true.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD default_handles.

    DATA row TYPE ty_s_row.

    DATA temp4 TYPE string_table.
    DATA cut TYPE REF TO z2ui5_cl_layo_pop_w_sel.
    DATA temp5 TYPE z2ui5_cl_layo_pop_w_sel=>ty_s_handles.
    DATA handles TYPE z2ui5_cl_layo_pop_w_sel=>ty_s_handles.
    CLEAR temp4.

    cut = new_cut( tab     = rows( )
                         columns = temp4 ).

    CLEAR temp5.

    handles = cut->get_handles( temp5 ).

    cl_abap_unit_assert=>assert_equals( exp = z2ui5_cl_layo_context=>rtti_get_classname_by_ref( cut )
                                        act = |{ handles-handle01 }| ).
    cl_abap_unit_assert=>assert_not_initial( handles-handle01 ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_typedescr=>describe_by_data( row )->get_relative_name( )
                                        act = |{ handles-handle02 }| ).
    cl_abap_unit_assert=>assert_initial( handles-handle03 ).
    cl_abap_unit_assert=>assert_initial( handles-handle04 ).

  ENDMETHOD.

  METHOD explicit_handles_kept.

    DATA temp6 TYPE string_table.
    DATA cut TYPE REF TO z2ui5_cl_layo_pop_w_sel.
    DATA temp7 TYPE z2ui5_cl_layo_pop_w_sel=>ty_s_handles.
    DATA handles TYPE z2ui5_cl_layo_pop_w_sel=>ty_s_handles.
    CLEAR temp6.

    cut = new_cut( tab     = rows( )
                         columns = temp6 ).

    CLEAR temp7.
    temp7-handle03 = `LTCL_POP_W_SEL`.

    handles = cut->get_handles( temp7 ).

    cl_abap_unit_assert=>assert_initial( handles-handle01 ).
    cl_abap_unit_assert=>assert_initial( handles-handle02 ).
    cl_abap_unit_assert=>assert_equals( exp = `LTCL_POP_W_SEL`
                                        act = |{ handles-handle03 }| ).

  ENDMETHOD.

  METHOD result_typed.

    FIELD-SYMBOLS <table> TYPE ty_t_row.
    FIELD-SYMBOLS <row>   TYPE ty_s_row.

    DATA temp8 TYPE string_table.
    DATA cut TYPE REF TO z2ui5_cl_layo_pop_w_sel.
    DATA result TYPE z2ui5_cl_layo_pop_w_sel=>ty_s_result.
    CLEAR temp8.

    cut = new_cut( tab         = rows( )
                         multiselect = abap_true
                         columns     = temp8 ).

    result = cut->result( ).

    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = result-check_confirmed ).
    ASSIGN result-table->* TO <table>.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_initial( <table> ).
    ASSIGN result-row->* TO <row>.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD multi_keeps_sel_over_search.

    FIELD-SYMBOLS <table> TYPE ty_t_row.
    FIELD-SYMBOLS <out>   TYPE STANDARD TABLE.

    DATA temp9 TYPE string_table.
    DATA cut TYPE REF TO z2ui5_cl_layo_pop_w_sel.
    DATA temp11 TYPE ty_t_row.
    DATA temp12 LIKE LINE OF temp11.
    CLEAR temp9.
    INSERT `PRODUCT` INTO TABLE temp9.
    INSERT `QUANTITY` INTO TABLE temp9.

    cut = new_cut( tab         = rows( )
                         multiselect = abap_true
                         columns     = temp9 ).
    cut->set_output_table( ).

    select_on_screen( cut    = cut
                      row_id = 4 ).
    select_on_screen( cut    = cut
                      row_id = 2 ).

    " a search hides the selected rows - case does not matter
    cut->mv_search_value = `sofa`.
    cut->on_event_search( ).
    ASSIGN cut->mr_out->* TO <out>.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( <out> ) ).
    select_on_screen( cut    = cut
                      row_id = 3 ).

    cut->mv_search_value = ``.
    cut->on_event_search( ).
    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = lines( <out> ) ).

    cut->sync_selection( ).
    cut->collect_result( ).

    ASSIGN cut->ms_result-table->* TO <table>.

    CLEAR temp11.

    temp12-product = `Chair 2`.
    temp12-quantity = 20.
    INSERT temp12 INTO TABLE temp11.
    temp12-product = `Sofa 3`.
    temp12-quantity = 30.
    INSERT temp12 INTO TABLE temp11.
    temp12-product = `Lamp 4`.
    temp12-quantity = 40.
    INSERT temp12 INTO TABLE temp11.
    cl_abap_unit_assert=>assert_equals( exp = temp11
                                        act = <table> ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = cut->result( )-check_confirmed ).

  ENDMETHOD.

  METHOD single_row_pressed.

    FIELD-SYMBOLS <table> TYPE ty_t_row.
    FIELD-SYMBOLS <row>   TYPE ty_s_row.

    DATA temp13 TYPE string_table.
    DATA cut TYPE REF TO z2ui5_cl_layo_pop_w_sel.
    DATA temp15 TYPE ty_t_row.
    DATA temp16 LIKE LINE OF temp15.
    CLEAR temp13.
    INSERT `PRODUCT` INTO TABLE temp13.
    INSERT `QUANTITY` INTO TABLE temp13.

    cut = new_cut( tab     = rows( )
                         columns = temp13 ).
    cut->set_output_table( ).

    cut->select_row( `3` ).
    cut->collect_result( ).

    ASSIGN cut->ms_result-table->* TO <table>.

    CLEAR temp15.

    temp16-product = `Sofa 3`.
    temp16-quantity = 30.
    INSERT temp16 INTO TABLE temp15.
    cl_abap_unit_assert=>assert_equals( exp = temp15
                                        act = <table> ).
    ASSIGN cut->ms_result-row->* TO <row>.
    cl_abap_unit_assert=>assert_equals( exp = `Sofa 3`
                                        act = <row>-product ).

  ENDMETHOD.

  METHOD single_selection_replaced.

    FIELD-SYMBOLS <table> TYPE ty_t_row.

    DATA temp17 TYPE string_table.
    DATA cut TYPE REF TO z2ui5_cl_layo_pop_w_sel.
    DATA temp19 TYPE ty_t_row.
    DATA temp20 LIKE LINE OF temp19.
    CLEAR temp17.
    INSERT `PRODUCT` INTO TABLE temp17.
    INSERT `QUANTITY` INTO TABLE temp17.

    cut = new_cut( tab     = rows( )
                         columns = temp17 ).
    cut->set_output_table( ).

    select_on_screen( cut    = cut
                      row_id = 1 ).
    cut->mv_search_value = `Lamp`.
    cut->on_event_search( ).

    " the radio button of a row the search shows replaces the hidden one
    select_on_screen( cut    = cut
                      row_id = 4 ).
    cut->sync_selection( ).
    cut->collect_result( ).

    ASSIGN cut->ms_result-table->* TO <table>.

    CLEAR temp19.

    temp20-product = `Lamp 4`.
    temp20-quantity = 40.
    INSERT temp20 INTO TABLE temp19.
    cl_abap_unit_assert=>assert_equals( exp = temp19
                                        act = <table> ).

  ENDMETHOD.

  METHOD elementary_line.

    FIELD-SYMBOLS <table> TYPE string_table.
    FIELD-SYMBOLS <row>   TYPE string.

    DATA temp21 TYPE string_table.
    DATA temp1 TYPE string_table.
    DATA cut TYPE REF TO z2ui5_cl_layo_pop_w_sel.
    DATA temp23 TYPE string_table.
    CLEAR temp21.
    INSERT `A` INTO TABLE temp21.
    INSERT `B` INTO TABLE temp21.
    INSERT `C` INTO TABLE temp21.

    CLEAR temp1.
    INSERT `TAB_LINE` INTO TABLE temp1.

    cut = new_cut( tab         = temp21
                         multiselect = abap_true
                         columns     = temp1 ).
    cut->set_output_table( ).

    cl_abap_unit_assert=>assert_true( cut->check_table_line ).
    cut->mv_search_value = `c`.
    cut->on_event_search( ).
    select_on_screen( cut    = cut
                      row_id = 3 ).
    cut->mv_search_value = ``.
    cut->on_event_search( ).

    select_on_screen( cut    = cut
                      row_id = 2 ).
    cut->sync_selection( ).
    cut->collect_result( ).

    ASSIGN cut->ms_result-table->* TO <table>.

    CLEAR temp23.
    INSERT `B` INTO TABLE temp23.
    INSERT `C` INTO TABLE temp23.
    cl_abap_unit_assert=>assert_equals( exp = temp23
                                        act = <table> ).
    ASSIGN cut->ms_result-row->* TO <row>.
    cl_abap_unit_assert=>assert_equals( exp = `B`
                                        act = <row> ).

  ENDMETHOD.

ENDCLASS.
