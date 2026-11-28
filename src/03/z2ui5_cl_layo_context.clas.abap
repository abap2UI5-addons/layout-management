CLASS z2ui5_cl_layo_context DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_s_name_value,
        n TYPE string,
        v TYPE string,
      END OF ty_s_name_value.
    TYPES ty_t_name_value TYPE STANDARD TABLE OF ty_s_name_value WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_msg,
        text       TYPE string,
        id         TYPE string,
        no         TYPE string,
        type       TYPE string,
        v1         TYPE string,
        v2         TYPE string,
        v3         TYPE string,
        v4         TYPE string,
        timestampl TYPE timestampl,
        t_meta     TYPE ty_t_name_value,
      END OF ty_s_msg,
      ty_t_msg TYPE STANDARD TABLE OF ty_s_msg WITH DEFAULT KEY.

    " Environment-abstracted character/format constants. Callers must read
    " these from z2ui5_cl_util instead of referencing cl_abap_char_utilities /
    " cl_abap_format directly, so the dependency on those SAP standard classes
    " lives in exactly one place (this class' class_constructor) and can be
    " ported once for non-ABAP runtimes (e.g. transpiled JS).
    CLASS-DATA cv_char_util_newline        TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_char_util_cr_lf          TYPE c LENGTH 2 READ-ONLY.

    CLASS-DATA cv_char_util_horizontal_tab TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_char_util_charsize       TYPE i          READ-ONLY.

    CLASS-DATA cv_format_e_xml_attr             TYPE i          READ-ONLY.

    " RTTI type-kind / kind / visibility constants, so callers can branch on
    " stored type_kind/kind fields without referencing cl_abap_typedescr /
    " cl_abap_objectdescr directly.
    CLASS-DATA cv_typedescr_typekind_table   TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_typedescr_typekind_dref    TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_typedescr_typekind_oref    TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_typedescr_typekind_struct1 TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_typedescr_typekind_struct2 TYPE c LENGTH 1 READ-ONLY.

    " the three elementary kinds whose JSON form is not their ABAP form
    " (ISO date/time strings, ISO timestamps) - what a caller converting a
    " scalar between the two representations has to branch on
    CLASS-DATA cv_typedescr_typekind_date    TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_typedescr_typekind_time    TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_typedescr_typekind_packed  TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_typedescr_kind_struct      TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_typedescr_kind_elem        TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_typedescr_kind_ref         TYPE c LENGTH 1 READ-ONLY.

    CLASS-DATA cv_objectdescr_public         TYPE c LENGTH 1 READ-ONLY.

    CLASS-METHODS class_constructor.

    CLASS-METHODS msg_get_t
      IMPORTING
        val           TYPE any
        val2          TYPE any OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_t_msg.

    " depth guards the mutual recursion between these two (an include whose
    " expansion reaches itself would otherwise be an unbounded stack).
    " Optional and last in the list, so every existing caller is unaffected
    CLASS-METHODS rtti_get_t_attri_by_include
      IMPORTING
        !type         TYPE REF TO cl_abap_datadescr
        depth         TYPE i DEFAULT 0
      RETURNING
        VALUE(result) TYPE abap_component_tab.

    CLASS-METHODS expand_components
      IMPORTING
        val           TYPE abap_component_tab
        depth         TYPE i DEFAULT 0
      RETURNING
        VALUE(result) TYPE abap_component_tab.

    CLASS-METHODS rtti_get_classname_by_ref
      IMPORTING
        val           TYPE REF TO object
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS c_trim
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_get_t_attri_by_oref
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_attrdescr_tab.

    CLASS-METHODS rtti_get_t_attri_by_any
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE cl_abap_structdescr=>component_table.

    CLASS-METHODS rtti_get_type_kind
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_check_ref_data
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS itab_filter_by_val
      IMPORTING
        val         TYPE clike
        fields      TYPE string_table OPTIONAL
        ignore_case TYPE abap_bool DEFAULT abap_false
      CHANGING
        !tab        TYPE STANDARD TABLE.

    CLASS-METHODS conv_copy_ref_data
      IMPORTING
        !from         TYPE any
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS conv_exit
      IMPORTING
        convexit TYPE clike
        output   TYPE abap_bool DEFAULT abap_false
        from     TYPE any       OPTIONAL
      CHANGING
        value    TYPE data
      RAISING
        z2ui5_cx_layo_error.

    CLASS-METHODS rtti_check_clike
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    TYPES:
      BEGIN OF ty_s_data_element_text,
        header TYPE string,
        short  TYPE string,
        medium TYPE string,
        long   TYPE string,
      END OF ty_s_data_element_text.

    TYPES:
      BEGIN OF ty_s_class_descr,
        classname   TYPE string,
        description TYPE string,
      END OF ty_s_class_descr.

    TYPES ty_t_classes TYPE STANDARD TABLE OF ty_s_class_descr WITH DEFAULT KEY.

    CLASS-METHODS check_abap_cloud
      RETURNING
        VALUE(result) TYPE abap_bool.

    " the system fields sy_get hands out, in the types SYST gives them
    TYPES:
      BEGIN OF ty_s_sy,
        datum TYPE d,
        uzeit TYPE t,
        uname TYPE c LENGTH 12,
        sysid TYPE c LENGTH 8,
        saprl TYPE c LENGTH 4,
      END OF ty_s_sy.

    " THE one place that reads a system field for its VALUE - date, time,
    " user, system id, release. Every other class asks here
    " (sy_get( )-uname), for two reasons: ABAP for Cloud Development reports
    " the old system fields on every statement that names one ("The old
    " variant of SY-DATUM should not be used ..."), so one reader is one
    " finding per field instead of one per use; and the day one of them
    " has to come from another API, it changes here and nowhere else.
    " Not meant: sy-subrc, sy-tabix and sy-index - those are the result of
    " the statement before them and have to be read where it stands
    CLASS-METHODS sy_get
      RETURNING
        VALUE(result) TYPE ty_s_sy.

    CLASS-METHODS uuid_get_c32
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_get_data_element_texts
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE ty_s_data_element_text.

    " read_description defaults to off: filling it costs one repository
    " read PER implementing class (SEO_CLASS_READ / XCO), and the common
    " caller - interface implementer discovery - only ever reads the
    " classname. Optional and last in the list, so it is additive
    CLASS-METHODS rtti_get_classes_impl_intf
      IMPORTING
        val              TYPE clike
        read_description TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result)    TYPE ty_t_classes.

    " abap_true for values that can be rendered into a text without a
    " conversion dump - the elementary types. Anything structured (struct,
    " table, reference) must be excluded before a generic `|{ val }|`.
    CLASS-METHODS rtti_check_printable
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    " The source-code position an exception was raised at, as
    " `<program> / <include> / line <n>`; empty when the runtime supplies
    " none. Wraps cx_root->get_source_position so the dependency on the SAP
    " standard exception API stays inside this class. This is what identifies
    " the failing method for exceptions that carry no text of their own -
    " a CX_SY_MOVE_CAST_ERROR only says which types did not match, the
    " position says where.
    CLASS-METHODS error_get_source_position
      IMPORTING
        val           TYPE REF TO cx_root
      RETURNING
        VALUE(result) TYPE string.

    " Every public, non-static, non-constant attribute of an exception that
    " has a printable value - the class-specific payload the text alone does
    " not carry (source/target type of a cast error, the offending value of a
    " conversion error, DB object of an SQL error, ...). The general cx_root
    " attributes (PREVIOUS, TEXTID, IS_RESUMABLE, KERNEL_ERRID) are skipped -
    " the caller renders them itself or they carry no information.
    CLASS-METHODS error_get_attributes
      IMPORTING
        val           TYPE REF TO cx_root
      RETURNING
        VALUE(result) TYPE ty_t_name_value.

    CLASS-METHODS msg_map
      IMPORTING
        name          TYPE clike
        val           TYPE data
        msg           TYPE ty_s_msg
      RETURNING
        VALUE(result) TYPE ty_s_msg.

    " abap_true when one component of a row holds the search text - the
    " per-field half of itab_filter_by_val. A component that is not printable
    " (a table of children, a reference) holds no text and answers false
    CLASS-METHODS itab_filter_check_field
      IMPORTING
        field         TYPE any
        search        TYPE string
        ignore_case   TYPE abap_bool
      RETURNING
        VALUE(result) TYPE abap_bool.

  PROTECTED SECTION.

    CLASS-METHODS rtti_get_class_descr_on_cloud
      IMPORTING
        classname     TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_internal
      IMPORTING
        val           TYPE any
        " the RAP-shape check of a structure is a property of its TYPE - a
        " table decides it once for its rows (msg_get_internal_tab) and hands
        " the answer down, instead of asking for every row
        iv_check_rap  TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result) TYPE ty_t_msg.

    CLASS-METHODS msg_get_by_oref
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE ty_t_msg.

    CLASS-METHODS check_is_rap_struct
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS msg_get_rap
      IMPORTING
        val           TYPE any
        entity_name   TYPE string OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_t_msg.

    CLASS-METHODS msg_get_rap_row
      IMPORTING
        val         TYPE any
        entity_name TYPE string OPTIONAL
      EXPORTING
        messages    TYPE ty_t_msg
        is_row      TYPE abap_bool.

    CLASS-METHODS msg_get_rap_element
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_state_area
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_action
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_pid
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_cid
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_tky
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_flatten
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS get_comp_str
      IMPORTING
        val           TYPE any
        comp          TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS scan_flag_prefix
      IMPORTING
        val           TYPE any
        prefix        TYPE clike
      RETURNING
        VALUE(result) TYPE string_table.

    CLASS-METHODS msg_get_rap_meta
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE ty_t_name_value.

    CLASS-METHODS msg_get_rap_fail_text
      IMPORTING
        cause         TYPE i
      RETURNING
        VALUE(result) TYPE string.

    " The base value of an IF_ABAP_BEHV=>T_FAIL_CAUSE value, from its name;
    " -1 for a name this release does not know.
    CLASS-METHODS msg_get_rap_cause_value
      IMPORTING
        name          TYPE clike
      RETURNING
        VALUE(result) TYPE i.

  PRIVATE SECTION.

    " whether a type kind is a number: i, int1, int2, int8, p, f,
    " decfloat16, decfloat34 - the one list the number checks share. int8
    " by its value `8`, a constant lower releases do not have
    CLASS-METHODS rtti_check_typekind_number
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS rtti_get_classes_intf_cloud
      IMPORTING
        val              TYPE clike
        read_description TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result)    TYPE ty_t_classes.

    CLASS-METHODS rtti_get_classes_intf_std
      IMPORTING
        val              TYPE clike
        read_description TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result)    TYPE ty_t_classes.

    CLASS-METHODS rtti_get_dtel_texts_by_ddic
      IMPORTING
        name        TYPE string
      EXPORTING
        texts       TYPE ty_s_data_element_text
        do_fallback TYPE abap_bool.

    CLASS-METHODS rtti_get_dtel_texts_by_xco
      IMPORTING
        name        TYPE string
      EXPORTING
        texts       TYPE ty_s_data_element_text
        do_fallback TYPE abap_bool.

    CLASS-METHODS check_msg_container
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    "! the public attributes of an object that carry a message part (TEXT,
    "! TYPE, MSGV1 ...), mapped over is_msg - see msg_map
    CLASS-METHODS msg_get_by_oref_attri
      IMPORTING
        io_obj        TYPE REF TO object
        is_msg        TYPE ty_s_msg
      RETURNING
        VALUE(result) TYPE ty_s_msg.

    "! the rows of a table, the RAP shape decided on the first structured row
    CLASS-METHODS msg_get_internal_tab
      IMPORTING
        it_tab        TYPE ANY TABLE
      RETURNING
        VALUE(result) TYPE ty_t_msg.

    " the text half of itab_filter_check_field: abap_true when text holds
    " search - upper case already when ignore_case is set
    CLASS-METHODS itab_filter_check_text
      IMPORTING
        !text         TYPE string
        search        TYPE string
        ignore_case   TYPE abap_bool
      RETURNING
        VALUE(result) TYPE abap_bool.

    TYPES:
      BEGIN OF ty_s_attri_cache,
        absolute_name TYPE string,
        o_struct      TYPE REF TO cl_abap_structdescr,
        t_attri       TYPE cl_abap_structdescr=>component_table,
      END OF ty_s_attri_cache.

    CLASS-DATA mt_attri_cache TYPE HASHED TABLE OF ty_s_attri_cache WITH UNIQUE KEY absolute_name.

    CLASS-DATA gv_check_cloud TYPE abap_bool.

    CLASS-DATA gv_check_cloud_cached TYPE abap_bool.

    " Guards the cycle z2ui5_cx_layo_error=>constructor -> uuid_get_c32 ->
    " RAISE z2ui5_cx_layo_error -> ... see uuid_get_c32.
    CLASS-DATA gv_uuid_failed TYPE abap_bool.

ENDCLASS.

CLASS z2ui5_cl_layo_context IMPLEMENTATION.

  METHOD class_constructor.

    cv_char_util_newline        = cl_abap_char_utilities=>newline.
    cv_char_util_cr_lf          = cl_abap_char_utilities=>cr_lf.
    cv_char_util_horizontal_tab = cl_abap_char_utilities=>horizontal_tab.
    cv_char_util_charsize       = cl_abap_char_utilities=>charsize.
    cv_format_e_xml_attr        = cl_abap_format=>e_xml_attr.

    cv_typedescr_typekind_table      = cl_abap_typedescr=>typekind_table.
    cv_typedescr_typekind_dref       = cl_abap_typedescr=>typekind_dref.
    cv_typedescr_typekind_oref       = cl_abap_typedescr=>typekind_oref.
    cv_typedescr_typekind_struct1    = cl_abap_typedescr=>typekind_struct1.
    cv_typedescr_typekind_struct2    = cl_abap_typedescr=>typekind_struct2.
    cv_typedescr_typekind_date       = cl_abap_typedescr=>typekind_date.
    cv_typedescr_typekind_time       = cl_abap_typedescr=>typekind_time.
    cv_typedescr_typekind_packed     = cl_abap_typedescr=>typekind_packed.
    cv_typedescr_kind_struct         = cl_abap_typedescr=>kind_struct.
    cv_typedescr_kind_elem           = cl_abap_typedescr=>kind_elem.
    cv_typedescr_kind_ref            = cl_abap_typedescr=>kind_ref.
    cv_objectdescr_public            = cl_abap_objectdescr=>public.

  ENDMETHOD.

  METHOD conv_copy_ref_data.

    FIELD-SYMBOLS <from>   TYPE data.
    FIELD-SYMBOLS <result> TYPE data.

    IF rtti_check_ref_data( from ) IS NOT INITIAL.
      ASSIGN from->* TO <from>.
      IF <from> IS NOT ASSIGNED.
        " unbound data reference - nothing to copy, return an initial reference
        RETURN.
      ENDIF.
    ELSE.
      ASSIGN from TO <from>.
    ENDIF.
    CREATE DATA result LIKE <from>.
    ASSIGN result->* TO <result>.

    <result> = <from>.

  ENDMETHOD.

  METHOD c_trim.
      DATA lv_before LIKE result.

    result = val.
    " spaces and tabs alternate at either end (`\t \tx`) - one pass of each
    " leaves the inner layer standing, so strip until nothing changes. No
    " fixed number of passes: ten left the eleventh layer of a padded value
    " standing. Every pass that changes something shortens the string, so
    " the loop ends
    DO.

      lv_before = result.
      result = shift_left( shift_right( result ) ).
      result = shift_right( val = result
                            sub = cv_char_util_horizontal_tab ).
      result = shift_left( val = result
                           sub = cv_char_util_horizontal_tab ).
      IF result = lv_before.
        EXIT.
      ENDIF.
    ENDDO.

  ENDMETHOD.

  METHOD itab_filter_by_val.
    " TRANSPILER NOTE: ABAP CS is always case-insensitive, so the two match
    " branches below differ deliberately: ignore_case = abap_true uses
    " to_upper + CS (JS: toLowerCase().includes(toLowerCase())), the default
    " uses find( ) for a genuinely case-sensitive match (JS: plain includes()).
    FIELD-SYMBOLS <row>   TYPE any.
    FIELD-SYMBOLS <field> TYPE any.
    FIELD-SYMBOLS <kept>  TYPE STANDARD TABLE.
    " the components that hold text: by position without a field list, by
    " name with one
    TYPES temp5 TYPE STANDARD TABLE OF i WITH DEFAULT KEY.
DATA lt_index TYPE temp5.
    DATA lt_name  TYPE string_table.
    DATA lv_whole_row TYPE abap_bool.
    DATA lr_kept TYPE REF TO data.

    DATA temp1 TYPE string.
    DATA lv_search LIKE temp1.
      DATA lv_index TYPE i.
      DATA temp2 LIKE LINE OF fields.
      DATA lr_field LIKE REF TO temp2.
      DATA lv_check_found LIKE abap_false.
      DATA temp3 LIKE LINE OF lt_index.
      DATA lr_index LIKE REF TO temp3.
      DATA temp4 LIKE LINE OF lt_name.
      DATA lr_name LIKE REF TO temp4.
    IF ignore_case = abap_true.
      temp1 = to_upper( val ).
    ELSE.
      temp1 = val.
    ENDIF.

    lv_search = temp1.
    " an empty search is no filter: every row stays. Said here rather than
    " left to the match below - whether find( ) or CS reports a hit for an
    " empty substring is not something to build on, and a row with nothing
    " printable in it (only a table of children, only a reference) matched
    " nothing and was deleted
    IF lv_search IS INITIAL.
      RETURN.
    ENDIF.

    " Which component holds text is a property of the line type: decided
    " once, on the first row, instead of describing every cell of every
    " row - this runs on every search keystroke over the whole table. A
    " table, a deep structure or a reference cannot go into a string
    " template - such a component holds no text to match
    READ TABLE tab INDEX 1 ASSIGNING <row>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    IF fields IS INITIAL.

      lv_index = 1.
      DO.
        ASSIGN COMPONENT lv_index OF STRUCTURE <row> TO <field>.
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.
        IF rtti_check_printable( <field> ) = abap_true.
          INSERT lv_index INTO TABLE lt_index.
        ENDIF.
        lv_index = lv_index + 1.
      ENDDO.
      " elementary line type (e.g. string_table) has no components -
      " match against the whole line instead of deleting every row
      IF lv_index = 1.
        lv_whole_row = rtti_check_printable( <row> ).
      ENDIF.
    ELSE.


      LOOP AT fields REFERENCE INTO lr_field.
        ASSIGN COMPONENT lr_field->* OF STRUCTURE <row> TO <field>.
        IF sy-subrc = 0 AND rtti_check_printable( <field> ) = abap_true.
          INSERT lr_field->* INTO TABLE lt_name.
        ENDIF.
      ENDLOOP.
    ENDIF.

    " the matching rows go into a copy - a DELETE ... INDEX per dropped row
    " shifted the rest of the table every time
    CREATE DATA lr_kept LIKE tab.
    ASSIGN lr_kept->* TO <kept>.

    LOOP AT tab ASSIGNING <row>.


      lv_check_found = abap_false.
      IF lv_whole_row = abap_true.
        lv_check_found = itab_filter_check_text( text        = |{ <row> }|
                                                 search      = lv_search
                                                 ignore_case = ignore_case ).
      ENDIF.


      LOOP AT lt_index REFERENCE INTO lr_index.
        ASSIGN COMPONENT lr_index->* OF STRUCTURE <row> TO <field> ##SUBRC_OK.
        IF itab_filter_check_text( text        = |{ <field> }|
                                   search      = lv_search
                                   ignore_case = ignore_case ) = abap_true.
          lv_check_found = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.


      LOOP AT lt_name REFERENCE INTO lr_name.
        ASSIGN COMPONENT lr_name->* OF STRUCTURE <row> TO <field> ##SUBRC_OK.
        IF itab_filter_check_text( text        = |{ <field> }|
                                   search      = lv_search
                                   ignore_case = ignore_case ) = abap_true.
          lv_check_found = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_check_found = abap_true.
        INSERT <row> INTO TABLE <kept>.
      ENDIF.

    ENDLOOP.

    IF lines( <kept> ) <> lines( tab ).
      tab = <kept>.
    ENDIF.

  ENDMETHOD.

  METHOD rtti_check_ref_data.
        DATA lo_typdescr TYPE REF TO cl_abap_typedescr.
        DATA temp5 TYPE REF TO cl_abap_refdescr.
        DATA lo_referenced TYPE REF TO cl_abap_typedescr.
        DATA temp1 TYPE xsdboolean.

    TRY.
        " a kind comparison, not a CAST probe: the cast raised
        " CX_SY_MOVE_CAST_ERROR for every NON-reference value, and the
        " non-reference is the COMMON case on this path (every value routed
        " through conv_copy_ref_data asks) - deciding a type question by
        " exception is orders of magnitude more expensive than comparing.
        " cl_abap_refdescr covers data and object references alike, and so
        " does kind_ref

        lo_typdescr = cl_abap_typedescr=>describe_by_data( val ).
        IF lo_typdescr->kind <> cl_abap_typedescr=>kind_ref.
          RETURN.
        ENDIF.
        " kind_ref covers object references too, and the one caller that
        " dereferences on a true answer (conv_copy_ref_data: `from->*`)
        " cannot do that to an object reference. Only a reference to DATA
        " answers true

        temp5 ?= lo_typdescr.

        lo_referenced = temp5->get_referenced_type( ).

        temp1 = boolc( lo_referenced->kind <> cl_abap_typedescr=>kind_class AND lo_referenced->kind <> cl_abap_typedescr=>kind_intf ).
        result = temp1.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

  ENDMETHOD.

  METHOD rtti_get_classname_by_ref.

    " an unbound reference has no class - answer with an empty name instead
    " of letting the RTTI call fail. Callers ask this while rendering (error
    " context, response header), where a half-built object graph is normal
    IF val IS NOT BOUND.
      RETURN.
    ENDIF.

    result = substring_after( val = cl_abap_classdescr=>get_class_name( val )
                              sub = `\CLASS=` ).

  ENDMETHOD.

  METHOD rtti_get_type_kind.

    result = cl_abap_datadescr=>get_data_type_kind( val ).

  ENDMETHOD.

  METHOD rtti_get_t_attri_by_include.

    " `type` IS the include's descriptor - the component the caller took it
    " from (as_include = abap_true) carries the structure descriptor, and
    " RTTI descriptors are singletons. It used to be re-described by name,
    " an RTTI lookup per include on the binding path that could only hand
    " back the object already in hand - or fail for a local include type
    " whose absolute name does not resolve, where the direct cast cannot
    DATA sdescr TYPE REF TO cl_abap_structdescr.
        DATA lx_cast TYPE REF TO cx_sy_move_cast_error.
    TRY.
        sdescr ?= type.

      CATCH cx_sy_move_cast_error INTO lx_cast.
        RAISE EXCEPTION TYPE z2ui5_cx_layo_error
          EXPORTING
            val      = |Include type '{ type->absolute_name }' is not a structure|
            previous = lx_cast.
    ENDTRY.
    result = expand_components( val   = sdescr->get_components( )
                                depth = depth ).

  ENDMETHOD.

  METHOD expand_components.
    DATA temp6 LIKE LINE OF val.
    DATA lr_comp LIKE REF TO temp6.
        DATA lt_include TYPE abap_component_tab.
          DATA temp7 LIKE LINE OF lt_include.
          DATA lr_include LIKE REF TO temp7.

    " see the declaration: bounded so a cyclic include chain surfaces as a
    " readable error instead of a stack-overflow dump. 16 nested include
    " levels is far beyond any real DDIC structure
    IF depth > 16.
      RAISE EXCEPTION TYPE z2ui5_cx_layo_error
        EXPORTING
          val = `RTTI_INCLUDE_RECURSION - include expansion exceeded 16 levels (cyclic include?)`.
    ENDIF.



    LOOP AT val REFERENCE INTO lr_comp.
      IF lr_comp->as_include = abap_true.
        " INCLUDE ... RENAMING WITH SUFFIX: the structure's components are
        " named <component><suffix>, and every nested level adds its own -
        " the bare include names do not exist on the structure, so a
        " binding path or ASSIGN COMPONENT built from them fails

        lt_include = rtti_get_t_attri_by_include( type  = lr_comp->type
                                                        depth = depth + 1 ).
        IF lr_comp->suffix IS NOT INITIAL.


          LOOP AT lt_include REFERENCE INTO lr_include.
            lr_include->name = lr_include->name && lr_comp->suffix.
          ENDLOOP.
        ENDIF.
        INSERT LINES OF lt_include INTO TABLE result.
      ELSE.
        INSERT lr_comp->* INTO TABLE result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD rtti_get_t_attri_by_oref.

    DATA lo_descr TYPE REF TO cl_abap_typedescr.
    DATA temp8 TYPE REF TO cl_abap_classdescr.

    " describe_by_object_ref raises the classic exception REFERENCE_IS_INITIAL
    " for an initial reference - called functionally that is a runtime error no
    " CATCH reaches
    cl_abap_objectdescr=>describe_by_object_ref( EXPORTING  p_object_ref         = val
                                                 RECEIVING p_descr_ref           = lo_descr
                                                 EXCEPTIONS reference_is_initial = 1
                                                            OTHERS               = 2 ).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z2ui5_cx_layo_error
        EXPORTING
          val = `RTTI_REFERENCE_IS_INITIAL`.
    ENDIF.

    temp8 ?= lo_descr.
    result = temp8->attributes.

  ENDMETHOD.

  METHOD rtti_get_t_attri_by_any.

    DATA lo_struct        TYPE REF TO cl_abap_structdescr.
    DATA lo_type          TYPE REF TO cl_abap_typedescr.
    " declared, not CONV string( ) - see error_get_attributes
    DATA lv_absolute_name TYPE string.
        DATA temp9 TYPE REF TO cl_abap_structdescr.
        DATA temp10 TYPE REF TO cl_abap_structdescr.
        DATA temp1 TYPE REF TO cl_abap_tabledescr.
    FIELD-SYMBOLS <ls_attri_cache> TYPE z2ui5_cl_layo_context=>ty_s_attri_cache.
      DATA temp11 TYPE z2ui5_cl_layo_context=>ty_s_attri_cache.

    " describe_by_data never fails for a data object, and the reference case
    " is the one branch. The fallback chain that used to sit here - a second
    " describe_by_data_ref, then describe_by_name( val ) - could rescue no
    " input: the first only re-raised what the branch above had raised, and
    " a data object is no type name
    lo_type = cl_abap_typedescr=>describe_by_data( val ).
    IF lo_type->kind = cl_abap_typedescr=>kind_ref.
      " REFERENCE_IS_INITIAL - see rtti_get_t_attri_by_oref
      cl_abap_typedescr=>describe_by_data_ref( EXPORTING  p_data_ref           = val
                                               RECEIVING p_descr_ref           = lo_type
                                               EXCEPTIONS reference_is_initial = 1
                                                          OTHERS               = 2 ).
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE z2ui5_cx_layo_error
          EXPORTING
            val = `RTTI_REFERENCE_IS_INITIAL`.
      ENDIF.
    ENDIF.

    CASE lo_type->kind.
      WHEN cl_abap_typedescr=>kind_struct.

        temp9 ?= lo_type.
        lo_struct = temp9.
      WHEN cl_abap_typedescr=>kind_table.


        temp1 ?= lo_type.
        temp10 ?= temp1->get_table_line_type( ).
        lo_struct = temp10.
      WHEN OTHERS.
        lo_struct ?= lo_type.
    ENDCASE.

    " descriptor instances are singletons per type, so the identity check
    " guards against absolute names reused by other (local/anonymous) types
    lv_absolute_name = lo_struct->absolute_name.

    READ TABLE mt_attri_cache WITH KEY absolute_name = lv_absolute_name ASSIGNING <ls_attri_cache>.
    IF <ls_attri_cache> IS ASSIGNED AND <ls_attri_cache>-o_struct = lo_struct.
      result = <ls_attri_cache>-t_attri.
      RETURN.
    ENDIF.

    result = expand_components( lo_struct->get_components( ) ).

    IF <ls_attri_cache> IS ASSIGNED.
      <ls_attri_cache>-o_struct = lo_struct.
      <ls_attri_cache>-t_attri  = result.
    ELSE.

      CLEAR temp11.
      temp11-absolute_name = lv_absolute_name.
      temp11-o_struct = lo_struct.
      temp11-t_attri = result.
      INSERT temp11 INTO TABLE mt_attri_cache.
    ENDIF.

  ENDMETHOD.

  METHOD conv_exit.

    DATA lv_message TYPE string.
    DATA lx_error   TYPE REF TO cx_root.

    DATA temp12 TYPE string.
    DATA conex LIKE temp12.
    IF output = abap_true.
      temp12 = |CONVERSION_EXIT_{ convexit }_OUTPUT|.
    ELSE.
      temp12 = |CONVERSION_EXIT_{ convexit }_INPUT|.
    ENDIF.

    conex = temp12.

    TRY.
        " CUNIT reads the unit in a language; the others take no such parameter
        IF from IS SUPPLIED AND convexit = `CUNIT`.
          CALL FUNCTION conex
            EXPORTING
              input    = from
              language = sy-langu
            IMPORTING
              output   = value
            EXCEPTIONS
              " a plain MESSAGE TYPE E of the exit ends the request without it
              error_message = 98
              OTHERS        = 99.
        ELSEIF from IS SUPPLIED.
          CALL FUNCTION conex
            EXPORTING
              input  = from
            IMPORTING
              output = value
            EXCEPTIONS
              error_message = 98
              OTHERS        = 99.
        ELSEIF convexit = `CUNIT`.
          CALL FUNCTION conex
            EXPORTING
              input    = value
              language = sy-langu
            IMPORTING
              output   = value
            EXCEPTIONS
              error_message = 98
              OTHERS        = 99.
        ELSE.
          CALL FUNCTION conex
            EXPORTING
              input  = value
            IMPORTING
              output = value
            EXCEPTIONS
              error_message = 98
              OTHERS        = 99.
        ENDIF.

      CATCH cx_root INTO lx_error.
        " no such exit, or a parameter it does not accept
        RAISE EXCEPTION TYPE z2ui5_cx_layo_error
          EXPORTING
            val = lx_error.
    ENDTRY.

    IF sy-subrc <> 0.
      " the exit raised its exception with MESSAGE ... RAISING, or sent a
      " plain MESSAGE TYPE E (error_message) - both leave it in sy-msg*
      IF sy-msgid IS NOT INITIAL.
        MESSAGE ID sy-msgid TYPE `E` NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
      ELSE.
        lv_message = |{ conex } failed|.
      ENDIF.
      RAISE EXCEPTION TYPE z2ui5_cx_layo_error
        EXPORTING
          val = lv_message.
    ENDIF.

  ENDMETHOD.

  METHOD msg_get_t.

    result = msg_get_internal( val ).
    IF result IS INITIAL AND val2 IS NOT INITIAL.
      result = msg_get_internal( val2 ).
    ENDIF.

  ENDMETHOD.

  METHOD rtti_check_clike.

    CASE rtti_get_type_kind( val ).
      " typekind_clike/_csequence are generic kinds of formal parameters and
      " can never be returned for a concrete data object - list the concrete
      " character-like kinds (c, string, n, d, t) instead
      WHEN cl_abap_datadescr=>typekind_char OR
          cl_abap_datadescr=>typekind_string OR
          cl_abap_datadescr=>typekind_num OR
          cl_abap_datadescr=>typekind_date OR
          cl_abap_datadescr=>typekind_time.
        result = abap_true.
    ENDCASE.

  ENDMETHOD.

  METHOD rtti_check_printable.
    DATA lv_type_kind TYPE string.
    DATA temp2 TYPE xsdboolean.

    IF rtti_check_clike( val ) = abap_true.
      result = abap_true.
      RETURN.
    ENDIF.


    lv_type_kind = rtti_get_type_kind( val ).

    temp2 = boolc( lv_type_kind = cl_abap_datadescr=>typekind_hex OR rtti_check_typekind_number( lv_type_kind ) = abap_true ).
    result = temp2.

  ENDMETHOD.

  METHOD error_get_source_position.

    " typed like the EXPORTING parameters of get_source_position (syrepid is
    " CHAR40) - they are passed by reference, so a string would not be
    " type-compatible here
    DATA lv_program TYPE c LENGTH 40.
    DATA lv_include TYPE c LENGTH 40.
    DATA lv_line    TYPE i.

    IF val IS NOT BOUND.
      RETURN.
    ENDIF.

    " open-abap - the transpiled JS runtime behind the node tests - implements
    " get_source_position by reading a field that only the RAISE statement
    " writes, and fails with a JS TypeError for every other exception (a
    " runtime-thrown one, or one built with NEW). That error is not an ABAP
    " exception, so the TRY below cannot intercept it and the caller would go
    " down instead of reporting the error it was diagnosing. sy-saprl is
    " `OPEN` on that runtime and a real release everywhere else.
    IF sy_get( )-saprl = `OPEN`.
      RETURN.
    ENDIF.

    TRY.
        val->get_source_position( IMPORTING program_name = lv_program
                                            include_name = lv_include
                                            source_line  = lv_line ).
      CATCH cx_root ##NO_HANDLER.
        " never let the diagnostic be the reason a caller fails
    ENDTRY.

    IF lv_program IS INITIAL AND lv_line IS INITIAL.
      RETURN.
    ENDIF.

    result = c_trim( lv_program ).
    " the include is the interesting part for a class (...CM001 = the method
    " that raised); repeating it when it equals the program adds nothing
    IF lv_include IS NOT INITIAL AND lv_include <> lv_program.
      result = |{ result } / { c_trim( lv_include ) }|.
    ENDIF.
    IF lv_line IS NOT INITIAL.
      result = |{ result } / line { lv_line }|.
    ENDIF.

  ENDMETHOD.

  METHOD error_get_attributes.

    " declared, NOT `DATA(lv_name) = CONV string( lr_attri->name )`: a CONV
    " that is the whole right-hand side of an assignment is "Redundant
    " conversion for type STRING" in SLIN - the assignment converts by
    " itself. The variable stays a string on purpose: the RTTI name is a
    " CHAR field whose trailing blanks have no business in the rendered name
    DATA lv_name TYPE string.

    FIELD-SYMBOLS <comp> TYPE any.
        DATA lt_attri TYPE abap_attrdescr_tab.
    DATA temp13 LIKE LINE OF lt_attri.
    DATA lr_attri LIKE REF TO temp13.
      DATA temp14 TYPE z2ui5_cl_layo_context=>ty_s_name_value.

    IF val IS NOT BOUND.
      RETURN.
    ENDIF.

    TRY.

        lt_attri = rtti_get_t_attri_by_oref( val ).
      CATCH cx_root.
        RETURN.
    ENDTRY.



    LOOP AT lt_attri REFERENCE INTO lr_attri      "#EC CI_SORTSEQ
         WHERE visibility  = cv_objectdescr_public
           AND is_constant = abap_false
           AND is_class    = abap_false.

      CASE lr_attri->name.
          " rendered by the caller (PREVIOUS as the next chain entry,
          " KERNEL_ERRID as its own line) or without information value
        WHEN `PREVIOUS` OR `TEXTID` OR `IS_RESUMABLE` OR `KERNEL_ERRID`.
          CONTINUE.
      ENDCASE.

      lv_name = lr_attri->name.
      " UNASSIGN + IS ASSIGNED, not sy-subrc - see unassign_data for the
      " release behaviour (#1937). INSIDE A LOOP the stale-subrc reading is
      " not just "skipped one attribute": a failed ASSIGN leaves the symbol
      " on the PREVIOUS iteration's attribute, so a stale 0 renders that
      " value under this attribute's name - a wrong value in the error dump,
      " which is the one place a reader has nothing else to go by
      UNASSIGN <comp>.
      ASSIGN val->(lv_name) TO <comp>.
      IF <comp> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.
      IF rtti_check_printable( <comp> ) = abap_false OR <comp> IS INITIAL.
        CONTINUE.
      ENDIF.


      CLEAR temp14.
      temp14-n = lv_name.
      temp14-v = c_trim( |{ <comp> }| ).
      INSERT temp14 INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD rtti_check_typekind_number.

    CASE val.
      WHEN cl_abap_typedescr=>typekind_int
          OR cl_abap_typedescr=>typekind_int1
          OR cl_abap_typedescr=>typekind_int2
          OR cl_abap_typedescr=>typekind_packed
          OR cl_abap_typedescr=>typekind_float
          OR cl_abap_typedescr=>typekind_decfloat16
          OR cl_abap_typedescr=>typekind_decfloat34
          OR `8`.
        result = abap_true.
    ENDCASE.

  ENDMETHOD.

  METHOD check_abap_cloud.

    IF gv_check_cloud_cached = abap_true.
      result = gv_check_cloud.
      RETURN.
    ENDIF.

    TRY.
        cl_abap_typedescr=>describe_by_name( `T100` ).
        gv_check_cloud = abap_false.
      CATCH cx_root.
        gv_check_cloud = abap_true.
    ENDTRY.
    gv_check_cloud_cached = abap_true.
    result = gv_check_cloud.

  ENDMETHOD.

  METHOD sy_get.

    result-datum = sy-datum.
    result-uzeit = sy-uzeit.
    result-uname = sy-uname.
    result-sysid = sy-sysid.
    result-saprl = sy-saprl.

  ENDMETHOD.

  METHOD rtti_get_classes_impl_intf.

    IF check_abap_cloud( ) IS NOT INITIAL.
      result = rtti_get_classes_intf_cloud( val              = val
                                            read_description = read_description ).
    ELSE.
      result = rtti_get_classes_intf_std( val              = val
                                          read_description = read_description ).
    ENDIF.

  ENDMETHOD.

  METHOD rtti_get_classes_intf_cloud.

    DATA obj TYPE REF TO object.
    FIELD-SYMBOLS <any> TYPE any.
    DATA lt_implementation_names TYPE string_table.
    DATA BEGIN OF ls_clskey.
    DATA clsname TYPE c LENGTH 30.
    DATA END OF ls_clskey.
    DATA xco_cp_abap         TYPE c LENGTH 11.
    DATA implementation_name LIKE LINE OF lt_implementation_names.
    DATA ls_class            LIKE LINE OF result.

    ls_clskey-clsname = val.

    xco_cp_abap = `XCO_CP_ABAP`.
    CALL METHOD (xco_cp_abap)=>interface
      EXPORTING
        iv_name      = ls_clskey-clsname
      RECEIVING
        ro_interface = obj.

    " an XCO object without the attribute knows no implementations: the
    " answer is the empty list the on-prem twin gives for an interface
    " nobody implements - not a kernel exception raised by hand
    " UNASSIGN + IS ASSIGNED, not sy-subrc - see unassign_data (#1937). The
    " SECOND hop is the one that bites: the symbol still holds the first
    " attribute when its ASSIGN fails, so a stale 0 would hand the WRONG
    " object to the GET_NAMES call below - and the caller reads the empty or
    " failed answer as "no user exit configured anywhere", the #2564 damage
    " picture, with nothing to point at
    UNASSIGN <any>.
    ASSIGN obj->(`IF_XCO_AO_INTERFACE~IMPLEMENTATIONS`) TO <any>.
    IF <any> IS NOT ASSIGNED.
      RETURN.
    ENDIF.
    obj = <any>.

    UNASSIGN <any>.
    ASSIGN obj->(`IF_XCO_INTF_IMPLEMENTATIONS_FC~ALL`) TO <any>.
    IF <any> IS NOT ASSIGNED.
      RETURN.
    ENDIF.
    obj = <any>.

    CALL METHOD obj->(`IF_XCO_INTF_IMPLEMENTATIONS~GET_NAMES`)
      RECEIVING
        rt_names = lt_implementation_names.

    LOOP AT lt_implementation_names INTO implementation_name.

      CLEAR ls_class.
      ls_class-classname = implementation_name.
      IF read_description = abap_true.
        " a class the XCO layer cannot describe (deleted mid-list, locked)
        " keeps its slot with a blank description - one broken implementer
        " must not hide every other one from the caller
        TRY.
            ls_class-description = rtti_get_class_descr_on_cloud( implementation_name ).
          CATCH cx_root ##NO_HANDLER.
        ENDTRY.
      ENDIF.
      INSERT ls_class INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD rtti_get_classes_intf_std.

    TYPES BEGIN OF ty_s_impl.
    TYPES clsname    TYPE c LENGTH 30.
    TYPES refclsname TYPE c LENGTH 30.
    TYPES END OF ty_s_impl.
    " DEFAULT KEY on purpose: this table is passed to the classic function
    " module SEO_INTERFACE_IMPLEM_GET_ALL (impkeys), whose formal parameter is
    " a STANDARD TABLE WITH DEFAULT KEY. WITH EMPTY KEY makes the table type
    " incompatible, so the CALL FUNCTION fails and no implementers are returned
    " (silently breaking user-exit discovery). Never change this key type.
    TYPES temp6 TYPE STANDARD TABLE OF ty_s_impl WITH DEFAULT KEY.
DATA lt_impl TYPE temp6.
    "#EC DEFAULT_KEY
    TYPES BEGIN OF ty_s_key.
    TYPES intkey TYPE c LENGTH 30.
    TYPES END OF ty_s_key.
    DATA ls_key TYPE ty_s_key.
    DATA BEGIN OF ls_clskey.
    DATA clsname TYPE c LENGTH 30.
    DATA END OF ls_clskey.
    DATA class    TYPE REF TO data.
    DATA type     TYPE c LENGTH 12.
    FIELD-SYMBOLS <class> TYPE data.
    DATA lr_impl  TYPE REF TO ty_s_impl.
    FIELD-SYMBOLS <description> TYPE any.
    DATA ls_class TYPE ty_s_class_descr.
    DATA lv_fm    TYPE string.

    ls_key-intkey = val.

    lv_fm = `SEO_INTERFACE_IMPLEM_GET_ALL`.
    CALL FUNCTION lv_fm
      EXPORTING
        intkey        = ls_key
      IMPORTING
        impkeys       = lt_impl
      EXCEPTIONS
        error_message = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT lt_impl REFERENCE INTO lr_impl.

      CLEAR ls_class.
      ls_class-classname = lr_impl->clsname.

      IF read_description = abap_true.

        " the repository structure only when a description is asked for -
        " the user-exit lookup (get_user_exit_class) never asks, and in a
        " stateless ICF session it runs once per request, so the dynamic
        " CREATE DATA of SEOC_CLASS_R was paid on every request for nothing
        IF class IS NOT BOUND.
          type = `SEOC_CLASS_R`.
          CREATE DATA class TYPE (type).
          ASSIGN class->* TO <class>.
        ENDIF.

        CLEAR <class>.
        ls_clskey-clsname = lr_impl->clsname.

        lv_fm = `SEO_CLASS_READ`.
        CALL FUNCTION lv_fm
          EXPORTING
            clskey        = ls_clskey
          IMPORTING
            class         = <class>
          EXCEPTIONS
            error_message = 1
            OTHERS        = 2.
        " a class the repository cannot read (deleted mid-list, inactive,
        " locked) keeps its slot with a blank description. This used to
        " RAISE, which turned ONE broken implementer into an empty result
        " for the caller - and the framework caller swallows that into
        " "no user exit configured anywhere", the #2564 damage picture,
        " with no error to point at
        IF sy-subrc = 0.
          ASSIGN
            COMPONENT `DESCRIPT`
            OF STRUCTURE <class>
            TO <description>.
          " ...and the same for a structure that does not carry the
          " component: skipped, blank description, not an ASSERT. An
          " ASSERTION_FAILED is a short dump no TRY can take (the reasoning
          " is written out at z2ui5_cl_ui5_view_builder=>a), so it would
          " bypass the single top-level catch in
          " z2ui5_cl_ui5_http_handler=>_main and answer the request with
          " nothing at all - to report that one description is missing.
          " sy-subrc is the right check HERE: ASSIGN COMPONENT sets it to
          " tell "component not found" from "assigned", which is the one
          " ASSIGN shape the #1937 rule does not cover (see unassign_data)
          IF sy-subrc = 0.
            ls_class-description = <description>.
          ENDIF.
        ENDIF.

      ENDIF.

      INSERT
        ls_class
        INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD rtti_get_data_element_texts.

    DATA data_element_name TYPE string.
    DATA lv_do_fallback    TYPE abap_bool.

    data_element_name = val.

    TRY.
        rtti_get_dtel_texts_by_ddic( EXPORTING name        = data_element_name
                                     IMPORTING texts       = result
                                               do_fallback = lv_do_fallback ).
      CATCH cx_root.
        rtti_get_dtel_texts_by_xco( EXPORTING name        = data_element_name
                                    IMPORTING texts       = result
                                              do_fallback = lv_do_fallback ).
    ENDTRY.

    IF lv_do_fallback = abap_true AND result IS INITIAL.
      result-header = val.
      result-long = val.
      result-medium = val.
      result-short = val.
    ENDIF.

  ENDMETHOD.

  METHOD rtti_get_dtel_texts_by_ddic.

    DATA ddic_ref TYPE REF TO data.
    DATA: BEGIN OF ddic,
            reptext   TYPE string,
            scrtext_s TYPE string,
            scrtext_m TYPE string,
            scrtext_l TYPE string,
          END OF ddic.
    DATA struct_descr TYPE REF TO cl_abap_structdescr.
    FIELD-SYMBOLS <ddic> TYPE data.
    DATA lo_typedescr TYPE REF TO cl_abap_typedescr.

    CLEAR texts.
    do_fallback = abap_false.

    cl_abap_typedescr=>describe_by_name( `T100` ).

    struct_descr ?= cl_abap_structdescr=>describe_by_name( `DFIES` ).

    CREATE DATA ddic_ref TYPE HANDLE struct_descr.

    " IS ASSIGNED, not sy-subrc, and a RETURN rather than an ASSERT: the
    " symbol is the unassign_data shape (#1937), and an ASSERTION_FAILED
    " here is a short dump the caller's own TRY cannot take - so the XCO
    " fallback it exists for would never run. The two branches below answer
    " a failure the same way
    ASSIGN ddic_ref->* TO <ddic>.
    IF <ddic> IS NOT ASSIGNED.
      RETURN.
    ENDIF.

    cl_abap_elemdescr=>describe_by_name( EXPORTING  p_name     = name
                                         RECEIVING p_descr_ref = lo_typedescr
                                         EXCEPTIONS OTHERS     = 1 ).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    CALL METHOD lo_typedescr->(`GET_DDIC_FIELD`)
      RECEIVING
        p_flddescr   = <ddic>
      EXCEPTIONS
        not_found    = 1
        no_ddic_type = 2
        OTHERS       = 3.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    MOVE-CORRESPONDING <ddic> TO ddic.
    texts-header = ddic-reptext.
    texts-short  = ddic-scrtext_s.
    texts-medium = ddic-scrtext_m.
    texts-long   = ddic-scrtext_l.
    do_fallback  = abap_true.

  ENDMETHOD.

  METHOD rtti_get_dtel_texts_by_xco.

    DATA data_element TYPE REF TO object.
    DATA content      TYPE REF TO object.
    DATA exists       TYPE abap_bool.
    DATA lv_xco_cp_abap_dictionary TYPE string.
    " A dynamic call checks its actual parameters against the formal ones at
    " runtime and converts nothing, so both sides are typed exactly as XCO
    " declares them. The name is sxco_ad_object_name (CHAR30), passed by
    " reference - a string there raised CX_SY_DYN_CALL_ILLEGAL_TYPE. Each
    " label is if_xco_dtel_content=>ts_field_label, a text (CHAR60) and its
    " length (NUMC2) - received into a string, every one raised the same.
    " Both ended in the CATCH below, so on ABAP Cloud every data element came
    " back with empty texts (or its own name, as the caller's fallback). The
    " shapes are written out because the XCO types exist on cloud only
    DATA lv_name TYPE c LENGTH 30.
    DATA: BEGIN OF ls_label,
            text   TYPE c LENGTH 60,
            length TYPE n LENGTH 2,
          END OF ls_label.

    CLEAR texts.
    do_fallback = abap_false.

    TRY.
        lv_name = name.
        lv_xco_cp_abap_dictionary = `XCO_CP_ABAP_DICTIONARY`.
        CALL METHOD (lv_xco_cp_abap_dictionary)=>(`DATA_ELEMENT`)
          EXPORTING
            iv_name         = lv_name
          RECEIVING
            ro_data_element = data_element.

        CALL METHOD data_element->(`IF_XCO_AD_DATA_ELEMENT~EXISTS`)
          RECEIVING
            rv_exists = exists.

        IF exists = abap_false.
          RETURN.
        ENDIF.

        CALL METHOD data_element->(`IF_XCO_AD_DATA_ELEMENT~CONTENT`)
          RECEIVING
            ro_content = content.

        CALL METHOD content->(`IF_XCO_DTEL_CONTENT~GET_HEADING_FIELD_LABEL`)
          RECEIVING
            rs_heading_field_label = ls_label.
        texts-header = ls_label-text.

        CALL METHOD content->(`IF_XCO_DTEL_CONTENT~GET_SHORT_FIELD_LABEL`)
          RECEIVING
            rs_short_field_label = ls_label.
        texts-short = ls_label-text.

        CALL METHOD content->(`IF_XCO_DTEL_CONTENT~GET_MEDIUM_FIELD_LABEL`)
          RECEIVING
            rs_medium_field_label = ls_label.
        texts-medium = ls_label-text.

        CALL METHOD content->(`IF_XCO_DTEL_CONTENT~GET_LONG_FIELD_LABEL`)
          RECEIVING
            rs_long_field_label = ls_label.
        texts-long = ls_label-text.

        do_fallback = abap_true.

      CATCH cx_root.
        do_fallback = abap_true.
    ENDTRY.

  ENDMETHOD.

  METHOD uuid_get_c32.
    DATA lv_uuid      TYPE c LENGTH 32.
    DATA lv_classname TYPE string.
    DATA lv_fm        TYPE string.
        DATA lx_uuid TYPE REF TO cx_root.

    TRY.

        TRY.

            lv_classname = `CL_SYSTEM_UUID`.
            CALL METHOD (lv_classname)=>if_system_uuid_static~create_uuid_c32
              RECEIVING
                uuid = lv_uuid.

          CATCH cx_root.

            lv_fm = `GUID_CREATE`.
            " error_message: a message the module sends would otherwise end
            " the request, which no CATCH reaches
            CALL FUNCTION lv_fm
              IMPORTING
                ev_guid_32    = lv_uuid
              EXCEPTIONS
                error_message = 1
                OTHERS        = 2.
            IF sy-subrc <> 0.
              RAISE EXCEPTION TYPE z2ui5_cx_layo_error
                EXPORTING
                  val = `GUID_CREATE_FAILED`.
            ENDIF.

        ENDTRY.

        result = lv_uuid.


      CATCH cx_root INTO lx_uuid.
        " both UUID mechanisms failed - raise the framework exception so the
        " consumer's single top-level catch can turn it into a handled error.
        " ASSERT would raise the uncatchable ASSERTION_FAILED and bypass that
        " catch (short dump instead of a handled error response).
        " z2ui5_cx_layo_error reads a uuid when it renders its full report,
        " so a renderer running while the raise below is on its way would
        " re-enter this method. gv_uuid_failed makes that nested call return an
        " empty UUID instead of raising again.
        IF gv_uuid_failed = abap_true.
          RETURN.
        ENDIF.
        gv_uuid_failed = abap_true.
        TRY.
            RAISE EXCEPTION TYPE z2ui5_cx_layo_error
              EXPORTING
                val = lx_uuid.
          CLEANUP.
            CLEAR gv_uuid_failed.
        ENDTRY.
    ENDTRY.
  ENDMETHOD.

  METHOD rtti_get_class_descr_on_cloud.
        DATA obj TYPE REF TO object.
        DATA content TYPE REF TO object.
        DATA lv_classname TYPE c LENGTH 30.
        DATA xco_cp_abap TYPE c LENGTH 11.
        DATA lv_description TYPE c LENGTH 60.
    TRY.







        lv_classname = classname.

        xco_cp_abap = `XCO_CP_ABAP`.
        CALL METHOD (xco_cp_abap)=>(`CLASS`)
          EXPORTING
            iv_name  = lv_classname
          RECEIVING
            ro_class = obj.

        CALL METHOD obj->(`IF_XCO_AO_CLASS~CONTENT`)
          RECEIVING
            ro_content = content.

        " sxco_ar_short_description, CHAR60 - typed exactly, for the same
        " reason as the labels in rtti_get_dtel_texts_by_xco
        CALL METHOD content->(`IF_XCO_CLAS_CONTENT~GET_SHORT_DESCRIPTION`)
          RECEIVING
            rv_short_description = lv_description.
        result = lv_description.

      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD msg_get_internal.
        FIELD-SYMBOLS <tab> TYPE ANY TABLE.
        DATA lt_attri TYPE abap_component_tab.
        DATA temp15 TYPE ty_s_msg.
        DATA ls_result LIKE temp15.
        DATA temp16 LIKE LINE OF lt_attri.
        DATA ls_attri LIKE REF TO temp16.
          FIELD-SYMBOLS <comp> TYPE any.
          DATA temp17 TYPE z2ui5_cl_layo_context=>ty_s_msg.

    CASE rtti_get_type_kind( val ).

      WHEN cl_abap_datadescr=>typekind_table.

        " guarded like data_render_tab and data_get_headline - handing an
        " UNASSIGNED symbol to the method below is a GETWA_NOT_ASSIGNED
        " dump. No messages then, which is what "nothing in here is a
        " message" means to the caller: it falls back to the data renderer
        ASSIGN val TO <tab>.
        IF <tab> IS NOT ASSIGNED.
          RETURN.
        ENDIF.
        result = msg_get_internal_tab( <tab> ).

      WHEN cl_abap_datadescr=>typekind_struct1 OR cl_abap_datadescr=>typekind_struct2.

        IF val IS INITIAL.
          RETURN.
        ENDIF.

        IF iv_check_rap = abap_true AND check_is_rap_struct( val ) = abap_true.
          result = msg_get_rap( val ).
          RETURN.
        ENDIF.


        lt_attri = rtti_get_t_attri_by_any( val ).


        CLEAR temp15.

        ls_result = temp15.


        LOOP AT lt_attri REFERENCE INTO ls_attri.

          ASSIGN COMPONENT ls_attri->name OF STRUCTURE val TO <comp>.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.

          " only an ITEM that can HOLD messages is the envelope's payload -
          " a table, a structure or an object (the BALI item). A plain
          " ITEM field (a position number) became the whole message and
          " dropped the structure's other fields
          IF ls_attri->name = `ITEM` AND check_msg_container( <comp> ) = abap_true.
            result = msg_get_internal( <comp> ).
            RETURN.
          ENDIF.
          ls_result = msg_map( name = ls_attri->name
                               val  = <comp>
                               msg  = ls_result ).

        ENDLOOP.
        " a T100 message is a class AND a number. A component called ID
        " alone is the key column of any business row - built into a
        " message, it gave `I:0001:` (a missing class still answers a text)
        " and the data never reached the data renderer it was meant for
        IF ls_result-text IS INITIAL AND ls_result-id IS NOT INITIAL AND ls_result-no IS NOT INITIAL.
          ls_result-id = to_upper( ls_result-id ).
          MESSAGE ID ls_result-id TYPE `I` NUMBER ls_result-no
                  WITH ls_result-v1 ls_result-v2 ls_result-v3 ls_result-v4
                  INTO ls_result-text.
        ENDIF.
        INSERT ls_result INTO TABLE result.

      WHEN cl_abap_datadescr=>typekind_oref.
        " an unbound reference carries no message - guarded like the struct
        " and table branches guard theirs. Unguarded it fell through the
        " three handlers of msg_get_by_oref into a describe on the null
        " reference, and message_box_display( unbound ) ended in a 500
        " instead of the documented silence
        IF val IS NOT INITIAL.
          result = msg_get_by_oref( val ).
        ENDIF.

      WHEN OTHERS.

        " skip an empty character value like the struct branch does -
        " otherwise msg_get_t's val2 fallback can never take over and the
        " caller renders a message box with blank text
        IF rtti_check_clike( val ) IS NOT INITIAL AND val IS NOT INITIAL.

          CLEAR temp17.
          temp17-text = val.
          INSERT temp17 INTO TABLE result.
        ENDIF.
    ENDCASE.

  ENDMETHOD.

  METHOD msg_get_by_oref.
        DATA temp18 TYPE REF TO cx_root.
        DATA lx LIKE temp18.
        DATA temp19 TYPE z2ui5_cl_layo_context=>ty_s_msg.
    DATA obj TYPE REF TO object.
    DATA lr_tab TYPE REF TO data.
    FIELD-SYMBOLS <tab> TYPE any.
    DATA temp20 TYPE z2ui5_cl_layo_context=>ty_s_msg.

    " four shapes, tried in turn and each on its own level - the nested
    " TRY/CATCH pyramid this used to be carried the attribute mapping twice,
    " three CATCH blocks deep, one fix away from drifting. Every attempt
    " that fails falls through to the next; the last one cannot fail
    " quietly, it maps whatever public attributes the object has

    " 1. an exception: its text, and its public attributes over it
    TRY.

        temp18 ?= val.

        lx = temp18.

        CLEAR temp19.
        temp19-type = `E`.
        temp19-text = lx->get_text( ).
        INSERT msg_get_by_oref_attri( io_obj = lx
                                      is_msg = temp19 ) INTO TABLE result.
        RETURN.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.


    obj = val.



    " 2. an application log (IF_BALI_LOG)
    TRY.
        CREATE DATA lr_tab TYPE (`if_bali_log=>ty_item_table`).
        ASSIGN lr_tab->* TO <tab>.
        CALL METHOD obj->(`IF_BALI_LOG~GET_ALL_ITEMS`)
          RECEIVING
            item_table = <tab>.
        INSERT LINES OF msg_get_internal( <tab> ) INTO TABLE result.
        RETURN.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    " 3. a logger (ZIF_LOGGER)
    TRY.
        CREATE DATA lr_tab TYPE (`BAPIRETTAB`).
        ASSIGN lr_tab->* TO <tab>.
        CALL METHOD obj->(`ZIF_LOGGER~EXPORT_TO_TABLE`)
          RECEIVING
            rt_bapiret = <tab>.
        INSERT LINES OF msg_get_internal( <tab> ) INTO TABLE result.
        RETURN.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    " 4. any object: whatever public attributes carry a message part

    CLEAR temp20.
    INSERT msg_get_by_oref_attri( io_obj = obj
                                  is_msg = temp20 ) INTO TABLE result.

  ENDMETHOD.

  METHOD msg_map.

    result = msg.

    " The value is a component of an ARBITRARY structure: msg_get_internal
    " walks whatever an app hands to message_box_display( ) and maps every
    " component BY NAME. A business structure with a component that happens
    " to be called TEXT, ID, TYPE or V1 and is a TABLE, a nested structure
    " or a reference is not a message part - and the assignments below are
    " no class-based exception for it, they are a MOVE type conflict
    " (OBJECTS_MOVE_NOT_SUPPORTED on a system, "table, no header line" in
    " the transpiled runtime). So the box that was supposed to REPORT a
    " problem was the crash: nothing between here and the app's own main( )
    " catches it, and the roundtrip ended as a 500.
    " Decided BEFORE anything is assigned, which is the same rule
    " z2ui5_cl_ui5_srv_model=>delta_apply_field follows for the same reason
    " - a runtime error cannot be caught after the fact. A skipped component
    " simply is not a message part: the entry ends up without a text,
    " ui5_msg_box_format drops it, and the caller falls back to the DATA
    " renderer, which shows the whole structure including that component
    IF rtti_check_printable( val ) = abap_false.
      RETURN.
    ENDIF.

    CASE name.
      WHEN `ID` OR `MSGID` OR `ARBGB`.
        result-id = val.
      WHEN `NO` OR `NUMBER` OR `MSGNO` OR `TXTNR`.
        result-no = val.
      WHEN `MESSAGE` OR `TEXT`.
        result-text = val.
      WHEN `TYPE` OR `MSGTY` OR `M_SEVERITY`.
        result-type = val.
      WHEN `MESSAGE_V1` OR `MSGV1` OR `V1`.
        result-v1 = val.
      WHEN `MESSAGE_V2` OR `MSGV2` OR `V2`.
        result-v2 = val.
      WHEN `MESSAGE_V3` OR `MSGV3` OR `V3`.
        result-v3 = val.
      WHEN `MESSAGE_V4` OR `MSGV4` OR `V4`.
        result-v4 = val.
      WHEN `TIME_STMP`.
        " the one target that is not a string: a printable but non-numeric
        " value (`2026-09-16 10:00` in a char field of that name) converts
        " into the packed timestamp with CX_SY_CONVERSION_NO_NUMBER, which
        " is catchable where the MOVE conflict above is not - caught, and
        " the entry keeps no timestamp rather than costing the whole box
        TRY.
            result-timestampl = val.
          CATCH cx_root ##NO_HANDLER.
        ENDTRY.
    ENDCASE.

  ENDMETHOD.

  METHOD check_is_rap_struct.

    DATA lt_attri TYPE abap_component_tab.
    DATA temp21 LIKE LINE OF lt_attri.
    DATA ls_attri LIKE REF TO temp21.
          DATA temp22 TYPE REF TO cl_abap_tabledescr.
          DATA lo_line TYPE REF TO cl_abap_datadescr.
          DATA temp23 TYPE REF TO cl_abap_structdescr.
          DATA lt_comps TYPE abap_component_tab.
          DATA temp24 LIKE LINE OF lt_comps.
          DATA ls_comp LIKE REF TO temp24.
    lt_attri = rtti_get_t_attri_by_any( val ).



    LOOP AT lt_attri REFERENCE INTO ls_attri.
      CASE ls_attri->name.
        WHEN `%MSG` OR `%FAIL` OR `%OTHER`.
          result = abap_true.
          RETURN.
      ENDCASE.
    ENDLOOP.

    LOOP AT lt_attri REFERENCE INTO ls_attri.
      " the component's descriptor is already in the attribute table - no
      " ASSIGN and no describe_by_data per component
      IF ls_attri->type->kind <> cl_abap_typedescr=>kind_table.
        CONTINUE.
      ENDIF.

      TRY.

          temp22 ?= ls_attri->type.

          lo_line = temp22->get_table_line_type( ).
          IF lo_line->kind <> cl_abap_typedescr=>kind_struct.
            CONTINUE.
          ENDIF.

          temp23 ?= lo_line.

          lt_comps = temp23->get_components( ).


          LOOP AT lt_comps REFERENCE INTO ls_comp.
            IF ls_comp->name = `%MSG` OR ls_comp->name = `%FAIL`.
              result = abap_true.
              RETURN.
            ENDIF.
          ENDLOOP.
        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD msg_get_rap.

    DATA lv_kind TYPE string.
    DATA lv_is_row TYPE abap_bool.
    DATA lt_attri TYPE abap_component_tab.
    DATA temp25 LIKE LINE OF lt_attri.
    DATA ls_attri LIKE REF TO temp25.
      FIELD-SYMBOLS <tab> TYPE any.
      FIELD-SYMBOLS <ftab> TYPE ANY TABLE.
      DATA temp26 TYPE REF TO cl_abap_tabledescr.
      DATA lo_line TYPE REF TO cl_abap_datadescr.
      FIELD-SYMBOLS <row> TYPE ANY.
    lv_kind = rtti_get_type_kind( val ).
    IF lv_kind <> cl_abap_datadescr=>typekind_struct1
        AND lv_kind <> cl_abap_datadescr=>typekind_struct2.
      RETURN.
    ENDIF.


    msg_get_rap_row( EXPORTING val         = val
                               entity_name = entity_name
                     IMPORTING messages    = result
                               is_row      = lv_is_row ).
    IF lv_is_row = abap_true.
      RETURN.
    ENDIF.


    lt_attri = rtti_get_t_attri_by_any( val ).


    LOOP AT lt_attri REFERENCE INTO ls_attri.

      ASSIGN COMPONENT ls_attri->name OF STRUCTURE val TO <tab>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      IF rtti_get_type_kind( <tab> ) <> cl_abap_datadescr=>typekind_table.
        CONTINUE.
      ENDIF.

      " guarded like data_render_tab, msg_get_internal and
      " data_get_headline - and here the symbol is LOOP-CARRIED, so an
      " ASSIGN that fails leaves it on the PREVIOUS component's table and
      " the rows below would be read out of that one

      UNASSIGN <ftab>.
      ASSIGN <tab> TO <ftab>.
      IF <ftab> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      " the row kind is a property of the table TYPE - decided once per
      " table, not asked of every row (same idea as msg_get_internal_tab)

      temp26 ?= ls_attri->type.

      lo_line = temp26->get_table_line_type( ).

      LOOP AT <ftab> ASSIGNING <row>.
        IF lo_line->type_kind = cl_abap_datadescr=>typekind_oref.
          IF <row> IS NOT INITIAL.
            TRY.
                INSERT LINES OF msg_get_t( <row> ) INTO TABLE result.
              CATCH cx_root ##NO_HANDLER.
            ENDTRY.
          ENDIF.
        ELSE.
          INSERT LINES OF msg_get_rap( val         = <row>
                                       entity_name = ls_attri->name ) INTO TABLE result.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

  METHOD msg_get_rap_row.
    DATA lv_meta_built TYPE abap_bool.
    DATA lt_meta TYPE ty_t_name_value.
    FIELD-SYMBOLS <msg> TYPE any.
            DATA lt_one TYPE z2ui5_cl_layo_context=>ty_t_msg.
            FIELD-SYMBOLS <m> LIKE LINE OF lt_one.
    FIELD-SYMBOLS <fail> TYPE any.
      FIELD-SYMBOLS <cause> TYPE any.
        DATA lv_cause TYPE i.
        DATA lv_text TYPE string.
        DATA temp27 TYPE z2ui5_cl_layo_context=>ty_s_msg.
    CLEAR messages.
    is_row = abap_false.

    " the meta block is built LAZILY: msg_get_rap_meta walks the row's
    " components three times over (element/action/tky scans), and the
    " common row in a RAP response table carries neither a filled %MSG nor
    " a %FAIL - building the block up front threw that work away per row




    ASSIGN COMPONENT `%MSG` OF STRUCTURE val TO <msg>.
    IF sy-subrc = 0.
      is_row = abap_true.
      IF <msg> IS NOT INITIAL.
        lt_meta = msg_get_rap_meta( val ).
        lv_meta_built = abap_true.
        TRY.

            lt_one = msg_get_t( <msg> ).

            LOOP AT lt_one ASSIGNING <m>.
              <m>-t_meta = lt_meta.
            ENDLOOP.
            INSERT LINES OF lt_one INTO TABLE messages.
          CATCH cx_root ##NO_HANDLER.
        ENDTRY.
      ENDIF.
    ENDIF.


    ASSIGN COMPONENT `%FAIL` OF STRUCTURE val TO <fail>.
    IF sy-subrc = 0.
      is_row = abap_true.

      ASSIGN COMPONENT `CAUSE` OF STRUCTURE <fail> TO <cause>.
      IF sy-subrc = 0.
        IF lv_meta_built = abap_false.
          lt_meta = msg_get_rap_meta( val ).
        ENDIF.
        " %FAIL-CAUSE is the enumeration IF_ABAP_BEHV=>T_FAIL_CAUSE (base
        " type i). An enumerated value does not convert to i - a plain MOVE
        " is the runtime error UC_OBJECTS_NOT_CONVERTIBLE - so it is read by
        " its name (a string template writes the name) and mapped to the
        " base value. Type kind `k` is the enumeration (literal: the
        " constant typekind_enum does not exist on 7.02).

        IF cl_abap_typedescr=>describe_by_data( <cause> )->type_kind = `k`.
          lv_cause = msg_get_rap_cause_value( |{ <cause> }| ).
        ELSE.
          lv_cause = <cause>.
        ENDIF.

        lv_text = msg_get_rap_fail_text( lv_cause ).
        IF entity_name IS NOT INITIAL.
          lv_text = |{ entity_name }: { lv_text }|.
        ENDIF.

        CLEAR temp27.
        temp27-type = `E`.
        temp27-text = lv_text.
        temp27-t_meta = lt_meta.
        INSERT temp27 INTO TABLE messages.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD get_comp_str.

    " printable first, then the assignment: the component comes out of a
    " structure this class did not declare, and a table or a nested
    " structure into a string is a MOVE type conflict, not an exception -
    " see msg_map, which learnt it the expensive way.
    " One chained AND and not the nested IFs z2ui5_cl_ui5_handler=>
    " request_context_info argues for: abaplint's if_in_if refuses the
    " nesting here (nothing sits between the two tests), and the second
    " operand is safe on a failed ASSIGN either way - ABAP evaluates a
    " logical expression left to right and stops once the result is decided
    FIELD-SYMBOLS <comp> TYPE any.
    ASSIGN COMPONENT comp OF STRUCTURE val TO <comp>.
    IF sy-subrc = 0 AND rtti_check_printable( <comp> ) = abap_true.
      result = <comp>.
    ENDIF.

  ENDMETHOD.

  METHOD scan_flag_prefix.

    DATA lv_kind TYPE string.
    DATA temp28 TYPE string.
    DATA lv_prefix LIKE temp28.
    DATA lv_off TYPE i.
      FIELD-SYMBOLS <sub> TYPE any.
    DATA lv_len TYPE i.
    DATA lt_attri TYPE abap_component_tab.
    DATA temp29 LIKE LINE OF lt_attri.
    DATA ls_attri LIKE REF TO temp29.
      FIELD-SYMBOLS <flag> TYPE any.
    lv_kind = rtti_get_type_kind( val ).
    IF lv_kind <> cl_abap_datadescr=>typekind_struct1
        AND lv_kind <> cl_abap_datadescr=>typekind_struct2.
      RETURN.
    ENDIF.

    " a `-` in the prefix is a path, not part of a component name - no
    " component name can contain one: %ELEMENT-<field> and
    " %OP-%ACTION-<name> are components of the NESTED structures %ELEMENT
    " and %OP-%ACTION. Compared against the row's own component names, the
    " two RAP prefixes never matched, and no message ever carried its
    " element or action

    temp28 = prefix.

    lv_prefix = temp28.

    lv_off = find( val = lv_prefix
                         sub = `-` ).
    IF lv_off >= 0.

      ASSIGN COMPONENT lv_prefix(lv_off) OF STRUCTURE val TO <sub>.
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.
      result = scan_flag_prefix( val    = <sub>
                                 prefix = substring( val = lv_prefix
                                                     off = lv_off + 1 ) ).
      RETURN.
    ENDIF.


    lv_len = strlen( lv_prefix ).

    lt_attri = rtti_get_t_attri_by_any( val ).


    LOOP AT lt_attri REFERENCE INTO ls_attri.
      IF strlen( ls_attri->name ) <= lv_len.
        CONTINUE.
      ENDIF.
      IF NOT ( lv_len = 0 OR ls_attri->name(lv_len) = lv_prefix ).
        CONTINUE.
      ENDIF.

      ASSIGN COMPONENT ls_attri->name OF STRUCTURE val TO <flag>.
      IF sy-subrc <> 0 OR <flag> IS INITIAL.
        CONTINUE.
      ENDIF.
      INSERT ls_attri->name+lv_len INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD msg_get_rap_element.

    DATA lt_suffix TYPE string_table.
    lt_suffix = scan_flag_prefix( val       = val
                                        prefix = `%ELEMENT-` ).
    result = concat_lines_of( table = lt_suffix
                              sep   = `, ` ).

  ENDMETHOD.

  METHOD msg_get_rap_state_area.

    result = get_comp_str( val     = val
                           comp = `%STATE_AREA` ).

  ENDMETHOD.

  METHOD msg_get_rap_action.

    DATA lt_suffix TYPE string_table.
    DATA temp30 TYPE string.
    DATA temp31 TYPE string.
    lt_suffix = scan_flag_prefix( val       = val
                                        prefix = `%OP-%ACTION-` ).

    CLEAR temp30.

    READ TABLE lt_suffix INTO temp31 INDEX 1.
    IF sy-subrc = 0.
      temp30 = temp31.
    ENDIF.
    result = temp30.

  ENDMETHOD.

  METHOD msg_get_rap_pid.

    result = get_comp_str( val     = val
                           comp = `%PID` ).

  ENDMETHOD.

  METHOD msg_get_rap_cid.

    result = get_comp_str( val     = val
                           comp = `%CID` ).

  ENDMETHOD.

  METHOD msg_get_rap_tky.

    FIELD-SYMBOLS <tky> TYPE any.
    ASSIGN COMPONENT `%TKY` OF STRUCTURE val TO <tky>.
    IF sy-subrc <> 0 OR <tky> IS INITIAL.
      RETURN.
    ENDIF.
    result = msg_get_rap_flatten( <tky> ).

  ENDMETHOD.

  METHOD msg_get_rap_flatten.

    DATA lv_kind TYPE string.
    DATA lt_attri TYPE abap_component_tab.
    DATA lt_part TYPE string_table.
    DATA temp32 LIKE LINE OF lt_attri.
    DATA ls_attri LIKE REF TO temp32.
      FIELD-SYMBOLS <comp> TYPE any.
      DATA lv_sub_kind TYPE string.
        DATA lv_sub TYPE string.
            DATA lv_str TYPE string.
            DATA temp33 LIKE LINE OF lt_part.
    lv_kind = rtti_get_type_kind( val ).
    IF lv_kind <> cl_abap_datadescr=>typekind_struct1
        AND lv_kind <> cl_abap_datadescr=>typekind_struct2.
      RETURN.
    ENDIF.


    lt_attri = rtti_get_t_attri_by_any( val ).




    LOOP AT lt_attri REFERENCE INTO ls_attri.

      ASSIGN COMPONENT ls_attri->name OF STRUCTURE val TO <comp>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.


      lv_sub_kind = rtti_get_type_kind( <comp> ).
      IF lv_sub_kind = cl_abap_datadescr=>typekind_struct1
          OR lv_sub_kind = cl_abap_datadescr=>typekind_struct2.

        lv_sub = msg_get_rap_flatten( <comp> ).
        IF lv_sub IS NOT INITIAL.
          INSERT lv_sub INTO TABLE lt_part.
        ENDIF.
      ELSEIF <comp> IS NOT INITIAL AND rtti_check_printable( <comp> ) = abap_true.
        " the printable test does what the TRY around this could not: a
        " TABLE component into the string below is a MOVE type conflict and
        " therefore a runtime error, which no CATCH takes (see msg_map). The
        " TRY stays for the conversions that ARE class-based - a character
        " value the packed/numeric target refuses
        TRY.

            lv_str = <comp>.

            temp33 = |{ ls_attri->name }={ lv_str }|.
            INSERT temp33 INTO TABLE lt_part.
          CATCH cx_root ##NO_HANDLER.
        ENDTRY.
      ENDIF.
    ENDLOOP.

    result = concat_lines_of( table = lt_part
                              sep   = `, ` ).

  ENDMETHOD.

  METHOD msg_get_rap_meta.

    DATA lv TYPE string.
      DATA temp34 TYPE z2ui5_cl_layo_context=>ty_s_name_value.
      DATA temp35 TYPE z2ui5_cl_layo_context=>ty_s_name_value.
      DATA temp36 TYPE z2ui5_cl_layo_context=>ty_s_name_value.
      DATA temp37 TYPE z2ui5_cl_layo_context=>ty_s_name_value.
      DATA temp38 TYPE z2ui5_cl_layo_context=>ty_s_name_value.
      DATA temp39 TYPE z2ui5_cl_layo_context=>ty_s_name_value.

    lv = msg_get_rap_element( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp34.
      temp34-n = `element`.
      temp34-v = lv.
      INSERT temp34 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_state_area( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp35.
      temp35-n = `state_area`.
      temp35-v = lv.
      INSERT temp35 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_action( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp36.
      temp36-n = `action`.
      temp36-v = lv.
      INSERT temp36 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_pid( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp37.
      temp37-n = `pid`.
      temp37-v = lv.
      INSERT temp37 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_cid( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp38.
      temp38-n = `cid`.
      temp38-v = lv.
      INSERT temp38 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_tky( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp39.
      temp39-n = `tky`.
      temp39-v = lv.
      INSERT temp39 INTO TABLE result.
    ENDIF.

  ENDMETHOD.

  METHOD msg_get_rap_fail_text.
    " the base values of IF_ABAP_BEHV=>T_FAIL_CAUSE, read on an S/4HANA
    " system (2026-11-13) - HTTP-like codes, not a running number
    DATA temp40 TYPE string.
    CASE cause.
      WHEN 0.
        temp40 = `Operation failed`.
      WHEN 401.
        temp40 = `Authorization failure`.
      WHEN 404.
        temp40 = `Entity not found`.
      WHEN 409.
        temp40 = `Concurrent modification`.
      WHEN 423.
        temp40 = `Entity is locked`.
      WHEN 424.
        temp40 = `Dependent operation failed`.
      WHEN 501.
        temp40 = `Operation not implemented`.
      WHEN 4221.
        temp40 = `Operation disabled`.
      WHEN 4222.
        temp40 = `Entity is read-only`.
      WHEN OTHERS.
        temp40 = |Operation failed (cause code { cause })|.
    ENDCASE.
    result = temp40.
  ENDMETHOD.

  METHOD check_msg_container.

    DATA lv_kind TYPE string.
    DATA temp3 TYPE xsdboolean.
    lv_kind = rtti_get_type_kind( val ).

    temp3 = boolc( lv_kind = cl_abap_datadescr=>typekind_table OR lv_kind = cl_abap_datadescr=>typekind_struct1 OR lv_kind = cl_abap_datadescr=>typekind_struct2 OR lv_kind = cl_abap_datadescr=>typekind_oref ).
    result = temp3.

  ENDMETHOD.

  METHOD itab_filter_check_field.

    " a table, a deep structure or a reference cannot go into a string
    " template - with no field list every component is visited, and a
    " master-detail row (a table of children inside the row) dumped the
    " whole filter. Such a component holds no text to match
    IF rtti_check_printable( field ) = abap_false.
      RETURN.
    ENDIF.

    result = itab_filter_check_text( text        = |{ field }|
                                     search      = search
                                     ignore_case = ignore_case ).

  ENDMETHOD.

  METHOD itab_filter_check_text.

    IF ignore_case = abap_true.
      IF to_upper( text ) CS search.
        result = abap_true.
      ENDIF.
    ELSEIF find( val = text
                 sub = search ) >= 0.
      result = abap_true.
    ENDIF.

  ENDMETHOD.

  METHOD msg_get_by_oref_attri.

    FIELD-SYMBOLS <comp> TYPE any.
    DATA lt_attri_o TYPE abap_attrdescr_tab.
    DATA temp41 LIKE LINE OF lt_attri_o.
    DATA ls_attri_o LIKE REF TO temp41.

    result = is_msg.

    lt_attri_o = rtti_get_t_attri_by_oref( io_obj ).


    LOOP AT lt_attri_o REFERENCE INTO ls_attri_o "#EC CI_SORTSEQ
         WHERE visibility = cv_objectdescr_public.
      " UNASSIGN + IS ASSIGNED, not sy-subrc - the loop-carried case (see
      " error_get_attributes). Here a stale 0 maps the PREVIOUS attribute's
      " value onto this one's name, i.e. a message id, number or placeholder
      " taken from the wrong attribute
      UNASSIGN <comp>.
      ASSIGN io_obj->(ls_attri_o->name) TO <comp>.
      IF <comp> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.
      result = msg_map( name = ls_attri_o->name
                        val  = <comp>
                        msg  = result ).
    ENDLOOP.

  ENDMETHOD.

  METHOD msg_get_internal_tab.

    " the RAP shape is a property of the ROW TYPE: decided on the first
    " structured row and handed down, not asked of every row - the check
    " describes every table component of a row, which a business table of a
    " few thousand rows paid a few thousand times before the box even
    " decided it carries no message at all
    DATA lv_rap LIKE abap_false.
    DATA lv_first LIKE abap_true.
    FIELD-SYMBOLS <row> TYPE ANY.
        DATA lv_row_kind TYPE string.
    lv_rap = abap_false.

    lv_first = abap_true.

    LOOP AT it_tab ASSIGNING <row>.
      IF lv_first = abap_true.
        lv_first = abap_false.

        lv_row_kind = rtti_get_type_kind( <row> ).
        IF lv_row_kind = cl_abap_datadescr=>typekind_struct1
            OR lv_row_kind = cl_abap_datadescr=>typekind_struct2.
          lv_rap = check_is_rap_struct( <row> ).
        ENDIF.
      ENDIF.
      IF lv_rap = abap_true AND <row> IS NOT INITIAL.
        INSERT LINES OF msg_get_rap( <row> ) INTO TABLE result.
      ELSE.
        INSERT LINES OF msg_get_internal( val          = <row>
                                          iv_check_rap = abap_false ) INTO TABLE result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD msg_get_rap_cause_value.

    " the name of an IF_ABAP_BEHV=>T_FAIL_CAUSE value to its base value;
    " -1 for a name this release does not know, which the text keeps
    " (the upper-case name in a variable first: the downport turns the
    " SWITCH into a CASE, whose operand takes no built-in function on 7.02)
    DATA lv_name TYPE string.
    DATA temp42 TYPE i.
    lv_name = to_upper( name ).

    CASE lv_name.
      WHEN `UNSPECIFIC`.
        temp42 = 0.
      WHEN `UNAUTHORIZED`.
        temp42 = 401.
      WHEN `NOT_FOUND`.
        temp42 = 404.
      WHEN `CONFLICT`.
        temp42 = 409.
      WHEN `LOCKED`.
        temp42 = 423.
      WHEN `DEPENDENCY`.
        temp42 = 424.
      WHEN `NOT_IMPLEMENTED`.
        temp42 = 501.
      WHEN `DISABLED`.
        temp42 = 4221.
      WHEN `READONLY`.
        temp42 = 4222.
      WHEN OTHERS.
        temp42 = -1.
    ENDCASE.
    result = temp42.

  ENDMETHOD.

ENDCLASS.
