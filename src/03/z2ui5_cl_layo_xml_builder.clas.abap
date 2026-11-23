CLASS z2ui5_cl_layo_xml_builder DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    "! Render a sap.m.Table for the layout into i_xml, a node of a
    "! z2ui5_cl_ui5_view_builder view. Declare the namespaces it may write
    "! on the root of that view: xmlns:core (sap.ui.core), xmlns:mchart
    "! (sap.suite.ui.microchart) and xmlns:si
    "! (sap.suite.ui.commons.statusindicator)
    CLASS-METHODS xml_build_table
      IMPORTING
        i_data             TYPE REF TO data
        i_xml              TYPE REF TO z2ui5_cl_ui5_view_builder
        I_client           TYPE REF TO z2ui5_if_client
        i_layout           TYPE REF TO z2ui5_cl_layo_manager
        i_search_value     TYPE REF TO data OPTIONAL
        i_growingthreshold TYPE string      OPTIONAL
        i_headertext       TYPE string      OPTIONAL
        i_Sel_mode         TYPE string      OPTIONAL
        i_sel_BIND_TO      TYPE string      OPTIONAL
        i_col_type         TYPE string      OPTIONAL
        i_col_bind_to      TYPE string      OPTIONAL.

    "! Render a sap.ui.layout.form.SimpleForm for the layout into i_xml, a
    "! node of a z2ui5_cl_ui5_view_builder view. Declare the namespaces it may
    "! write on the root of that view: xmlns:form (sap.ui.layout.form),
    "! xmlns:layout (sap.ui.layout), xmlns:core (sap.ui.core), xmlns:mchart
    "! (sap.suite.ui.microchart) and xmlns:si
    "! (sap.suite.ui.commons.statusindicator)
    CLASS-METHODS xml_build_simple_form
      IMPORTING
        i_DATA   TYPE REF TO data
        i_xml    TYPE REF TO z2ui5_cl_ui5_view_builder
        I_client TYPE REF TO z2ui5_if_client
        i_layout TYPE REF TO z2ui5_cl_layo_manager
        i_title  TYPE string OPTIONAL.

  PROTECTED SECTION.




  PRIVATE SECTION.
    TYPES: BEGIN OF ty_s_grid_layout,
             label    TYPE string,
             value    TYPE string,
             ref_fied TYPE string,
           END OF ty_s_grid_layout.

    CLASS-METHODS xml_build_status_indicator
      IMPORTING
        i_data        TYPE REF TO data OPTIONAL
        I_client      TYPE REF TO z2ui5_if_client
        i_layout      TYPE REF TO z2ui5_cl_layo_manager=>ty_s_positions
        i_xml         TYPE REF TO z2ui5_cl_ui5_view_builder
      RETURNING
        VALUE(result) TYPE  REF TO z2ui5_cl_ui5_view_builder.

    CLASS-METHODS xml_build_progress_indicator
      IMPORTING
        i_data        TYPE REF TO data OPTIONAL
        I_client      TYPE REF TO z2ui5_if_client
        i_layout      TYPE REF TO z2ui5_cl_layo_manager=>ty_s_positions
        i_xml         TYPE REF TO z2ui5_cl_ui5_view_builder
      RETURNING
        VALUE(result) TYPE  REF TO z2ui5_cl_ui5_view_builder.

    CLASS-METHODS xml_build_radial_microchart
      IMPORTING
        i_data        TYPE REF TO data OPTIONAL
        I_client      TYPE REF TO z2ui5_if_client
        i_layout      TYPE REF TO z2ui5_cl_layo_manager=>ty_s_positions
        i_xml         TYPE REF TO z2ui5_cl_ui5_view_builder
      RETURNING
        VALUE(result) TYPE  REF TO z2ui5_cl_ui5_view_builder.

    CLASS-METHODS xml_build_icon
      IMPORTING
        i_data        TYPE REF TO data OPTIONAL
        I_client      TYPE REF TO z2ui5_if_client
        i_layout      TYPE REF TO z2ui5_cl_layo_manager=>ty_s_positions
        i_xml         TYPE REF TO z2ui5_cl_ui5_view_builder
      RETURNING
        VALUE(result) TYPE  REF TO z2ui5_cl_ui5_view_builder.

    CLASS-METHODS xml_build_generic_tag
      IMPORTING
        i_data        TYPE REF TO data OPTIONAL
        I_client      TYPE REF TO z2ui5_if_client
        i_layout      TYPE REF TO z2ui5_cl_layo_manager=>ty_s_positions
        i_xml         TYPE REF TO z2ui5_cl_ui5_view_builder
      RETURNING
        VALUE(result) TYPE  REF TO z2ui5_cl_ui5_view_builder.

    CLASS-METHODS get_grid_layout
      IMPORTING
        !layout       TYPE REF TO z2ui5_cl_layo_manager=>ty_s_positions
      RETURNING
        VALUE(result) TYPE ty_s_grid_layout.

    CLASS-METHODS set_layout_for_element
      IMPORTING
        span  TYPE string
        i_xml TYPE REF TO z2ui5_cl_ui5_view_builder.

    CLASS-METHODS value_formatter
      IMPORTING
        I_client      TYPE REF TO z2ui5_if_client
        !value        TYPE any
        !layout       type ref to z2ui5_cl_layo_manager=>ty_s_positions
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS table_value_formatter
      IMPORTING
        !position     TYPE z2ui5_cl_layo_manager=>ty_s_positions
      RETURNING
        VALUE(result) TYPE string.

ENDCLASS.


CLASS z2ui5_cl_layo_xml_builder IMPLEMENTATION.

  METHOD xml_build_simple_form.

    z2ui5_cl_layo_pop=>render_layout_function( client = i_client
                                               xml    = i_xml
                                               layout = i_layout ).

    DATA(form) = i_xml->ele( n = `SimpleForm` ns = `form` ).

    IF i_title IS NOT INITIAL.
      form->a( n = `title` v = i_title ).
    ENDIF.

    DATA(line) = form->a( n = `layout`                  v = `ResponsiveGridLayout`
                    )->a( n = `emptySpanL`              v = `4`
                    )->a( n = `emptySpanM`              v = `2`
                    )->a( n = `emptySpanS`              v = `0`
                    )->a( n = `emptySpanXL`             v = `4`
                    )->a( n = `labelSpanL`              v = `3`
                    )->a( n = `labelSpanM`              v = `3`
                    )->a( n = `labelSpanS`              v = `3`
                    )->a( n = `labelSpanXL`             v = `3`
                    )->a( n = `singleContainerFullSize` b = abap_false
                    )->a( n = `columnsXL`               v = `1`
                    )->a( n = `columnsL`                v = `1`
                    )->a( n = `columnsM`                v = `1`
                    )->a( n = `editable`                b = abap_true
                    )->ele( n = `content` ns = `form` ).

    LOOP AT i_layout->ms_layout-t_layout REFERENCE INTO DATA(layout).

      DATA(lv_index) = sy-tabix.

      " sy-subrc, not IS ASSIGNED: a failed ASSIGN COMPONENT keeps the field
      " symbol on the previous column, which then rendered a second time
      ASSIGN COMPONENT layout->fname OF STRUCTURE i_data->* TO FIELD-SYMBOL(<value>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      DATA(grid_layout) = get_grid_layout( layout ).

      DATA(label) = line->ele( `Label`
          )->a( n = `text`     v = i_client->_bind( val       = layout->tlabel
                                                    tab       = i_layout->ms_layout-t_layout
                                                    tab_index = lv_index )
          )->a( n = `wrapping` b = abap_false
          )->a( n = `labelFor` v = ` ` ).

      set_layout_for_element( i_xml = label
                              span  = grid_layout-label ).

      IF    layout->rollname CP `*_XML_S_ICON`
         OR layout->rollname CP `*_XML_S_PROGRESSIND`
         OR layout->rollname CP `*_XML_S_GENERICTAG`
         OR layout->rollname CP `*_XML_S_STATUSIND`
         OR layout->rollname CP `*_XML_S_RADIALCHART`.

        DATA(hbox) = line->ele( `HBox`
            )->a( n = `renderType` v = `Bare`
            )->a( n = `visible`    v = i_client->_bind( val       = layout->visible
                                                        tab       = i_layout->ms_layout-t_layout
                                                        tab_index = lv_index ) ).

        set_layout_for_element( i_xml = hbox
                                span  = grid_layout-value ).

        IF layout->rollname CP `*_XML_S_ICON`.

          xml_build_icon( i_layout = layout
                          i_data   = i_data
                          i_client = i_client
                          i_xml    = hbox ).

        ELSEIF layout->rollname CP `*_XML_S_PROGRESSIND`.

          xml_build_progress_indicator( i_layout = layout
                                        i_data   = i_data
                                        i_client = i_client
                                        i_xml    = hbox ).

        ELSEIF layout->rollname CP `*_XML_S_GENERICTAG`.

          xml_build_generic_tag( i_layout = layout
                                 i_data   = i_data
                                 i_client = i_client
                                 i_xml    = hbox ).

        ELSEIF layout->rollname CP `*_XML_S_STATUSIND`.

          xml_build_status_indicator( i_data   = i_data
                                      i_client = i_client
                                      i_layout = layout
                                      i_xml    = hbox ).

        ELSE.

          xml_build_radial_microchart( i_data   = i_data
                                       i_client = i_client
                                       i_layout = layout
                                       i_xml    = hbox ).

        ENDIF.

      ELSE.

        DATA(input) = line->ele( `Input`
            )->a( n = `enabled` b = abap_false
            )->a( n = `visible` v = i_client->_bind( val       = layout->visible
                                                     tab       = i_layout->ms_layout-t_layout
                                                     tab_index = lv_index )
            )->a( n = `value`   v = value_formatter( layout   = layout
                                                     i_client = i_client
                                                     value    = <value> )
            )->a( n = `width`   v = i_client->_bind( val       = layout->width
                                                     tab       = i_layout->ms_layout-t_layout
                                                     tab_index = lv_index ) ).

        set_layout_for_element( i_xml = input
                                span  = grid_layout-value ).

      ENDIF.

      IF layout->reference_field IS NOT INITIAL.

        ASSIGN COMPONENT layout->reference_field OF STRUCTURE i_data->* TO FIELD-SYMBOL(<ref_value>).
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        " a table expression with OPTIONAL sets no sy-subrc - test the
        " reference, value_formatter( ) dereferences it
        DATA(ref_field) = REF #( i_layout->ms_layout-t_layout[ fname = layout->reference_field ] OPTIONAL ).
        IF ref_field IS NOT BOUND.
          CONTINUE.
        ENDIF.

        DATA(ref_input) = line->ele( `Input`
            )->a( n = `enabled` b = abap_false
            )->a( n = `visible` v = i_client->_bind( val       = layout->visible
                                                     tab       = i_layout->ms_layout-t_layout
                                                     tab_index = lv_index )
            )->a( n = `value`   v = value_formatter( layout   = ref_field
                                                     i_client = i_client
                                                     value    = <ref_value> ) ).

        set_layout_for_element( i_xml = ref_input
                                span  = grid_layout-ref_fied ).

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_grid_layout.

    IF layout->grid_label_xl > 0.
      DATA(label_xl) = |XL{ layout->grid_label_xl }|.
    ENDIF.
    IF layout->grid_label_l > 0.
      DATA(label_l) = |L{ layout->grid_label_l }|.
    ENDIF.
    IF layout->grid_label_m > 0.
      DATA(label_m) = |M{ layout->grid_label_m }|.
    ENDIF.
    IF layout->grid_label_s > 0.
      DATA(label_s) = |S{ layout->grid_label_s }|.
    ENDIF.

    IF label_xl IS NOT INITIAL.
      result-label = |{ result-label }{ label_xl } |.
    ENDIF.
    IF label_l IS NOT INITIAL.
      result-label = |{ result-label }{ label_l } |.
    ENDIF.
    IF label_m IS NOT INITIAL.
      result-label = |{ result-label }{ label_m } |.
    ENDIF.
    IF label_s IS NOT INITIAL.
      result-label = |{ result-label }{ label_s }|.
    ENDIF.

    IF layout->reference_field IS NOT INITIAL.

      DATA(ref_size) = 1.
      result-ref_fied = |XL1 L1 M1 S2|.

    ENDIF.

    IF layout->grid_value_xl > 0.
      DATA(value_xl) = |XL{ layout->grid_value_xl - ref_size }|.
    ENDIF.
    IF layout->grid_value_l > 0.
      DATA(value_l) = |L{ layout->grid_value_l - ref_size }|.
    ENDIF.
    IF layout->grid_value_m > 0.
      DATA(value_m) = |M{ layout->grid_value_m - ref_size }|.
    ENDIF.
    IF layout->grid_value_s > 0.
      DATA(value_s) = |S{ layout->grid_value_s - ref_size - 1 }|.
    ENDIF.

    IF value_xl IS NOT INITIAL.
      result-value = |{ result-value }{ value_xl } |.
    ENDIF.
    IF value_l IS NOT INITIAL.
      result-value = |{ result-value }{ value_l } |.
    ENDIF.
    IF value_m IS NOT INITIAL.
      result-value = |{ result-value }{ value_m } |.
    ENDIF.
    IF value_s IS NOT INITIAL.
      result-value = |{ result-value }{ value_s }|.
    ENDIF.

  ENDMETHOD.

  METHOD set_layout_for_element.

    " i_xml is the control itself: its layoutData aggregation carries the
    " grid span of the ResponsiveGridLayout
    IF span IS INITIAL.
      RETURN.
    ENDIF.

    i_xml->ele( `layoutData`
        )->tag( n = `GridData` ns = `layout`
            )->a( n = `span` v = span ).

  ENDMETHOD.

  METHOD xml_build_table.

    ASSIGN i_data->* TO FIELD-SYMBOL(<tab>).

    DATA(table) = i_xml->ele( `Table`
        )->a( n = `items`   v = i_client->_bind( <tab> )
        )->a( n = `growing` b = xsdbool( i_growingthreshold <> space ) ).

    IF i_growingthreshold IS NOT INITIAL.
      table->a( n = `growingThreshold` v = i_growingthreshold ).
    ENDIF.

    table->a( n = `mode`            v = COND #( WHEN i_sel_mode = space THEN `None` ELSE i_sel_mode )
        )->a( n = `width`           v = `auto`
        )->a( n = `selectionChange` v = i_client->_event( 'SELECTION_CHANGE' ) ).

    DATA(toolbar) = table->ele( `headerToolbar`
        )->ele( `OverflowToolbar` ).

    IF i_headertext IS NOT INITIAL.
      toolbar->tag( `Title`
          )->a( n = `text`  v = i_headertext
          )->a( n = `level` v = `H2` ).
    ENDIF.

    toolbar->tag( `ToolbarSpacer` ).

    IF i_search_value IS SUPPLIED.

      ASSIGN i_search_value->* TO FIELD-SYMBOL(<search>).

      toolbar->tag( `SearchField`
          )->a( n = `width`  v = `17.5rem`
          )->a( n = `search` v = i_client->_event( 'SEARCH' )
          )->a( n = `value`  v = i_client->_bind( <search> )
          )->a( n = `id`     v = `SEARCH`
          )->a( n = `change` v = i_client->_event( 'SEARCH' ) ).
    ENDIF.

    z2ui5_cl_layo_pop=>render_layout_function( client = i_client
                                               xml    = toolbar
                                               layout = i_layout ).

    DATA(columns) = table->ele( `columns` ).

    LOOP AT i_layout->ms_layout-t_layout REFERENCE INTO DATA(layout).
      DATA(lv_index) = sy-tabix.

      DATA(column) = columns->ele( `Column`
          )->a( n = `width`           v = i_client->_bind( val       = layout->width
                                                           tab       = i_layout->ms_layout-t_layout
                                                           tab_index = lv_index )
          )->a( n = `mergeDuplicates` v = i_client->_bind( val       = layout->merge
                                                           tab       = i_layout->ms_layout-t_layout
                                                           tab_index = lv_index )
          )->a( n = `visible`         v = i_client->_bind( val       = layout->visible
                                                           tab       = i_layout->ms_layout-t_layout
                                                           tab_index = lv_index ) ).

      " the label is text (a DDIC text or the user's alternative text), so a
      " brace in it must show, not open a binding
      column->tag( `Text` ).
      IF layout->tlabel IS NOT INITIAL.
        column->a( n = `text` t = layout->tlabel ).
      ENDIF.

    ENDLOOP.

    DATA(column_list_item) = table->ele( `items`
        )->ele( `ColumnListItem`
            )->a( n = `vAlign` v = `Middle` ).

    IF i_sel_bind_to <> space.
      column_list_item->a( n = `selected` v = |\{{ i_sel_bind_to }\}| ).
    ENDIF.

    column_list_item->a( n = `type`  v = COND #( WHEN i_col_type = space THEN `Inactive` ELSE i_col_type )
        )->a( n = `press` v = i_client->_event( val   = 'ROW_SELECT'
                                                t_arg = VALUE #( ( COND #( WHEN i_col_bind_to = space
                                                                           THEN ``
                                                                           ELSE |$\{{ i_col_bind_to }\}| ) ) ) ) ).

    DATA(cells) = column_list_item->ele( `cells` ).

    LOOP AT i_layout->ms_layout-t_layout REFERENCE INTO layout.

      lv_index = sy-tabix.

      IF layout->rollname CP `*_XML_S_ICON`.

        xml_build_icon( i_client = i_client
                        i_layout = layout
                        i_xml    = cells ).

      ELSEIF layout->rollname CP `*_XML_S_RADIALCHART`.

        xml_build_radial_microchart( i_layout = layout
                                     i_client = i_client
                                     i_xml    = cells ).

      ELSEIF layout->rollname CP `*_XML_S_PROGRESSIND`.

        xml_build_progress_indicator( i_layout = layout
                                      i_client = i_client
                                      i_xml    = cells ).

      ELSEIF layout->rollname CP `*_XML_S_STATUSIND`.

        xml_build_status_indicator( i_layout = layout
                                    i_client = i_client
                                    i_xml    = cells ).

      ELSEIF layout->rollname CP `*_XML_S_GENERICTAG`.

        xml_build_generic_tag( i_layout = layout
                               i_client = i_client
                               i_xml    = cells ).

      ELSE.

        " the reference field of this column - only when it is a column, a
        " failed READ used to leave the previous column's one in the work area
        DATA(ref) = VALUE z2ui5_cl_layo_manager=>ty_s_positions( ).
        IF layout->reference_field IS NOT INITIAL.
          READ TABLE i_layout->ms_layout-t_layout INTO ref WITH KEY fname = layout->reference_field.
          IF sy-subrc <> 0.
            CLEAR ref.
          ENDIF.
        ENDIF.

        DATA(cell_text) = table_value_formatter( layout->* ).
        IF ref IS NOT INITIAL.
          cell_text = |{ cell_text } { table_value_formatter( ref ) }|.
        ENDIF.

        IF layout->t_sub_col IS INITIAL.

          cells->tag( `ObjectIdentifier`
              )->a( n = `text` v = cell_text ).

        ELSE.

          DATA(sub_col) = ``.

          LOOP AT layout->t_sub_col INTO DATA(subcol).

            " a subcolumn that is no column (any more) is skipped - a failed
            " READ left the previous subcolumn in the work area, rendered twice
            READ TABLE i_layout->ms_layout-t_layout INTO DATA(line) WITH KEY fname = subcol-fname.
            IF sy-subrc <> 0.
              CONTINUE.
            ENDIF.

            " the label is literal text inside a value that carries bindings
            DATA(col_text) = |{ z2ui5_cl_ui5_view_builder=>escape_literal( line-tlabel ) }: { table_value_formatter( line ) }|.

            IF line-reference_field IS NOT INITIAL.
              READ TABLE i_layout->ms_layout-t_layout INTO DATA(sub_ref) WITH KEY fname = line-reference_field.
              IF sy-subrc = 0.
                col_text = |{ col_text } { table_value_formatter( sub_ref ) }|.
              ENDIF.
            ENDIF.

            IF sub_col IS INITIAL.
              sub_col = col_text.
            ELSE.
              sub_col = |{ sub_col }{ cl_abap_char_utilities=>cr_lf }{ col_text }|.
            ENDIF.
          ENDLOOP.

          cells->tag( `ObjectIdentifier`
              )->a( n = `text`  v = sub_col
              )->a( n = `title` v = cell_text ).

        ENDIF.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD table_value_formatter.

*    result = COND #( WHEN position-no_leading_zero = abap_true
*                     THEN |\{path : '{ position-fname }', type : 'sap.ui.model.odata.type.String', constraints : \{  isDigitSequence : true \} \}|
*                     ELSE |\{{ position-fname }\}| ).

 result = |\{{ position-fname }\}|.

  ENDMETHOD.

  METHOD xml_build_icon.

    IF i_data IS NOT SUPPLIED. " Table case

      i_xml->tag( n = `Icon` ns = `core`
          )->a( n = `size` v = |\{{ i_layout->fname }/ICON_SIZE\}|
          )->a( n = `src`  v = |\{{ i_layout->fname }/SRC\}| ).

    ELSE.

      ASSIGN COMPONENT |{ i_layout->fname }-SRC| OF STRUCTURE i_data->* TO FIELD-SYMBOL(<src>).
      IF <src> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      ASSIGN COMPONENT |{ i_layout->fname }-ICON_SIZE| OF STRUCTURE i_data->* TO FIELD-SYMBOL(<size>).
      IF <size> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      i_xml->tag( n = `Icon` ns = `core`
          )->a( n = `size` v = i_client->_bind( val = <size> )
          )->a( n = `src`  v = i_client->_bind( val = <src> ) ).

    ENDIF.

    result = i_xml.

  ENDMETHOD.

  METHOD xml_build_radial_microchart.

    IF i_data IS NOT SUPPLIED. " Table case

      i_xml->tag( n = `RadialMicroChart` ns = `mchart`
          )->a( n = `percentage`   v = |\{{ i_layout->fname }/PERCENTAGE\}|
          )->a( n = `size`         v = |\{{ i_layout->fname }/RADIALMICROCHART_SIZE\}|
          )->a( n = `hideOnNoData` v = |\{{ i_layout->fname }/HIDEONNODATA\}|
          )->a( n = `valueColor`   v = |\{{ i_layout->fname }/VALUECOLOR\}| ).

    ELSE.

      ASSIGN COMPONENT |{ i_layout->fname }-RADIALMICROCHART_SIZE| OF STRUCTURE i_data->* TO FIELD-SYMBOL(<size>).
      IF <size> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      ASSIGN COMPONENT |{ i_layout->fname }-PERCENTAGE| OF STRUCTURE i_data->* TO FIELD-SYMBOL(<percentage>).
      IF <percentage> IS NOT ASSIGNED.
        RETURN.
      ENDIF.
      ASSIGN COMPONENT |{ i_layout->fname }-VALUECOLOR| OF STRUCTURE i_data->* TO FIELD-SYMBOL(<valuecolor>).
      IF <valuecolor> IS NOT ASSIGNED.
        RETURN.
      ENDIF.
      ASSIGN COMPONENT |{ i_layout->fname }-HIDEONNODATA| OF STRUCTURE i_data->* TO FIELD-SYMBOL(<hideonnodata>).
      IF <hideonnodata> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      i_xml->tag( n = `RadialMicroChart` ns = `mchart`
          )->a( n = `percentage`   v = i_client->_bind( val = <percentage> )
          )->a( n = `size`         v = i_client->_bind( val = <size> )
          )->a( n = `hideOnNoData` v = i_client->_bind( val = <hideonnodata> )
          )->a( n = `valueColor`   v = i_client->_bind( val = <valuecolor> ) ).

    ENDIF.

    result = i_xml.

  ENDMETHOD.

  METHOD xml_build_progress_indicator.

    IF i_data IS NOT SUPPLIED. " Table case

      i_xml->tag( `ProgressIndicator`
          )->a( n = `class`        v = `sapUiSmallMarginBottom`
          )->a( n = `percentValue` v = |\{{ i_layout->fname }/PERCENTVALUE\}|
          )->a( n = `displayValue` v = |\{{ i_layout->fname }/DISPLAYVALUE\}|
          )->a( n = `showValue`    v = |\{{ i_layout->fname }/SHOWVALUE\}|
          )->a( n = `state`        v = |\{{ i_layout->fname }/STATE\}| ).

    ELSE.

      ASSIGN COMPONENT |{ i_layout->fname }-PERCENTVALUE| OF STRUCTURE i_data->* TO FIELD-SYMBOL(<percentvalue>).
      IF <percentvalue> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      ASSIGN COMPONENT |{ i_layout->fname }-DISPLAYVALUE| OF STRUCTURE i_data->* TO FIELD-SYMBOL(<displayvalue>).
      IF <displayvalue> IS NOT ASSIGNED.
        RETURN.
      ENDIF.
      ASSIGN COMPONENT |{ i_layout->fname }-SHOWVALUE| OF STRUCTURE i_data->* TO FIELD-SYMBOL(<showvalue>).
      IF <showvalue> IS NOT ASSIGNED.
        RETURN.
      ENDIF.
      ASSIGN COMPONENT |{ i_layout->fname }-STATE| OF STRUCTURE i_data->* TO FIELD-SYMBOL(<state>).
      IF <state> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      i_xml->tag( `ProgressIndicator`
          )->a( n = `class`        v = `sapUiSmallMarginBottom`
          )->a( n = `percentValue` v = i_client->_bind( val = <percentvalue> )
          )->a( n = `displayValue` v = i_client->_bind( val = <displayvalue> )
          )->a( n = `showValue`    v = i_client->_bind( val = <showvalue> )
          )->a( n = `visible`      b = i_layout->visible
          )->a( n = `state`        v = i_client->_bind( val = <state> ) ).

    ENDIF.

    result = i_xml.

  ENDMETHOD.

  METHOD xml_build_status_indicator.

    IF i_data IS NOT SUPPLIED. " We want to build a Table!

      DATA(status_indicator) = i_xml->ele( n = `StatusIndicator` ns = `si`
          )->a( n = `class` v = |\{{ i_layout->fname }/CLASS\}|
          )->a( n = `size`  v = |\{{ i_layout->fname }/STATUSINDICATOR_SIZE\}|
          )->a( n = `value` v = |\{{ i_layout->fname }/VALUE\}| ).

      status_indicator->ele( n = `propertyThresholds` ns = `si`
          )->tag( n = `PropertyThreshold` ns = `si`
              )->a( n = `fillColor` v = `Good`
              )->a( n = `toValue`   v = |\{{ i_layout->fname }/FILLCOLOR_GOOD\}|
          )->tag( n = `PropertyThreshold` ns = `si`
              )->a( n = `fillColor` v = `Critical`
              )->a( n = `toValue`   v = |\{{ i_layout->fname }/FILLCOLOR_CRITICAL\}|
          )->tag( n = `PropertyThreshold` ns = `si`
              )->a( n = `fillColor` v = `Error`
              )->a( n = `toValue`   v = |\{{ i_layout->fname }/FILLCOLOR_ERROR\}| ).

      status_indicator->ele( n = `ShapeGroup` ns = `si`
          )->tag( n = `LibraryShape` ns = `si`
              )->a( n = `shapeId` v = |\{{ i_layout->fname }/SHAPEID\}| ).

    ELSE.

      ASSIGN COMPONENT |{ i_layout->fname }-VALUE| OF STRUCTURE i_data->* TO FIELD-SYMBOL(<value>).
      IF <value> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      ASSIGN COMPONENT |{ i_layout->fname }-CLASS| OF STRUCTURE i_data->* TO FIELD-SYMBOL(<class>).
      IF <class> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      ASSIGN COMPONENT |{ i_layout->fname }-STATUSINDICATOR_SIZE| OF STRUCTURE i_data->* TO FIELD-SYMBOL(<size>).
      IF <size> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      status_indicator = i_xml->ele( n = `StatusIndicator` ns = `si`
          )->a( n = `class`   v = i_client->_bind( val = <class> )
          )->a( n = `size`    v = i_client->_bind( val = <size> )
          )->a( n = `value`   v = i_client->_bind( val = <value> )
          )->a( n = `visible` b = i_layout->visible ).

      DATA(thresholds) = status_indicator->ele( n = `propertyThresholds` ns = `si` ).

      ASSIGN COMPONENT |{ i_layout->fname }-FILLCOLOR_GOOD| OF STRUCTURE i_data->* TO FIELD-SYMBOL(<fillcolor_good>).
      IF <fillcolor_good> IS NOT ASSIGNED.
        RETURN.
      ENDIF.
      ASSIGN COMPONENT |{ i_layout->fname }-FILLCOLOR_CRITICAL| OF STRUCTURE i_data->* TO FIELD-SYMBOL(<fillcolor_critical>).
      IF <fillcolor_critical> IS NOT ASSIGNED.
        RETURN.
      ENDIF.
      ASSIGN COMPONENT |{ i_layout->fname }-FILLCOLOR_ERROR| OF STRUCTURE i_data->* TO FIELD-SYMBOL(<fillcolor_error>).
      IF <fillcolor_error> IS NOT ASSIGNED.
        RETURN.
      ENDIF.
      ASSIGN COMPONENT |{ i_layout->fname }-SHAPEID| OF STRUCTURE i_data->* TO FIELD-SYMBOL(<shapeid>).
      IF <shapeid> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      thresholds->tag( n = `PropertyThreshold` ns = `si`
          )->a( n = `fillColor` v = `Good`
          )->a( n = `toValue`   v = i_client->_bind( val = <fillcolor_good> )
      )->tag( n = `PropertyThreshold` ns = `si`
          )->a( n = `fillColor` v = `Critical`
          )->a( n = `toValue`   v = i_client->_bind( val = <fillcolor_critical> )
      )->tag( n = `PropertyThreshold` ns = `si`
          )->a( n = `fillColor` v = `Error`
          )->a( n = `toValue`   v = i_client->_bind( val = <fillcolor_error> ) ).

      status_indicator->ele( n = `ShapeGroup` ns = `si`
          )->tag( n = `LibraryShape` ns = `si`
              )->a( n = `shapeId` v = i_client->_bind( val = <shapeid> ) ).

    ENDIF.

    result = i_xml.

  ENDMETHOD.

  METHOD xml_build_generic_tag.

    IF i_data IS NOT SUPPLIED. " Table case

      i_xml->tag( `GenericTag`
          )->a( n = `design` v = |\{{ i_layout->fname }/DESIGN\}|
          )->a( n = `status` v = |\{{ i_layout->fname }/STATUS\}|
          )->a( n = `text`   v = |\{{ i_layout->fname }/TEXT\}| ).

    ELSE.

      ASSIGN COMPONENT |{ i_layout->fname }-TEXT| OF STRUCTURE i_data->* TO FIELD-SYMBOL(<text>).
      IF <text> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      ASSIGN COMPONENT |{ i_layout->fname }-DESIGN| OF STRUCTURE i_data->* TO FIELD-SYMBOL(<design>).
      IF <design> IS NOT ASSIGNED.
        RETURN.
      ENDIF.
      ASSIGN COMPONENT |{ i_layout->fname }-STATUS| OF STRUCTURE i_data->* TO FIELD-SYMBOL(<status>).
      IF <status> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      i_xml->tag( `GenericTag`
          )->a( n = `design` v = i_client->_bind( <design> )
          )->a( n = `status` v = i_client->_bind( <status> )
          )->a( n = `text`   v = i_client->_bind( <text> ) ).

    ENDIF.

    result = i_xml.

  ENDMETHOD.

  METHOD value_formatter.

*    result = COND #( WHEN no_zero = abap_true
*                     THEN |\{path : '{ I_client->_bind(
*                                           val  = value
*                                           path = abap_true ) }', type : 'sap.ui.model.odata.type.String', constraints : \{  isDigitSequence : true \} \}|
*                     ELSE I_client->_bind( value ) ).

result = I_client->_bind( value ).

  ENDMETHOD.

ENDCLASS.
