CLASS z2ui5_cl_layo_sample_01 DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES  BEGIN OF ty_s_tab.
    TYPES:   names             TYPE string,
             icon              TYPE z2ui5_xml_s_icon,
             generictag        TYPE z2ui5_xml_s_generictag,
             progressindicator TYPE z2ui5_xml_s_progressind,
             radialmicrochart  TYPE z2ui5_xml_s_radialchart,
             statusindicator   TYPE z2ui5_xml_s_statusind,
             selkz             TYPE abap_bool,
           END OF ty_s_tab.
    TYPES ty_t_table TYPE STANDARD TABLE OF ty_s_tab WITH EMPTY KEY.

    " abap2ui5lint-disable-next-line unbound-public-attribute -- z2ui5_cl_layo_xml_builder=>xml_build_table( ) binds it, handed over as REF #( mt_table )
    DATA mt_table  TYPE ty_t_table.
    DATA mo_layout TYPE REF TO z2ui5_cl_layo_manager.

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


CLASS z2ui5_cl_layo_sample_01 IMPLEMENTATION.

  METHOD on_event.

    CASE client->get( )-event.

      WHEN 'ROW_SELECT'.

        mo_layout->set_selkz( client->get( )-t_event_arg ).

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN OTHERS.

        z2ui5_cl_layo_pop=>on_event_layout( client = client
                                            layout = mo_layout ).

    ENDCASE.

    client->view_model_update( ).

  ENDMETHOD.

  METHOD on_init.

    get_data( ).

    init_layout( ).

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
                                                i_layout = mo_layout ).

    client->view_display( view->stringify( ) ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.
    me->client = client.

    IF client->check_on_init( ).
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

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
