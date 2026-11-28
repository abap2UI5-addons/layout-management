CLASS z2ui5_cl_sel_var_pop_save DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_variant,
        uname   TYPE string,
        handle1 TYPE string,
        handle2 TYPE string,
        handle3 TYPE string,
      END OF ty_s_variant.

    TYPES:
      BEGIN OF ty_s_variant_out,
        s_variant     TYPE ty_s_variant,
        name          TYPE string,
        description   TYPE string,
        selkz         TYPE abap_bool,
        check_user    TYPE abap_bool,
        check_default TYPE abap_bool,
        t_filter      TYPE z2ui5_cl_layo_context=>ty_t_filter_multi,
      END OF ty_s_variant_out.
    " kept for callers - the popup itself keeps no list of variants
    TYPES ty_t_variant_out TYPE STANDARD TABLE OF ty_s_variant_out WITH EMPTY KEY ##NEEDED.

    DATA ms_variant_save TYPE ty_s_variant_out.

    CLASS-METHODS factory
      IMPORTING
        val             TYPE z2ui5_cl_sel_multisel=>ty_s_result
        var_check_user  TYPE abap_bool DEFAULT abap_true
        var_handle1     TYPE clike     DEFAULT sy-repid
        var_handle2     TYPE clike     OPTIONAL
        var_handle3     TYPE clike     OPTIONAL
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_sel_var_pop_save.

    TYPES:
      BEGIN OF ty_s_result,
        t_filter        TYPE z2ui5_cl_layo_context=>ty_t_filter_multi,
        check_confirmed TYPE abap_bool,
      END OF ty_s_result.

    METHODS result
      RETURNING
        VALUE(result) TYPE ty_s_result.

  PROTECTED SECTION.
    DATA client     TYPE REF TO z2ui5_if_client.
    DATA ms_variant TYPE ty_s_variant.
    DATA s_variant  TYPE z2ui5_cl_sel_multisel=>ty_s_result.
    DATA ms_result  TYPE ty_s_result.

    METHODS popup_variant_save.
    METHODS init.
    METHODS save_variant.

    "! user and name of the variant the user was told exists already - Save
    "! again replaces it. Protected, not private: the draft of the app
    "! reaches no private attribute
    DATA mv_name_confirmed TYPE string.

  PRIVATE SECTION.
    " the lengths of NAME and DESCR of z2ui5_t_13 - a longer input was cut
    " off silently, and two names alike in their first ten characters
    " replaced each other
    CONSTANTS cv_name_length  TYPE i VALUE 10.
    CONSTANTS cv_descr_length TYPE i VALUE 50.

    "! the variant as it goes into the table
    METHODS get_db_info
      RETURNING
        VALUE(result) TYPE z2ui5_t_13.

    "! abap_false with a message when the input cannot be saved as it is
    METHODS check_save
      RETURNING
        VALUE(result) TYPE abap_bool.

ENDCLASS.


CLASS z2ui5_cl_sel_var_pop_save IMPLEMENTATION.

  METHOD factory.

    r_result = NEW #( ).
    r_result->s_variant = val.

    r_result->ms_variant = VALUE #( uname   = COND #( WHEN var_check_user = abap_true THEN sy-uname )
                                    handle1 = var_handle1
                                    handle2 = var_handle2
                                    handle3 = var_handle3 ).
    " the switch starts where the caller stands: user-specific unless it
    " asked for variants without a user
    r_result->ms_variant_save-check_user = var_check_user.

  ENDMETHOD.

  METHOD init.

    popup_variant_save( ).

  ENDMETHOD.

  METHOD popup_variant_save.

    DATA(popup) = z2ui5_cl_ui5_view_builder=>factory(
                      )->ele( n = `FragmentDefinition` ns = `core`
                      )->a( n = `xmlns` v = `sap.m`
                      )->a( n = `xmlns:core` v = `sap.ui.core`
                      )->a( n = `xmlns:form` v = `sap.ui.layout.form` ).

    DATA(dialog) = popup->ele( `Dialog`
                       )->a( n = `title` v = `Save Variant`
                       )->a( n = `contentHeight` v = `50%`
                       )->a( n = `contentWidth` v = `50%`
                       )->a( n = `afterClose` v = client->_event( `DB_SAVE_CLOSE` ) ).

    DATA(form) = dialog->ele( n = `SimpleForm` ns = `form`
                     )->a( n = `editable` b = abap_true
                     )->a( n = `labelSpanXL` v = `4`
                     )->a( n = `labelSpanL` v = `4`
                     )->a( n = `labelSpanM` v = `4`
                     )->a( n = `labelSpanS` v = `4`
                     )->a( n = `adjustLabelSpan` b = abap_false ).

    form->ele( `Toolbar`
        )->tag( `Title`
        )->a( n = `text` v = `Variant` ).

    form->ele( n = `content` ns = `form`
        )->tag( `Label`
        )->a( n = `text` v = `Variant`
        )->tag( `Input`
        )->a( n = `value` v = client->_bind( ms_variant_save-name )
        )->a( n = `maxLength` v = |{ cv_name_length }|
        )->tag( `Label`
        )->a( n = `text` v = `Description`
        )->tag( `Input`
        )->a( n = `value` v = client->_bind( ms_variant_save-description )
        )->a( n = `maxLength` v = |{ cv_descr_length }| ).

    form->ele( `Toolbar`
        )->tag( `Title`
        )->a( n = `text` v = `Save Options` ).

    form->ele( n = `content` ns = `form`
        )->tag( `Label`
        )->a( n = `text` v = `Default Variant`
        )->tag( `Switch`
        )->a( n = `type` v = `AcceptReject`
        )->a( n = `state` v = client->_bind( ms_variant_save-check_default )
        )->tag( `Label`
        )->a( n = `text` v = `User specific`
        )->tag( `Switch`
        )->a( n = `type` v = `AcceptReject`
        )->a( n = `state` v = client->_bind( ms_variant_save-check_user ) ).

    dialog->ele( `buttons`
        )->tag( `Button`
        )->a( n = `text` v = `Cancel`
        )->a( n = `icon` v = `sap-icon://sys-cancel`
        )->a( n = `press` v = client->_event( `DB_SAVE_CLOSE` )
        )->tag( `Button`
        )->a( n = `text` v = `Save`
        )->a( n = `press` v = client->_event( `DB_SAVE` )
        )->a( n = `type` v = `Success`
        )->a( n = `icon` v = `sap-icon://save` ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD result.
    result = ms_result.
  ENDMETHOD.

  METHOD z2ui5_if_app~main.
    me->client = client.

    IF client->check_on_init( ).
      init( ).
      RETURN.
    ELSEIF client->check_on_navigated( ).
      " a restored draft (browser Forward, a reload): the popup went with
      " the page - show it again
      popup_variant_save( ).
      RETURN.
    ENDIF.

    CASE client->get( )-event.

      WHEN `DB_SAVE_CLOSE`.
        client->popup_destroy( ).
        client->nav_app_leave( ).

      WHEN `DB_SAVE`.
        IF check_save( ) = abap_false.
          RETURN.
        ENDIF.
        save_variant( ).
        ms_result-check_confirmed = abap_true.
        client->popup_destroy( ).
        client->nav_app_leave( ).

    ENDCASE.
  ENDMETHOD.

  METHOD save_variant.

    " the result is the selection saved
    ms_result-t_filter       = s_variant-t_filter.
    ms_variant_save-t_filter = s_variant-t_filter.

    z2ui5_cl_sel_var_db=>db_save( s_info = get_db_info( )
                                  data   = s_variant ).

  ENDMETHOD.

  METHOD get_db_info.

    " "User specific" decides who sees the variant: saved with the user
    " name only the user, saved without one everybody
    result = VALUE #( uname     = COND #( WHEN ms_variant_save-check_user = abap_true
                                          THEN sy-uname )
                      name      = ms_variant_save-name
                      descr     = ms_variant_save-description
                      check_def = ms_variant_save-check_default
                      check_usr = ms_variant_save-check_user
                      handle01  = ms_variant-handle1
                      handle02  = ms_variant-handle2
                      handle03  = ms_variant-handle3 ).

  ENDMETHOD.

  METHOD check_save.

    IF ms_variant_save-name IS INITIAL.
      client->message_toast_display( `Enter a name for the variant` ).
      RETURN.
    ENDIF.

    " the input is limited in the browser, the event is not
    IF    strlen( ms_variant_save-name ) > cv_name_length
       OR strlen( ms_variant_save-description ) > cv_descr_length.
      client->message_toast_display( |The name has at most { cv_name_length }, the description { cv_descr_length } characters| ).
      RETURN.
    ENDIF.

    " saving under a name that exists replaces that variant - a shared one
    " every user sees - so only when Save is pressed again for that name
    DATA(ls_info) = get_db_info( ).
    DATA(lv_key)  = |{ ls_info-uname }/{ ls_info-name }|.
    IF     lv_key <> mv_name_confirmed
       AND z2ui5_cl_sel_var_db=>db_check_exists( ls_info ) = abap_true.
      mv_name_confirmed = lv_key.
      client->message_toast_display( |A variant { ms_variant_save-name } exists already - press Save again to replace it| ).
      RETURN.
    ENDIF.

    result = abap_true.

  ENDMETHOD.

ENDCLASS.
