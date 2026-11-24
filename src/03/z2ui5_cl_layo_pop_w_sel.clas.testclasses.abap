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
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.

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

    result = VALUE #( ( product = `Table 1` quantity = 10 )
                      ( product = `Chair 2` quantity = 20 )
                      ( product = `Sofa 3`  quantity = 30 )
                      ( product = `Lamp 4`  quantity = 40 ) ).

  ENDMETHOD.

  METHOD new_cut.

    result = NEW #( ).
    result->multiselect = multiselect.
    result->set_input( tab ).

    result->mo_layout = NEW #( ).
    LOOP AT columns INTO DATA(column).
      INSERT VALUE #( fname   = column
                      visible = abap_true ) INTO TABLE result->mo_layout->ms_layout-t_layout.
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

    DATA(cut) = new_cut( tab     = rows( )
                         columns = VALUE #( ) ).
    DATA(handles) = cut->get_handles( VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals( exp = z2ui5_cl_layo_context=>rtti_get_classname_by_ref( cut )
                                        act = |{ handles-handle01 }| ).
    cl_abap_unit_assert=>assert_not_initial( handles-handle01 ).
    cl_abap_unit_assert=>assert_equals( exp = cl_abap_typedescr=>describe_by_data( row )->get_relative_name( )
                                        act = |{ handles-handle02 }| ).
    cl_abap_unit_assert=>assert_initial( handles-handle03 ).
    cl_abap_unit_assert=>assert_initial( handles-handle04 ).

  ENDMETHOD.

  METHOD explicit_handles_kept.

    DATA(cut) = new_cut( tab     = rows( )
                         columns = VALUE #( ) ).
    DATA(handles) = cut->get_handles( VALUE #( handle03 = `LTCL_POP_W_SEL` ) ).

    cl_abap_unit_assert=>assert_initial( handles-handle01 ).
    cl_abap_unit_assert=>assert_initial( handles-handle02 ).
    cl_abap_unit_assert=>assert_equals( exp = `LTCL_POP_W_SEL`
                                        act = |{ handles-handle03 }| ).

  ENDMETHOD.

  METHOD result_typed.

    FIELD-SYMBOLS <table> TYPE ty_t_row.
    FIELD-SYMBOLS <row>   TYPE ty_s_row.

    DATA(cut) = new_cut( tab         = rows( )
                         multiselect = abap_true
                         columns     = VALUE #( ) ).
    DATA(result) = cut->result( ).

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

    DATA(cut) = new_cut( tab         = rows( )
                         multiselect = abap_true
                         columns     = VALUE #( ( `PRODUCT` ) ( `QUANTITY` ) ) ).
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
    cl_abap_unit_assert=>assert_equals( exp = VALUE ty_t_row( ( product = `Chair 2` quantity = 20 )
                                                              ( product = `Sofa 3`  quantity = 30 )
                                                              ( product = `Lamp 4`  quantity = 40 ) )
                                        act = <table> ).
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = cut->result( )-check_confirmed ).

  ENDMETHOD.

  METHOD single_row_pressed.

    FIELD-SYMBOLS <table> TYPE ty_t_row.
    FIELD-SYMBOLS <row>   TYPE ty_s_row.

    DATA(cut) = new_cut( tab     = rows( )
                         columns = VALUE #( ( `PRODUCT` ) ( `QUANTITY` ) ) ).
    cut->set_output_table( ).

    cut->select_row( `3` ).
    cut->collect_result( ).

    ASSIGN cut->ms_result-table->* TO <table>.
    cl_abap_unit_assert=>assert_equals( exp = VALUE ty_t_row( ( product = `Sofa 3` quantity = 30 ) )
                                        act = <table> ).
    ASSIGN cut->ms_result-row->* TO <row>.
    cl_abap_unit_assert=>assert_equals( exp = `Sofa 3`
                                        act = <row>-product ).

  ENDMETHOD.

  METHOD single_selection_replaced.

    FIELD-SYMBOLS <table> TYPE ty_t_row.

    DATA(cut) = new_cut( tab     = rows( )
                         columns = VALUE #( ( `PRODUCT` ) ( `QUANTITY` ) ) ).
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
    cl_abap_unit_assert=>assert_equals( exp = VALUE ty_t_row( ( product = `Lamp 4` quantity = 40 ) )
                                        act = <table> ).

  ENDMETHOD.

  METHOD elementary_line.

    FIELD-SYMBOLS <table> TYPE string_table.
    FIELD-SYMBOLS <row>   TYPE string.

    DATA(cut) = new_cut( tab         = VALUE string_table( ( `A` ) ( `B` ) ( `C` ) )
                         multiselect = abap_true
                         columns     = VALUE #( ( `TAB_LINE` ) ) ).
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
    cl_abap_unit_assert=>assert_equals( exp = VALUE string_table( ( `B` ) ( `C` ) )
                                        act = <table> ).
    ASSIGN cut->ms_result-row->* TO <row>.
    cl_abap_unit_assert=>assert_equals( exp = `B`
                                        act = <row> ).

  ENDMETHOD.

ENDCLASS.
