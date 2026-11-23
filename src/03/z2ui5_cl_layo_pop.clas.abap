CLASS z2ui5_cl_layo_pop DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_sorting,
        sorting TYPE string,
        descr   TYPE string,
      END OF ty_s_sorting.
    TYPES ty_t_sorting TYPE STANDARD TABLE OF ty_s_sorting WITH EMPTY KEY.

    TYPES BEGIN OF ty_s_layo.
            INCLUDE TYPE z2ui5_t_11.
    TYPES   selkz  TYPE abap_bool.
    TYPES   active TYPE c LENGTH 1.
    TYPES END OF ty_s_layo.
    TYPES ty_t_layo TYPE STANDARD TABLE OF ty_s_layo WITH EMPTY KEY.

    TYPES: BEGIN OF ty_s_col,
             col TYPE c LENGTH 2,
           END OF ty_s_col.

    DATA t_col          TYPE STANDARD TABLE OF ty_s_col WITH EMPTY KEY.

    DATA mo_layout      TYPE REF TO z2ui5_cl_layo_manager.
    DATA mt_controls    TYPE z2ui5_cl_layo_manager=>ty_t_controls.
    DATA mt_layout      TYPE z2ui5_cl_layo_manager=>ty_t_positions.

    DATA mt_head        TYPE ty_t_layo.
    DATA mv_descr       TYPE string.
    DATA mv_layout      TYPE string.
    DATA mv_def         TYPE abap_bool.
    DATA mv_usr         TYPE abap_bool.
    DATA mv_format      TYPE string.
    DATA mv_open        TYPE abap_bool.
    DATA mv_delete      TYPE abap_bool.
    DATA mt_sorting     TYPE ty_t_sorting.
    DATA mv_active_line TYPE string.
    DATA mv_rerender    TYPE abap_bool.
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
    DATA client TYPE REF TO z2ui5_if_client.

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
        active        TYPE string
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_view_builder.

    METHODS render_add_subcolumn.
    METHODS on_event_subcoloumns.
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

    METHODS Edit_okay.
    METHODS Search.

ENDCLASS.


CLASS z2ui5_cl_layo_pop IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    me->client = client.

    IF client->check_on_init( ).
      on_init( ).
      init_edit( ).
      render_edit( ).
    ELSEIF client->check_on_event( ).
      update_values( ).
      on_event( ).
    ENDIF.

  ENDMETHOD.

  METHOD on_init.

    IF mt_controls IS INITIAL.
      mt_controls = z2ui5_cl_layo_manager=>get_controls( ).

      mt_sorting = VALUE #( ( sorting = 'ASCENDING' descr = 'Ascending'  )
                            ( sorting = 'DESCENDING' descr = 'Descending'  )
                            ( sorting = `` descr = ``  ) ).

    ENDIF.

  ENDMETHOD.

  METHOD render_edit.

    DATA(popup) = z2ui5_cl_ui5_view_builder=>factory(
        )->ele( n = `FragmentDefinition` ns = `core`
            )->a( n = `xmlns`      v = `sap.m`
            )->a( n = `xmlns:core` v = `sap.ui.core` ).

    DATA(dialog) = popup->ele( `Dialog`
        )->a( n = `title`         v = `Edit Layout`
        )->a( n = `contentWidth`  v = `80%`
        )->a( n = `contentHeight` v = `80%`
        )->a( n = `afterClose`    v = client->_event( 'CLOSE' ) ).

    DATA(content) = render_tabstrip( dialog = dialog
                                     active = 'EDIT' ).

    DATA(tab) = content->ele( `Table`
        )->a( n = `items`            v = client->_bind( mt_layout )
        )->a( n = `growing`          b = abap_true
        )->a( n = `growingThreshold` v = `80`
        )->a( n = `sticky`           v = `ColumnHeaders` ).

    tab->ele( `headerToolbar`
        )->ele( `OverflowToolbar`

            )->tag( `ToolbarSpacer`
            )->tag( `SearchField`
                )->a( n = `width`       v = `17.5rem`
                )->a( n = `placeholder` t = |{ z2ui5_cl_layo_util=>rtti_get_data_element_texts( 'ROLLNAME' )-long
                                             }/{
                                               z2ui5_cl_layo_util=>rtti_get_data_element_texts( 'NAME_FELD' )-long }|
                )->a( n = `liveChange`  v = client->_event( val    = 'BUTTON_SEARCH'
                                                            t_arg  = VALUE #( ( `${$source>/value}` ) )
                                                            s_ctrl = VALUE #( check_queue_last = abap_true
                                                                              check_no_busy    = abap_true ) ) ).

    DATA(cells) = tab->ele( `ColumnListItem`
        )->ele( `cells` ).

    DATA(columns) = tab->ele( `columns` ).

    " only the components of the position type are read here - the sorted
    " copy of the layout this used to describe was never displayed
    DATA(lt_comp) = z2ui5_cl_layo_util=>rtti_get_t_attri_by_any( mt_layout ).

    LOOP AT mt_controls REFERENCE INTO DATA(control) WHERE control = mo_layout->ms_layout-s_head-control.

      READ TABLE lt_comp INTO DATA(comp) WITH KEY name = control->attribute.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      DATA(col_width) = ``.
      DATA(col_text) = ``.

      CASE control->attribute.
        WHEN 'TLABEL'.
          col_width = `15%`.
          col_text  = `Row`.
        WHEN 'VISIBLE'.
          col_width = `10%`.
          col_text  = `Visible`.
        WHEN 'MERGE'.
          col_width = `10%`.
          col_text  = `Merge`.
        WHEN 'WIDTH'.
          col_width = `10%`.
          col_text  = `Width in rem`.
        WHEN 'SEQUENCE'.
          col_width = `10%`.
          col_text  = `Sequence`.
        WHEN 'ALTERNATIVE_TEXT'.
          col_width = `10%`.
          col_text  = `Alternative Text`.
        WHEN 'REFERENCE_FIELD'.
          col_width = `10%`.
          col_text  = `Reference Field`.
        WHEN 'SUBCOLUMN'.
          col_width = `15%`.
          col_text  = `Subcolumn`.
        WHEN 'GRID_LAYOUT'.
          col_width = `5%`.
          col_text  = `Layout`.
        WHEN 'NO_CONVEXIT'.
          col_width = `10%`.
          col_text  = `No Conversion Exit`.
        WHEN 'SORTING'.
          col_width = `10%`.
          col_text  = `Sorting`.
        WHEN OTHERS.
          CONTINUE.
      ENDCASE.

      columns->ele( `Column`
          )->a( n = `width` v = col_width
          )->ele( `header`
              )->tag( `Text`
                  )->a( n = `text` t = col_text ).

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
              )->a( n = `type`  v = `AcceptReject`
              )->a( n = `state` v = |\{{ comp-name }\}| ).

        WHEN 'NO_CONVEXIT'.

          cells->ele( `VBox`
              )->a( n = `visible` v = |\{SHOW_CONVEXIT\}|

              )->tag( `Switch`
                  )->a( n = `state`         v = |\{{ comp-name }\}|
                  )->a( n = `customTextOff` v = |\{CONVEXIT\}|
                  )->a( n = `customTextOn`  v = |\{CONVEXIT\}| ).

        WHEN 'WIDTH'.

          cells->tag( `Input`
              )->a( n = `maxLength` v = `6`
              )->a( n = `value`     v = |\{{ comp-name }\}|
              )->a( n = `width`     v = `4rem` ).

        WHEN 'SEQUENCE'.

          cells->tag( `Input`
              )->a( n = `type`      v = `Number`
              )->a( n = `maxLength` v = `3`
              )->a( n = `value`     v = |\{{ comp-name }\}|
              )->a( n = `width`     v = `3rem` ).

        WHEN 'ALTERNATIVE_TEXT'.

          cells->tag( `Input`
              )->a( n = `value` v = |\{{ comp-name }\}| ).

        WHEN 'SUBCOLUMN'.

          cells->tag( `Button`
              )->a( n = `press` v = client->_event( val   = 'CALL_SUBCOLUMN'
                                                    t_arg = VALUE #( ( `${FNAME}` ) ) )
              )->a( n = `text`  v = |\{{ comp-name }\}|
              )->a( n = `icon`  v = `sap-icon://add`
              )->a( n = `width` v = `100%` ).

        WHEN 'SORTING'.

          cells->ele( `ComboBox`
              )->a( n = `selectedKey` v = |\{{ comp-name }\}|
              )->a( n = `items`       v = client->_bind( mt_sorting )
              )->a( n = `width`       v = `5rem`

              )->tag( n = `Item` ns = `core`
                  )->a( n = `key`  v = `{SORTING}`
                  )->a( n = `text` v = `{DESCR}` ).

        WHEN 'REFERENCE_FIELD'.

          cells->ele( `ComboBox`
              )->a( n = `selectedKey` v = |\{{ comp-name }\}|
              )->a( n = `items`       v = client->_bind( mo_layout->ms_layout-t_layout )
              )->a( n = `width`       v = `10rem`

              )->tag( n = `Item` ns = `core`
                  )->a( n = `key`  v = `{FNAME}`
                  )->a( n = `text` v = `{FNAME} - {TLABEL}` ).

        WHEN 'GRID_LAYOUT'.

          cells->tag( `Button`
              )->a( n = `press` v = client->_event( val   = 'CALL_GRIDLAYOUT'
                                                    t_arg = VALUE #( ( `${FNAME}` ) ) )
              )->a( n = `text`  v = |\{{ comp-name }\}|
              )->a( n = `icon`  v = `sap-icon://grid`
              )->a( n = `width` v = `5rem` ).

      ENDCASE.

    ENDLOOP.

    dialog->ele( `buttons`

        )->tag( `Button`
            )->a( n = `press` v = client->_event( 'CLOSE' )
            )->a( n = `text`  v = `Close`
            )->a( n = `icon`  v = `sap-icon://sys-cancel-2`
        )->tag( `Button`
            )->a( n = `press` v = client->_event( 'EDIT_OKAY' )
            )->a( n = `text`  v = `Okay`
            )->a( n = `icon`  v = `sap-icon://accept`
        )->tag( `Button`
            )->a( n = `press` v = client->_event( 'EDIT_SAVE' )
            )->a( n = `text`  v = `Save`
            )->a( n = `icon`  v = `sap-icon://save`
            )->a( n = `type`  v = `Emphasized` ).

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

        Edit_okay( ).

      WHEN 'BUTTON_SEARCH'.

        Search( ).

      WHEN 'CLOSE'.

        mo_layout->ms_layout = mo_layout->ms_layout_tmp.

        client->popup_destroy( ).

        client->nav_app_leave( ).

      WHEN 'EDIT_SAVE'.

        render_save( ).

      WHEN 'SAVE_CLOSE'.

        client->popup_destroy( ).

        render_edit( ).

      WHEN 'SAVE_SAVE'.

        " Only leave the save dialog when the layout was really persisted,
        " so a failed save (e.g. missing name) keeps the dialog open.
        IF save_layout( ) = abap_true.
          Edit_okay( ).
        ENDIF.

      WHEN 'OPEN_SELECT'.

        " nothing selected (or no layout at all): loading guid '' gave a
        " layout without head - no control, no handles, nothing to save to
        DATA(selected) = get_selected_layout( ).
        IF selected-guid IS INITIAL.
          client->message_toast_display( 'No layout selected.' ).
          RETURN.
        ENDIF.

        set_selected_layout( selected ).

        mv_rerender = abap_true.

        client->popup_destroy( ).

        client->nav_app_leave( ).

      WHEN 'DELETE_SELECT'.

        " Only remove the row from the list when the delete was committed,
        " otherwise the layout would reappear on the next selection.
        IF delete_selected_layout( get_selected_layout( ) ) = abap_true.
          DELETE mt_head WHERE selkz = abap_true.
        ENDIF.

      WHEN OTHERS.

        on_event_subcoloumns( ).

        on_event_gridlayout( ).

    ENDCASE.

  ENDMETHOD.

  METHOD Search.

    DATA(search_value) = client->get_event_arg( ).

    mt_layout = mo_layout->ms_layout-t_layout.

    LOOP AT mt_layout REFERENCE INTO DATA(row).
      IF |{ row->fname }{ row->rollname }{ row->tlabel }| NS search_value.
        DELETE mt_layout.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD Edit_okay.

    LOOP AT mo_layout->ms_layout-t_layout REFERENCE INTO DATA(layout).
      layout->tlabel           = mo_layout->set_text( layout->* ).
      layout->alternative_text = to_upper( layout->alternative_text ).
      layout->width            = check_width_unit( layout->width ).
    ENDLOOP.

    mo_layout->ms_layout-t_layout = mo_layout->sort_by_seqence( mo_layout->ms_layout-t_layout ).

    check_rerender_necessary( ).

    client->popup_destroy( ).

    client->nav_app_leave( ).

  ENDMETHOD.

  METHOD factory.

    result = NEW #( ).

    result->mo_layout = layout.

    result->mt_layout = layout->ms_layout-t_layout.

    result->mv_open   = open_layout.
    result->mv_delete = delete_layout.

    result->mo_layout->ms_layout_tmp = result->mo_layout->ms_layout.

  ENDMETHOD.

  METHOD render_layout_function.

    result = xml->tag( `Button`
        )->a( n = `press` v = client->_event( layout->ms_layout-s_head-guid )
        )->a( n = `icon`  v = `sap-icon://action-settings` ).

  ENDMETHOD.

  METHOD render_save.

    DATA(popup) = z2ui5_cl_ui5_view_builder=>factory(
        )->ele( n = `FragmentDefinition` ns = `core`
            )->a( n = `xmlns`      v = `sap.m`
            )->a( n = `xmlns:core` v = `sap.ui.core`
            )->a( n = `xmlns:form` v = `sap.ui.layout.form` ).

    DATA(dialog) = popup->ele( `Dialog`
        )->a( n = `title`        v = `Save`
        )->a( n = `contentWidth` v = `80%`
        )->a( n = `afterClose`   v = client->_event( 'SAVE_CLOSE' ) ).

    DATA(form) = dialog->ele( `content`
        )->ele( n = `SimpleForm` ns = `form`
            )->a( n = `title`                   v = `Layout`
            )->a( n = `emptySpanL`              v = `0`
            )->a( n = `emptySpanM`              v = `0`
            )->a( n = `emptySpanS`              v = `0`
            )->a( n = `emptySpanXL`             v = `0`
            )->a( n = `labelSpanL`              v = `4`
            )->a( n = `labelSpanM`              v = `4`
            )->a( n = `labelSpanS`              v = `4`
            )->a( n = `labelSpanXL`             v = `4`
            )->a( n = `singleContainerFullSize` v = `true`
            )->a( n = `columnsXL`               v = `2`
            )->a( n = `columnsL`                v = `2`
            )->a( n = `columnsM`                v = `2`
            )->a( n = `editable`                b = abap_true ).

    " ONE content aggregation: a second form:content tag replaces the first,
    " and a Toolbar beside it lands in content anyway. In content, each
    " Toolbar opens a new form container - the two sections of the form
    form->ele( n = `content` ns = `form`
        )->ele( `Toolbar`
            )->tag( `Title`
                )->a( n = `text` v = `Layout`

        )->end(
        )->tag( `Label`
            )->a( n = `text` v = `Layout`
        )->tag( `Input`
            )->a( n = `maxLength` v = `10`
            )->a( n = `value`     v = client->_bind( mv_layout )
        )->tag( `Label`
            )->a( n = `text` v = `Description`
        )->tag( `Input`
            )->a( n = `value` v = client->_bind( mv_descr )
        )->ele( `Toolbar`
            )->tag( `Title`
                )->a( n = `text` v = `Save Options`

        )->end(
        )->tag( `Label`
            )->a( n = `text` v = `Default Layout`
        )->tag( `Switch`
            )->a( n = `type`  v = `AcceptReject`
            )->a( n = `state` v = client->_bind( mv_def )
        )->tag( `Label`
            )->a( n = `text` v = `User specific`
        )->tag( `Switch`
            )->a( n = `type`  v = `AcceptReject`
            )->a( n = `state` v = client->_bind( mv_usr )
        )->tag( `Label`
            )->a( n = `text` v = `Screen Size`
        )->ele( `ComboBox`
            )->a( n = `selectedKey` v = client->_bind( mv_format )

            )->tag( n = `Item` ns = `core`
                )->a( n = `key`  v = z2ui5_cl_layo_manager=>screen_format_l
                )->a( n = `text` v = `Large  - Terminal`
            )->tag( n = `Item` ns = `core`
                )->a( n = `key`  v = z2ui5_cl_layo_manager=>screen_format_s
                )->a( n = `text` v = `Small - Handheld` ).

    dialog->ele( `buttons`

        )->tag( `Button`
            )->a( n = `press` v = client->_event( 'SAVE_CLOSE' )
            )->a( n = `text`  v = `Back`
            )->a( n = `icon`  v = `sap-icon://nav-back`
        )->tag( `Button`
            )->a( n = `press` v = client->_event( 'SAVE_SAVE' )
            )->a( n = `text`  v = `Save`
            )->a( n = `icon`  v = `sap-icon://save`
            )->a( n = `type`  v = `Accept` ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD save_layout.

    DATA position  TYPE z2ui5_t_12.
    DATA positions TYPE STANDARD TABLE OF z2ui5_t_12 WITH EMPTY KEY.

    IF mv_layout IS INITIAL.
      client->message_toast_display( 'Layout name missing.' ).
      RETURN.
    ENDIF.

    IF mv_usr = abap_true.
      DATA(user) = sy-uname.
    ENDIF.

    DATA(head) = VALUE z2ui5_t_11( guid          = mo_layout->ms_layout-s_head-guid
                                   layout        = mv_layout
                                   control       = mo_layout->ms_layout-s_head-control
                                   handle01      = mo_layout->ms_layout-s_head-handle01
                                   handle02      = mo_layout->ms_layout-s_head-handle02
                                   handle03      = mo_layout->ms_layout-s_head-handle03
                                   handle04      = mo_layout->ms_layout-s_head-handle04
                                   screen_format = mv_format
                                   descr         = mv_descr
                                   def           = mv_def
                                   uname         = user ).

    SELECT SINGLE guid,
                  layout,
                  control,
                  handle01,
                  handle02,
                  handle03,
                  handle04,
                  screen_format

      FROM z2ui5_t_11
      WHERE guid = @head-guid
      INTO @DATA(head_db).

    IF sy-subrc = 0.

      " found entry.
      IF     head_db-layout        = head-layout
         AND head_db-control       = head-control
         AND head_db-handle01      = head-handle01
         AND head_db-handle02      = head-handle02
         AND head_db-handle03      = head-handle03
         AND head_db-handle04      = head-handle04
         AND (    head_db-screen_format = head-screen_format
               " a layout saved before the screen format existed is read
               " back under the requested format - it is the same layout
               OR head_db-screen_format IS INITIAL ).
        " Save Changes

      ELSE.

        " Save New Layout - new Guid
        TRY.
            head-guid = cl_system_uuid=>create_uuid_c32_static( ).
          CATCH cx_root.
        ENDTRY.

      ENDIF.

    ENDIF.

    LOOP AT mo_layout->ms_layout-t_layout REFERENCE INTO DATA(r_layout).
      r_layout->guid = head-guid.

      MOVE-CORRESPONDING r_layout->* TO position.
      position-width = check_width_unit( position-width ).

      " only visible/ref_fields/SubCols should be saved.
      IF r_layout->visible = abap_true.
        APPEND position TO positions.
        CONTINUE.
      ENDIF.

      IF line_exists( mo_layout->ms_layout-t_layout[ reference_field = r_layout->fname ] ).
        APPEND position TO positions.
        CONTINUE.
      ENDIF.

      " a hidden field can be the subcolumn of several columns - append it
      " only once, otherwise duplicate POS_GUID keys break the array MODIFY
      LOOP AT mo_layout->ms_layout-t_layout INTO DATA(layout) WHERE t_sub_col IS NOT INITIAL.
        IF line_exists( layout-t_sub_col[ fname = r_layout->fname ] ).
          APPEND position TO positions.
          EXIT.
        ENDIF.
      ENDLOOP.

    ENDLOOP.

    " Persist head and positions in a single LUW. Do not rely on the
    " array-MODIFY sy-subrc for the commit decision: it is 4 for an empty
    " position table, which would silently skip the COMMIT.
    MODIFY z2ui5_t_11 FROM @head.
    IF sy-subrc <> 0.
      ROLLBACK WORK.
      client->message_toast_display( 'Layout could not be saved.' ).
      RETURN.
    ENDIF.

    DELETE FROM z2ui5_t_12 WHERE guid = @head-guid.

    IF positions IS NOT INITIAL.
      MODIFY z2ui5_t_12 FROM TABLE @positions.
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
      UPDATE z2ui5_t_11 SET def = @abap_false WHERE control        = @head-control
                                                AND handle01       = @head-handle01
                                                AND handle02       = @head-handle02
                                                AND handle03       = @head-handle03
                                                AND handle04       = @head-handle04
                                                AND screen_format  = @head-screen_format
                                                AND uname          = @head-uname
                                                AND def            = @abap_true
                                                AND guid          <> @head-guid.
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

    " Remember the active tab - it is two-way bound to the IconTabBar
    " selectedKey, so a tab click sends the new key back in mv_tab.
    mv_tab = active.

    DATA(bar) = dialog->ele( `IconTabBar`
        )->a( n = `select`               v = client->_event( 'TAB_SELECT' )
        )->a( n = `expandable`           b = abap_false
        )->a( n = `stretchContentHeight` b = abap_true
        )->a( n = `selectedKey`          v = client->_bind( mv_tab ) ).

    bar->ele( `items`
        )->tag( `IconTabFilter`
            )->a( n = `icon` v = `sap-icon://edit`
            )->a( n = `text` v = `Edit`
            )->a( n = `key`  v = `EDIT`
        )->tag( `IconTabFilter`
            )->a( n = `icon` v = `sap-icon://open-folder`
            )->a( n = `text` v = `Select`
            )->a( n = `key`  v = `SELECT`
        )->tag( `IconTabFilter`
            )->a( n = `icon` v = `sap-icon://delete`
            )->a( n = `text` v = `Delete`
            )->a( n = `key`  v = `DELETE` ).

    " The screen content lives in the bar-level content aggregation and is
    " swapped by the server when a different tab is selected.
    result = bar->ele( `content` ).

  ENDMETHOD.

  METHOD render_delete.

    DATA(popup) = z2ui5_cl_ui5_view_builder=>factory(
        )->ele( n = `FragmentDefinition` ns = `core`
            )->a( n = `xmlns`      v = `sap.m`
            )->a( n = `xmlns:core` v = `sap.ui.core` ).

    DATA(dialog) = popup->ele( `Dialog`
        )->a( n = `title`         v = `Delete Layout`
        )->a( n = `contentWidth`  v = `80%`
        )->a( n = `contentHeight` v = `80%`
        )->a( n = `afterClose`    v = client->_event( 'CLOSE' ) ).

    DATA(content) = render_tabstrip( dialog = dialog
                                     active = 'DELETE' ).

    content->ele( `Table`
        )->a( n = `items` v = client->_bind( mt_head )
        )->a( n = `mode`  v = `SingleSelectLeft`

        )->ele( `columns`
            )->ele( `Column`
                )->tag( `Text`
                    )->a( n = `text` v = `Layout`

            )->end(
            )->ele( `Column`
                )->tag( `Text`
                    )->a( n = `text` v = `Description`

            )->end(
            )->ele( `Column`
                )->tag( `Text`
                    )->a( n = `text` v = `Active`

            )->end(
        )->end(
        )->ele( `items`
            )->ele( `ColumnListItem`
                )->a( n = `selected` v = `{SELKZ}`

                )->ele( `cells`

                    )->tag( `Text`
                        )->a( n = `text` v = `{LAYOUT}`
                    )->tag( `Text`
                        )->a( n = `text` v = `{DESCR}`
                    )->tag( `Text`
                        )->a( n = `text` v = `{ACTIVE}` ).

    dialog->ele( `buttons`

        )->tag( `Button`
            )->a( n = `press` v = client->_event( 'CLOSE' )
            )->a( n = `text`  v = `Close`
            )->a( n = `icon`  v = `sap-icon://sys-cancel-2`
        )->tag( `Button`
            )->a( n = `press` v = client->_event( 'DELETE_SELECT' )
            )->a( n = `text`  v = `Delete`
            )->a( n = `icon`  v = `sap-icon://delete`
            )->a( n = `type`  v = `Reject` ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD render_open.

    DATA(popup) = z2ui5_cl_ui5_view_builder=>factory(
        )->ele( n = `FragmentDefinition` ns = `core`
            )->a( n = `xmlns`      v = `sap.m`
            )->a( n = `xmlns:core` v = `sap.ui.core` ).

    DATA(dialog) = popup->ele( `Dialog`
        )->a( n = `title`         v = `Select Layout`
        )->a( n = `contentWidth`  v = `80%`
        )->a( n = `contentHeight` v = `80%`
        )->a( n = `afterClose`    v = client->_event( 'CLOSE' ) ).

    DATA(content) = render_tabstrip( dialog = dialog
                                     active = 'SELECT' ).

    content->ele( `Table`
        )->a( n = `items` v = client->_bind( mt_head )
        )->a( n = `mode`  v = `SingleSelectLeft`

        )->ele( `columns`
            )->ele( `Column`
                )->tag( `Text`
                    )->a( n = `text` v = `Layout`

            )->end(
            )->ele( `Column`
                )->tag( `Text`
                    )->a( n = `text` v = `Active`

            )->end(
            )->ele( `Column`
                )->tag( `Text`
                    )->a( n = `text` v = `Description`

            )->end(
            )->ele( `Column`
                )->tag( `Text`
                    )->a( n = `text` v = `Screen Format`

            )->end(
            )->ele( `Column`
                )->tag( `Text`
                    )->a( n = `text` v = `Default`

            )->end(
        )->end(
        )->ele( `items`
            )->ele( `ColumnListItem`
                )->a( n = `selected` v = `{SELKZ}`

                )->ele( `cells`

                    )->tag( `Text`
                        )->a( n = `text` v = `{LAYOUT}`
                    )->tag( `Text`
                        )->a( n = `text` v = `{ACTIVE}`
                    )->tag( `Text`
                        )->a( n = `text` v = `{DESCR}`
                    )->tag( `Text`
                        )->a( n = `text` v = `{SCREEN_FORMAT}`
                    )->tag( `Text`
                        )->a( n = `text` v = `{DEF}` ).

    dialog->ele( `buttons`

        )->tag( `Button`
            )->a( n = `press` v = client->_event( 'CLOSE' )
            )->a( n = `text`  v = `Close`
            )->a( n = `icon`  v = `sap-icon://sys-cancel-2`
        )->tag( `Button`
            )->a( n = `press` v = client->_event( 'OPEN_SELECT' )
            )->a( n = `text`  v = `OK`
            )->a( n = `icon`  v = `sap-icon://accept`
            )->a( n = `type`  v = `Emphasized` ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD get_selected_layout.

    result = VALUE #( mt_head[ selkz = abap_true ] OPTIONAL ).

  ENDMETHOD.

  METHOD set_selected_layout.

    DATA(layout) = z2ui5_cl_layo_manager=>factory_by_guid( layout_guid = head-guid
                                                           t_comps     = mo_layout->ms_layout-t_layout ).

    " deleted meanwhile (another session): keep the current layout
    IF layout->ms_layout-s_head IS INITIAL.
      client->message_toast_display( 'Layout no longer exists.' ).
      RETURN.
    ENDIF.

    " the new manager knows only the layout - keep the data it sorts and
    " converts and the row selection settings of the one it replaces
    layout->mr_data = mo_layout->mr_data.
    layout->set_selektion_criteria( sel_mode      = mo_layout->mv_sel_mode
                                    sel_field     = mo_layout->mv_sel_field
                                    sel_key_field = mo_layout->mv_sel_key_field ).

    mo_layout = layout.

  ENDMETHOD.

  METHOD get_layouts.

    mt_head = mo_layout->select_layouts( control  = mo_layout->ms_layout-s_head-control
                                         handle01 = mo_layout->ms_layout-s_head-handle01
                                         handle02 = mo_layout->ms_layout-s_head-handle02
                                         handle03 = mo_layout->ms_layout-s_head-handle03
                                         handle04 = mo_layout->ms_layout-s_head-handle04
                                         format   = mo_layout->ms_layout-s_head-screen_format ).

    " another user's personal layouts are neither to open nor to delete
    DELETE mt_head WHERE uname IS NOT INITIAL AND uname <> sy-uname.

    IF mt_head IS INITIAL.
      RETURN.
    ENDIF.

    DATA(head) = REF #( mt_head[ guid = mo_layout->ms_layout-s_head-guid ] OPTIONAL ).
    IF head IS BOUND.
      head->selkz  = abap_true.
      head->active = abap_true.
      RETURN.
    ELSE.
*      head = REF #( mt_head[ 1 ] OPTIONAL ).
*      head->selkz = abap_true.
    ENDIF.

  ENDMETHOD.

  METHOD init_edit.

    mv_layout = mo_layout->ms_layout-s_head-layout.
    mv_descr  = mo_layout->ms_layout-s_head-descr.
    mv_def    = mo_layout->ms_layout-s_head-def.
    mv_format = mo_layout->ms_layout-s_head-screen_format.

    mv_usr    = xsdbool( mo_layout->ms_layout-s_head-uname IS NOT INITIAL ).

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

    " Nothing selected - guid initial would delete unrelated blank-guid rows.
    IF head-guid IS INITIAL.
      client->message_toast_display( 'No layout selected.' ).
      RETURN.
    ENDIF.

    DELETE FROM z2ui5_t_11 WHERE guid = @head-guid.
    " Base the outcome on the header delete. The old code only checked the
    " sy-subrc of the position delete, so a layout without position rows
    " (e.g. all columns hidden) was never committed and reappeared.
    DATA(head_deleted) = xsdbool( sy-subrc = 0 ).

    DELETE FROM z2ui5_t_12 WHERE guid = @head-guid.

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
      FIND REGEX '([0-9]{1,4}.[0-9]{1})' IN width SUBMATCHES result.
    ELSE.
      FIND REGEX '([0-9]{1,4})' IN width SUBMATCHES result.
    ENDIF.

    " no digits in it (auto, %): an empty result stays empty - CO is true
    " for an empty operand, which made the width a bare, invalid `rem`
    IF result IS NOT INITIAL AND result CO '0123456789. '.
      result = |{ result }rem|.
    ENDIF.

  ENDMETHOD.

  METHOD render_add_subcolumn.

    DATA(popup) = z2ui5_cl_ui5_view_builder=>factory(
        )->ele( n = `FragmentDefinition` ns = `core`
            )->a( n = `xmlns`      v = `sap.m`
            )->a( n = `xmlns:core` v = `sap.ui.core` ).

    DATA(dialog) = popup->ele( `Dialog`
        )->a( n = `title`        v = `Define Sub Coloumns`
        )->a( n = `contentWidth` v = `50%`
        )->a( n = `afterClose`   v = client->_event( 'SUBCOLUMN_CANCEL' ) ).

    dialog->ele( `VBox`
        )->a( n = `justifyContent` v = `SpaceBetween`

        )->ele( `List`
            )->a( n = `items`           v = client->_bind( mo_layout->mt_sub_cols )
            )->a( n = `selectionChange` v = client->_event( 'SELCHANGE' )
            )->a( n = `noDataText`      v = `no Subcolumns defined`

            )->ele( `CustomListItem`
                )->ele( `ComboBox`
                    )->a( n = `selectedKey` v = `{FNAME}`
                    )->a( n = `items`       v = client->_bind( mo_layout->mt_comps )

                    )->tag( n = `Item` ns = `core`
                        )->a( n = `key`  v = `{FNAME}`
                        )->a( n = `text` v = `{FNAME} {TLABEL}`

                )->end(

                )->tag( `Button`
                    )->a( n = `press` v = client->_event( val   = `SUBCOLUMN_DELETE`
                                                          t_arg = VALUE #( ( `${KEY}` ) ) )
                    )->a( n = `icon`  v = `sap-icon://decline`
                    )->a( n = `type`  v = `Transparent` ).

    dialog->ele( `buttons`

        )->tag( `Button`
            )->a( n = `press` v = client->_event( val = `SUBCOLUMN_DELETE_ALL` )
            )->a( n = `text`  v = `Delete All`
            )->a( n = `icon`  v = `sap-icon://delete`
            )->a( n = `type`  v = `Transparent`
        )->tag( `Button`
            )->a( n = `press` v = client->_event( val = `SUBCOLUMN_ADD` )
            )->a( n = `text`  v = `Add Item`
            )->a( n = `icon`  v = `sap-icon://add`
        )->tag( `Button`
            )->a( n = `press` v = client->_event( 'SUBCOLUMN_CANCEL' )
            )->a( n = `text`  v = `Cancel`
        )->tag( `Button`
            )->a( n = `press` v = client->_event( 'SUBCOLUMN_CONFIRM' )
            )->a( n = `text`  v = `OK`
            )->a( n = `type`  v = `Emphasized` ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD on_event_subcoloumns.

    CASE client->get( )-event.

      WHEN 'CALL_SUBCOLUMN'.

        DATA(arg) = client->get( )-t_event_arg.
        mv_active_line = VALUE #( arg[ 1 ] OPTIONAL ).

        READ TABLE mt_layout REFERENCE INTO DATA(layout) WITH KEY fname = mv_active_line.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        mo_layout->mt_comps    = mo_layout->ms_layout-t_layout.   " Components for DropDownList
        mo_layout->mt_sub_cols = layout->t_sub_col.               " Defined Sub Col´s

        render_add_subcolumn( ).

      WHEN `SUBCOLUMN_CONFIRM`.

        READ TABLE mt_layout REFERENCE INTO layout WITH KEY fname = mv_active_line.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        CLEAR layout->subcolumn.

        " rows added but never given a field would save as blanks
        DELETE mo_layout->mt_sub_cols WHERE fname IS INITIAL.

        LOOP AT mo_layout->mt_sub_cols REFERENCE INTO DATA(line).
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
        INSERT VALUE #( key = z2ui5_cl_layo_util=>uuid_get_c32( ) ) INTO TABLE mo_layout->mt_sub_cols.

      WHEN `SUBCOLUMN_DELETE`.
        " get_event_arg( ) is empty without an argument - lt_event[ 1 ] dumped
        DATA(sub_col_key) = client->get_event_arg( ).
        DELETE mo_layout->mt_sub_cols WHERE key = sub_col_key.

      WHEN `SUBCOLUMN_DELETE_ALL`.
        mo_layout->mt_sub_cols = VALUE #( ).

    ENDCASE.

  ENDMETHOD.

  METHOD check_rerender_necessary.

    CLEAR mv_rerender.

    " Sequence and SubCols need rerendering
    LOOP AT mo_layout->ms_layout-t_layout INTO DATA(layout).

      READ TABLE mo_layout->ms_layout_tmp-t_layout INTO DATA(layout_tmp)
           WITH KEY guid     = layout-guid
                    pos_guid = layout-pos_guid.

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      IF layout-alternative_text <> layout_tmp-alternative_text.
        mv_rerender = abap_true.
        RETURN.
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

    CASE client->get( )-event.

      WHEN 'CALL_GRIDLAYOUT'.

        DATA(arg) = client->get( )-t_event_arg.
        mv_active_line = VALUE #( arg[ 1 ] OPTIONAL ).

        READ TABLE mo_layout->ms_layout-t_layout REFERENCE INTO DATA(layout) WITH KEY fname = mv_active_line.
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

        IF    check_grid_sum( value = mv_xl_label + mv_xl_value )
           OR check_grid_sum( value = mv_l_label + mv_l_value )
           OR check_grid_sum( value = mv_m_label + mv_m_value )
           OR check_grid_sum( value = mv_s_label + mv_s_value ) = abap_true.

        ELSE.

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

    IF ( value ) > 12.

      result = abap_true.

      client->message_toast_display( 'Maximum number of columns (12) exceeded' ).

    ENDIF.

  ENDMETHOD.

  METHOD render_add_gridlayout.

    t_col = VALUE #( ( col = 1  )
                     ( col = 2  )
                     ( col = 3  )
                     ( col = 4  )
                     ( col = 5  )
                     ( col = 6  )
                     ( col = 7  )
                     ( col = 8  )
                     ( col = 9  )
                     ( col = 10  )
                     ( col = 11  )
                     ( col = 12  ) ).

    DATA(popup) = z2ui5_cl_ui5_view_builder=>factory(
        )->ele( n = `FragmentDefinition` ns = `core`
            )->a( n = `xmlns`      v = `sap.m`
            )->a( n = `xmlns:core` v = `sap.ui.core`
            )->a( n = `xmlns:form` v = `sap.ui.layout.form` ).

    DATA(dialog) = popup->ele( `Dialog`
        )->a( n = `title`        v = `Grid Layout`
        )->a( n = `contentWidth` v = `140px`
        )->a( n = `afterClose`   v = client->_event( 'GRIDLAYOUT_CANCEL' ) ).

    dialog->ele( n = `SimpleForm` ns = `form`
        )->a( n = `title`    v = `Define Label and Value Span`
        )->a( n = `editable` b = abap_true

        )->ele( n = `content` ns = `form`

            )->tag( `Label`
                )->a( n = `text` v = `XL`
            )->ele( `ComboBox`
                )->a( n = `selectedKey` v = client->_bind( mv_xl_label )
                )->a( n = `items`       v = client->_bind( t_col )
                )->a( n = `width`       v = `7rem`

                )->tag( n = `Item` ns = `core`
                    )->a( n = `key`  v = `{COL}`
                    )->a( n = `text` v = `{COL} Label Span`

            )->end(
            )->ele( `ComboBox`
                )->a( n = `selectedKey` v = client->_bind( mv_xl_value )
                )->a( n = `items`       v = client->_bind( t_col )
                )->a( n = `width`       v = `7rem`

                )->tag( n = `Item` ns = `core`
                    )->a( n = `key`  v = `{COL}`
                    )->a( n = `text` v = `{COL} Value Span`

            )->end(

            )->tag( `Label`
                )->a( n = `text` v = `L`
            )->ele( `ComboBox`
                )->a( n = `selectedKey` v = client->_bind( mv_l_label )
                )->a( n = `items`       v = client->_bind( t_col )
                )->a( n = `width`       v = `7rem`

                )->tag( n = `Item` ns = `core`
                    )->a( n = `key`  v = `{COL}`
                    )->a( n = `text` v = `{COL} Label Span`

            )->end(
            )->ele( `ComboBox`
                )->a( n = `selectedKey` v = client->_bind( mv_l_value )
                )->a( n = `items`       v = client->_bind( t_col )

                )->tag( n = `Item` ns = `core`
                    )->a( n = `key`  v = `{COL}`
                    )->a( n = `text` v = `{COL} Value Span`

            )->end(

            )->tag( `Label`
                )->a( n = `text` v = `M`
            )->ele( `ComboBox`
                )->a( n = `selectedKey` v = client->_bind( mv_m_label )
                )->a( n = `items`       v = client->_bind( t_col )
                )->a( n = `width`       v = `7rem`

                )->tag( n = `Item` ns = `core`
                    )->a( n = `key`  v = `{COL}`
                    )->a( n = `text` v = `{COL} Label Span`

            )->end(
            )->ele( `ComboBox`
                )->a( n = `selectedKey` v = client->_bind( mv_m_value )
                )->a( n = `items`       v = client->_bind( t_col )
                )->a( n = `width`       v = `7rem`

                )->tag( n = `Item` ns = `core`
                    )->a( n = `key`  v = `{COL}`
                    )->a( n = `text` v = `{COL} Value Span`

            )->end(

            )->tag( `Label`
                )->a( n = `text` v = `S`
            )->ele( `ComboBox`
                )->a( n = `selectedKey` v = client->_bind( mv_s_label )
                )->a( n = `items`       v = client->_bind( t_col )
                )->a( n = `width`       v = `7rem`

                )->tag( n = `Item` ns = `core`
                    )->a( n = `key`  v = `{COL}`
                    )->a( n = `text` v = `{COL} Label Span`

            )->end(
            )->ele( `ComboBox`
                )->a( n = `selectedKey` v = client->_bind( mv_s_value )
                )->a( n = `items`       v = client->_bind( t_col )
                )->a( n = `width`       v = `7rem`

                )->tag( n = `Item` ns = `core`
                    )->a( n = `key`  v = `{COL}`
                    )->a( n = `text` v = `{COL} Value Span` ).

    dialog->ele( `buttons`

        )->tag( `Button`
            )->a( n = `press` v = client->_event( 'GRIDLAYOUT_CANCEL' )
            )->a( n = `text`  v = `Cancel`
        )->tag( `Button`
            )->a( n = `press` v = client->_event( 'GRIDLAYOUT_CONFIRM' )
            )->a( n = `text`  v = `OK`
            )->a( n = `type`  v = `Emphasized` ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD update_values.

    LOOP AT mo_layout->ms_layout-t_layout REFERENCE INTO DATA(line).

      DATA(layout) = VALUE #( mt_layout[ pos_guid = line->pos_guid ] OPTIONAL ).
      IF layout IS NOT INITIAL.
        line->* = layout.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
