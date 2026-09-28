CLASS z2ui5_cl_layo_sample_02 DEFINITION
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

    " abap2ui5lint-disable-next-line unbound-public-attribute -- z2ui5_cl_layo_xml_builder=>xml_build_simple_form( ) binds it, handed over as REF #( ms_data )
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

    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA page TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA temp2 TYPE xsdboolean.
    DATA temp1 LIKE REF TO ms_data.
    view = z2ui5_cl_ui5_view_builder=>factory(
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



    temp2 = boolc( client->get( )-s_draft-id_prev_app_stack IS NOT INITIAL ).
    page = view->ele( `Page`
                     )->a( n = `title` v = 'Layout'
                     )->a( n = `navButtonPress` v = client->_event( 'BACK' )
                     )->a( n = `showNavButton` b = temp2
                     )->a( n = `class` v = 'sapUiContentPadding' ).


    GET REFERENCE OF ms_data INTO temp1.
z2ui5_cl_layo_xml_builder=>xml_build_simple_form( i_data   = temp1
                                                      i_xml    = page
                                                      i_client = client
                                                      i_layout = mo_layout ).

    client->view_display( view->stringify( ) ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.
    me->client = client.

    IF client->check_on_init( ) IS NOT INITIAL.
      on_init( ).
    ENDIF.

    on_event( ).

    IF client->get( )-check_on_navigated = abap_true.
      on_after_navigation( ).
    ENDIF.

  ENDMETHOD.

  METHOD get_data.

    CLEAR ms_data.
    ms_data-names = 'Viktor'.
    CLEAR ms_data-icon.
    ms_data-icon-src = 'sap-icon://customer'.
    ms_data-icon-icon_size = '2rem'.
    CLEAR ms_data-generictag.
    ms_data-generictag-text = 'Viktor'.
    ms_data-generictag-status = 'Warning'.
    ms_data-generictag-design = 'StatusIconHidden'.
    CLEAR ms_data-progressindicator.
    ms_data-progressindicator-percentvalue = '70'.
    ms_data-progressindicator-state = 'Warning'.
    CLEAR ms_data-radialmicrochart.
    ms_data-radialmicrochart-percentage = '70'.
    ms_data-radialmicrochart-valuecolor = 'Critical'.
    ms_data-radialmicrochart-radialmicrochart_size = 'S'.
    CLEAR ms_data-statusindicator.
    ms_data-statusindicator-value = '70'.
    ms_data-statusindicator-fillcolor_error = '100'.
    ms_data-statusindicator-fillcolor_critical = '80'.
    ms_data-statusindicator-fillcolor_good = '40'.
    ms_data-statusindicator-shapeid = 'tool'.
    ms_data-statusindicator-statusindicator_size = 'Medium'.

  ENDMETHOD.

  METHOD init_layout.
    DATA class TYPE abap_abstypename.
    DATA temp2 LIKE REF TO ms_data.
    DATA temp3 LIKE LINE OF mo_layout->ms_layout-t_layout.
    DATA layout LIKE REF TO temp3.

    IF mo_layout IS BOUND.
      RETURN.
    ENDIF.


    class = cl_abap_classdescr=>get_class_name( me ).
    SHIFT class LEFT DELETING LEADING '\CLASS='.


    GET REFERENCE OF ms_data INTO temp2.
mo_layout = z2ui5_cl_layo_manager=>factory( control  = z2ui5_cl_layo_manager=>ui_simpleform
                                                data     = temp2
                                                handle01 = class
                                                handle02 = 'USR01'
                                                handle03 = ''
                                                handle04 = '' ).



    LOOP AT mo_layout->ms_layout-t_layout REFERENCE INTO layout.

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
        DATA temp4 TYPE REF TO z2ui5_cl_layo_pop.
        DATA app LIKE temp4.

    CHECK client->check_on_navigated( ) IS NOT INITIAL.

    TRY.


        temp4 ?= client->get_app( client->get( )-s_draft-id_prev_app ).

        app = temp4.
        mo_layout = app->mo_layout.

        IF app->mv_rerender = abap_true.
          " subcolumns need rerendering to work ..
          render_main( ).
        ELSE.
          "  for all other changes in Layout View Model Update is enough.
          client->view_model_update( ).
        ENDIF.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
