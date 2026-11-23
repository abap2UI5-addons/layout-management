CLASS z2ui5_cl_layo_sample_02 DEFINITION
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

    DATA ms_data   TYPE ty_s_tab.
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


CLASS z2ui5_cl_layo_sample_02 IMPLEMENTATION.

  METHOD on_event.

    CASE client->get( )-event.

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

    z2ui5_cl_layo_xml_builder=>xml_build_simple_form( i_data   = REF #( ms_data )
                                                      i_xml    = page
                                                      i_client = client
                                                      i_layout = mo_layout
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

    ms_data = VALUE #( names             = 'Viktor'
                       icon              = VALUE #( src       = 'sap-icon://customer'
                                                    icon_size = '2rem' )
                       generictag        = VALUE #( text   = 'Viktor'
                                                    status = 'Warning'
                                                    design = 'StatusIconHidden' )
                       progressindicator = VALUE #( percentvalue = '70'
                                                    state        = 'Warning'  )
                       radialmicrochart  = VALUE #( percentage = '70'
                                                    valuecolor = 'Critical'
                                                    radialmicrochart_size       = 'S' )
                       statusindicator   = VALUE #( value              = '70'
                                                    fillcolor_error    = '100'
                                                    fillcolor_critical = '80'
                                                    fillcolor_good     = '40'
                                                    shapeid            = 'tool'
                                                    statusindicator_size               = 'Medium' ) ).

  ENDMETHOD.

  METHOD init_layout.

    IF mo_layout IS BOUND.
      RETURN.
    ENDIF.

    DATA(class) = cl_abap_classdescr=>get_class_name( me ).
    SHIFT class LEFT DELETING LEADING '\CLASS='.

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

    CHECK client->check_on_navigated( ).

    TRY.

        DATA(app) = CAST z2ui5_cl_layo_pop( client->get_app( client->get( )-s_draft-id_prev_app ) ).
        mo_layout = app->mo_layout.

        IF app->mv_rerender = abap_true.
          " subcolumns need rerendering to work ..
          render_main( ).
        ELSE.
          "  for all other changes in Layout View Model Update is enough.
        ENDIF.
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
