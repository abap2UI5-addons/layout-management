"! The popup to select rows with a layout: z2ui5_cl_layo_pop_w_sel in multi
"! select. The settings button of its table chooses, orders and sizes the
"! columns and saves the layout - offered again the next time; the
"! selection survives a search. The selected rows come back in result( ).
CLASS z2ui5_cl_layo_sample_07 DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_row,
        product  TYPE string,
        category TYPE string,
        location TYPE string,
        quantity TYPE i,
        unit     TYPE string,
        created  TYPE string,
      END OF ty_s_row.
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.

    DATA mt_selected TYPE ty_t_row.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.
    DATA mt_tab TYPE ty_t_row.

    METHODS view_display.
    METHODS on_event.
    METHODS on_navigated.
    METHODS set_data.

  PRIVATE SECTION.

ENDCLASS.


CLASS z2ui5_cl_layo_sample_07 IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    me->client = client.

    IF client->check_on_init( ).
      set_data( ).
      view_display( ).
    ELSEIF client->check_on_navigated( ).
      on_navigated( ).
    ELSEIF client->check_on_event( ).
      on_event( ).
    ENDIF.

  ENDMETHOD.

  METHOD set_data.

    DATA(lt_product) = VALUE string_table( ( `Table` ) ( `Chair` ) ( `Sofa` ) ( `Lamp` ) ( `Shelf` ) ).
    DATA(lt_location) = VALUE string_table( ( `AREA_001` ) ( `AREA_002` ) ( `AREA_003` ) ( `AREA_004` ) ).

    DO 20 TIMES.
      DATA(lv_index) = sy-index.
      DATA(lv_product) = lt_product[ ( lv_index - 1 ) MOD lines( lt_product ) + 1 ].
      INSERT VALUE #( product  = |{ lv_product } { lv_index }|
                      category = COND #( WHEN lv_index MOD 2 = 0 THEN `Furniture` ELSE `Decoration` )
                      location = lt_location[ ( lv_index - 1 ) MOD lines( lt_location ) + 1 ]
                      quantity = lv_index * 10
                      unit     = `PC`
                      created  = |2024-01-{ lv_index WIDTH = 2 ALIGN = RIGHT PAD = `0` }| ) INTO TABLE mt_tab.
    ENDDO.

  ENDMETHOD.

  METHOD on_event.

    IF client->get( )-event = `POPUP`.
      " no handles: the layouts are saved per popup class and line type
      client->nav_app_call( z2ui5_cl_layo_pop_w_sel=>factory( i_tab         = mt_tab
                                                              i_title       = `Select Products`
                                                              i_multiselect = abap_true ) ).
    ENDIF.

  ENDMETHOD.

  METHOD on_navigated.

    FIELD-SYMBOLS <table> TYPE ty_t_row.

    TRY.
        DATA(ls_result) = CAST z2ui5_cl_layo_pop_w_sel( client->get_app_prev( ) )->result( ).

        IF ls_result-check_confirmed = abap_false.
          client->message_toast_display( `Popup was cancelled` ).
        ELSE.
          ASSIGN ls_result-table->* TO <table>.
          mt_selected = <table>.
          client->message_toast_display( |{ lines( mt_selected ) } rows selected| ).
        ENDIF.

      CATCH cx_root ##NO_HANDLER.
        " not back from the popup (e.g. a restored draft) - show the view again
    ENDTRY.

    view_display( ).

  ENDMETHOD.

  METHOD view_display.

    DATA(view) = z2ui5_cl_ui5_view_builder=>factory(
                     )->ele( n = `View` ns = `mvc`
                     )->a( n = `xmlns` v = `sap.m`
                     )->a( n = `xmlns:mvc` v = `sap.ui.core.mvc`
                     )->a( n = `displayBlock` v = `true`
                     )->a( n = `height` v = `100%` ).

    DATA(page) = view->ele( `Shell`
                     )->ele( `Page`
                     )->a( n = `title` v = `Layout - Popup to Select with Layout`
                     )->a( n = `navButtonPress` v = client->_event_nav_app_leave( )
                     )->a( n = `showNavButton` b = client->check_app_prev_stack( ) ).

    page->ele( `VBox`
        )->a( n = `class` v = `sapUiSmallMargin`
        )->tag( `Text`
        )->a( n = `text` v = `Select rows in the popup. The settings button of its table chooses, orders and sizes the columns and saves the layout.`
        )->tag( `Button`
        )->a( n = `text` v = `Open Popup...`
        )->a( n = `press` v = client->_event( `POPUP` )
        )->a( n = `type` v = `Emphasized` ).

    DATA(table) = page->ele( `Table`
                      )->a( n = `headerText` v = `Selected rows`
                      )->a( n = `items` v = client->_bind( mt_selected ) ).

    DATA(columns) = table->ele( `columns` ).
    columns->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = `Product` ).
    columns->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = `Category` ).
    columns->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = `Location` ).
    columns->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = `Quantity` ).
    columns->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = `Created` ).

    DATA(cells) = table->ele( `items`
                      )->ele( `ColumnListItem`
                      )->ele( `cells` ).
    cells->tag( `Text`
        )->a( n = `text` v = `{PRODUCT}` ).
    cells->tag( `Text`
        )->a( n = `text` v = `{CATEGORY}` ).
    cells->tag( `Text`
        )->a( n = `text` v = `{LOCATION}` ).
    cells->tag( `Text`
        )->a( n = `text` v = `{QUANTITY} {UNIT}` ).
    cells->tag( `Text`
        )->a( n = `text` v = `{CREATED}` ).

    client->view_display( view->stringify( ) ).

  ENDMETHOD.

ENDCLASS.
