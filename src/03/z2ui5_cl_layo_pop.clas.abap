CLASS z2ui5_cl_layo_pop DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    " abap2ui5lint-disable-next-line unbound-public-attribute -- the calling apps read it after nav_app_leave( ) to decide whether to re-render
    DATA mv_rerender    TYPE abap_bool.

    TYPES:
      BEGIN OF ty_s_sorting,
        sorting TYPE string,
        descr   TYPE string,
      END OF ty_s_sorting.
    TYPES ty_t_sorting TYPE STANDARD TABLE OF ty_s_sorting WITH DEFAULT KEY.

    TYPES BEGIN OF ty_s_layo.
            INCLUDE TYPE z2ui5_t_11.
    TYPES   selkz  TYPE abap_bool.
    TYPES   active TYPE c LENGTH 1.
    TYPES END OF ty_s_layo.
    TYPES ty_t_layo TYPE STANDARD TABLE OF ty_s_layo WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_s_col,
             col TYPE c LENGTH 2,
           END OF ty_s_col.

    TYPES temp1_0c842a14a6 TYPE STANDARD TABLE OF ty_s_col WITH DEFAULT KEY.
DATA t_col          TYPE temp1_0c842a14a6.

    DATA mo_layout      TYPE REF TO z2ui5_cl_layo_manager.
    DATA mt_layout      TYPE z2ui5_cl_layo_manager=>ty_t_positions.

    DATA mt_head        TYPE ty_t_layo.
    DATA mv_descr       TYPE string.
    DATA mv_layout      TYPE string.
    DATA mv_def         TYPE abap_bool.
    DATA mv_usr         TYPE abap_bool.
    DATA mv_format      TYPE string.
    DATA mt_sorting     TYPE ty_t_sorting.
    DATA mv_tab         TYPE string.

    DATA mv_xl_label    TYPE int4.
    DATA mv_xl_value    TYPE int4.
    DATA mv_l_label     TYPE int4.
    DATA mv_l_value     TYPE int4.
    DATA mv_m_label     TYPE int4.
    DATA mv_m_value     TYPE int4.
    DATA mv_s_label     TYPE int4.
    DATA mv_s_value     TYPE int4.

    CLASS-METHODS on_event_layout
      IMPORTING
        !client TYPE REF TO z2ui5_if_client
        !layout TYPE REF TO z2ui5_cl_layo_manager.

    CLASS-METHODS render_layout_function
      IMPORTING
        !xml          TYPE REF TO z2ui5_cl_ui5_view_builder
        !client       TYPE REF TO z2ui5_if_client
        !layout       TYPE REF TO z2ui5_cl_layo_manager
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_view_builder.

    CLASS-METHODS factory
      IMPORTING
        !layout       TYPE REF TO z2ui5_cl_layo_manager
        open_layout   TYPE abap_bool OPTIONAL
        delete_layout TYPE abap_bool OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_layo_pop.

  PROTECTED SECTION.
    DATA mt_controls    TYPE z2ui5_cl_layo_manager=>ty_t_controls.
    DATA mv_open        TYPE abap_bool.
    DATA mv_delete      TYPE abap_bool.
    DATA mv_active_line TYPE string.

    DATA client  TYPE REF TO z2ui5_if_client.

    METHODS render_edit.
    METHODS on_event.
    METHODS render_save.
    METHODS save_layout
      RETURNING
        VALUE(result) TYPE abap_bool.
    METHODS get_layouts.
    METHODS init_edit.
    METHODS render_delete.
    METHODS render_tabstrip
      IMPORTING
        !dialog       TYPE REF TO z2ui5_cl_ui5_view_builder
        !active       TYPE string
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_view_builder.
    METHODS render_add_subcolumn.
    METHODS on_event_subcolumns.
    METHODS check_rerender_necessary.

    METHODS on_init.

    METHODS render_open.

    METHODS get_selected_layout
      RETURNING
        VALUE(result) TYPE ty_s_layo.

    METHODS delete_selected_layout
      IMPORTING
        !head         TYPE ty_s_layo
      RETURNING
        VALUE(result) TYPE abap_bool.

    METHODS set_selected_layout
      IMPORTING
        !head TYPE ty_s_layo.

    METHODS check_width_unit
      IMPORTING
        !width        TYPE z2ui5_t_12-width
      RETURNING
        VALUE(result) TYPE z2ui5_t_12-width.

    METHODS on_event_gridlayout.
    METHODS render_add_gridlayout.
    METHODS update_values.

  PRIVATE SECTION.
    METHODS check_grid_sum
      IMPORTING
        !value        TYPE int4
      RETURNING
        VALUE(result) TYPE abap_bool.

    METHODS edit_okay.
    METHODS search.

ENDCLASS.


CLASS z2ui5_cl_layo_pop IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    me->client = client.

    IF client->check_on_init( ) IS NOT INITIAL.

      on_init( ).

      init_edit( ).

      render_edit( ).
      RETURN.

    ENDIF.

    update_values( ).

    on_event( ).

  ENDMETHOD.

  METHOD on_init.
      DATA temp1 TYPE z2ui5_cl_layo_pop=>ty_t_sorting.
      DATA temp2 LIKE LINE OF temp1.

    IF mt_controls IS INITIAL.
      mt_controls = z2ui5_cl_layo_manager=>get_controls( ).


      CLEAR temp1.

      temp2-sorting = 'ASCENDING'.
      temp2-descr = 'Ascending'.
      INSERT temp2 INTO TABLE temp1.
      temp2-sorting = 'DESCENDING'.
      temp2-descr = 'Descending'.
      INSERT temp2 INTO TABLE temp1.
      temp2-sorting = ``.
      temp2-descr = ``.
      INSERT temp2 INTO TABLE temp1.
      mt_sorting = temp1.

    ENDIF.

  ENDMETHOD.

  METHOD render_edit.

    DATA popup TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA dialog TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA content TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA tab TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA temp3 TYPE z2ui5_if_client=>ty_s_event_control.
    DATA list TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA cells TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA columns TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA t_layout LIKE mo_layout->ms_layout-t_layout.
    DATA lt_comp TYPE abap_component_tab.
    DATA temp4 LIKE LINE OF mt_controls.
    DATA control LIKE REF TO temp4.
      DATA comp TYPE abap_componentdescr.
          DATA col TYPE REF TO z2ui5_cl_ui5_view_builder.
    popup = z2ui5_cl_ui5_view_builder=>factory(
                      )->ele( n = `FragmentDefinition` ns = `core`
                      )->a( n = `xmlns` v = `sap.m`
                      )->a( n = `xmlns:core` v = `sap.ui.core` ).


    dialog = popup->ele( `Dialog`
                       )->a( n = `title` v = 'Edit Layout'
                       )->a( n = `contentWidth` v = '80%'
                       )->a( n = `contentHeight` v = '80%'
                       )->a( n = `afterClose` v = client->_event( 'CLOSE' ) ).


    content = render_tabstrip( dialog = dialog
                                     active = 'EDIT' ).


    tab = content->ele( `Table`
                    )->a( n = `growing` b = abap_true
                    )->a( n = `growingThreshold` v = '80'
                    )->a( n = `sticky` v = `ColumnHeaders`
                    )->a( n = `items` v = client->_bind_edit( mt_layout ) ).


    CLEAR temp3.
    temp3-check_queue_last = abap_true.
    temp3-check_no_busy = abap_true.
    tab->ele( `headerToolbar`
        )->ele( `OverflowToolbar`
        )->tag( `ToolbarSpacer`
        )->tag( `SearchField`
        )->a( n = `width` v = `17.5rem`
        )->a( n = `placeholder` t = |{ z2ui5_cl_util=>rtti_get_data_element_texts( 'ROLLNAME' )-long
                                       }/{
                                         z2ui5_cl_util=>rtti_get_data_element_texts( 'NAME_FELD' )-long }|
        )->a( n = `liveChange` v = client->_event( val    = 'BUTTON_SEARCH'
                                                      arg    = `${$source>/value}`
                                                      s_ctrl = temp3 ) ).


    list = tab->ele( `ColumnListItem` ).


    cells = list->ele( `cells` ).


    columns = tab->ele( `columns` ).


    t_layout = mo_layout->ms_layout-t_layout.

    SORT t_layout BY visible DESCENDING
                     fname ASCENDING.


    lt_comp = z2ui5_cl_util=>rtti_get_t_attri_by_any( t_layout ).



    LOOP AT mt_controls REFERENCE INTO control WHERE control = mo_layout->ms_layout-s_head-control.


      READ TABLE lt_comp INTO comp WITH KEY name = control->attribute.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      CASE control->attribute.
        WHEN 'TLABEL'.

          col = columns->ele( `Column`
                          )->a( n = `width` v = `15%`
                          )->ele( `header` ).
          col->tag( `Text`
              )->a( n = `text` v = `Row` ).
        WHEN 'VISIBLE'.
          col = columns->ele( `Column`
                    )->a( n = `width` v = `10%`
                    )->ele( `header` ).
          col->tag( `Text`
              )->a( n = `text` v = 'Visible' ).
        WHEN 'MERGE'.
          col = columns->ele( `Column`
                    )->a( n = `width` v = `10%`
                    )->ele( `header` ).
          col->tag( `Text`
              )->a( n = `text` v = 'Merge' ).
        WHEN 'WIDTH'.
          col = columns->ele( `Column`
                    )->a( n = `width` v = `10%`
                    )->ele( `header` ).
          col->tag( `Text`
              )->a( n = `text` v = 'Width in rem' ).
        WHEN 'SEQUENCE'.
          col = columns->ele( `Column`
                    )->a( n = `width` v = `10%`
                    )->ele( `header` ).
          col->tag( `Text`
              )->a( n = `text` v = 'Sequence' ).
        WHEN 'ALTERNATIVE_TEXT'.
          col = columns->ele( `Column`
                    )->a( n = `width` v = `10%`
                    )->ele( `header` ).
          col->tag( `Text`
              )->a( n = `text` v = 'Alternative Text' ).
        WHEN 'REFERENCE_FIELD'.
          col = columns->ele( `Column`
                    )->a( n = `width` v = `10%`
                    )->ele( `header` ).
          col->tag( `Text`
              )->a( n = `text` v = 'Reference Field' ).
        WHEN 'SUBCOLUMN'.
          col = columns->ele( `Column`
                    )->a( n = `width` v = `15%`
                    )->ele( `header` ).
          col->tag( `Text`
              )->a( n = `text` v = 'Subcolumn' ).
        WHEN 'GRID_LAYOUT'.
          col = columns->ele( `Column`
                    )->a( n = `width` v = `5%`
                    )->ele( `header` ).
          col->tag( `Text`
              )->a( n = `text` v = 'Layout' ).
        WHEN 'NO_CONVEXIT'.
          col = columns->ele( `Column`
                    )->a( n = `width` v = `10%`
                    )->ele( `header` ).
          col->tag( `Text`
              )->a( n = `text` v = 'No Conversion Exit' ).
        WHEN 'SORTING'.
          col = columns->ele( `Column`
                    )->a( n = `width` v = `10%`
                    )->ele( `header` ).
          col->tag( `Text`
              )->a( n = `text` v = 'Sorting' ).
      ENDCASE.

    ENDLOOP.

    LOOP AT mt_controls REFERENCE INTO control WHERE control = mo_layout->ms_layout-s_head-control.

      READ TABLE lt_comp INTO comp WITH KEY name = control->attribute.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      CASE comp-name.
        WHEN 'TLABEL'.

          cells->tag( `Text`
              )->a( n = `text` v = |\{FNAME\} { cl_abap_char_utilities=>cr_lf } \{TLABEL\} | ).

        WHEN 'VISIBLE' OR 'MERGE'.

          cells->tag( `Switch`
              )->a( n = `type` v = 'AcceptReject'
              )->a( n = `state` v = |\{{ comp-name }\}| ).

        WHEN 'NO_CONVEXIT'.

          cells->ele( `VBox`
              )->a( n = `visible` v = |\{SHOW_CONVEXIT\}|
              )->tag( `Switch`
              )->a( n = `customTextOn` v = |\{CONVEXIT\}|
              )->a( n = `customTextOff` v = |\{CONVEXIT\}|
              )->a( n = `state` v = |\{{ comp-name }\}| ).

        WHEN 'WIDTH'.

          cells->tag( `Input`
              )->a( n = `value` v = |\{{ comp-name }\}|
              )->a( n = `maxLength` v = `6`
              )->a( n = `width` v = `4rem` ).

        WHEN 'SEQUENCE'.

          cells->tag( `Input`
              )->a( n = `value` v = |\{{ comp-name }\}|
              )->a( n = `maxLength` v = `3`
              )->a( n = `width` v = `3rem`
              )->a( n = `type` v = `Number` ).

        WHEN 'ALTERNATIVE_TEXT'.

          cells->tag( `Input`
              )->a( n = `value` v = |\{{ comp-name }\}| ).

        WHEN 'SUBCOLUMN'.

          cells->tag( `Button`
              )->a( n = `text` v = |\{{ comp-name }\}|
              )->a( n = `icon` v = `sap-icon://add`
              )->a( n = `width` v = '100%'
              )->a( n = `press` v = client->_event( val = 'CALL_SUBCOLUMN'
                                                 arg = `${FNAME}` ) ).

        WHEN 'SORTING'.

          cells->ele( `ComboBox`
              )->a( n = `selectedKey` v = |\{{ comp-name }\}|
              )->a( n = `items` v = client->_bind_edit( mt_sorting )
              )->a( n = `width` v = '5rem'
              )->tag( n = `Item` ns = `core`
              )->a( n = `key` v = '{SORTING}'
              )->a( n = `text` v = '{DESCR}' ).

        WHEN 'REFERENCE_FIELD'.

          cells->ele( `ComboBox`
              )->a( n = `selectedKey` v = |\{{ comp-name }\}|
              )->a( n = `items` v = client->_bind_edit( mo_layout->ms_layout-t_layout )
              )->a( n = `width` v = '10rem'
              )->tag( n = `Item` ns = `core`
              )->a( n = `key` v = '{FNAME}'
              )->a( n = `text` v = '{FNAME} - {TLABEL}' ).

        WHEN 'GRID_LAYOUT'.

          cells->tag( `Button`
              )->a( n = `text` v = |\{{ comp-name }\}|
              )->a( n = `icon` v = `sap-icon://grid`
              )->a( n = `width` v = '5rem'
              )->a( n = `press` v = client->_event( val = 'CALL_GRIDLAYOUT'
                                                 arg = `${FNAME}` ) ).

      ENDCASE.

    ENDLOOP.

    dialog->ele( `buttons`
        )->tag( `Button`
        )->a( n = `text` v = 'Close'
        )->a( n = `icon` v = 'sap-icon://sys-cancel-2'
        )->a( n = `press` v = client->_event( 'CLOSE' )
        )->tag( `Button`
        )->a( n = `text` v = 'Okay'
        )->a( n = `icon` v = 'sap-icon://accept'
        )->a( n = `press` v = client->_event( 'EDIT_OKAY' )
        )->tag( `Button`
        )->a( n = `text` v = 'Save'
        )->a( n = `press` v = client->_event( 'EDIT_SAVE' )
        )->a( n = `icon` v = 'sap-icon://save'
        )->a( n = `type` v = 'Emphasized' ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD on_event.

    CASE client->get( )-event.

      WHEN 'TAB_SELECT'.

        " mv_tab is two-way bound to the IconTabBar selectedKey and already
        " carries the newly selected tab here.
        CASE mv_tab.
          WHEN 'SELECT'.
            get_layouts( ).
            render_open( ).
          WHEN 'DELETE'.
            get_layouts( ).
            render_delete( ).
          WHEN OTHERS.
            init_edit( ).
            render_edit( ).
        ENDCASE.

      WHEN 'EDIT_OKAY'.

        edit_okay( ).

      WHEN 'BUTTON_SEARCH'.

        search( ).

      WHEN 'CLOSE'.

        mo_layout->ms_layout = mo_layout->ms_layout_tmp.

        client->popup_destroy( ).

        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN 'EDIT_SAVE'.

        render_save( ).

      WHEN 'SAVE_CLOSE'.

        client->popup_destroy( ).

        render_edit( ).

      WHEN 'SAVE_SAVE'.

        " Only leave the save dialog when the layout was really persisted,
        " so a failed save (e.g. missing name) keeps the dialog open.
        IF save_layout( ) = abap_true.
          edit_okay( ).
        ENDIF.

      WHEN 'OPEN_SELECT'.

        set_selected_layout( get_selected_layout( ) ).

        mv_rerender = abap_true.

        client->popup_destroy( ).

        client->nav_app_leave( ).

      WHEN 'DELETE_SELECT'.

        " Only remove the row from the list when the delete was committed,
        " otherwise the layout would reappear on the next selection.
        IF delete_selected_layout( get_selected_layout( ) ) = abap_true.
          DELETE mt_head WHERE selkz = abap_true.
        ENDIF.

        client->popup_model_update( ).

      WHEN OTHERS.

        on_event_subcolumns( ).

        on_event_gridlayout( ).

    ENDCASE.

  ENDMETHOD.

  METHOD search.
    DATA temp5 TYPE string_table.

    mt_layout = mo_layout->ms_layout-t_layout.


    CLEAR temp5.
    INSERT `FNAME` INTO TABLE temp5.
    INSERT `ROLLNAME` INTO TABLE temp5.
    INSERT `TLABEL` INTO TABLE temp5.
    z2ui5_cl_util=>itab_filter_by_val(
      EXPORTING
        val    = client->get_event_arg( )
        fields = temp5
      CHANGING
        tab    = mt_layout ).

    client->popup_model_update( ).

  ENDMETHOD.

  METHOD edit_okay.

    DATA temp7 LIKE LINE OF mo_layout->ms_layout-t_layout.
    DATA layout LIKE REF TO temp7.
    LOOP AT mo_layout->ms_layout-t_layout REFERENCE INTO layout.
      " the alternative text is a data element name for a table or form, a
      " label as typed in the generic mode
      IF mo_layout->ms_layout-s_head-control <> z2ui5_cl_layo_manager=>generic.
        layout->alternative_text = to_upper( layout->alternative_text ).
        layout->width            = check_width_unit( layout->width ).
      ENDIF.
      layout->tlabel = mo_layout->text_of( layout->* ).
    ENDLOOP.

    mo_layout->ms_layout-t_layout = mo_layout->sort_by_sequence( mo_layout->ms_layout-t_layout ).

    check_rerender_necessary( ).

    client->popup_destroy( ).

    client->nav_app_leave( ).

  ENDMETHOD.

  METHOD factory.

    CREATE OBJECT result.

    result->mo_layout = layout.

    result->mt_layout = layout->ms_layout-t_layout.

    result->mv_open   = open_layout.
    result->mv_delete = delete_layout.

    result->mo_layout->ms_layout_tmp = result->mo_layout->ms_layout.

  ENDMETHOD.

  METHOD render_layout_function.

    result = xml.

    " the generic mode loads its default variant on the first use - before
    " the button takes the guid, or it would fire the guid of a layout that
    " the default has replaced by then
    layout->prepare( ).

    result->tag( `Button`
        )->a( n = `icon` v = 'sap-icon://action-settings'
        )->a( n = `press` v = client->_event( layout->ms_layout-s_head-guid ) ).

  ENDMETHOD.

  METHOD render_save.

    DATA popup TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA dialog TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA form TYPE REF TO z2ui5_cl_ui5_view_builder.
    popup = z2ui5_cl_ui5_view_builder=>factory(
                      )->ele( n = `FragmentDefinition` ns = `core`
                      )->a( n = `xmlns` v = `sap.m`
                      )->a( n = `xmlns:core` v = `sap.ui.core`
                      )->a( n = `xmlns:form` v = `sap.ui.layout.form` ).


    dialog = popup->ele( `Dialog`
                       )->a( n = `title` v = 'Save'
                       )->a( n = `contentWidth` v = '80%'
                       )->a( n = `afterClose` v = client->_event( 'SAVE_CLOSE' ) ).


    form = dialog->ele( `content`
                     )->ele( n = `SimpleForm` ns = `form`
                     )->a( n = `title` v = 'Layout'
                     )->a( n = `editable` b = abap_true
                     )->a( n = `labelSpanXL` v = `4`
                     )->a( n = `labelSpanL` v = `4`
                     )->a( n = `labelSpanM` v = `4`
                     )->a( n = `labelSpanS` v = `4`
                     )->a( n = `adjustLabelSpan` b = abap_false
                     )->a( n = `emptySpanXL` v = `0`
                     )->a( n = `emptySpanL` v = `0`
                     )->a( n = `emptySpanM` v = `0`
                     )->a( n = `emptySpanS` v = `0`
                     )->a( n = `columnsXL` v = `2`
                     )->a( n = `columnsL` v = `2`
                     )->a( n = `columnsM` v = `2`
                     )->a( n = `singleContainerFullSize` v = `true` ).

    form->ele( `Toolbar`
        )->tag( `Title`
        )->a( n = `text` v = 'Layout' ).

    form->ele( n = `content` ns = `form`
        )->tag( `Label`
        )->a( n = `text` v = 'Layout'
        )->tag( `Input`
        )->a( n = `value` v = client->_bind_edit( mv_layout )
        )->a( n = `maxLength` v = '10'
        )->tag( `Label`
        )->a( n = `text` v = 'Description'
        )->tag( `Input`
        )->a( n = `value` v = client->_bind_edit( mv_descr ) ).

    form->ele( `Toolbar`
        )->tag( `Title`
        )->a( n = `text` v = `Save Options` ).

    form->ele( n = `content` ns = `form`
        )->tag( `Label`
        )->a( n = `text` v = 'Default Layout'
        )->tag( `Switch`
        )->a( n = `type` v = 'AcceptReject'
        )->a( n = `state` v = client->_bind_edit( mv_def )
        )->tag( `Label`
        )->a( n = `text` v = 'User specific'
        )->tag( `Switch`
        )->a( n = `type` v = 'AcceptReject'
        )->a( n = `state` v = client->_bind_edit( mv_usr )
        )->tag( `Label`
        )->a( n = `text` v = 'Screen Size'
        )->ele( `ComboBox`
        )->a( n = `selectedKey` v = client->_bind_edit( mv_format )
*             )->item( key  = `X`
*                         text        = `XL - Large Desktop`
        )->tag( n = `Item` ns = `core`
        )->a( n = `key` v = z2ui5_cl_layo_manager=>screen_format_l
        )->a( n = `text` v = `Large - Terminal`
*             )->item( key  = `M`
*                      text = `M - Tablet`
        )->tag( n = `Item` ns = `core`
        )->a( n = `key` v = z2ui5_cl_layo_manager=>screen_format_s
        )->a( n = `text` v = `Small - Handheld` ).

    dialog->ele( `buttons`
        )->tag( `Button`
        )->a( n = `text` v = 'Back'
        )->a( n = `icon` v = 'sap-icon://nav-back'
        )->a( n = `press` v = client->_event( 'SAVE_CLOSE' )
        )->tag( `Button`
        )->a( n = `text` v = 'Save'
        )->a( n = `press` v = client->_event( 'SAVE_SAVE' )
        )->a( n = `type` v = 'Accept'
        )->a( n = `icon` v = 'sap-icon://save' ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD save_layout.

    DATA position  TYPE z2ui5_t_12.
    TYPES temp2 TYPE STANDARD TABLE OF z2ui5_t_12 WITH DEFAULT KEY.
DATA positions TYPE temp2.
      DATA user LIKE sy-uname.
    DATA temp8 TYPE z2ui5_t_11.
    DATA head LIKE temp8.
    DATA temp9 TYPE string.
    DATA action LIKE temp9.
DATA BEGIN OF head_db.
DATA guid TYPE z2ui5_t_11-guid.
DATA layout TYPE z2ui5_t_11-layout.
DATA control TYPE z2ui5_t_11-control.
DATA handle01 TYPE z2ui5_t_11-handle01.
DATA handle02 TYPE z2ui5_t_11-handle02.
DATA handle03 TYPE z2ui5_t_11-handle03.
DATA handle04 TYPE z2ui5_t_11-handle04.
DATA uname TYPE z2ui5_t_11-uname.
DATA END OF head_db.
    DATA temp10 LIKE LINE OF mo_layout->ms_layout-t_layout.
    DATA r_layout LIKE REF TO temp10.
      DATA temp11 LIKE sy-subrc.
      DATA temp12 LIKE sy-subrc.
      DATA layout LIKE LINE OF mo_layout->ms_layout-t_layout.
        DATA temp13 LIKE sy-subrc.
        DATA temp14 LIKE sy-subrc.

    IF mv_layout IS INITIAL.
      client->message_toast_display( 'Layout name missing.' ).
      RETURN.
    ENDIF.

    IF mv_usr = abap_true.

      user = sy-uname.
    ENDIF.


    CLEAR temp8.
    temp8-guid = mo_layout->ms_layout-s_head-guid.
    temp8-layout = mv_layout.
    temp8-control = mo_layout->ms_layout-s_head-control.
    temp8-handle01 = mo_layout->ms_layout-s_head-handle01.
    temp8-handle02 = mo_layout->ms_layout-s_head-handle02.
    temp8-handle03 = mo_layout->ms_layout-s_head-handle03.
    temp8-handle04 = mo_layout->ms_layout-s_head-handle04.
    temp8-screen_format = mv_format.
    temp8-descr = mv_descr.
    temp8-def = mv_def.
    temp8-uname = user.

    head = temp8.

    " A shared layout (no user) is offered to, and loaded as default by,
    " every user of the app: saving one needs an authorization the addon
    " cannot decide itself - z2ui5_if_layo_auth does, and without an
    " implementation in the system the shipped default denies it

    IF head-uname IS INITIAL.
      temp9 = z2ui5_if_layo_auth=>cs_action-save_shared.
    ELSE.
      temp9 = z2ui5_if_layo_auth=>cs_action-save_own.
    ENDIF.

    action = temp9.
    IF z2ui5_cl_layo_auth=>check( action = action
                                  head   = head ) = abap_false.
      IF head-uname IS INITIAL.
        client->message_toast_display( 'You are not authorized to save a layout for all users - save it as user specific.' ).
      ELSE.
        client->message_toast_display( 'You are not authorized to save this layout.' ).
      ENDIF.
      RETURN.
    ENDIF.


    SELECT SINGLE guid
                  layout
                  control
                  handle01
                  handle02
                  handle03
                  handle04
                  uname
      FROM z2ui5_t_11 INTO head_db
      WHERE guid = head-guid
      .

    IF sy-subrc = 0.

      " found entry - the same keys save the changes, other keys a new layout.
      " A layout never changes hands: another user's personal layout, or a
      " shared layout saved as user specific, is saved as a new layout of
      " its own (a copy under the same name) and the original stays as it is
      IF NOT (     head_db-layout   = head-layout
               AND head_db-control  = head-control
               AND head_db-handle01 = head-handle01
               AND head_db-handle02 = head-handle02
               AND head_db-handle03 = head-handle03
               AND head_db-handle04 = head-handle04 )
          OR ( head_db-uname IS NOT INITIAL AND head_db-uname <> sy-uname )
          OR ( head_db-uname IS INITIAL AND head-uname IS NOT INITIAL ).

        " Save New Layout - new Guid
        TRY.
            head-guid = cl_system_uuid=>create_uuid_c32_static( ).
          CATCH cx_root ##NO_HANDLER.
        ENDTRY.

      ENDIF.

    ENDIF.



    LOOP AT mo_layout->ms_layout-t_layout REFERENCE INTO r_layout.
      r_layout->guid = head-guid.

      MOVE-CORRESPONDING r_layout->* TO position.
      " the generic mode keeps the width as typed (a CSS size), like edit_okay( )
      IF mo_layout->ms_layout-s_head-control <> z2ui5_cl_layo_manager=>generic.
        position-width = check_width_unit( position-width ).
      ENDIF.

      " only visible/ref_fields/SubCols should be saved - in the generic
      " mode every position is: a control missing from a saved layout is one
      " registered since, and is shown
      IF r_layout->visible = abap_true
          OR mo_layout->ms_layout-s_head-control = z2ui5_cl_layo_manager=>generic.
        APPEND position TO positions.
        CONTINUE.
      ENDIF.



      temp12 = sy-subrc.
      READ TABLE mo_layout->ms_layout-t_layout WITH KEY reference_field = r_layout->fname TRANSPORTING NO FIELDS.
      temp11 = sy-subrc.
      sy-subrc = temp12.
      IF temp11 = 0.
        APPEND position TO positions.
        CONTINUE.
      ENDIF.


      LOOP AT mo_layout->ms_layout-t_layout INTO layout WHERE t_sub_col IS NOT INITIAL.


        temp14 = sy-subrc.
        READ TABLE layout-t_sub_col WITH KEY fname = r_layout->fname TRANSPORTING NO FIELDS.
        temp13 = sy-subrc.
        sy-subrc = temp14.
        IF temp13 = 0.
          APPEND position TO positions.
          EXIT.
        ENDIF.
      ENDLOOP.

    ENDLOOP.

    " Persist head and positions in a single LUW. Do not rely on the
    " array-MODIFY sy-subrc for the commit decision: it is 4 for an empty
    " position table, which would silently skip the COMMIT.
    MODIFY z2ui5_t_11 FROM head.
    IF sy-subrc <> 0.
      ROLLBACK WORK.
      client->message_toast_display( 'Layout could not be saved.' ).
      RETURN.
    ENDIF.

    DELETE FROM z2ui5_t_12 WHERE guid = head-guid.

    IF positions IS NOT INITIAL.
      MODIFY z2ui5_t_12 FROM TABLE positions.
      IF sy-subrc <> 0.
        ROLLBACK WORK.
        client->message_toast_display( 'Layout could not be saved.' ).
        RETURN.
      ENDIF.
    ENDIF.

    " Only when this layout is the default, demote the other defaults of the
    " same scope. Saving a non-default layout must not touch the current
    " default - otherwise auto-loading silently stops working.
    IF head-def = abap_true.
      UPDATE z2ui5_t_11 SET def = abap_false WHERE control       = head-control
                                                AND handle01      = head-handle01
                                                AND handle02      = head-handle02
                                                AND handle03      = head-handle03
                                                AND handle04      = head-handle04
                                                AND screen_format = head-screen_format
                                                AND uname         = head-uname
                                                AND def           = abap_true
                                                AND guid         <> head-guid.
    ENDIF.

    COMMIT WORK AND WAIT.

    " Keep the in-memory head in sync with what was persisted, so a second
    " save in the same session compares against the right identity.
    mo_layout->ms_layout-s_head-guid          = head-guid.
    mo_layout->ms_layout-s_head-layout        = head-layout.
    mo_layout->ms_layout-s_head-descr         = head-descr.
    mo_layout->ms_layout-s_head-def           = head-def.
    mo_layout->ms_layout-s_head-screen_format = head-screen_format.
    mo_layout->ms_layout-s_head-uname         = head-uname.

    result = abap_true.

    client->message_toast_display( 'Data saved.' ).

  ENDMETHOD.

  METHOD render_tabstrip.
    DATA bar TYPE REF TO z2ui5_cl_ui5_view_builder.

    " Remember the active tab - it is two-way bound to the IconTabBar
    " selectedKey, so a tab click sends the new key back in mv_tab.
    mv_tab = active.


    bar = dialog->ele( `IconTabBar`
                    )->a( n = `selectedKey` v = client->_bind_edit( mv_tab )
                    )->a( n = `select` v = client->_event( 'TAB_SELECT' )
                    )->a( n = `stretchContentHeight` b = abap_true
                    )->a( n = `expandable` b = abap_false ).

    bar->ele( `items`
        )->ele( `IconTabFilter`
        )->a( n = `key` v = 'EDIT'
        )->a( n = `text` v = 'Edit'
        )->a( n = `icon` v = 'sap-icon://edit'
        )->end(
        )->ele( `IconTabFilter`
        )->a( n = `key` v = 'SELECT'
        )->a( n = `text` v = 'Select'
        )->a( n = `icon` v = 'sap-icon://open-folder'
        )->end(
        )->ele( `IconTabFilter`
        )->a( n = `key` v = 'DELETE'
        )->a( n = `text` v = 'Delete'
        )->a( n = `icon` v = 'sap-icon://delete' ).

    " The screen content lives in the bar-level content aggregation and is
    " swapped by the server when a different tab is selected.
    result = bar->ele( `content` ).

  ENDMETHOD.

  METHOD render_delete.

    DATA popup TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA dialog TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA content TYPE REF TO z2ui5_cl_ui5_view_builder.
    popup = z2ui5_cl_ui5_view_builder=>factory(
                      )->ele( n = `FragmentDefinition` ns = `core`
                      )->a( n = `xmlns` v = `sap.m`
                      )->a( n = `xmlns:core` v = `sap.ui.core` ).


    dialog = popup->ele( `Dialog`
                       )->a( n = `title` v = 'Delete Layout'
                       )->a( n = `contentWidth` v = '80%'
                       )->a( n = `contentHeight` v = '80%'
                       )->a( n = `afterClose` v = client->_event( 'CLOSE' ) ).


    content = render_tabstrip( dialog = dialog
                                     active = 'DELETE' ).

    content->ele( `Table`
        )->a( n = `mode` v = 'SingleSelectLeft'
        )->a( n = `items` v = client->_bind_edit( mt_head )
        )->ele( `columns`
        )->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = 'Layout'
        )->end(
        )->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = 'Description'
        )->end(
        )->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = 'Active'
        )->end(
        )->end(
        )->ele( `items`
        )->ele( `ColumnListItem`
        )->a( n = `selected` v = '{SELKZ}'
        )->ele( `cells`
        )->tag( `Text`
        )->a( n = `text` v = '{LAYOUT}'
        )->tag( `Text`
        )->a( n = `text` v = '{DESCR}'
        )->tag( `Text`
        )->a( n = `text` v = '{ACTIVE}' ).

    dialog->ele( `buttons`
        )->tag( `Button`
        )->a( n = `text` v = 'Close'
        )->a( n = `icon` v = 'sap-icon://sys-cancel-2'
        )->a( n = `press` v = client->_event( 'CLOSE' )
        )->tag( `Button`
        )->a( n = `text` v = 'Delete'
        )->a( n = `icon` v = 'sap-icon://delete'
        )->a( n = `press` v = client->_event( 'DELETE_SELECT' )
        )->a( n = `type` v = 'Reject' ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD render_open.

    DATA popup TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA dialog TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA content TYPE REF TO z2ui5_cl_ui5_view_builder.
    popup = z2ui5_cl_ui5_view_builder=>factory(
                      )->ele( n = `FragmentDefinition` ns = `core`
                      )->a( n = `xmlns` v = `sap.m`
                      )->a( n = `xmlns:core` v = `sap.ui.core` ).


    dialog = popup->ele( `Dialog`
                       )->a( n = `title` v = 'Select Layout'
                       )->a( n = `contentWidth` v = '80%'
                       )->a( n = `contentHeight` v = '80%'
                       )->a( n = `afterClose` v = client->_event( 'CLOSE' ) ).


    content = render_tabstrip( dialog = dialog
                                     active = 'SELECT' ).

    content->ele( `Table`
        )->a( n = `mode` v = 'SingleSelectLeft'
        )->a( n = `items` v = client->_bind_edit( mt_head )
        )->ele( `columns`
        )->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = 'Layout'
        )->end(
        )->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = 'Active'
        )->end(
        )->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = 'Description'
        )->end(
        )->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = 'Screen Format'
        )->end(
        )->ele( `Column`
        )->tag( `Text`
        )->a( n = `text` v = 'Default'
        )->end(
        )->end(
        )->ele( `items`
        )->ele( `ColumnListItem`
        )->a( n = `selected` v = '{SELKZ}'
        )->ele( `cells`
        )->tag( `Text`
        )->a( n = `text` v = '{LAYOUT}'
        )->tag( `Text`
        )->a( n = `text` v = '{ACTIVE}'
        )->tag( `Text`
        )->a( n = `text` v = '{DESCR}'
        )->tag( `Text`
        )->a( n = `text` v = '{SCREEN_FORMAT}'
        )->tag( `Text`
        )->a( n = `text` v = '{DEF}' ).

    dialog->ele( `buttons`
        )->tag( `Button`
        )->a( n = `text` v = 'Close'
        )->a( n = `icon` v = 'sap-icon://sys-cancel-2'
        )->a( n = `press` v = client->_event( 'CLOSE' )
        )->tag( `Button`
        )->a( n = `text` v = 'OK'
        )->a( n = `icon` v = 'sap-icon://accept'
        )->a( n = `press` v = client->_event( 'OPEN_SELECT' )
        )->a( n = `type` v = 'Emphasized' ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD get_selected_layout.

    DATA temp15 TYPE z2ui5_cl_layo_pop=>ty_s_layo.
    DATA temp16 TYPE z2ui5_cl_layo_pop=>ty_s_layo.
    CLEAR temp15.

    READ TABLE mt_head INTO temp16 WITH KEY selkz = abap_true.
    IF sy-subrc = 0.
      temp15 = temp16.
    ENDIF.
    result = temp15.

  ENDMETHOD.

  METHOD set_selected_layout.

    mo_layout = z2ui5_cl_layo_manager=>factory_by_guid( layout_guid = head-guid
                                                        t_comps     = mo_layout->ms_layout-t_layout
                                                        t_slots     = mo_layout->mt_slots ).

  ENDMETHOD.

  METHOD get_layouts.
    FIELD-SYMBOLS <temp17> TYPE z2ui5_cl_layo_pop=>ty_s_layo.
DATA head LIKE REF TO <temp17>.
      FIELD-SYMBOLS <temp18> TYPE z2ui5_cl_layo_pop=>ty_s_layo.

    mt_head = mo_layout->select_layouts( control  = mo_layout->ms_layout-s_head-control
                                         handle01 = mo_layout->ms_layout-s_head-handle01
                                         handle02 = mo_layout->ms_layout-s_head-handle02
                                         handle03 = mo_layout->ms_layout-s_head-handle03
                                         handle04 = mo_layout->ms_layout-s_head-handle04 ).

    IF mt_head IS INITIAL.
      RETURN.
    ENDIF.


    READ TABLE mt_head WITH KEY guid = mo_layout->ms_layout-s_head-guid ASSIGNING <temp17>.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.

GET REFERENCE OF <temp17> INTO head.
    IF head IS BOUND.
      head->selkz  = abap_true.
      head->active = abap_true.
      RETURN.
    ELSE.

      READ TABLE mt_head INDEX 1 ASSIGNING <temp18>.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.
GET REFERENCE OF <temp18> INTO head.
      head->selkz = abap_true.
    ENDIF.

  ENDMETHOD.

  METHOD init_edit.
    DATA temp1 TYPE xsdboolean.
      DATA head LIKE mo_layout->ms_layout-s_head.

    mv_layout = mo_layout->ms_layout-s_head-layout.
    mv_descr  = mo_layout->ms_layout-s_head-descr.
    mv_def    = mo_layout->ms_layout-s_head-def.
    mv_format = mo_layout->ms_layout-s_head-screen_format.


    temp1 = boolc( mo_layout->ms_layout-s_head-uname IS NOT INITIAL ).
    mv_usr    = temp1.

    " without the authorization for a shared layout the switch starts on
    " user specific - otherwise every first save would be refused
    IF mv_usr = abap_false.

      head = mo_layout->ms_layout-s_head.
      CLEAR head-uname.
      IF z2ui5_cl_layo_auth=>check( action = z2ui5_if_layo_auth=>cs_action-save_shared
                                    head   = head ) = abap_false.
        mv_usr = abap_true.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD on_event_layout.

    IF layout IS NOT BOUND.
      RETURN.
    ENDIF.

    IF layout->ms_layout IS INITIAL.
      RETURN.
    ENDIF.

    IF client->get( )-event = layout->ms_layout-s_head-guid.
      client->nav_app_call( factory( layout = layout ) ).
    ENDIF.

  ENDMETHOD.

  METHOD delete_selected_layout.
    DATA head_db TYPE z2ui5_t_11.
    DATA owner LIKE head_db-uname.
    DATA head_deleted TYPE abap_bool.
    DATA temp2 TYPE xsdboolean.

    " Nothing selected - guid initial would delete unrelated blank-guid rows.
    IF head-guid IS INITIAL.
      client->message_toast_display( 'No layout selected.' ).
      RETURN.
    ENDIF.

    " The head - owner and handles - comes from the database, not from the
    " bound list the browser sends back. Whether the user may delete it is
    " z2ui5_if_layo_auth's decision: the shipped default allows a user to
    " delete his own layouts and nothing else; an implementation in the
    " system may let an administrator remove shared layouts as well

    SELECT SINGLE * FROM z2ui5_t_11 INTO head_db
      WHERE guid = head-guid
      .
    IF sy-subrc <> 0.
      client->message_toast_display( 'Layout could not be deleted.' ).
      RETURN.
    ENDIF.

    owner = head_db-uname.

    IF z2ui5_cl_layo_auth=>check( action = z2ui5_if_layo_auth=>cs_action-delete
                                  head   = head_db ) = abap_false.
      IF owner IS INITIAL.
        client->message_toast_display( 'A shared layout is used by every user and cannot be deleted here.' ).
      ELSEIF owner <> sy-uname.
        client->message_toast_display( 'Only the user who saved this layout can delete it.' ).
      ELSE.
        client->message_toast_display( 'You are not authorized to delete this layout.' ).
      ENDIF.
      RETURN.
    ENDIF.

    DELETE FROM z2ui5_t_11 WHERE guid = head-guid
                             AND uname = owner.
    " Base the outcome on the header delete. The old code only checked the
    " sy-subrc of the position delete, so a layout without position rows
    " (e.g. all columns hidden) was never committed and reappeared.


    temp2 = boolc( sy-subrc = 0 ).
    head_deleted = temp2.

    DELETE FROM z2ui5_t_12 WHERE guid = head-guid.

    IF head_deleted = abap_false.
      client->message_toast_display( 'Layout could not be deleted.' ).
      RETURN.
    ENDIF.

    COMMIT WORK AND WAIT.

    result = abap_true.

    client->message_toast_display( 'Layout deleted.' ).

  ENDMETHOD.

  METHOD check_width_unit.

    IF width IS INITIAL.
      RETURN.
    ENDIF.

    IF width CA '.'.
      FIND REGEX '([0-9]{1,4}\.[0-9]{1})' IN width SUBMATCHES result.
    ELSE.
      FIND REGEX '([0-9]{1,4})' IN width SUBMATCHES result.
    ENDIF.

    IF result CO '0123456789. '.
      result = |{ result }rem|.
    ENDIF.

  ENDMETHOD.

  METHOD render_add_subcolumn.

    DATA lo_popup TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA vbox TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA item TYPE REF TO z2ui5_cl_ui5_view_builder.
    lo_popup = z2ui5_cl_ui5_view_builder=>factory(
                         )->ele( n = `FragmentDefinition` ns = `core`
                         )->a( n = `xmlns` v = `sap.m`
                         )->a( n = `xmlns:core` v = `sap.ui.core` ).

    lo_popup = lo_popup->ele( `Dialog`
                   )->a( n = `afterClose` v = client->_event( 'SUBCOLUMN_CANCEL' )
                   )->a( n = `contentWidth` v = `50%`
                   )->a( n = `title` v = 'Define Subcolumns' ).


    vbox = lo_popup->ele( `VBox`
                     )->a( n = `justifyContent` v = 'SpaceBetween' ).


    item = vbox->ele( `List`
                     )->a( n = `noDataText` v = `No subcolumns defined`
                     )->a( n = `items` v = client->_bind_edit( mo_layout->mt_sub_cols )
                     )->a( n = `selectionChange` v = client->_event( 'SELCHANGE' )
                     )->ele( `CustomListItem` ).

    item->ele( `ComboBox`
        )->a( n = `selectedKey` v = `{FNAME}`
        )->a( n = `items` v = client->_bind( mo_layout->mt_comps  )
        )->tag( n = `Item` ns = `core`
        )->a( n = `key` v = '{FNAME}'
        )->a( n = `text` v = '{FNAME} {TLABEL}'
        )->end(
        )->tag( `Button`
        )->a( n = `icon` v = 'sap-icon://decline'
        )->a( n = `tooltip` v = `Delete`
        )->a( n = `type` v = `Transparent`
        )->a( n = `press` v = client->_event( val = `SUBCOLUMN_DELETE`
                                                arg = `${KEY}` ) ).

    lo_popup->ele( `buttons`
        )->tag( `Button`
        )->a( n = `text` v = `Delete All`
        )->a( n = `icon` v = 'sap-icon://delete'
        )->a( n = `type` v = `Transparent`
        )->a( n = `press` v = client->_event( val = `SUBCOLUMN_DELETE_ALL` )
        )->tag( `Button`
        )->a( n = `text` v = `Add Item`
        )->a( n = `icon` v = `sap-icon://add`
        )->a( n = `press` v = client->_event( val = `SUBCOLUMN_ADD` )
        )->tag( `Button`
        )->a( n = `text` v = 'Cancel'
        )->a( n = `press` v = client->_event( 'SUBCOLUMN_CANCEL' )
        )->tag( `Button`
        )->a( n = `text` v = 'OK'
        )->a( n = `press` v = client->_event( 'SUBCOLUMN_CONFIRM' )
        )->a( n = `type` v = 'Emphasized' ).

    client->popup_display( lo_popup->stringify( ) ).

  ENDMETHOD.

  METHOD on_event_subcolumns.
        DATA arg TYPE string_table.
        DATA temp19 TYPE string.
        DATA temp20 TYPE string.
        DATA layout TYPE REF TO z2ui5_cl_layo_manager=>ty_s_positions.
        DATA temp21 LIKE LINE OF mo_layout->mt_sub_cols.
        DATA line LIKE REF TO temp21.
        DATA temp22 TYPE z2ui5_cl_layo_manager=>ty_s_sub_columns.
        DATA lt_event TYPE string_table.
        FIELD-SYMBOLS <temp23> LIKE LINE OF lt_event.
        DATA temp24 LIKE sy-tabix.
        DATA temp25 TYPE z2ui5_cl_layo_manager=>ty_t_sub_columns.

    CASE client->get( )-event.

      WHEN 'CALL_SUBCOLUMN'.


        arg = client->get( )-t_event_arg.

        CLEAR temp19.

        READ TABLE arg INTO temp20 INDEX 1.
        IF sy-subrc = 0.
          temp19 = temp20.
        ENDIF.
        mv_active_line = temp19.


        READ TABLE mt_layout REFERENCE INTO layout WITH KEY fname = mv_active_line.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        mo_layout->mt_comps    = mo_layout->ms_layout-t_layout.   " Components for DropDownList
        mo_layout->mt_sub_cols = layout->t_sub_col.               " Defined subcolumns

        render_add_subcolumn( ).

      WHEN `SUBCOLUMN_CONFIRM`.

        READ TABLE mt_layout REFERENCE INTO layout WITH KEY fname = mv_active_line.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        CLEAR layout->subcolumn.



        LOOP AT mo_layout->mt_sub_cols REFERENCE INTO line.
          layout->subcolumn = |{ layout->subcolumn } { line->fname }|.
        ENDLOOP.
        SHIFT layout->subcolumn LEFT DELETING LEADING space.

        layout->t_sub_col = mo_layout->mt_sub_cols.

        client->popup_destroy( ).

        update_values( ).
        mt_layout = mo_layout->ms_layout-t_layout.

        init_edit( ).
        render_edit( ).

      WHEN `SUBCOLUMN_CANCEL`.

        update_values( ).
        mt_layout = mo_layout->ms_layout-t_layout.

        init_edit( ).
        render_edit( ).

      WHEN `SUBCOLUMN_ADD`.

        CLEAR temp22.
        temp22-key = z2ui5_cl_util=>uuid_get_c32( ).
        INSERT temp22 INTO TABLE mo_layout->mt_sub_cols.
        client->popup_model_update( ).

      WHEN `SUBCOLUMN_DELETE`.

        lt_event = client->get( )-t_event_arg.


        temp24 = sy-tabix.
        READ TABLE lt_event INDEX 1 ASSIGNING <temp23>.
        sy-tabix = temp24.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        DELETE mo_layout->mt_sub_cols WHERE key = <temp23>.
        client->popup_model_update( ).

      WHEN `SUBCOLUMN_DELETE_ALL`.

        CLEAR temp25.
        mo_layout->mt_sub_cols = temp25.
        client->popup_model_update( ).

    ENDCASE.

  ENDMETHOD.

  METHOD check_rerender_necessary.
    DATA layout LIKE LINE OF mo_layout->ms_layout-t_layout.
      DATA layout_tmp TYPE z2ui5_cl_layo_manager=>ty_s_positions.

    CLEAR mv_rerender.

    " Sequence and SubCols need rerendering

    LOOP AT mo_layout->ms_layout-t_layout INTO layout.


      READ TABLE mo_layout->ms_layout_tmp-t_layout INTO layout_tmp
           WITH KEY guid     = layout-guid
                    pos_guid = layout-pos_guid.

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      IF layout-alternative_text <> layout_tmp-alternative_text.
        mv_rerender = abap_true.
        RETURN.
      ENDIF.

      " the generic mode binds nothing - every change is written into the view
      IF mo_layout->ms_layout-s_head-control = z2ui5_cl_layo_manager=>generic.
        IF layout-visible <> layout_tmp-visible OR layout-width <> layout_tmp-width.
          mv_rerender = abap_true.
          RETURN.
        ENDIF.
      ENDIF.

      IF layout-sequence <> layout_tmp-sequence.
        mv_rerender = abap_true.
        RETURN.
      ENDIF.

      IF layout-t_sub_col <> layout_tmp-t_sub_col.
        mv_rerender = abap_true.
        RETURN.
      ENDIF.

      IF layout-reference_field <> layout_tmp-reference_field.
        mv_rerender = abap_true.
        RETURN.
      ENDIF.

      IF    layout-grid_value_xl <> layout_tmp-grid_value_xl
         OR layout-grid_value_l  <> layout_tmp-grid_value_l
         OR layout-grid_value_m  <> layout_tmp-grid_value_m
         OR layout-grid_value_s  <> layout_tmp-grid_value_s.
        mv_rerender = abap_true.
        RETURN.
      ENDIF.

      IF    layout-grid_label_xl <> layout_tmp-grid_label_xl
         OR layout-grid_label_l  <> layout_tmp-grid_label_l
         OR layout-grid_label_m  <> layout_tmp-grid_label_m
         OR layout-grid_label_s  <> layout_tmp-grid_label_s.
        mv_rerender = abap_true.
        RETURN.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD on_event_gridlayout.
        DATA arg TYPE string_table.
        DATA temp26 TYPE string.
        DATA temp27 TYPE string.
        DATA layout TYPE REF TO z2ui5_cl_layo_manager=>ty_s_positions.

    CASE client->get( )-event.

      WHEN 'CALL_GRIDLAYOUT'.


        arg = client->get( )-t_event_arg.

        CLEAR temp26.

        READ TABLE arg INTO temp27 INDEX 1.
        IF sy-subrc = 0.
          temp26 = temp27.
        ENDIF.
        mv_active_line = temp26.


        READ TABLE mo_layout->ms_layout-t_layout REFERENCE INTO layout WITH KEY fname = mv_active_line.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        mv_xl_value = layout->grid_value_xl.
        mv_l_value = layout->grid_value_l.
        mv_m_value = layout->grid_value_m.
        mv_s_value = layout->grid_value_s.

        mv_xl_label = layout->grid_label_xl.
        mv_l_label  = layout->grid_label_l.
        mv_m_label  = layout->grid_label_m.
        mv_s_label  = layout->grid_label_s.

        render_add_gridlayout( ).

      WHEN `GRIDLAYOUT_CONFIRM`.

        IF NOT (    check_grid_sum( mv_xl_label + mv_xl_value ) = abap_true
                 OR check_grid_sum( mv_l_label + mv_l_value )  = abap_true
                 OR check_grid_sum( mv_m_label + mv_m_value )  = abap_true
                 OR check_grid_sum( mv_s_label + mv_s_value )  = abap_true ).

          READ TABLE mo_layout->ms_layout-t_layout REFERENCE INTO layout WITH KEY fname = mv_active_line.
          IF sy-subrc <> 0.
            RETURN.
          ENDIF.

          layout->grid_value_xl = mv_xl_value.
          layout->grid_value_l  = mv_l_value.
          layout->grid_value_m  = mv_m_value.
          layout->grid_value_s  = mv_s_value.

          layout->grid_label_xl = mv_xl_label.
          layout->grid_label_l  = mv_l_label.
          layout->grid_label_m  = mv_m_label.
          layout->grid_label_s  = mv_s_label.

          mt_layout = mo_layout->ms_layout-t_layout.

          init_edit( ).
          render_edit( ).

        ENDIF.

      WHEN `GRIDLAYOUT_CANCEL`.

        init_edit( ).
        render_edit( ).

    ENDCASE.

  ENDMETHOD.

  METHOD check_grid_sum.

    IF value > 12.

      result = abap_true.

      client->message_toast_display( 'Maximum number of columns (12) exceeded' ).

    ENDIF.

  ENDMETHOD.

  METHOD render_add_gridlayout.

    DATA temp28 LIKE t_col.
    DATA temp29 LIKE LINE OF temp28.
    DATA lo_popup TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA form TYPE REF TO z2ui5_cl_ui5_view_builder.
    CLEAR temp28.

    temp29-col = 1.
    INSERT temp29 INTO TABLE temp28.
    temp29-col = 2.
    INSERT temp29 INTO TABLE temp28.
    temp29-col = 3.
    INSERT temp29 INTO TABLE temp28.
    temp29-col = 4.
    INSERT temp29 INTO TABLE temp28.
    temp29-col = 5.
    INSERT temp29 INTO TABLE temp28.
    temp29-col = 6.
    INSERT temp29 INTO TABLE temp28.
    temp29-col = 7.
    INSERT temp29 INTO TABLE temp28.
    temp29-col = 8.
    INSERT temp29 INTO TABLE temp28.
    temp29-col = 9.
    INSERT temp29 INTO TABLE temp28.
    temp29-col = 10.
    INSERT temp29 INTO TABLE temp28.
    temp29-col = 11.
    INSERT temp29 INTO TABLE temp28.
    temp29-col = 12.
    INSERT temp29 INTO TABLE temp28.
    t_col = temp28.


    lo_popup = z2ui5_cl_ui5_view_builder=>factory(
                         )->ele( n = `FragmentDefinition` ns = `core`
                         )->a( n = `xmlns` v = `sap.m`
                         )->a( n = `xmlns:core` v = `sap.ui.core`
                         )->a( n = `xmlns:form` v = `sap.ui.layout.form` ).

    lo_popup = lo_popup->ele( `Dialog`
                   )->a( n = `afterClose` v = client->_event( 'GRIDLAYOUT_CANCEL' )
                   )->a( n = `contentWidth` v = `140px`
                   )->a( n = `title` v = 'Grid Layout' ).


    form = lo_popup->ele( n = `SimpleForm` ns = `form`
                     )->a( n = `editable` b = abap_true
                     )->a( n = `title` v = 'Define Label and Value Span'
                     )->ele( n = `content` ns = `form` ).

    form->tag( `Label`
        )->a( n = `text` v = 'XL'
        )->ele( `ComboBox`
        )->a( n = `selectedKey` v = client->_bind_edit( mv_xl_label )
        )->a( n = `width` v = `7rem`
        )->a( n = `items` v = client->_bind( t_col  )
        )->tag( n = `Item` ns = `core`
        )->a( n = `key` v = '{COL}'
        )->a( n = `text` v = '{COL} Label Span' ).

    form->ele( `ComboBox`
        )->a( n = `selectedKey` v = client->_bind_edit( mv_xl_value )
        )->a( n = `width` v = `7rem`
        )->a( n = `items` v = client->_bind( t_col  )
        )->tag( n = `Item` ns = `core`
        )->a( n = `key` v = '{COL}'
        )->a( n = `text` v = '{COL} Value Span' ).

    form->tag( `Label`
        )->a( n = `text` v = 'L'
        )->ele( `ComboBox`
        )->a( n = `selectedKey` v = client->_bind_edit( mv_l_label )
        )->a( n = `width` v = `7rem`
        )->a( n = `items` v = client->_bind( t_col  )
        )->tag( n = `Item` ns = `core`
        )->a( n = `key` v = '{COL}'
        )->a( n = `text` v = '{COL} Label Span' ).

    form->ele( `ComboBox`
        )->a( n = `selectedKey` v = client->_bind_edit( mv_l_value )
        )->a( n = `width` v = `7rem`
        )->a( n = `items` v = client->_bind( t_col  )
        )->tag( n = `Item` ns = `core`
        )->a( n = `key` v = '{COL}'
        )->a( n = `text` v = '{COL} Value Span' ).

    form->tag( `Label`
        )->a( n = `text` v = 'M'
        )->ele( `ComboBox`
        )->a( n = `selectedKey` v = client->_bind_edit( mv_m_label )
        )->a( n = `width` v = `7rem`
        )->a( n = `items` v = client->_bind( t_col  )
        )->tag( n = `Item` ns = `core`
        )->a( n = `key` v = '{COL}'
        )->a( n = `text` v = '{COL} Label Span' ).

    form->ele( `ComboBox`
        )->a( n = `selectedKey` v = client->_bind_edit( mv_m_value )
        )->a( n = `width` v = `7rem`
        )->a( n = `items` v = client->_bind( t_col  )
        )->tag( n = `Item` ns = `core`
        )->a( n = `key` v = '{COL}'
        )->a( n = `text` v = '{COL} Value Span' ).

    form->tag( `Label`
        )->a( n = `text` v = 'S'
        )->ele( `ComboBox`
        )->a( n = `selectedKey` v = client->_bind_edit( mv_s_label )
        )->a( n = `width` v = `7rem`
        )->a( n = `items` v = client->_bind( t_col  )
        )->tag( n = `Item` ns = `core`
        )->a( n = `key` v = '{COL}'
        )->a( n = `text` v = '{COL} Label Span' ).

    form->ele( `ComboBox`
        )->a( n = `selectedKey` v = client->_bind_edit( mv_s_value )
        )->a( n = `width` v = `7rem`
        )->a( n = `items` v = client->_bind( t_col  )
        )->tag( n = `Item` ns = `core`
        )->a( n = `key` v = '{COL}'
        )->a( n = `text` v = '{COL} Value Span' ).

    lo_popup->ele( `buttons`
        )->tag( `Button`
        )->a( n = `text` v = 'Cancel'
        )->a( n = `press` v = client->_event( 'GRIDLAYOUT_CANCEL' )
        )->tag( `Button`
        )->a( n = `text` v = 'OK'
        )->a( n = `press` v = client->_event( 'GRIDLAYOUT_CONFIRM' )
        )->a( n = `type` v = 'Emphasized' ).

    client->popup_display( lo_popup->stringify( ) ).

  ENDMETHOD.

  METHOD update_values.

    DATA temp30 LIKE LINE OF mo_layout->ms_layout-t_layout.
    DATA line LIKE REF TO temp30.
      DATA temp31 TYPE z2ui5_cl_layo_manager=>ty_s_positions.
      DATA temp32 TYPE z2ui5_cl_layo_manager=>ty_s_positions.
      DATA layout LIKE temp31.
    LOOP AT mo_layout->ms_layout-t_layout REFERENCE INTO line.


      CLEAR temp31.

      READ TABLE mt_layout INTO temp32 WITH KEY pos_guid = line->pos_guid.
      IF sy-subrc = 0.
        temp31 = temp32.
      ENDIF.

      layout = temp31.
      IF layout IS NOT INITIAL.
        line->* = layout.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
