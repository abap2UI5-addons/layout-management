CLASS z2ui5_cl_layo_sample_05 DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_data.
        INCLUDE TYPE  z2ui5_t_11.
    TYPES:
        selkz TYPE abap_bool,
      END OF ty_s_data.
    TYPES ty_t_data TYPE STANDARD TABLE OF ty_s_data WITH EMPTY KEY.

    DATA mt_table        TYPE ty_t_data.
    DATA ms_struc        TYPE ty_s_data.
    DATA mo_layout       TYPE REF TO z2ui5_cl_layo_manager.
    DATA mo_table_layout TYPE REF TO z2ui5_cl_layo_manager.

  PROTECTED SECTION.
    DATA client            TYPE REF TO z2ui5_if_client.
    DATA check_initialized TYPE abap_bool.

    METHODS on_init.
    METHODS on_event.
    METHODS render_main.
    METHODS get_data.
    METHODS init_layout.
    METHODS on_after_navigation.

  PRIVATE SECTION.

ENDCLASS.


CLASS z2ui5_cl_layo_sample_05 IMPLEMENTATION.

  METHOD on_event.

    CASE client->get( )-event.

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN OTHERS.

        IF mo_layout->ms_layout-s_head-guid = client->get( )-event.

          z2ui5_cl_layo_pop=>on_event_layout( client = client
                                              layout = mo_layout ).

        ELSEIF mo_table_layout->ms_layout-s_head-guid = client->get( )-event.

          z2ui5_cl_layo_pop=>on_event_layout( client = client
                                              layout = mo_table_layout ).

        ENDIF.

    ENDCASE.
  ENDMETHOD.

  METHOD on_init.

    init_layout( ).

    get_data( ).

    render_main( ).
  ENDMETHOD.

  METHOD render_main.

    DATA(view) = z2ui5_cl_xml_view=>factory( )->shell( ).

    DATA(page) = view->page( title          = 'Layout'
                             navbuttonpress = client->_event( 'BACK' )
                             shownavbutton  = xsdbool( client->get( )-s_draft-id_prev_app_stack IS NOT INITIAL )
                             class          = 'sapUiContentPadding' ).

    z2ui5_cl_layo_xml_builder=>xml_build_table( i_data   = REF #( mt_table )
                                                i_xml    = page
                                                i_client = client
                                                i_layout = mo_Table_layout ).

    z2ui5_cl_layo_xml_builder=>xml_build_simple_form( i_data   = REF #( ms_struc )
                                                      i_xml    = page
                                                      i_client = client
                                                      i_layout = mo_layout
*                                                      i_title  =
    ).

    client->view_display( view->stringify( ) ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.
    me->client = client.

    IF check_initialized = abap_false.
      check_initialized = abap_true.
      on_init( ).
    ENDIF.

    on_event( ).

    IF client->get( )-check_on_navigated = abap_true.
      on_after_navigation( ).
    ENDIF.

  ENDMETHOD.

  METHOD get_data.

    SELECT * FROM z2ui5_t_11 INTO TABLE @mt_table UP TO 5 ROWS.

    ms_struc = VALUE #( mt_table[ 1 ] OPTIONAL ).

  ENDMETHOD.

  METHOD init_layout.

    IF mo_layout IS BOUND.
      RETURN.
    ENDIF.

    DATA(class) = cl_abap_classdescr=>get_class_name( me ).
    SHIFT class LEFT DELETING LEADING '\CLASS='.

    mo_table_layout = z2ui5_cl_layo_manager=>factory( control  = z2ui5_cl_layo_manager=>m_table
                                                data     = REF #( mt_table )
                                                handle01 = class
                                                handle02 = 'Z2UI5_T_01'
                                                handle03 = ''
                                                handle04 = '' ).

    mo_layout = z2ui5_cl_layo_manager=>factory( control  = z2ui5_cl_layo_manager=>ui_simpleform
                                                      data     = REF #( ms_struc )
                                                      handle01 = class
                                                      handle02 = 'Z2UI5_S_01'
                                                      handle03 = ''
                                                      handle04 = '' ).

  ENDMETHOD.

  METHOD on_after_navigation.

    TRY.

        DATA(app) = CAST z2ui5_cl_layo_pop( client->get_app( client->get( )-s_draft-id_prev_app ) ).

        IF     mo_layout->ms_layout-s_head-control  = app->mo_layout->ms_layout-s_head-control
           AND mo_layout->ms_layout-s_head-handle01 = app->mo_layout->ms_layout-s_head-handle01
           AND mo_layout->ms_layout-s_head-handle02 = app->mo_layout->ms_layout-s_head-handle02
           AND mo_layout->ms_layout-s_head-handle03 = app->mo_layout->ms_layout-s_head-handle03
           AND mo_layout->ms_layout-s_head-handle04 = app->mo_layout->ms_layout-s_head-handle04.

          mo_layout->ms_layout = app->mo_layout->ms_layout.
        ENDIF.

        IF     mo_table_layout->ms_layout-s_head-control  = app->mo_layout->ms_layout-s_head-control
           AND mo_table_layout->ms_layout-s_head-handle01 = app->mo_layout->ms_layout-s_head-handle01
           AND mo_table_layout->ms_layout-s_head-handle02 = app->mo_layout->ms_layout-s_head-handle02
           AND mo_table_layout->ms_layout-s_head-handle03 = app->mo_layout->ms_layout-s_head-handle03
           AND mo_table_layout->ms_layout-s_head-handle04 = app->mo_layout->ms_layout-s_head-handle04.
          mo_table_layout->ms_layout = app->mo_layout->ms_layout.
        ENDIF.

        IF app->mv_rerender = abap_true.
          " e.g. subcolumns need rerendering to work ..
          render_main( ).
        ELSE.
          "  for all other changes in Layout View Model Update is enough.
        ENDIF.
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
