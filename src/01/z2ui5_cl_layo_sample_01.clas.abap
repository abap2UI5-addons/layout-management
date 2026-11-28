CLASS z2ui5_cl_layo_sample_01 DEFINITION
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
    TYPES ty_t_table TYPE STANDARD TABLE OF ty_s_tab WITH DEFAULT KEY.

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
        DATA temp1 LIKE REF TO mt_table.
        DATA temp2 LIKE REF TO mt_table.

    CASE client->get( )-event.

      WHEN 'ROW_SELECT'.


        GET REFERENCE OF mt_table INTO temp1.
mo_layout->set_selkz( t_event_arg = client->get( )-t_event_arg
                               data        = temp1 ).

      WHEN 'BACK'.
        client->nav_app_leave( ).

      WHEN OTHERS.

        " the settings button, and a click on a column header (i_col_sort)

        GET REFERENCE OF mt_table INTO temp2.
z2ui5_cl_layo_pop=>on_event_layout( client = client
                                            layout = mo_layout
                                            data   = temp2 ).

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
    DATA temp3 LIKE REF TO mt_table.
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
                     )->a( n = `displayBlock` b = abap_true
                     )->a( n = `height` v = `100%`
                     )->ele( `Shell` ).


    page = view->ele( `Page`
                     )->a( n = `title` v = `Layout`
                     )->a( n = `navButtonPress` v = client->_event( 'BACK' )
                     )->a( n = `showNavButton` b = client->check_app_prev_stack( )
                     )->a( n = `class` v = `sapUiContentPadding` ).


    GET REFERENCE OF mt_table INTO temp3.
z2ui5_cl_layo_xml_builder=>xml_build_table( i_data     = temp3
                                                i_xml      = page
                                                i_client   = client
                                                i_layout   = mo_layout
                                                i_col_sort = abap_true ).

    client->view_display( view->stringify( ) ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.
    DATA temp4 LIKE REF TO mt_table.
    me->client = client.

    IF client->check_on_init( ) IS NOT INITIAL.
      on_init( ).
    ELSEIF client->check_on_navigated( ) IS NOT INITIAL.
      on_after_navigation( ).
    ELSEIF client->check_on_event( ) IS NOT INITIAL.
      on_event( ).
    ENDIF.

    " the table again: the restored draft holds the layout's reference to a
    " copy of it (z2ui5_cl_layo_manager=>set_data)

    GET REFERENCE OF mt_table INTO temp4.
mo_layout->sort( data = temp4 ).

  ENDMETHOD.

  METHOD get_data.

    DATA temp5 TYPE z2ui5_cl_layo_sample_01=>ty_t_table.
    DATA temp6 LIKE LINE OF temp5.
    CLEAR temp5.

    temp6-names = 'Viktor'.
    CLEAR temp6-icon.
    temp6-icon-src = 'sap-icon://customer'.
    temp6-icon-icon_size = '2rem'.
    CLEAR temp6-generictag.
    temp6-generictag-text = 'Viktor'.
    temp6-generictag-status = 'Warning'.
    temp6-generictag-design = 'StatusIconHidden'.
    CLEAR temp6-progressindicator.
    temp6-progressindicator-percentvalue = '70'.
    temp6-progressindicator-state = 'Warning'.
    CLEAR temp6-radialmicrochart.
    temp6-radialmicrochart-percentage = '70'.
    temp6-radialmicrochart-valuecolor = 'Critical'.
    temp6-radialmicrochart-radialmicrochart_size = 'S'.
    CLEAR temp6-statusindicator.
    temp6-statusindicator-value = '70'.
    temp6-statusindicator-fillcolor_error = '100'.
    temp6-statusindicator-fillcolor_critical = '80'.
    temp6-statusindicator-fillcolor_good = '40'.
    temp6-statusindicator-shapeid = 'tool'.
    temp6-statusindicator-statusindicator_size = 'Medium'.
    INSERT temp6 INTO TABLE temp5.
    temp6-names = 'Lars'.
    CLEAR temp6-icon.
    temp6-icon-src = 'sap-icon://end-user-experience-monitoring'.
    temp6-icon-icon_size = '2rem'.
    CLEAR temp6-generictag.
    temp6-generictag-text = 'Lars'.
    temp6-generictag-status = 'Success'.
    temp6-generictag-design = 'StatusIconHidden'.
    CLEAR temp6-progressindicator.
    temp6-progressindicator-percentvalue = '20'.
    temp6-progressindicator-state = 'Success'.
    CLEAR temp6-radialmicrochart.
    temp6-radialmicrochart-percentage = '20'.
    temp6-radialmicrochart-valuecolor = 'Good'.
    temp6-radialmicrochart-radialmicrochart_size = 'S'.
    CLEAR temp6-statusindicator.
    temp6-statusindicator-value = '20'.
    temp6-statusindicator-fillcolor_error = '100'.
    temp6-statusindicator-fillcolor_critical = '80'.
    temp6-statusindicator-fillcolor_good = '40'.
    temp6-statusindicator-shapeid = 'tool'.
    temp6-statusindicator-statusindicator_size = 'Medium'.
    INSERT temp6 INTO TABLE temp5.
    mt_table = temp5.

  ENDMETHOD.

  METHOD init_layout.
    DATA class TYPE abap_abstypename.
    DATA table TYPE string.
    DATA temp7 LIKE REF TO mt_table.

    IF mo_layout IS BOUND.
      RETURN.
    ENDIF.


    class = cl_abap_classdescr=>get_class_name( me ).
    class = shift_left( val = class sub = `\CLASS=` ).

    " the draft table's name behind this class's own prefix (Z2UI5_, or the
    " one a namespace rename gave it) - the rename rewrites the class name,
    " never a literal

    table = substring_before( val = class
                                    sub = `CL_LAYO_` ) && `T_01`.


    GET REFERENCE OF mt_table INTO temp7.
mo_layout = z2ui5_cl_layo_manager=>factory( control  = z2ui5_cl_layo_manager=>m_table
                                                data     = temp7
                                                handle01 = class
                                                handle02 = table
                                                handle03 = ''
                                                handle04 = '' ).

  ENDMETHOD.

  METHOD on_after_navigation.

    " back from the layout popup: take over the layout chosen there; on
    " any other navigation (e.g. a restored draft) take_over( ) does
    " nothing - the view is displayed either way
    z2ui5_cl_layo_pop=>take_over( client = client layout = mo_layout ).
    render_main( ).

  ENDMETHOD.

ENDCLASS.
