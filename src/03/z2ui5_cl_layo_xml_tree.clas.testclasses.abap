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

    DATA temp1 TYPE z2ui5_cl_layo_xml_tree=>ty_t_slot.
    DATA temp2 LIKE LINE OF temp1.
    CLEAR temp1.

    temp2-visible = abap_true.
    temp2-id = `inpName`.
    INSERT temp2 INTO TABLE temp1.
    temp2-id = `inpCity`.
    INSERT temp2 INTO TABLE temp1.
    temp2-id = `inpFree`.
    INSERT temp2 INTO TABLE temp1.
    temp2-id = `btnSave`.
    INSERT temp2 INTO TABLE temp1.
    temp2-id = `btnCancel`.
    INSERT temp2 INTO TABLE temp1.
    temp2-id = `btnReset`.
    INSERT temp2 INTO TABLE temp1.
    temp2-id = `lst`.
    INSERT temp2 INTO TABLE temp1.
    result = temp1.

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

    DATA lv_xml TYPE string.
    DATA temp3 TYPE z2ui5_cl_layo_xml_tree=>ty_t_slot.
    DATA temp4 LIKE LINE OF temp3.
    lv_xml = `<?xml version="1.0"?><!-- a comment --><mvc:View xmlns:mvc="sap.ui.core.mvc">` &&
                   `<Text id="t" text="a &amp; b &lt; c"/>` && cl_abap_char_utilities=>newline &&
                   `<Text text="plain">inner text</Text></mvc:View>` && cl_abap_char_utilities=>newline.


    CLEAR temp3.

    temp4-id = `t`.
    temp4-visible = abap_true.
    INSERT temp4 INTO TABLE temp3.
    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_layo_xml_tree=>apply( xml    = lv_xml
                                           t_slot = temp3 )
      exp = lv_xml ).

  ENDMETHOD.

  METHOD hide_control_and_its_label.

    DATA lt_slot TYPE z2ui5_cl_layo_xml_tree=>ty_t_slot.
    FIELD-SYMBOLS <temp5> LIKE LINE OF lt_slot.
    DATA temp6 LIKE sy-tabix.
    DATA lv_act TYPE string.
    DATA lv_exp TYPE string.
    lt_slot = slots_all_visible( ).


    temp6 = sy-tabix.
    READ TABLE lt_slot WITH KEY id = `inpCity` ASSIGNING <temp5>.
    sy-tabix = temp6.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    <temp5>-visible = abap_false.


    lv_act = z2ui5_cl_layo_xml_tree=>apply( xml    = c_view
                                                  t_slot = lt_slot ).


    lv_exp = replace( val  = c_view
                            sub  = `<Label text="City" labelFor="inpCity"/><Input id="inpCity" value="{/CITY}"/>`
                            with = `<Label text="City" labelFor="inpCity" visible="false"/><Input id="inpCity" value="{/CITY}" visible="false"/>` ).

    cl_abap_unit_assert=>assert_equals( act = lv_act
                                        exp = lv_exp ).

  ENDMETHOD.

  METHOD hide_button_sets_visible.

    DATA lt_slot TYPE z2ui5_cl_layo_xml_tree=>ty_t_slot.
    FIELD-SYMBOLS <temp7> LIKE LINE OF lt_slot.
    DATA temp8 LIKE sy-tabix.
    DATA lv_act TYPE string.
    DATA lv_exp TYPE string.
    lt_slot = slots_all_visible( ).


    temp8 = sy-tabix.
    READ TABLE lt_slot WITH KEY id = `btnReset` ASSIGNING <temp7>.
    sy-tabix = temp8.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    <temp7>-visible = abap_false.


    lv_act = z2ui5_cl_layo_xml_tree=>apply( xml    = c_view
                                                  t_slot = lt_slot ).


    lv_exp = replace( val  = c_view
                            sub  = `<Button id="btnReset" text="Reset"/>`
                            with = `<Button id="btnReset" text="Reset" visible="false"/>` ).

    cl_abap_unit_assert=>assert_equals( act = lv_act
                                        exp = lv_exp ).

  ENDMETHOD.

  METHOD hide_replaces_existing_visible.

    DATA lv_xml TYPE string.
    DATA temp9 TYPE z2ui5_cl_layo_xml_tree=>ty_t_slot.
    DATA temp10 LIKE LINE OF temp9.
    lv_xml = `<Page><Button id="b" visible="{/SHOW}" text="B"/></Page>`.


    CLEAR temp9.

    temp10-id = `b`.
    temp10-visible = abap_false.
    INSERT temp10 INTO TABLE temp9.
    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_layo_xml_tree=>apply( xml    = lv_xml
                                           t_slot = temp9 )
      exp = `<Page><Button id="b" visible="false" text="B"/></Page>` ).

  ENDMETHOD.

  METHOD label_on_control.

    DATA lt_slot TYPE z2ui5_cl_layo_xml_tree=>ty_t_slot.
    FIELD-SYMBOLS <temp11> LIKE LINE OF lt_slot.
    DATA temp12 LIKE sy-tabix.
    FIELD-SYMBOLS <temp13> LIKE LINE OF lt_slot.
    DATA temp14 LIKE sy-tabix.
    DATA lv_act TYPE string.
    DATA lv_exp TYPE string.
    lt_slot = slots_all_visible( ).


    temp12 = sy-tabix.
    READ TABLE lt_slot WITH KEY id = `btnSave` ASSIGNING <temp11>.
    sy-tabix = temp12.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    <temp11>-label = `Store`.


    temp14 = sy-tabix.
    READ TABLE lt_slot WITH KEY id = `lst` ASSIGNING <temp13>.
    sy-tabix = temp14.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    <temp13>-label = `Remarks`.


    lv_act = z2ui5_cl_layo_xml_tree=>apply( xml    = c_view
                                                  t_slot = lt_slot ).


    lv_exp = replace( val  = c_view
                            sub  = `<Button id="btnSave" text="Save"`
                            with = `<Button id="btnSave" text="Store"` ).
    lv_exp = replace( val  = lv_exp
                      sub  = `<List id="lst" headerText="Notes"`
                      with = `<List id="lst" headerText="Remarks"` ).

    cl_abap_unit_assert=>assert_equals( act = lv_act
                                        exp = lv_exp ).

  ENDMETHOD.

  METHOD label_on_leading_label.

    DATA lt_slot TYPE z2ui5_cl_layo_xml_tree=>ty_t_slot.
    FIELD-SYMBOLS <temp15> LIKE LINE OF lt_slot.
    DATA temp16 LIKE sy-tabix.
    DATA lv_act TYPE string.
    DATA lv_exp TYPE string.
    lt_slot = slots_all_visible( ).


    temp16 = sy-tabix.
    READ TABLE lt_slot WITH KEY id = `inpName` ASSIGNING <temp15>.
    sy-tabix = temp16.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    <temp15>-label = `Full name`.


    lv_act = z2ui5_cl_layo_xml_tree=>apply( xml    = c_view
                                                  t_slot = lt_slot ).


    lv_exp = replace( val  = c_view
                            sub  = `<Label text="Name" labelFor="inpName"/>`
                            with = `<Label text="Full name" labelFor="inpName"/>` ).

    cl_abap_unit_assert=>assert_equals( act = lv_act
                                        exp = lv_exp ).

  ENDMETHOD.

  METHOD label_explicit_attribute.

    DATA lt_slot TYPE z2ui5_cl_layo_xml_tree=>ty_t_slot.
    FIELD-SYMBOLS <temp17> LIKE LINE OF lt_slot.
    DATA temp18 LIKE sy-tabix.
    FIELD-SYMBOLS <temp19> LIKE LINE OF lt_slot.
    DATA temp20 LIKE sy-tabix.
    DATA lv_act TYPE string.
    DATA lv_exp TYPE string.
    lt_slot = slots_all_visible( ).


    temp18 = sy-tabix.
    READ TABLE lt_slot WITH KEY id = `inpName` ASSIGNING <temp17>.
    sy-tabix = temp18.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    <temp17>-label = `Type here`.


    temp20 = sy-tabix.
    READ TABLE lt_slot WITH KEY id = `inpName` ASSIGNING <temp19>.
    sy-tabix = temp20.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    <temp19>-label_attr = `placeholder`.


    lv_act = z2ui5_cl_layo_xml_tree=>apply( xml    = c_view
                                                  t_slot = lt_slot ).


    lv_exp = replace( val  = c_view
                            sub  = `<Input id="inpName" value="{/NAME}"/>`
                            with = `<Input id="inpName" value="{/NAME}" placeholder="Type here"/>` ).

    cl_abap_unit_assert=>assert_equals( act = lv_act
                                        exp = lv_exp ).

  ENDMETHOD.

  METHOD label_is_escaped.

    DATA lv_xml TYPE string.
    DATA temp21 TYPE z2ui5_cl_layo_xml_tree=>ty_t_slot.
    DATA temp22 LIKE LINE OF temp21.
    lv_xml = `<Page><Button id="b" text="B"/></Page>`.


    CLEAR temp21.

    temp22-id = `b`.
    temp22-visible = abap_true.
    temp22-label = `a<b & "c"`.
    INSERT temp22 INTO TABLE temp21.
    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_layo_xml_tree=>apply( xml    = lv_xml
                                           t_slot = temp21 )
      exp = `<Page><Button id="b" text="a&lt;b &amp; &quot;c&quot;"/></Page>` ).

  ENDMETHOD.

  METHOD width_is_set.

    DATA lt_slot TYPE z2ui5_cl_layo_xml_tree=>ty_t_slot.
    FIELD-SYMBOLS <temp23> LIKE LINE OF lt_slot.
    DATA temp24 LIKE sy-tabix.
    DATA lv_act TYPE string.
    DATA lv_exp TYPE string.
    lt_slot = slots_all_visible( ).


    temp24 = sy-tabix.
    READ TABLE lt_slot WITH KEY id = `inpFree` ASSIGNING <temp23>.
    sy-tabix = temp24.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    <temp23>-width = `10rem`.


    lv_act = z2ui5_cl_layo_xml_tree=>apply( xml    = c_view
                                                  t_slot = lt_slot ).


    lv_exp = replace( val  = c_view
                            sub  = `<Input id="inpFree" value="{/FREE}"/>`
                            with = `<Input id="inpFree" value="{/FREE}" width="10rem"/>` ).

    cl_abap_unit_assert=>assert_equals( act = lv_act
                                        exp = lv_exp ).

  ENDMETHOD.

  METHOD reorder_within_parent.

    " the layout wants Reset, Cancel, Save - the spacer stays where it was
    DATA temp25 TYPE z2ui5_cl_layo_xml_tree=>ty_t_slot.
    DATA temp26 LIKE LINE OF temp25.
    DATA lt_slot LIKE temp25.
    DATA lv_act TYPE string.
    DATA lv_exp TYPE string.
    CLEAR temp25.

    temp26-visible = abap_true.
    temp26-id = `btnReset`.
    INSERT temp26 INTO TABLE temp25.
    temp26-id = `btnCancel`.
    INSERT temp26 INTO TABLE temp25.
    temp26-id = `btnSave`.
    INSERT temp26 INTO TABLE temp25.

    lt_slot = temp25.


    lv_act = z2ui5_cl_layo_xml_tree=>apply( xml    = c_view
                                                  t_slot = lt_slot ).


    lv_exp = replace( val  = c_view
                            sub  = `<Toolbar id="tb"><Button id="btnSave" text="Save" press="X"/><ToolbarSpacer/><Button id="btnCancel" text="Cancel"/><Button id="btnReset" text="Reset"/></Toolbar>`
                            with = `<Toolbar id="tb"><Button id="btnReset" text="Reset"/><ToolbarSpacer/><Button id="btnCancel" text="Cancel"/><Button id="btnSave" text="Save" press="X"/></Toolbar>` ).

    cl_abap_unit_assert=>assert_equals( act = lv_act
                                        exp = lv_exp ).

  ENDMETHOD.

  METHOD reorder_keeps_unregistered.

    " only two of the three buttons are registered: they swap, Cancel stays
    DATA temp27 TYPE z2ui5_cl_layo_xml_tree=>ty_t_slot.
    DATA temp28 LIKE LINE OF temp27.
    DATA lt_slot LIKE temp27.
    DATA lv_act TYPE string.
    DATA lv_exp TYPE string.
    CLEAR temp27.

    temp28-visible = abap_true.
    temp28-id = `btnReset`.
    INSERT temp28 INTO TABLE temp27.
    temp28-id = `btnSave`.
    INSERT temp28 INTO TABLE temp27.

    lt_slot = temp27.


    lv_act = z2ui5_cl_layo_xml_tree=>apply( xml    = c_view
                                                  t_slot = lt_slot ).


    lv_exp = replace( val  = c_view
                            sub  = `<Toolbar id="tb"><Button id="btnSave" text="Save" press="X"/><ToolbarSpacer/><Button id="btnCancel" text="Cancel"/><Button id="btnReset" text="Reset"/></Toolbar>`
                            with = `<Toolbar id="tb"><Button id="btnReset" text="Reset"/><ToolbarSpacer/><Button id="btnCancel" text="Cancel"/><Button id="btnSave" text="Save" press="X"/></Toolbar>` ).

    cl_abap_unit_assert=>assert_equals( act = lv_act
                                        exp = lv_exp ).

  ENDMETHOD.

  METHOD reorder_moves_label_along.

    " City in front of Name: each input travels with the Label that points at it
    DATA temp29 TYPE z2ui5_cl_layo_xml_tree=>ty_t_slot.
    DATA temp30 LIKE LINE OF temp29.
    DATA lt_slot LIKE temp29.
    DATA lv_act TYPE string.
    DATA lv_exp TYPE string.
    CLEAR temp29.

    temp30-visible = abap_true.
    temp30-id = `inpCity`.
    INSERT temp30 INTO TABLE temp29.
    temp30-id = `inpName`.
    INSERT temp30 INTO TABLE temp29.
    temp30-id = `inpFree`.
    INSERT temp30 INTO TABLE temp29.

    lt_slot = temp29.


    lv_act = z2ui5_cl_layo_xml_tree=>apply( xml    = c_view
                                                  t_slot = lt_slot ).


    lv_exp = replace( val  = c_view
                            sub  = `<Label text="Name" labelFor="inpName"/><Input id="inpName" value="{/NAME}"/><Label text="City" labelFor="inpCity"/><Input id="inpCity" value="{/CITY}"/>`
                            with = `<Label text="City" labelFor="inpCity"/><Input id="inpCity" value="{/CITY}"/><Label text="Name" labelFor="inpName"/><Input id="inpName" value="{/NAME}"/>` ).

    cl_abap_unit_assert=>assert_equals( act = lv_act
                                        exp = lv_exp ).

  ENDMETHOD.

  METHOD reorder_only_within_parent.

    " the list is wanted first, the buttons last - they sit in different
    " parents, so nothing moves across: the view stays as it is
    DATA temp31 TYPE z2ui5_cl_layo_xml_tree=>ty_t_slot.
    DATA temp32 LIKE LINE OF temp31.
    DATA lt_slot LIKE temp31.
    CLEAR temp31.

    temp32-visible = abap_true.
    temp32-id = `lst`.
    INSERT temp32 INTO TABLE temp31.
    temp32-id = `btnSave`.
    INSERT temp32 INTO TABLE temp31.
    temp32-id = `btnCancel`.
    INSERT temp32 INTO TABLE temp31.
    temp32-id = `btnReset`.
    INSERT temp32 INTO TABLE temp31.

    lt_slot = temp31.

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_layo_xml_tree=>apply( xml    = c_view
                                           t_slot = lt_slot )
      exp = c_view ).

  ENDMETHOD.

  METHOD unknown_id_is_ignored.

    DATA lt_slot TYPE z2ui5_cl_layo_xml_tree=>ty_t_slot.
    DATA temp33 TYPE z2ui5_cl_layo_xml_tree=>ty_s_slot.
    lt_slot = slots_all_visible( ).

    CLEAR temp33.
    temp33-id = `doesNotExist`.
    temp33-visible = abap_false.
    temp33-label = `x`.
    APPEND temp33 TO lt_slot.

    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_layo_xml_tree=>apply( xml    = c_view
                                           t_slot = lt_slot )
      exp = c_view ).

  ENDMETHOD.

  METHOD scan_ids_all.

    DATA lt_id TYPE z2ui5_cl_layo_xml_tree=>ty_t_id.
    FIELD-SYMBOLS <temp34> LIKE LINE OF lt_id.
    DATA temp35 LIKE sy-tabix.
    FIELD-SYMBOLS <temp36> LIKE LINE OF lt_id.
    DATA temp37 LIKE sy-tabix.
    FIELD-SYMBOLS <temp38> LIKE LINE OF lt_id.
    DATA temp39 LIKE sy-tabix.
    lt_id = z2ui5_cl_layo_xml_tree=>scan_ids( c_view ).

    " pnl, inpName, inpCity, inpFree, tb, btnSave, btnCancel, btnReset, lst
    cl_abap_unit_assert=>assert_equals( act = lines( lt_id )
                                        exp = 9 ).


    temp35 = sy-tabix.
    READ TABLE lt_id INDEX 1 ASSIGNING <temp34>.
    sy-tabix = temp35.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( act = <temp34>-id
                                        exp = `pnl` ).


    temp37 = sy-tabix.
    READ TABLE lt_id INDEX 1 ASSIGNING <temp36>.
    sy-tabix = temp37.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( act = <temp36>-control
                                        exp = `Panel` ).


    temp39 = sy-tabix.
    READ TABLE lt_id INDEX 9 ASSIGNING <temp38>.
    sy-tabix = temp39.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( act = <temp38>-id
                                        exp = `lst` ).

  ENDMETHOD.

  METHOD scan_ids_prefix.

    DATA lt_id TYPE z2ui5_cl_layo_xml_tree=>ty_t_id.
    FIELD-SYMBOLS <temp40> LIKE LINE OF lt_id.
    DATA temp41 LIKE sy-tabix.
    lt_id = z2ui5_cl_layo_xml_tree=>scan_ids( xml    = c_view
                                                    prefix = `btn` ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_id )
                                        exp = 3 ).


    temp41 = sy-tabix.
    READ TABLE lt_id INDEX 2 ASSIGNING <temp40>.
    sy-tabix = temp41.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( act = <temp40>-id
                                        exp = `btnCancel` ).

  ENDMETHOD.

  METHOD scan_ids_label.

    DATA lt_id TYPE z2ui5_cl_layo_xml_tree=>ty_t_id.
    DATA ls_button LIKE LINE OF lt_id.
    FIELD-SYMBOLS <temp1> LIKE LINE OF lt_id.
    DATA temp2 LIKE sy-tabix.
    DATA ls_list LIKE LINE OF lt_id.
    FIELD-SYMBOLS <temp3> LIKE LINE OF lt_id.
    DATA temp4 LIKE sy-tabix.
    DATA ls_input LIKE LINE OF lt_id.
    FIELD-SYMBOLS <temp5> LIKE LINE OF lt_id.
    DATA temp6 LIKE sy-tabix.
    lt_id = z2ui5_cl_layo_xml_tree=>scan_ids( c_view ).




    temp2 = sy-tabix.
    READ TABLE lt_id WITH KEY id = `btnSave` ASSIGNING <temp1>.
    sy-tabix = temp2.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    ls_button = <temp1>.
    cl_abap_unit_assert=>assert_equals( act = ls_button-label
                                        exp = `Save` ).
    cl_abap_unit_assert=>assert_equals( act = ls_button-label_attr
                                        exp = `text` ).




    temp4 = sy-tabix.
    READ TABLE lt_id WITH KEY id = `lst` ASSIGNING <temp3>.
    sy-tabix = temp4.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    ls_list = <temp3>.
    cl_abap_unit_assert=>assert_equals( act = ls_list-label
                                        exp = `Notes` ).
    cl_abap_unit_assert=>assert_equals( act = ls_list-label_attr
                                        exp = `headerText` ).

    " an Input has no label attribute of its own - text is assumed, empty



    temp6 = sy-tabix.
    READ TABLE lt_id WITH KEY id = `inpName` ASSIGNING <temp5>.
    sy-tabix = temp6.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    ls_input = <temp5>.
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
    DATA lv_xml TYPE string.
    DATA temp42 TYPE z2ui5_cl_layo_xml_tree=>ty_t_slot.
    DATA temp43 LIKE LINE OF temp42.
    lv_xml = `<Page>` && cl_abap_char_utilities=>newline &&
                   `  <Button id='b'` && cl_abap_char_utilities=>newline &&
                   `          text="a > b"/>` && cl_abap_char_utilities=>newline &&
                   `</Page>`.


    CLEAR temp42.

    temp43-id = `b`.
    temp43-visible = abap_false.
    INSERT temp43 INTO TABLE temp42.
    cl_abap_unit_assert=>assert_equals(
      act = z2ui5_cl_layo_xml_tree=>apply( xml    = lv_xml
                                           t_slot = temp42 )
      exp = `<Page>` && cl_abap_char_utilities=>newline &&
            `  <Button id="b" text="a > b" visible="false"/>` && cl_abap_char_utilities=>newline &&
            `</Page>` ).

  ENDMETHOD.

ENDCLASS.
