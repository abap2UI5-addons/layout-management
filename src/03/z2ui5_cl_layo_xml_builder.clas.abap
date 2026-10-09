CLASS z2ui5_cl_layo_xml_builder DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS xml_build_table
      IMPORTING
        i_data             TYPE REF TO data
        i_xml              TYPE REF TO z2ui5_cl_ui5_view_builder
        i_client           TYPE REF TO z2ui5_if_client
        i_layout           TYPE REF TO z2ui5_cl_layo_manager
        i_search_value     TYPE REF TO data OPTIONAL
        i_growingthreshold TYPE string      OPTIONAL
        i_headertext       TYPE string      OPTIONAL
        i_sel_mode         TYPE string      OPTIONAL
        i_sel_bind_to      TYPE string      OPTIONAL
        i_col_type         TYPE string      OPTIONAL
        i_col_bind_to      TYPE string      OPTIONAL.

    CLASS-METHODS xml_build_simple_form
      IMPORTING
        i_data   TYPE REF TO data
        i_xml    TYPE REF TO z2ui5_cl_ui5_view_builder
        i_client TYPE REF TO z2ui5_if_client
        i_layout TYPE REF TO z2ui5_cl_layo_manager
        i_title  TYPE string OPTIONAL.

  PROTECTED SECTION.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_s_grid_layout,
             label     TYPE string,
             value     TYPE string,
             ref_field TYPE string,
           END OF ty_s_grid_layout.


    CLASS-METHODS xml_build_status_indicator
      IMPORTING
        i_data        TYPE REF TO data OPTIONAL
        i_client      TYPE REF TO z2ui5_if_client
        i_layout      TYPE REF TO z2ui5_cl_layo_manager=>ty_s_positions
        i_xml         TYPE REF TO z2ui5_cl_ui5_view_builder
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_view_builder.

    CLASS-METHODS xml_build_progress_indicator
      IMPORTING
        i_data        TYPE REF TO data OPTIONAL
        i_client      TYPE REF TO z2ui5_if_client
        i_layout      TYPE REF TO z2ui5_cl_layo_manager=>ty_s_positions
        i_xml         TYPE REF TO z2ui5_cl_ui5_view_builder
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_view_builder.

    CLASS-METHODS xml_build_radial_microchart
      IMPORTING
        i_data        TYPE REF TO data OPTIONAL
        i_client      TYPE REF TO z2ui5_if_client
        i_layout      TYPE REF TO z2ui5_cl_layo_manager=>ty_s_positions
        i_xml         TYPE REF TO z2ui5_cl_ui5_view_builder
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_view_builder.

    CLASS-METHODS xml_build_icon
      IMPORTING
        i_data        TYPE REF TO data OPTIONAL
        i_client      TYPE REF TO z2ui5_if_client
        i_layout      TYPE REF TO z2ui5_cl_layo_manager=>ty_s_positions
        i_xml         TYPE REF TO z2ui5_cl_ui5_view_builder
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_view_builder.

    CLASS-METHODS xml_build_generic_tag
      IMPORTING
        i_data        TYPE REF TO data OPTIONAL
        i_client      TYPE REF TO z2ui5_if_client
        i_layout      TYPE REF TO z2ui5_cl_layo_manager=>ty_s_positions
        i_xml         TYPE REF TO z2ui5_cl_ui5_view_builder
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_view_builder.

    CLASS-METHODS get_grid_layout
      IMPORTING
        !layout       TYPE REF TO z2ui5_cl_layo_manager=>ty_s_positions
      RETURNING
        VALUE(result) TYPE ty_s_grid_layout.

    "! Attach the grid layout to one form element.
    "!
    "! @parameter i_xml | the ELEMENT to decorate, not its container. It used to
    "!                    take the container and reach the element by counting
    "!                    children, which the generic view builder cannot do -
    "!                    and a class-wide counter was the wrong place to keep
    "!                    that state anyway.
    "! @parameter span  | grid span, e.g. `XL2 L3 M4 S12`; nothing is written
    "!                    when it is empty
    CLASS-METHODS set_layout_for_element
      IMPORTING
        span  TYPE string
        i_xml TYPE REF TO z2ui5_cl_ui5_view_builder.

    CLASS-METHODS value_formatter
      IMPORTING
        i_client      TYPE REF TO z2ui5_if_client
        !value        TYPE any
        !layout       TYPE REF TO z2ui5_cl_layo_manager=>ty_s_positions
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
    DATA form TYPE REF TO z2ui5_cl_ui5_view_builder.
    FIELD-SYMBOLS <data> TYPE data.
    DATA temp1 LIKE LINE OF i_layout->ms_layout-t_layout.
    DATA layout LIKE REF TO temp1.
      DATA lv_index LIKE sy-tabix.
      FIELD-SYMBOLS <value> TYPE any.
      DATA grid_layout TYPE z2ui5_cl_layo_xml_builder=>ty_s_grid_layout.
      DATA line LIKE form.
      DATA label TYPE REF TO z2ui5_cl_ui5_view_builder.
        DATA hbox TYPE REF TO z2ui5_cl_ui5_view_builder.
        DATA input TYPE REF TO z2ui5_cl_ui5_view_builder.
        FIELD-SYMBOLS <ref_value> TYPE any.
        FIELD-SYMBOLS <temp2> TYPE z2ui5_cl_layo_manager=>ty_s_positions.
DATA ref_field LIKE REF TO <temp2>.
        DATA ref_input TYPE REF TO z2ui5_cl_ui5_view_builder.

    z2ui5_cl_layo_pop=>render_layout_function( client = i_client
                                               xml    = i_xml
                                               layout = i_layout ).


    form = i_xml->ele( n = `SimpleForm` ns = `form`
                     )->a( n = `title` v = i_title
                     )->a( n = `editable` b = abap_true
                     )->a( n = `layout` v = `ResponsiveGridLayout`
                     )->a( n = `labelSpanS` v = '3'
                     )->a( n = `labelSpanM` v = '3'
                     )->a( n = `labelSpanL` v = '3'
                     )->a( n = `labelSpanXL` v = '3'
                     )->a( n = `adjustLabelSpan` b = abap_false
                     )->a( n = `emptySpanXL` v = '4'
                     )->a( n = `emptySpanL` v = '4'
                     )->a( n = `emptySpanM` v = '2'
                     )->a( n = `emptySpanS` v = '0'
                     )->a( n = `columnsXL` v = '1'
                     )->a( n = `columnsL` v = '1'
                     )->a( n = `columnsM` v = '1'
                     )->a( n = `singleContainerFullSize` b = abap_false
                     )->ele( n = `content` ns = `form` ).


    ASSIGN i_data->* TO <data>.



    LOOP AT i_layout->ms_layout-t_layout REFERENCE INTO layout.


      lv_index = sy-tabix.


      ASSIGN COMPONENT layout->fname OF STRUCTURE <data> TO <value>.
      IF <value> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.


      grid_layout = get_grid_layout( layout ).


      line = form.


      label = line->ele( `Label`
                        )->a( n = `wrapping` b = abap_false
                        )->a( n = `text` v = i_client->_bind( val       = layout->tlabel
                                                             tab       = i_layout->ms_layout-t_layout
                                                             tab_index = lv_index )
                        )->a( n = `labelFor` v = ` ` ).

      set_layout_for_element( i_xml = label
                              span  = grid_layout-label ).

      IF layout->rollname CP `*_XML_S_ICON`.


        hbox = line->ele( `HBox`
                         )->a( n = `renderType` v = `Bare`
                         )->a( n = `visible` v = i_client->_bind( val       = layout->visible
                                                               tab       = i_layout->ms_layout-t_layout
                                                               tab_index = lv_index ) ).

        set_layout_for_element( i_xml = hbox
                                span  = grid_layout-value ).

        xml_build_icon( i_layout = layout
                        i_data   = i_data
                        i_client = i_client
                        i_xml    = hbox ).

      ELSEIF layout->rollname CP `*_XML_S_PROGRESSIND`.

        hbox = line->ele( `HBox`
                   )->a( n = `renderType` v = `Bare`
                   )->a( n = `visible` v = i_client->_bind( val       = layout->visible
                                                         tab       = i_layout->ms_layout-t_layout
                                                         tab_index = lv_index ) ).

        set_layout_for_element( i_xml = hbox
                                span  = grid_layout-value ).

        xml_build_progress_indicator( i_layout = layout
                                      i_data   = i_data
                                      i_client = i_client
                                      i_xml    = hbox ).

      ELSEIF layout->rollname CP `*_XML_S_GENERICTAG`.

        hbox = line->ele( `HBox`
                   )->a( n = `renderType` v = `Bare`
                   )->a( n = `visible` v = i_client->_bind( val       = layout->visible
                                                         tab       = i_layout->ms_layout-t_layout
                                                         tab_index = lv_index ) ).

        set_layout_for_element( i_xml = hbox
                                span  = grid_layout-value ).

        xml_build_generic_tag( i_layout = layout
                               i_data   = i_data
                               i_client = i_client
                               i_xml    = hbox ).

      ELSEIF layout->rollname CP `*_XML_S_STATUSIND`.

        hbox = line->ele( `HBox`
                   )->a( n = `renderType` v = `Bare`
                   )->a( n = `visible` v = i_client->_bind( val       = layout->visible
                                                         tab       = i_layout->ms_layout-t_layout
                                                         tab_index = lv_index ) ).

        set_layout_for_element( i_xml = hbox
                                span  = grid_layout-value ).

        xml_build_status_indicator( i_data   = i_data
                                    i_client = i_client
                                    i_layout = layout
                                    i_xml    = hbox ).

      ELSEIF layout->rollname CP `*_XML_S_RADIALCHART`.

        hbox = line->ele( `HBox`
                   )->a( n = `renderType` v = `Bare`
                   )->a( n = `visible` v = i_client->_bind( val       = layout->visible
                                                         tab       = i_layout->ms_layout-t_layout
                                                         tab_index = lv_index ) ).

        set_layout_for_element( i_xml = hbox
                                span  = grid_layout-value ).

        xml_build_radial_microchart( i_data   = i_data
                                     i_client = i_client
                                     i_layout = layout
                                     i_xml    = hbox ).

      ELSE.


        input = line->ele( `Input`
                          )->a( n = `visible` v = i_client->_bind( val       = layout->visible
                                                                   tab       = i_layout->ms_layout-t_layout
                                                                   tab_index = lv_index )
                          )->a( n = `value` v = value_formatter( layout   = layout
                                                                 i_client = i_client
                                                                 value    = <value> )
                          )->a( n = `enabled` b = abap_false
                          )->a( n = `width` v = i_client->_bind( val       = layout->width
                                                                 tab       = i_layout->ms_layout-t_layout
                                                                 tab_index = lv_index ) ).

        set_layout_for_element( i_xml = input
                                span  = grid_layout-value ).

      ENDIF.

      IF layout->reference_field IS NOT INITIAL.


        ASSIGN COMPONENT layout->reference_field OF STRUCTURE <data> TO <ref_value>.
        IF <ref_value> IS NOT ASSIGNED.
          CONTINUE.
        ENDIF.


        READ TABLE i_layout->ms_layout-t_layout WITH KEY fname = layout->reference_field ASSIGNING <temp2>.
IF sy-subrc <> 0.
  ASSERT 1 = 0.
ENDIF.

GET REFERENCE OF <temp2> INTO ref_field.
        IF ref_field IS INITIAL.
          CONTINUE.
        ENDIF.


        ref_input = line->ele( `Input`
                              )->a( n = `visible` v = i_client->_bind( val       = layout->visible
                                                                       tab       = i_layout->ms_layout-t_layout
                                                                       tab_index = lv_index )
                              )->a( n = `value` v = value_formatter( layout   = ref_field
                                                                     i_client = i_client
                                                                     value    = <ref_value> )
                              )->a( n = `enabled` b = abap_false ).

        set_layout_for_element( i_xml = ref_input
                                span  = grid_layout-ref_field ).

      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD get_grid_layout.
      DATA label_xl TYPE string.
      DATA label_l TYPE string.
      DATA label_m TYPE string.
      DATA label_s TYPE string.
      DATA ref_size TYPE i.
      DATA ref_size_s TYPE i.
      DATA value_xl TYPE string.
      DATA value_l TYPE string.
      DATA value_m TYPE string.
      DATA value_s TYPE string.

    IF layout->grid_label_xl > 0.

      label_xl = |XL{ layout->grid_label_xl }|.
    ENDIF.
    IF layout->grid_label_l > 0.

      label_l = |L{ layout->grid_label_l }|.
    ENDIF.
    IF layout->grid_label_m > 0.

      label_m = |M{ layout->grid_label_m }|.
    ENDIF.
    IF layout->grid_label_s > 0.

      label_s = |S{ layout->grid_label_s }|.
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


      ref_size = 1.
      " the reference field occupies two columns on the S breakpoint (S2)

      ref_size_s = 2.
      result-ref_field = |XL1 L1 M1 S2|.

    ENDIF.

    IF layout->grid_value_xl > 0.

      value_xl = |XL{ layout->grid_value_xl - ref_size }|.
    ENDIF.
    IF layout->grid_value_l > 0.

      value_l = |L{ layout->grid_value_l - ref_size }|.
    ENDIF.
    IF layout->grid_value_m > 0.

      value_m = |M{ layout->grid_value_m - ref_size }|.
    ENDIF.
    IF layout->grid_value_s > 0.

      value_s = |S{ layout->grid_value_s - ref_size_s }|.
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

    IF span IS INITIAL.
      RETURN.
    ENDIF.

    i_xml->ele( `layoutData`
        )->tag( n = `GridData` ns = `layout`
        )->a( n = `span` v = span ).

  ENDMETHOD.

  METHOD xml_build_table.

    FIELD-SYMBOLS <tab> TYPE data.
    DATA temp3 TYPE string.
    DATA temp1 TYPE string.
    DATA table TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA toolbar TYPE REF TO z2ui5_cl_ui5_view_builder.
      FIELD-SYMBOLS <search> TYPE data.
    DATA columns TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA temp4 LIKE LINE OF i_layout->ms_layout-t_layout.
    DATA layout LIKE REF TO temp4.
      DATA lv_index LIKE sy-tabix.
    DATA temp5 TYPE string_table.
    DATA temp2 TYPE string.
    DATA temp6 TYPE string.
    DATA temp7 TYPE string.
    DATA column_list_item TYPE REF TO z2ui5_cl_ui5_view_builder.
    DATA cells TYPE REF TO z2ui5_cl_ui5_view_builder.
          DATA sub_col TYPE string.
          DATA index TYPE i.
          DATA subcol LIKE LINE OF layout->t_sub_col.
            DATA line TYPE z2ui5_cl_layo_manager=>ty_s_positions.
              DATA column TYPE string.
              DATA ref TYPE z2ui5_cl_layo_manager=>ty_s_positions.
    ASSIGN i_data->* TO <tab>.


    IF i_growingthreshold = space.
      temp3 = abap_false.
    ELSE.
      temp3 = abap_true.
    ENDIF.

    IF i_sel_mode = space.
      temp1 = `None`.
    ELSE.
      temp1 = i_sel_mode.
    ENDIF.

    table = i_xml->ele( `Table`
                      )->a( n = `growing` v = temp3
                      )->a( n = `growingThreshold` v = i_growingthreshold
                      )->a( n = `width` v = 'auto'
                      )->a( n = `mode` v = temp1
                      )->a( n = `items` v = i_client->_bind_edit( <tab> )
                      )->a( n = `selectionChange` v = i_client->_event( 'SELECTION_CHANGE' ) ).


    toolbar = table->ele( `headerToolbar`
                        )->ele( `OverflowToolbar` ).

    IF i_headertext IS NOT INITIAL.
      toolbar->tag( `Title`
          )->a( n = `text` v = i_headertext
          )->a( n = `level` v = `H2` ).
    ENDIF.

    toolbar->tag( `ToolbarSpacer` ).

    IF i_search_value IS SUPPLIED.


      ASSIGN i_search_value->* TO <search>.

      toolbar->tag( `SearchField`
          )->a( n = `value` v = i_client->_bind_edit( <search> )
          )->a( n = `search` v = i_client->_event( 'SEARCH' )
          )->a( n = `change` v = i_client->_event( 'SEARCH' )
          )->a( n = `id` v = `SEARCH`
          )->a( n = `width` v = '17.5rem' ).
    ENDIF.

    z2ui5_cl_layo_pop=>render_layout_function( client = i_client
                                               xml    = toolbar
                                               layout = i_layout ).


    columns = table->ele( `columns` ).



    LOOP AT i_layout->ms_layout-t_layout REFERENCE INTO layout.

      lv_index = sy-tabix.

      columns->ele( `Column`
          )->a( n = `visible` v = i_client->_bind( val       = layout->visible
                                                          tab       = i_layout->ms_layout-t_layout
                                                          tab_index = lv_index )
          )->a( n = `mergeDuplicates` v = i_client->_bind( val       = layout->merge
                                                          tab       = i_layout->ms_layout-t_layout
                                                          tab_index = lv_index )
          )->a( n = `width` v = i_client->_bind( val       = layout->width
                                                          tab       = i_layout->ms_layout-t_layout
                                                          tab_index = lv_index )
          )->tag( `Text`
          )->a( n = `text` v = layout->tlabel ).

    ENDLOOP.


    CLEAR temp5.

    IF i_col_bind_to = space.
      temp2 = ``.
    ELSE.
      temp2 = |$\{{ i_col_bind_to }\}|.
    ENDIF.
    INSERT temp2 INTO TABLE temp5.

    IF i_sel_bind_to = space.
      temp6 = ``.
    ELSE.
      temp6 = |\{{ i_sel_bind_to }\}|.
    ENDIF.

    IF i_col_type = space.
      temp7 = `Inactive`.
    ELSE.
      temp7 = i_col_type.
    ENDIF.

    column_list_item = columns->end(
                                 )->ele( `items`
                                 )->ele( `ColumnListItem`
                                 )->a( n = `vAlign` v = 'Middle'
                                 )->a( n = `selected` v = temp6
                                 )->a( n = `type` v = temp7
                                 )->a( n = `press` v = i_client->_event(
                                               val   = 'ROW_SELECT'
                                               t_arg = temp5 ) ).


    cells = column_list_item->ele( `cells` ).

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

        IF layout->t_sub_col IS NOT INITIAL.


          sub_col = ``.

          index = 0.


          LOOP AT layout->t_sub_col INTO subcol.

            index = index + 1.


            READ TABLE i_layout->ms_layout-t_layout INTO line WITH KEY fname = subcol-fname.

            IF line-reference_field IS INITIAL.

              column = |{ line-tlabel }: { table_value_formatter( line ) }|.
            ELSE.


              READ TABLE i_layout->ms_layout-t_layout INTO ref WITH KEY fname = line-reference_field.

              column = |{ line-tlabel }: { table_value_formatter( line ) } { table_value_formatter( ref ) }|.
            ENDIF.

            IF index = 1.
              sub_col = column.
            ELSE.
              sub_col = |{ sub_col }{ cl_abap_char_utilities=>cr_lf }{ column }|.
            ENDIF.
          ENDLOOP.

          IF layout->reference_field IS NOT INITIAL.

            READ TABLE i_layout->ms_layout-t_layout INTO ref WITH KEY fname = layout->reference_field.

            cells->ele( `ObjectIdentifier`
                )->a( n = `title` v = |{ table_value_formatter( layout->* ) } {
                                                 table_value_formatter( ref ) }|
                )->a( n = `text` v = sub_col ).
          ELSE.
            cells->ele( `ObjectIdentifier`
                )->a( n = `title` v = table_value_formatter( layout->* )
                )->a( n = `text` v = sub_col ).
          ENDIF.

        ELSE.

          IF layout->reference_field IS NOT INITIAL.

            READ TABLE i_layout->ms_layout-t_layout INTO ref WITH KEY fname = layout->reference_field.

            cells->ele( `ObjectIdentifier`
                )->a( n = `text` v = |{ table_value_formatter( layout->* ) } {
                                                table_value_formatter( ref ) }| ).
          ELSE.
            cells->ele( `ObjectIdentifier`
                )->a( n = `text` v = |{ table_value_formatter( layout->* ) }| ).
          ENDIF.
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
      FIELD-SYMBOLS <data> TYPE data.
      DATA temp7 TYPE string.
FIELD-SYMBOLS <src> TYPE any.
      DATA temp8 TYPE string.
FIELD-SYMBOLS <size> TYPE any.

    IF i_data IS NOT SUPPLIED. " Table case

      i_xml->tag( n = `Icon` ns = `core`
          )->a( n = `src` v = |\{{ i_layout->fname }/SRC\}|
          )->a( n = `size` v = |\{{ i_layout->fname }/ICON_SIZE\}| ).

    ELSE.


      ASSIGN i_data->* TO <data>.


      temp7 = |{ i_layout->fname }-SRC|.

ASSIGN COMPONENT temp7 OF STRUCTURE <data> TO <src>.
      IF <src> IS NOT ASSIGNED.
        RETURN.
      ENDIF.


      temp8 = |{ i_layout->fname }-ICON_SIZE|.

ASSIGN COMPONENT temp8 OF STRUCTURE <data> TO <size>.
      IF <size> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      i_xml->tag( n = `Icon` ns = `core`
          )->a( n = `src` v = i_client->_bind( val = <src> )
          )->a( n = `size` v = i_client->_bind( val = <size> ) ).

    ENDIF.

    result = i_xml.

  ENDMETHOD.

  METHOD xml_build_radial_microchart.
      FIELD-SYMBOLS <data> TYPE data.
      DATA temp9 TYPE string.
FIELD-SYMBOLS <size> TYPE any.
      DATA temp10 TYPE string.
FIELD-SYMBOLS <percentage> TYPE any.
      DATA temp11 TYPE string.
FIELD-SYMBOLS <valuecolor> TYPE any.
      DATA temp12 TYPE string.
FIELD-SYMBOLS <hideonnodata> TYPE any.

    IF i_data IS NOT SUPPLIED. " Table case

      i_xml->tag( n = `RadialMicroChart` ns = `mchart`
          )->a( n = `size` v = |\{{ i_layout->fname }/RADIALMICROCHART_SIZE\}|
          )->a( n = `percentage` v = |\{{ i_layout->fname }/PERCENTAGE\}|
          )->a( n = `valueColor` v = |\{{ i_layout->fname }/VALUECOLOR\}|
          )->a( n = `hideOnNoData` v = |\{{ i_layout->fname }/HIDEONNODATA\}| ).

    ELSE.


      ASSIGN i_data->* TO <data>.


      temp9 = |{ i_layout->fname }-RADIALMICROCHART_SIZE|.

ASSIGN COMPONENT temp9 OF STRUCTURE <data> TO <size>.
      IF <size> IS NOT ASSIGNED.
        RETURN.
      ENDIF.


      temp10 = |{ i_layout->fname }-PERCENTAGE|.

ASSIGN COMPONENT temp10 OF STRUCTURE <data> TO <percentage>.
      IF <percentage> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      temp11 = |{ i_layout->fname }-VALUECOLOR|.

ASSIGN COMPONENT temp11 OF STRUCTURE <data> TO <valuecolor>.
      IF <valuecolor> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      temp12 = |{ i_layout->fname }-HIDEONNODATA|.

ASSIGN COMPONENT temp12 OF STRUCTURE <data> TO <hideonnodata>.
      IF <hideonnodata> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      i_xml->tag( n = `RadialMicroChart` ns = `mchart`
          )->a( n = `size` v = i_client->_bind( val = <size> )
          )->a( n = `percentage` v = i_client->_bind( val = <percentage> )
*                                 press        = press
          )->a( n = `valueColor` v = i_client->_bind( val = <valuecolor> )
*                                 height       = height
*                                 aligncontent = aligncontent
          )->a( n = `hideOnNoData` v = i_client->_bind( val = <hideonnodata> ) ).

    ENDIF.

    result = i_xml.

  ENDMETHOD.

  METHOD xml_build_progress_indicator.
      FIELD-SYMBOLS <data> TYPE data.
      DATA temp13 TYPE string.
FIELD-SYMBOLS <percentvalue> TYPE any.
      DATA temp14 TYPE string.
FIELD-SYMBOLS <displayvalue> TYPE any.
      DATA temp15 TYPE string.
FIELD-SYMBOLS <showvalue> TYPE any.
      DATA temp16 TYPE string.
FIELD-SYMBOLS <state> TYPE any.

    IF i_data IS NOT SUPPLIED. " Table case

      i_xml->tag( `ProgressIndicator`
          )->a( n = `class` v = `sapUiSmallMarginBottom`
          )->a( n = `percentValue` v = |\{{ i_layout->fname }/PERCENTVALUE\}|
          )->a( n = `displayValue` v = |\{{ i_layout->fname }/DISPLAYVALUE\}|
          )->a( n = `showValue` v = |\{{ i_layout->fname }/SHOWVALUE\}|
          )->a( n = `state` v = |\{{ i_layout->fname }/STATE\}| ).

    ELSE.


      ASSIGN i_data->* TO <data>.


      temp13 = |{ i_layout->fname }-PERCENTVALUE|.

ASSIGN COMPONENT temp13 OF STRUCTURE <data> TO <percentvalue>.
      IF <percentvalue> IS NOT ASSIGNED.
        RETURN.
      ENDIF.


      temp14 = |{ i_layout->fname }-DISPLAYVALUE|.

ASSIGN COMPONENT temp14 OF STRUCTURE <data> TO <displayvalue>.
      IF <displayvalue> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      temp15 = |{ i_layout->fname }-SHOWVALUE|.

ASSIGN COMPONENT temp15 OF STRUCTURE <data> TO <showvalue>.
      IF <showvalue> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      temp16 = |{ i_layout->fname }-STATE|.

ASSIGN COMPONENT temp16 OF STRUCTURE <data> TO <state>.
      IF <state> IS NOT ASSIGNED.
        RETURN.
      ENDIF.
*      ASSIGN COMPONENT |{ i_layout->visible }| OF STRUCTURE i_data->* TO FIELD-SYMBOL(<visible>).
*      IF <visible> IS NOT ASSIGNED.
*        RETURN.
*      ENDIF.

      i_xml->tag( `ProgressIndicator`
          )->a( n = `class` v = `sapUiSmallMarginBottom`
          )->a( n = `percentValue` v = i_client->_bind( val = <percentvalue> )
          )->a( n = `displayValue` v = i_client->_bind( val = <displayvalue> )
          )->a( n = `showValue` v = i_client->_bind( val = <showvalue> )
          )->a( n = `state` v = i_client->_bind( val = <state> )
          )->a( n = `visible` b = i_layout->visible ).

    ENDIF.

    result = i_xml.

  ENDMETHOD.

  METHOD xml_build_status_indicator.
      DATA status_indicator TYPE REF TO z2ui5_cl_ui5_view_builder.
      DATA thresholds TYPE REF TO z2ui5_cl_ui5_view_builder.
      FIELD-SYMBOLS <data> TYPE data.
      DATA temp17 TYPE string.
FIELD-SYMBOLS <value> TYPE any.
      DATA temp18 TYPE string.
FIELD-SYMBOLS <class> TYPE any.
      DATA temp19 TYPE string.
FIELD-SYMBOLS <size> TYPE any.
      DATA temp20 TYPE string.
FIELD-SYMBOLS <fillcolor_good> TYPE any.
      DATA temp21 TYPE string.
FIELD-SYMBOLS <fillcolor_critical> TYPE any.
      DATA temp22 TYPE string.
FIELD-SYMBOLS <fillcolor_error> TYPE any.
      DATA temp23 TYPE string.
FIELD-SYMBOLS <shapeid> TYPE any.

    IF i_data IS NOT SUPPLIED. " We want to build a Table!


      status_indicator = i_xml->ele( n = `StatusIndicator` ns = `si`
                                   )->a( n = `class` v = |\{{ i_layout->fname }/CLASS\}|
                                   )->a( n = `size` v = |\{{ i_layout->fname }/STATUSINDICATOR_SIZE\}|
                                   )->a( n = `value` v = |\{{ i_layout->fname }/VALUE\}| ).


      thresholds = status_indicator->ele( n = `propertyThresholds` ns = `si` ).

      thresholds->ele( n = `PropertyThreshold` ns = `si`
          )->a( n = `fillColor` v = 'Good'
          )->a( n = `toValue` v = |\{{ i_layout->fname }/FILLCOLOR_GOOD\}| ).

      thresholds->ele( n = `PropertyThreshold` ns = `si`
          )->a( n = `fillColor` v = 'Critical'
          )->a( n = `toValue` v = |\{{ i_layout->fname }/FILLCOLOR_CRITICAL\}| ).

      thresholds->ele( n = `PropertyThreshold` ns = `si`
          )->a( n = `fillColor` v = 'Error'
          )->a( n = `toValue` v = |\{{ i_layout->fname }/FILLCOLOR_ERROR\}| ).

      status_indicator->ele( n = `ShapeGroup` ns = `si`
          )->ele( n = `LibraryShape` ns = `si`
          )->a( n = `shapeId` v = |\{{ i_layout->fname }/SHAPEID\}| ).

    ELSE.


      ASSIGN i_data->* TO <data>.


      temp17 = |{ i_layout->fname }-VALUE|.

ASSIGN COMPONENT temp17 OF STRUCTURE <data> TO <value>.
      IF <value> IS NOT ASSIGNED.
        RETURN.
      ENDIF.


      temp18 = |{ i_layout->fname }-CLASS|.

ASSIGN COMPONENT temp18 OF STRUCTURE <data> TO <class>.
      IF <class> IS NOT ASSIGNED.
        RETURN.
      ENDIF.


      temp19 = |{ i_layout->fname }-STATUSINDICATOR_SIZE|.

ASSIGN COMPONENT temp19 OF STRUCTURE <data> TO <size>.
      IF <size> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      status_indicator = i_xml->ele( n = `StatusIndicator` ns = `si`
                             )->a( n = `class` v = i_client->_bind( val = <class> )
                             )->a( n = `size` v = i_client->_bind( val = <size> )
                             )->a( n = `value` v = i_client->_bind( val = <value> )
                             )->a( n = `visible` b = i_layout->visible ).

      thresholds = status_indicator->ele( n = `propertyThresholds` ns = `si` ).


      temp20 = |{ i_layout->fname }-FILLCOLOR_GOOD|.

ASSIGN COMPONENT temp20 OF STRUCTURE <data> TO <fillcolor_good>.
      IF <fillcolor_good> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      temp21 = |{ i_layout->fname }-FILLCOLOR_CRITICAL|.

ASSIGN COMPONENT temp21 OF STRUCTURE <data> TO <fillcolor_critical>.
      IF <fillcolor_critical> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      temp22 = |{ i_layout->fname }-FILLCOLOR_ERROR|.

ASSIGN COMPONENT temp22 OF STRUCTURE <data> TO <fillcolor_error>.
      IF <fillcolor_error> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      temp23 = |{ i_layout->fname }-SHAPEID|.

ASSIGN COMPONENT temp23 OF STRUCTURE <data> TO <shapeid>.
      IF <shapeid> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      thresholds->ele( n = `PropertyThreshold` ns = `si`
          )->a( n = `fillColor` v = 'Good'
          )->a( n = `toValue` v = i_client->_bind( val = <fillcolor_good> ) ).

      thresholds->ele( n = `PropertyThreshold` ns = `si`
          )->a( n = `fillColor` v = 'Critical'
          )->a( n = `toValue` v = i_client->_bind( val = <fillcolor_critical> ) ).

      thresholds->ele( n = `PropertyThreshold` ns = `si`
          )->a( n = `fillColor` v = 'Error'
          )->a( n = `toValue` v = i_client->_bind( val = <fillcolor_error> ) ).

      status_indicator->ele( n = `ShapeGroup` ns = `si`
          )->ele( n = `LibraryShape` ns = `si`
          )->a( n = `shapeId` v = i_client->_bind( val = <shapeid> ) ).

    ENDIF.

    result = i_xml.

  ENDMETHOD.

  METHOD xml_build_generic_tag.
      FIELD-SYMBOLS <data> TYPE data.
      DATA temp24 TYPE string.
FIELD-SYMBOLS <text> TYPE any.
      DATA temp25 TYPE string.
FIELD-SYMBOLS <design> TYPE any.
      DATA temp26 TYPE string.
FIELD-SYMBOLS <status> TYPE any.

    IF i_data IS NOT SUPPLIED. " Table case

      i_xml->ele( `GenericTag`
          )->a( n = `text` v = |\{{ i_layout->fname }/TEXT\}|
          )->a( n = `design` v = |\{{ i_layout->fname }/DESIGN\}|
          )->a( n = `status` v = |\{{ i_layout->fname }/STATUS\}| ).

    ELSE.


      ASSIGN i_data->* TO <data>.


      temp24 = |{ i_layout->fname }-TEXT|.

ASSIGN COMPONENT temp24 OF STRUCTURE <data> TO <text>.
      IF <text> IS NOT ASSIGNED.
        RETURN.
      ENDIF.


      temp25 = |{ i_layout->fname }-DESIGN|.

ASSIGN COMPONENT temp25 OF STRUCTURE <data> TO <design>.
      IF <design> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      temp26 = |{ i_layout->fname }-STATUS|.

ASSIGN COMPONENT temp26 OF STRUCTURE <data> TO <status>.
      IF <status> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      i_xml->ele( `GenericTag`
          )->a( n = `text` v = i_client->_bind( <text> )
          )->a( n = `design` v = i_client->_bind( <design> )
          )->a( n = `status` v = i_client->_bind( <status> ) ).

    ENDIF.

    result = i_xml.

  ENDMETHOD.

  METHOD value_formatter.

*    result = COND #( WHEN no_zero = abap_true
*                     THEN |\{path : '{ i_client->_bind_edit(
*                                           val  = value
*                                           path = abap_true ) }', type : 'sap.ui.model.odata.type.String', constraints : \{  isDigitSequence : true \} \}|
*                     ELSE i_client->_bind( value ) ).

    result = i_client->_bind( value ).

  ENDMETHOD.

ENDCLASS.
