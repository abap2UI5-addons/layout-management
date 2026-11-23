CLASS z2ui5_cl_layo_xml_builder DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS xml_build_table
      IMPORTING
        i_data             TYPE REF TO data
        i_xml              TYPE REF TO z2ui5_cl_xml_view
        I_client           TYPE REF TO z2ui5_if_client
        i_layout           TYPE REF TO z2ui5_cl_layo_manager
        i_search_value     TYPE REF TO data OPTIONAL
        i_growingthreshold TYPE string      OPTIONAL
        i_headertext       TYPE string      OPTIONAL
        i_Sel_mode         TYPE string      OPTIONAL
        i_sel_BIND_TO      TYPE string      OPTIONAL
        i_col_type         TYPE string      OPTIONAL
        i_col_bind_to      TYPE string      OPTIONAL.

    CLASS-METHODS xml_build_simple_form
      IMPORTING
        i_DATA   TYPE REF TO data
        i_xml    TYPE REF TO z2ui5_cl_xml_view
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

    CLASS-DATA mv_element_counter TYPE int4.

    CLASS-METHODS xml_build_status_indicator
      IMPORTING
        i_data        TYPE REF TO data OPTIONAL
        I_client      TYPE REF TO z2ui5_if_client
        i_layout      TYPE REF TO z2ui5_cl_layo_manager=>ty_s_positions
        i_xml         TYPE REF TO z2ui5_cl_xml_view
      RETURNING
        VALUE(result) TYPE  REF TO z2ui5_cl_xml_view.

    CLASS-METHODS xml_build_progress_indicator
      IMPORTING
        i_data        TYPE REF TO data OPTIONAL
        I_client      TYPE REF TO z2ui5_if_client
        i_layout      TYPE REF TO z2ui5_cl_layo_manager=>ty_s_positions
        i_xml         TYPE REF TO z2ui5_cl_xml_view
      RETURNING
        VALUE(result) TYPE  REF TO z2ui5_cl_xml_view.

    CLASS-METHODS xml_build_radial_microchart
      IMPORTING
        i_data        TYPE REF TO data OPTIONAL
        I_client      TYPE REF TO z2ui5_if_client
        i_layout      TYPE REF TO z2ui5_cl_layo_manager=>ty_s_positions
        i_xml         TYPE REF TO z2ui5_cl_xml_view
      RETURNING
        VALUE(result) TYPE  REF TO z2ui5_cl_xml_view.

    CLASS-METHODS xml_build_icon
      IMPORTING
        i_data        TYPE REF TO data OPTIONAL
        I_client      TYPE REF TO z2ui5_if_client
        i_layout      TYPE REF TO z2ui5_cl_layo_manager=>ty_s_positions
        i_xml         TYPE REF TO z2ui5_cl_xml_view
      RETURNING
        VALUE(result) TYPE  REF TO z2ui5_cl_xml_view.

    CLASS-METHODS xml_build_generic_tag
      IMPORTING
        i_data        TYPE REF TO data OPTIONAL
        I_client      TYPE REF TO z2ui5_if_client
        i_layout      TYPE REF TO z2ui5_cl_layo_manager=>ty_s_positions
        i_xml         TYPE REF TO z2ui5_cl_xml_view
      RETURNING
        VALUE(result) TYPE  REF TO z2ui5_cl_xml_view.

    CLASS-METHODS get_grid_layout
      IMPORTING
        !layout       TYPE REF TO z2ui5_cl_layo_manager=>ty_s_positions
      RETURNING
        VALUE(result) TYPE ty_s_grid_layout.

    CLASS-METHODS set_layout_for_element
      IMPORTING
        span  TYPE string
        i_xml TYPE REF TO z2ui5_cl_xml_view.

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

    DATA(form) = i_xml->simple_form( title                   = i_title
                                     editable                = abap_true
                                     layout                  = `ResponsiveGridLayout`
                                     labelspans              = '3'
                                     labelspanm              = '3'
                                     labelspanl              = '3'
                                     labelspanxl             = '3'
                                     adjustlabelspan         = abap_false
                                     emptyspanxl             = '4'
                                     emptyspanl              = '4'
                                     emptyspanm              = '2'
                                     emptyspans              = '0'
                                     columnsxl               = '1'
                                     columnsl                = '1'
                                     columnsm                = '1'
                                     singlecontainerfullsize = abap_false
                              )->content( ns = `form` ).

    LOOP AT i_layout->ms_layout-t_layout REFERENCE INTO DATA(layout).

      DATA(lv_index) = sy-tabix.

      ASSIGN COMPONENT layout->fname OF STRUCTURE i_data->* TO FIELD-SYMBOL(<value>).
      IF <value> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      DATA(grid_layout) = get_grid_layout( layout ).

      DATA(line) = form->label( wrapping = abap_false
                                text     = i_client->_bind( val       = layout->tlabel
                                                            tab       = i_layout->ms_layout-t_layout
                                                            tab_index = lv_index )
                                labelfor = ` `  ).

      set_layout_for_element( i_xml = line
                              span  = grid_layout-label ).

      IF layout->rollname CP `*_XML_S_ICON`.

        DATA(hbox) = line->hbox( rendertype = `Bare`
                                 visible    = I_client->_bind( val       = layout->visible
                                                               tab       = i_layout->ms_layout-t_layout
                                                               tab_index = lv_index ) ).

        set_layout_for_element( i_xml = line
                                span  = grid_layout-value ).

        xml_build_icon( i_layout = layout
                        i_data   = i_data
                        I_client = I_client
                        i_xml    = hbox ).

      ELSEIF layout->rollname CP `*_XML_S_PROGRESSIND`.

        hbox = line->hbox( rendertype = `Bare`
                           visible    = I_client->_bind( val       = layout->visible
                                                         tab       = I_layout->ms_layout-t_layout
                                                         tab_index = lv_index ) ).

        set_layout_for_element( i_xml = line
                                span  = grid_layout-value ).

        xml_build_progress_indicator( i_layout = layout
                                      i_data   = i_data
                                      I_client = I_client
                                      i_xml    = hbox ).

      ELSEIF layout->rollname CP `*_XML_S_GENERICTAG`.

        hbox = line->hbox( rendertype = `Bare`
                           visible    = I_client->_bind( val       = layout->visible
                                                         tab       = I_layout->ms_layout-t_layout
                                                         tab_index = lv_index ) ).

        set_layout_for_element( i_xml = line
                                span  = grid_layout-value ).

        xml_build_generic_tag( i_layout = layout
                               i_data   = i_data
                               I_client = I_client
                               i_xml    = hbox ).

      ELSEIF layout->rollname CP `*_XML_S_STATUSIND`.

        hbox = line->hbox( rendertype = `Bare`
                           visible    = I_client->_bind( val       = layout->visible
                                                         tab       = I_layout->ms_layout-t_layout
                                                         tab_index = lv_index ) ).

        set_layout_for_element( i_xml = line
                                span  = grid_layout-value ).

        xml_build_status_indicator( i_data   = i_data
                                    I_client = I_client
                                    i_layout = layout
                                    i_xml    = hbox ).

      ELSEIF layout->rollname CP `*_XML_S_RADIALCHART`.

        hbox = line->hbox( rendertype = `Bare`
                           visible    = I_client->_bind( val       = layout->visible
                                                         tab       = I_layout->ms_layout-t_layout
                                                         tab_index = lv_index ) ).

        set_layout_for_element( i_xml = line
                                span  = grid_layout-value ).

        xml_build_radial_microchart( i_data   = i_data
                                     I_client = I_client
                                     i_layout = layout
                                     i_xml    = hbox ).

      ELSE.

        line->input( visible = I_client->_bind( val       = layout->visible
                                                tab       = I_layout->ms_layout-t_layout
                                                tab_index = lv_index )
                     value   = value_formatter( layout  = layout
                                                I_client = I_client
                                                value    = <value> )
                     enabled = abap_false
                     width   = I_client->_bind( val       = layout->width
                                                tab       = I_layout->ms_layout-t_layout
                                                tab_index = lv_index ) ).

        set_layout_for_element( i_xml = line
                                span  = grid_layout-value ).

      ENDIF.

      IF layout->reference_field IS NOT INITIAL.

        ASSIGN COMPONENT layout->reference_field OF STRUCTURE i_data->* TO FIELD-SYMBOL(<ref_value>).
        IF <ref_value> IS NOT ASSIGNED.
          CONTINUE.
        ENDIF.

        DATA(ref_field) = ref #( I_layout->ms_layout-t_layout[ fname = layout->reference_field ] OPTIONAL ).
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        " TODO: variable is assigned but never used (ABAP cleaner)
        DATA(ref_f) = VALUE #( I_layout->ms_layout-t_layout[ fname = layout->reference_field ] OPTIONAL ).

        line->input( visible = I_client->_bind( val       = layout->visible
                                                tab       = I_layout->ms_layout-t_layout
                                                tab_index = lv_index )
                     value   = value_formatter( layout  = ref_field
                                                I_client = I_client
                                                value    = <ref_value> )
                     enabled = abap_false ).

        set_layout_for_element( i_xml = line
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

    mv_element_counter = mv_element_counter + 1.
    IF span IS INITIAL.

      RETURN.
    ENDIF.
    i_xml->get_child( mv_element_counter )->layout_data( )->grid_data( span = span ).

  ENDMETHOD.

  METHOD xml_build_table.

  ASSIGN i_data->* to FIELD-SYMBOL(<tab>).

    DATA(table) = i_xml->table(
                      growing          = COND #( WHEN i_growingthreshold = space THEN abap_false ELSE abap_true  )
                      growingthreshold = i_growingthreshold
                      width            = 'auto'
                      mode             = COND #( WHEN i_sel_mode = space THEN `None` ELSE i_sel_mode  )
                      items            = i_client->_bind( <tab> )
                      selectionchange  = i_client->_event( 'SELECTION_CHANGE' ) ).

    DATA(toolbar) = table->header_toolbar(
                  )->overflow_toolbar( ).

    IF i_headertext IS NOT INITIAL.
      toolbar->title( text  = i_headertext
                      level = `H2` ).
    ENDIF.

    toolbar->toolbar_spacer( ).

    IF i_search_value IS SUPPLIED.

    ASSIGN i_search_value->* to FIELD-SYMBOL(<search>).

      toolbar->search_field( value  = i_client->_bind( <search> )
                             search = i_client->_event( 'SEARCH' )
                             change = i_client->_event( 'SEARCH' )
                             id     = `SEARCH`
                             width  = '17.5rem' ).
    ENDIF.

    z2ui5_cl_layo_pop=>render_layout_function( client = i_client
                                               xml    = toolbar
                                               layout = i_layout ).

    DATA(columns) = table->columns( ).

    LOOP AT i_layout->ms_layout-t_layout REFERENCE INTO DATA(layout).
      DATA(lv_index) = sy-tabix.

      columns->column( visible         = i_client->_bind( val       = layout->visible
                                                          tab       = i_layout->ms_layout-t_layout
                                                          tab_index = lv_index )
                       mergeduplicates = i_client->_bind( val       = layout->merge
                                                          tab       = i_layout->ms_layout-t_layout
                                                          tab_index = lv_index )
                       width           = i_client->_bind( val       = layout->width
                                                          tab       = i_layout->ms_layout-t_layout
                                                          tab_index = lv_index )

       )->text( layout->tlabel ).

    ENDLOOP.

    DATA(column_list_item) = columns->get_parent( )->items(
                                       )->column_list_item(
                                           valign   = 'Middle'
                                           selected = COND #( WHEN i_sel_bind_to = space
                                                              THEN ``
                                                              ELSE |\{{ i_sel_bind_to }\}| )
                                           type     = COND #( WHEN i_col_type = space THEN `Inactive` ELSE i_col_type  )
                                           press    = i_client->_event(
                                               val   = 'ROW_SELECT'
                                               t_arg = VALUE #( ( COND #( WHEN i_col_bind_to = space
                                                                          THEN ``
                                                                          ELSE |$\{{ i_col_bind_to }\}| )  ) ) ) ).

    DATA(cells) = column_list_item->cells( ).

    LOOP AT i_layout->ms_layout-t_layout REFERENCE INTO layout.

      lv_index = sy-tabix.

      IF layout->rollname CP `*_XML_S_ICON`.

        xml_build_icon( I_client = I_client
                        i_layout = layout
                        i_xml    = cells ).

      ELSEIF layout->rollname CP `*_XML_S_RADIALCHART`.

        xml_build_radial_microchart( i_layout = layout
                                     I_client = I_client
                                     i_xml    = cells ).

      ELSEIF layout->rollname CP `*_XML_S_PROGRESSIND`.

        xml_build_progress_indicator( i_layout = layout
                                      I_client = I_client
                                      i_xml    = cells ).

      ELSEIF layout->rollname CP `*_XML_S_STATUSIND`.

        xml_build_status_indicator( i_layout = layout
                                    I_client = I_client
                                    i_xml    = cells ).

      ELSEIF layout->rollname CP `*_XML_S_GENERICTAG`.

        xml_build_generic_tag( i_layout = layout
                               I_client = I_client
                               i_xml    = cells ).

      ELSE.

        IF layout->t_sub_col IS NOT INITIAL.

          DATA(sub_col) = ``.
          DATA(index) = 0.

          LOOP AT layout->t_sub_col INTO DATA(subcol).

            index = index + 1.

            READ TABLE i_layout->ms_layout-t_layout INTO DATA(line) WITH KEY fname = subcol-fname.

            IF line-reference_field IS INITIAL.
              DATA(column) = |{ line-tlabel }: { table_value_formatter( line ) }|.
            ELSE.

              READ TABLE i_layout->ms_layout-t_layout INTO DATA(ref) WITH KEY fname = line-reference_field.

              column = |{ line-tlabel }:  { table_value_formatter( line ) } { table_value_formatter( ref ) }|.
            ENDIF.

            IF index = 1.
              sub_col = column.
            ELSE.
              sub_col = |{ sub_col }{ cl_abap_char_utilities=>cr_lf }{ column }|.
            ENDIF.
          ENDLOOP.

          IF layout->reference_field IS NOT INITIAL.

            READ TABLE i_layout->ms_layout-t_layout INTO ref WITH KEY fname = layout->reference_field.

            cells->object_identifier( title = |{ table_value_formatter( layout->* ) } {
                                                 table_value_formatter( ref ) }|
                                      text  = sub_col ).
          ELSE.
            cells->object_identifier( title = table_value_formatter( layout->* )
                                      text  = sub_col ).
          ENDIF.

        ELSE.

          IF layout->reference_field IS NOT INITIAL.

            READ TABLE i_layout->ms_layout-t_layout INTO ref WITH KEY fname = layout->reference_field.

            cells->object_identifier( text = |{ table_value_formatter( layout->* ) } {
                                                table_value_formatter( ref ) }| ).
          ELSE.
            cells->object_identifier( text = |{ table_value_formatter( layout->* ) }| ).
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

    IF i_data IS NOT SUPPLIED. " Table case

      i_xml->icon( src  = |\{{ i_layout->fname }/SRC\}|
                   size = |\{{ i_layout->fname }/ICON_SIZE\}| ).

    ELSE.

      ASSIGN COMPONENT |{ i_layout->fname }-SRC| OF STRUCTURE i_data->* TO FIELD-SYMBOL(<src>).
      IF <src> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      ASSIGN COMPONENT |{ i_layout->fname }-ICON_SIZE| OF STRUCTURE i_data->* TO FIELD-SYMBOL(<size>).
      IF <size> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      i_xml->icon( src  = I_client->_bind( val = <src> )
                   size = I_client->_bind( val = <size> ) ).

    ENDIF.

    result = i_xml.

  ENDMETHOD.

  METHOD xml_build_radial_microchart.

    IF i_data IS NOT  SUPPLIED. " Table case

      i_xml->radial_micro_chart( size         = |\{{ i_layout->fname }/RADIALMICROCHART_SIZE\}|
                                 percentage   = |\{{ i_layout->fname }/PERCENTAGE\}|
                                 valuecolor   = |\{{ i_layout->fname }/VALUECOLOR\}|
                                 hideonnodata = |\{{ i_layout->fname }/HIDEONNODATA\}| ).

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

      i_xml->radial_micro_chart( size         = I_client->_bind( val = <size> )
                                 percentage   = I_client->_bind( val = <percentage> )
*                                 press        = press
                                 valuecolor   = I_client->_bind( val = <valuecolor> )
*                                 height       = height
*                                 aligncontent = aligncontent
                                 hideonnodata = I_client->_bind( val = <hideonnodata> ) ).

    ENDIF.

    result = i_xml.

  ENDMETHOD.

  METHOD xml_build_progress_indicator.

    IF i_data IS NOT  SUPPLIED. " Table case

      i_xml->progress_indicator( class        = `sapUiSmallMarginBottom`
                                 percentvalue = |\{{ i_layout->fname }/PERCENTVALUE\}|
                                 displayvalue = |\{{ i_layout->fname }/DISPLAYVALUE\}|
                                 showvalue    = |\{{ i_layout->fname }/SHOWVALUE\}|
                                 state        = |\{{ i_layout->fname }/STATE\}| ).

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
*      ASSIGN COMPONENT |{ i_layout->visible }| OF STRUCTURE i_data->* TO FIELD-SYMBOL(<visible>).
*      IF <visible> IS NOT ASSIGNED.
*        RETURN.
*      ENDIF.

      i_xml->progress_indicator( class        = `sapUiSmallMarginBottom`
                                 percentvalue = I_client->_bind( val = <percentvalue> )
                                 displayvalue = I_client->_bind( val = <displayvalue> )
                                 showvalue    = I_client->_bind( val = <showvalue> )
                                 state        = I_client->_bind( val = <state> )
                                 visible      = i_layout->visible  ).

    ENDIF.

    result = i_xml.

  ENDMETHOD.

  METHOD xml_build_status_indicator.

    IF i_data IS NOT SUPPLIED. " We want to build a Table!

      DATA(status_indicator) = i_xml->status_indicator( class = |\{{ i_layout->fname }/CLASS\}|
                                                        size  = |\{{ i_layout->fname }/STATUSINDICATOR_SIZE\}|
                                                        value = |\{{ i_layout->fname }/VALUE\}| ).

      DATA(thresholds) = status_indicator->property_thresholds( ).

      thresholds->property_threshold( fillcolor = 'Good'
                                      tovalue   = |\{{ i_layout->fname }/FILLCOLOR_GOOD\}| ).

      thresholds->property_threshold( fillcolor = 'Critical'
                                      tovalue   = |\{{ i_layout->fname }/FILLCOLOR_CRITICAL\}| ).

      thresholds->property_threshold( fillcolor = 'Error'
                                      tovalue   = |\{{ i_layout->fname }/FILLCOLOR_ERROR\}| ).

      status_indicator->shape_group( )->library_shape( shapeid = |\{{ i_layout->fname }/SHAPEID\}| ).

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

      status_indicator = i_xml->status_indicator( class   = I_client->_bind( val = <class> )
                                                  size    = I_client->_bind( val = <size> )
                                                  value   = I_client->_bind( val = <value> )
                                                  visible = i_layout->visible ).

      thresholds = status_indicator->property_thresholds( ).

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

      thresholds->property_threshold( fillcolor = 'Good'
                                      tovalue   = I_client->_bind( val = <fillcolor_good> ) ).

      thresholds->property_threshold( fillcolor = 'Critical'
                                      tovalue   = I_client->_bind( val = <fillcolor_critical> ) ).

      thresholds->property_threshold( fillcolor = 'Error'
                                      tovalue   = I_client->_bind( val = <fillcolor_error> ) ).

      status_indicator->shape_group( )->library_shape( shapeid = I_client->_bind( val = <shapeid> ) ).

    ENDIF.

    result = i_xml.

  ENDMETHOD.

  METHOD xml_build_generic_tag.

    IF i_data IS NOT SUPPLIED. " Table case

      i_xml->generic_tag( text   = |\{{ i_layout->fname }/TEXT\}|
                          design = |\{{ i_layout->fname }/DESIGN\}|
                          status = |\{{ i_layout->fname }/STATUS\}| ).

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

      i_xml->generic_tag( text   = I_client->_bind( <text> )
                          design = I_client->_bind( <design> )
                          status = I_client->_bind( <status> ) ).

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
