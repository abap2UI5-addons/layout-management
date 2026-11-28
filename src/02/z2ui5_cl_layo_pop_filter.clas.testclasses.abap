CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_factory        FOR TESTING RAISING cx_static_check.
    METHODS test_result_initial FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory.

    DATA(lt_filter) = VALUE z2ui5_cl_layo_context=>ty_t_filter_multi(
      ( name = `CARRID` t_range = VALUE #( ( sign = `I` option = `EQ` low = `AA` ) ) )
      ( name = `CONNID` ) ).

    DATA(lo_pop) = z2ui5_cl_layo_pop_filter=>factory( lt_filter ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).
    cl_abap_unit_assert=>assert_false( lo_pop->mo_multiselect->mv_check_variant ).

  ENDMETHOD.

  METHOD test_result_initial.

    DATA(lt_filter) = VALUE z2ui5_cl_layo_context=>ty_t_filter_multi(
      ( name = `FIELD1` ) ).

    DATA(lo_pop) = z2ui5_cl_layo_pop_filter=>factory( lt_filter ).
    DATA(ls_result) = lo_pop->result( ).
    cl_abap_unit_assert=>assert_false( ls_result-check_confirmed ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( ls_result-t_filter ) ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_roundtrip DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_action TYPE REF TO z2ui5_cl_ui5_action.
    DATA mi_client TYPE REF TO z2ui5_if_client.

    " what the roundtrip queued for the frontend, read off the response
    METHODS popup_xml
      RETURNING
        VALUE(result) TYPE string.
    METHODS popup_destroyed
      RETURNING
        VALUE(result) TYPE abap_bool.

    METHODS popup_create
      RETURNING
        VALUE(ro_pop) TYPE REF TO z2ui5_cl_layo_pop_filter.

    METHODS test_init_displays_popup FOR TESTING RAISING cx_static_check.
    METHODS test_no_variant_buttons  FOR TESTING RAISING cx_static_check.
    METHODS test_confirm             FOR TESTING RAISING cx_static_check.
    METHODS test_cancel_keeps_filter FOR TESTING RAISING cx_static_check.
    METHODS test_list_open_calls_pop FOR TESTING RAISING cx_static_check.
    METHODS test_delete_all          FOR TESTING RAISING cx_static_check.
    METHODS test_list_open_unknown   FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test_roundtrip IMPLEMENTATION.

  METHOD popup_create.

    ro_pop = z2ui5_cl_layo_pop_filter=>factory( VALUE #(
        ( name    = `MATNR`
          t_range = VALUE #( ( sign = `I` option = `EQ` low = `100` ) ) ) ) ).
    mo_action = NEW #( NEW z2ui5_cl_ui5_handler( `` ) ).
    mo_action->mo_app->mo_app = ro_pop.
    mi_client = NEW z2ui5_cl_ui5_client( mo_action ).

    ro_pop->z2ui5_if_app~main( mi_client ).
    mo_action->mo_app->mv_check_initialized = abap_true.

  ENDMETHOD.

  METHOD test_init_displays_popup.

    DATA(lo_pop) = popup_create( ).

    cl_abap_unit_assert=>assert_bound( lo_pop ).
    DATA(lv_xml) = popup_xml( ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Define Filter Conditions` ) ).
    " the filter names live in the model, the table only carries the binding
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `T_FILTER` ) ).

  ENDMETHOD.

  METHOD test_no_variant_buttons.

    " factory( ) is the popup for a filter the caller keeps - no variants
    popup_create( ).

    DATA(lv_xml) = popup_xml( ).
    cl_abap_unit_assert=>assert_false( xsdbool( lv_xml CS `BUTTON_LOAD` ) ).
    cl_abap_unit_assert=>assert_false( xsdbool( lv_xml CS `BUTTON_SAVE` ) ).

  ENDMETHOD.

  METHOD test_confirm.

    DATA(lo_pop) = popup_create( ).

    mo_action->ms_actual-event = `BUTTON_CONFIRM`.
    lo_pop->z2ui5_if_app~main( mi_client ).

    DATA(ls_result) = lo_pop->result( ).
    cl_abap_unit_assert=>assert_true( ls_result-check_confirmed ).
    cl_abap_unit_assert=>assert_equals( exp = `MATNR`
                                        act = ls_result-t_filter[ 1 ]-name ).
    cl_abap_unit_assert=>assert_true( popup_destroyed( ) ).
    cl_abap_unit_assert=>assert_bound( mo_action->ms_next-o_app_leave ).

  ENDMETHOD.

  METHOD test_cancel_keeps_filter.

    DATA(lo_pop) = popup_create( ).

    mo_action->ms_actual-event = `DELETE_ALL`.
    lo_pop->z2ui5_if_app~main( mi_client ).
    mo_action->ms_actual-event = `BUTTON_CANCEL`.
    lo_pop->z2ui5_if_app~main( mi_client ).

    DATA(ls_result) = lo_pop->result( ).
    cl_abap_unit_assert=>assert_false( ls_result-check_confirmed ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( ls_result-t_filter[ 1 ]-t_range ) ).
    cl_abap_unit_assert=>assert_true( popup_destroyed( ) ).

  ENDMETHOD.

  METHOD test_list_open_calls_pop.

    DATA(lo_pop) = popup_create( ).

    mo_action->ms_actual-event = `LIST_OPEN`.
    mo_action->ms_actual-t_event_arg = VALUE #( ( `MATNR` ) ).
    lo_pop->z2ui5_if_app~main( mi_client ).

    DATA(lo_range_pop) = CAST z2ui5_cl_layo_pop_range( mo_action->ms_next-o_app_call ).
    cl_abap_unit_assert=>assert_bound( lo_range_pop ).

  ENDMETHOD.

  METHOD test_list_open_unknown.

    " the name comes from the client - one that is no filter calls nothing
    " instead of raising CX_SY_ITAB_LINE_NOT_FOUND
    DATA(lo_pop) = popup_create( ).

    mo_action->ms_actual-event = `LIST_OPEN`.
    mo_action->ms_actual-t_event_arg = VALUE #( ( `UNKNOWN` ) ).
    lo_pop->z2ui5_if_app~main( mi_client ).

    cl_abap_unit_assert=>assert_not_bound( mo_action->ms_next-o_app_call ).

  ENDMETHOD.

  METHOD test_delete_all.

    DATA(lo_pop) = popup_create( ).

    mo_action->ms_actual-event = `DELETE_ALL`.
    lo_pop->z2ui5_if_app~main( mi_client ).

    cl_abap_unit_assert=>assert_initial( lo_pop->mo_multiselect->ms_result-t_filter[ 1 ]-t_range ).

  ENDMETHOD.

  METHOD popup_xml.

    LOOP AT mo_action->ms_next-t_action_front INTO DATA(ls_action)
         WHERE slot = z2ui5_if_client=>cs_view-popup AND method = `display`.
      result = ls_action-xml.
    ENDLOOP.

  ENDMETHOD.

  METHOD popup_destroyed.

    result = xsdbool( line_exists( mo_action->ms_next-t_action_front[ slot   = z2ui5_if_client=>cs_view-popup
                                                                      method = `destroy` ] ) ).

  ENDMETHOD.

ENDCLASS.
