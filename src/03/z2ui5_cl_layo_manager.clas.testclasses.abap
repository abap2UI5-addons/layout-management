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
  RISK LEVEL HARMLESS.

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

    METHODS cleanup.
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

  ENDMETHOD.

  METHOD teardown.
    cleanup( ).
    z2ui5_cl_layo_auth=>set_instance( ).
  ENDMETHOD.

  METHOD cleanup.

    DELETE FROM z2ui5_t_11 WHERE handle03 = `LTCL_FROM` OR handle03 = `LTCL_TO` ##SUBRC_OK.
    DELETE FROM z2ui5_t_12 WHERE pos_guid LIKE 'LTCL%' OR guid = @c_source ##SUBRC_OK.
    COMMIT WORK.

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
  RISK LEVEL HARMLESS.

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
