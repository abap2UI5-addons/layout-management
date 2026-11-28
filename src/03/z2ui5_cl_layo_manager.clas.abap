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
    "! the generic mode: a layout of registered control ids applied to the
    "! XML of any view - see factory_generic( ) and register( )
    CLASS-DATA generic       TYPE control VALUE 'GENERIC' ##NO_TEXT.
    CLASS-DATA others        TYPE control VALUE '' ##NO_TEXT.

    TYPES ty_s_head TYPE z2ui5_t_11.
    TYPES ty_t_head TYPE STANDARD TABLE OF ty_s_head WITH DEFAULT KEY.

    " one layout to copy: the guid of the original and the handles (and,
    " when not empty, the description) the copy is saved under
    TYPES:
      BEGIN OF ty_s_copy,
        guid     TYPE z2ui5_t_11-guid,
        handle01 TYPE z2ui5_t_11-handle01,
        handle02 TYPE z2ui5_t_11-handle02,
        handle03 TYPE z2ui5_t_11-handle03,
        handle04 TYPE z2ui5_t_11-handle04,
        descr    TYPE z2ui5_t_11-descr,
      END OF ty_s_copy.
    TYPES ty_t_copy TYPE STANDARD TABLE OF ty_s_copy WITH DEFAULT KEY.

    " the selection of select_layouts_by_range( ) - one range per column of
    " the layout head
    TYPES ty_r_guid    TYPE RANGE OF z2ui5_t_11-guid.
    TYPES ty_r_layout  TYPE RANGE OF z2ui5_t_11-layout.
    TYPES ty_r_control TYPE RANGE OF z2ui5_t_11-control.
    TYPES ty_r_handle  TYPE RANGE OF z2ui5_t_11-handle01.
    TYPES ty_r_format  TYPE RANGE OF z2ui5_t_11-screen_format.
    TYPES ty_r_uname   TYPE RANGE OF z2ui5_t_11-uname.

    TYPES:
      BEGIN OF ty_s_sub_columns,
        key   TYPE string,
        fname TYPE string,
        descr TYPE abap_bool,
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
             "! the length of a column the browser formats itself, 0 for
             "! every other one: the conversion exit ALPHA on a CHAR or a
             "! NUMC column. z2ui5_cl_layo_xml_builder binds it with the
             "! type sap.ui.model.odata.type.String (isDigitSequence, this
             "! as maxLength) - see digit_type( )
             digits            TYPE i,
           END OF ty_s_positions.
    TYPES ty_t_positions TYPE STANDARD TABLE OF ty_s_positions WITH DEFAULT KEY.

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
    TYPES ty_t_slot TYPE STANDARD TABLE OF ty_s_slot WITH DEFAULT KEY.

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
        label         TYPE clike OPTIONAL
        label_attr    TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_layo_manager.

    "! register every control of the view XML whose id starts with the prefix
    "! (all ids without one), with the label the view carries for it
    METHODS register_by_xml
      IMPORTING
        !xml          TYPE string
        prefix        TYPE clike OPTIONAL
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

    "! abap_true when layout is a layout of the same table, form or view as
    "! this one: the same control and the same four handles
    METHODS is_same_layout
      IMPORTING
        !layout       TYPE REF TO z2ui5_cl_layo_manager
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS select_layouts
      IMPORTING
        layout_guid   TYPE clike OPTIONAL
        !control      TYPE clike OPTIONAL
        handle01      TYPE clike OPTIONAL
        handle02      TYPE clike OPTIONAL
        handle03      TYPE clike OPTIONAL
        handle04      TYPE clike OPTIONAL
        !format       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE  ty_t_head.

    "! Reads layout heads by ranges - for tools that copy or migrate layouts
    "! (select, then copy_layouts( )) without reading the layout tables
    "! themselves. Every range is optional, an empty one selects everything;
    "! the handles take the same range type (patterns with CP, e.g. APP*).
    "! The heads come as saved - no screen format fallback and no default
    "! demotion of select_layouts( ).
    "! all_users: abap_false - the user's own and the shared layouts, as the
    "! layout popup offers them; abap_true - also other users' personal ones
    "! check_auth: with all_users, ask z2ui5_if_layo_auth for every personal
    "! layout of another user (action READ_OTHERS) and leave out the ones it
    "! refuses - the shipped default refuses them; abap_false only for an admin
    "! tool that checks itself
    "! result: the heads ordered by guid - the guids and handles copy_layouts( )
    "! takes in its ty_s_copy
    CLASS-METHODS select_layouts_by_range
      IMPORTING
        guid          TYPE ty_r_guid    OPTIONAL
        !layout       TYPE ty_r_layout  OPTIONAL
        !control      TYPE ty_r_control OPTIONAL
        handle01      TYPE ty_r_handle  OPTIONAL
        handle02      TYPE ty_r_handle  OPTIONAL
        handle03      TYPE ty_r_handle  OPTIONAL
        handle04      TYPE ty_r_handle  OPTIONAL
        !format       TYPE ty_r_format  OPTIONAL
        uname         TYPE ty_r_uname   OPTIONAL
        all_users     TYPE abap_bool    DEFAULT abap_false
        check_auth    TYPE abap_bool    DEFAULT abap_true
      RETURNING
        VALUE(result) TYPE ty_t_head.

    CLASS-METHODS select_layout_components
      IMPORTING
        layout_guid   TYPE clike
      RETURNING
        VALUE(result) TYPE  ty_t_positions.

    "! Copies saved layouts with their positions under other handles - for
    "! example the layouts of one app and warehouse to another. Every copy
    "! gets new guids and keeps name, control, screen format, user and the
    "! default flag of its original; a copy flagged as default demotes the
    "! defaults of its new scope. One LUW.
    "! check_auth: ask z2ui5_if_layo_auth for every copy as the layout popup
    "! does for a save - abap_false only for an admin tool that checks itself
    "! iv_commit: abap_true (the default) ends with COMMIT WORK AND WAIT - and
    "! so also commits whatever the caller has open; abap_false neither
    "! commits nor rolls back, the copies are part of the caller's LUW and
    "! the caller commits them together with its own changes
    "! Raises z2ui5_cx_layo_error when an original does not exist or a copy
    "! is not authorized - checked before the first write, nothing is written
    "! - or when the database refuses the write: with iv_commit = abap_true
    "! after a ROLLBACK WORK, with abap_false without one - what was written
    "! is then still in the caller's LUW, the caller rolls it back.
    "! result: the heads of the copies
    CLASS-METHODS copy_layouts
      IMPORTING
        t_copy        TYPE ty_t_copy
        check_auth    TYPE abap_bool DEFAULT abap_true
        iv_commit     TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result) TYPE ty_t_head.

    "! output: abap_true formats the values for the screen, abap_false back.
    "! data: the table again - see set_data( )
    "! Leaves out the columns the view formats itself: NUMC always, ALPHA
    "! on CHAR with mv_alpha_in_browser - see digit_type( )
    METHODS data_conversion
      IMPORTING
        !output TYPE abap_bool
        !data   TYPE REF TO data OPTIONAL.

    "! Point the layout at the app's table again. Call it in every
    "! roundtrip before sort( ), set_selkz( ) or data_conversion( ), or pass
    "! the table to them directly: the draft of an app is serialized and
    "! restored between two roundtrips, and a data reference comes back as a
    "! reference to a COPY of the table, no longer to the app's attribute -
    "! so without it the layout sorts and converts a copy nobody sees.
    "! (A sticky session keeps the reference; then it is merely redundant.)
    METHODS set_data
      IMPORTING
        !data TYPE REF TO data.

    CLASS-METHODS set_text
      IMPORTING
        !layout       TYPE  ty_s_positions
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS sort_by_sequence
      IMPORTING
        pos           TYPE  ty_t_positions
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
        !format       TYPE clike   OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_layo_pop_w_sel.

    "! data: the table again - see set_data( )
    METHODS sort
      IMPORTING
        no_selkz_sort TYPE abap_bool    OPTIONAL
        !data         TYPE REF TO data OPTIONAL
          PREFERRED PARAMETER no_selkz_sort.

    "! The sorting of one column clicked in the table header: none -&gt;
    "! ascending -&gt; descending -&gt; none. Every other column loses its
    "! sorting, so the table is sorted by the column clicked last. Changes the
    "! layout only - sort( ) applies it to the data.
    "! result: abap_false when the layout has no column fname
    METHODS toggle_sorting
      IMPORTING
        fname         TYPE clike
      RETURNING
        VALUE(result) TYPE abap_bool.

    METHODS set_selektion_criteria
      IMPORTING
        sel_mode      TYPE string
        sel_field     TYPE string
        sel_key_field TYPE string.

    "! data: the table again - see set_data( )
    METHODS set_selkz
      IMPORTING
        t_event_arg TYPE string_table
        !data       TYPE REF TO data OPTIONAL.

    DATA mv_sel_mode      TYPE string.
    DATA mv_sel_field     TYPE string.
    DATA mv_sel_key_field TYPE string.

    "! abap_true: data_conversion( ) leaves the ALPHA columns of CHAR type
    "! alone, they stay internal - for an app whose view binds them with
    "! the digit type, as z2ui5_cl_layo_xml_builder does (see digit_type( )).
    "! Set it once after factory( ). Not for an app with an EDITABLE ALPHA
    "! column: the type refuses a letter there, so such a column needs the
    "! conversion in ABAP. NUMC columns are never converted in ABAP - there
    "! is no conversion routine for them, the view formats them
    DATA mv_alpha_in_browser TYPE abap_bool.

    "! abap_true when the view formats the column itself: a digit sequence
    "! (ALPHA on CHAR, NUMC) whose conversion the user did not switch off
    "! in the layout popup
    CLASS-METHODS digit_type
      IMPORTING
        !position     TYPE ty_s_positions
      RETURNING
        VALUE(result) TYPE abap_bool.

    "! the binding of a column the view formats itself (digit_type( )): the
    "! path with the type sap.ui.model.odata.type.String, isDigitSequence
    "! and the column's length as maxLength - `000000004711` is shown as
    "! `4711`, an input of `4711` parsed back to `000000004711`, a value
    "! with letters shown as it is. The type is named by the alias
    "! digit_type_alias; the view loads it with the core:require of
    "! digit_type_require( ) on the control or one of its parents
    CLASS-METHODS digit_type_binding
      IMPORTING
        path          TYPE clike
        position      TYPE ty_s_positions
      RETURNING
        VALUE(result) TYPE string.

    "! the value of the core:require a control needs for
    "! digit_type_binding( ) inside it (the namespace sap.ui.core declared
    "! as core). On UI5 1.71 a type named in a binding is resolved only when
    "! its module is loaded already - nothing loads it for the binding
    CLASS-METHODS digit_type_require
      RETURNING
        VALUE(result) TYPE string.

    CONSTANTS digit_type_alias  TYPE string VALUE `LayoDigitString` ##NO_TEXT.
    CONSTANTS digit_type_module TYPE string VALUE `sap/ui/model/odata/type/String` ##NO_TEXT.

  PROTECTED SECTION.
    CLASS-METHODS get_conversion_exit
      IMPORTING
        !type         TYPE REF TO cl_abap_datadescr
        !layout       TYPE ty_s_positions
      RETURNING
        VALUE(result) TYPE ty_s_positions.

    "! the length the column gets as maxLength of the digit type - for
    "! ALPHA on a CHAR column and NUMC (convexit NUMC: ALPHA or ALPH0 on a
    "! NUMC column), 0 for every other column
    CLASS-METHODS get_digits
      IMPORTING
        !type         TYPE REF TO cl_abap_datadescr
        convexit      TYPE clike
      RETURNING
        VALUE(result) TYPE i.

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
        !format       TYPE clike OPTIONAL
        head          TYPE  ty_t_head
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

    DATA temp85 TYPE z2ui5_cl_layo_manager=>ty_t_controls.
    DATA temp86 LIKE LINE OF temp85.
    CLEAR temp85.

    temp86-active = abap_true.
    temp86-control = m_table.
    temp86-index = 1.
    temp86-attribute = 'TLABEL'.
    INSERT temp86 INTO TABLE temp85.
    temp86-control = m_table.
    temp86-index = 2.
    temp86-attribute = 'VISIBLE'.
    INSERT temp86 INTO TABLE temp85.
    temp86-control = m_table.
    temp86-index = 3.
    temp86-attribute = 'MERGE'.
    INSERT temp86 INTO TABLE temp85.
    temp86-control = m_table.
    temp86-index = 4.
    temp86-attribute = 'WIDTH'.
    INSERT temp86 INTO TABLE temp85.
    temp86-control = m_table.
    temp86-index = 5.
    temp86-attribute = 'ALTERNATIVE_TEXT'.
    INSERT temp86 INTO TABLE temp85.
    temp86-control = m_table.
    temp86-index = 6.
    temp86-attribute = 'SEQUENCE'.
    INSERT temp86 INTO TABLE temp85.
    temp86-control = m_table.
    temp86-index = 7.
    temp86-attribute = 'SUBCOLUMN'.
    INSERT temp86 INTO TABLE temp85.
    temp86-control = m_table.
    temp86-index = 8.
    temp86-attribute = 'REFERENCE_FIELD'.
    INSERT temp86 INTO TABLE temp85.
    temp86-control = m_table.
    temp86-index = 9.
    temp86-attribute = 'SORTING'.
    INSERT temp86 INTO TABLE temp85.
    temp86-control = m_table.
    temp86-index = 10.
    temp86-attribute = 'NO_CONVEXIT'.
    INSERT temp86 INTO TABLE temp85.
    temp86-control = ui_table.
    temp86-index = 1.
    temp86-attribute = 'TLABEL'.
    INSERT temp86 INTO TABLE temp85.
    temp86-control = ui_table.
    temp86-index = 2.
    temp86-attribute = 'VISIBLE'.
    INSERT temp86 INTO TABLE temp85.
    temp86-control = ui_table.
    temp86-index = 3.
    temp86-attribute = 'ALTERNATIVE_TEXT'.
    INSERT temp86 INTO TABLE temp85.
    temp86-control = ui_table.
    temp86-index = 5.
    temp86-attribute = 'WIDTH'.
    INSERT temp86 INTO TABLE temp85.
    temp86-control = others.
    temp86-index = 1.
    temp86-attribute = 'TLABEL'.
    INSERT temp86 INTO TABLE temp85.
    temp86-control = others.
    temp86-index = 2.
    temp86-attribute = 'VISIBLE'.
    INSERT temp86 INTO TABLE temp85.
    temp86-control = others.
    temp86-index = 3.
    temp86-attribute = 'SEQUENCE'.
    INSERT temp86 INTO TABLE temp85.
    temp86-control = others.
    temp86-index = 4.
    temp86-attribute = 'ALTERNATIVE_TEXT'.
    INSERT temp86 INTO TABLE temp85.
    temp86-control = ui_simpleform.
    temp86-index = 1.
    temp86-attribute = 'TLABEL'.
    INSERT temp86 INTO TABLE temp85.
    temp86-control = ui_simpleform.
    temp86-index = 2.
    temp86-attribute = 'VISIBLE'.
    INSERT temp86 INTO TABLE temp85.
    temp86-control = ui_simpleform.
    temp86-index = 3.
    temp86-attribute = 'SEQUENCE'.
    INSERT temp86 INTO TABLE temp85.
    temp86-control = ui_simpleform.
    temp86-index = 4.
    temp86-attribute = 'ALTERNATIVE_TEXT'.
    INSERT temp86 INTO TABLE temp85.
    temp86-control = ui_simpleform.
    temp86-index = 5.
    temp86-attribute = 'REFERENCE_FIELD'.
    INSERT temp86 INTO TABLE temp85.
    temp86-control = ui_simpleform.
    temp86-index = 6.
    temp86-attribute = 'GRID_LAYOUT'.
    INSERT temp86 INTO TABLE temp85.
    temp86-control = ui_simpleform.
    temp86-index = 7.
    temp86-attribute = 'NO_CONVEXIT'.
    INSERT temp86 INTO TABLE temp85.
    temp86-control = generic.
    temp86-index = 1.
    temp86-attribute = 'TLABEL'.
    INSERT temp86 INTO TABLE temp85.
    temp86-control = generic.
    temp86-index = 2.
    temp86-attribute = 'VISIBLE'.
    INSERT temp86 INTO TABLE temp85.
    temp86-control = generic.
    temp86-index = 3.
    temp86-attribute = 'SEQUENCE'.
    INSERT temp86 INTO TABLE temp85.
    temp86-control = generic.
    temp86-index = 4.
    temp86-attribute = 'ALTERNATIVE_TEXT'.
    INSERT temp86 INTO TABLE temp85.
    temp86-control = generic.
    temp86-index = 5.
    temp86-attribute = 'WIDTH'.
    INSERT temp86 INTO TABLE temp85.
    result = temp85.
  ENDMETHOD.

  METHOD factory_generic.

    CREATE OBJECT result.

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
    DATA lr_slot TYPE REF TO ty_s_slot.
    DATA temp87 LIKE sy-subrc.
      FIELD-SYMBOLS <temp88> TYPE z2ui5_cl_layo_manager=>ty_s_slot.
      DATA temp89 TYPE z2ui5_cl_layo_manager=>ty_s_slot.

    result = me.

    lv_id = id.
    IF lv_id IS INITIAL.
      RETURN.
    ENDIF.



    READ TABLE mt_slots WITH KEY id = lv_id TRANSPORTING NO FIELDS.
    temp87 = sy-subrc.
    IF temp87 = 0.           "#EC CI_SORTSEQ

      READ TABLE mt_slots WITH KEY id = lv_id ASSIGNING <temp88>.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.
GET REFERENCE OF <temp88> INTO lr_slot.        "#EC CI_SORTSEQ
    ELSE.

      CLEAR temp89.
      temp89-id = lv_id.
      INSERT temp89 INTO TABLE mt_slots REFERENCE INTO lr_slot.
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
    DATA lt_id TYPE z2ui5_cl_layo_xml_tree=>ty_t_id.
    DATA temp90 LIKE LINE OF lt_id.
    DATA lr_id LIKE REF TO temp90.

    result = me.

    lv_prefix = prefix.

    lt_id = z2ui5_cl_layo_xml_tree=>scan_ids( xml    = xml
                                                    prefix = lv_prefix ).



    LOOP AT lt_id REFERENCE INTO lr_id.
      register( id         = lr_id->id
                label      = lr_id->label
                label_attr = lr_id->label_attr ).
    ENDLOOP.

  ENDMETHOD.

  METHOD prepare.

    DATA lt_layout TYPE ty_t_positions.
    DATA ls_layout TYPE ty_s_positions.
    DATA lv_guid   TYPE sysuuid_c32.
    DATA lt_head TYPE z2ui5_cl_layo_manager=>ty_t_head.
    DATA ls_def TYPE z2ui5_cl_layo_manager=>ty_s_head.
      DATA lt_pos TYPE z2ui5_cl_layo_manager=>ty_t_positions.
    DATA temp91 LIKE LINE OF mt_slots.
    DATA lr_slot LIKE REF TO temp91.
      DATA temp92 LIKE sy-subrc.
        FIELD-SYMBOLS <temp13> LIKE LINE OF lt_pos.
        DATA temp14 LIKE sy-tabix.

    IF ms_layout-s_head-control <> generic OR mv_slots_dirty = abap_false.
      RETURN.
    ENDIF.
    mv_slots_dirty = abap_false.


    lt_head = select_layouts( control  = ms_layout-s_head-control
                                    handle01 = ms_layout-s_head-handle01
                                    handle02 = ms_layout-s_head-handle02
                                    handle03 = ms_layout-s_head-handle03
                                    handle04 = ms_layout-s_head-handle04 ).


    ls_def = get_default_layout( handle04 = ms_layout-s_head-handle04
                                       handle03 = ms_layout-s_head-handle03
                                       handle02 = ms_layout-s_head-handle02
                                       handle01 = ms_layout-s_head-handle01
                                       format   = ms_layout-s_head-screen_format
                                       head     = lt_head ).

    IF ls_def-layout IS NOT INITIAL.
      ms_layout-s_head = ls_def.

      lt_pos = select_layout_components( ls_def-guid ).
    ENDIF.
    lv_guid = ms_layout-s_head-guid.



    LOOP AT mt_slots REFERENCE INTO lr_slot.


      READ TABLE lt_pos WITH KEY fname = lr_slot->id TRANSPORTING NO FIELDS.
      temp92 = sy-subrc.
      IF temp92 = 0.  "#EC CI_SORTSEQ
        " a saved position - a control registered since the save is new and visible


        temp14 = sy-tabix.
        READ TABLE lt_pos WITH KEY fname = lr_slot->id ASSIGNING <temp13>.
        sy-tabix = temp14.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        MOVE-CORRESPONDING <temp13> TO ls_layout. "#EC CI_SORTSEQ
      ELSE.
        ls_layout = build_slot_position( slot = lr_slot->*
                                         guid = lv_guid ).
      ENDIF.
      ls_layout-tlabel = text_of( ls_layout ).
      INSERT ls_layout INTO TABLE lt_layout.

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

    DATA temp93 LIKE LINE OF ms_layout-t_layout.
    DATA lr_layout LIKE REF TO temp93.
      DATA temp94 LIKE sy-subrc.
        FIELD-SYMBOLS <temp95> LIKE LINE OF mt_slots.
        DATA temp96 LIKE sy-tabix.
    LOOP AT ms_layout-t_layout REFERENCE INTO lr_layout.
      CLEAR ls_slot.
      ls_slot-id      = lr_layout->fname.
      ls_slot-visible = lr_layout->visible.
      ls_slot-width   = lr_layout->width.
      " the label is written into the view only when the user renamed the control
      IF lr_layout->alternative_text IS NOT INITIAL.
        ls_slot-label = lr_layout->tlabel.
      ENDIF.

      READ TABLE mt_slots WITH KEY id = ls_slot-id TRANSPORTING NO FIELDS.
      temp94 = sy-subrc.
      IF temp94 = 0.    "#EC CI_SORTSEQ


        temp96 = sy-tabix.
        READ TABLE mt_slots WITH KEY id = ls_slot-id ASSIGNING <temp95>.
        sy-tabix = temp96.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        ls_slot-label_attr = <temp95>-label_attr. "#EC CI_SORTSEQ
      ENDIF.
      INSERT ls_slot INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD text_of.

    DATA lv_id TYPE string.
    DATA temp97 LIKE sy-subrc.
      FIELD-SYMBOLS <temp98> LIKE LINE OF mt_slots.
      DATA temp99 LIKE sy-tabix.

    IF ms_layout-s_head-control <> generic.
      result = set_text( layout ).
      RETURN.
    ENDIF.

    IF layout-alternative_text IS NOT INITIAL.
      result = layout-alternative_text.
      RETURN.
    ENDIF.

    lv_id = layout-fname.

    READ TABLE mt_slots WITH KEY id = lv_id TRANSPORTING NO FIELDS.
    temp97 = sy-subrc.
    IF temp97 = 0.           "#EC CI_SORTSEQ


      temp99 = sy-tabix.
      READ TABLE mt_slots WITH KEY id = lv_id ASSIGNING <temp98>.
      sy-tabix = temp99.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      result = <temp98>-label.            "#EC CI_SORTSEQ
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
    DATA temp100 TYPE string.
    DATA fmt LIKE temp100.
    DATA other_default TYPE abap_bool.
    DATA temp15 LIKE sy-subrc.
    DATA temp1 TYPE xsdboolean.
    DATA temp101 LIKE LINE OF result.
    DATA line LIKE REF TO temp101.

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
        ORDER BY PRIMARY KEY
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
          " the user's own layouts and the shared ones (no user) - never
          " another user's personal layout
          AND ( uname = sy-uname OR uname = space )
        ORDER BY PRIMARY KEY
         ##SUBRC_OK.

    ENDIF.

    " FALLBACK - Screenformat was added! Layouts without a format are taken
    " for the requested format (L when none is requested). The check for an
    " existing default runs against that same format - with the raw, empty
    " format it found the format-less default itself and demoted it.

    IF format IS INITIAL.
      temp100 = screen_format_l.
    ELSE.
      temp100 = format.
    ENDIF.

    fmt = temp100.



    READ TABLE result WITH KEY screen_format = fmt def = abap_true TRANSPORTING NO FIELDS.
    temp15 = sy-subrc.

    temp1 = boolc( temp15 = 0 ).
    other_default = temp1.



    LOOP AT result REFERENCE INTO line WHERE screen_format IS INITIAL.

      IF other_default = abap_true.
        line->def = abap_false.
      ENDIF.

      line->screen_format = fmt.

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
      ORDER BY PRIMARY KEY
       ##SUBRC_OK.

  ENDMETHOD.

  METHOD set_text.

    IF layout-alternative_text IS INITIAL.
      result = z2ui5_cl_layo_context=>rtti_get_data_element_texts( layout-rollname  )-long.
    ELSE.
      result = z2ui5_cl_layo_context=>rtti_get_data_element_texts( layout-alternative_text )-long.
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
        INSERT line INTO TABLE result.
      ENDLOOP.
      " delete after the loop: deleting inside LOOP AT ... WHERE skips the
      " row that shifts into the current position, dropping duplicates
      DELETE tab WHERE sequence = index.

    ENDDO.

    INSERT LINES OF tab INTO TABLE result.

  ENDMETHOD.

  METHOD set_sub_columns.
    DATA temp102 LIKE LINE OF result.
    DATA line LIKE REF TO temp102.
      TYPES temp1 TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
DATA tab TYPE temp1.
      DATA temp103 TYPE z2ui5_cl_layo_manager=>ty_t_sub_columns.
      DATA t LIKE LINE OF tab.
        DATA temp104 LIKE LINE OF temp103.

    result = layout.

    " every row anew from its SUBCOLUMN - factory_by_guid( ) merges the saved
    " positions into the rows of the layout shown before, and a row without
    " subcolumns kept the subcolumns of that layout


    LOOP AT result REFERENCE INTO line.

      CLEAR line->t_sub_col.
      IF line->subcolumn IS INITIAL.
        CONTINUE.
      ENDIF.



      SPLIT line->subcolumn AT ` ` INTO TABLE tab.


      CLEAR temp103.

      LOOP AT tab INTO t.

        temp104-key = z2ui5_cl_layo_context=>uuid_get_c32( ).
        temp104-fname = t.
        INSERT temp104 INTO TABLE temp103.
      ENDLOOP.
      line->t_sub_col = temp103.

    ENDLOOP.

  ENDMETHOD.

  METHOD choose_layout.

    DATA layouts TYPE z2ui5_cl_layo_manager=>ty_t_head.
    layouts = select_layouts( control  = control
                                    handle01 = handle01
                                    handle02 = handle02
                                    handle03 = handle03
                                    handle04 = handle04
                                    format   = format  ).

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
    DATA temp105 LIKE LINE OF result->ms_layout-t_layout.
    DATA layout LIKE REF TO temp105.
      DATA convexit LIKE layout->convexit.
      DATA show_convexit LIKE layout->show_convexit.
      DATA digits LIKE layout->digits.
      DATA temp106 LIKE sy-subrc.
        DATA temp107 TYPE z2ui5_cl_layo_manager=>ty_s_positions.
        DATA temp108 TYPE z2ui5_cl_layo_manager=>ty_s_positions.
        DATA pos LIKE temp107.
        DATA fname LIKE layout->fname.
        DATA rollname LIKE layout->rollname.

    CREATE OBJECT result.

    result->ms_layout-t_layout = t_comps.
    result->mt_slots           = t_slots.

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
      .

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " the head first: text_of( ) decides by the control. No early return on
    " an empty position table - a saved layout without positions is one
    " with every component hidden, not a missing one
    MOVE-CORRESPONDING head TO result->ms_layout-s_head.


    t_pos = select_layout_components( layout_guid ).



    LOOP AT result->ms_layout-t_layout REFERENCE INTO layout.

      " what the type of the component says (conversion exit, digit type)
      " is no part of the saved position - it is kept, not read back empty

      convexit = layout->convexit.

      show_convexit = layout->show_convexit.

      digits = layout->digits.


      READ TABLE t_pos WITH KEY fname = layout->fname TRANSPORTING NO FIELDS.
      temp106 = sy-subrc.
      IF temp106 = 0.


        CLEAR temp107.

        READ TABLE t_pos INTO temp108 WITH KEY fname = layout->fname.
        IF sy-subrc = 0.
          temp107 = temp108.
        ENDIF.

        pos = temp107.
        layout->* = layout->*.
MOVE-CORRESPONDING pos TO layout->*.

      ELSE.


        fname = layout->fname.

        rollname = layout->rollname.

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

      layout->guid          = layout_guid.
      layout->tlabel        = result->text_of( layout->* ).
      layout->convexit      = convexit.
      layout->show_convexit = show_convexit.
      layout->digits        = digits.

    ENDLOOP.

    result->ms_layout-t_layout = sort_by_sequence( result->ms_layout-t_layout ).
    result->ms_layout-t_layout = set_sub_columns( result->ms_layout-t_layout ).

  ENDMETHOD.

  METHOD create_layout_obj.
    DATA t_comp TYPE abap_component_tab.
    DATA head TYPE z2ui5_cl_layo_manager=>ty_t_head.
    DATA def TYPE z2ui5_cl_layo_manager=>ty_s_head.
      DATA t_pos TYPE z2ui5_cl_layo_manager=>ty_t_positions.
      DATA temp109 LIKE LINE OF t_comp.
      DATA r_comp LIKE REF TO temp109.
        DATA temp110 LIKE sy-subrc.
          FIELD-SYMBOLS <temp111> TYPE z2ui5_cl_layo_manager=>ty_s_positions.
DATA pos LIKE REF TO <temp111>.
          DATA temp112 TYPE ty_s_positions.
          DATA layout LIKE temp112.
          DATA guid TYPE sysuuid_c32.
      DATA index TYPE i.

    CREATE OBJECT result.

    " Save Ref for Sorting and Conversions
    result->mr_data = data.


    t_comp = z2ui5_cl_layo_context=>rtti_get_t_attri_by_any( data ).

    DELETE t_comp WHERE type->type_kind = cl_abap_elemdescr=>typekind_oref.

    " Select Layout Heads

    head = select_layouts( control  = control
                                 handle01 = handle01
                                 handle02 = handle02
                                 handle03 = handle03
                                 handle04 = handle04
                                 format   = format  ).


    def = get_default_layout( handle04 = handle04
                                    handle03 = handle03
                                    handle02 = handle02
                                    handle01 = handle01
                                    format   = format
                                    head     = head ).

    IF def-layout IS NOT INITIAL.


      t_pos = select_layout_components( def-guid ).

      " Structure was changed - Field Added


      LOOP AT t_comp REFERENCE INTO r_comp.


        READ TABLE t_pos WITH KEY fname = r_comp->name TRANSPORTING NO FIELDS.
        temp110 = sy-subrc.
        IF NOT temp110 = 0.

          INSERT build_default_positions( comp  = r_comp
                                          guid  = def-guid
                                          index = 99 ) INTO TABLE result->ms_layout-t_layout.

        ELSE.

          " positions of fields that no longer exist are never reached - the
          " loop runs over the fields of the structure

          READ TABLE t_pos WITH KEY fname = r_comp->name ASSIGNING <temp111>.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.

GET REFERENCE OF <temp111> INTO pos.


          CLEAR temp112.

          layout = temp112.

          MOVE-CORRESPONDING pos->* TO layout.
          layout-rollname = r_comp->type->get_relative_name( ).
          layout-tlabel   = set_text( layout ).

          layout = get_conversion_exit( layout = layout
                                        type   = r_comp->type ).

          INSERT layout INTO TABLE result->ms_layout-t_layout.

        ENDIF.

      ENDLOOP.

      MOVE-CORRESPONDING def TO result->ms_layout-s_head.
      result->ms_layout-t_layout = sort_by_sequence( result->ms_layout-t_layout ).
      result->ms_layout-t_layout = set_sub_columns( result->ms_layout-t_layout ).

    ELSE.

      TRY.

          guid = cl_system_uuid=>create_uuid_c32_static( ).
        CATCH cx_root ##NO_HANDLER.
      ENDTRY.

      " Default Layout

      index = 0.

      LOOP AT t_comp REFERENCE INTO r_comp.

        index = index + 1.

        INSERT build_default_positions( comp  = r_comp
                                        guid  = guid
                                        index = index ) INTO TABLE result->ms_layout-t_layout.

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
    DATA temp113 TYPE string.
    DATA lv_format LIKE temp113.
    DATA temp114 TYPE z2ui5_cl_layo_manager=>ty_s_head.
    DATA temp115 TYPE z2ui5_cl_layo_manager=>ty_s_head.
    DATA temp116 TYPE z2ui5_cl_layo_manager=>ty_s_head.
    DATA temp117 TYPE z2ui5_cl_layo_manager=>ty_s_head.
    DATA temp118 TYPE z2ui5_cl_layo_manager=>ty_s_head.
    DATA temp119 TYPE z2ui5_cl_layo_manager=>ty_s_head.

    IF head IS INITIAL.
      RETURN.
    ENDIF.

    " select_layouts( ) reads a layout without a format as the requested one,
    " L when none is requested - so no format asked for is L as well;
    " compared as is, a default never matched

    temp113 = format.

    lv_format = temp113.
    IF lv_format IS INITIAL.
      lv_format = screen_format_l.
    ENDIF.

    " Default all Handles + User and Format

    CLEAR temp114.

    READ TABLE head INTO temp115 WITH KEY handle01 = handle01 handle02 = handle02 handle03 = handle03 handle04 = handle04 screen_format = lv_format def = abap_true uname = sy-uname.
    IF sy-subrc = 0.
      temp114 = temp115.
    ENDIF.
    result = temp114.

    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    " Fall back to a global default (blank user) - never another user's
    " personal default

    CLEAR temp116.

    READ TABLE head INTO temp117 WITH KEY handle01 = handle01 handle02 = handle02 handle03 = handle03 handle04 = handle04 screen_format = lv_format def = abap_true uname = space.
    IF sy-subrc = 0.
      temp116 = temp117.
    ENDIF.
    result = temp116.

    IF result IS NOT INITIAL.
      RETURN.
    ENDIF.

    " no default at all - the first global layout of the handles and format

    CLEAR temp118.

    READ TABLE head INTO temp119 WITH KEY handle01 = handle01 handle02 = handle02 handle03 = handle03 handle04 = handle04 screen_format = lv_format uname = space.
    IF sy-subrc = 0.
      temp118 = temp119.
    ENDIF.
    result = temp118.

  ENDMETHOD.

  METHOD set_data.

    mr_data = data.

  ENDMETHOD.

  METHOD sort.

    FIELD-SYMBOLS <table> TYPE STANDARD TABLE.
    DATA temp120 LIKE sy-subrc.
      DATA selkz TYPE z2ui5_cl_layo_manager=>ty_s_positions.
      FIELD-SYMBOLS <temp16> LIKE LINE OF ms_layout-t_layout.
      DATA temp17 LIKE sy-tabix.
        DATA temp121 TYPE abap_sortorder_tab.
        DATA temp122 LIKE LINE OF temp121.
        DATA sortorder LIKE temp121.
    DATA temp123 TYPE abap_sortorder_tab.
    DATA layout LIKE LINE OF ms_layout-t_layout.
      DATA temp124 LIKE LINE OF temp123.
      DATA temp2 TYPE xsdboolean.

    " the table again - see set_data( )
    IF data IS BOUND.
      mr_data = data.
    ENDIF.

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

    " SELKZ first - but only when the table has it: a sort order naming a
    " component the table lacks raises, and the CATCH below then dropped
    " every sort the user had configured

    READ TABLE ms_layout-t_layout WITH KEY fname = 'SELKZ' TRANSPORTING NO FIELDS.
    temp120 = sy-subrc.
    IF     no_selkz_sort = abap_false
       AND temp120 = 0.



      temp17 = sy-tabix.
      READ TABLE ms_layout-t_layout WITH KEY fname = 'SELKZ' ASSIGNING <temp16>.
      sy-tabix = temp17.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      selkz = <temp16>.

      IF selkz-sorting = space.


        CLEAR temp121.

        temp122-descending = abap_true.
        temp122-name = 'SELKZ'.
        temp122-astext = abap_true.
        INSERT temp122 INTO TABLE temp121.

        sortorder = temp121.

      ENDIF.
    ENDIF.


    CLEAR temp123.
    temp123 = sortorder.

    LOOP AT ms_layout-t_layout INTO layout WHERE sorting <> space.


      temp2 = boolc( layout-sorting = 'DESCENDING' ).
      temp124-descending = temp2.
      temp124-name = layout-fname.
      INSERT temp124 INTO TABLE temp123.
    ENDLOOP.
    sortorder = temp123.

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
    DATA temp125 TYPE string.
    DATA temp126 TYPE string.
    DATA id LIKE temp125.
    FIELD-SYMBOLS <row> TYPE ANY.
      FIELD-SYMBOLS <id> TYPE any.
      FIELD-SYMBOLS <selkz> TYPE any.
        DATA temp3 TYPE xsdboolean.

    " the table again - see set_data( )
    IF data IS BOUND.
      mr_data = data.
    ENDIF.

    IF mv_sel_mode = space.
      RETURN.
    ENDIF.

    IF mr_data IS NOT BOUND.
      RETURN.
    ENDIF.

    ASSIGN mr_data->* TO <table>.

    IF <table> IS NOT ASSIGNED OR <table> IS INITIAL.
      RETURN.
    ENDIF.

    IF t_event_arg IS INITIAL.
      RETURN.
    ENDIF.


    CLEAR temp125.

    READ TABLE t_event_arg INTO temp126 INDEX 1.
    IF sy-subrc = 0.
      temp125 = temp126.
    ENDIF.

    id = temp125.


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

        temp3 = boolc( <selkz> <> abap_true ).
        <selkz> = temp3.

        IF mv_sel_mode = `M`.
          EXIT.
        ELSEIF <selkz> = abap_false.
          " if deselected, exit as well
          EXIT.
        ENDIF.

      ELSEIF mv_sel_mode <> `M`.
        <selkz> = abap_false.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD data_conversion.

    FIELD-SYMBOLS <tab> TYPE ANY TABLE.
    FIELD-SYMBOLS <any> TYPE data.
    DATA layout LIKE LINE OF ms_layout-t_layout.
        DATA temp127 LIKE sy-subrc.
        DATA temp128 LIKE sy-subrc.
          DATA ref LIKE abap_true.
        DATA tmp LIKE LINE OF ms_layout-t_layout.
          DATA temp129 LIKE sy-subrc.
          DATA temp130 LIKE sy-subrc.
          DATA sub LIKE LINE OF tmp-t_sub_col.
            DATA temp131 LIKE sy-subrc.
            DATA temp132 LIKE sy-subrc.
          FIELD-SYMBOLS <line> TYPE ANY.
            FIELD-SYMBOLS <value> TYPE any.

    " the table again - see set_data( )
    IF data IS BOUND.
      mr_data = data.
    ENDIF.

    IF mr_data IS NOT BOUND.
      RETURN.
    ENDIF.


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

      " a digit sequence the view formats stays internal: NUMC always - no
      " conversion routine exists for it, the call converted nothing - and
      " ALPHA on CHAR when the app said its view formats it
      IF     digit_type( layout ) = abap_true
         AND (    layout-convexit   = `NUMC`
               OR mv_alpha_in_browser = abap_true ).
        CONTINUE.
      ENDIF.

      IF layout-visible = abap_false.

        " is this a reference field?


        temp128 = sy-subrc.
        READ TABLE ms_layout-t_layout WITH KEY reference_field = layout-fname visible = abap_true TRANSPORTING NO FIELDS.
        temp127 = sy-subrc.
        sy-subrc = temp128.
        IF temp127 = 0.

          ref = abap_true.
        ENDIF.


        LOOP AT ms_layout-t_layout INTO tmp WHERE t_sub_col IS NOT INITIAL AND visible = abap_true.



          temp130 = sy-subrc.
          READ TABLE tmp-t_sub_col WITH KEY fname = layout-fname TRANSPORTING NO FIELDS.
          temp129 = sy-subrc.
          sy-subrc = temp130.
          IF temp129 = 0.
            ref = abap_true.
          ENDIF.


          LOOP AT tmp-t_sub_col INTO sub.



            temp132 = sy-subrc.
            READ TABLE ms_layout-t_layout WITH KEY fname = sub-fname reference_field = layout-fname TRANSPORTING NO FIELDS.
            temp131 = sy-subrc.
            sy-subrc = temp132.
            IF temp131 = 0.
              ref = abap_true.
            ENDIF.
          ENDLOOP.

        ENDLOOP.

        IF ref = abap_false.
          CONTINUE.
        ENDIF.

        CLEAR ref.

      ENDIF.

      " a failed ASSIGN COMPONENT leaves the field symbol on what it pointed
      " to before - test sy-subrc, or a column missing in the data converts
      " the previous column a second time
      CASE ms_layout-s_head-control.
        WHEN ui_table OR m_table.

          UNASSIGN <tab>.
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

    " a value the exit refuses, or an exit the system does not have, leaves
    " the cell as it is - one odd cell must not end the whole table
    TRY.
        z2ui5_cl_layo_context=>conv_exit(
          EXPORTING
            convexit = i_layout-convexit
            output   = i_output
          CHANGING
            value    = c_value ).
      CATCH z2ui5_cx_layo_error ##NO_HANDLER.
    ENDTRY.

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
                     no_ddic_type = 2
                     OTHERS       = 3.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        UNASSIGN <obj>.
        READ TABLE <t_obj> INDEX 1 ASSIGNING <obj>.
        IF <obj> IS NOT ASSIGNED.
          RETURN.
        ENDIF.


        ASSIGN COMPONENT 'CONVEXIT' OF STRUCTURE <obj> TO <conv>.
        IF <conv> IS NOT ASSIGNED.
          RETURN.
        ENDIF.

        " GUID to Product works but the way back will fail (not in SAP GUI).
        IF <conv> = `MDLPD`.
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

        result-digits = get_digits( type     = type
                                    convexit = result-convexit ).

      CATCH cx_root.
        RETURN.
    ENDTRY.

  ENDMETHOD.

  METHOD get_digits.

    " the browser does what ALPHA does only for these two: a digit sequence
    " loses its leading zeros on the screen and gets them back on input.
    " Every other exit (CUNIT, MATN1, ...) stays a conversion in ABAP
    IF NOT (    ( type->type_kind = cl_abap_elemdescr=>typekind_char AND convexit = `ALPHA` )
             OR ( type->type_kind = cl_abap_elemdescr=>typekind_num  AND convexit = `NUMC` ) ).
      RETURN.
    ENDIF.

    " the length in characters - a C10 or N10 has 10 of them
    result = type->length / cl_abap_char_utilities=>charsize.

  ENDMETHOD.

  METHOD digit_type.

    DATA temp4 TYPE xsdboolean.
    temp4 = boolc( position-digits > 0 AND position-no_convexit = abap_false ).
    result = temp4.

  ENDMETHOD.

  METHOD digit_type_binding.

    result = |\{path:'{ path }',type:'{ digit_type_alias }',|
          && |constraints:\{isDigitSequence:true,maxLength:{ position-digits }\}\}|.

  ENDMETHOD.

  METHOD digit_type_require.

    result = |\{{ digit_type_alias }:'{ digit_type_module }'\}|.

  ENDMETHOD.

  METHOD toggle_sorting.

    DATA temp133 LIKE sy-subrc.
    FIELD-SYMBOLS <temp134> TYPE z2ui5_cl_layo_manager=>ty_s_positions.
DATA column LIKE REF TO <temp134>.
    DATA temp135 TYPE string.
    DATA sorting LIKE temp135.
    DATA temp136 LIKE LINE OF ms_layout-t_layout.
    DATA position LIKE REF TO temp136.
    READ TABLE ms_layout-t_layout WITH KEY fname = fname TRANSPORTING NO FIELDS.
    temp133 = sy-subrc.
    IF NOT temp133 = 0.
      RETURN.
    ENDIF.

    READ TABLE ms_layout-t_layout WITH KEY fname = fname ASSIGNING <temp134>.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.

GET REFERENCE OF <temp134> INTO column.


    CASE column->sorting.
      WHEN space.
        temp135 = `ASCENDING`.
      WHEN `ASCENDING`.
        temp135 = `DESCENDING`.
      WHEN OTHERS.
        temp135 = ``.
    ENDCASE.

    sorting = temp135.



    LOOP AT ms_layout-t_layout REFERENCE INTO position WHERE sorting IS NOT INITIAL.
      CLEAR position->sorting.
    ENDLOOP.

    column->sorting = sorting.
    result = abap_true.

  ENDMETHOD.

  METHOD set_selektion_criteria.

    mv_sel_mode      = sel_mode.
    mv_sel_field     = sel_field.
    mv_sel_key_field = sel_key_field.

  ENDMETHOD.

  METHOD select_layouts_by_range.
    DATA selected LIKE result.
    DATA head LIKE LINE OF selected.

    IF all_users = abap_true.

      SELECT * FROM z2ui5_t_11 INTO TABLE result
        WHERE guid          IN guid
          AND layout        IN layout
          AND control       IN control
          AND handle01      IN handle01
          AND handle02      IN handle02
          AND handle03      IN handle03
          AND handle04      IN handle04
          AND screen_format IN format
          AND uname         IN uname
        ORDER BY PRIMARY KEY
         ##SUBRC_OK.

    ELSE.

      SELECT * FROM z2ui5_t_11 INTO TABLE result
        WHERE guid          IN guid
          AND layout        IN layout
          AND control       IN control
          AND handle01      IN handle01
          AND handle02      IN handle02
          AND handle03      IN handle03
          AND handle04      IN handle04
          AND screen_format IN format
          AND uname         IN uname
          " the user's own layouts and the shared ones (no user) - never
          " another user's personal layout
          AND ( uname = sy-uname OR uname = space )
        ORDER BY PRIMARY KEY
         ##SUBRC_OK.

    ENDIF.

    IF all_users = abap_false OR check_auth = abap_false.
      RETURN.
    ENDIF.

    " another user's personal layout only when the hook allows it - rebuilt
    " instead of DELETE inside the loop

    selected = result.
    CLEAR result.

    LOOP AT selected INTO head.
      IF    head-uname IS INITIAL
         OR head-uname = sy-uname
         OR z2ui5_cl_layo_auth=>check( action = z2ui5_if_layo_auth=>cs_action-read_others
                                       head   = head ) = abap_true.
        INSERT head INTO TABLE result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD copy_layouts.

    TYPES temp2 TYPE RANGE OF z2ui5_t_11-guid.
DATA source_guids TYPE temp2.
    TYPES temp3 TYPE RANGE OF z2ui5_t_11-guid.
DATA new_guids    TYPE temp3.
    TYPES temp4 TYPE STANDARD TABLE OF z2ui5_t_12 WITH DEFAULT KEY.
DATA positions    TYPE temp4.
    DATA temp137 LIKE source_guids.
    DATA c LIKE LINE OF t_copy.
      DATA temp138 LIKE LINE OF temp137.
    TYPES temp5 TYPE STANDARD TABLE OF z2ui5_t_11 WITH DEFAULT KEY.
DATA sources TYPE temp5.
    TYPES temp6 TYPE STANDARD TABLE OF z2ui5_t_12 WITH DEFAULT KEY.
DATA source_positions TYPE temp6.
    DATA copy LIKE LINE OF t_copy.
      DATA temp141 TYPE z2ui5_t_11.
      DATA temp142 TYPE z2ui5_t_11.
      DATA head LIKE temp141.
        DATA temp143 TYPE string.
        DATA action LIKE temp143.
      DATA position LIKE LINE OF source_positions.
      DATA temp144 LIKE LINE OF new_guids.
        DATA x_sql TYPE REF TO cx_sy_open_sql_db.
    DATA temp145 TYPE ty_t_head.
    DATA h LIKE LINE OF result.
    DATA defaults LIKE temp145.
      TYPES temp7 TYPE RANGE OF z2ui5_t_11-handle03.
DATA scope03 TYPE temp7.
      TYPES temp8 TYPE RANGE OF z2ui5_t_11-guid.
DATA demote TYPE temp8.
      DATA temp147 LIKE scope03.
      DATA d LIKE LINE OF defaults.
        DATA temp148 LIKE LINE OF temp147.
      TYPES temp9 TYPE STANDARD TABLE OF z2ui5_t_11 WITH DEFAULT KEY.
DATA candidates TYPE temp9.
      DATA candidate LIKE LINE OF candidates.
            DATA temp150 LIKE LINE OF demote.

    IF t_copy IS INITIAL.
      RETURN.
    ENDIF.


    CLEAR temp137.

    LOOP AT t_copy INTO c.

      temp138-sign = `I`.
      temp138-option = `EQ`.
      temp138-low = c-guid.
      INSERT temp138 INTO TABLE temp137.
    ENDLOOP.
    source_guids = temp137.



    SELECT * FROM z2ui5_t_11 INTO TABLE sources
      WHERE guid IN source_guids
      ORDER BY PRIMARY KEY
       ##SUBRC_OK.



    SELECT * FROM z2ui5_t_12 INTO TABLE source_positions
      WHERE guid IN source_guids
      ORDER BY PRIMARY KEY
       ##SUBRC_OK.


    LOOP AT t_copy INTO copy.


      CLEAR temp141.

      READ TABLE sources INTO temp142 WITH KEY guid = copy-guid.
      IF sy-subrc = 0.
        temp141 = temp142.
      ENDIF.

      head = temp141.
      IF head IS INITIAL.
        RAISE EXCEPTION TYPE z2ui5_cx_layo_error
          EXPORTING val = |Layout { copy-guid } not found|.
      ENDIF.

      head-guid     = z2ui5_cl_layo_context=>uuid_get_c32( ).
      head-handle01 = copy-handle01.
      head-handle02 = copy-handle02.
      head-handle03 = copy-handle03.
      head-handle04 = copy-handle04.
      IF copy-descr IS NOT INITIAL.
        head-descr = copy-descr.
      ENDIF.

      IF check_auth = abap_true.

        IF head-uname IS INITIAL.
          temp143 = z2ui5_if_layo_auth=>cs_action-save_shared.
        ELSE.
          temp143 = z2ui5_if_layo_auth=>cs_action-save_own.
        ENDIF.

        action = temp143.
        IF z2ui5_cl_layo_auth=>check( action = action
                                      head   = head ) = abap_false.
          RAISE EXCEPTION TYPE z2ui5_cx_layo_error
            EXPORTING val = |Not authorized to save layout { head-layout } for { head-handle01 } { head-handle03 } { head-handle04 }|.
        ENDIF.
      ENDIF.


      LOOP AT source_positions INTO position WHERE guid = copy-guid.
        position-guid     = head-guid.
        position-pos_guid = z2ui5_cl_layo_context=>uuid_get_c32( ).
        INSERT position INTO TABLE positions.
      ENDLOOP.

      INSERT head INTO TABLE result.

      CLEAR temp144.
      temp144-sign = `I`.
      temp144-option = `EQ`.
      temp144-low = head-guid.
      INSERT temp144 INTO TABLE new_guids.

    ENDLOOP.

    " with iv_commit = abap_false the LUW is the caller's: no ROLLBACK here,
    " the exception tells the caller to roll back. INSERT FROM TABLE does
    " not set sy-subrc on a duplicate key - it raises cx_sy_open_sql_db
    TRY.
        INSERT z2ui5_t_11 FROM TABLE result ##SUBRC_OK.
        IF positions IS NOT INITIAL.
          INSERT z2ui5_t_12 FROM TABLE positions ##SUBRC_OK.
        ENDIF.

      CATCH cx_sy_open_sql_db INTO x_sql.
        IF iv_commit = abap_true.
          ROLLBACK WORK.
        ENDIF.
        RAISE EXCEPTION TYPE z2ui5_cx_layo_error
          EXPORTING val      = `Layouts could not be copied`
                    previous = x_sql.
    ENDTRY.

    " a copied default demotes the defaults of its new scope, as a save does
    " - a layout saved before the screen format existed has none and is a
    " default of the same scope. One read of the candidates, one update.

    CLEAR temp145.

    LOOP AT result INTO h WHERE def = abap_true.
      INSERT h INTO TABLE temp145.
    ENDLOOP.

    defaults = temp145.
    IF defaults IS NOT INITIAL.






      CLEAR temp147.

      LOOP AT defaults INTO d.

        temp148-sign = `I`.
        temp148-option = `EQ`.
        temp148-low = d-handle03.
        INSERT temp148 INTO TABLE temp147.
      ENDLOOP.
      scope03 = temp147.



      SELECT * FROM z2ui5_t_11 INTO TABLE candidates
        WHERE handle03 IN scope03
          AND def       = abap_true
          AND guid NOT IN new_guids
        ORDER BY PRIMARY KEY
         ##SUBRC_OK.


      LOOP AT candidates INTO candidate.
        LOOP AT defaults INTO head WHERE control  = candidate-control
                                     AND handle01 = candidate-handle01
                                     AND handle02 = candidate-handle02
                                     AND handle03 = candidate-handle03
                                     AND handle04 = candidate-handle04
                                     AND uname    = candidate-uname.
          IF    candidate-screen_format = head-screen_format
             OR ( head-screen_format = screen_format_l AND candidate-screen_format IS INITIAL )
             OR ( head-screen_format IS INITIAL AND candidate-screen_format = screen_format_l ).

            CLEAR temp150.
            temp150-sign = `I`.
            temp150-option = `EQ`.
            temp150-low = candidate-guid.
            INSERT temp150 INTO TABLE demote.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDLOOP.

      IF demote IS NOT INITIAL.
        UPDATE z2ui5_t_11 SET def = abap_false WHERE guid IN demote ##SUBRC_OK.
      ENDIF.

    ENDIF.

    IF iv_commit = abap_true.
      COMMIT WORK AND WAIT.
    ENDIF.

  ENDMETHOD.

  METHOD is_same_layout.

    IF layout IS NOT BOUND.
      RETURN.
    ENDIF.

    " an IF, not xsdbool( ): the 7.02 downport writes the condition into one
    " line longer than 255 characters
    IF     ms_layout-s_head-control  = layout->ms_layout-s_head-control
       AND ms_layout-s_head-handle01 = layout->ms_layout-s_head-handle01
       AND ms_layout-s_head-handle02 = layout->ms_layout-s_head-handle02
       AND ms_layout-s_head-handle03 = layout->ms_layout-s_head-handle03
       AND ms_layout-s_head-handle04 = layout->ms_layout-s_head-handle04.
      result = abap_true.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
