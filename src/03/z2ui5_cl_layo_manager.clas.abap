CLASS z2ui5_cl_layo_manager DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_serializable_object.

    CONSTANTS screen_format_l TYPE string VALUE 'L' ##NO_TEXT.
    CONSTANTS screen_format_s TYPE string VALUE 'S' ##NO_TEXT.

    TYPES handle  TYPE c LENGTH 40.
    TYPES control TYPE c LENGTH 15.

    TYPES:
      BEGIN OF ty_s_controls,
        attribute TYPE string,
        control   TYPE control,
        active    TYPE abap_bool,
        index     TYPE int4,
      END OF ty_s_controls.
    TYPES ty_t_controls TYPE STANDARD TABLE OF ty_s_controls WITH DEFAULT KEY.

    CLASS-DATA ui_table      TYPE control VALUE 'UI.TABLE' ##NO_TEXT.
    CLASS-DATA m_table       TYPE control VALUE 'M.TABLE' ##NO_TEXT.
    CLASS-DATA ui_simpleform TYPE control VALUE 'UI.SIMPLEFORM' ##NO_TEXT.
    CLASS-DATA others        TYPE control VALUE '' ##NO_TEXT.

    TYPES ty_s_head TYPE z2ui5_t_11.
    TYPES ty_t_head TYPE STANDARD TABLE OF ty_s_head WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_sub_columns,
        key   TYPE string,
        fname TYPE string,
      END OF ty_s_sub_columns.
    TYPES ty_t_sub_columns TYPE STANDARD TABLE OF ty_s_sub_columns WITH DEFAULT KEY.

    TYPES  BEGIN OF ty_s_positions.
             INCLUDE TYPE z2ui5_t_12.
    TYPES:   tlabel            TYPE string,
             t_sub_col         TYPE ty_t_sub_columns,
             grid_layout       TYPE string,
             grid_layout_label TYPE string,
             show_convexit     TYPE abap_bool,
             convexit          TYPE string,
           END OF ty_s_positions.
    TYPES ty_t_positions TYPE STANDARD TABLE OF ty_s_positions WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_layout,
        s_head   TYPE ty_s_head,
        t_layout TYPE ty_t_positions,
      END OF ty_s_layout.

    DATA ms_layout     TYPE ty_s_layout.
    DATA ms_layout_tmp TYPE ty_s_layout.
    DATA mt_comps      TYPE ty_t_positions.
    DATA mt_sub_cols   TYPE ty_t_sub_columns.
    DATA mr_data       TYPE REF TO data.

    CLASS-METHODS factory
      IMPORTING
        !data         TYPE REF TO data
        !control      TYPE clike
        handle01      TYPE clike OPTIONAL
        handle02      TYPE clike OPTIONAL
        handle03      TYPE clike OPTIONAL
        handle04      TYPE clike OPTIONAL
        !format       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_layo_manager.

    CLASS-METHODS factory_by_guid
      IMPORTING
        layout_guid   TYPE clike
        t_comps       TYPE ty_t_positions
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_layo_manager.

    CLASS-METHODS select_layouts
      IMPORTING
        layout_guid   TYPE clike OPTIONAL
        !control      TYPE clike OPTIONAL
        handle01      TYPE clike OPTIONAL
        handle02      TYPE clike OPTIONAL
        handle03      TYPE clike OPTIONAL
        handle04      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE  ty_t_head.

    CLASS-METHODS select_layout_components
      IMPORTING
        layout_guid   TYPE clike
      RETURNING
        VALUE(result) TYPE  ty_t_positions.

    METHODS data_conversion
      IMPORTING
        !output TYPE abap_bool.

    CLASS-METHODS set_text
      IMPORTING
        !layout       TYPE  ty_s_positions
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS sort_by_sequence
      IMPORTING
        !pos          TYPE  ty_t_positions
      RETURNING
        VALUE(result) TYPE  ty_t_positions.

    CLASS-METHODS set_sub_columns
      IMPORTING
        !layout       TYPE  ty_t_positions
      RETURNING
        VALUE(result) TYPE  ty_t_positions.

    CLASS-METHODS get_controls
      RETURNING
        VALUE(result) TYPE  ty_t_controls.

    CLASS-METHODS choose_layout
      IMPORTING
        !control      TYPE control DEFAULT  m_table
        handle01      TYPE clike   OPTIONAL
        handle02      TYPE clike   OPTIONAL
        handle03      TYPE clike   OPTIONAL
        handle04      TYPE clike   OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_layo_pop_w_sel.

    METHODS sort
      IMPORTING
        no_selkz_sort TYPE abap_bool OPTIONAL.

    METHODS set_selektion_criteria
      IMPORTING
        sel_mode      TYPE string
        sel_field     TYPE string
        sel_key_field TYPE string.

    METHODS set_selkz IMPORTING t_event_arg TYPE string_table.

    DATA mv_sel_mode      TYPE string.
    DATA mv_sel_field     TYPE string.
    DATA mv_sel_key_field TYPE string.

  PROTECTED SECTION.
    CLASS-METHODS get_conversion_exit
      IMPORTING
        !type         TYPE REF TO cl_abap_datadescr
        !layout       TYPE ty_s_positions
      RETURNING
        VALUE(result) TYPE ty_s_positions.

  PRIVATE SECTION.
    CLASS-METHODS create_layout_obj
      IMPORTING
        layout_guid   TYPE clike       OPTIONAL
        !data         TYPE REF TO data OPTIONAL
        !control      TYPE clike       OPTIONAL
        handle01      TYPE clike       OPTIONAL
        handle02      TYPE clike       OPTIONAL
        handle03      TYPE clike       OPTIONAL
        handle04      TYPE clike       OPTIONAL
        !format       TYPE clike       OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_layo_manager.

    CLASS-METHODS get_default_layout
      IMPORTING
        handle04      TYPE clike
        handle03      TYPE clike
        handle02      TYPE clike
        handle01      TYPE clike
        layout_guid   TYPE clike
        !format       TYPE clike OPTIONAL
        !head         TYPE  ty_t_head
      RETURNING
        VALUE(result) TYPE  ty_s_head.

    CLASS-METHODS build_default_positions
      IMPORTING
        comp          TYPE REF TO abap_componentdescr
        guid          TYPE sysuuid_c32
        !index        TYPE i
      RETURNING
        VALUE(result) TYPE  ty_s_positions.

    CLASS-METHODS default_grid_layout
      IMPORTING
        !position     TYPE  ty_s_positions
      RETURNING
        VALUE(result) TYPE  ty_s_positions.

    METHODS convert
      IMPORTING
        i_output TYPE abap_bool
        i_layout TYPE ty_s_positions
      CHANGING
        c_value  TYPE data.

ENDCLASS.


CLASS z2ui5_cl_layo_manager IMPLEMENTATION.

  METHOD get_controls.

    DATA temp1 TYPE z2ui5_cl_layo_manager=>ty_t_controls.
    DATA temp2 LIKE LINE OF temp1.
    CLEAR temp1.

    temp2-active = abap_true.
    temp2-control = m_table.
    temp2-index = 1.
    temp2-attribute = 'TLABEL'.
    INSERT temp2 INTO TABLE temp1.
    temp2-control = m_table.
    temp2-index = 2.
    temp2-attribute = 'VISIBLE'.
    INSERT temp2 INTO TABLE temp1.
    temp2-control = m_table.
    temp2-index = 3.
    temp2-attribute = 'MERGE'.
    INSERT temp2 INTO TABLE temp1.
    temp2-control = m_table.
    temp2-index = 4.
    temp2-attribute = 'WIDTH'.
    INSERT temp2 INTO TABLE temp1.
    temp2-control = m_table.
    temp2-index = 5.
    temp2-attribute = 'ALTERNATIVE_TEXT'.
    INSERT temp2 INTO TABLE temp1.
    temp2-control = m_table.
    temp2-index = 6.
    temp2-attribute = 'SEQUENCE'.
    INSERT temp2 INTO TABLE temp1.
    temp2-control = m_table.
    temp2-index = 7.
    temp2-attribute = 'SUBCOLUMN'.
    INSERT temp2 INTO TABLE temp1.
    temp2-control = m_table.
    temp2-index = 8.
    temp2-attribute = 'REFERENCE_FIELD'.
    INSERT temp2 INTO TABLE temp1.
    temp2-control = m_table.
    temp2-index = 9.
    temp2-attribute = 'SORTING'.
    INSERT temp2 INTO TABLE temp1.
    temp2-control = m_table.
    temp2-index = 10.
    temp2-attribute = 'NO_CONVEXIT'.
    INSERT temp2 INTO TABLE temp1.
    temp2-control = ui_table.
    temp2-index = 1.
    temp2-attribute = 'TLABEL'.
    INSERT temp2 INTO TABLE temp1.
    temp2-control = ui_table.
    temp2-index = 2.
    temp2-attribute = 'VISIBLE'.
    INSERT temp2 INTO TABLE temp1.
    temp2-control = ui_table.
    temp2-index = 3.
    temp2-attribute = 'ALTERNATIVE_TEXT'.
    INSERT temp2 INTO TABLE temp1.
    temp2-control = ui_table.
    temp2-index = 5.
    temp2-attribute = 'WIDTH'.
    INSERT temp2 INTO TABLE temp1.
    temp2-control = others.
    temp2-index = 1.
    temp2-attribute = 'TLABEL'.
    INSERT temp2 INTO TABLE temp1.
    temp2-control = others.
    temp2-index = 2.
    temp2-attribute = 'VISIBLE'.
    INSERT temp2 INTO TABLE temp1.
    temp2-control = others.
    temp2-index = 3.
    temp2-attribute = 'SEQUENCE'.
    INSERT temp2 INTO TABLE temp1.
    temp2-control = others.
    temp2-index = 4.
    temp2-attribute = 'ALTERNATIVE_TEXT'.
    INSERT temp2 INTO TABLE temp1.
    temp2-control = ui_simpleform.
    temp2-index = 1.
    temp2-attribute = 'TLABEL'.
    INSERT temp2 INTO TABLE temp1.
    temp2-control = ui_simpleform.
    temp2-index = 2.
    temp2-attribute = 'VISIBLE'.
    INSERT temp2 INTO TABLE temp1.
    temp2-control = ui_simpleform.
    temp2-index = 3.
    temp2-attribute = 'SEQUENCE'.
    INSERT temp2 INTO TABLE temp1.
    temp2-control = ui_simpleform.
    temp2-index = 4.
    temp2-attribute = 'ALTERNATIVE_TEXT'.
    INSERT temp2 INTO TABLE temp1.
    temp2-control = ui_simpleform.
    temp2-index = 5.
    temp2-attribute = 'REFERENCE_FIELD'.
    INSERT temp2 INTO TABLE temp1.
    temp2-control = ui_simpleform.
    temp2-index = 6.
    temp2-attribute = 'GRID_LAYOUT'.
    INSERT temp2 INTO TABLE temp1.
    temp2-control = ui_simpleform.
    temp2-index = 7.
    temp2-attribute = 'NO_CONVEXIT'.
    INSERT temp2 INTO TABLE temp1.
    result = temp1.
  ENDMETHOD.

  METHOD factory.

    result = create_layout_obj( data     = data
                                control  = control
                                handle01 = handle01
                                handle02 = handle02
                                handle03 = handle03
                                handle04 = handle04
                                format   = format  ).

  ENDMETHOD.

  METHOD select_layouts.
    DATA temp3 LIKE LINE OF result.
    DATA line LIKE REF TO temp3.

    IF layout_guid IS NOT INITIAL.

      SELECT guid
             layout
             control
             handle01
             handle02
             handle03
             handle04
             screen_format
             descr
             def
             uname
        FROM z2ui5_t_11 INTO CORRESPONDING FIELDS OF TABLE result
        WHERE guid = layout_guid
         ##SUBRC_OK.

    ELSE.

      SELECT guid
             layout
             control
             handle01
             handle02
             handle03
             handle04
             screen_format
             descr
             def
             uname
        FROM z2ui5_t_11 INTO CORRESPONDING FIELDS OF TABLE result
        WHERE control  = control
          AND handle01 = handle01
          AND handle02 = handle02
          AND handle03 = handle03
          AND handle04 = handle04
         ##SUBRC_OK.

    ENDIF.

    " FALLBACK - Screen format was added later! We are changing an empty format to L.


    LOOP AT result REFERENCE INTO line WHERE screen_format IS INITIAL.
      line->screen_format = screen_format_l.
    ENDLOOP.

  ENDMETHOD.

  METHOD select_layout_components.

    SELECT guid
           pos_guid
           fname
           rollname
           visible
           merge
           halign
           importance
           width
           sequence
           alternative_text
           reference_field
           subcolumn
           grid_label_xl
           grid_value_xl
           grid_label_l
           grid_value_l
           grid_label_m
           grid_value_m
           grid_label_s
           grid_value_s
           no_convexit
           sorting
      FROM z2ui5_t_12 INTO CORRESPONDING FIELDS OF TABLE result
      WHERE guid = layout_guid
       ##SUBRC_OK.

  ENDMETHOD.

  METHOD set_text.

    IF layout-alternative_text IS INITIAL.
      result = z2ui5_cl_util=>rtti_get_data_element_texts( layout-rollname  )-long.
    ELSE.
      result = z2ui5_cl_util=>rtti_get_data_element_texts( layout-alternative_text )-long.
    ENDIF.

    IF result IS INITIAL.
      IF layout-alternative_text IS NOT INITIAL.
        result = layout-alternative_text.
      ELSE.
        result = layout-fname.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD sort_by_sequence.

    " First all with a sequence, then the rest
    DATA tab LIKE pos.
    DATA index TYPE i.
      DATA line LIKE LINE OF tab.
    tab = pos.


    index = 0.

    DO 999 TIMES.

      index = index + 1.


      LOOP AT tab INTO line WHERE sequence = index.
        APPEND line TO result.
      ENDLOOP.
      " delete after the loop: deleting inside LOOP AT ... WHERE skips the
      " row that shifts into the current position, dropping duplicates
      DELETE tab WHERE sequence = index.

    ENDDO.

    APPEND LINES OF tab TO result.

  ENDMETHOD.

  METHOD set_sub_columns.
    DATA temp4 LIKE LINE OF result.
    DATA line LIKE REF TO temp4.
      DATA tab TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
      DATA temp5 TYPE z2ui5_cl_layo_manager=>ty_t_sub_columns.
      DATA t LIKE LINE OF tab.
        DATA temp6 LIKE LINE OF temp5.

    result = layout.



    LOOP AT result REFERENCE INTO line WHERE subcolumn IS NOT INITIAL.


      SPLIT line->subcolumn AT ` ` INTO TABLE tab.


      CLEAR temp5.

      LOOP AT tab INTO t.

        temp6-key = z2ui5_cl_util=>uuid_get_c32( ).
        temp6-fname = t.
        INSERT temp6 INTO TABLE temp5.
      ENDLOOP.
      line->t_sub_col = temp5.

    ENDLOOP.

  ENDMETHOD.

  METHOD choose_layout.

    DATA layouts TYPE z2ui5_cl_layo_manager=>ty_t_head.
    layouts = select_layouts( control  = control
                                    handle01 = handle01
                                    handle02 = handle02
                                    handle03 = handle03
                                    handle04 = handle04  ).

    result = z2ui5_cl_layo_pop_w_sel=>factory( i_tab   = layouts
                                               i_title = 'Layouts' ).

  ENDMETHOD.

  METHOD factory_by_guid.
DATA BEGIN OF head.
DATA guid TYPE z2ui5_t_11-guid.
DATA layout TYPE z2ui5_t_11-layout.
DATA control TYPE z2ui5_t_11-control.
DATA handle01 TYPE z2ui5_t_11-handle01.
DATA handle02 TYPE z2ui5_t_11-handle02.
DATA handle03 TYPE z2ui5_t_11-handle03.
DATA handle04 TYPE z2ui5_t_11-handle04.
DATA screen_format TYPE z2ui5_t_11-screen_format.
DATA descr TYPE z2ui5_t_11-descr.
DATA def TYPE z2ui5_t_11-def.
DATA uname TYPE z2ui5_t_11-uname.
DATA END OF head.
    DATA t_pos TYPE z2ui5_cl_layo_manager=>ty_t_positions.
    DATA temp7 LIKE LINE OF result->ms_layout-t_layout.
    DATA layout LIKE REF TO temp7.
      DATA temp8 LIKE sy-subrc.
        DATA temp9 TYPE z2ui5_cl_layo_manager=>ty_s_positions.
        DATA temp10 TYPE z2ui5_cl_layo_manager=>ty_s_positions.
        DATA pos LIKE temp9.
        DATA fname LIKE layout->fname.
        DATA rollname LIKE layout->rollname.

    CREATE OBJECT result.

    result->ms_layout-t_layout = t_comps.

    " Select Layout Heads

    SELECT SINGLE guid
                  layout
                  control
                  handle01
                  handle02
                  handle03
                  handle04
                  screen_format
                  descr
                  def
                  uname
      FROM z2ui5_t_11 INTO head
      WHERE guid = layout_guid
       ##SUBRC_OK.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.


    t_pos = select_layout_components( layout_guid ).

    IF t_pos IS INITIAL.
      RETURN.
    ENDIF.



    LOOP AT result->ms_layout-t_layout REFERENCE INTO layout.


      READ TABLE t_pos WITH KEY fname = layout->fname TRANSPORTING NO FIELDS.
      temp8 = sy-subrc.
      IF temp8 = 0.


        CLEAR temp9.

        READ TABLE t_pos INTO temp10 WITH KEY fname = layout->fname.
        IF sy-subrc = 0.
          temp9 = temp10.
        ENDIF.

        pos = temp9.
        MOVE-CORRESPONDING pos TO layout->*.

      ELSE.


        fname = layout->fname.

        rollname = layout->rollname.

        CLEAR layout->*.

        layout->fname    = fname.
        layout->rollname = rollname.

        TRY.
            layout->pos_guid = cl_system_uuid=>create_uuid_c32_static( ).
          CATCH cx_root.
        ENDTRY.

        layout->* = default_grid_layout( layout->* ).

      ENDIF.

      layout->guid   = layout_guid.
      layout->tlabel = set_text( layout->* ).

    ENDLOOP.

    MOVE-CORRESPONDING head TO result->ms_layout-s_head.
    result->ms_layout-t_layout = sort_by_sequence( result->ms_layout-t_layout ).
    result->ms_layout-t_layout = set_sub_columns( result->ms_layout-t_layout ).

  ENDMETHOD.

  METHOD create_layout_obj.
    DATA t_comp TYPE abap_component_tab.
    DATA comp LIKE LINE OF t_comp.
    DATA head TYPE z2ui5_cl_layo_manager=>ty_t_head.
    DATA def TYPE z2ui5_t_11.
      DATA t_pos TYPE z2ui5_cl_layo_manager=>ty_t_positions.
      DATA temp11 LIKE LINE OF t_comp.
      DATA r_comp LIKE REF TO temp11.
        DATA temp12 LIKE sy-subrc.
          FIELD-SYMBOLS <temp13> TYPE z2ui5_cl_layo_manager=>ty_s_positions.
DATA pos LIKE REF TO <temp13>.
          DATA temp14 LIKE sy-subrc.
          DATA temp15 TYPE ty_s_positions.
          DATA layout LIKE temp15.
          DATA guid TYPE sysuuid_c32.
      DATA index TYPE i.

    CREATE OBJECT result.

    " Save Ref for Sorting and Conversions
    result->mr_data = data.


    t_comp = z2ui5_cl_util=>rtti_get_t_attri_by_any( data ).


    LOOP AT t_comp INTO comp.
      IF comp-type->type_kind = cl_abap_elemdescr=>typekind_oref.
        DELETE t_comp.
      ENDIF.
    ENDLOOP.

    " Select Layout Heads

    head = select_layouts( layout_guid = layout_guid
                                 control     = control
                                 handle01    = handle01
                                 handle02    = handle02
                                 handle03    = handle03
                                 handle04    = handle04 ).


    def = get_default_layout( handle04    = handle04
                                    handle03    = handle03
                                    handle02    = handle02
                                    handle01    = handle01
                                    layout_guid = layout_guid
                                    format      = format
                                    head        = head ).

    IF def-layout IS NOT INITIAL.


      t_pos = select_layout_components( def-guid ).

      " Structure was changed - Field Added


      LOOP AT t_comp REFERENCE INTO r_comp.


        READ TABLE t_pos WITH KEY fname = r_comp->name TRANSPORTING NO FIELDS.
        temp12 = sy-subrc.
        IF NOT temp12 = 0.

          APPEND build_default_positions( comp  = r_comp
                                          guid  = def-guid
                                          index = 99 ) TO result->ms_layout-t_layout.

        ELSE.


          READ TABLE t_pos WITH KEY fname = r_comp->name ASSIGNING <temp13>.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.

GET REFERENCE OF <temp13> INTO pos.

          " Structure was changed - Field no longer exists

          READ TABLE t_comp WITH KEY name = pos->fname TRANSPORTING NO FIELDS.
          temp14 = sy-subrc.
          IF NOT temp14 = 0.
            CONTINUE.
          ENDIF.


          CLEAR temp15.

          layout = temp15.

          MOVE-CORRESPONDING pos->* TO layout.
          layout-rollname = r_comp->type->get_relative_name( ).
          layout-tlabel   = set_text( layout ).

          layout = get_conversion_exit( layout = layout
                                        type   = r_comp->type ).

          APPEND layout TO result->ms_layout-t_layout.

        ENDIF.

      ENDLOOP.

      MOVE-CORRESPONDING def TO result->ms_layout-s_head.
      result->ms_layout-t_layout = sort_by_sequence( result->ms_layout-t_layout ).
      result->ms_layout-t_layout = set_sub_columns( result->ms_layout-t_layout ).

    ELSE.

      TRY.

          guid = cl_system_uuid=>create_uuid_c32_static( ).
        CATCH cx_root.
      ENDTRY.

      " Default Layout

      index = 0.

      LOOP AT t_comp REFERENCE INTO r_comp.

        index = index + 1.

        APPEND build_default_positions( comp  = r_comp
                                        guid  = guid
                                        index = index ) TO result->ms_layout-t_layout.

      ENDLOOP.

      result->ms_layout-s_head-guid          = guid.
      result->ms_layout-s_head-layout        = 'DEFAULT'.
      result->ms_layout-s_head-control       = control.
      result->ms_layout-s_head-descr         = |{ handle04 } - { handle03 } - { format }|.
      result->ms_layout-s_head-def           = abap_true.
      result->ms_layout-s_head-handle01      = handle01.
      result->ms_layout-s_head-handle02      = handle02.
      result->ms_layout-s_head-handle03      = handle03.
      result->ms_layout-s_head-handle04      = handle04.
      result->ms_layout-s_head-screen_format = format.

    ENDIF.

  ENDMETHOD.

  METHOD build_default_positions.
        DATA pos_guid TYPE sysuuid_c32.

    result-fname    = comp->name.
    result-rollname = comp->type->get_relative_name( ).

    IF result-rollname IS INITIAL.
      result-rollname = result-fname.
    ENDIF.

    result = get_conversion_exit( layout = result
                                  type   = comp->type ).

    TRY.

        pos_guid = cl_system_uuid=>create_uuid_c32_static( ).
      CATCH cx_root.
    ENDTRY.

    " Default only 10 rows
    IF index <= 10.
      result-visible = abap_true.
    ENDIF.

    IF    result-fname = 'MANDT'
       OR result-fname = 'ROW_ID'
       OR result-fname = 'SELKZ'.
      result-visible = abap_false.
    ENDIF.

    result-guid     = guid.
    result-pos_guid = pos_guid.

    result = default_grid_layout( result ).

    result-tlabel = set_text( result ).

  ENDMETHOD.

  METHOD default_grid_layout.
    result = position.

    result-grid_label_xl = 2.
    result-grid_label_l  = 2.
    result-grid_label_m  = 2.
    result-grid_label_s  = 3.

    result-grid_value_xl = 4.
    result-grid_value_l  = 4.
    result-grid_value_m  = 4.
    result-grid_value_s  = 9.

  ENDMETHOD.

  METHOD get_default_layout.
    DATA temp16 TYPE z2ui5_t_11.
    DATA temp17 TYPE z2ui5_t_11.
    DATA temp18 TYPE z2ui5_t_11.
    DATA temp19 TYPE z2ui5_t_11.

    IF head IS INITIAL OR layout_guid IS NOT INITIAL.
      RETURN.
    ENDIF.

    " Default all Handles + User and Format

    CLEAR temp16.

    READ TABLE head INTO temp17 WITH KEY handle01 = handle01 handle02 = handle02 handle03 = handle03 handle04 = handle04 screen_format = format def = abap_true uname = sy-uname.
    IF sy-subrc = 0.
      temp16 = temp17.
    ENDIF.
    result = temp16.

    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    " Fall back to a global default (blank user) - never another user's
    " personal default

    CLEAR temp18.

    READ TABLE head INTO temp19 WITH KEY handle01 = handle01 handle02 = handle02 handle03 = handle03 handle04 = handle04 screen_format = format def = abap_true uname = space.
    IF sy-subrc = 0.
      temp18 = temp19.
    ENDIF.
    result = temp18.

    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

  ENDMETHOD.

  METHOD sort.

    FIELD-SYMBOLS <table> TYPE STANDARD TABLE.
      DATA temp20 TYPE z2ui5_cl_layo_manager=>ty_s_positions.
      DATA temp21 TYPE z2ui5_cl_layo_manager=>ty_s_positions.
      DATA selkz LIKE temp20.
        DATA temp22 TYPE abap_sortorder_tab.
        DATA temp23 LIKE LINE OF temp22.
        DATA sortorder LIKE temp22.
    DATA temp24 TYPE abap_sortorder_tab.
    DATA layout LIKE LINE OF ms_layout-t_layout.
      DATA temp25 LIKE LINE OF temp24.
      DATA temp1 LIKE temp25-descending.

    ASSIGN mr_data->* TO <table>.

    IF <table> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    IF <table> IS INITIAL.
      RETURN.
    ENDIF.

    IF no_selkz_sort = abap_false.

      CLEAR temp20.

      READ TABLE ms_layout-t_layout INTO temp21 WITH KEY fname = 'SELKZ'.
      IF sy-subrc = 0.
        temp20 = temp21.
      ENDIF.

      selkz = temp20.

      IF selkz-sorting = space.


        CLEAR temp22.

        temp23-descending = abap_true.
        temp23-name = 'SELKZ'.
        temp23-astext = abap_true.
        INSERT temp23 INTO TABLE temp22.

        sortorder = temp22.

      ENDIF.
    ENDIF.


    CLEAR temp24.
    temp24 = sortorder.

    LOOP AT ms_layout-t_layout INTO layout WHERE sorting <> space.


      IF layout-sorting = 'DESCENDING'.
        temp1 = abap_true.
      ELSE.
        CLEAR temp1.
      ENDIF.
      temp25-descending = temp1.
      temp25-name = layout-fname.
      INSERT temp25 INTO TABLE temp24.
    ENDLOOP.
    sortorder = temp24.

    IF sortorder IS INITIAL.
      RETURN.
    ENDIF.

    TRY.

        SORT <table>
             BY (sortorder).

      CATCH cx_root ##NO_HANDLER.
        " invalid dynamic sort spec: leave the table in its current order
    ENDTRY.

  ENDMETHOD.

  METHOD set_selkz.

    FIELD-SYMBOLS <table> TYPE STANDARD TABLE.
    DATA temp26 TYPE string.
    DATA temp27 TYPE string.
    DATA id LIKE temp26.
    FIELD-SYMBOLS <row> TYPE ANY.
      FIELD-SYMBOLS <id> TYPE any.
      FIELD-SYMBOLS <selkz> TYPE any.
        DATA temp28 TYPE abap_bool.

    CHECK mv_sel_mode <> space.

    ASSIGN mr_data->* TO <table>.

    IF <table> IS INITIAL.
      RETURN.
    ENDIF.

    IF t_event_arg IS INITIAL.
      RETURN.
    ENDIF.


    CLEAR temp26.

    READ TABLE t_event_arg INTO temp27 INDEX 1.
    IF sy-subrc = 0.
      temp26 = temp27.
    ENDIF.

    id = temp26.


    LOOP AT <table> ASSIGNING <row>.

      " check sy-subrc instead of IS ASSIGNED - a field symbol stays
      " assigned from the previous loop iteration

      ASSIGN COMPONENT mv_sel_key_field OF STRUCTURE <row> TO <id>.

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.


      ASSIGN COMPONENT mv_sel_field OF STRUCTURE <row> TO <selkz>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      IF <id> = id.

        IF <selkz> = abap_true.
          temp28 = abap_false.
        ELSE.
          temp28 = abap_true.
        ENDIF.
        <selkz> = temp28.

        IF mv_sel_mode = `M`.
          EXIT.
        ELSE.
          " if deselected, exit as well
          IF <selkz> = abap_false.
            EXIT.
          ENDIF.
        ENDIF.

      ELSE.

        IF mv_sel_mode <> `M`.
          <selkz> = abap_false.
        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD data_conversion.

    FIELD-SYMBOLS <tab> TYPE ANY TABLE.

    FIELD-SYMBOLS <any> TYPE data.
    DATA layout LIKE LINE OF ms_layout-t_layout.
        DATA temp29 LIKE sy-subrc.
          DATA ref LIKE abap_true.
        DATA tmp LIKE LINE OF ms_layout-t_layout.
          DATA temp30 LIKE sy-subrc.
          DATA sub LIKE LINE OF tmp-t_sub_col.
            DATA temp31 LIKE sy-subrc.
          FIELD-SYMBOLS <line> TYPE ANY.
            FIELD-SYMBOLS <value> TYPE any.
    ASSIGN mr_data->* TO <any>.

    IF <any> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    IF <any> IS INITIAL.
      RETURN.
    ENDIF.


    LOOP AT ms_layout-t_layout INTO layout
         WHERE     no_convexit  = abap_false
               AND convexit    <> space.

      IF layout-visible = abap_false.

        " is this a reference field?

        READ TABLE ms_layout-t_layout WITH KEY reference_field = layout-fname visible = abap_true TRANSPORTING NO FIELDS.
        temp29 = sy-subrc.
        IF temp29 = 0.

          ref = abap_true.
        ENDIF.


        LOOP AT ms_layout-t_layout INTO tmp WHERE t_sub_col IS NOT INITIAL AND visible = abap_true.


          READ TABLE tmp-t_sub_col WITH KEY fname = layout-fname TRANSPORTING NO FIELDS.
          temp30 = sy-subrc.
          IF temp30 = 0.
            ref = abap_true.
          ENDIF.


          LOOP AT tmp-t_sub_col INTO sub.


            READ TABLE ms_layout-t_layout WITH KEY fname = sub-fname reference_field = layout-fname TRANSPORTING NO FIELDS.
            temp31 = sy-subrc.
            IF temp31 = 0.
              ref = abap_true.
            ENDIF.
          ENDLOOP.

        ENDLOOP.

        IF ref = abap_false.
          CONTINUE.
        ENDIF.

        CLEAR ref.

      ENDIF.

      CASE ms_layout-s_head-control.
        WHEN ui_table OR m_table.

          ASSIGN mr_data->* TO <tab>.
          IF <tab> IS NOT ASSIGNED.
            CONTINUE.
          ENDIF.


          LOOP AT <tab> ASSIGNING <line>.


            ASSIGN COMPONENT layout-fname OF STRUCTURE <line> TO <value>.
            IF sy-subrc <> 0.
              CONTINUE.
            ENDIF.

            convert( EXPORTING i_output = output
                               i_layout = layout
                     CHANGING  c_value  = <value> ).

          ENDLOOP.

        WHEN ui_simpleform.

          ASSIGN COMPONENT layout-fname OF STRUCTURE <any> TO <value>.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.

          convert( EXPORTING i_output = output
                             i_layout = layout
                   CHANGING  c_value  = <value> ).

      ENDCASE.

    ENDLOOP.
  ENDMETHOD.

  METHOD convert.

    z2ui5_cl_util=>conv_exit(
      EXPORTING
        convexit = i_layout-convexit
        output   = i_output
      CHANGING
        value    = c_value ).

  ENDMETHOD.

  METHOD get_conversion_exit.

    DATA string TYPE string.
    DATA t_obj  TYPE REF TO data.
    DATA s_obj  TYPE REF TO data.

    FIELD-SYMBOLS <t_obj> TYPE STANDARD TABLE.
        FIELD-SYMBOLS <obj> TYPE data.
        FIELD-SYMBOLS <conv> TYPE any.

    result = layout.

    TRY.

        string = 'DD_X031L_TABLE'.

        CREATE DATA t_obj TYPE (string).
        CREATE DATA s_obj TYPE LINE OF (string).
        ASSIGN t_obj->* TO <t_obj>.

        ASSIGN s_obj->* TO <obj>.

        CALL METHOD type->('GET_DDIC_OBJECT')
          RECEIVING  p_object     = <t_obj>
          EXCEPTIONS not_found    = 1
                     no_ddic_type = 2.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        READ TABLE <t_obj> INDEX 1 ASSIGNING <obj>.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.


        ASSIGN COMPONENT 'CONVEXIT' OF STRUCTURE <obj> TO <conv>.
        IF <conv> IS NOT ASSIGNED.
          RETURN.
        ENDIF.

        IF <conv> = `MDLPD`. " GUID to Product works but the way back will fail (not in SAP GUI).
          RETURN.
        ENDIF.

        result-convexit = <conv>.

        IF result-convexit <> space.
          result-show_convexit = abap_true.

          IF type->type_kind = cl_abap_elemdescr=>typekind_num.
            IF    result-convexit = 'ALPH0'
               OR result-convexit = 'ALPHA'.
              " Serialization does not work with NUMC
              result-convexit = `NUMC`.
            ENDIF.

          ENDIF.
        ENDIF.

      CATCH cx_root.
        RETURN.
    ENDTRY.

  ENDMETHOD.

  METHOD set_selektion_criteria.

    mv_sel_mode      = sel_mode.
    mv_sel_field     = sel_field.
    mv_sel_key_field = sel_key_field.

  ENDMETHOD.

ENDCLASS.
