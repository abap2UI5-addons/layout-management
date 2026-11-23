CLASS z2ui5_cl_layo_sample_01 DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES  BEGIN OF ty_s_tab.
    TYPES:   Names             TYPE string,
             icon              TYPE z2ui5_xml_s_icon,
             generictag        TYPE z2ui5_xml_s_generictag,
             progressindicator TYPE z2ui5_xml_s_progressind,
             radialmicrochart  TYPE z2ui5_xml_s_radialchart,
             statusindicator   TYPE z2ui5_xml_s_statusind,
             selkz             TYPE abap_bool,
           END OF ty_s_tab.
    TYPES ty_t_table TYPE STANDARD TABLE OF ty_s_tab WITH EMPTY KEY.

    DATA mt_table  TYPE ty_t_table.
    DATA mo_layout TYPE REF TO z2ui5_cl_layo_manager.

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


CLASS z2ui5_cl_layo_sample_01 IMPLEMENTATION.

  METHOD on_event.

    CASE client->get( )-event.

      WHEN 'ROW_SELECT'.

        mo_layout->set_selkz( t_event_arg = client->get( )-t_event_arg ).

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN OTHERS.

        z2ui5_cl_layo_pop=>on_event_layout( client = client
                                            layout = mo_layout ).

    ENDCASE.

  ENDMETHOD.

  METHOD on_init.

    get_data( ).

    init_layout( ).

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
                                                i_layout = mo_layout ).

    client->view_display( view->stringify( ) ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.
    me->client = client.

    IF check_initialized = abap_false.
      check_initialized = abap_true.
      on_init( ).
    ENDIF.

    on_event( ).

    mo_layout->sort( ).

    IF client->get( )-check_on_navigated = abap_true.
      on_after_navigation( ).
    ENDIF.

  ENDMETHOD.

  METHOD get_data.

    mt_table = VALUE #( ( names             = 'Viktor'
                          icon              = VALUE #( src       = 'sap-icon://customer'
                                                       icon_size = '2rem' )
                          generictag        = VALUE #( text   = 'Viktor'
                                                       status = 'Warning'
                                                       design = 'StatusIconHidden' )
                          progressindicator = VALUE #( percentvalue = '70'
                                                       state        = 'Warning'  )
                          radialmicrochart  = VALUE #( percentage            = '70'
                                                       valuecolor            = 'Critical'
                                                       radialmicrochart_size = 'S' )
                          statusindicator   = VALUE #( value                = '70'
                                                       fillcolor_error      = '100'
                                                       fillcolor_critical   = '80'
                                                       fillcolor_good       = '40'
                                                       shapeid              = 'tool'
                                                       statusindicator_size = 'Medium' ) )
                        ( names             = 'Lars'
                          icon              = VALUE #( src       = 'sap-icon://end-user-experience-monitoring'
                                                       icon_size = '2rem' )
                          generictag        = VALUE #( text   = 'Lars'
                                                       status = 'Success'
                                                       design = 'StatusIconHidden' )
                          progressindicator = VALUE #( percentvalue = '20'
                                                       state        = 'Success'  )
                          radialmicrochart  = VALUE #( percentage            = '20'
                                                       valuecolor            = 'Good'
                                                       radialmicrochart_size = 'S' )
                          statusindicator   = VALUE #( value                = '20'
                                                       fillcolor_error      = '100'
                                                       fillcolor_critical   = '80'
                                                       fillcolor_good       = '40'
                                                       shapeid              = 'tool'
                                                       statusindicator_size = 'Medium' ) ) ).

  ENDMETHOD.

  METHOD init_layout.

    IF mo_layout IS BOUND.
      RETURN.
    ENDIF.

    DATA(class) = cl_abap_classdescr=>get_class_name( me ).
    SHIFT class LEFT DELETING LEADING '\CLASS='.

    mo_layout = z2ui5_cl_layo_manager=>factory( control  = z2ui5_cl_layo_manager=>m_table
                                                data     = REF #( mt_table )
                                                handle01 = class
                                                handle02 = 'Z2UI5_T_01'
                                                handle03 = ''
                                                handle04 = '' ).

  ENDMETHOD.

  METHOD on_after_navigation.

    CHECK client->check_on_navigated( ).

    TRY.

        DATA(app) = CAST z2ui5_cl_layo_pop( client->get_app( client->get( )-s_draft-id_prev_app ) ).
        mo_layout = app->mo_layout.

        render_main( ).

      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
