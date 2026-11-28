CLASS z2ui5_cl_layo_pop_range DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_filter_pop,
        " I include, E exclude - as the sign of a range row
        sign   TYPE string,
        option TYPE string,
        low    TYPE string,
        high   TYPE string,
        key    TYPE string,
      END OF ty_s_filter_pop.

    DATA mt_filter TYPE STANDARD TABLE OF ty_s_filter_pop WITH EMPTY KEY.

    CLASS-METHODS factory
      IMPORTING
        t_range         TYPE ANY TABLE OPTIONAL
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_layo_pop_range.

    TYPES:
      BEGIN OF ty_s_result,
        t_range         TYPE z2ui5_cl_layo_context=>ty_t_range,
        check_confirmed TYPE abap_bool,
      END OF ty_s_result.

    " abap2ui5lint-disable-next-line unbound-public-attribute -- a popup's attributes are its interface to the app that called it, which reads them once the popup returns
    DATA ms_result TYPE ty_s_result.

    METHODS result
      RETURNING
        VALUE(result) TYPE ty_s_result.

    DATA mt_mapping TYPE z2ui5_cl_layo_context=>ty_t_name_value.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.

    METHODS view_display.

  PRIVATE SECTION.
    " entries of filter_get_token_range_mapping( ) that are no option of a
    " range: the empty value, EQ or NE an empty LOW
    CONSTANTS cv_option_empty     TYPE string VALUE `<leer>`.
    CONSTANTS cv_option_not_empty TYPE string VALUE `!<leer>`.

    METHODS filter_of_range
      IMPORTING
        range         TYPE z2ui5_cl_layo_context=>ty_s_range
      RETURNING
        VALUE(result) TYPE ty_s_filter_pop.

    "! the range row of a condition of the popup - initial for a condition
    "! without a value
    METHODS range_of_filter
      IMPORTING
        filter        TYPE ty_s_filter_pop
      RETURNING
        VALUE(result) TYPE z2ui5_cl_layo_context=>ty_s_range.

ENDCLASS.


CLASS z2ui5_cl_layo_pop_range IMPLEMENTATION.

  METHOD factory.

    r_result = NEW #( ).

    z2ui5_cl_layo_context=>itab_corresponding( EXPORTING val = t_range
                                       CHANGING  tab             = r_result->ms_result-t_range ).

    INSERT VALUE #( ) INTO TABLE r_result->ms_result-t_range.

  ENDMETHOD.

  METHOD result.

    result = ms_result.

  ENDMETHOD.

  METHOD view_display.

    DATA(lo_popup) = z2ui5_cl_ui5_view_builder=>factory(
                         )->ele( n = `FragmentDefinition` ns = `core`
                         )->a( n = `xmlns` v = `sap.m`
                         )->a( n = `xmlns:core` v = `sap.ui.core`
                         )->a( n = `xmlns:layout` v = `sap.ui.layout` ).

    lo_popup = lo_popup->ele( `Dialog`
                   )->a( n = `afterClose` v = client->_event( `BUTTON_CANCEL` )
                   )->a( n = `contentHeight` v = `50%`
                   )->a( n = `contentWidth` v = `50%`
                   )->a( n = `title` v = `Define Filter Conditions` ).

    DATA(vbox) = lo_popup->ele( `VBox`
                     )->a( n = `height` v = `100%`
                     )->a( n = `justifyContent` v = `SpaceBetween` ).

    DATA(item) = vbox->ele( `List`
                     )->a( n = `noDataText` v = `No conditions defined`
                     )->a( n = `items` v = client->_bind( mt_filter )
                     )->ele( `CustomListItem` ).

    DATA(grid) = item->ele( n = `Grid` ns = `layout`
                     )->a( n = `defaultSpan` v = `L2 M4 S12` ).

    grid->ele( `Select`
        )->a( n = `selectedKey` v = `{SIGN}`
        )->tag( n = `Item` ns = `core`
        )->a( n = `key` v = `I`
        )->a( n = `text` v = `Include`
        )->tag( n = `Item` ns = `core`
        )->a( n = `key` v = `E`
        )->a( n = `text` v = `Exclude`
        )->end(
        )->ele( `ComboBox`
        )->a( n = `selectedKey` v = `{OPTION}`
        )->a( n = `items` v = client->_bind( mt_mapping )
        )->tag( n = `Item` ns = `core`
        )->a( n = `key` v = `{N}`
        )->a( n = `text` v = `{N}`
        )->end(
        )->tag( `Input`
        )->a( n = `value` v = `{LOW}`
        )->a( n = `submit` v = client->_event( `BUTTON_CONFIRM` )
        )->tag( `Input`
        )->a( n = `value` v = `{HIGH}`
        )->a( n = `visible` v = `{= ${OPTION} === 'BT' || ${OPTION} === 'NB' }`
        )->a( n = `submit` v = client->_event( `BUTTON_CONFIRM` )
        )->tag( `Button`
        )->a( n = `icon` v = `sap-icon://decline`
        )->a( n = `type` v = `Transparent`
        )->a( n = `tooltip` v = `Delete condition`
        )->a( n = `press` v = client->_event( val   = `POPUP_DELETE`
                                                arg   = `${KEY}` ) ).

    lo_popup->ele( `buttons`
        )->tag( `Button`
        )->a( n = `text` v = `Delete All`
        )->a( n = `icon` v = `sap-icon://delete`
        )->a( n = `type` v = `Transparent`
        )->a( n = `press` v = client->_event( `POPUP_DELETE_ALL` )
        )->tag( `Button`
        )->a( n = `text` v = `Add Item`
        )->a( n = `icon` v = `sap-icon://add`
        )->a( n = `press` v = client->_event( `POPUP_ADD` )
        )->tag( `Button`
        )->a( n = `text` v = `Cancel`
        )->a( n = `press` v = client->_event( `BUTTON_CANCEL` )
        )->tag( `Button`
        )->a( n = `text` v = `OK`
        )->a( n = `press` v = client->_event( `BUTTON_CONFIRM` )
        )->a( n = `type` v = `Emphasized` ).

    client->popup_display( lo_popup->stringify( ) ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.

    me->client = client.

    IF client->check_on_init( ).
      mt_mapping = z2ui5_cl_layo_context=>filter_get_token_range_mapping( ).

      CLEAR mt_filter.
      LOOP AT ms_result-t_range REFERENCE INTO DATA(lr_range).
        INSERT filter_of_range( lr_range->* ) INTO TABLE mt_filter.
      ENDLOOP.

      view_display( ).
      RETURN.
    ELSEIF client->check_on_navigated( ).
      " a restored draft (browser Forward, a reload): the popup went with
      " the page - show it again
      view_display( ).
      RETURN.
    ENDIF.

    CASE client->get( )-event.

      WHEN `BUTTON_CONFIRM`.

        CLEAR ms_result-t_range.
        LOOP AT mt_filter REFERENCE INTO DATA(lr_filter).
          DATA(ls_range) = range_of_filter( lr_filter->* ).
          IF ls_range IS NOT INITIAL.
            INSERT ls_range INTO TABLE ms_result-t_range.
          ENDIF.
        ENDLOOP.

        ms_result-check_confirmed = abap_true.
        client->popup_destroy( ).
        client->nav_app_leave( ).

      WHEN `BUTTON_CANCEL`.
        client->popup_destroy( ).
        client->nav_app_leave( ).

      WHEN `POPUP_ADD`.
        INSERT VALUE #( key = z2ui5_cl_layo_context=>uuid_get_c32( ) ) INTO TABLE mt_filter.

      WHEN `POPUP_DELETE`.
        DELETE mt_filter WHERE key = client->get_event_arg( ).

      WHEN `POPUP_DELETE_ALL`.
        CLEAR mt_filter.

    ENDCASE.

  ENDMETHOD.

  METHOD filter_of_range.

    result = VALUE #( sign   = COND #( WHEN range-sign = `E` THEN `E` ELSE `I` )
                      option = range-option
                      low    = range-low
                      high   = range-high
                      key    = z2ui5_cl_layo_context=>uuid_get_c32( ) ).

    IF range-low IS INITIAL AND range-high IS INITIAL.
      CASE range-option.
        WHEN `EQ`.
          result-option = cv_option_empty.
        WHEN `NE`.
          result-option = cv_option_not_empty.
      ENDCASE.
    ENDIF.

  ENDMETHOD.

  METHOD range_of_filter.

    CASE filter-option.

      WHEN cv_option_empty.
        result-option = `EQ`.

      WHEN cv_option_not_empty.
        result-option = `NE`.

      WHEN OTHERS.
        IF filter-low IS INITIAL AND filter-high IS INITIAL.
          RETURN.
        ENDIF.
        " a condition without an option compares like the token it shows
        result-option = COND #( WHEN filter-option IS INITIAL THEN `EQ` ELSE filter-option ).
        result-low    = filter-low.
        " HIGH only where the option has one - it stays in the row when the
        " user switches from BT to another option
        IF result-option = `BT` OR result-option = `NB`.
          result-high = filter-high.
        ENDIF.

    ENDCASE.

    " the sign as chosen - a confirmed popup turned every excluding row into
    " an including one
    result-sign = COND #( WHEN filter-sign = `E` THEN `E` ELSE `I` ).

  ENDMETHOD.

ENDCLASS.
