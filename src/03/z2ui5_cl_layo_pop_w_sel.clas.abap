"! Select one or several rows of any table in a popup whose columns follow a
"! saved layout (column choice, order, width, sorting) - the settings button
"! of its table opens the layout popup. Single select confirms with the
"! first click on a row, multi select with OK; the selection survives
"! searching. Without handles the layouts are kept per popup class and line
"! type of i_tab.
"!   client-&gt;nav_app_call( z2ui5_cl_layo_pop_w_sel=&gt;factory( i_tab         = mt_tab
"!                                                         i_multiselect = abap_true ) ).
"! and back in check_on_navigated( ):
"!   DATA(result) = CAST z2ui5_cl_layo_pop_w_sel( client-&gt;get_app_prev( ) )-&gt;result( ).
"! result-check_confirmed, result-table (the selected rows, a table of the
"! type of i_tab, in its order) and result-row (the first of them).
CLASS z2ui5_cl_layo_pop_w_sel DEFINITION
  PUBLIC FINAL
  CREATE PROTECTED.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    DATA mr_tab          TYPE REF TO data.
    "! the rows on screen: those of mr_tab with ZZROW_ID and ZZSELKZ in front,
    "! filtered by the search and sorted by the layout
    DATA mr_out          TYPE REF TO data.
    "! every row in the caller's order - ZZROW_ID is its index; the selection
    "! of the rows a search hides is kept here
    DATA mr_out_tmp      TYPE REF TO data.

    DATA mo_layout       TYPE REF TO z2ui5_cl_layo_manager.
    " abap2ui5lint-disable-next-line unbound-public-attribute -- z2ui5_cl_layo_xml_builder binds it, handed over as REF #( mv_search_value )
    DATA mv_search_value TYPE string.

    TYPES:
      BEGIN OF ty_s_result,
        row             TYPE REF TO data,
        check_confirmed TYPE abap_bool,
        table           TYPE REF TO data,
      END OF ty_s_result.

    " abap2ui5lint-disable-next-line unbound-public-attribute -- a popup's result is its interface to the app that called it; result( ) returns the same, PUBLIC keeps direct readers compiling
    DATA ms_result       TYPE ty_s_result.

    "! @parameter i_tab | the rows to choose from - any standard table, also
    "!                    one of an elementary line type
    "! @parameter i_handle01 | the handles the layouts are saved under; when
    "!                    none is given: the name of this class and the
    "!                    relative name of the line type of i_tab
    "! @parameter i_multiselect | several rows, confirmed with OK
    "! @parameter i_event_canceled | the event nav_app_leave( ) raises in the
    "!                    calling app on cancel
    "! @parameter i_event_confirmed | the same on confirm; r_data carries the
    "!                    selected rows
    CLASS-METHODS factory
      IMPORTING
        i_tab              TYPE STANDARD TABLE
        i_title            TYPE clike                         OPTIONAL
        i_sort_field       TYPE clike                         OPTIONAL
        i_descending       TYPE abap_bool                     OPTIONAL
        i_contentwidth     TYPE clike                         OPTIONAL
        i_contentheight    TYPE clike                         OPTIONAL
        i_growingthreshold TYPE clike                         OPTIONAL
        i_handle01         TYPE z2ui5_cl_layo_manager=>handle OPTIONAL
        i_handle02         TYPE z2ui5_cl_layo_manager=>handle OPTIONAL
        i_handle03         TYPE z2ui5_cl_layo_manager=>handle OPTIONAL
        i_handle04         TYPE z2ui5_cl_layo_manager=>handle OPTIONAL
        i_multiselect      TYPE abap_bool                     OPTIONAL
        i_event_canceled   TYPE string                        OPTIONAL
        i_event_confirmed  TYPE string                        OPTIONAL
      RETURNING
        VALUE(r_result)    TYPE REF TO z2ui5_cl_layo_pop_w_sel.

    METHODS result
      RETURNING
        VALUE(result) TYPE ty_s_result.

  PROTECTED SECTION.
    CONSTANTS cv_row_id_field TYPE string VALUE `ZZROW_ID`.
    CONSTANTS cv_sel_field    TYPE string VALUE `ZZSELKZ`.
    CONSTANTS cv_tab_line     TYPE string VALUE `TAB_LINE`.

    DATA client            TYPE REF TO z2ui5_if_client.
    DATA title             TYPE string.
    DATA sort_field        TYPE string.
    DATA content_width     TYPE string.
    DATA content_height    TYPE string.
    DATA growing_threshold TYPE string.
    DATA descending        TYPE abap_bool.
    DATA multiselect       TYPE abap_bool.
    DATA event_canceled    TYPE string.
    DATA event_confirmed   TYPE string.
    "! i_tab has an elementary line type - its value is the column TAB_LINE
    DATA check_table_line  TYPE abap_bool.

    METHODS on_event.
    METHODS render_main.
    METHODS set_output_table.

    METHODS on_event_search.

    METHODS get_comp
      RETURNING
        VALUE(result) TYPE abap_component_tab.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_s_handles,
        handle01 TYPE z2ui5_cl_layo_manager=>handle,
        handle02 TYPE z2ui5_cl_layo_manager=>handle,
        handle03 TYPE z2ui5_cl_layo_manager=>handle,
        handle04 TYPE z2ui5_cl_layo_manager=>handle,
      END OF ty_s_handles.

    "! mr_tab, the typed result references and check_table_line
    METHODS set_input
      IMPORTING
        i_tab TYPE STANDARD TABLE.

    "! the handles the layouts are saved under: the caller's, or when he
    "! gives none the name of this class and the line type of mr_tab
    METHODS get_handles
      IMPORTING
        handles       TYPE ty_s_handles
      RETURNING
        VALUE(result) TYPE ty_s_handles.

    "! the type description of mr_tab, which factory( ) binds
    METHODS get_table_descr
      RETURNING
        VALUE(result) TYPE REF TO cl_abap_tabledescr.

    METHODS init_layout
      IMPORTING
        handles TYPE ty_s_handles.

    METHODS confirm.
    METHODS on_after_layout.
    METHODS sort_output_table.

    "! the selection of the rows on screen into mr_out_tmp
    METHODS sync_selection.

    "! a row pressed in single select: the only selected one
    METHODS select_row
      IMPORTING
        row_id TYPE string.

    "! ms_result from the selected rows of mr_out_tmp
    METHODS collect_result.

    METHODS get_search_fields
      RETURNING
        VALUE(result) TYPE string_table.

ENDCLASS.


CLASS z2ui5_cl_layo_pop_w_sel IMPLEMENTATION.

  METHOD factory.

    r_result = NEW #( ).
    r_result->title = COND #( WHEN i_title IS NOT INITIAL THEN i_title
                              WHEN i_multiselect = abap_true THEN `Multi Select`
                              ELSE `Single Select` ).
    r_result->sort_field        = i_sort_field.
    r_result->descending        = i_descending.
    r_result->multiselect       = i_multiselect.
    r_result->event_canceled    = i_event_canceled.
    r_result->event_confirmed   = i_event_confirmed.
    r_result->growing_threshold = i_growingthreshold.

    " a multi selection needs room for its rows and the OK button - the
    " single selection keeps the size of its content as before
    r_result->content_width = COND #( WHEN i_contentwidth IS NOT INITIAL THEN i_contentwidth
                                      WHEN i_multiselect = abap_true THEN `90%` ).
    r_result->content_height = COND #( WHEN i_contentheight IS NOT INITIAL THEN i_contentheight
                                       WHEN i_multiselect = abap_true THEN `70%` ).

    r_result->set_input( i_tab ).

    r_result->init_layout( r_result->get_handles( VALUE #( handle01 = i_handle01
                                                           handle02 = i_handle02
                                                           handle03 = i_handle03
                                                           handle04 = i_handle04 ) ) ).

  ENDMETHOD.

  METHOD set_input.

    mr_tab = z2ui5_cl_layo_context=>conv_copy_ref_data( i_tab ).

    CREATE DATA ms_result-row LIKE LINE OF i_tab.
    CREATE DATA ms_result-table LIKE i_tab.

    DATA(table_descr) = CAST cl_abap_tabledescr( cl_abap_typedescr=>describe_by_data( i_tab ) ).
    DATA(line_descr) = table_descr->get_table_line_type( ).
    check_table_line = xsdbool( line_descr->kind <> cl_abap_typedescr=>kind_struct ).

  ENDMETHOD.

  METHOD get_handles.

    result = handles.

    IF handles IS NOT INITIAL.
      RETURN.
    ENDIF.

    " no handles: the layouts of this popup per line type. The class name is
    " read from the reference, never written - the namespace rename rewrites
    " references only
    DATA(table_descr) = get_table_descr( ).
    result-handle01 = z2ui5_cl_layo_context=>rtti_get_classname_by_ref( me ).
    DATA(line_descr) = table_descr->get_table_line_type( ).
    result-handle02 = line_descr->get_relative_name( ).

  ENDMETHOD.

  METHOD get_table_descr.

    DATA descr TYPE REF TO cl_abap_typedescr.

    cl_abap_typedescr=>describe_by_data_ref( EXPORTING  p_data_ref           = mr_tab
                                             RECEIVING  p_descr_ref          = descr
                                             EXCEPTIONS reference_is_initial = 1
                                                        OTHERS               = 2 ).
    " mr_tab is bound since factory( ) - an initial one ends in a runtime
    " error, as the functional call before did
    ASSERT sy-subrc = 0.
    result = CAST #( descr ).

  ENDMETHOD.

  METHOD init_layout.

    DATA layout_tab TYPE REF TO data.

    " the layout is built on the columns of the caller's line only - the row
    " id and the selection flag are no columns to choose
    IF check_table_line = abap_true.
      DATA(table_descr) = get_table_descr( ).
      DATA(layout_line) = cl_abap_structdescr=>create( VALUE #( ( name = cv_tab_line
                                                                  type = table_descr->get_table_line_type( ) ) ) ).
      DATA(layout_descr) = cl_abap_tabledescr=>create( layout_line ).
      CREATE DATA layout_tab TYPE HANDLE layout_descr.
    ELSE.
      layout_tab = mr_tab.
    ENDIF.

    mo_layout = z2ui5_cl_layo_manager=>factory( data     = layout_tab
                                                control  = z2ui5_cl_layo_manager=>m_table
                                                handle01 = handles-handle01
                                                handle02 = handles-handle02
                                                handle03 = handles-handle03
                                                handle04 = handles-handle04 ).

  ENDMETHOD.

  METHOD render_main.

    DATA(popup) = z2ui5_cl_ui5_view_builder=>factory(
                      )->ele( n = `FragmentDefinition` ns = `core`
                      )->a( n = `xmlns` v = `sap.m`
                      )->a( n = `xmlns:core` v = `sap.ui.core`
                      " abap2ui5lint-disable unused-namespace-declaration -- z2ui5_cl_layo_xml_builder writes controls with these prefixes into this view
                      )->a( n = `xmlns:form` v = `sap.ui.layout.form`
                      )->a( n = `xmlns:mchart` v = `sap.suite.ui.microchart`
                      )->a( n = `xmlns:si` v = `sap.suite.ui.commons.statusindicator` ).
    " abap2ui5lint-enable unused-namespace-declaration

    DATA(dialog) = popup->ele( `Dialog`
                       )->a( n = `title` t = title
                       )->a( n = `afterClose` v = client->_event( `CANCEL` ) ).

    IF content_width IS NOT INITIAL.
      dialog->a( n = `contentWidth` v = content_width ).
    ENDIF.
    IF content_height IS NOT INITIAL.
      dialog->a( n = `contentHeight` v = content_height ).
    ENDIF.

    " single select: the radio button and the press on the row both confirm
    " at once; multi select: check boxes, confirmed with OK
    IF multiselect = abap_true.
      z2ui5_cl_layo_xml_builder=>xml_build_table( i_data             = mr_out
                                                  i_xml              = dialog
                                                  i_client           = client
                                                  i_layout           = mo_layout
                                                  i_search_value     = REF #( mv_search_value )
                                                  i_growingthreshold = growing_threshold
                                                  i_sel_mode         = `MultiSelect`
                                                  i_sel_bind_to      = cv_sel_field ).
    ELSE.
      z2ui5_cl_layo_xml_builder=>xml_build_table( i_data             = mr_out
                                                  i_xml              = dialog
                                                  i_client           = client
                                                  i_layout           = mo_layout
                                                  i_search_value     = REF #( mv_search_value )
                                                  i_growingthreshold = growing_threshold
                                                  i_sel_mode         = `SingleSelectLeft`
                                                  i_sel_bind_to      = cv_sel_field
                                                  i_col_type         = `Navigation`
                                                  i_col_bind_to      = cv_row_id_field ).
    ENDIF.

    DATA(buttons) = dialog->ele( `buttons`
                        )->tag( `Button`
                        )->a( n = `text` v = `Cancel`
                        )->a( n = `press` v = client->_event( `CANCEL` ) ).

    IF multiselect = abap_true.
      buttons->tag( `Button`
          )->a( n = `text` v = `OK`
          )->a( n = `press` v = client->_event( `CONFIRM` )
          )->a( n = `type` v = `Emphasized` ).
    ENDIF.

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.

    me->client = client.

    IF client->check_on_init( ).
      set_output_table( ).
      sort_output_table( ).
      render_main( ).
    ELSEIF client->check_on_navigated( ).
      on_after_layout( ).
    ELSEIF client->check_on_event( ).
      on_event( ).
    ENDIF.

  ENDMETHOD.

  METHOD on_event.

    CASE client->get( )-event.

      WHEN `ROW_SELECT`.
        " get_event_arg( ) is empty without an argument - t_arg[ 1 ] dumped
        select_row( client->get_event_arg( ) ).
        confirm( ).

      WHEN `SELECTION_CHANGE`.
        " a single selection confirms at once, a multi selection waits for OK
        IF multiselect = abap_false.
          sync_selection( ).
          confirm( ).
        ENDIF.

      WHEN `CONFIRM`.
        sync_selection( ).
        confirm( ).

      WHEN `CANCEL`.
        client->popup_destroy( ).
        client->nav_app_leave( event = event_canceled ).

      WHEN `SEARCH`.
        on_event_search( ).

      WHEN OTHERS.

        z2ui5_cl_layo_pop=>on_event_layout( client = client
                                            layout = mo_layout ).

    ENDCASE.

  ENDMETHOD.

  METHOD on_after_layout.

    " back from the layout popup: take its layout. Any other return (a
    " restored draft) still has to put the popup on screen again
    TRY.
        DATA(app) = CAST z2ui5_cl_layo_pop( client->get_app_prev( ) ).
        IF app IS BOUND.
          mo_layout = app->mo_layout.
        ENDIF.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    sort_output_table( ).
    render_main( ).

  ENDMETHOD.

  METHOD confirm.

    FIELD-SYMBOLS <table_result> TYPE STANDARD TABLE.

    collect_result( ).

    ASSIGN ms_result-table->* TO <table_result>.

    client->popup_destroy( ).
    client->nav_app_leave( event  = event_confirmed
                           r_data = <table_result> ).

  ENDMETHOD.

  METHOD select_row.

    FIELD-SYMBOLS <tab_backup> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row>        TYPE any.
    FIELD-SYMBOLS <selkz>      TYPE any.
    FIELD-SYMBOLS <row_id>     TYPE any.

    ASSIGN mr_out_tmp->* TO <tab_backup>.

    LOOP AT <tab_backup> ASSIGNING <row>.
      ASSIGN COMPONENT cv_sel_field OF STRUCTURE <row> TO <selkz>.
      ASSERT sy-subrc = 0.
      ASSIGN COMPONENT cv_row_id_field OF STRUCTURE <row> TO <row_id>.
      ASSERT sy-subrc = 0.
      " compared as text: the event argument is a string, the id a number
      <selkz> = xsdbool( |{ <row_id> }| = row_id ).
    ENDLOOP.

  ENDMETHOD.

  METHOD collect_result.

    FIELD-SYMBOLS <tab_backup>   TYPE STANDARD TABLE.
    FIELD-SYMBOLS <table_result> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row_backup>   TYPE any.
    FIELD-SYMBOLS <selkz>        TYPE any.
    FIELD-SYMBOLS <row_result>   TYPE any.
    FIELD-SYMBOLS <tab_line>     TYPE any.

    ASSIGN mr_out_tmp->* TO <tab_backup>.
    ASSIGN ms_result-table->* TO <table_result>.
    ASSIGN ms_result-row->* TO <row_result>.

    " the result only contains rows of this confirmation, in the caller's order
    CLEAR <table_result>.

    LOOP AT <tab_backup> ASSIGNING <row_backup>.

      ASSIGN COMPONENT cv_sel_field OF STRUCTURE <row_backup> TO <selkz>.
      ASSERT sy-subrc = 0.
      IF <selkz> = abap_false.
        CONTINUE.
      ENDIF.

      INSERT INITIAL LINE INTO TABLE <table_result> ASSIGNING <row_result>.
      IF check_table_line = abap_true.
        ASSIGN COMPONENT cv_tab_line OF STRUCTURE <row_backup> TO <tab_line>.
        ASSERT sy-subrc = 0.
        <row_result> = <tab_line>.
      ELSE.
        MOVE-CORRESPONDING <row_backup> TO <row_result>.
      ENDIF.

      IF multiselect = abap_false.
        EXIT.
      ENDIF.

    ENDLOOP.

    " the row: the first selected one - the only one of a single selection
    ASSIGN ms_result-row->* TO <row_result>.
    CLEAR <row_result>.
    ASSIGN <table_result>[ 1 ] TO FIELD-SYMBOL(<first>).
    IF <first> IS ASSIGNED.
      <row_result> = <first>.
    ENDIF.

    ms_result-check_confirmed = abap_true.

  ENDMETHOD.

  METHOD result.

    result = ms_result.

  ENDMETHOD.

  METHOD set_output_table.

    DATA(t_comp) = get_comp( ).
    TRY.

        DATA(new_struct_desc) = cl_abap_structdescr=>create( t_comp ).

        DATA(new_table_desc) = cl_abap_tabledescr=>create( p_line_type  = new_struct_desc
                                                           p_table_kind = cl_abap_tabledescr=>tablekind_std ).

        CREATE DATA mr_out     TYPE HANDLE new_table_desc.
        CREATE DATA mr_out_tmp TYPE HANDLE new_table_desc.

      CATCH cx_root ##NO_HANDLER.

    ENDTRY.

    FIELD-SYMBOLS <t_out>     TYPE STANDARD TABLE.
    FIELD-SYMBOLS <t_out_tmp> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <t_tab>     TYPE STANDARD TABLE.
    FIELD-SYMBOLS <ls_tab>    TYPE any.
    FIELD-SYMBOLS <ls_out>    TYPE any.
    FIELD-SYMBOLS <field>     TYPE any.

    ASSIGN mr_out->* TO <t_out>.
    ASSIGN mr_out_tmp->* TO <t_out_tmp>.
    ASSIGN mr_tab->* TO <t_tab>.

    " row by row: the output line has ZZROW_ID in front, so the lines are not
    " convertible as a whole (UC_OBJECTS_NOT_CONVERTIBLE)
    CLEAR <t_out>.
    LOOP AT <t_tab> ASSIGNING <ls_tab>.
      DATA(index) = sy-tabix.

      INSERT INITIAL LINE INTO TABLE <t_out> ASSIGNING <ls_out>.
      IF check_table_line = abap_true.
        ASSIGN COMPONENT cv_tab_line OF STRUCTURE <ls_out> TO <field>.
        ASSERT sy-subrc = 0.
        <field> = <ls_tab>.
      ELSE.
        MOVE-CORRESPONDING <ls_tab> TO <ls_out>.
      ENDIF.

      " the row id is the index in the caller's table - it survives
      " searching and sorting
      ASSIGN COMPONENT cv_row_id_field OF STRUCTURE <ls_out> TO <field>.
      ASSERT sy-subrc = 0.
      <field> = index.

      " a ZZSELKZ of the caller's line is no selection
      ASSIGN COMPONENT cv_sel_field OF STRUCTURE <ls_out> TO <field>.
      ASSERT sy-subrc = 0.
      CLEAR <field>.
    ENDLOOP.

    <t_out_tmp> = <t_out>.

  ENDMETHOD.

  METHOD get_comp.
    DATA index TYPE int4.
    DATA selkz TYPE abap_bool.
    DATA comp  TYPE abap_component_tab.

    TRY.

        IF check_table_line = abap_true.
          DATA(table_descr) = get_table_descr( ).
          comp = VALUE #( ( name = cv_tab_line
                            type = table_descr->get_table_line_type( ) ) ).
        ELSE.
          comp = z2ui5_cl_layo_context=>rtti_get_t_attri_by_any( mr_tab ).
        ENDIF.

        IF NOT line_exists( comp[ name = cv_row_id_field ] ).
          INSERT VALUE #( name = cv_row_id_field
                          type = CAST #( cl_abap_datadescr=>describe_by_data( index ) ) ) INTO TABLE result.
        ENDIF.

        IF NOT line_exists( comp[ name = cv_sel_field ] ).
          INSERT VALUE #( name = cv_sel_field
                          type = CAST #( cl_abap_datadescr=>describe_by_data( selkz ) ) ) INTO TABLE result.
        ENDIF.

        INSERT LINES OF comp INTO TABLE result.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD sort_output_table.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.

    " the order the caller asked for (i_sort_field, i_descending) - the
    " sorting of the layout, when it has one, decides over it
    IF sort_field IS NOT INITIAL.
      ASSIGN mr_out->* TO <tab>.
      DATA(lv_name) = to_upper( sort_field ).
      TRY.
          IF descending = abap_true.
            SORT <tab> BY (lv_name) DESCENDING.
          ELSE.
            SORT <tab> BY (lv_name) ASCENDING.
          ENDIF.
        CATCH cx_root ##NO_HANDLER.
          " no column of that name: the caller's order stays
      ENDTRY.
    ENDIF.

    " the sorting of the layout - point it at the table again first: the
    " draft restores the layout's own reference as one to a copy
    mo_layout->sort( no_selkz_sort = abap_true
                     data          = mr_out ).

  ENDMETHOD.

  METHOD sync_selection.

    FIELD-SYMBOLS <tab_out>      TYPE STANDARD TABLE.
    FIELD-SYMBOLS <tab_backup>   TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row>          TYPE any.
    FIELD-SYMBOLS <row_backup>   TYPE any.
    FIELD-SYMBOLS <row_id>       TYPE any.
    FIELD-SYMBOLS <selkz>        TYPE any.
    FIELD-SYMBOLS <selkz_backup> TYPE any.

    ASSIGN mr_out->* TO <tab_out>.
    ASSIGN mr_out_tmp->* TO <tab_backup>.

    " a single selection replaces one hidden by a search
    IF multiselect = abap_false.
      LOOP AT <tab_backup> ASSIGNING <row_backup>.
        ASSIGN COMPONENT cv_sel_field OF STRUCTURE <row_backup> TO <selkz_backup>.
        ASSERT sy-subrc = 0.
        CLEAR <selkz_backup>.
      ENDLOOP.
    ENDIF.

    LOOP AT <tab_out> ASSIGNING <row>.
      ASSIGN COMPONENT cv_row_id_field OF STRUCTURE <row> TO <row_id>.
      ASSERT sy-subrc = 0.
      ASSIGN COMPONENT cv_sel_field OF STRUCTURE <row> TO <selkz>.
      ASSERT sy-subrc = 0.

      UNASSIGN <row_backup>.
      ASSIGN <tab_backup>[ <row_id> ] TO <row_backup>.
      IF <row_backup> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.
      ASSIGN COMPONENT cv_sel_field OF STRUCTURE <row_backup> TO <selkz_backup>.
      ASSERT sy-subrc = 0.
      <selkz_backup> = <selkz>.
    ENDLOOP.

  ENDMETHOD.

  METHOD get_search_fields.

    " the columns of the layout - never the row id or the selection flag
    LOOP AT mo_layout->ms_layout-t_layout INTO DATA(layout).
      INSERT |{ layout-fname }| INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD on_event_search.

    FIELD-SYMBOLS <tab>     TYPE STANDARD TABLE.
    FIELD-SYMBOLS <tab_tmp> TYPE STANDARD TABLE.

    " keep what was selected before the rows are filtered anew
    sync_selection( ).

    ASSIGN mr_out->* TO <tab>.
    ASSIGN mr_out_tmp->* TO <tab_tmp>.

    <tab> = <tab_tmp>.

    z2ui5_cl_layo_context=>itab_filter_by_val( EXPORTING val         = mv_search_value
                                                         fields      = get_search_fields( )
                                                         ignore_case = abap_true
                                               CHANGING  tab         = <tab> ).

    sort_output_table( ).

  ENDMETHOD.

ENDCLASS.
