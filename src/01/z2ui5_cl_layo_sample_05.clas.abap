CLASS z2ui5_cl_layo_sample_05 DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES BEGIN OF ty_s_data.
    INCLUDE TYPE z2ui5_t_11.
    TYPES selkz TYPE abap_bool.
    TYPES END OF ty_s_data.
    TYPES ty_t_data TYPE STANDARD TABLE OF ty_s_data WITH EMPTY KEY.

    DATA mt_table        TYPE ty_t_data.
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
        client->nav_app_leave( ).

      WHEN mo_layout->ms_layout-s_head-guid.
        z2ui5_cl_layo_pop=>on_event_layout( client = client
                                            layout = mo_layout ).

      WHEN mo_table_layout->ms_layout-s_head-guid.
        z2ui5_cl_layo_pop=>on_event_layout( client = client
                                            layout = mo_table_layout ).

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
    ELSEIF client->check_on_navigated( ).
      on_after_navigation( ).
    ELSEIF client->check_on_event( ).
      on_event( ).
    ENDIF.

  ENDMETHOD.

  METHOD get_data.

    SELECT * FROM z2ui5_t_11 ORDER BY PRIMARY KEY INTO TABLE @mt_table UP TO 5 ROWS ##SUBRC_OK.

    ms_struc = VALUE #( mt_table[ 1 ] OPTIONAL ).

  ENDMETHOD.

  METHOD init_layout.

    IF mo_layout IS BOUND.
      RETURN.
    ENDIF.

    DATA(class) = cl_abap_classdescr=>get_class_name( me ).
    class = shift_left( val = class sub = `\CLASS=` ).

    " the draft table's name behind this class's own prefix (Z2UI5_, or the
    " one a namespace rename gave it) - the rename rewrites the class name,
    " never a literal
    DATA(table) = substring_before( val = class
                                    sub = `CL_LAYO_` ) && `T_01`.

    mo_table_layout = z2ui5_cl_layo_manager=>factory( control  = z2ui5_cl_layo_manager=>m_table
                                                      data     = REF #( mt_table )
                                                      handle01 = class
                                                      handle02 = table
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

    " back from the layout popup: each layout takes over the one chosen
    " there when it is its own - the form's or the table's. Render again
    " only when the popup changed what the view is built from (e.g.
    " subcolumns) - for all other changes the changed model is enough, the
    " framework sends it by itself. Not back from the layout popup (e.g. a
    " restored draft): the view still has to be displayed
    DATA(lv_rerender) = z2ui5_cl_layo_pop=>take_over( client = client layout = mo_layout ).
    IF z2ui5_cl_layo_pop=>take_over( client = client layout = mo_table_layout ) = abap_true.
      lv_rerender = abap_true.
    ENDIF.

    IF lv_rerender = abap_true OR client->check_on_nav_back( ) = abap_false.
      render_main( ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
