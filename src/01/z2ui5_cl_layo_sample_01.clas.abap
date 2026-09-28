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
    TYPES ty_t_table TYPE STANDARD TABLE OF ty_s_tab WITH DEFAULT KEY.

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

    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA page TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA temp2 TYPE xsdboolean.
    DATA temp1 LIKE REF TO mt_table.
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


    GET REFERENCE OF mt_table INTO temp1.
z2ui5_cl_layo_xml_builder=>xml_build_table( i_data   = temp1
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

    mo_layout->sort( ).

    IF client->get( )-check_on_navigated = abap_true.
      on_after_navigation( ).
    ENDIF.

  ENDMETHOD.

  METHOD get_data.

    DATA temp2 TYPE z2ui5_cl_layo_sample_01=>ty_t_table.
    DATA temp3 LIKE LINE OF temp2.
    CLEAR temp2.

    temp3-names = 'Viktor'.
    CLEAR temp3-icon.
    temp3-icon-src = 'sap-icon://customer'.
    temp3-icon-icon_size = '2rem'.
    CLEAR temp3-generictag.
    temp3-generictag-text = 'Viktor'.
    temp3-generictag-status = 'Warning'.
    temp3-generictag-design = 'StatusIconHidden'.
    CLEAR temp3-progressindicator.
    temp3-progressindicator-percentvalue = '70'.
    temp3-progressindicator-state = 'Warning'.
    CLEAR temp3-radialmicrochart.
    temp3-radialmicrochart-percentage = '70'.
    temp3-radialmicrochart-valuecolor = 'Critical'.
    temp3-radialmicrochart-radialmicrochart_size = 'S'.
    CLEAR temp3-statusindicator.
    temp3-statusindicator-value = '70'.
    temp3-statusindicator-fillcolor_error = '100'.
    temp3-statusindicator-fillcolor_critical = '80'.
    temp3-statusindicator-fillcolor_good = '40'.
    temp3-statusindicator-shapeid = 'tool'.
    temp3-statusindicator-statusindicator_size = 'Medium'.
    INSERT temp3 INTO TABLE temp2.
    temp3-names = 'Lars'.
    CLEAR temp3-icon.
    temp3-icon-src = 'sap-icon://end-user-experience-monitoring'.
    temp3-icon-icon_size = '2rem'.
    CLEAR temp3-generictag.
    temp3-generictag-text = 'Lars'.
    temp3-generictag-status = 'Success'.
    temp3-generictag-design = 'StatusIconHidden'.
    CLEAR temp3-progressindicator.
    temp3-progressindicator-percentvalue = '20'.
    temp3-progressindicator-state = 'Success'.
    CLEAR temp3-radialmicrochart.
    temp3-radialmicrochart-percentage = '20'.
    temp3-radialmicrochart-valuecolor = 'Good'.
    temp3-radialmicrochart-radialmicrochart_size = 'S'.
    CLEAR temp3-statusindicator.
    temp3-statusindicator-value = '20'.
    temp3-statusindicator-fillcolor_error = '100'.
    temp3-statusindicator-fillcolor_critical = '80'.
    temp3-statusindicator-fillcolor_good = '40'.
    temp3-statusindicator-shapeid = 'tool'.
    temp3-statusindicator-statusindicator_size = 'Medium'.
    INSERT temp3 INTO TABLE temp2.
    mt_table = temp2.

  ENDMETHOD.

  METHOD init_layout.
    DATA class TYPE abap_abstypename.
    DATA temp4 LIKE REF TO mt_table.

    IF mo_layout IS BOUND.
      RETURN.
    ENDIF.


    class = cl_abap_classdescr=>get_class_name( me ).
    SHIFT class LEFT DELETING LEADING '\CLASS='.


    GET REFERENCE OF mt_table INTO temp4.
mo_layout = z2ui5_cl_layo_manager=>factory( control  = z2ui5_cl_layo_manager=>m_table
                                                data     = temp4
                                                handle01 = class
                                                handle02 = 'Z2UI5_T_01'
                                                handle03 = ''
                                                handle04 = '' ).

  ENDMETHOD.

  METHOD on_after_navigation.
        DATA temp5 TYPE REF TO z2ui5_cl_layo_pop.
        DATA app LIKE temp5.

    CHECK client->check_on_navigated( ) IS NOT INITIAL.

    TRY.


        temp5 ?= client->get_app( client->get( )-s_draft-id_prev_app ).

        app = temp5.
        mo_layout = app->mo_layout.

        render_main( ).

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
