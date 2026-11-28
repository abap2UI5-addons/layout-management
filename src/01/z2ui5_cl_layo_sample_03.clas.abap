CLASS z2ui5_cl_layo_sample_03 DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES BEGIN OF ty_s_tab.
    INCLUDE TYPE z2ui5_t_11.
    TYPES selkz TYPE abap_bool.
    TYPES END OF ty_s_tab.
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


CLASS z2ui5_cl_layo_sample_03 IMPLEMENTATION.

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

    init_layout( ).

    get_data( ).

    render_main( ).
  ENDMETHOD.

  METHOD render_main.

    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA page TYPE REF TO z2ui5_cl_ui5_view_builder.
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
                     )->a( n = `displayBlock` b = abap_true
                     )->a( n = `height` v = `100%`
                     )->ele( `Shell` ).


    page = view->ele( `Page`
                     )->a( n = `title` v = `Layout`
                     )->a( n = `navButtonPress` v = client->_event( 'BACK' )
                     )->a( n = `showNavButton` b = client->check_app_prev_stack( )
                     )->a( n = `class` v = `sapUiContentPadding` ).


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
    ELSEIF client->check_on_navigated( ) IS NOT INITIAL.
      on_after_navigation( ).
    ELSEIF client->check_on_event( ) IS NOT INITIAL.
      on_event( ).
    ENDIF.

  ENDMETHOD.

  METHOD get_data.

    SELECT * FROM z2ui5_t_11 UP TO 10 ROWS INTO TABLE mt_table ORDER BY PRIMARY KEY   ##SUBRC_OK.

  ENDMETHOD.

  METHOD init_layout.
    DATA class TYPE abap_abstypename.
    DATA table TYPE string.
    DATA temp2 LIKE REF TO mt_table.

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


    GET REFERENCE OF mt_table INTO temp2.
mo_layout = z2ui5_cl_layo_manager=>factory( control  = z2ui5_cl_layo_manager=>m_table
                                                data     = temp2
                                                handle01 = class
                                                handle02 = table
                                                handle03 = ''
                                                handle04 = '' ).

  ENDMETHOD.

  METHOD on_after_navigation.

    " back from the layout popup: take over the layout chosen there. Render
    " again only when the popup changed what the view is built from (e.g.
    " subcolumns) - for all other changes the changed model is enough, the
    " framework sends it by itself. Not back from the layout popup (e.g. a
    " restored draft): take_over( ) asks for the view to be displayed too
    IF z2ui5_cl_layo_pop=>take_over( client = client layout = mo_layout ) = abap_true.
      render_main( ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
