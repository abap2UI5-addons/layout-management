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
    METHODS copy_shared_denied FOR TESTING.

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
    INSERT z2ui5_t_11 FROM TABLE @heads.

    positions = VALUE #( ( guid = c_source pos_guid = 'LTCLCOPYPOS000000000000000000001' fname = `MATNR` visible = abap_true sequence = 1 )
                         ( guid = c_source pos_guid = 'LTCLCOPYPOS000000000000000000002' fname = `MAKTX` visible = abap_true sequence = 2 ) ).
    INSERT z2ui5_t_12 FROM TABLE @positions.

  ENDMETHOD.

  METHOD teardown.
    cleanup( ).
    z2ui5_cl_layo_auth=>set_instance( ).
  ENDMETHOD.

  METHOD cleanup.

    DELETE FROM z2ui5_t_11 WHERE handle03 = `LTCL_FROM` OR handle03 = `LTCL_TO`.
    DELETE FROM z2ui5_t_12 WHERE pos_guid LIKE 'LTCL%' OR guid = @c_source.
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

    SELECT * FROM z2ui5_t_12 WHERE guid = @head-guid INTO TABLE @DATA(db_positions).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( db_positions ) ).
    LOOP AT db_positions INTO DATA(position).
      cl_abap_unit_assert=>assert_char_np( act = position-pos_guid
                                           exp = 'LTCL*' ).
    ENDLOOP.

    " the original is untouched
    SELECT SINGLE handle03 FROM z2ui5_t_11 WHERE guid = @c_source INTO @DATA(source_handle03).
    cl_abap_unit_assert=>assert_equals( exp = `LTCL_FROM`
                                        act = source_handle03 ).
    SELECT * FROM z2ui5_t_12 WHERE guid = @c_source INTO TABLE @DATA(source_positions).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( source_positions ) ).

  ENDMETHOD.

  METHOD copy_demotes_default.

    z2ui5_cl_layo_manager=>copy_layouts( t_copy     = VALUE #( ( guid     = c_source
                                                                 handle03 = `LTCL_TO`
                                                                 handle04 = `0002` ) )
                                         check_auth = abap_false ).

    SELECT SINGLE def FROM z2ui5_t_11 WHERE guid = @c_old_def INTO @DATA(old_def).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = old_def ).

    SELECT SINGLE def FROM z2ui5_t_11 WHERE guid = @c_other_s INTO @DATA(other_def).
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

  METHOD copy_shared_denied.

    DATA count TYPE i.

    " the shipped default: nobody may save a layout for all users
    TRY.
        z2ui5_cl_layo_manager=>copy_layouts( VALUE #( ( guid     = c_source
                                                        handle03 = `LTCL_TO`
                                                        handle04 = `0002` ) ) ).
        cl_abap_unit_assert=>fail( `a shared copy was not checked` ).
      CATCH z2ui5_cx_layo_error ##NO_HANDLER.
    ENDTRY.

    SELECT COUNT(*) FROM z2ui5_t_11 WHERE handle03 = `LTCL_TO` INTO @count.
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = count ).

  ENDMETHOD.

ENDCLASS.
