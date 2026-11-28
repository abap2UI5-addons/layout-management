CLASS z2ui5_cl_layo_sample_09 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_tab,
        selkz            TYPE abap_bool,
        product          TYPE string,
        create_date      TYPE string,
        create_by        TYPE string,
        storage_location TYPE string,
        quantity         TYPE i,
      END OF ty_s_tab.
    TYPES ty_t_table TYPE STANDARD TABLE OF ty_s_tab WITH EMPTY KEY.

    DATA mt_table TYPE ty_t_table.

  PROTECTED SECTION.
    DATA client     TYPE REF TO z2ui5_if_client.
    DATA mo_variant TYPE REF TO z2ui5_cl_layo_pop_filter.

    METHODS on_event.
    METHODS view_display.
    METHODS set_data.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_layo_sample_09 IMPLEMENTATION.


  METHOD on_event.

    CASE client->get( )-event.
      WHEN `BUTTON_START`.
        set_data( ).
      WHEN `PREVIEW_FILTER`.
        client->nav_app_call( mo_variant ).
      WHEN `BACK`.
        client->nav_app_leave( ).
    ENDCASE.

  ENDMETHOD.


  METHOD set_data.

    mt_table = VALUE #(
        ( product = `table`    create_date = `01.01.2023` create_by = `Peter` storage_location = `AREA_001` quantity = 400 )
        ( product = `chair`    create_date = `01.01.2023` create_by = `Peter` storage_location = `AREA_001` quantity = 400 )
        ( product = `sofa`     create_date = `01.01.2023` create_by = `Peter` storage_location = `AREA_001` quantity = 400 )
        ( product = `computer` create_date = `01.01.2023` create_by = `Peter` storage_location = `AREA_001` quantity = 400 )
        ( product = `oven`     create_date = `01.01.2023` create_by = `Peter` storage_location = `AREA_001` quantity = 400 )
        ( product = `table2`   create_date = `01.01.2023` create_by = `Peter` storage_location = `AREA_001` quantity = 400 ) ).

    z2ui5_cl_layo_context=>filter_itab(
      EXPORTING
       filter = mo_variant->mo_multiselect->ms_result-t_filter
      CHANGING
        val   = mt_table ).

  ENDMETHOD.


  METHOD view_display.

    DATA(view) = z2ui5_cl_ui5_view_builder=>factory(
                     )->ele( n = `View` ns = `mvc`
                     )->a( n = `xmlns` v = `sap.m`
                     )->a( n = `xmlns:mvc` v = `sap.ui.core.mvc`
                     )->a( n = `displayBlock` v = `true`
                     )->a( n = `height` v = `100%` ).

    view = view->ele( `Shell`
               )->ele( `Page`
               )->a( n = `id` v = `page_main`
               )->a( n = `title` v = `abap2UI5 - Select-Options`
               )->a( n = `navButtonPress` v = client->_event( `BACK` )
               )->a( n = `showNavButton` b = client->check_app_prev_stack( ) ).

    DATA(vbox) = view->ele( `VBox` ).

    DATA(tab) = vbox->ele( `Table`
                    )->a( n = `items` v = client->_bind( val = mt_table )
                    )->ele( `headerToolbar`
                    )->ele( `OverflowToolbar`
                    )->tag( `ToolbarSpacer`
                    )->tag( `Button`
                    )->a( n = `text` v = `Filter`
                    )->a( n = `press` v = client->_event( `PREVIEW_FILTER` )
                    )->a( n = `icon` v = `sap-icon://filter`
                    )->tag( `Button`
                    )->a( n = `text` v = `Go`
                    )->a( n = `press` v = client->_event( `BUTTON_START` )
                    )->a( n = `type` v = `Emphasized`
                    )->end(
                    )->end( ).

    DATA(lo_columns) = tab->ele( `columns` ).
    lo_columns->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = `Product` ).
    lo_columns->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = `Date` ).
    lo_columns->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = `Name` ).
    lo_columns->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = `Location` ).
    lo_columns->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = `Quantity` ).

    DATA(lo_cells) = tab->ele( `items`
                         )->ele( `ColumnListItem` ).
    lo_cells->tag( `Text`
        )->a( n = `text` v = `{PRODUCT}` ).
    lo_cells->tag( `Text`
        )->a( n = `text` v = `{CREATE_DATE}` ).
    lo_cells->tag( `Text`
        )->a( n = `text` v = `{CREATE_BY}` ).
    lo_cells->tag( `Text`
        )->a( n = `text` v = `{STORAGE_LOCATION}` ).
    lo_cells->tag( `Text`
        )->a( n = `text` v = `{QUANTITY}` ).

    client->view_display( view->stringify( ) ).

  ENDMETHOD.


  METHOD z2ui5_if_app~main.

    me->client = client.

    IF client->check_on_init( ).

      mo_variant = z2ui5_cl_layo_pop_filter=>factory_by_data( data        = mt_table
                                                               var_handle1 = `TEST_POP` ).
      set_data( ).
      view_display( ).

    ELSEIF client->check_on_nav_back( ).
      " back from the select-options popup, the one app this sample calls
      DATA(lo_value_help) = CAST z2ui5_cl_layo_pop_filter( client->get_app_prev( ) ).
      IF lo_value_help->result( )-check_confirmed = abap_true.
        mo_variant->mo_multiselect->ms_result-t_filter = lo_value_help->result( )-t_filter.
        set_data( ).
      ENDIF.
      view_display( ).

    ELSEIF client->check_on_navigated( ).
      " a restored draft or a return from another app - the view is shown again
      view_display( ).

    ELSEIF client->get( )-event IS NOT INITIAL.
      on_event( ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
