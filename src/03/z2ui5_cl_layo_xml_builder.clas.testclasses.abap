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

ENDCLASS.
