"! Applies a generic layout to the XML of ANY view - the half of
"! layout-management that does not need to know which control it works on.
"! A layout here is a list of slots: a control id, whether it is visible, an
"! optional label and width, in display order. apply( ) reads the view the
"! app's builder produced, hides the controls whose slot is not visible
"! (visible="false", together with a Label that points at them with labelFor),
"! replaces their label, sets their width, and reorders them inside the
"! aggregation they sit in - controls the layout does not know keep their
"! place. scan_ids( ) is the inverse: the ids a view carries, so an app can
"! register them with a prefix instead of one by one.
"! The class parses the XML itself: the view builder emits elements and
"! attributes only - no text nodes, no CDATA - and a view that round-trips
"! through here unchanged comes back byte-identical. It has no dependency
"! on the layout tables or the framework, which keeps it testable anywhere.
CLASS z2ui5_cl_layo_xml_tree DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_s_slot,
        "! the id attribute of the control in the view
        id         TYPE string,
        visible    TYPE abap_bool,
        "! the text to write into the label attribute; nothing is written when empty
        label      TYPE string,
        "! the attribute that carries the label - found automatically when empty
        "! (the first of text, title, header, headerText, label, placeholder the
        "! element has, text otherwise)
        label_attr TYPE string,
        "! written into the width attribute when filled
        width      TYPE string,
      END OF ty_s_slot.
    "! the slots in display order - the order inside a parent aggregation
    "! follows the order of this table
    TYPES ty_t_slot TYPE STANDARD TABLE OF ty_s_slot WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_id,
        id         TYPE string,
        "! the element name, e.g. Input or Button
        control    TYPE string,
        "! the current text of the label attribute, unescaped
        label      TYPE string,
        label_attr TYPE string,
      END OF ty_s_id.
    TYPES ty_t_id TYPE STANDARD TABLE OF ty_s_id WITH DEFAULT KEY.

    "! the view with the slots applied - unchanged where no slot names a control
    CLASS-METHODS apply
      IMPORTING
        xml           TYPE string
        t_slot        TYPE ty_t_slot
      RETURNING
        VALUE(result) TYPE string.

    "! every element with an id, in document order; with a prefix only the
    "! ids that start with it (case sensitive, like the id itself)
    CLASS-METHODS scan_ids
      IMPORTING
        xml           TYPE string
        prefix        TYPE string OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_t_id.

    "! the XML escaping of an attribute value - the four characters that may
    "! not stand in one
    CLASS-METHODS escape_xml
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS unescape_xml
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_s_attr,
        n TYPE string,
        v TYPE string,
      END OF ty_s_attr.
    TYPES ty_t_attr  TYPE STANDARD TABLE OF ty_s_attr WITH DEFAULT KEY.
    TYPES ty_t_index TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    CONSTANTS c_element TYPE c LENGTH 1 VALUE 'E' ##NO_TEXT.
    "! anything kept verbatim: text between tags, comments, processing instructions
    CONSTANTS c_raw     TYPE c LENGTH 1 VALUE 'R' ##NO_TEXT.

    TYPES:
      BEGIN OF ty_s_node,
        kind    TYPE c LENGTH 1,
        name    TYPE string,
        raw     TYPE string,
        t_attr  TYPE ty_t_attr,
        parent  TYPE i,
        t_child TYPE ty_t_index,
      END OF ty_s_node.
    TYPES ty_t_node TYPE STANDARD TABLE OF ty_s_node WITH DEFAULT KEY.

    "! node 1 is the document root, never rendered itself
    DATA mt_node TYPE ty_t_node.

    METHODS parse
      IMPORTING
        xml TYPE string.

    METHODS parse_tag
      IMPORTING
        tag           TYPE string
        parent        TYPE i
      RETURNING
        VALUE(result) TYPE i.

    METHODS add_node
      IMPORTING
        node          TYPE ty_s_node
      RETURNING
        VALUE(result) TYPE i.

    METHODS render
      IMPORTING
        index  TYPE i
      CHANGING
        ct_out TYPE string_table.

    METHODS find_by_id
      IMPORTING
        id            TYPE string
      RETURNING
        VALUE(result) TYPE i.

    METHODS attr_get
      IMPORTING
        index         TYPE i
        n             TYPE string
      RETURNING
        VALUE(result) TYPE string.

    METHODS attr_set
      IMPORTING
        index TYPE i
        n     TYPE string
        v     TYPE string.

    METHODS label_attr_of
      IMPORTING
        index         TYPE i
      RETURNING
        VALUE(result) TYPE string.

    "! the Label directly in front of the control, when it points at it
    "! with labelFor - it travels with the control: hidden and moved together
    METHODS label_of
      IMPORTING
        index         TYPE i
      RETURNING
        VALUE(result) TYPE i.

    METHODS apply_slots
      IMPORTING
        t_slot TYPE ty_t_slot.

    METHODS reorder
      IMPORTING
        t_index TYPE ty_t_index.

ENDCLASS.


CLASS z2ui5_cl_layo_xml_tree IMPLEMENTATION.

  METHOD apply.

    DATA lt_out TYPE string_table.
    DATA lo_tree TYPE REF TO z2ui5_cl_layo_xml_tree.

    IF t_slot IS INITIAL.
      result = xml.
      RETURN.
    ENDIF.

    CREATE OBJECT lo_tree.
    lo_tree->parse( xml ).
    lo_tree->apply_slots( t_slot ).
    lo_tree->render( EXPORTING index  = 1
                     CHANGING  ct_out = lt_out ).
    result = concat_lines_of( lt_out ).

  ENDMETHOD.

  METHOD scan_ids.

    DATA lo_tree TYPE REF TO z2ui5_cl_layo_xml_tree.
    DATA ls_id   TYPE ty_s_id.
    DATA lv_id   TYPE string.
    DATA lv_len  TYPE i.
    DATA temp44 LIKE LINE OF lo_tree->mt_node.
    DATA lr_node LIKE REF TO temp44.
      DATA lv_index LIKE sy-tabix.

    CREATE OBJECT lo_tree.
    lo_tree->parse( xml ).

    lv_len = strlen( prefix ).



    LOOP AT lo_tree->mt_node REFERENCE INTO lr_node WHERE kind = c_element.

      lv_index = sy-tabix.
      lv_id = lo_tree->attr_get( index = lv_index
                                 n     = `id` ).
      IF lv_id IS INITIAL.
        CONTINUE.
      ENDIF.
      IF lv_len > 0.
        IF strlen( lv_id ) < lv_len.
          CONTINUE.
        ENDIF.
        IF substring( val = lv_id
                      len = lv_len ) <> prefix.
          CONTINUE.
        ENDIF.
      ENDIF.
      CLEAR ls_id.
      ls_id-id         = unescape_xml( lv_id ).
      ls_id-control    = lr_node->name.
      ls_id-label_attr = lo_tree->label_attr_of( lv_index ).
      ls_id-label      = unescape_xml( lo_tree->attr_get( index = lv_index
                                                      n     = ls_id-label_attr ) ).
      APPEND ls_id TO result.
    ENDLOOP.

  ENDMETHOD.

  METHOD escape_xml.

    result = replace( val  = val
                      sub  = `&`
                      with = `&amp;`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = `<`
                      with = `&lt;`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = `>`
                      with = `&gt;`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = `"`
                      with = `&quot;`
                      occ  = 0 ).

  ENDMETHOD.

  METHOD unescape_xml.

    result = replace( val  = val
                      sub  = `&lt;`
                      with = `<`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = `&gt;`
                      with = `>`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = `&quot;`
                      with = `"`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = `&apos;`
                      with = `'`
                      occ  = 0 ).
    result = replace( val  = result
                      sub  = `&amp;`
                      with = `&`
                      occ  = 0 ).

  ENDMETHOD.

  METHOD add_node.
    DATA lr_parent TYPE REF TO z2ui5_cl_layo_xml_tree=>ty_s_node.

    APPEND node TO mt_node.
    result = lines( mt_node ).
    IF node-parent <= 0.
      RETURN.
    ENDIF.

    READ TABLE mt_node REFERENCE INTO lr_parent INDEX node-parent.
    IF sy-subrc = 0.
      APPEND result TO lr_parent->t_child.
    ENDIF.

  ENDMETHOD.

  METHOD parse.

    DATA ls_node  TYPE ty_s_node.
    DATA lv_pos   TYPE i.
    DATA lv_lt    TYPE i.
    DATA lv_gt    TYPE i.
    DATA lv_len   TYPE i.
    DATA lv_tag   TYPE string.
    DATA lv_close TYPE string.
    DATA lv_quote TYPE string.
    DATA lv_char  TYPE string.
    DATA lv_parent TYPE i.
          FIELD-SYMBOLS <temp45> LIKE LINE OF mt_node.
          DATA temp46 LIKE sy-tabix.
      DATA lv_new TYPE i.

    CLEAR mt_node.
    ls_node-kind = c_raw.
    add_node( ls_node ).

    lv_parent = 1.

    lv_len = strlen( xml ).

    WHILE lv_pos < lv_len.

      lv_lt = find( val = xml
                    sub = `<`
                    off = lv_pos ).

      IF lv_lt < 0.
        " trailing text
        CLEAR ls_node.
        ls_node-kind   = c_raw.
        ls_node-raw    = substring( val = xml
                                    off = lv_pos ).
        ls_node-parent = lv_parent.
        add_node( ls_node ).
        RETURN.
      ENDIF.

      IF lv_lt > lv_pos.
        CLEAR ls_node.
        ls_node-kind   = c_raw.
        ls_node-raw    = substring( val = xml
                                    off = lv_pos
                                    len = lv_lt - lv_pos ).
        ls_node-parent = lv_parent.
        add_node( ls_node ).
      ENDIF.

      " comments and processing instructions are kept as they are
      IF lv_lt + 4 <= lv_len AND substring( val = xml
                                            off = lv_lt
                                            len = 4 ) = `<!--`.
        lv_close = `-->`.
      ELSEIF lv_lt + 2 <= lv_len AND substring( val = xml
                                                off = lv_lt
                                                len = 2 ) = `<?`.
        lv_close = `?>`.
      ELSEIF lv_lt + 2 <= lv_len AND substring( val = xml
                                                off = lv_lt
                                                len = 2 ) = `<!`.
        lv_close = `>`.
      ELSE.
        CLEAR lv_close.
      ENDIF.

      IF lv_close IS NOT INITIAL.
        lv_gt = find( val = xml
                      sub = lv_close
                      off = lv_lt ).
        IF lv_gt < 0.
          lv_gt = lv_len.
        ELSE.
          lv_gt = lv_gt + strlen( lv_close ).
        ENDIF.
        CLEAR ls_node.
        ls_node-kind   = c_raw.
        ls_node-raw    = substring( val = xml
                                    off = lv_lt
                                    len = lv_gt - lv_lt ).
        ls_node-parent = lv_parent.
        add_node( ls_node ).
        lv_pos = lv_gt.
        CONTINUE.
      ENDIF.

      " a tag: attribute values may carry a > - skip quoted parts
      lv_gt = lv_lt + 1.
      CLEAR lv_quote.
      WHILE lv_gt < lv_len.
        lv_char = substring( val = xml
                             off = lv_gt
                             len = 1 ).
        IF lv_quote IS NOT INITIAL.
          IF lv_char = lv_quote.
            CLEAR lv_quote.
          ENDIF.
        ELSEIF lv_char = `"` OR lv_char = `'`.
          lv_quote = lv_char.
        ELSEIF lv_char = `>`.
          EXIT.
        ENDIF.
        lv_gt = lv_gt + 1.
      ENDWHILE.

      lv_tag = substring( val = xml
                          off = lv_lt + 1
                          len = lv_gt - lv_lt - 1 ).
      lv_pos = lv_gt + 1.

      IF lv_tag IS INITIAL.
        CONTINUE.
      ENDIF.

      IF substring( val = lv_tag
                    len = 1 ) = `/`.
        " closing tag - ascend
        IF lv_parent > 1.


          temp46 = sy-tabix.
          READ TABLE mt_node INDEX lv_parent ASSIGNING <temp45>.
          sy-tabix = temp46.
          IF sy-subrc <> 0.
            ASSERT 1 = 0.
          ENDIF.
          lv_parent = <temp45>-parent.
        ENDIF.
        CONTINUE.
      ENDIF.


      lv_new = parse_tag( tag    = lv_tag
                                parent = lv_parent ).
      IF lv_new > 0.
        lv_parent = lv_new.
      ENDIF.

    ENDWHILE.

  ENDMETHOD.

  METHOD parse_tag.

    " returns the new node when the tag opens an element with children to
    " come, 0 when it closed itself
    DATA ls_node TYPE ty_s_node.
    DATA ls_attr TYPE ty_s_attr.
    DATA lv_tag  TYPE string.
    DATA lv_len  TYPE i.
    DATA lv_pos  TYPE i.
    DATA lv_self TYPE abap_bool.
    DATA lv_eq   TYPE i.
    DATA lv_end  TYPE i.
    DATA lv_ws   TYPE string.
    DATA lv_rest TYPE string.
    DATA lv_char TYPE string.
      DATA lv_quote_pos TYPE i.
      DATA lv_quote TYPE string.
    DATA lv_index TYPE i.

    lv_ws = ` ` && cl_abap_char_utilities=>newline && cl_abap_char_utilities=>cr_lf(1) && cl_abap_char_utilities=>horizontal_tab.

    lv_tag = tag.
    lv_len = strlen( lv_tag ).
    IF lv_len > 0 AND substring( val = lv_tag
                                 off = lv_len - 1
                                 len = 1 ) = `/`.
      lv_self = abap_true.
      lv_tag = substring( val = lv_tag
                          len = lv_len - 1 ).
      lv_len = lv_len - 1.
    ENDIF.

    ls_node-kind   = c_element.
    ls_node-parent = parent.

    " the name runs to the first blank
    IF lv_tag CA lv_ws.
      ls_node-name = substring( val = lv_tag
                                len = sy-fdpos ).
      lv_pos = sy-fdpos.
    ELSE.
      ls_node-name = lv_tag.
      lv_pos = lv_len.
    ENDIF.

    WHILE lv_pos < lv_len.
      " skip whitespace
      lv_char = substring( val = lv_tag
                           off = lv_pos
                           len = 1 ).
      IF lv_char CA lv_ws.
        lv_pos = lv_pos + 1.
        CONTINUE.
      ENDIF.
      lv_eq = find( val = lv_tag
                    sub = `=`
                    off = lv_pos ).
      IF lv_eq < 0.
        EXIT.
      ENDIF.
      CLEAR ls_attr.
      ls_attr-n = condense( substring( val = lv_tag
                                       off = lv_pos
                                       len = lv_eq - lv_pos ) ).
      " the value: the first quote after the = up to its twin
      lv_rest = substring( val = lv_tag
                           off = lv_eq ).
      IF lv_rest NA `"'`.
        EXIT.
      ENDIF.

      lv_quote_pos = lv_eq + sy-fdpos.

      lv_quote = substring( val = lv_tag
                                  off = lv_quote_pos
                                  len = 1 ).
      lv_end = find( val = lv_tag
                     sub = lv_quote
                     off = lv_quote_pos + 1 ).
      IF lv_end < 0.
        EXIT.
      ENDIF.
      ls_attr-v = substring( val = lv_tag
                             off = lv_quote_pos + 1
                             len = lv_end - lv_quote_pos - 1 ).
      " a single-quoted value is rewritten double-quoted on render
      IF lv_quote = `'`.
        ls_attr-v = replace( val  = ls_attr-v
                             sub  = `"`
                             with = `&quot;`
                             occ  = 0 ).
      ENDIF.
      APPEND ls_attr TO ls_node-t_attr.
      lv_pos = lv_end + 1.
    ENDWHILE.


    lv_index = add_node( ls_node ).
    IF lv_self = abap_false.
      result = lv_index.
    ENDIF.

  ENDMETHOD.

  METHOD render.

    DATA lv_child TYPE i.

    FIELD-SYMBOLS <temp47> TYPE z2ui5_cl_layo_xml_tree=>ty_s_node.
DATA lr_node LIKE REF TO <temp47>.
    DATA lt_attr TYPE string_table.
    DATA temp48 LIKE LINE OF lr_node->t_attr.
    DATA lr_attr LIKE REF TO temp48.
      DATA temp49 LIKE LINE OF lt_attr.
    DATA lv_attrs TYPE string.
      DATA temp50 LIKE LINE OF ct_out.
    DATA temp51 LIKE LINE OF ct_out.
    DATA temp52 LIKE LINE OF ct_out.
    READ TABLE mt_node INDEX index ASSIGNING <temp47>.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.

GET REFERENCE OF <temp47> INTO lr_node.

    IF lr_node->kind = c_raw.
      " node 1 is the document root: its raw is empty, its children are the document
      IF lr_node->raw IS NOT INITIAL.
        APPEND lr_node->raw TO ct_out.
      ENDIF.
      LOOP AT lr_node->t_child INTO lv_child.
        render( EXPORTING index  = lv_child
                CHANGING  ct_out = ct_out ).
      ENDLOOP.
      RETURN.
    ENDIF.




    LOOP AT lr_node->t_attr REFERENCE INTO lr_attr.

      temp49 = | { lr_attr->n }="{ lr_attr->v }"|.
      APPEND temp49 TO lt_attr.
    ENDLOOP.

    lv_attrs = concat_lines_of( lt_attr ).

    IF lr_node->t_child IS INITIAL.

      temp50 = |<{ lr_node->name }{ lv_attrs }/>|.
      APPEND temp50 TO ct_out.
      RETURN.
    ENDIF.


    temp51 = |<{ lr_node->name }{ lv_attrs }>|.
    APPEND temp51 TO ct_out.
    LOOP AT lr_node->t_child INTO lv_child.
      render( EXPORTING index  = lv_child
              CHANGING  ct_out = ct_out ).
    ENDLOOP.

    temp52 = |</{ lr_node->name }>|.
    APPEND temp52 TO ct_out.

  ENDMETHOD.

  METHOD find_by_id.

    DATA lv_id TYPE string.
    DATA temp53 LIKE LINE OF mt_node.
    DATA lr_node LIKE REF TO temp53.
      DATA lv_tabix LIKE sy-tabix.
      DATA temp54 LIKE sy-subrc.
      DATA temp55 LIKE sy-tabix.

    lv_id = escape_xml( id ).



    LOOP AT mt_node REFERENCE INTO lr_node WHERE kind = c_element.

      lv_tabix = sy-tabix.


      temp55 = sy-tabix.
      READ TABLE lr_node->t_attr WITH KEY n = `id` v = lv_id TRANSPORTING NO FIELDS.
      temp54 = sy-subrc.
      sy-tabix = temp55.
      IF temp54 = 0. "#EC CI_SORTSEQ
        result = lv_tabix.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD attr_get.
    DATA lr_node TYPE REF TO z2ui5_cl_layo_xml_tree=>ty_s_node.
    DATA lr_attr TYPE REF TO z2ui5_cl_layo_xml_tree=>ty_s_attr.

    IF index <= 0 OR n IS INITIAL.
      RETURN.
    ENDIF.

    READ TABLE mt_node REFERENCE INTO lr_node INDEX index.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    READ TABLE lr_node->t_attr REFERENCE INTO lr_attr WITH KEY n = n. "#EC CI_SORTSEQ
    IF sy-subrc = 0.
      result = lr_attr->v.
    ENDIF.

  ENDMETHOD.

  METHOD attr_set.

    FIELD-SYMBOLS <temp56> TYPE z2ui5_cl_layo_xml_tree=>ty_s_node.
DATA lr_node LIKE REF TO <temp56>.
    DATA lr_attr TYPE REF TO z2ui5_cl_layo_xml_tree=>ty_s_attr.
    DATA temp57 TYPE z2ui5_cl_layo_xml_tree=>ty_s_attr.
    READ TABLE mt_node INDEX index ASSIGNING <temp56>.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.

GET REFERENCE OF <temp56> INTO lr_node.

    READ TABLE lr_node->t_attr REFERENCE INTO lr_attr WITH KEY n = n. "#EC CI_SORTSEQ
    IF sy-subrc = 0.
      lr_attr->v = v.
      RETURN.
    ENDIF.

    CLEAR temp57.
    temp57-n = n.
    temp57-v = v.
    APPEND temp57 TO lr_node->t_attr.

  ENDMETHOD.

  METHOD label_attr_of.

    DATA lt_cand TYPE string_table.
    DATA lv_cand TYPE string.

    DATA temp58 TYPE string_table.
    DATA lr_node TYPE REF TO z2ui5_cl_layo_xml_tree=>ty_s_node.
        DATA temp60 LIKE sy-subrc.
    CLEAR temp58.
    INSERT `text` INTO TABLE temp58.
    INSERT `title` INTO TABLE temp58.
    INSERT `header` INTO TABLE temp58.
    INSERT `headerText` INTO TABLE temp58.
    INSERT `label` INTO TABLE temp58.
    INSERT `placeholder` INTO TABLE temp58.
    lt_cand = temp58.

    " not line_exists( mt_node[ index ]-t_attr[ n = lv_cand ] ): the 7.02
    " downport drops the inner key of a chained table expression

    READ TABLE mt_node REFERENCE INTO lr_node INDEX index.
    IF sy-subrc = 0.
      LOOP AT lt_cand INTO lv_cand.

        READ TABLE lr_node->t_attr WITH KEY n = lv_cand TRANSPORTING NO FIELDS.
        temp60 = sy-subrc.
        IF temp60 = 0. "#EC CI_SORTSEQ
          result = lv_cand.
          RETURN.
        ENDIF.
      ENDLOOP.
    ENDIF.

    result = `text`.

  ENDMETHOD.

  METHOD label_of.

    DATA lv_prev TYPE i.
    DATA lv_pos  TYPE i.

    FIELD-SYMBOLS <temp61> TYPE z2ui5_cl_layo_xml_tree=>ty_s_node.
DATA lr_node LIKE REF TO <temp61>.
    FIELD-SYMBOLS <temp62> TYPE z2ui5_cl_layo_xml_tree=>ty_s_node.
DATA lr_parent LIKE REF TO <temp62>.
    FIELD-SYMBOLS <temp63> LIKE LINE OF lr_parent->t_child.
    DATA temp64 LIKE sy-tabix.
    FIELD-SYMBOLS <temp65> TYPE z2ui5_cl_layo_xml_tree=>ty_s_node.
DATA lr_prev LIKE REF TO <temp65>.
    DATA lv_for TYPE string.
    READ TABLE mt_node INDEX index ASSIGNING <temp61>.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.

GET REFERENCE OF <temp61> INTO lr_node.
    IF lr_node->parent <= 0.
      RETURN.
    ENDIF.


    READ TABLE mt_node INDEX lr_node->parent ASSIGNING <temp62>.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.

GET REFERENCE OF <temp62> INTO lr_parent.
    READ TABLE lr_parent->t_child WITH KEY table_line = index TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0 OR sy-tabix <= 1.
      RETURN.
    ENDIF.
    lv_pos = sy-tabix - 1.


    temp64 = sy-tabix.
    READ TABLE lr_parent->t_child INDEX lv_pos ASSIGNING <temp63>.
    sy-tabix = temp64.
    IF sy-subrc <> 0.
      ASSERT 1 = 0.
    ENDIF.
    lv_prev = <temp63>.


    READ TABLE mt_node INDEX lv_prev ASSIGNING <temp65>.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.

GET REFERENCE OF <temp65> INTO lr_prev.
    IF lr_prev->kind <> c_element.
      RETURN.
    ENDIF.
    IF lr_prev->name <> `Label` AND lr_prev->name NP `*:Label`.
      RETURN.
    ENDIF.

    lv_for = attr_get( index = lv_prev
                             n     = `labelFor` ).
    IF lv_for <> attr_get( index = index
                           n     = `id` ).
      RETURN.
    ENDIF.
    result = lv_prev.

  ENDMETHOD.

  METHOD apply_slots.

    DATA lt_index TYPE ty_t_index.

    DATA temp66 LIKE LINE OF t_slot.
    DATA lr_slot LIKE REF TO temp66.
      DATA lv_index TYPE i.
      DATA lv_label TYPE i.
        DATA lv_attr LIKE lr_slot->label_attr.
    LOOP AT t_slot REFERENCE INTO lr_slot.


      lv_index = find_by_id( lr_slot->id ).
      IF lv_index = 0.
        CONTINUE.
      ENDIF.
      APPEND lv_index TO lt_index.


      lv_label = label_of( lv_index ).

      IF lr_slot->visible = abap_false.
        attr_set( index = lv_index
                  n     = `visible`
                  v     = `false` ).
        IF lv_label > 0.
          attr_set( index = lv_label
                    n     = `visible`
                    v     = `false` ).
        ENDIF.
      ENDIF.

      IF lr_slot->label IS NOT INITIAL.

        lv_attr = lr_slot->label_attr.
        IF lv_attr IS INITIAL.
          lv_attr = label_attr_of( lv_index ).
        ENDIF.
        " a Label in front of the control carries the text the user sees
        IF lv_label > 0 AND lr_slot->label_attr IS INITIAL.
          attr_set( index = lv_label
                    n     = `text`
                    v     = escape_xml( lr_slot->label ) ).
        ELSE.
          attr_set( index = lv_index
                    n     = lv_attr
                    v     = escape_xml( lr_slot->label ) ).
        ENDIF.
      ENDIF.

      IF lr_slot->width IS NOT INITIAL.
        attr_set( index = lv_index
                  n     = `width`
                  v     = escape_xml( lr_slot->width ) ).
      ENDIF.

    ENDLOOP.

    reorder( lt_index ).

  ENDMETHOD.

  METHOD reorder.

    " t_index holds the matched controls in the order the layout wants.
    " Inside each parent, the positions the matched controls (and the Labels
    " that travel with them) occupy are refilled in that order; every other
    " child keeps its position
    TYPES:
      BEGIN OF ty_s_block,
        parent  TYPE i,
        t_index TYPE ty_t_index,
      END OF ty_s_block.
    DATA lt_block   TYPE STANDARD TABLE OF ty_s_block WITH DEFAULT KEY.
    DATA lt_parent  TYPE ty_t_index.
    DATA lv_index   TYPE i.
    DATA lv_member  TYPE i.
    DATA lv_parent  TYPE i.
    DATA lt_pos     TYPE ty_t_index.
    DATA lt_members TYPE ty_t_index.
    DATA lv_pos     TYPE i.
      DATA temp67 TYPE ty_s_block.
      FIELD-SYMBOLS <temp7> LIKE LINE OF mt_node.
      DATA temp8 LIKE sy-tabix.
      DATA ls_block LIKE temp67.
      DATA lv_label TYPE i.
      DATA temp68 LIKE sy-subrc.
      DATA temp69 LIKE sy-tabix.
      FIELD-SYMBOLS <temp70> TYPE z2ui5_cl_layo_xml_tree=>ty_s_node.
DATA lr_parent LIKE REF TO <temp70>.
      DATA temp71 LIKE LINE OF lt_block.
      DATA lr_block LIKE REF TO temp71.
        DATA temp72 LIKE sy-subrc.
        DATA temp73 LIKE sy-tabix.
        DATA lv_tabix LIKE sy-tabix.
        FIELD-SYMBOLS <temp74> LIKE LINE OF lt_pos.
        DATA temp75 LIKE sy-tabix.
        FIELD-SYMBOLS <temp76> LIKE LINE OF lr_parent->t_child.
        DATA temp77 LIKE sy-tabix.

    LOOP AT t_index INTO lv_index.

      CLEAR temp67.


      temp8 = sy-tabix.
      READ TABLE mt_node INDEX lv_index ASSIGNING <temp7>.
      sy-tabix = temp8.
      IF sy-subrc <> 0.
        ASSERT 1 = 0.
      ENDIF.
      temp67-parent = <temp7>-parent.

      ls_block = temp67.

      lv_label = label_of( lv_index ).
      IF lv_label > 0.
        APPEND lv_label TO ls_block-t_index.
      ENDIF.
      APPEND lv_index TO ls_block-t_index.
      APPEND ls_block TO lt_block.


      temp69 = sy-tabix.
      READ TABLE lt_parent WITH KEY table_line = ls_block-parent TRANSPORTING NO FIELDS.
      temp68 = sy-subrc.
      sy-tabix = temp69.
      IF NOT temp68 = 0.
        APPEND ls_block-parent TO lt_parent.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_parent INTO lv_parent.


      READ TABLE mt_node INDEX lv_parent ASSIGNING <temp70>.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.

GET REFERENCE OF <temp70> INTO lr_parent.

      " the positions occupied, in document order, and the members in layout order
      CLEAR lt_members.


      LOOP AT lt_block REFERENCE INTO lr_block WHERE parent = lv_parent. "#EC CI_SORTSEQ
        APPEND LINES OF lr_block->t_index TO lt_members.
      ENDLOOP.

      CLEAR lt_pos.
      " the position is kept before line_exists( ) - a system field is read
      " right after the statement that sets it
      LOOP AT lr_parent->t_child INTO lv_member.
        lv_pos = sy-tabix.


        temp73 = sy-tabix.
        READ TABLE lt_members WITH KEY table_line = lv_member TRANSPORTING NO FIELDS.
        temp72 = sy-subrc.
        sy-tabix = temp73.
        IF temp72 = 0.
          APPEND lv_pos TO lt_pos.
        ENDIF.
      ENDLOOP.

      LOOP AT lt_members INTO lv_member.

        lv_tabix = sy-tabix.


        temp75 = sy-tabix.
        READ TABLE lt_pos INDEX lv_tabix ASSIGNING <temp74>.
        sy-tabix = temp75.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        lv_pos = <temp74>.


        temp77 = sy-tabix.
        READ TABLE lr_parent->t_child INDEX lv_pos ASSIGNING <temp76>.
        sy-tabix = temp77.
        IF sy-subrc <> 0.
          ASSERT 1 = 0.
        ENDIF.
        <temp76> = lv_member.
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
