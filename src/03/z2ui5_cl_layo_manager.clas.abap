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
    TYPES ty_t_controls TYPE STANDARD TABLE OF ty_s_controls WITH EMPTY KEY.

    CLASS-DATA ui_table      TYPE control VALUE 'UI.TABLE' ##NO_TEXT.
    CLASS-DATA m_table       TYPE control VALUE 'M.TABLE' ##NO_TEXT.
    CLASS-DATA ui_simpleform TYPE control VALUE 'UI.SIMPLEFORM' ##NO_TEXT.
    "! the generic mode: a layout of registered control ids applied to the
    "! XML of any view - see factory_generic( ) and register( )
    CLASS-DATA generic       TYPE control VALUE 'GENERIC' ##NO_TEXT.
    CLASS-DATA others        TYPE control VALUE '' ##NO_TEXT.

    TYPES ty_s_head TYPE z2ui5_t_11.
    TYPES ty_t_head TYPE STANDARD TABLE OF ty_s_head WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_s_sub_columns,
        key   TYPE string,
        fname TYPE string,
      END OF ty_s_sub_columns.
    TYPES ty_t_sub_columns TYPE STANDARD TABLE OF ty_s_sub_columns WITH EMPTY KEY.

    TYPES  BEGIN OF ty_s_positions.
             INCLUDE TYPE z2ui5_t_12.
    TYPES:   tlabel            TYPE string,
             t_sub_col         TYPE ty_t_sub_columns,
             grid_layout       TYPE string,
             grid_layout_label TYPE string,
             show_convexit     TYPE abap_bool,
             convexit          TYPE string,
           END OF ty_s_positions.
    TYPES ty_t_positions TYPE STANDARD TABLE OF ty_s_positions WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_s_layout,
        s_head   TYPE ty_s_head,
        t_layout TYPE ty_t_positions,
      END OF ty_s_layout.

    TYPES:
      "! a control the app registered for the generic mode: its id in the view,
      "! the label the user sees for it, and the attribute that carries the label
      BEGIN OF ty_s_slot,
        id         TYPE string,
        label      TYPE string,
        label_attr TYPE string,
      END OF ty_s_slot.
    TYPES ty_t_slot TYPE STANDARD TABLE OF ty_s_slot WITH EMPTY KEY.

    DATA ms_layout     TYPE ty_s_layout.
    DATA ms_layout_tmp TYPE ty_s_layout.
    DATA mt_comps      TYPE ty_t_positions.
    DATA mt_sub_cols   TYPE ty_t_sub_columns.
    DATA mr_data       TYPE REF TO data.
    "! the registered controls of the generic mode, in registration order
    DATA mt_slots      TYPE ty_t_slot.

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

    "! a layout from the database by its guid, over the components (or the
    "! registered slots of the generic mode, passed as t_slots) of the
    "! current layout
    CLASS-METHODS factory_by_guid
      IMPORTING
        layout_guid   TYPE clike
        t_comps       TYPE ty_t_positions
        t_slots       TYPE ty_t_slot OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_layo_manager.

    "! The generic mode: a layout for ANY view. Register the controls the user
    "! may personalize with register( ) or register_by_xml( ), then let
    "! z2ui5_cl_layo_xml_builder=&gt;xml_apply_layout( ) apply the layout to the
    "! XML the app's view builder produced - visibility, order within the
    "! parent aggregation, label and width. The default variant is loaded on
    "! the first apply, like for a table.
    CLASS-METHODS factory_generic
      IMPORTING
        handle01      TYPE clike OPTIONAL
        handle02      TYPE clike OPTIONAL
        handle03      TYPE clike OPTIONAL
        handle04      TYPE clike OPTIONAL
        !format       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_layo_manager.

    "! register one control of the view for the generic mode (ids up to 30
    "! characters - the length of the position key). The label is what the
    "! user sees in the popup and what is written back into the view when
    "! the user renames the control; label_attr names the attribute that
    "! carries it when the default (text, title, header, headerText, label,
    "! placeholder - whichever the control has) is not the right one
    METHODS register
      IMPORTING
        !id           TYPE clike
        !label        TYPE clike OPTIONAL
        label_attr    TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_layo_manager.

    "! register every control of the view XML whose id starts with the prefix
    "! (all ids without one), with the label the view carries for it
    METHODS register_by_xml
      IMPORTING
        !xml          TYPE string
        !prefix       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_layo_manager.

    "! merges the registered slots with the default variant of the database -
    "! called by render_layout_function( ) and xml_apply_layout( ), needed by
    "! hand only to read the layout before either
    METHODS prepare.

    "! the current layout as the slots the generic application takes, in
    "! display order
    METHODS get_slots
      RETURNING
        VALUE(result) TYPE z2ui5_cl_layo_xml_tree=>ty_t_slot.

    "! the label of one position: set_text( ) for the data-bound modes, the
    "! alternative text or the registered label in the generic mode
    METHODS text_of
      IMPORTING
        !layout       TYPE ty_s_positions
      RETURNING
        VALUE(result) TYPE string.

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
    "! set by register( ), cleared by prepare( )
    DATA mv_slots_dirty TYPE abap_bool.

    METHODS build_slot_position
      IMPORTING
        slot          TYPE ty_s_slot
        guid          TYPE sysuuid_c32
      RETURNING
        VALUE(result) TYPE ty_s_positions.

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

    result = VALUE #( active = abap_true
                      ( control =  m_table       index = 1 attribute = 'TLABEL' )
                      ( control =  m_table       index = 2 attribute = 'VISIBLE' )
                      ( control =  m_table       index = 3 attribute = 'MERGE' )
                      ( control =  m_table       index = 4 attribute = 'WIDTH' )
                      ( control =  m_table       index = 5 attribute = 'ALTERNATIVE_TEXT' )
                      ( control =  m_table       index = 6 attribute = 'SEQUENCE' )
                      ( control =  m_table       index = 7 attribute = 'SUBCOLUMN' )
                      ( control =  m_table       index = 8 attribute = 'REFERENCE_FIELD' )
                      ( control =  m_table       index = 9 attribute = 'SORTING' )
                      ( control =  m_table       index = 10 attribute = 'NO_CONVEXIT' )
                      ( control =  ui_table      index = 1 attribute = 'TLABEL' )
                      ( control =  ui_table      index = 2 attribute = 'VISIBLE' )
                      ( control =  ui_table      index = 3 attribute = 'ALTERNATIVE_TEXT' )
                      ( control =  ui_table      index = 5 attribute = 'WIDTH' )
                      ( control =  others        index = 1 attribute = 'TLABEL' )
                      ( control =  others        index = 2 attribute = 'VISIBLE' )
                      ( control =  others        index = 3 attribute = 'SEQUENCE' )
                      ( control =  others        index = 4 attribute = 'ALTERNATIVE_TEXT' )
*                      ( control =  others        index = 5 attribute = 'REFERENCE_FIELD' )
*                      ( control =  others        index = 6 attribute = 'WIDTH' )
                      ( control =  ui_simpleform index = 1 attribute = 'TLABEL' )
                      ( control =  ui_simpleform index = 2 attribute = 'VISIBLE' )
                      ( control =  ui_simpleform index = 3 attribute = 'SEQUENCE' )
                      ( control =  ui_simpleform index = 4 attribute = 'ALTERNATIVE_TEXT' )
                      ( control =  ui_simpleform index = 5 attribute = 'REFERENCE_FIELD' )
                      ( control =  ui_simpleform index = 6 attribute = 'GRID_LAYOUT' )
                      ( control =  ui_simpleform index = 7 attribute = 'NO_CONVEXIT' )
                      ( control =  generic       index = 1 attribute = 'TLABEL' )
                      ( control =  generic       index = 2 attribute = 'VISIBLE' )
                      ( control =  generic       index = 3 attribute = 'SEQUENCE' )
                      ( control =  generic       index = 4 attribute = 'ALTERNATIVE_TEXT' )
                      ( control =  generic       index = 5 attribute = 'WIDTH' ) ).
  ENDMETHOD.

  METHOD factory_generic.

    result = NEW #( ).

    TRY.
        result->ms_layout-s_head-guid = cl_system_uuid=>create_uuid_c32_static( ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    result->ms_layout-s_head-layout        = 'DEFAULT'.
    result->ms_layout-s_head-control       = generic.
    result->ms_layout-s_head-descr         = |{ handle04 } - { handle03 } - { format }|.
    result->ms_layout-s_head-def           = abap_true.
    result->ms_layout-s_head-handle01      = handle01.
    result->ms_layout-s_head-handle02      = handle02.
    result->ms_layout-s_head-handle03      = handle03.
    result->ms_layout-s_head-handle04      = handle04.
    result->ms_layout-s_head-screen_format = format.

    result->mv_slots_dirty = abap_true.

  ENDMETHOD.

  METHOD register.

    DATA lv_id TYPE string.

    result = me.

    lv_id = id.
    IF lv_id IS INITIAL.
      RETURN.
    ENDIF.

    READ TABLE mt_slots REFERENCE INTO DATA(lr_slot) WITH KEY id = lv_id. "#EC CI_SORTSEQ
    IF sy-subrc <> 0.
      APPEND VALUE #( id = lv_id ) TO mt_slots.
      READ TABLE mt_slots REFERENCE INTO lr_slot INDEX lines( mt_slots ).
    ENDIF.

    IF label IS NOT INITIAL.
      lr_slot->label = label.
    ENDIF.
    IF lr_slot->label IS INITIAL.
      lr_slot->label = lv_id.
    ENDIF.
    IF label_attr IS NOT INITIAL.
      lr_slot->label_attr = label_attr.
    ENDIF.

    mv_slots_dirty = abap_true.

  ENDMETHOD.

  METHOD register_by_xml.

    DATA lv_prefix TYPE string.

    result = me.

    lv_prefix = prefix.
    DATA(lt_id) = z2ui5_cl_layo_xml_tree=>scan_ids( xml    = xml
                                                    prefix = lv_prefix ).

    LOOP AT lt_id REFERENCE INTO DATA(lr_id).
      register( id         = lr_id->id
                label      = lr_id->label
                label_attr = lr_id->label_attr ).
    ENDLOOP.

  ENDMETHOD.

  METHOD prepare.

    DATA lt_layout TYPE ty_t_positions.
    DATA ls_layout TYPE ty_s_positions.
    DATA lv_guid   TYPE sysuuid_c32.

    IF ms_layout-s_head-control <> generic OR mv_slots_dirty = abap_false.
      RETURN.
    ENDIF.
    mv_slots_dirty = abap_false.

    DATA(lt_head) = select_layouts( control  = ms_layout-s_head-control
                                    handle01 = ms_layout-s_head-handle01
                                    handle02 = ms_layout-s_head-handle02
                                    handle03 = ms_layout-s_head-handle03
                                    handle04 = ms_layout-s_head-handle04 ).

    DATA(ls_def) = get_default_layout( handle04    = ms_layout-s_head-handle04
                                       handle03    = ms_layout-s_head-handle03
                                       handle02    = ms_layout-s_head-handle02
                                       handle01    = ms_layout-s_head-handle01
                                       layout_guid = ``
                                       format      = ms_layout-s_head-screen_format
                                       head        = lt_head ).

    IF ls_def-layout IS NOT INITIAL.
      ms_layout-s_head = ls_def.
      DATA(lt_pos) = select_layout_components( ls_def-guid ).
    ENDIF.
    lv_guid = ms_layout-s_head-guid.

    LOOP AT mt_slots REFERENCE INTO DATA(lr_slot).

      READ TABLE lt_pos INTO DATA(ls_pos) WITH KEY fname = lr_slot->id. "#EC CI_SORTSEQ
      IF sy-subrc = 0.
        " a saved position - a control registered since the save is new and visible
        CLEAR ls_layout.
        MOVE-CORRESPONDING ls_pos TO ls_layout.
      ELSE.
        ls_layout = build_slot_position( slot = lr_slot->*
                                         guid = lv_guid ).
      ENDIF.
      ls_layout-tlabel = text_of( ls_layout ).
      APPEND ls_layout TO lt_layout.

    ENDLOOP.

    ms_layout-t_layout = sort_by_sequence( lt_layout ).

  ENDMETHOD.

  METHOD build_slot_position.

    result-fname   = slot-id.
    result-guid    = guid.
    result-visible = abap_true.

    TRY.
        result-pos_guid = cl_system_uuid=>create_uuid_c32_static( ).
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD get_slots.

    DATA ls_slot TYPE z2ui5_cl_layo_xml_tree=>ty_s_slot.

    LOOP AT ms_layout-t_layout REFERENCE INTO DATA(lr_layout).
      CLEAR ls_slot.
      ls_slot-id      = lr_layout->fname.
      ls_slot-visible = lr_layout->visible.
      ls_slot-width   = lr_layout->width.
      " the label is written into the view only when the user renamed the control
      IF lr_layout->alternative_text IS NOT INITIAL.
        ls_slot-label = lr_layout->tlabel.
      ENDIF.
      READ TABLE mt_slots REFERENCE INTO DATA(lr_slot) WITH KEY id = ls_slot-id. "#EC CI_SORTSEQ
      IF sy-subrc = 0.
        ls_slot-label_attr = lr_slot->label_attr.
      ENDIF.
      APPEND ls_slot TO result.
    ENDLOOP.

  ENDMETHOD.

  METHOD text_of.

    DATA lv_id TYPE string.

    IF ms_layout-s_head-control <> generic.
      result = set_text( layout ).
      RETURN.
    ENDIF.

    IF layout-alternative_text IS NOT INITIAL.
      result = layout-alternative_text.
      RETURN.
    ENDIF.

    lv_id = layout-fname.
    READ TABLE mt_slots REFERENCE INTO DATA(lr_slot) WITH KEY id = lv_id. "#EC CI_SORTSEQ
    IF sy-subrc = 0.
      result = lr_slot->label.
    ENDIF.
    IF result IS INITIAL.
      result = lv_id.
    ENDIF.

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

    IF layout_guid IS NOT INITIAL.

      SELECT guid,
             layout,
             control,
             handle01,
             handle02,
             handle03,
             handle04,
             screen_format,
             descr,
             def,
             uname
        FROM z2ui5_t_11
        WHERE guid = @layout_guid
        INTO CORRESPONDING FIELDS OF TABLE @result ##SUBRC_OK.

    ELSE.

      SELECT guid,
             layout,
             control,
             handle01,
             handle02,
             handle03,
             handle04,
             screen_format,
             descr,
             def,
             uname
        FROM z2ui5_t_11
        WHERE control  = @control
          AND handle01 = @handle01
          AND handle02 = @handle02
          AND handle03 = @handle03
          AND handle04 = @handle04
          " the user's own layouts and the shared ones (no user) - never
          " another user's personal layout
          AND ( uname = @sy-uname OR uname = @space )
        INTO CORRESPONDING FIELDS OF TABLE @result ##SUBRC_OK.

    ENDIF.

    " FALLBACK - Screen format was added later! We are changing an empty format to L.
    LOOP AT result REFERENCE INTO DATA(line) WHERE screen_format IS INITIAL.
      line->screen_format = screen_format_l.
    ENDLOOP.

  ENDMETHOD.

  METHOD select_layout_components.

    SELECT guid,
           pos_guid,
           fname,
           rollname,
           visible,
           merge,
           halign,
           importance,
           width,
           sequence,
           alternative_text,
           reference_field,
           subcolumn,
           grid_label_xl,
           grid_value_xl,
           grid_label_l,
           grid_value_l,
           grid_label_m,
           grid_value_m,
           grid_label_s,
           grid_value_s,
           no_convexit,
           sorting
      FROM z2ui5_t_12
      WHERE guid = @layout_guid
      INTO CORRESPONDING FIELDS OF TABLE @result ##SUBRC_OK.

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
    DATA(tab) = pos.

    DATA(index) = 0.

    DO 999 TIMES.

      index = index + 1.

      LOOP AT tab INTO DATA(line) WHERE sequence = index.
        APPEND line TO result.
      ENDLOOP.
      " delete after the loop: deleting inside LOOP AT ... WHERE skips the
      " row that shifts into the current position, dropping duplicates
      DELETE tab WHERE sequence = index.

    ENDDO.

    APPEND LINES OF tab TO result.

  ENDMETHOD.

  METHOD set_sub_columns.

    result = layout.

    LOOP AT result REFERENCE INTO DATA(line) WHERE subcolumn IS NOT INITIAL.

      SPLIT line->subcolumn AT ` ` INTO TABLE DATA(tab).

      line->t_sub_col = VALUE #( FOR t IN tab
                                 ( key = z2ui5_cl_util=>uuid_get_c32( ) fname = t ) ).

    ENDLOOP.

  ENDMETHOD.

  METHOD choose_layout.

    DATA(layouts) = select_layouts( control  = control
                                    handle01 = handle01
                                    handle02 = handle02
                                    handle03 = handle03
                                    handle04 = handle04  ).

    result = z2ui5_cl_layo_pop_w_sel=>factory( i_tab   = layouts
                                               i_title = 'Layouts' ).

  ENDMETHOD.

  METHOD factory_by_guid.

    result = NEW #( ).

    result->ms_layout-t_layout = t_comps.
    result->mt_slots           = t_slots.

    " Select Layout Heads
    SELECT SINGLE guid,
                  layout,
                  control,
                  handle01,
                  handle02,
                  handle03,
                  handle04,
                  screen_format,
                  descr,
                  def,
                  uname
      FROM z2ui5_t_11
      WHERE guid = @layout_guid
      INTO @DATA(head).

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " the head first: text_of( ) decides by the control. No early return on
    " an empty position table - a saved layout without positions is one
    " with every component hidden, not a missing one
    result->ms_layout-s_head = CORRESPONDING #( head ).

    DATA(t_pos) = select_layout_components( layout_guid ).

    LOOP AT result->ms_layout-t_layout REFERENCE INTO DATA(layout).

      IF line_exists( t_pos[ fname = layout->fname ] ).

        DATA(pos) = VALUE #( t_pos[ fname = layout->fname ] OPTIONAL ).
        MOVE-CORRESPONDING pos TO layout->*.

      ELSE.

        DATA(fname) = layout->fname.
        DATA(rollname) = layout->rollname.

        CLEAR layout->*.

        layout->fname    = fname.
        layout->rollname = rollname.

        TRY.
            layout->pos_guid = cl_system_uuid=>create_uuid_c32_static( ).
          CATCH cx_root ##NO_HANDLER.
        ENDTRY.

        layout->* = default_grid_layout( layout->* ).

        " the generic mode saves every position, hidden ones included - a
        " control without one was registered after the save and is shown
        IF result->ms_layout-s_head-control = generic.
          layout->visible = abap_true.
        ENDIF.

      ENDIF.

      layout->guid   = layout_guid.
      layout->tlabel = result->text_of( layout->* ).

    ENDLOOP.

    result->ms_layout-t_layout = sort_by_sequence( result->ms_layout-t_layout ).
    result->ms_layout-t_layout = set_sub_columns( result->ms_layout-t_layout ).

  ENDMETHOD.

  METHOD create_layout_obj.

    result = NEW #( ).

    " Save Ref for Sorting and Conversions
    result->mr_data = data.

    DATA(t_comp) = z2ui5_cl_util=>rtti_get_t_attri_by_any( data ).

    LOOP AT t_comp INTO DATA(comp).
      IF comp-type->type_kind = cl_abap_elemdescr=>typekind_oref.
        DELETE t_comp INDEX sy-tabix.
      ENDIF.
    ENDLOOP.

    " Select Layout Heads
    DATA(head) = select_layouts( layout_guid = layout_guid
                                 control     = control
                                 handle01    = handle01
                                 handle02    = handle02
                                 handle03    = handle03
                                 handle04    = handle04 ).

    DATA(def) = get_default_layout( handle04    = handle04
                                    handle03    = handle03
                                    handle02    = handle02
                                    handle01    = handle01
                                    layout_guid = layout_guid
                                    format      = format
                                    head        = head ).

    IF def-layout IS NOT INITIAL.

      DATA(t_pos) = select_layout_components( def-guid ).

      " Structure was changed - Field Added
      LOOP AT t_comp REFERENCE INTO DATA(r_comp).

        IF NOT line_exists( t_pos[ fname = r_comp->name ] ).

          APPEND build_default_positions( comp  = r_comp
                                          guid  = def-guid
                                          index = 99 ) TO result->ms_layout-t_layout.

        ELSE.

          DATA(pos) = REF #( t_pos[ fname = r_comp->name ] OPTIONAL ).

          " Structure was changed - Field no longer exists
          IF NOT line_exists( t_comp[ name = pos->fname ] ).
            CONTINUE.
          ENDIF.

          DATA(layout) = VALUE ty_s_positions( ).

          layout = CORRESPONDING #( pos->* ).
          layout-rollname = r_comp->type->get_relative_name( ).
          layout-tlabel   = set_text( layout ).

          layout = get_conversion_exit( layout = layout
                                        type   = r_comp->type ).

          APPEND layout TO result->ms_layout-t_layout.

        ENDIF.

      ENDLOOP.

      result->ms_layout-s_head   = CORRESPONDING #( def ).
      result->ms_layout-t_layout = sort_by_sequence( result->ms_layout-t_layout ).
      result->ms_layout-t_layout = set_sub_columns( result->ms_layout-t_layout ).

    ELSE.

      TRY.
          DATA(guid) = cl_system_uuid=>create_uuid_c32_static( ).
        CATCH cx_root ##NO_HANDLER.
      ENDTRY.

      " Default Layout
      DATA(index) = 0.

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

    result-fname    = comp->name.
    result-rollname = comp->type->get_relative_name( ).

    IF result-rollname IS INITIAL.
      result-rollname = result-fname.
    ENDIF.

    result = get_conversion_exit( layout = result
                                  type   = comp->type ).

    TRY.
        DATA(pos_guid) = cl_system_uuid=>create_uuid_c32_static( ).
      CATCH cx_root ##NO_HANDLER.
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

    IF head IS INITIAL OR layout_guid IS NOT INITIAL.
      RETURN.
    ENDIF.

    " Default all Handles + User and Format
    result = VALUE #( head[ handle01      = handle01
                            handle02      = handle02
                            handle03      = handle03
                            handle04      = handle04
                            screen_format = format
                            def           = abap_true
                            uname         = sy-uname ] OPTIONAL ).

    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    " Fall back to a global default (blank user) - never another user's
    " personal default
    result = VALUE #( head[ handle01      = handle01
                            handle02      = handle02
                            handle03      = handle03
                            handle04      = handle04
                            screen_format = format
                            def           = abap_true
                            uname         = space ] OPTIONAL ).

    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

  ENDMETHOD.

  METHOD sort.

    FIELD-SYMBOLS <table> TYPE STANDARD TABLE.

    " the generic mode has no data to sort
    IF mr_data IS NOT BOUND.
      RETURN.
    ENDIF.

    ASSIGN mr_data->* TO <table>.

    IF <table> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    IF <table> IS INITIAL.
      RETURN.
    ENDIF.

    IF no_selkz_sort = abap_false.
      DATA(selkz) = VALUE #( ms_layout-t_layout[ fname = 'SELKZ' ] OPTIONAL ).

      IF selkz-sorting = space.

        DATA(sortorder) = VALUE abap_sortorder_tab( ( descending = abap_true
                                                      name       = 'SELKZ'
                                                      astext     = abap_true ) ).

      ENDIF.
    ENDIF.

    sortorder = VALUE abap_sortorder_tab( BASE sortorder
                                          FOR layout IN ms_layout-t_layout  WHERE ( sorting <> space )
                                          ( descending = COND #( WHEN layout-sorting = 'DESCENDING' THEN abap_true )
                                            name       = layout-fname ) ).

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

    CHECK mv_sel_mode <> space.

    IF mr_data IS NOT BOUND.
      RETURN.
    ENDIF.

    ASSIGN mr_data->* TO <table>.

    IF <table> IS INITIAL.
      RETURN.
    ENDIF.

    IF t_event_arg IS INITIAL.
      RETURN.
    ENDIF.

    DATA(id) = VALUE #( t_event_arg[ 1 ] OPTIONAL ).

    LOOP AT <table> ASSIGNING FIELD-SYMBOL(<row>).

      " check sy-subrc instead of IS ASSIGNED - a field symbol stays
      " assigned from the previous loop iteration
      ASSIGN COMPONENT mv_sel_key_field OF STRUCTURE <row> TO FIELD-SYMBOL(<id>).

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      ASSIGN COMPONENT mv_sel_field OF STRUCTURE <row> TO FIELD-SYMBOL(<selkz>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      IF <id> = id.
        <selkz> = COND #( WHEN <selkz> = abap_true THEN abap_false ELSE abap_true ).

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

    IF mr_data IS NOT BOUND.
      RETURN.
    ENDIF.

    ASSIGN mr_data->* TO FIELD-SYMBOL(<any>).

    IF <any> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    IF <any> IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT ms_layout-t_layout INTO DATA(layout)
         WHERE     no_convexit  = abap_false
               AND convexit    <> space.

      IF layout-visible = abap_false.

        " is this a reference field?
        IF line_exists( ms_layout-t_layout[ reference_field = layout-fname
                                            visible         = abap_true ] ).
          DATA(ref) = abap_true.
        ENDIF.

        LOOP AT ms_layout-t_layout INTO DATA(tmp) WHERE t_sub_col IS NOT INITIAL AND visible = abap_true.

          IF line_exists( tmp-t_sub_col[ fname = layout-fname ] ).
            ref = abap_true.
          ENDIF.

          LOOP AT tmp-t_sub_col INTO DATA(sub).

            IF line_exists( ms_layout-t_layout[ fname           = sub-fname
                                                reference_field = layout-fname ] ).
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

          LOOP AT <tab> ASSIGNING FIELD-SYMBOL(<line>).

            ASSIGN COMPONENT layout-fname OF STRUCTURE <line> TO FIELD-SYMBOL(<value>).
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

    result = layout.

    TRY.

        string = 'DD_X031L_TABLE'.

        CREATE DATA t_obj TYPE (string).
        CREATE DATA s_obj TYPE LINE OF (string).
        ASSIGN t_obj->* TO <t_obj>.
        ASSIGN s_obj->* TO FIELD-SYMBOL(<obj>).

        CALL METHOD type->('GET_DDIC_OBJECT')
          RECEIVING  p_object     = <t_obj>
          EXCEPTIONS not_found    = 1
                     no_ddic_type = 2.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        ASSIGN <t_obj>[ 1 ] TO <obj>.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        ASSIGN COMPONENT 'CONVEXIT' OF STRUCTURE <obj> TO FIELD-SYMBOL(<conv>).
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
