CLASS ltcl_apply DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_view TYPE string VALUE
      `<mvc:View xmlns="sap.m" xmlns:mvc="sap.ui.core.mvc"><Page title="P">` &
      `<Panel id="pnl" headerText="Customer">` &
      `<Label text="Name" labelFor="inpName"/><Input id="inpName" value="{/NAME}"/>` &
      `<Label text="City" labelFor="inpCity"/><Input id="inpCity" value="{/CITY}"/>` &
      `<Input id="inpFree" value="{/FREE}"/>` &
      `</Panel>` &
      `<Toolbar id="tb"><Button id="btnSave" text="Save" press="X"/><ToolbarSpacer/>` &
      `<Button id="btnCancel" text="Cancel"/><Button id="btnReset" text="Reset"/></Toolbar>` &
      `<List id="lst" headerText="Notes" items="{/T_NOTE}"/>` &
      `</Page></mvc:View>`.

    METHODS slots_all_visible
      RETURNING
        VALUE(result) TYPE z2ui5_cl_layo_xml_tree=>ty_t_slot.

    METHODS no_slots_no_change FOR TESTING.
    METHODS all_visible_no_change FOR TESTING.
    METHODS roundtrip_keeps_decoration FOR TESTING.
    METHODS hide_control_and_its_label FOR TESTING.
    METHODS hide_button_sets_visible FOR TESTING.
    METHODS hide_replaces_existing_visible FOR TESTING.
    METHODS label_on_control FOR TESTING.
    METHODS label_on_leading_label FOR TESTING.
    METHODS label_explicit_attribute FOR TESTING.
    METHODS label_is_escaped FOR TESTING.
    METHODS width_is_set FOR TESTING.
    METHODS reorder_within_parent FOR TESTING.
    METHODS reorder_keeps_unregistered FOR TESTING.
    METHODS reorder_moves_label_along FOR TESTING.
    METHODS reorder_only_within_parent FOR TESTING.
    METHODS unknown_id_is_ignored FOR TESTING.
    METHODS scan_ids_all FOR TESTING.
    METHODS scan_ids_prefix FOR TESTING.
    METHODS scan_ids_label FOR TESTING.
    METHODS escape_unescape FOR TESTING.
    METHODS single_quotes_and_whitespace FOR TESTING.
ENDCLASS.


CLASS ltcl_apply IMPLEMENTATION.

  METHOD slots_all_visible.

    result = VALUE #( visible = abap_true
                      ( id = `inpName` ) ( id = `inpCity` ) ( id = `inpFree` )
                      ( id = `btnSave` ) ( id = `btnCancel` ) ( id = `btnReset` )
                      ( id = `lst` ) ).

  ENDMETHOD.

  METHOD no_slots_no_change.

    DATA lt_slot TYPE z2ui5_cl_layo_xml_tree=>ty_t_slot.

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_layo_xml_tree=>apply( xml    = c_view
                                           t_slot = lt_slot )
      exp = c_view ).

  ENDMETHOD.

  METHOD all_visible_no_change.

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_layo_xml_tree=>apply( xml    = c_view
                                           t_slot = slots_all_visible( ) )
      exp = c_view ).

  ENDMETHOD.

  METHOD roundtrip_keeps_decoration.

    DATA(lv_xml) = `<?xml version="1.0"?><!-- a comment --><mvc:View xmlns:mvc="sap.ui.core.mvc">` &&
                   `<Text id="t" text="a &amp; b &lt; c"/>` && cl_abap_char_utilities=>newline &&
                   `<Text text="plain">inner text</Text></mvc:View>` && cl_abap_char_utilities=>newline.

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_layo_xml_tree=>apply( xml    = lv_xml
                                           t_slot = VALUE #( ( id = `t` visible = abap_true ) ) )
      exp = lv_xml ).

  ENDMETHOD.

  METHOD hide_control_and_its_label.

    DATA(lt_slot) = slots_all_visible( ).
    lt_slot[ id = `inpCity` ]-visible = abap_false.

    DATA(lv_act) = z2ui5_cl_layo_xml_tree=>apply( xml    = c_view
                                                  t_slot = lt_slot ).

    DATA(lv_exp) = replace( val  = c_view
                            sub  = `<Label text="City" labelFor="inpCity"/><Input id="inpCity" value="{/CITY}"/>`
                            with = `<Label text="City" labelFor="inpCity" visible="false"/><Input id="inpCity" value="{/CITY}" visible="false"/>` ).

    cl_abap_unit_assert=>assert_equals( act = lv_act
                                        exp = lv_exp ).

  ENDMETHOD.

  METHOD hide_button_sets_visible.

    DATA(lt_slot) = slots_all_visible( ).
    lt_slot[ id = `btnReset` ]-visible = abap_false.

    DATA(lv_act) = z2ui5_cl_layo_xml_tree=>apply( xml    = c_view
                                                  t_slot = lt_slot ).

    DATA(lv_exp) = replace( val  = c_view
                            sub  = `<Button id="btnReset" text="Reset"/>`
                            with = `<Button id="btnReset" text="Reset" visible="false"/>` ).

    cl_abap_unit_assert=>assert_equals( act = lv_act
                                        exp = lv_exp ).

  ENDMETHOD.

  METHOD hide_replaces_existing_visible.

    DATA(lv_xml) = `<Page><Button id="b" visible="{/SHOW}" text="B"/></Page>`.

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_layo_xml_tree=>apply( xml    = lv_xml
                                           t_slot = VALUE #( ( id = `b` visible = abap_false ) ) )
      exp = `<Page><Button id="b" visible="false" text="B"/></Page>` ).

  ENDMETHOD.

  METHOD label_on_control.

    DATA(lt_slot) = slots_all_visible( ).
    lt_slot[ id = `btnSave` ]-label = `Store`.
    lt_slot[ id = `lst` ]-label = `Remarks`.

    DATA(lv_act) = z2ui5_cl_layo_xml_tree=>apply( xml    = c_view
                                                  t_slot = lt_slot ).

    DATA(lv_exp) = replace( val  = c_view
                            sub  = `<Button id="btnSave" text="Save"`
                            with = `<Button id="btnSave" text="Store"` ).
    lv_exp = replace( val  = lv_exp
                      sub  = `<List id="lst" headerText="Notes"`
                      with = `<List id="lst" headerText="Remarks"` ).

    cl_abap_unit_assert=>assert_equals( act = lv_act
                                        exp = lv_exp ).

  ENDMETHOD.

  METHOD label_on_leading_label.

    DATA(lt_slot) = slots_all_visible( ).
    lt_slot[ id = `inpName` ]-label = `Full name`.

    DATA(lv_act) = z2ui5_cl_layo_xml_tree=>apply( xml    = c_view
                                                  t_slot = lt_slot ).

    DATA(lv_exp) = replace( val  = c_view
                            sub  = `<Label text="Name" labelFor="inpName"/>`
                            with = `<Label text="Full name" labelFor="inpName"/>` ).

    cl_abap_unit_assert=>assert_equals( act = lv_act
                                        exp = lv_exp ).

  ENDMETHOD.

  METHOD label_explicit_attribute.

    DATA(lt_slot) = slots_all_visible( ).
    lt_slot[ id = `inpName` ]-label = `Type here`.
    lt_slot[ id = `inpName` ]-label_attr = `placeholder`.

    DATA(lv_act) = z2ui5_cl_layo_xml_tree=>apply( xml    = c_view
                                                  t_slot = lt_slot ).

    DATA(lv_exp) = replace( val  = c_view
                            sub  = `<Input id="inpName" value="{/NAME}"/>`
                            with = `<Input id="inpName" value="{/NAME}" placeholder="Type here"/>` ).

    cl_abap_unit_assert=>assert_equals( act = lv_act
                                        exp = lv_exp ).

  ENDMETHOD.

  METHOD label_is_escaped.

    DATA(lv_xml) = `<Page><Button id="b" text="B"/></Page>`.

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_layo_xml_tree=>apply( xml    = lv_xml
                                           t_slot = VALUE #( ( id = `b` visible = abap_true label = `a<b & "c"` ) ) )
      exp = `<Page><Button id="b" text="a&lt;b &amp; &quot;c&quot;"/></Page>` ).

  ENDMETHOD.

  METHOD width_is_set.

    DATA(lt_slot) = slots_all_visible( ).
    lt_slot[ id = `inpFree` ]-width = `10rem`.

    DATA(lv_act) = z2ui5_cl_layo_xml_tree=>apply( xml    = c_view
                                                  t_slot = lt_slot ).

    DATA(lv_exp) = replace( val  = c_view
                            sub  = `<Input id="inpFree" value="{/FREE}"/>`
                            with = `<Input id="inpFree" value="{/FREE}" width="10rem"/>` ).

    cl_abap_unit_assert=>assert_equals( act = lv_act
                                        exp = lv_exp ).

  ENDMETHOD.

  METHOD reorder_within_parent.

    " the layout wants Reset, Cancel, Save - the spacer stays where it was
    DATA(lt_slot) = VALUE z2ui5_cl_layo_xml_tree=>ty_t_slot( visible = abap_true
                                                             ( id = `btnReset` ) ( id = `btnCancel` ) ( id = `btnSave` ) ).

    DATA(lv_act) = z2ui5_cl_layo_xml_tree=>apply( xml    = c_view
                                                  t_slot = lt_slot ).

    DATA(lv_exp) = replace( val  = c_view
                            sub  = `<Toolbar id="tb"><Button id="btnSave" text="Save" press="X"/><ToolbarSpacer/><Button id="btnCancel" text="Cancel"/><Button id="btnReset" text="Reset"/></Toolbar>`
                            with = `<Toolbar id="tb"><Button id="btnReset" text="Reset"/><ToolbarSpacer/><Button id="btnCancel" text="Cancel"/><Button id="btnSave" text="Save" press="X"/></Toolbar>` ).

    cl_abap_unit_assert=>assert_equals( act = lv_act
                                        exp = lv_exp ).

  ENDMETHOD.

  METHOD reorder_keeps_unregistered.

    " only two of the three buttons are registered: they swap, Cancel stays
    DATA(lt_slot) = VALUE z2ui5_cl_layo_xml_tree=>ty_t_slot( visible = abap_true
                                                             ( id = `btnReset` ) ( id = `btnSave` ) ).

    DATA(lv_act) = z2ui5_cl_layo_xml_tree=>apply( xml    = c_view
                                                  t_slot = lt_slot ).

    DATA(lv_exp) = replace( val  = c_view
                            sub  = `<Toolbar id="tb"><Button id="btnSave" text="Save" press="X"/><ToolbarSpacer/><Button id="btnCancel" text="Cancel"/><Button id="btnReset" text="Reset"/></Toolbar>`
                            with = `<Toolbar id="tb"><Button id="btnReset" text="Reset"/><ToolbarSpacer/><Button id="btnCancel" text="Cancel"/><Button id="btnSave" text="Save" press="X"/></Toolbar>` ).

    cl_abap_unit_assert=>assert_equals( act = lv_act
                                        exp = lv_exp ).

  ENDMETHOD.

  METHOD reorder_moves_label_along.

    " City in front of Name: each input travels with the Label that points at it
    DATA(lt_slot) = VALUE z2ui5_cl_layo_xml_tree=>ty_t_slot( visible = abap_true
                                                             ( id = `inpCity` ) ( id = `inpName` ) ( id = `inpFree` ) ).

    DATA(lv_act) = z2ui5_cl_layo_xml_tree=>apply( xml    = c_view
                                                  t_slot = lt_slot ).

    DATA(lv_exp) = replace( val  = c_view
                            sub  = `<Label text="Name" labelFor="inpName"/><Input id="inpName" value="{/NAME}"/><Label text="City" labelFor="inpCity"/><Input id="inpCity" value="{/CITY}"/>`
                            with = `<Label text="City" labelFor="inpCity"/><Input id="inpCity" value="{/CITY}"/><Label text="Name" labelFor="inpName"/><Input id="inpName" value="{/NAME}"/>` ).

    cl_abap_unit_assert=>assert_equals( act = lv_act
                                        exp = lv_exp ).

  ENDMETHOD.

  METHOD reorder_only_within_parent.

    " the list is wanted first, the buttons last - they sit in different
    " parents, so nothing moves across: the view stays as it is
    DATA(lt_slot) = VALUE z2ui5_cl_layo_xml_tree=>ty_t_slot( visible = abap_true
                                                             ( id = `lst` ) ( id = `btnSave` ) ( id = `btnCancel` ) ( id = `btnReset` ) ).

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_layo_xml_tree=>apply( xml    = c_view
                                           t_slot = lt_slot )
      exp = c_view ).

  ENDMETHOD.

  METHOD unknown_id_is_ignored.

    DATA(lt_slot) = slots_all_visible( ).
    APPEND VALUE #( id = `doesNotExist` visible = abap_false label = `x` ) TO lt_slot.

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_layo_xml_tree=>apply( xml    = c_view
                                           t_slot = lt_slot )
      exp = c_view ).

  ENDMETHOD.

  METHOD scan_ids_all.

    DATA(lt_id) = z2ui5_cl_layo_xml_tree=>scan_ids( c_view ).

    " pnl, inpName, inpCity, inpFree, tb, btnSave, btnCancel, btnReset, lst
    cl_abap_unit_assert=>assert_equals( act = lines( lt_id )
                                        exp = 9 ).
    cl_abap_unit_assert=>assert_equals( act = lt_id[ 1 ]-id
                                        exp = `pnl` ).
    cl_abap_unit_assert=>assert_equals( act = lt_id[ 1 ]-control
                                        exp = `Panel` ).
    cl_abap_unit_assert=>assert_equals( act = lt_id[ 9 ]-id
                                        exp = `lst` ).

  ENDMETHOD.

  METHOD scan_ids_prefix.

    DATA(lt_id) = z2ui5_cl_layo_xml_tree=>scan_ids( xml    = c_view
                                                    prefix = `btn` ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_id )
                                        exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_id[ 2 ]-id
                                        exp = `btnCancel` ).

  ENDMETHOD.

  METHOD scan_ids_label.

    DATA(lt_id) = z2ui5_cl_layo_xml_tree=>scan_ids( c_view ).

    DATA(ls_button) = lt_id[ id = `btnSave` ].
    cl_abap_unit_assert=>assert_equals( act = ls_button-label
                                        exp = `Save` ).
    cl_abap_unit_assert=>assert_equals( act = ls_button-label_attr
                                        exp = `text` ).

    DATA(ls_list) = lt_id[ id = `lst` ].
    cl_abap_unit_assert=>assert_equals( act = ls_list-label
                                        exp = `Notes` ).
    cl_abap_unit_assert=>assert_equals( act = ls_list-label_attr
                                        exp = `headerText` ).

    " an Input has no label attribute of its own - text is assumed, empty
    DATA(ls_input) = lt_id[ id = `inpName` ].
    cl_abap_unit_assert=>assert_equals( act = ls_input-label
                                        exp = `` ).

  ENDMETHOD.

  METHOD escape_unescape.

    cl_abap_unit_assert=>assert_equals( act = z2ui5_cl_layo_xml_tree=>escape_xml( `a<b>c&"d"` )
                                        exp = `a&lt;b&gt;c&amp;&quot;d&quot;` ).
    cl_abap_unit_assert=>assert_equals( act = z2ui5_cl_layo_xml_tree=>unescape_xml( `a&lt;b&gt;c&amp;&quot;d&quot;&apos;` )
                                        exp = `a<b>c&"d"'` ).

  ENDMETHOD.

  METHOD single_quotes_and_whitespace.

    " hand-written XML: single quotes, line breaks inside a tag, a > in a value
    DATA(lv_xml) = `<Page>` && cl_abap_char_utilities=>newline &&
                   `  <Button id='b'` && cl_abap_char_utilities=>newline &&
                   `          text="a > b"/>` && cl_abap_char_utilities=>newline &&
                   `</Page>`.

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_layo_xml_tree=>apply( xml    = lv_xml
                                           t_slot = VALUE #( ( id = `b` visible = abap_false ) ) )
      exp = `<Page>` && cl_abap_char_utilities=>newline &&
            `  <Button id="b" text="a > b" visible="false"/>` && cl_abap_char_utilities=>newline &&
            `</Page>` ).

  ENDMETHOD.

ENDCLASS.
