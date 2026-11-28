CLASS z2ui5_cl_sel_multisel DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_serializable_object.

    DATA mv_check_popup TYPE abap_bool.

    DATA ms_variant TYPE z2ui5_cl_sel_var_db=>ty_s_db.

    TYPES:
      BEGIN OF ty_s_result,
        tab_name        TYPE string,
        var_name        TYPE string,
        t_filter        TYPE z2ui5_cl_layo_context=>ty_t_filter_multi,
        check_confirmed TYPE abap_bool,
      END OF ty_s_result.

    DATA ms_result     TYPE ty_s_result.
    DATA mv_popup_name TYPE string.

    TYPES:
      BEGIN OF ty_s_component,
        name             TYPE string,
        visible          TYPE abap_bool,
        check_value_help TYPE abap_bool,
      END OF ty_s_component.

    DATA mt_component TYPE STANDARD TABLE OF ty_s_component WITH EMPTY KEY.

    CLASS-METHODS factory_by_filter
      IMPORTING
        val             TYPE z2ui5_cl_layo_context=>ty_t_filter_multi
        check_popup     TYPE abap_bool OPTIONAL
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_sel_multisel.

    CLASS-METHODS factory_by_name
      IMPORTING
        val             TYPE clike
        s_variant       TYPE z2ui5_cl_sel_var_db=>ty_s_db OPTIONAL
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_sel_multisel.

    CLASS-METHODS factory_by_data
      IMPORTING
        val             TYPE any
        s_variant       TYPE z2ui5_cl_sel_var_db=>ty_s_db OPTIONAL
        check_popup     TYPE abap_bool OPTIONAL
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_sel_multisel.

    METHODS result
      RETURNING
        VALUE(result) TYPE ty_s_result.

    METHODS set_output
      IMPORTING
        client TYPE REF TO z2ui5_if_client
        view   TYPE REF TO z2ui5_cl_ui5_view_builder.

    METHODS main
      IMPORTING
        client        TYPE REF TO z2ui5_if_client
      RETURNING
        VALUE(result) TYPE abap_bool.

    METHODS set_var_default.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF cs_nav,
        range    TYPE string VALUE `RANGE`,
        var_read TYPE string VALUE `VAR_READ`,
        var_save TYPE string VALUE `VAR_SAVE`,
      END OF cs_nav.

    "! the id of this instance in its nav tags - set on its first popup, kept
    "! in the draft with the instance
    DATA mv_nav_id TYPE string.

    "! the tag of a popup this instance calls: its own id and what for - so
    "! a return is claimed only by the instance that called the popup, and
    "! not by another selection of the host or the host's own popup call
    METHODS nav_tag
      IMPORTING
        kind          TYPE string
      RETURNING
        VALUE(result) TYPE string.

    "! the popup this instance called has returned: its result taken over
    METHODS on_nav_back
      IMPORTING
        client TYPE REF TO z2ui5_if_client
        kind   TYPE string.

ENDCLASS.


CLASS z2ui5_cl_sel_multisel IMPLEMENTATION.

  METHOD factory_by_filter.

    r_result = NEW #( ).
    r_result->mv_check_popup = check_popup.
    r_result->ms_result-t_filter = val.

    LOOP AT r_result->ms_result-t_filter REFERENCE INTO DATA(lr_filter).
      INSERT VALUE #( name    = lr_filter->name
                      visible = abap_true
      ) INTO TABLE r_result->mt_component.
    ENDLOOP.

  ENDMETHOD.

  METHOD factory_by_data.

    r_result = factory_by_filter( z2ui5_cl_layo_context=>filter_get_multi_by_data( val ) ).
    r_result->mv_check_popup = check_popup.
    r_result->ms_variant = s_variant.
    r_result->set_var_default( ).

  ENDMETHOD.

  METHOD result.
    result = ms_result.
  ENDMETHOD.

  METHOD set_output.

    DATA(tab) = view->ele( `Table`
                    )->a( n = `items` v = client->_bind( ms_result-t_filter ) ).

    tab->ele( `headerToolbar`
        )->ele( `Toolbar`
        )->tag( `Title`
        )->a( n = `text` v = ms_result-tab_name
        )->tag( `ToolbarSpacer`
        )->tag( `Button`
        )->a( n = `text` v = `Clear`
        )->a( n = `icon` v = `sap-icon://delete`
        )->a( n = `type` v = `Transparent`
        )->a( n = `press` v = client->_event( val = `DELETE_ALL` )
        )->tag( `Button`
        )->a( n = `text` v = `Load`
        )->a( n = `icon` v = `sap-icon://download-from-cloud`
        )->a( n = `press` v = client->_event( `BUTTON_LOAD` )
        )->tag( `Button`
        )->a( n = `text` v = `Save`
        )->a( n = `icon` v = `sap-icon://save`
        )->a( n = `press` v = client->_event( `BUTTON_SAVE` ) ).

    tab->ele( `columns`
        )->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = `Name`
        )->end(
        )->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = `Options`
        )->end(
        )->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = `Select`
        )->end(
        )->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = `Clear`
        )->end( ).
    DATA(cells) = tab->ele( `items`
                      )->ele( `ColumnListItem`
                      )->ele( `cells` ).
    cells->tag( `Text`
        )->a( n = `text` v = `{NAME}` ).
    cells->ele( `MultiInput`
        )->a( n = `tokens` v = `{T_TOKEN}`
        )->a( n = `enabled` b = abap_false
        )->a( n = `valueHelpRequest` v = client->_event( val   = `LIST_OPEN`
                                                           t_arg = VALUE #( ( `${NAME}` ) ) )
        )->ele( `tokens`
        )->tag( `Token`
        )->a( n = `key` v = `{KEY}`
        )->a( n = `text` v = `{TEXT}`
        )->a( n = `visible` v = `{VISIBLE}`
        )->a( n = `selected` v = `{SELKZ}`
        )->a( n = `editable` v = `{EDITABLE}` ).
    cells->tag( `Button`
        )->a( n = `text` v = `Select`
        )->a( n = `press` v = client->_event( val   = `LIST_OPEN`
                                           t_arg = VALUE #( ( `${NAME}` ) ) ) ).
    cells->tag( `Button`
        )->a( n = `icon` v = `sap-icon://delete`
        )->a( n = `type` v = `Transparent`
        )->a( n = `text` v = `Clear`
        )->a( n = `press` v = client->_event( val   = `LIST_DELETE`
                                           t_arg = VALUE #( ( `${NAME}` ) ) ) ).

  ENDMETHOD.

  METHOD main.

    result = abap_true.

    " only the return of a popup THIS instance called (its nav tag): a host
    " with two selections, or one that opens a range or variant popup
    " itself, keeps its own returns. Handled on cancel too: the caller has
    " to display its view again, and the popup's events must not reach it
    IF client->check_on_nav_back( ) = abap_true AND mv_nav_id IS NOT INITIAL.
      DATA(lv_tag) = client->get_nav_tag( ).
      DATA(lv_prefix) = |{ mv_nav_id }_|.
      IF strlen( lv_tag ) > strlen( lv_prefix ) AND lv_tag CP |{ lv_prefix }*|.
        on_nav_back( client = client
                     kind   = substring( val = lv_tag
                                         off = strlen( lv_prefix ) ) ).
        RETURN.
      ENDIF.
    ENDIF.

    CASE client->get( )-event.

      WHEN `LIST_OPEN`.
        " the name comes from the client - an unknown one is ignored instead
        " of raising CX_SY_ITAB_LINE_NOT_FOUND
        ASSIGN ms_result-t_filter[ name = client->get_event_arg( 1 ) ] TO FIELD-SYMBOL(<ls_open>).
        IF <ls_open> IS NOT ASSIGNED.
          RETURN.
        ENDIF.
        mv_popup_name = <ls_open>-name.
        client->nav_app_call( app = z2ui5_cl_sel_range_pop=>factory( <ls_open>-t_range )
                              tag = nav_tag( cs_nav-range ) ).

      WHEN `LIST_DELETE`.
        mv_popup_name = client->get_event_arg( 1 ).
        " a field symbol, not CLEAR itab[ ... ]-component: the 702 downport
        " cannot rewrite that
        ASSIGN ms_result-t_filter[ name = mv_popup_name ] TO FIELD-SYMBOL(<ls_filter>).
        IF <ls_filter> IS ASSIGNED.
          CLEAR <ls_filter>-t_range.
          CLEAR <ls_filter>-t_token.
        ENDIF.

      WHEN `BUTTON_LOAD`.
        DATA(lo_popup3) = z2ui5_cl_sel_var_pop_read=>factory( var_check_user = abap_true
                                                              var_handle1    = ms_variant-handle01
                                                              var_handle2    = ms_variant-handle02
                                                              var_handle3    = ms_variant-handle03 ).
        client->nav_app_call( app = lo_popup3
                              tag = nav_tag( cs_nav-var_read ) ).

      WHEN `BUTTON_SAVE`.
        DATA(lo_popup4) = z2ui5_cl_sel_var_pop_save=>factory( val            = ms_result
                                                              var_check_user = abap_true
                                                              var_handle1    = ms_variant-handle01
                                                              var_handle2    = ms_variant-handle02
                                                              var_handle3    = ms_variant-handle03 ).
        client->nav_app_call( app = lo_popup4
                              tag = nav_tag( cs_nav-var_save ) ).

      WHEN `DELETE_ALL`.
        LOOP AT ms_result-t_filter REFERENCE INTO DATA(lr_sql).
          CLEAR lr_sql->t_token.
          CLEAR lr_sql->t_range.
        ENDLOOP.

      WHEN OTHERS.
        result = abap_false.

    ENDCASE.

  ENDMETHOD.

  METHOD factory_by_name.

    r_result = factory_by_data( val       = z2ui5_cl_layo_context=>rtti_create_tab_by_name( val )
                                s_variant = s_variant ).
    r_result->ms_result-tab_name = val.

  ENDMETHOD.

  METHOD nav_tag.

    IF mv_nav_id IS INITIAL.
      mv_nav_id = z2ui5_cl_layo_context=>uuid_get_c32( ).
    ENDIF.
    result = |{ mv_nav_id }_{ kind }|.

  ENDMETHOD.

  METHOD on_nav_back.

    FIELD-SYMBOLS <tab> TYPE z2ui5_cl_layo_context=>ty_s_filter_multi.

    " the popup once - get_app_prev( ) loads and parses its draft
    DATA(li_prev) = client->get_app_prev( ).

    IF kind = cs_nav-range AND li_prev IS INSTANCE OF z2ui5_cl_sel_range_pop.
      DATA(ls_range) = CAST z2ui5_cl_sel_range_pop( li_prev )->result( ).
      IF ls_range-check_confirmed = abap_true.
        ASSIGN ms_result-t_filter[ name = mv_popup_name ] TO <tab>.
        IF <tab> IS ASSIGNED.
          <tab>-t_range = ls_range-t_range.
          <tab>-t_token = z2ui5_cl_layo_context=>filter_get_token_t_by_range_t( <tab>-t_range ).
        ENDIF.
      ENDIF.

    ELSEIF kind = cs_nav-var_read AND li_prev IS INSTANCE OF z2ui5_cl_sel_var_pop_read.
      DATA(ls_value) = CAST z2ui5_cl_sel_var_pop_read( li_prev )->result( ).
      IF ls_value-check_confirmed = abap_true.
        TRY.
            z2ui5_cl_layo_context=>xml_parse( EXPORTING xml = ls_value-s_variant-data
                                             IMPORTING any = ms_result ).
          CATCH cx_root ##NO_HANDLER.
            " a variant that no longer fits the selection - the selection stays
        ENDTRY.
      ENDIF.

    ENDIF.
    " the save popup has stored its variant itself - nothing to take over

  ENDMETHOD.

  METHOD set_var_default.

    DATA(ls_default) = z2ui5_cl_sel_var_db=>db_read_default( ms_variant ).

    IF ls_default-data IS NOT INITIAL.
      " a default saved for an older shape of the selection no longer
      " parses (xml_parse raises) - the selection the caller handed in stays
      DATA(ls_result) = ms_result.
      TRY.
          z2ui5_cl_layo_context=>xml_parse( EXPORTING xml = ls_default-data
                                           IMPORTING any = ls_result ).
          ms_result = ls_result.
        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
