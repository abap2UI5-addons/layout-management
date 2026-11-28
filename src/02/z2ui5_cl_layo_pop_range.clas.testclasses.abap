
CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_factory_empty       FOR TESTING RAISING cx_static_check.
    METHODS test_factory_w_range     FOR TESTING RAISING cx_static_check.
    METHODS test_result_initial      FOR TESTING RAISING cx_static_check.
    METHODS test_factory_range_count FOR TESTING RAISING cx_static_check.
    METHODS test_factory_empty_row   FOR TESTING RAISING cx_static_check.
    METHODS test_factory_multi_range FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_factory_empty.

    DATA(lo_pop) = z2ui5_cl_layo_pop_range=>factory( ).
    cl_abap_unit_assert=>assert_bound( lo_pop ).

  ENDMETHOD.

  METHOD test_factory_w_range.

    DATA(lt_range) = VALUE z2ui5_cl_layo_context=>ty_t_range(
      ( sign = `I` option = `EQ` low = `100` ) ).

    DATA(lo_pop) = z2ui5_cl_layo_pop_range=>factory( lt_range ).
    DATA(ls_result) = lo_pop->result( ).

    cl_abap_unit_assert=>assert_false( ls_result-check_confirmed ).
    cl_abap_unit_assert=>assert_not_initial( ls_result-t_range ).

  ENDMETHOD.

  METHOD test_result_initial.

    DATA(lo_pop) = z2ui5_cl_layo_pop_range=>factory( ).
    DATA(ls_result) = lo_pop->result( ).
    cl_abap_unit_assert=>assert_false( ls_result-check_confirmed ).

  ENDMETHOD.

  METHOD test_factory_range_count.

    DATA(lt_range) = VALUE z2ui5_cl_layo_context=>ty_t_range(
      ( sign = `I` option = `EQ` low = `100` )
      ( sign = `I` option = `BT` low = `200` high = `300` ) ).

    DATA(lo_pop) = z2ui5_cl_layo_pop_range=>factory( lt_range ).
    DATA(ls_result) = lo_pop->result( ).

    " factory appends one empty row to the range for new entries
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( ls_result-t_range ) ).

  ENDMETHOD.

  METHOD test_factory_empty_row.

    DATA(lo_pop) = z2ui5_cl_layo_pop_range=>factory( ).
    DATA(ls_result) = lo_pop->result( ).

    " factory always inserts one empty row even for empty input
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( ls_result-t_range ) ).

  ENDMETHOD.

  METHOD test_factory_multi_range.

    DATA(lt_range) = VALUE z2ui5_cl_layo_context=>ty_t_range(
      ( sign = `I` option = `EQ` low = `A` )
      ( sign = `E` option = `EQ` low = `B` )
      ( sign = `I` option = `GE` low = `C` ) ).

    DATA(lo_pop) = z2ui5_cl_layo_pop_range=>factory( lt_range ).
    DATA(ls_result) = lo_pop->result( ).

    " 3 input rows + 1 empty row appended by factory
    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = lines( ls_result-t_range ) ).

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
      IMPORTING
        it_range      TYPE z2ui5_cl_layo_context=>ty_t_range OPTIONAL
      RETURNING
        VALUE(ro_pop) TYPE REF TO z2ui5_cl_layo_pop_range.

    METHODS test_init_displays_popup FOR TESTING RAISING cx_static_check.
    METHODS test_confirm_builds_range FOR TESTING RAISING cx_static_check.
    METHODS test_confirm_skips_empty FOR TESTING RAISING cx_static_check.
    METHODS test_add_row             FOR TESTING RAISING cx_static_check.
    METHODS test_delete_row          FOR TESTING RAISING cx_static_check.
    METHODS test_cancel              FOR TESTING RAISING cx_static_check.
    METHODS test_roundtrip_keeps_sign FOR TESTING RAISING cx_static_check.
    METHODS test_confirm_empty_value FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test_roundtrip IMPLEMENTATION.

  METHOD popup_create.

    ro_pop = z2ui5_cl_layo_pop_range=>factory( it_range ).
    mo_action = NEW #( NEW z2ui5_cl_ui5_handler( `` ) ).
    mo_action->mo_app->mo_app = ro_pop.
    mi_client = NEW z2ui5_cl_ui5_client( mo_action ).

    " first roundtrip builds mt_filter and renders the dialog
    ro_pop->z2ui5_if_app~main( mi_client ).
    mo_action->mo_app->mv_check_initialized = abap_true.

  ENDMETHOD.

  METHOD test_init_displays_popup.

    DATA(lo_pop) = popup_create( ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lo_pop->mt_filter ) ).
    cl_abap_unit_assert=>assert_not_initial( popup_xml( ) ).

  ENDMETHOD.

  METHOD test_confirm_builds_range.

    DATA(lo_pop) = popup_create( ).
    lo_pop->mt_filter[ 1 ]-option = `EQ`.
    lo_pop->mt_filter[ 1 ]-low    = `ABC`.

    mo_action->ms_actual-event = `BUTTON_CONFIRM`.
    lo_pop->z2ui5_if_app~main( mi_client ).

    DATA(ls_result) = lo_pop->result( ).
    cl_abap_unit_assert=>assert_true( ls_result-check_confirmed ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( ls_result-t_range ) ).
    cl_abap_unit_assert=>assert_equals( exp = `I`
                                        act = ls_result-t_range[ 1 ]-sign ).
    cl_abap_unit_assert=>assert_equals( exp = `EQ`
                                        act = ls_result-t_range[ 1 ]-option ).
    cl_abap_unit_assert=>assert_equals( exp = `ABC`
                                        act = ls_result-t_range[ 1 ]-low ).
    cl_abap_unit_assert=>assert_true( popup_destroyed( ) ).

  ENDMETHOD.

  METHOD test_confirm_skips_empty.

    DATA(lo_pop) = popup_create( ).

    mo_action->ms_actual-event = `BUTTON_CONFIRM`.
    lo_pop->z2ui5_if_app~main( mi_client ).

    cl_abap_unit_assert=>assert_initial( lo_pop->result( )-t_range ).
    cl_abap_unit_assert=>assert_true( lo_pop->result( )-check_confirmed ).

  ENDMETHOD.

  METHOD test_add_row.

    DATA(lo_pop) = popup_create( ).

    mo_action->ms_actual-event = `POPUP_ADD`.
    lo_pop->z2ui5_if_app~main( mi_client ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( lo_pop->mt_filter ) ).

  ENDMETHOD.

  METHOD test_delete_row.

    DATA(lo_pop) = popup_create( ).
    DATA(lv_key) = lo_pop->mt_filter[ 1 ]-key.

    mo_action->ms_actual-event = `POPUP_DELETE`.
    mo_action->ms_actual-t_event_arg = VALUE #( ( lv_key ) ).
    lo_pop->z2ui5_if_app~main( mi_client ).

    cl_abap_unit_assert=>assert_initial( lo_pop->mt_filter ).

  ENDMETHOD.

  METHOD test_cancel.

    DATA(lo_pop) = popup_create( ).

    mo_action->ms_actual-event = `BUTTON_CANCEL`.
    lo_pop->z2ui5_if_app~main( mi_client ).

    cl_abap_unit_assert=>assert_false( lo_pop->result( )-check_confirmed ).
    cl_abap_unit_assert=>assert_true( popup_destroyed( ) ).

  ENDMETHOD.

  METHOD test_roundtrip_keeps_sign.

    " an excluding row comes back excluding - and with an option and a value
    DATA(lt_range) = VALUE z2ui5_cl_layo_context=>ty_t_range(
      ( sign = `I` option = `EQ` low = `A` )
      ( sign = `E` option = `EQ` low = `B` )
      ( sign = `E` option = `BT` low = `C` high = `D` ) ).

    DATA(lo_pop) = popup_create( lt_range ).
    cl_abap_unit_assert=>assert_equals( exp = `E`
                                        act = lo_pop->mt_filter[ 2 ]-sign ).

    mo_action->ms_actual-event = `BUTTON_CONFIRM`.
    lo_pop->z2ui5_if_app~main( mi_client ).

    " the empty row factory( ) appends is left out
    cl_abap_unit_assert=>assert_equals( exp = lt_range
                                        act = lo_pop->result( )-t_range ).

  ENDMETHOD.

  METHOD test_confirm_empty_value.

    " <leer> and !<leer> are no options of a range - the empty value is
    " EQ or NE an empty LOW, and kept although it has no value
    DATA(lt_range) = VALUE z2ui5_cl_layo_context=>ty_t_range(
      ( sign = `I` option = `EQ` )
      ( sign = `E` option = `NE` ) ).

    DATA(lo_pop) = popup_create( lt_range ).
    cl_abap_unit_assert=>assert_equals( exp = `<leer>`
                                        act = lo_pop->mt_filter[ 1 ]-option ).
    cl_abap_unit_assert=>assert_equals( exp = `!<leer>`
                                        act = lo_pop->mt_filter[ 2 ]-option ).

    mo_action->ms_actual-event = `BUTTON_CONFIRM`.
    lo_pop->z2ui5_if_app~main( mi_client ).

    cl_abap_unit_assert=>assert_equals( exp = lt_range
                                        act = lo_pop->result( )-t_range ).

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
