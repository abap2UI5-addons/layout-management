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
    TYPES ty_t_row TYPE STANDARD TABLE OF ty_s_row WITH DEFAULT KEY.

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

    IF client->check_on_init( ) IS NOT INITIAL.
      set_data( ).
      view_display( ).
    ELSEIF client->check_on_navigated( ) IS NOT INITIAL.
      on_navigated( ).
    ELSEIF client->check_on_event( ) IS NOT INITIAL.
      on_event( ).
    ENDIF.

  ENDMETHOD.

  METHOD set_data.

    DATA temp1 TYPE string_table.
    DATA lt_product LIKE temp1.
    DATA temp3 TYPE string_table.
    DATA lt_location LIKE temp3.
      DATA lv_index LIKE sy-index.
      DATA lv_product LIKE LINE OF lt_product.
      FIELD-SYMBOLS <temp1> LIKE LINE OF lt_product.
      DATA temp2 LIKE sy-tabix.
      DATA temp5 TYPE z2ui5_cl_layo_sample_07=>ty_s_row.
      DATA temp4 TYPE z2ui5_cl_layo_sample_07=>ty_s_row-category.
      FIELD-SYMBOLS <temp5> LIKE LINE OF lt_location.
      DATA temp6 LIKE sy-tabix.
    CLEAR temp1.
    INSERT `Table` INTO TABLE temp1.
    INSERT `Chair` INTO TABLE temp1.
    INSERT `Sofa` INTO TABLE temp1.
    INSERT `Lamp` INTO TABLE temp1.
    INSERT `Shelf` INTO TABLE temp1.

    lt_product = temp1.

    CLEAR temp3.
    INSERT `AREA_001` INTO TABLE temp3.
    INSERT `AREA_002` INTO TABLE temp3.
    INSERT `AREA_003` INTO TABLE temp3.
    INSERT `AREA_004` INTO TABLE temp3.

    lt_location = temp3.

    DO 20 TIMES.

      lv_index = sy-index.



      temp2 = sy-tabix.
      READ TABLE lt_product INDEX ( lv_index - 1 ) MOD lines( lt_product ) + 1 ASSIGNING <temp1>.
      sy-tabix = temp2.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      lv_product = <temp1>.

      CLEAR temp5.
      temp5-product = |{ lv_product } { lv_index }|.

      IF lv_index MOD 2 = 0.
        temp4 = `Furniture`.
      ELSE.
        temp4 = `Decoration`.
      ENDIF.
      temp5-category = temp4.


      temp6 = sy-tabix.
      READ TABLE lt_location INDEX ( lv_index - 1 ) MOD lines( lt_location ) + 1 ASSIGNING <temp5>.
      sy-tabix = temp6.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      temp5-location = <temp5>.
      temp5-quantity = lv_index * 10.
      temp5-unit = `PC`.
      temp5-created = |2024-01-{ lv_index WIDTH = 2 ALIGN = RIGHT PAD = `0` }|.
      INSERT temp5 INTO TABLE mt_tab.
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

    DATA lo_popup TYPE REF TO z2ui5_cl_layo_pop_w_sel.
    DATA ls_result TYPE z2ui5_cl_layo_pop_w_sel=>ty_s_result.

    " not back from the popup (e.g. a restored draft, where get_app_prev( )
    " is the app itself): nothing to read - only the cast is caught, so an
    " error in reading the result is not swallowed. The view is shown again
    " either way
    TRY.
        lo_popup ?= client->get_app_prev( ).
      CATCH cx_sy_move_cast_error.
        view_display( ).
        RETURN.
    ENDTRY.


    ls_result = lo_popup->result( ).
    IF ls_result-check_confirmed = abap_false.
      client->message_toast_display( `Popup was cancelled` ).
    ELSE.
      ASSIGN ls_result-table->* TO <table>.
      mt_selected = <table>.
      client->message_toast_display( |{ lines( mt_selected ) } rows selected| ).
    ENDIF.

    view_display( ).

  ENDMETHOD.

  METHOD view_display.

    DATA view TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA page TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA table TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA columns TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA cells TYPE REF TO z2ui5_cl_ui5_view_builder.
    view = z2ui5_cl_ui5_view_builder=>factory(
                     )->ele( n = `View` ns = `mvc`
                     )->a( n = `xmlns` v = `sap.m`
                     )->a( n = `xmlns:mvc` v = `sap.ui.core.mvc`
                     )->a( n = `displayBlock` b = abap_true
                     )->a( n = `height` v = `100%` ).


    page = view->ele( `Shell`
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


    table = page->ele( `Table`
                      )->a( n = `headerText` v = `Selected rows`
                      )->a( n = `items` v = client->_bind( mt_selected ) ).


    columns = table->ele( `columns` ).
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


    cells = table->ele( `items`
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
