"! The generic mode: a layout for a view that is neither a table nor a form.
"! The page carries a Panel with inputs, a Toolbar with buttons and a List;
"! the app registers the controls the user may personalize, builds its view
"! as usual and hands the XML through xml_apply_layout( ) - the settings
"! button opens the same popup as for a table, the variants are saved to the
"! same tables.
CLASS z2ui5_cl_layo_sample_06 DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_note,
        title TYPE string,
        descr TYPE string,
      END OF ty_s_note.
    TYPES ty_t_note TYPE STANDARD TABLE OF ty_s_note WITH DEFAULT KEY.

    DATA mv_name    TYPE string.
    DATA mv_city    TYPE string.
    DATA mv_country TYPE string.
    DATA mv_email   TYPE string.
    DATA mt_note    TYPE ty_t_note.
    DATA mo_layout  TYPE REF TO z2ui5_cl_layo_manager.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.

    METHODS model_init.
    METHODS layout_init.
    METHODS view_display.
    METHODS on_event.
    METHODS on_navigated.

  PRIVATE SECTION.

ENDCLASS.


CLASS z2ui5_cl_layo_sample_06 IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    me->client = client.

    IF client->check_on_init( ) IS NOT INITIAL.
      model_init( ).
      layout_init( ).
      view_display( ).
    ELSEIF client->check_on_navigated( ) IS NOT INITIAL.
      on_navigated( ).
    ELSEIF client->check_on_event( ) IS NOT INITIAL.
      on_event( ).
    ENDIF.

  ENDMETHOD.

  METHOD model_init.
    DATA temp1 TYPE z2ui5_cl_layo_sample_06=>ty_t_note.
    DATA temp2 LIKE LINE OF temp1.

    mv_name    = `Erika Mustermann`.
    mv_city    = `Walldorf`.
    mv_country = `Germany`.
    mv_email   = `erika@example.com`.


    CLEAR temp1.

    temp2-title = `First contact`.
    temp2-descr = `Asked for a quotation`.
    INSERT temp2 INTO TABLE temp1.
    temp2-title = `Follow-up`.
    temp2-descr = `Quotation sent, waiting for the answer`.
    INSERT temp2 INTO TABLE temp1.
    temp2-title = `Decision`.
    temp2-descr = `Order placed`.
    INSERT temp2 INTO TABLE temp1.
    mt_note = temp1.

  ENDMETHOD.

  METHOD layout_init.
    DATA class TYPE abap_abstypename.

    IF mo_layout IS BOUND.
      RETURN.
    ENDIF.


    class = cl_abap_classdescr=>get_class_name( me ).
    SHIFT class LEFT DELETING LEADING '\CLASS='.

    " the handles are the key the variants are saved under - the app class
    " and a name for the view
    mo_layout = z2ui5_cl_layo_manager=>factory_generic( handle01 = class
                                                        handle02 = 'MAIN_VIEW' ).

    " the controls the user may hide, move and rename - by their id in the
    " view. The label is what the popup shows; the Label in front of an
    " Input is found through its labelFor and travels with it
    mo_layout->register( id    = `inpName`
                         label = `Name` ).
    mo_layout->register( id    = `inpCity`
                         label = `City` ).
    mo_layout->register( id    = `inpCountry`
                         label = `Country` ).
    mo_layout->register( id    = `inpEmail`
                         label = `E-Mail` ).
    mo_layout->register( id    = `btnSave`
                         label = `Save` ).
    mo_layout->register( id    = `btnCheck`
                         label = `Check` ).
    mo_layout->register( id    = `btnReset`
                         label = `Reset` ).
    mo_layout->register( id         = `lstNotes`
                         label      = `Notes`
                         label_attr = `headerText` ).

  ENDMETHOD.

  METHOD view_display.

    DATA page TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA temp1 TYPE xsdboolean.
    DATA header TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA panel TYPE REF TO z2ui5_cl_ui5_view_builder.
    temp1 = boolc( client->get( )-s_draft-id_prev_app_stack IS NOT INITIAL ).
    page = z2ui5_cl_ui5_view_builder=>factory(
        )->ele( n = `View` ns = `mvc`
            )->a( n = `xmlns`     v = `sap.m`
            )->a( n = `xmlns:mvc` v = `sap.ui.core.mvc`

            )->ele( `Shell`
                )->ele( `Page`
                    )->a( n = `title`          v = `Layout - any view`
                    )->a( n = `navButtonPress` v = client->_event( `BACK` )
                    )->a( n = `showNavButton`  b = temp1
                    )->a( n = `class`          v = `sapUiContentPadding` ).

    " the settings button of the layout - the same popup as for a table

    header = page->ele( `headerContent` ).
    z2ui5_cl_layo_pop=>render_layout_function( xml    = header
                                               client = client
                                               layout = mo_layout ).


    panel = page->ele( `Panel`
        )->a( n = `id`         v = `pnlCustomer`
        )->a( n = `headerText` v = `Customer`
        )->ele( `VBox` ).

    panel->tag( `Label`
        )->a( n = `text`     v = `Name`
        )->a( n = `labelFor` v = `inpName`
        )->tag( `Input`
        )->a( n = `id`    v = `inpName`
        )->a( n = `value` v = client->_bind( mv_name )
        )->tag( `Label`
        )->a( n = `text`     v = `City`
        )->a( n = `labelFor` v = `inpCity`
        )->tag( `Input`
        )->a( n = `id`    v = `inpCity`
        )->a( n = `value` v = client->_bind( mv_city )
        )->tag( `Label`
        )->a( n = `text`     v = `Country`
        )->a( n = `labelFor` v = `inpCountry`
        )->tag( `Input`
        )->a( n = `id`    v = `inpCountry`
        )->a( n = `value` v = client->_bind( mv_country )
        )->tag( `Label`
        )->a( n = `text`     v = `E-Mail`
        )->a( n = `labelFor` v = `inpEmail`
        )->tag( `Input`
        )->a( n = `id`    v = `inpEmail`
        )->a( n = `value` v = client->_bind( mv_email ) ).

    page->ele( `Toolbar`
        )->a( n = `id` v = `tbActions`
        )->tag( `Button`
        )->a( n = `id`    v = `btnSave`
        )->a( n = `text`  v = `Save`
        )->a( n = `type`  v = `Emphasized`
        )->a( n = `press` v = client->_event( `SAVE` )
        )->tag( `Button`
        )->a( n = `id`    v = `btnCheck`
        )->a( n = `text`  v = `Check`
        )->a( n = `press` v = client->_event( `CHECK` )
        )->tag( `ToolbarSpacer`
        )->tag( `Button`
        )->a( n = `id`    v = `btnReset`
        )->a( n = `text`  v = `Reset`
        )->a( n = `press` v = client->_event( `RESET` ) ).

    page->ele( `List`
        )->a( n = `id`         v = `lstNotes`
        )->a( n = `headerText` v = `Notes`
        )->a( n = `items`      v = client->_bind( mt_note )
        )->ele( `items`
            )->tag( `StandardListItem`
            )->a( n = `title`       v = `{TITLE}`
            )->a( n = `description` v = `{DESCR}` ).

    " the layout is applied to the finished XML: hidden controls, order,
    " labels and widths of the registered ids
    client->view_display( z2ui5_cl_layo_xml_builder=>xml_apply_layout( i_xml    = page->stringify( )
                                                                         i_layout = mo_layout ) ).

  ENDMETHOD.

  METHOD on_event.

    CASE client->get( )-event.

      WHEN `BACK`.
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN `SAVE`.
        client->message_toast_display( |Saved { mv_name }| ).

      WHEN `CHECK`.
        client->message_toast_display( |{ mv_name } lives in { mv_city }, { mv_country }| ).

      WHEN `RESET`.
        model_init( ).

      WHEN OTHERS.
        " the settings button fires the guid of the layout
        z2ui5_cl_layo_pop=>on_event_layout( client = client
                                            layout = mo_layout ).

    ENDCASE.

  ENDMETHOD.

  METHOD on_navigated.
        DATA temp3 TYPE REF TO z2ui5_cl_layo_pop.
        DATA app LIKE temp3.

    " back from the layout popup: take over the chosen layout and render
    " again - the generic mode writes it into the view
    TRY.

        temp3 ?= client->get_app( client->get( )-s_draft-id_prev_app ).

        app = temp3.
        mo_layout = app->mo_layout.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    view_display( ).

  ENDMETHOD.

ENDCLASS.
