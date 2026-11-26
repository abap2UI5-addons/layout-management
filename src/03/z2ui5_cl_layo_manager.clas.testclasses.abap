CLASS ltcl_conv DEFINITION DEFERRED.
CLASS z2ui5_cl_layo_manager DEFINITION LOCAL FRIENDS ltcl_conv.

CLASS ltd_deny_all DEFINITION FINAL FOR TESTING.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_layo_auth.
ENDCLASS.


CLASS ltd_deny_all IMPLEMENTATION.

  METHOD z2ui5_if_layo_auth~check_authorized.
    result = abap_false.
  ENDMETHOD.

ENDCLASS.


CLASS ltd_allow_all DEFINITION FINAL FOR TESTING.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_layo_auth.
ENDCLASS.


CLASS ltd_allow_all IMPLEMENTATION.

  METHOD z2ui5_if_layo_auth~check_authorized.
    result = abap_true.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_copy DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL DANGEROUS.

  PRIVATE SECTION.
    CONSTANTS c_source   TYPE z2ui5_t_11-guid VALUE 'LTCLCOPYSOURCE000000000000000001'.
    CONSTANTS c_old_def  TYPE z2ui5_t_11-guid VALUE 'LTCLCOPYOLDDEFAULT00000000000001'.
    CONSTANTS c_other_s  TYPE z2ui5_t_11-guid VALUE 'LTCLCOPYOTHERFORMAT0000000000001'.

    METHODS setup.
    METHODS teardown.
    METHODS copy_with_positions FOR TESTING.
    METHODS copy_demotes_default FOR TESTING.
    METHODS copy_unknown_raises FOR TESTING.
    METHODS copy_denied_by_auth FOR TESTING.
    METHODS copy_checked_by_default FOR TESTING.
    METHODS copy_commits_by_default FOR TESTING.
    METHODS copy_no_commit_rollback FOR TESTING.
    METHODS copy_no_commit_caller_commits FOR TESTING.

    METHODS cleanup.

    "! abap_true when the copy of c_source under LTCL_TO is in the database
    METHODS copy_in_db
      RETURNING
        VALUE(result) TYPE abap_bool.
ENDCLASS.


CLASS ltcl_copy IMPLEMENTATION.

  METHOD setup.

    TYPES temp5 TYPE STANDARD TABLE OF z2ui5_t_11 WITH DEFAULT KEY.
DATA heads     TYPE temp5.
    TYPES temp6 TYPE STANDARD TABLE OF z2ui5_t_12 WITH DEFAULT KEY.
DATA positions TYPE temp6.
    DATA temp1 LIKE heads.
    DATA temp2 LIKE LINE OF temp1.
    DATA temp3 LIKE positions.
    DATA temp4 LIKE LINE OF temp3.

    cleanup( ).


    CLEAR temp1.

    CLEAR temp2.
    temp2-guid = c_source.
    temp2-layout = `LTCL`.
    temp2-control = z2ui5_cl_layo_manager=>m_table.
    temp2-handle03 = `LTCL_FROM`.
    temp2-handle04 = `0001`.
    temp2-screen_format = z2ui5_cl_layo_manager=>screen_format_l.
    temp2-descr = `from`.
    temp2-def = abap_true.
    INSERT temp2 INTO TABLE temp1.
    CLEAR temp2.
    temp2-guid = c_old_def.
    temp2-layout = `OLD`.
    temp2-control = z2ui5_cl_layo_manager=>m_table.
    temp2-handle03 = `LTCL_TO`.
    temp2-handle04 = `0002`.
    temp2-screen_format = z2ui5_cl_layo_manager=>screen_format_l.
    temp2-def = abap_true.
    INSERT temp2 INTO TABLE temp1.
    CLEAR temp2.
    temp2-guid = c_other_s.
    temp2-layout = `SMALL`.
    temp2-control = z2ui5_cl_layo_manager=>m_table.
    temp2-handle03 = `LTCL_TO`.
    temp2-handle04 = `0002`.
    temp2-screen_format = z2ui5_cl_layo_manager=>screen_format_s.
    temp2-def = abap_true.
    INSERT temp2 INTO TABLE temp1.
    heads = temp1.
    INSERT z2ui5_t_11 FROM TABLE heads ##SUBRC_OK.


    CLEAR temp3.

    temp4-guid = c_source.
    temp4-pos_guid = 'LTCLCOPYPOS000000000000000000001'.
    temp4-fname = `MATNR`.
    temp4-visible = abap_true.
    temp4-sequence = 1.
    INSERT temp4 INTO TABLE temp3.
    temp4-guid = c_source.
    temp4-pos_guid = 'LTCLCOPYPOS000000000000000000002'.
    temp4-fname = `MAKTX`.
    temp4-visible = abap_true.
    temp4-sequence = 2.
    INSERT temp4 INTO TABLE temp3.
    positions = temp3.
    INSERT z2ui5_t_12 FROM TABLE positions ##SUBRC_OK.

    " committed: the iv_commit tests roll back, and must only undo the copy
    COMMIT WORK.

  ENDMETHOD.

  METHOD teardown.
    cleanup( ).
    z2ui5_cl_layo_auth=>set_instance( ).
  ENDMETHOD.

  METHOD cleanup.

    TYPES temp8 TYPE RANGE OF z2ui5_t_11-guid.
DATA guids TYPE temp8.

    " the positions of the copies have new pos_guids - found by their heads
    TYPES: BEGIN OF temp5,
            guid TYPE z2ui5_t_11-guid,
          END OF temp5.
    TYPES temp9 TYPE STANDARD TABLE OF temp5 WITH DEFAULT KEY.
DATA heads TYPE temp9.
    DATA temp6 LIKE guids.
    DATA h LIKE LINE OF heads.
      DATA temp7 LIKE LINE OF temp6.
    SELECT guid FROM z2ui5_t_11 INTO TABLE heads
      WHERE handle03 = `LTCL_FROM` OR handle03 = `LTCL_TO`
      ORDER BY PRIMARY KEY
       ##SUBRC_OK.

    CLEAR temp6.

    LOOP AT heads INTO h.

      temp7-sign = `I`.
      temp7-option = `EQ`.
      temp7-low = h-guid.
      INSERT temp7 INTO TABLE temp6.
    ENDLOOP.
    guids = temp6.
    IF guids IS NOT INITIAL.
      DELETE FROM z2ui5_t_12 WHERE guid IN guids ##SUBRC_OK.
    ENDIF.

    DELETE FROM z2ui5_t_11 WHERE handle03 = `LTCL_FROM` OR handle03 = `LTCL_TO` ##SUBRC_OK.
    DELETE FROM z2ui5_t_12 WHERE pos_guid LIKE 'LTCL%' OR guid = c_source ##SUBRC_OK.
    COMMIT WORK.

  ENDMETHOD.

  METHOD copy_in_db.

    DATA count TYPE i.
    DATA temp1 TYPE xsdboolean.

    SELECT COUNT(*) FROM z2ui5_t_11 INTO count
      WHERE handle03 = `LTCL_TO`
        AND layout   = `LTCL`
      .

    temp1 = boolc( count > 0 ).
    result = temp1.

  ENDMETHOD.

  METHOD copy_commits_by_default.

    DATA positions TYPE i.

    " iv_commit defaults to abap_true: the copy is committed, a ROLLBACK of
    " the caller afterwards does not undo it
    DATA temp8 TYPE z2ui5_cl_layo_manager=>ty_t_copy.
    DATA temp9 LIKE LINE OF temp8.
    DATA heads TYPE z2ui5_cl_layo_manager=>ty_t_head.
    DATA copy_guid TYPE c LENGTH 32.
    FIELD-SYMBOLS <temp1> LIKE LINE OF heads.
    DATA temp2 LIKE sy-tabix.
    DATA old_def TYPE z2ui5_t_11-def.
    CLEAR temp8.

    temp9-guid = c_source.
    temp9-handle03 = `LTCL_TO`.
    temp9-handle04 = `0002`.
    INSERT temp9 INTO TABLE temp8.

    heads = z2ui5_cl_layo_manager=>copy_layouts( t_copy     = temp8
                                                       check_auth = abap_false ).



    temp2 = sy-tabix.
    READ TABLE heads INDEX 1 ASSIGNING <temp1>.
    sy-tabix = temp2.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    copy_guid = <temp1>-guid.
    ROLLBACK WORK.

    cl_abap_unit_assert=>assert_true( copy_in_db( ) ).
    SELECT COUNT(*) FROM z2ui5_t_12 INTO positions WHERE guid = copy_guid .
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = positions ).

    SELECT SINGLE def FROM z2ui5_t_11 INTO old_def WHERE guid = c_old_def  ##SUBRC_OK.
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = old_def ).

  ENDMETHOD.

  METHOD copy_no_commit_rollback.

    DATA positions        TYPE i.
    DATA source_positions TYPE i.

    " iv_commit = abap_false: the copy is part of the caller's LUW - the
    " caller's ROLLBACK undoes head, positions and the default demotion
    DATA temp10 TYPE z2ui5_cl_layo_manager=>ty_t_copy.
    DATA temp11 LIKE LINE OF temp10.
    DATA heads TYPE z2ui5_cl_layo_manager=>ty_t_head.
    DATA copy_guid TYPE c LENGTH 32.
    FIELD-SYMBOLS <temp3> LIKE LINE OF heads.
    DATA temp4 LIKE sy-tabix.
    DATA old_def TYPE z2ui5_t_11-def.
    CLEAR temp10.

    temp11-guid = c_source.
    temp11-handle03 = `LTCL_TO`.
    temp11-handle04 = `0002`.
    INSERT temp11 INTO TABLE temp10.

    heads = z2ui5_cl_layo_manager=>copy_layouts( t_copy     = temp10
                                                       check_auth = abap_false
                                                       iv_commit  = abap_false ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( heads ) ).
    " visible in the open LUW
    cl_abap_unit_assert=>assert_true( copy_in_db( ) ).




    temp4 = sy-tabix.
    READ TABLE heads INDEX 1 ASSIGNING <temp3>.
    sy-tabix = temp4.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    copy_guid = <temp3>-guid.
    ROLLBACK WORK.

    cl_abap_unit_assert=>assert_false( copy_in_db( ) ).
    SELECT COUNT(*) FROM z2ui5_t_12 INTO positions WHERE guid = copy_guid .
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = positions ).

    SELECT SINGLE def FROM z2ui5_t_11 INTO old_def WHERE guid = c_old_def  ##SUBRC_OK.
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = old_def ).
    " the original is untouched
    SELECT COUNT(*) FROM z2ui5_t_12 INTO source_positions WHERE guid = c_source .
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = source_positions ).

  ENDMETHOD.

  METHOD copy_no_commit_caller_commits.

    " iv_commit = abap_false: the caller's COMMIT WORK writes the copy
    DATA temp12 TYPE z2ui5_cl_layo_manager=>ty_t_copy.
    DATA temp13 LIKE LINE OF temp12.
    CLEAR temp12.

    temp13-guid = c_source.
    temp13-handle03 = `LTCL_TO`.
    temp13-handle04 = `0002`.
    INSERT temp13 INTO TABLE temp12.
    z2ui5_cl_layo_manager=>copy_layouts( t_copy     = temp12
                                         check_auth = abap_false
                                         iv_commit  = abap_false ).
    COMMIT WORK.
    ROLLBACK WORK.

    cl_abap_unit_assert=>assert_true( copy_in_db( ) ).

  ENDMETHOD.

  METHOD copy_with_positions.

    DATA temp14 TYPE z2ui5_cl_layo_manager=>ty_t_copy.
    DATA temp15 LIKE LINE OF temp14.
    DATA heads TYPE z2ui5_cl_layo_manager=>ty_t_head.
    DATA head LIKE LINE OF heads.
    FIELD-SYMBOLS <temp5> LIKE LINE OF heads.
    DATA temp6 LIKE sy-tabix.
    DATA db_head TYPE z2ui5_t_11.
    TYPES temp10 TYPE STANDARD TABLE OF z2ui5_t_12 WITH DEFAULT KEY.
DATA db_positions TYPE temp10.
    DATA position LIKE LINE OF db_positions.
    DATA source_handle03 TYPE z2ui5_t_11-handle03.
    TYPES temp11 TYPE STANDARD TABLE OF z2ui5_t_12 WITH DEFAULT KEY.
DATA source_positions TYPE temp11.
    CLEAR temp14.

    temp15-guid = c_source.
    temp15-handle03 = `LTCL_TO`.
    temp15-handle04 = `0002`.
    temp15-descr = `to`.
    INSERT temp15 INTO TABLE temp14.

    heads = z2ui5_cl_layo_manager=>copy_layouts(
                      t_copy     = temp14
                      check_auth = abap_false ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( heads ) ).



    temp6 = sy-tabix.
    READ TABLE heads INDEX 1 ASSIGNING <temp5>.
    sy-tabix = temp6.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    head = <temp5>.
    cl_abap_unit_assert=>assert_differs( exp = c_source
                                         act = head-guid ).
    cl_abap_unit_assert=>assert_equals( exp = `LTCL`
                                        act = head-layout ).
    cl_abap_unit_assert=>assert_equals( exp = `to`
                                        act = head-descr ).


    SELECT SINGLE * FROM z2ui5_t_11 INTO db_head WHERE guid = head-guid .
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( exp = `LTCL_TO`
                                        act = db_head-handle03 ).



    SELECT * FROM z2ui5_t_12 INTO TABLE db_positions WHERE guid = head-guid ORDER BY PRIMARY KEY  ##SUBRC_OK.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( db_positions ) ).

    LOOP AT db_positions INTO position.
      cl_abap_unit_assert=>assert_char_np( act = position-pos_guid
                                           exp = 'LTCL*' ).
    ENDLOOP.

    " the original is untouched

    SELECT SINGLE handle03 FROM z2ui5_t_11 INTO source_handle03 WHERE guid = c_source  ##SUBRC_OK.
    cl_abap_unit_assert=>assert_equals( exp = `LTCL_FROM`
                                        act = source_handle03 ).


    SELECT * FROM z2ui5_t_12 INTO TABLE source_positions WHERE guid = c_source ORDER BY PRIMARY KEY  ##SUBRC_OK.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( source_positions ) ).

  ENDMETHOD.

  METHOD copy_demotes_default.

    DATA temp18 TYPE z2ui5_cl_layo_manager=>ty_t_copy.
    DATA temp19 LIKE LINE OF temp18.
    DATA old_def TYPE z2ui5_t_11-def.
    DATA other_def TYPE z2ui5_t_11-def.
    CLEAR temp18.

    temp19-guid = c_source.
    temp19-handle03 = `LTCL_TO`.
    temp19-handle04 = `0002`.
    INSERT temp19 INTO TABLE temp18.
    z2ui5_cl_layo_manager=>copy_layouts( t_copy     = temp18
                                         check_auth = abap_false ).


    SELECT SINGLE def FROM z2ui5_t_11 INTO old_def WHERE guid = c_old_def  ##SUBRC_OK.
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = old_def ).


    SELECT SINGLE def FROM z2ui5_t_11 INTO other_def WHERE guid = c_other_s  ##SUBRC_OK.
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = other_def ).

  ENDMETHOD.

  METHOD copy_unknown_raises.
        DATA temp20 TYPE z2ui5_cl_layo_manager=>ty_t_copy.
        DATA temp21 LIKE LINE OF temp20.

    TRY.

        CLEAR temp20.

        temp21-guid = 'LTCLCOPYDOESNOTEXIST000000000001'.
        temp21-handle03 = `LTCL_TO`.
        INSERT temp21 INTO TABLE temp20.
        z2ui5_cl_layo_manager=>copy_layouts( t_copy     = temp20
                                             check_auth = abap_false ).
        cl_abap_unit_assert=>fail( `no exception for an unknown layout` ).
      CATCH z2ui5_cx_layo_error ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD copy_denied_by_auth.

    DATA count TYPE i.

    " a system's own z2ui5_if_layo_auth that refuses - nothing is written
    DATA temp22 TYPE REF TO ltd_deny_all.
        DATA temp23 TYPE z2ui5_cl_layo_manager=>ty_t_copy.
        DATA temp24 LIKE LINE OF temp23.
    CREATE OBJECT temp22 TYPE ltd_deny_all.
    z2ui5_cl_layo_auth=>set_instance( temp22 ).

    TRY.

        CLEAR temp23.

        temp24-guid = c_source.
        temp24-handle03 = `LTCL_TO`.
        temp24-handle04 = `0002`.
        INSERT temp24 INTO TABLE temp23.
        z2ui5_cl_layo_manager=>copy_layouts( temp23 ).
        cl_abap_unit_assert=>fail( `the copy was not checked` ).
      CATCH z2ui5_cx_layo_error ##NO_HANDLER.
    ENDTRY.

    SELECT COUNT(*) FROM z2ui5_t_11 INTO count WHERE handle03 = `LTCL_TO` .
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = count ).

  ENDMETHOD.

  METHOD copy_checked_by_default.

    " the shipped default allows a shared layout - the copy goes through
    DATA temp25 TYPE z2ui5_cl_layo_manager=>ty_t_copy.
    DATA temp26 LIKE LINE OF temp25.
    DATA heads TYPE z2ui5_cl_layo_manager=>ty_t_head.
    CLEAR temp25.

    temp26-guid = c_source.
    temp26-handle03 = `LTCL_TO`.
    temp26-handle04 = `0002`.
    INSERT temp26 INTO TABLE temp25.

    heads = z2ui5_cl_layo_manager=>copy_layouts( temp25 ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( heads ) ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_select_range DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL DANGEROUS.

  PRIVATE SECTION.
    CONSTANTS c_shared   TYPE z2ui5_t_11-guid VALUE 'LTCLSELSHARED0000000000000000001'.
    CONSTANTS c_own      TYPE z2ui5_t_11-guid VALUE 'LTCLSELOWN0000000000000000000001'.
    CONSTANTS c_other    TYPE z2ui5_t_11-guid VALUE 'LTCLSELOTHER00000000000000000001'.
    CONSTANTS c_elsewhere TYPE z2ui5_t_11-guid VALUE 'LTCLSELELSEWHERE0000000000000001'.
    CONSTANTS c_other_user TYPE z2ui5_t_11-uname VALUE 'LTCL_OTHER'.

    METHODS setup.
    METHODS teardown.
    METHODS own_and_shared_by_default FOR TESTING.
    METHODS all_users_admin FOR TESTING.
    METHODS all_users_default_auth FOR TESTING.
    METHODS all_users_hook_allows FOR TESTING.
    METHODS ranges_restrict FOR TESTING.
    METHODS select_then_copy FOR TESTING.

    METHODS cleanup.

    "! the LTCL_SEL* handle03 range every test selects in
    CLASS-METHODS scope
      RETURNING
        VALUE(result) TYPE z2ui5_cl_layo_manager=>ty_r_handle.
ENDCLASS.


CLASS ltcl_select_range IMPLEMENTATION.

  METHOD setup.

    TYPES temp12 TYPE STANDARD TABLE OF z2ui5_t_11 WITH DEFAULT KEY.
DATA heads TYPE temp12.
    DATA temp27 LIKE heads.
    DATA temp28 LIKE LINE OF temp27.

    cleanup( ).


    CLEAR temp27.

    CLEAR temp28.
    temp28-control = z2ui5_cl_layo_manager=>m_table.
    temp28-handle01 = `LTCL_APP`.
    temp28-guid = c_shared.
    temp28-layout = `SHARED`.
    temp28-handle03 = `LTCL_SEL_A`.
    temp28-handle04 = `0001`.
    INSERT temp28 INTO TABLE temp27.
    CLEAR temp28.
    temp28-control = z2ui5_cl_layo_manager=>m_table.
    temp28-handle01 = `LTCL_APP`.
    temp28-guid = c_own.
    temp28-layout = `OWN`.
    temp28-handle03 = `LTCL_SEL_A`.
    temp28-handle04 = `0001`.
    temp28-uname = sy-uname.
    INSERT temp28 INTO TABLE temp27.
    CLEAR temp28.
    temp28-control = z2ui5_cl_layo_manager=>m_table.
    temp28-handle01 = `LTCL_APP`.
    temp28-guid = c_other.
    temp28-layout = `OTHER`.
    temp28-handle03 = `LTCL_SEL_B`.
    temp28-handle04 = `0001`.
    temp28-uname = c_other_user.
    INSERT temp28 INTO TABLE temp27.
    CLEAR temp28.
    temp28-control = z2ui5_cl_layo_manager=>m_table.
    temp28-handle01 = `LTCL_APP`.
    temp28-guid = c_elsewhere.
    temp28-layout = `ELSE`.
    temp28-handle03 = `LTCL_SEL_B`.
    temp28-handle04 = `0002`.
    INSERT temp28 INTO TABLE temp27.
    heads = temp27.
    INSERT z2ui5_t_11 FROM TABLE heads ##SUBRC_OK.

  ENDMETHOD.

  METHOD teardown.
    cleanup( ).
    z2ui5_cl_layo_auth=>set_instance( ).
  ENDMETHOD.

  METHOD cleanup.

    DELETE FROM z2ui5_t_11 WHERE handle03 LIKE 'LTCL_SEL%' ##SUBRC_OK.
    COMMIT WORK.

  ENDMETHOD.

  METHOD scope.
    DATA temp29 TYPE z2ui5_cl_layo_manager=>ty_r_handle.
    DATA temp30 LIKE LINE OF temp29.
    CLEAR temp29.

    temp30-sign = `I`.
    temp30-option = `CP`.
    temp30-low = `LTCL_SEL*`.
    INSERT temp30 INTO TABLE temp29.
    result = temp29.
  ENDMETHOD.

  METHOD own_and_shared_by_default.

    DATA heads TYPE z2ui5_cl_layo_manager=>ty_t_head.
    DATA temp2 TYPE xsdboolean.
    DATA temp1 LIKE sy-subrc.
    heads = z2ui5_cl_layo_manager=>select_layouts_by_range( handle03 = scope( ) ).

    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( heads ) ).


    READ TABLE heads WITH KEY guid = c_other TRANSPORTING NO FIELDS.
    temp1 = sy-subrc.
    temp2 = boolc( temp1 = 0 ).
    cl_abap_unit_assert=>assert_false( temp2 ).

  ENDMETHOD.

  METHOD all_users_admin.

    DATA heads TYPE z2ui5_cl_layo_manager=>ty_t_head.
    DATA temp3 TYPE xsdboolean.
    DATA temp2 LIKE sy-subrc.
    heads = z2ui5_cl_layo_manager=>select_layouts_by_range( handle03   = scope( )
                                                                  all_users  = abap_true
                                                                  check_auth = abap_false ).

    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = lines( heads ) ).


    READ TABLE heads WITH KEY guid = c_other uname = c_other_user TRANSPORTING NO FIELDS.
    temp2 = sy-subrc.
    temp3 = boolc( temp2 = 0 ).
    cl_abap_unit_assert=>assert_true( temp3 ).

  ENDMETHOD.

  METHOD all_users_default_auth.

    " the shipped default never hands out another user's personal layout
    DATA heads TYPE z2ui5_cl_layo_manager=>ty_t_head.
    DATA temp4 TYPE xsdboolean.
    DATA temp3 LIKE sy-subrc.
    heads = z2ui5_cl_layo_manager=>select_layouts_by_range( handle03  = scope( )
                                                                  all_users = abap_true ).

    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( heads ) ).


    READ TABLE heads WITH KEY guid = c_other TRANSPORTING NO FIELDS.
    temp3 = sy-subrc.
    temp4 = boolc( temp3 = 0 ).
    cl_abap_unit_assert=>assert_false( temp4 ).

  ENDMETHOD.

  METHOD all_users_hook_allows.

    DATA temp31 TYPE REF TO ltd_allow_all.
    DATA heads TYPE z2ui5_cl_layo_manager=>ty_t_head.
    CREATE OBJECT temp31 TYPE ltd_allow_all.
    z2ui5_cl_layo_auth=>set_instance( temp31 ).


    heads = z2ui5_cl_layo_manager=>select_layouts_by_range( handle03  = scope( )
                                                                  all_users = abap_true ).

    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = lines( heads ) ).

  ENDMETHOD.

  METHOD ranges_restrict.

    DATA lv_handle04 TYPE z2ui5_cl_layo_manager=>ty_r_handle.
    DATA lv_layout   TYPE z2ui5_cl_layo_manager=>ty_r_layout.

    DATA temp32 TYPE z2ui5_cl_layo_manager=>ty_r_handle.
    DATA temp33 LIKE LINE OF temp32.
    DATA heads TYPE z2ui5_cl_layo_manager=>ty_t_head.
    DATA temp5 TYPE xsdboolean.
    DATA temp4 LIKE sy-subrc.
    DATA temp6 LIKE sy-subrc.
    DATA temp7 LIKE sy-tabix.
    DATA temp34 TYPE z2ui5_cl_layo_manager=>ty_r_layout.
    DATA temp35 LIKE LINE OF temp34.
    FIELD-SYMBOLS <temp36> LIKE LINE OF heads.
    DATA temp37 LIKE sy-tabix.
    CLEAR temp32.

    temp33-sign = `I`.
    temp33-option = `EQ`.
    temp33-low = `0001`.
    INSERT temp33 INTO TABLE temp32.
    lv_handle04 = temp32.

    heads = z2ui5_cl_layo_manager=>select_layouts_by_range( handle03   = scope( )
                                                                  handle04   = lv_handle04
                                                                  all_users  = abap_true
                                                                  check_auth = abap_false ).
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( heads ) ).




    temp6 = sy-subrc.
    temp7 = sy-tabix.
    READ TABLE heads WITH KEY guid = c_elsewhere TRANSPORTING NO FIELDS.
    temp4 = sy-subrc.
    sy-subrc = temp6.
    sy-tabix = temp7.
    temp5 = boolc( temp4 = 0 ).
    cl_abap_unit_assert=>assert_false( temp5 ).


    CLEAR temp34.

    temp35-sign = `E`.
    temp35-option = `EQ`.
    temp35-low = `SHARED`.
    INSERT temp35 INTO TABLE temp34.
    lv_layout = temp34.
    heads = z2ui5_cl_layo_manager=>select_layouts_by_range( handle03 = scope( )
                                                            handle04 = lv_handle04
                                                            layout   = lv_layout ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( heads ) ).


    temp37 = sy-tabix.
    READ TABLE heads INDEX 1 ASSIGNING <temp36>.
    sy-tabix = temp37.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = c_own
                                        act = <temp36>-guid ).

  ENDMETHOD.

  METHOD select_then_copy.

    DATA lv_handle03 TYPE z2ui5_cl_layo_manager=>ty_r_handle.

    DATA temp38 TYPE z2ui5_cl_layo_manager=>ty_r_handle.
    DATA temp39 LIKE LINE OF temp38.
    DATA heads TYPE z2ui5_cl_layo_manager=>ty_t_head.
    DATA temp40 TYPE z2ui5_cl_layo_manager=>ty_t_copy.
    DATA h LIKE LINE OF heads.
      DATA temp41 LIKE LINE OF temp40.
    DATA copies TYPE z2ui5_cl_layo_manager=>ty_t_head.
    DATA temp42 TYPE z2ui5_cl_layo_manager=>ty_r_handle.
    DATA temp43 LIKE LINE OF temp42.
    CLEAR temp38.

    temp39-sign = `I`.
    temp39-option = `EQ`.
    temp39-low = `LTCL_SEL_A`.
    INSERT temp39 INTO TABLE temp38.
    lv_handle03 = temp38.

    heads = z2ui5_cl_layo_manager=>select_layouts_by_range( handle03   = lv_handle03
                                                                  all_users  = abap_true
                                                                  check_auth = abap_false ).


    CLEAR temp40.

    LOOP AT heads INTO h.

      temp41-guid = h-guid.
      temp41-handle01 = h-handle01.
      temp41-handle02 = h-handle02.
      temp41-handle03 = `LTCL_SEL_C`.
      temp41-handle04 = h-handle04.
      INSERT temp41 INTO TABLE temp40.
    ENDLOOP.

    copies = z2ui5_cl_layo_manager=>copy_layouts(
                       t_copy     = temp40
                       check_auth = abap_false ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( copies ) ).

    CLEAR temp42.

    temp43-sign = `I`.
    temp43-option = `EQ`.
    temp43-low = `LTCL_SEL_C`.
    INSERT temp43 INTO TABLE temp42.
    lv_handle03 = temp42.
    heads = z2ui5_cl_layo_manager=>select_layouts_by_range( handle03 = lv_handle03 ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( heads ) ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_conv DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL DANGEROUS.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_s_row,
        id    TYPE c LENGTH 10,
        nr    TYPE n LENGTH 10,
        langu TYPE c LENGTH 2,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.

    CONSTANTS c_guid TYPE z2ui5_t_11-guid VALUE 'LTCLCONVHEAD00000000000000000001'.

    DATA mt_row TYPE ty_t_row.

    METHODS digits_alpha_char FOR TESTING.
    METHODS digits_numc FOR TESTING.
    METHODS digits_other_exits FOR TESTING.
    METHODS digit_type_switched_off FOR TESTING.
    METHODS binding_with_length FOR TESTING.
    METHODS conversion_default FOR TESTING.
    METHODS conversion_alpha_in_browser FOR TESTING.
    METHODS opened_layout_keeps_type FOR TESTING.

    METHODS layout
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_layo_manager.

    METHODS cleanup.
ENDCLASS.


CLASS ltcl_conv IMPLEMENTATION.

  METHOD layout.

    DATA temp44 TYPE ltcl_conv=>ty_t_row.
    DATA temp45 LIKE LINE OF temp44.
    DATA temp46 TYPE z2ui5_cl_layo_manager=>ty_t_positions.
    DATA temp47 LIKE LINE OF temp46.
    DATA temp48 LIKE REF TO mt_row.
    CLEAR temp44.

    temp45-id = `0000004711`.
    temp45-nr = `0000004711`.
    temp45-langu = `E`.
    INSERT temp45 INTO TABLE temp44.
    mt_row = temp44.

    CREATE OBJECT result.
    result->ms_layout-s_head-control = z2ui5_cl_layo_manager=>m_table.

    CLEAR temp46.

    CLEAR temp47.
    temp47-visible = abap_true.
    temp47-fname = `ID`.
    temp47-convexit = `ALPHA`.
    temp47-digits = 10.
    INSERT temp47 INTO TABLE temp46.
    CLEAR temp47.
    temp47-visible = abap_true.
    temp47-fname = `NR`.
    temp47-convexit = `NUMC`.
    temp47-digits = 10.
    INSERT temp47 INTO TABLE temp46.
    CLEAR temp47.
    temp47-visible = abap_true.
    temp47-fname = `LANGU`.
    temp47-convexit = `ISOLA`.
    INSERT temp47 INTO TABLE temp46.
    result->ms_layout-t_layout = temp46.

    GET REFERENCE OF mt_row INTO temp48.
result->set_data( temp48 ).

  ENDMETHOD.

  METHOD digits_alpha_char.

    cl_abap_unit_assert=>assert_equals(
        exp = 10
        act = z2ui5_cl_layo_manager=>get_digits( type     = cl_abap_elemdescr=>get_c( 10 )
                                                 convexit = `ALPHA` ) ).

  ENDMETHOD.

  METHOD digits_numc.

    " ALPHA or ALPH0 on a NUMC column is kept as NUMC by get_conversion_exit( )
    cl_abap_unit_assert=>assert_equals(
        exp = 12
        act = z2ui5_cl_layo_manager=>get_digits( type     = cl_abap_elemdescr=>get_n( 12 )
                                                 convexit = `NUMC` ) ).

  ENDMETHOD.

  METHOD digits_other_exits.

    " every other exit stays a conversion in ABAP
    cl_abap_unit_assert=>assert_equals(
        exp = 0
        act = z2ui5_cl_layo_manager=>get_digits( type     = cl_abap_elemdescr=>get_c( 40 )
                                                 convexit = `MATN1` ) ).
    cl_abap_unit_assert=>assert_equals(
        exp = 0
        act = z2ui5_cl_layo_manager=>get_digits( type     = cl_abap_elemdescr=>get_c( 3 )
                                                 convexit = `CUNIT` ) ).
    " a NUMC column without an exit shows its zeros, as in the SAP GUI
    cl_abap_unit_assert=>assert_equals(
        exp = 0
        act = z2ui5_cl_layo_manager=>get_digits( type     = cl_abap_elemdescr=>get_n( 6 )
                                                 convexit = `` ) ).

  ENDMETHOD.

  METHOD digit_type_switched_off.

    DATA temp49 TYPE z2ui5_cl_layo_manager=>ty_s_positions.
    DATA temp50 TYPE z2ui5_cl_layo_manager=>ty_s_positions.
    DATA temp51 TYPE z2ui5_cl_layo_manager=>ty_s_positions.
    CLEAR temp49.
    temp49-digits = 10.
    cl_abap_unit_assert=>assert_true(
        z2ui5_cl_layo_manager=>digit_type( temp49 ) ).
    " the user switched the conversion off in the layout popup

    CLEAR temp50.
    temp50-digits = 10.
    temp50-no_convexit = abap_true.
    cl_abap_unit_assert=>assert_false(
        z2ui5_cl_layo_manager=>digit_type( temp50 ) ).

    CLEAR temp51.
    temp51-convexit = `CUNIT`.
    cl_abap_unit_assert=>assert_false(
        z2ui5_cl_layo_manager=>digit_type( temp51 ) ).

  ENDMETHOD.

  METHOD binding_with_length.

    DATA temp52 TYPE z2ui5_cl_layo_manager=>ty_s_positions.
    CLEAR temp52.
    temp52-digits = 10.
    cl_abap_unit_assert=>assert_equals(
        exp = `{path:'VBELN',type:'LayoDigitString',constraints:{isDigitSequence:true,maxLength:10}}`
        act = z2ui5_cl_layo_manager=>digit_type_binding( path     = `VBELN`
                                                         position = temp52 ) ).
    cl_abap_unit_assert=>assert_equals(
        exp = `{LayoDigitString:'sap/ui/model/odata/type/String'}`
        act = z2ui5_cl_layo_manager=>digit_type_require( ) ).

  ENDMETHOD.

  METHOD conversion_default.

    DATA layout TYPE REF TO z2ui5_cl_layo_manager.
    FIELD-SYMBOLS <temp53> LIKE LINE OF mt_row.
    DATA temp54 LIKE sy-tabix.
    FIELD-SYMBOLS <temp55> LIKE LINE OF mt_row.
    DATA temp56 LIKE sy-tabix.
    FIELD-SYMBOLS <temp57> LIKE LINE OF mt_row.
    DATA temp58 LIKE sy-tabix.
    FIELD-SYMBOLS <temp59> LIKE LINE OF mt_row.
    DATA temp60 LIKE sy-tabix.
    FIELD-SYMBOLS <temp61> LIKE LINE OF mt_row.
    DATA temp62 LIKE sy-tabix.
    layout = layout( ).

    layout->data_conversion( abap_true ).

    " ALPHA on CHAR converted as before, NUMC never, every other exit as before


    temp54 = sy-tabix.
    READ TABLE mt_row INDEX 1 ASSIGNING <temp53>.
    sy-tabix = temp54.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `4711`
                                        act = condense( <temp53>-id ) ).


    temp56 = sy-tabix.
    READ TABLE mt_row INDEX 1 ASSIGNING <temp55>.
    sy-tabix = temp56.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `0000004711`
                                        act = <temp55>-nr ).


    temp58 = sy-tabix.
    READ TABLE mt_row INDEX 1 ASSIGNING <temp57>.
    sy-tabix = temp58.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `EN`
                                        act = <temp57>-langu ).

    layout->data_conversion( abap_false ).



    temp60 = sy-tabix.
    READ TABLE mt_row INDEX 1 ASSIGNING <temp59>.
    sy-tabix = temp60.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `0000004711`
                                        act = <temp59>-id ).


    temp62 = sy-tabix.
    READ TABLE mt_row INDEX 1 ASSIGNING <temp61>.
    sy-tabix = temp62.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `E`
                                        act = <temp61>-langu ).

  ENDMETHOD.

  METHOD conversion_alpha_in_browser.

    DATA layout TYPE REF TO z2ui5_cl_layo_manager.
    FIELD-SYMBOLS <temp63> LIKE LINE OF mt_row.
    DATA temp64 LIKE sy-tabix.
    FIELD-SYMBOLS <temp65> LIKE LINE OF mt_row.
    DATA temp66 LIKE sy-tabix.
    FIELD-SYMBOLS <temp67> LIKE LINE OF mt_row.
    DATA temp68 LIKE sy-tabix.
    FIELD-SYMBOLS <temp69> LIKE LINE OF layout->ms_layout-t_layout.
    DATA temp70 LIKE sy-tabix.
    FIELD-SYMBOLS <temp71> LIKE LINE OF mt_row.
    DATA temp72 LIKE sy-tabix.
    FIELD-SYMBOLS <temp73> LIKE LINE OF mt_row.
    DATA temp74 LIKE sy-tabix.
    layout = layout( ).
    layout->mv_alpha_in_browser = abap_true.

    layout->data_conversion( abap_true ).

    " the view formats ID and NR - they stay internal; LANGU is converted


    temp64 = sy-tabix.
    READ TABLE mt_row INDEX 1 ASSIGNING <temp63>.
    sy-tabix = temp64.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `0000004711`
                                        act = <temp63>-id ).


    temp66 = sy-tabix.
    READ TABLE mt_row INDEX 1 ASSIGNING <temp65>.
    sy-tabix = temp66.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `0000004711`
                                        act = <temp65>-nr ).


    temp68 = sy-tabix.
    READ TABLE mt_row INDEX 1 ASSIGNING <temp67>.
    sy-tabix = temp68.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `EN`
                                        act = <temp67>-langu ).

    " switched off in the layout popup: neither the view nor ABAP converts


    temp70 = sy-tabix.
    READ TABLE layout->ms_layout-t_layout WITH KEY fname = `ID` ASSIGNING <temp69>.
    sy-tabix = temp70.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    <temp69>-no_convexit = abap_true.
    layout->data_conversion( abap_false ).


    temp72 = sy-tabix.
    READ TABLE mt_row INDEX 1 ASSIGNING <temp71>.
    sy-tabix = temp72.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `0000004711`
                                        act = <temp71>-id ).


    temp74 = sy-tabix.
    READ TABLE mt_row INDEX 1 ASSIGNING <temp73>.
    sy-tabix = temp74.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    cl_abap_unit_assert=>assert_equals( exp = `E`
                                        act = <temp73>-langu ).

  ENDMETHOD.

  METHOD opened_layout_keeps_type.

    DATA head      TYPE z2ui5_t_11.
    TYPES temp13 TYPE STANDARD TABLE OF z2ui5_t_12 WITH DEFAULT KEY.
DATA positions TYPE temp13.
    DATA temp75 LIKE positions.
    DATA temp76 LIKE LINE OF temp75.
    DATA opened TYPE REF TO z2ui5_cl_layo_manager.
    DATA id TYPE z2ui5_cl_layo_manager=>ty_s_positions.
    FIELD-SYMBOLS <temp7> LIKE LINE OF opened->ms_layout-t_layout.
    DATA temp8 LIKE sy-tabix.
    DATA nr TYPE z2ui5_cl_layo_manager=>ty_s_positions.
    FIELD-SYMBOLS <temp9> LIKE LINE OF opened->ms_layout-t_layout.
    DATA temp10 LIKE sy-tabix.

    cleanup( ).

    CLEAR head.
    head-guid = c_guid.
    head-layout = `LTCL`.
    head-control = z2ui5_cl_layo_manager=>m_table.
    head-handle03 = `LTCL_CONV`.
    INSERT z2ui5_t_11 FROM head ##SUBRC_OK.

    CLEAR temp75.

    temp76-guid = c_guid.
    temp76-pos_guid = 'LTCLCONVPOS000000000000000000001'.
    temp76-fname = `ID`.
    temp76-visible = abap_true.
    INSERT temp76 INTO TABLE temp75.
    positions = temp75.
    INSERT z2ui5_t_12 FROM TABLE positions ##SUBRC_OK.


    opened = z2ui5_cl_layo_manager=>factory_by_guid( layout_guid = c_guid
                                                           t_comps     = layout( )->ms_layout-t_layout ).

    cleanup( ).

    " the saved position (ID) and the one saved without it (NR) keep what
    " the type of their component says



    temp8 = sy-tabix.
    READ TABLE opened->ms_layout-t_layout WITH KEY fname = `ID` ASSIGNING <temp7>.
    sy-tabix = temp8.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    id = <temp7>.
    cl_abap_unit_assert=>assert_equals( exp = `ALPHA`
                                        act = id-convexit ).
    cl_abap_unit_assert=>assert_equals( exp = 10
                                        act = id-digits ).



    temp10 = sy-tabix.
    READ TABLE opened->ms_layout-t_layout WITH KEY fname = `NR` ASSIGNING <temp9>.
    sy-tabix = temp10.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    nr = <temp9>.
    cl_abap_unit_assert=>assert_equals( exp = `NUMC`
                                        act = nr-convexit ).
    cl_abap_unit_assert=>assert_equals( exp = 10
                                        act = nr-digits ).

  ENDMETHOD.

  METHOD cleanup.

    DELETE FROM z2ui5_t_11 WHERE guid = c_guid ##SUBRC_OK.
    DELETE FROM z2ui5_t_12 WHERE guid = c_guid ##SUBRC_OK.
    COMMIT WORK.

  ENDMETHOD.

ENDCLASS.
