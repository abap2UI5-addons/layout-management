CLASS z2ui5_cl_layo_sample_03 DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_tab.
        INCLUDE TYPE  z2ui5_t_11.
    TYPES:
        selkz TYPE abap_bool,
      END OF ty_s_tab.
    TYPES ty_t_table TYPE STANDARD TABLE OF ty_s_tab WITH EMPTY KEY.

    DATA mt_table  TYPE ty_t_table.
    DATA mo_layout TYPE REF TO z2ui5_cl_layo_manager.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.

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

    DATA(view) = z2ui5_cl_ui5_view_builder=>factory(
        )->ele( n = `View` ns = `mvc`
            )->a( n = `displayBlock` v = `true`
            )->a( n = `height`       v = `100%`
            )->a( n = `xmlns`        v = `sap.m`
            )->a( n = `xmlns:mvc`    v = `sap.ui.core.mvc`
            )->a( n = `xmlns:core`   v = `sap.ui.core`
            )->a( n = `xmlns:mchart` v = `sap.suite.ui.microchart`
            )->a( n = `xmlns:si`     v = `sap.suite.ui.commons.statusindicator` ).

    DATA(page) = view->ele( `Shell`
        )->ele( `Page`
            )->a( n = `title`          v = `Layout`
            )->a( n = `showNavButton`  b = client->check_app_prev_stack( )
            )->a( n = `navButtonPress` v = client->_event( 'BACK' )
            )->a( n = `class`          v = `sapUiContentPadding` ).

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
    ELSEIF client->check_on_navigated( ).
      on_after_navigation( ).
    ELSEIF client->check_on_event( ).
      on_event( ).
    ENDIF.

  ENDMETHOD.

  METHOD get_data.

    SELECT * FROM z2ui5_t_11 INTO TABLE @mt_table UP TO 10 ROWS.

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

    TRY.

        DATA(app) = CAST z2ui5_cl_layo_pop( client->get_app_prev( ) ).
        mo_layout = app->mo_layout.

        IF app->mv_rerender = abap_true.
          " e.g. subcolumns need rerendering to work ..
          render_main( ).
        ELSE.
          "  for all other changes in Layout View Model Update is enough.
        ENDIF.
      CATCH cx_root.
        " not back from the layout popup (e.g. a restored draft) - the
        " view still has to be displayed
        render_main( ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
