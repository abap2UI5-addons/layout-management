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

    " abap2ui5lint-disable-next-line unbound-public-attribute -- z2ui5_cl_layo_xml_builder=>xml_build_table( ) binds it, handed over as REF #( mt_table )
    DATA mt_table        TYPE ty_t_data.
    " abap2ui5lint-disable-next-line unbound-public-attribute -- z2ui5_cl_layo_xml_builder=>xml_build_simple_form( ) binds it, handed over as REF #( ms_struc )
    DATA ms_struc        TYPE ty_s_data.
    DATA mo_layout       TYPE REF TO z2ui5_cl_layo_manager.
    DATA mo_table_layout TYPE REF TO z2ui5_cl_layo_manager.

  PROTECTED SECTION.
    DATA client            TYPE REF TO z2ui5_if_client.

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

    DATA(view) = z2ui5_cl_ui5_view_builder=>factory(
                     )->ele( n = `View` ns = `mvc`
                     )->a( n = `xmlns` v = `sap.m`
                     )->a( n = `xmlns:mvc` v = `sap.ui.core.mvc`
                     " abap2ui5lint-disable unused-namespace-declaration -- z2ui5_cl_layo_xml_builder writes controls with these prefixes into this view
                     )->a( n = `xmlns:core` v = `sap.ui.core`
                     )->a( n = `xmlns:form` v = `sap.ui.layout.form`
                     )->a( n = `xmlns:mchart` v = `sap.suite.ui.microchart`
                     )->a( n = `xmlns:si` v = `sap.suite.ui.commons.statusindicator`
                     " abap2ui5lint-enable unused-namespace-declaration
                     )->a( n = `displayBlock` v = `true`
                     )->a( n = `height` v = `100%`
                     )->ele( `Shell` ).

    DATA(page) = view->ele( `Page`
                     )->a( n = `title` v = 'Layout'
                     )->a( n = `navButtonPress` v = client->_event( 'BACK' )
                     )->a( n = `showNavButton` b = xsdbool( client->get( )-s_draft-id_prev_app_stack IS NOT INITIAL )
                     )->a( n = `class` v = 'sapUiContentPadding' ).

    z2ui5_cl_layo_xml_builder=>xml_build_table( i_data   = REF #( mt_table )
                                                i_xml    = page
                                                i_client = client
                                                i_layout = mo_table_layout ).

    z2ui5_cl_layo_xml_builder=>xml_build_simple_form( i_data   = REF #( ms_struc )
                                                      i_xml    = page
                                                      i_client = client
                                                      i_layout = mo_layout ).

    client->view_display( view->stringify( ) ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.
    me->client = client.

    IF client->check_on_init( ).
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
          client->view_model_update( ).
        ENDIF.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
