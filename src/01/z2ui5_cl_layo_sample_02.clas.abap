CLASS z2ui5_cl_layo_sample_02 DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_tab,
        names             TYPE string,
        icon              TYPE z2ui5_xml_s_icon,
        generictag        TYPE z2ui5_xml_s_generictag,
        progressindicator TYPE z2ui5_xml_s_progressind,
        radialmicrochart  TYPE z2ui5_xml_s_radialchart,
        statusindicator   TYPE z2ui5_xml_s_statusind,
        selkz             TYPE abap_bool,
      END OF ty_s_tab.

    DATA ms_data   TYPE ty_s_tab.
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


CLASS z2ui5_cl_layo_sample_02 IMPLEMENTATION.

  METHOD on_event.

    CASE client->get( )-event.

      WHEN 'BACK'.
        client->nav_app_leave( ).

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

    DATA(view) = z2ui5_cl_ui5_view_builder=>factory(
                     )->ele( n = `View` ns = `mvc`
                     )->a( n = `xmlns` v = `sap.m`
                     )->a( n = `xmlns:mvc` v = `sap.ui.core.mvc`
                     " abap2ui5lint-disable unused-namespace-declaration -- z2ui5_cl_layo_xml_builder writes controls with these prefixes into this view
                     )->a( n = `xmlns:core` v = `sap.ui.core`
                     )->a( n = `xmlns:form` v = `sap.ui.layout.form`
                     )->a( n = `xmlns:layout` v = `sap.ui.layout`
                     )->a( n = `xmlns:mchart` v = `sap.suite.ui.microchart`
                     )->a( n = `xmlns:si` v = `sap.suite.ui.commons.statusindicator`
                     " abap2ui5lint-enable unused-namespace-declaration
                     )->a( n = `displayBlock` b = abap_true
                     )->a( n = `height` v = `100%`
                     )->ele( `Shell` ).

    DATA(page) = view->ele( `Page`
                     )->a( n = `title` v = `Layout`
                     )->a( n = `navButtonPress` v = client->_event( 'BACK' )
                     )->a( n = `showNavButton` b = client->check_app_prev_stack( )
                     )->a( n = `class` v = `sapUiContentPadding` ).

    z2ui5_cl_layo_xml_builder=>xml_build_simple_form( i_data   = REF #( ms_data )
                                                      i_xml    = page
                                                      i_client = client
                                                      i_layout = mo_layout ).

    client->view_display( view->stringify( ) ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.
    me->client = client.

    IF client->check_on_init( ).
      on_init( ).
    ELSEIF client->check_on_navigated( ).
      on_after_navigation( ).
    ELSEIF client->check_on_event( ).
      on_event( ).
    ENDIF.

  ENDMETHOD.

  METHOD get_data.

    ms_data = VALUE #( names             = 'Viktor'
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
                                                    statusindicator_size = 'Medium' ) ).

  ENDMETHOD.

  METHOD init_layout.

    IF mo_layout IS BOUND.
      RETURN.
    ENDIF.

    DATA(class) = cl_abap_classdescr=>get_class_name( me ).
    class = shift_left( val = class sub = `\CLASS=` ).

    mo_layout = z2ui5_cl_layo_manager=>factory( control  = z2ui5_cl_layo_manager=>ui_simpleform
                                                data     = REF #( ms_data )
                                                handle01 = class
                                                handle02 = 'USR01'
                                                handle03 = ''
                                                handle04 = '' ).

    LOOP AT mo_layout->ms_layout-t_layout REFERENCE INTO DATA(layout).

      layout->grid_label_xl = '4'.
      layout->grid_label_l  = '4'.
      layout->grid_label_m  = '4'.
      layout->grid_label_s  = '4'.

      layout->grid_value_xl = '8'.
      layout->grid_value_l  = '8'.
      layout->grid_value_m  = '8'.
      layout->grid_value_s  = '8'.

    ENDLOOP.

  ENDMETHOD.

  METHOD on_after_navigation.

    " back from the layout popup: take over the layout chosen there. Render
    " again only when the popup changed what the view is built from (e.g.
    " subcolumns) - for all other changes the changed model is enough, the
    " framework sends it by itself. Not back from the layout popup (e.g. a
    " restored draft): the view still has to be displayed
    IF z2ui5_cl_layo_pop=>take_over( client = client layout = mo_layout ) = abap_true
        OR client->check_on_nav_back( ) = abap_false.
      render_main( ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
