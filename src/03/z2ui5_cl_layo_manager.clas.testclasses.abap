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

    DATA heads     TYPE STANDARD TABLE OF z2ui5_t_11 WITH EMPTY KEY.
    DATA positions TYPE STANDARD TABLE OF z2ui5_t_12 WITH EMPTY KEY.

    cleanup( ).

    heads = VALUE #( ( guid          = c_source
                       layout        = `LTCL`
                       control       = z2ui5_cl_layo_manager=>m_table
                       handle03      = `LTCL_FROM`
                       handle04      = `0001`
                       screen_format = z2ui5_cl_layo_manager=>screen_format_l
                       descr         = `from`
                       def           = abap_true )
                     " the default of the target scope a copied default replaces
                     ( guid          = c_old_def
                       layout        = `OLD`
                       control       = z2ui5_cl_layo_manager=>m_table
                       handle03      = `LTCL_TO`
                       handle04      = `0002`
                       screen_format = z2ui5_cl_layo_manager=>screen_format_l
                       def           = abap_true )
                     " a default of another screen format stays one
                     ( guid          = c_other_s
                       layout        = `SMALL`
                       control       = z2ui5_cl_layo_manager=>m_table
                       handle03      = `LTCL_TO`
                       handle04      = `0002`
                       screen_format = z2ui5_cl_layo_manager=>screen_format_s
                       def           = abap_true ) ).
    INSERT z2ui5_t_11 FROM TABLE @heads ##SUBRC_OK.

    positions = VALUE #( ( guid = c_source pos_guid = 'LTCLCOPYPOS000000000000000000001' fname = `MATNR` visible = abap_true sequence = 1 )
                         ( guid = c_source pos_guid = 'LTCLCOPYPOS000000000000000000002' fname = `MAKTX` visible = abap_true sequence = 2 ) ).
    INSERT z2ui5_t_12 FROM TABLE @positions ##SUBRC_OK.

    " committed: the iv_commit tests roll back, and must only undo the copy
    COMMIT WORK.

  ENDMETHOD.

  METHOD teardown.
    cleanup( ).
    z2ui5_cl_layo_auth=>set_instance( ).
  ENDMETHOD.

  METHOD cleanup.

    DATA guids TYPE RANGE OF z2ui5_t_11-guid.

    " the positions of the copies have new pos_guids - found by their heads
    SELECT guid FROM z2ui5_t_11
      WHERE handle03 = `LTCL_FROM` OR handle03 = `LTCL_TO`
      ORDER BY PRIMARY KEY
      INTO TABLE @DATA(heads) ##SUBRC_OK.
    guids = VALUE #( FOR h IN heads ( sign = `I` option = `EQ` low = h-guid ) ).
    IF guids IS NOT INITIAL.
      DELETE FROM z2ui5_t_12 WHERE guid IN @guids ##SUBRC_OK.
    ENDIF.

    DELETE FROM z2ui5_t_11 WHERE handle03 = `LTCL_FROM` OR handle03 = `LTCL_TO` ##SUBRC_OK.
    DELETE FROM z2ui5_t_12 WHERE pos_guid LIKE 'LTCL%' OR guid = @c_source ##SUBRC_OK.
    COMMIT WORK.

  ENDMETHOD.

  METHOD copy_in_db.

    DATA count TYPE i.

    SELECT COUNT(*) FROM z2ui5_t_11
      WHERE handle03 = `LTCL_TO`
        AND layout   = `LTCL`
      INTO @count.
    result = xsdbool( count > 0 ).

  ENDMETHOD.

  METHOD copy_commits_by_default.

    DATA positions TYPE i.

    " iv_commit defaults to abap_true: the copy is committed, a ROLLBACK of
    " the caller afterwards does not undo it
    DATA(heads) = z2ui5_cl_layo_manager=>copy_layouts( t_copy     = VALUE #( ( guid     = c_source
                                                                               handle03 = `LTCL_TO`
                                                                               handle04 = `0002` ) )
                                                       check_auth = abap_false ).
    DATA(copy_guid) = heads[ 1 ]-guid.
    ROLLBACK WORK.

    cl_abap_unit_assert=>assert_true( copy_in_db( ) ).
    SELECT COUNT(*) FROM z2ui5_t_12 WHERE guid = @copy_guid INTO @positions.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = positions ).
    SELECT SINGLE def FROM z2ui5_t_11 WHERE guid = @c_old_def INTO @DATA(old_def) ##SUBRC_OK.
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = old_def ).

  ENDMETHOD.

  METHOD copy_no_commit_rollback.

    DATA positions        TYPE i.
    DATA source_positions TYPE i.

    " iv_commit = abap_false: the copy is part of the caller's LUW - the
    " caller's ROLLBACK undoes head, positions and the default demotion
    DATA(heads) = z2ui5_cl_layo_manager=>copy_layouts( t_copy     = VALUE #( ( guid     = c_source
                                                                               handle03 = `LTCL_TO`
                                                                               handle04 = `0002` ) )
                                                       check_auth = abap_false
                                                       iv_commit  = abap_false ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( heads ) ).
    " visible in the open LUW
    cl_abap_unit_assert=>assert_true( copy_in_db( ) ).

    DATA(copy_guid) = heads[ 1 ]-guid.
    ROLLBACK WORK.

    cl_abap_unit_assert=>assert_false( copy_in_db( ) ).
    SELECT COUNT(*) FROM z2ui5_t_12 WHERE guid = @copy_guid INTO @positions.
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = positions ).
    SELECT SINGLE def FROM z2ui5_t_11 WHERE guid = @c_old_def INTO @DATA(old_def) ##SUBRC_OK.
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = old_def ).
    " the original is untouched
    SELECT COUNT(*) FROM z2ui5_t_12 WHERE guid = @c_source INTO @source_positions.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = source_positions ).

  ENDMETHOD.

  METHOD copy_no_commit_caller_commits.

    " iv_commit = abap_false: the caller's COMMIT WORK writes the copy
    z2ui5_cl_layo_manager=>copy_layouts( t_copy     = VALUE #( ( guid     = c_source
                                                                 handle03 = `LTCL_TO`
                                                                 handle04 = `0002` ) )
                                         check_auth = abap_false
                                         iv_commit  = abap_false ).
    COMMIT WORK.
    ROLLBACK WORK.

    cl_abap_unit_assert=>assert_true( copy_in_db( ) ).

  ENDMETHOD.

  METHOD copy_with_positions.

    DATA(heads) = z2ui5_cl_layo_manager=>copy_layouts(
                      t_copy     = VALUE #( ( guid     = c_source
                                              handle03 = `LTCL_TO`
                                              handle04 = `0002`
                                              descr    = `to` ) )
                      check_auth = abap_false ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( heads ) ).
    DATA(head) = heads[ 1 ].
    cl_abap_unit_assert=>assert_differs( exp = c_source
                                         act = head-guid ).
    cl_abap_unit_assert=>assert_equals( exp = `LTCL`
                                        act = head-layout ).
    cl_abap_unit_assert=>assert_equals( exp = `to`
                                        act = head-descr ).

    SELECT SINGLE * FROM z2ui5_t_11 WHERE guid = @head-guid INTO @DATA(db_head).
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals( exp = `LTCL_TO`
                                        act = db_head-handle03 ).

    SELECT * FROM z2ui5_t_12 WHERE guid = @head-guid ORDER BY PRIMARY KEY INTO TABLE @DATA(db_positions) ##SUBRC_OK.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( db_positions ) ).
    LOOP AT db_positions INTO DATA(position).
      cl_abap_unit_assert=>assert_char_np( act = position-pos_guid
                                           exp = 'LTCL*' ).
    ENDLOOP.

    " the original is untouched
    SELECT SINGLE handle03 FROM z2ui5_t_11 WHERE guid = @c_source INTO @DATA(source_handle03) ##SUBRC_OK.
    cl_abap_unit_assert=>assert_equals( exp = `LTCL_FROM`
                                        act = source_handle03 ).
    SELECT * FROM z2ui5_t_12 WHERE guid = @c_source ORDER BY PRIMARY KEY INTO TABLE @DATA(source_positions) ##SUBRC_OK.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( source_positions ) ).

  ENDMETHOD.

  METHOD copy_demotes_default.

    z2ui5_cl_layo_manager=>copy_layouts( t_copy     = VALUE #( ( guid     = c_source
                                                                 handle03 = `LTCL_TO`
                                                                 handle04 = `0002` ) )
                                         check_auth = abap_false ).

    SELECT SINGLE def FROM z2ui5_t_11 WHERE guid = @c_old_def INTO @DATA(old_def) ##SUBRC_OK.
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = old_def ).

    SELECT SINGLE def FROM z2ui5_t_11 WHERE guid = @c_other_s INTO @DATA(other_def) ##SUBRC_OK.
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = other_def ).

  ENDMETHOD.

  METHOD copy_unknown_raises.

    TRY.
        z2ui5_cl_layo_manager=>copy_layouts( t_copy     = VALUE #( ( guid     = 'LTCLCOPYDOESNOTEXIST000000000001'
                                                                     handle03 = `LTCL_TO` ) )
                                             check_auth = abap_false ).
        cl_abap_unit_assert=>fail( `no exception for an unknown layout` ).
      CATCH z2ui5_cx_layo_error ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD copy_denied_by_auth.

    DATA count TYPE i.

    " a system's own z2ui5_if_layo_auth that refuses - nothing is written
    z2ui5_cl_layo_auth=>set_instance( NEW ltd_deny_all( ) ).

    TRY.
        z2ui5_cl_layo_manager=>copy_layouts( VALUE #( ( guid     = c_source
                                                        handle03 = `LTCL_TO`
                                                        handle04 = `0002` ) ) ).
        cl_abap_unit_assert=>fail( `the copy was not checked` ).
      CATCH z2ui5_cx_layo_error ##NO_HANDLER.
    ENDTRY.

    SELECT COUNT(*) FROM z2ui5_t_11 WHERE handle03 = `LTCL_TO` INTO @count.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = count ).

  ENDMETHOD.

  METHOD copy_checked_by_default.

    " the shipped default allows a shared layout - the copy goes through
    DATA(heads) = z2ui5_cl_layo_manager=>copy_layouts( VALUE #( ( guid     = c_source
                                                                  handle03 = `LTCL_TO`
                                                                  handle04 = `0002` ) ) ).

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

    DATA heads TYPE STANDARD TABLE OF z2ui5_t_11 WITH EMPTY KEY.

    cleanup( ).

    heads = VALUE #( control  = z2ui5_cl_layo_manager=>m_table
                     handle01 = `LTCL_APP`
                     ( guid = c_shared    layout = `SHARED` handle03 = `LTCL_SEL_A` handle04 = `0001` )
                     ( guid = c_own       layout = `OWN`    handle03 = `LTCL_SEL_A` handle04 = `0001` uname = sy-uname )
                     ( guid = c_other     layout = `OTHER`  handle03 = `LTCL_SEL_B` handle04 = `0001` uname = c_other_user )
                     ( guid = c_elsewhere layout = `ELSE`   handle03 = `LTCL_SEL_B` handle04 = `0002` ) ).
    INSERT z2ui5_t_11 FROM TABLE @heads ##SUBRC_OK.

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
    result = VALUE #( ( sign = `I` option = `CP` low = `LTCL_SEL*` ) ).
  ENDMETHOD.

  METHOD own_and_shared_by_default.

    DATA(heads) = z2ui5_cl_layo_manager=>select_layouts_by_range( handle03 = scope( ) ).

    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( heads ) ).
    cl_abap_unit_assert=>assert_false( xsdbool( line_exists( heads[ guid = c_other ] ) ) ).

  ENDMETHOD.

  METHOD all_users_admin.

    DATA(heads) = z2ui5_cl_layo_manager=>select_layouts_by_range( handle03   = scope( )
                                                                  all_users  = abap_true
                                                                  check_auth = abap_false ).

    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = lines( heads ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( line_exists( heads[ guid  = c_other
                                                                   uname = c_other_user ] ) ) ).

  ENDMETHOD.

  METHOD all_users_default_auth.

    " the shipped default never hands out another user's personal layout
    DATA(heads) = z2ui5_cl_layo_manager=>select_layouts_by_range( handle03  = scope( )
                                                                  all_users = abap_true ).

    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( heads ) ).
    cl_abap_unit_assert=>assert_false( xsdbool( line_exists( heads[ guid = c_other ] ) ) ).

  ENDMETHOD.

  METHOD all_users_hook_allows.

    z2ui5_cl_layo_auth=>set_instance( NEW ltd_allow_all( ) ).

    DATA(heads) = z2ui5_cl_layo_manager=>select_layouts_by_range( handle03  = scope( )
                                                                  all_users = abap_true ).

    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = lines( heads ) ).

  ENDMETHOD.

  METHOD ranges_restrict.

    DATA lv_handle04 TYPE z2ui5_cl_layo_manager=>ty_r_handle.
    DATA lv_layout   TYPE z2ui5_cl_layo_manager=>ty_r_layout.

    lv_handle04 = VALUE #( ( sign = `I` option = `EQ` low = `0001` ) ).
    DATA(heads) = z2ui5_cl_layo_manager=>select_layouts_by_range( handle03   = scope( )
                                                                  handle04   = lv_handle04
                                                                  all_users  = abap_true
                                                                  check_auth = abap_false ).
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( heads ) ).
    cl_abap_unit_assert=>assert_false( xsdbool( line_exists( heads[ guid = c_elsewhere ] ) ) ).

    lv_layout = VALUE #( ( sign = `E` option = `EQ` low = `SHARED` ) ).
    heads = z2ui5_cl_layo_manager=>select_layouts_by_range( handle03 = scope( )
                                                            handle04 = lv_handle04
                                                            layout   = lv_layout ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( heads ) ).
    cl_abap_unit_assert=>assert_equals( exp = c_own
                                        act = heads[ 1 ]-guid ).

  ENDMETHOD.

  METHOD select_then_copy.

    DATA lv_handle03 TYPE z2ui5_cl_layo_manager=>ty_r_handle.

    lv_handle03 = VALUE #( ( sign = `I` option = `EQ` low = `LTCL_SEL_A` ) ).
    DATA(heads) = z2ui5_cl_layo_manager=>select_layouts_by_range( handle03   = lv_handle03
                                                                  all_users  = abap_true
                                                                  check_auth = abap_false ).

    DATA(copies) = z2ui5_cl_layo_manager=>copy_layouts(
                       t_copy     = VALUE #( FOR h IN heads
                                             ( guid     = h-guid
                                               handle01 = h-handle01
                                               handle02 = h-handle02
                                               handle03 = `LTCL_SEL_C`
                                               handle04 = h-handle04 ) )
                       check_auth = abap_false ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( copies ) ).
    lv_handle03 = VALUE #( ( sign = `I` option = `EQ` low = `LTCL_SEL_C` ) ).
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
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.

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
    METHODS opened_layout_own_sub_cols FOR TESTING.

    METHODS layout
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_layo_manager.

    METHODS cleanup.
ENDCLASS.


CLASS ltcl_conv IMPLEMENTATION.

  METHOD layout.

    mt_row = VALUE #( ( id = `0000004711` nr = `0000004711` langu = `E` ) ).

    result = NEW #( ).
    result->ms_layout-s_head-control = z2ui5_cl_layo_manager=>m_table.
    result->ms_layout-t_layout = VALUE #( visible = abap_true
                                          ( fname = `ID`    convexit = `ALPHA` digits = 10 )
                                          ( fname = `NR`    convexit = `NUMC`  digits = 10 )
                                          ( fname = `LANGU` convexit = `ISOLA` ) ).
    result->set_data( REF #( mt_row ) ).

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

    cl_abap_unit_assert=>assert_true(
        z2ui5_cl_layo_manager=>digit_type( VALUE #( digits = 10 ) ) ).
    " the user switched the conversion off in the layout popup
    cl_abap_unit_assert=>assert_false(
        z2ui5_cl_layo_manager=>digit_type( VALUE #( digits = 10 no_convexit = abap_true ) ) ).
    cl_abap_unit_assert=>assert_false(
        z2ui5_cl_layo_manager=>digit_type( VALUE #( convexit = `CUNIT` ) ) ).

  ENDMETHOD.

  METHOD binding_with_length.

    cl_abap_unit_assert=>assert_equals(
        exp = `{path:'VBELN',type:'LayoDigitString',constraints:{isDigitSequence:true,maxLength:10}}`
        act = z2ui5_cl_layo_manager=>digit_type_binding( path     = `VBELN`
                                                         position = VALUE #( digits = 10 ) ) ).
    cl_abap_unit_assert=>assert_equals(
        exp = `{LayoDigitString:'sap/ui/model/odata/type/String'}`
        act = z2ui5_cl_layo_manager=>digit_type_require( ) ).

  ENDMETHOD.

  METHOD conversion_default.

    DATA(layout) = layout( ).

    layout->data_conversion( abap_true ).

    " ALPHA on CHAR converted as before, NUMC never, every other exit as before
    cl_abap_unit_assert=>assert_equals( exp = `4711`
                                        act = condense( mt_row[ 1 ]-id ) ).
    cl_abap_unit_assert=>assert_equals( exp = `0000004711`
                                        act = mt_row[ 1 ]-nr ).
    cl_abap_unit_assert=>assert_equals( exp = `EN`
                                        act = mt_row[ 1 ]-langu ).

    layout->data_conversion( abap_false ).

    cl_abap_unit_assert=>assert_equals( exp = `0000004711`
                                        act = mt_row[ 1 ]-id ).
    cl_abap_unit_assert=>assert_equals( exp = `E`
                                        act = mt_row[ 1 ]-langu ).

  ENDMETHOD.

  METHOD conversion_alpha_in_browser.

    DATA(layout) = layout( ).
    layout->mv_alpha_in_browser = abap_true.

    layout->data_conversion( abap_true ).

    " the view formats ID and NR - they stay internal; LANGU is converted
    cl_abap_unit_assert=>assert_equals( exp = `0000004711`
                                        act = mt_row[ 1 ]-id ).
    cl_abap_unit_assert=>assert_equals( exp = `0000004711`
                                        act = mt_row[ 1 ]-nr ).
    cl_abap_unit_assert=>assert_equals( exp = `EN`
                                        act = mt_row[ 1 ]-langu ).

    " switched off in the layout popup: neither the view nor ABAP converts
    layout->ms_layout-t_layout[ fname = `ID` ]-no_convexit = abap_true.
    layout->data_conversion( abap_false ).
    cl_abap_unit_assert=>assert_equals( exp = `0000004711`
                                        act = mt_row[ 1 ]-id ).
    cl_abap_unit_assert=>assert_equals( exp = `E`
                                        act = mt_row[ 1 ]-langu ).

  ENDMETHOD.

  METHOD opened_layout_keeps_type.

    DATA head      TYPE z2ui5_t_11.
    DATA positions TYPE STANDARD TABLE OF z2ui5_t_12 WITH EMPTY KEY.

    cleanup( ).

    head = VALUE #( guid     = c_guid
                    layout   = `LTCL`
                    control  = z2ui5_cl_layo_manager=>m_table
                    handle03 = `LTCL_CONV` ).
    INSERT z2ui5_t_11 FROM @head ##SUBRC_OK.
    positions = VALUE #( ( guid = c_guid pos_guid = 'LTCLCONVPOS000000000000000000001' fname = `ID` visible = abap_true ) ).
    INSERT z2ui5_t_12 FROM TABLE @positions ##SUBRC_OK.

    DATA(opened) = z2ui5_cl_layo_manager=>factory_by_guid( layout_guid = c_guid
                                                           t_comps     = layout( )->ms_layout-t_layout ).

    cleanup( ).

    " the saved position (ID) and the one saved without it (NR) keep what
    " the type of their component says
    DATA(id) = opened->ms_layout-t_layout[ fname = `ID` ].
    cl_abap_unit_assert=>assert_equals( exp = `ALPHA`
                                        act = id-convexit ).
    cl_abap_unit_assert=>assert_equals( exp = 10
                                        act = id-digits ).
    DATA(nr) = opened->ms_layout-t_layout[ fname = `NR` ].
    cl_abap_unit_assert=>assert_equals( exp = `NUMC`
                                        act = nr-convexit ).
    cl_abap_unit_assert=>assert_equals( exp = 10
                                        act = nr-digits ).

  ENDMETHOD.

  METHOD opened_layout_own_sub_cols.

    DATA head      TYPE z2ui5_t_11.
    DATA positions TYPE STANDARD TABLE OF z2ui5_t_12 WITH EMPTY KEY.

    cleanup( ).

    head = VALUE #( guid     = c_guid
                    layout   = `LTCL`
                    control  = z2ui5_cl_layo_manager=>m_table
                    handle03 = `LTCL_CONV` ).
    INSERT z2ui5_t_11 FROM @head ##SUBRC_OK.
    positions = VALUE #( ( guid = c_guid pos_guid = 'LTCLCONVPOS000000000000000000001' fname = `ID` visible = abap_true )
                         ( guid = c_guid pos_guid = 'LTCLCONVPOS000000000000000000002' fname = `NR` visible = abap_true
                           subcolumn = `LANGU` ) ).
    INSERT z2ui5_t_12 FROM TABLE @positions ##SUBRC_OK.

    " the layout shown before has subcolumns on ID, the opened one on NR only
    DATA(before) = layout( )->ms_layout-t_layout.
    ASSIGN before[ fname = `ID` ] TO FIELD-SYMBOL(<id>).
    <id>-subcolumn = `NR`.
    <id>-t_sub_col = VALUE #( ( fname = `NR` ) ).

    DATA(opened) = z2ui5_cl_layo_manager=>factory_by_guid( layout_guid = c_guid
                                                           t_comps     = before ).

    cleanup( ).

    cl_abap_unit_assert=>assert_initial( opened->ms_layout-t_layout[ fname = `ID` ]-t_sub_col ).
    DATA(nr_sub_col) = opened->ms_layout-t_layout[ fname = `NR` ]-t_sub_col.
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( nr_sub_col ) ).
    cl_abap_unit_assert=>assert_equals( exp = `LANGU`
                                        act = nr_sub_col[ 1 ]-fname ).

  ENDMETHOD.

  METHOD cleanup.

    DELETE FROM z2ui5_t_11 WHERE guid = @c_guid ##SUBRC_OK.
    DELETE FROM z2ui5_t_12 WHERE guid = @c_guid ##SUBRC_OK.
    COMMIT WORK.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_same_layout DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS same_control_and_handles FOR TESTING.
    METHODS other_handle FOR TESTING.
    METHODS other_control FOR TESTING.
    METHODS unbound FOR TESTING.

    "! a manager with the head the layout popup compares
    METHODS layout
      IMPORTING
        !control      TYPE clike
        handle04      TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_layo_manager.
ENDCLASS.


CLASS ltcl_same_layout IMPLEMENTATION.

  METHOD layout.

    result = NEW #( ).
    result->ms_layout-s_head-control  = control.
    result->ms_layout-s_head-handle01 = `APP`.
    result->ms_layout-s_head-handle02 = `TABLE`.
    result->ms_layout-s_head-handle03 = `X`.
    result->ms_layout-s_head-handle04 = handle04.

  ENDMETHOD.

  METHOD same_control_and_handles.

    " the guid differs - another variant of the same table is the same layout
    DATA(lo_other) = layout( control  = z2ui5_cl_layo_manager=>m_table
                             handle04 = `4` ).
    lo_other->ms_layout-s_head-guid = `OTHER`.

    cl_abap_unit_assert=>assert_true( layout( control  = z2ui5_cl_layo_manager=>m_table
                                              handle04 = `4` )->is_same_layout( lo_other ) ).

  ENDMETHOD.

  METHOD other_handle.

    cl_abap_unit_assert=>assert_false( layout( control  = z2ui5_cl_layo_manager=>m_table
                                               handle04 = `4` )->is_same_layout(
                                         layout( control  = z2ui5_cl_layo_manager=>m_table
                                                 handle04 = `5` ) ) ).

  ENDMETHOD.

  METHOD other_control.

    cl_abap_unit_assert=>assert_false( layout( control  = z2ui5_cl_layo_manager=>m_table
                                               handle04 = `4` )->is_same_layout(
                                         layout( control  = z2ui5_cl_layo_manager=>ui_simpleform
                                                 handle04 = `4` ) ) ).

  ENDMETHOD.

  METHOD unbound.

    DATA lo_none TYPE REF TO z2ui5_cl_layo_manager.

    cl_abap_unit_assert=>assert_false( layout( control  = z2ui5_cl_layo_manager=>m_table
                                               handle04 = `4` )->is_same_layout( lo_none ) ).

  ENDMETHOD.

ENDCLASS.
