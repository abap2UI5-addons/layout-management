CLASS ltcl_xml_builder DEFINITION DEFERRED.
CLASS z2ui5_cl_layo_xml_builder DEFINITION LOCAL FRIENDS ltcl_xml_builder.

CLASS ltcl_xml_builder DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS cell_plain_name FOR TESTING.
    METHODS cell_namespaced_name FOR TESTING.
    METHODS icon_namespaced_name FOR TESTING.
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

ENDCLASS.
