CLASS z2ui5_cl_layo_xml_builder DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    " the controls a table cell is drawn with - the value of
    " ty_s_cell_control-control
    CONSTANTS:
      BEGIN OF cs_cell_control,
        " the value as text (sap.m.ObjectIdentifier) - every column that is
        " no control
        text         TYPE string VALUE `TEXT`,
        " sap.ui.core.Icon: SRC, ICON_SIZE or SIZE, and COLOR, PRESS,
        " PRESS_VALUE when the structure has them (z2ui5_xml_s_icon)
        icon         TYPE string VALUE `ICON`,
        " sap.suite.ui.microchart.RadialMicroChart (z2ui5_xml_s_radialchart)
        radial_chart TYPE string VALUE `RADIAL_CHART`,
        " sap.m.ProgressIndicator (z2ui5_xml_s_progressind)
        progress_ind TYPE string VALUE `PROGRESS_IND`,
        " sap.suite.ui.commons.statusindicator.StatusIndicator (z2ui5_xml_s_statusind)
        status_ind   TYPE string VALUE `STATUS_IND`,
        " sap.m.GenericTag (z2ui5_xml_s_generictag)
        generic_tag  TYPE string VALUE `GENERIC_TAG`,
        " sap.m.Switch (z2ui5_xml_s_switch)
        switch       TYPE string VALUE `SWITCH`,
        " sap.m.Input (z2ui5_xml_s_input)
        input        TYPE string VALUE `INPUT`,
        " sap.m.Button (z2ui5_xml_s_button)
        button       TYPE string VALUE `BUTTON`,
      END OF cs_cell_control.

    TYPES:
      "! The control the cells of a column are drawn with, by the rollname of
      "! the column - its data element, or for a structured column its
      "! structure type. rollname is a pattern (CP, e.g. `ZMY_S_ICON` or
      "! `ZMY_*_SWITCH`), control one of cs_cell_control. The entries an app
      "! passes come first, in their order; behind them the built-in ones:
      "! `*_XML_S_ICON`, `*_XML_S_RADIALCHART`, `*_XML_S_PROGRESSIND`,
      "! `*_XML_S_STATUSIND`, `*_XML_S_GENERICTAG`, `*_XML_S_SWITCH`,
      "! `*_XML_S_INPUT`, `*_XML_S_BUTTON`
      BEGIN OF ty_s_cell_control,
        rollname TYPE string,
        control  TYPE string,
      END OF ty_s_cell_control.
    TYPES ty_t_cell_control TYPE STANDARD TABLE OF ty_s_cell_control WITH EMPTY KEY.

    "! the event of a column header clicked with i_col_sort - the arguments
    "! are the guid of the layout and the name of the column; handled by
    "! on_event_column_sort( ) and z2ui5_cl_layo_pop=&gt;on_event_layout( )
    CONSTANTS cv_event_column_sort TYPE string VALUE `LAYO_COLUMN_SORT` ##NO_TEXT.

    "! The table of a layout (sap.m.Table). Every parameter behind i_col_bind_to
    "! is optional and changes nothing when it is not passed.
    "! @parameter i_col_sort | abap_true: the header of a column is a link -
    "!   clicking it sorts the table by that column (none, ascending,
    "!   descending) through the layout, the column shows the sort order with
    "!   its standard sort icon (sap.m.Column sortIndicator). The event is
    "!   cv_event_column_sort - pass it to on_event_column_sort( ) or
    "!   z2ui5_cl_layo_pop=&gt;on_event_layout( ) together with the table
    "! @parameter i_col_sort_class | a style class for the links of the headers,
    "!   for an app that styles them with CSS of its own
    "! @parameter i_row_color | the field of the row that carries a colour key,
    "!   relative to the row (`COLOR`, or `CELL_COLOR-COLOR` for a component of
    "!   a structured column): every row gets it as custom data `color`,
    "!   written to the DOM - `&lt;tr data-color="red_1"&gt;`. The CSS that
    "!   turns the key into a colour is the app's
    "! @parameter i_sub_col_controls | abap_true: a subcolumn that is a cell
    "!   control (see ty_s_cell_control) is drawn as that control, and a
    "!   column that is a control shows its subcolumns as well - several
    "!   controls of one cell are stacked in a VBox. Without it a control
    "!   column shows the control only, and every subcolumn is text
    "! @parameter i_t_cell_control | the app's own mapping of rollnames to
    "!   cell controls, checked before the built-in one - see ty_s_cell_control
    "! @parameter i_sel_event | the event of selectionChange, SELECTION_CHANGE
    "!   when empty
    "! @parameter i_toolbar | abap_false: the table has no header toolbar - no
    "!   layout settings button, no search field (i_search_value is ignored);
    "!   i_headertext becomes the headerText of the table instead of a title
    "!   in the toolbar
    CLASS-METHODS xml_build_table
      IMPORTING
        i_data             TYPE REF TO data
        i_xml              TYPE REF TO z2ui5_cl_ui5_view_builder
        i_client           TYPE REF TO z2ui5_if_client
        i_layout           TYPE REF TO z2ui5_cl_layo_manager
        i_search_value     TYPE REF TO data       OPTIONAL
        i_growingthreshold TYPE string            OPTIONAL
        i_headertext       TYPE string            OPTIONAL
        i_sel_mode         TYPE string            OPTIONAL
        i_sel_bind_to      TYPE string            OPTIONAL
        i_col_type         TYPE string            OPTIONAL
        i_col_bind_to      TYPE string            OPTIONAL
        i_col_sort         TYPE abap_bool         DEFAULT abap_false
        i_col_sort_class   TYPE string            OPTIONAL
        i_row_color        TYPE string            OPTIONAL
        i_sub_col_controls TYPE abap_bool         DEFAULT abap_false
        i_t_cell_control   TYPE ty_t_cell_control OPTIONAL
        i_sel_event        TYPE string            OPTIONAL
        i_toolbar          TYPE abap_bool         DEFAULT abap_true.

    "! The click on a column header of a table rendered with i_col_sort:
    "! switches the sorting of the column in the layout (none -&gt; ascending
    "! -&gt; descending -&gt; none, every other column loses its sorting) and
    "! sorts the table. z2ui5_cl_layo_pop=&gt;on_event_layout( ) calls it as
    "! well.
    "! @parameter data | the table again - see z2ui5_cl_layo_manager=&gt;set_data( )
    "! @parameter result | abap_true when the event was the column sort of
    "!   this layout
    CLASS-METHODS on_event_column_sort
      IMPORTING
        !client       TYPE REF TO z2ui5_if_client
        !layout       TYPE REF TO z2ui5_cl_layo_manager
        !data         TYPE REF TO data OPTIONAL
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS xml_build_simple_form
      IMPORTING
        i_data   TYPE REF TO data
        i_xml    TYPE REF TO z2ui5_cl_ui5_view_builder
        i_client TYPE REF TO z2ui5_if_client
        i_layout TYPE REF TO z2ui5_cl_layo_manager
        i_title  TYPE string OPTIONAL.

    "! The generic mode: the view XML with the layout applied. i_layout comes
    "! from z2ui5_cl_layo_manager=&gt;factory_generic( ) with the controls
    "! registered; the controls the layout hides get visible="false" (a Label
    "! pointing at them with labelFor too), the registered controls are
    "! reordered inside their parent aggregation, renamed controls get their
    "! label and width written. Everything else in the view stays as it is:
    "!   client-&gt;view_display( z2ui5_cl_layo_xml_builder=&gt;xml_apply_layout( i_xml    = view-&gt;stringify( )
    "!                                                                      i_layout = mo_layout ) ).
    CLASS-METHODS xml_apply_layout
      IMPORTING
        i_xml         TYPE string
        i_layout      TYPE REF TO z2ui5_cl_layo_manager
      RETURNING
        VALUE(result) TYPE string.

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
        i_t_comp      TYPE string_table OPTIONAL
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
        i_t_comp      TYPE string_table OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ui5_view_builder.

    CLASS-METHODS xml_build_icon
      IMPORTING
        i_data        TYPE REF TO data OPTIONAL
        i_client      TYPE REF TO z2ui5_if_client
        i_layout      TYPE REF TO z2ui5_cl_layo_manager=>ty_s_positions
        i_xml         TYPE REF TO z2ui5_cl_ui5_view_builder
        i_t_comp      TYPE string_table OPTIONAL
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

    "! table case: sap.m.Switch over STATE, CUSTOMTEXTON, CUSTOMTEXTOFF,
    "! ENABLED, TYPE and the event CHANGE / CHANGE_VALUE - each one the
    "! structure has (all of them with no i_t_comp)
    CLASS-METHODS xml_build_switch
      IMPORTING
        i_client TYPE REF TO z2ui5_if_client
        i_layout TYPE REF TO z2ui5_cl_layo_manager=>ty_s_positions
        i_xml    TYPE REF TO z2ui5_cl_ui5_view_builder
        i_t_comp TYPE string_table OPTIONAL.

    "! table case: sap.m.Input over VALUE, PLACEHOLDER, ENABLED, EDITABLE,
    "! VISIBLE - each one the structure has
    CLASS-METHODS xml_build_input
      IMPORTING
        i_layout TYPE REF TO z2ui5_cl_layo_manager=>ty_s_positions
        i_xml    TYPE REF TO z2ui5_cl_ui5_view_builder
        i_t_comp TYPE string_table OPTIONAL.

    "! table case: sap.m.Button over TEXT, ICON, TYPE and the event PRESS /
    "! PRESS_VALUE - each one the structure has
    CLASS-METHODS xml_build_button
      IMPORTING
        i_client TYPE REF TO z2ui5_if_client
        i_layout TYPE REF TO z2ui5_cl_layo_manager=>ty_s_positions
        i_xml    TYPE REF TO z2ui5_cl_ui5_view_builder
        i_t_comp TYPE string_table OPTIONAL.

    "! the control of a column - the app's entries first, then the
    "! built-in patterns (see ty_s_cell_control); cs_cell_control-text for
    "! every other column
    CLASS-METHODS cell_control
      IMPORTING
        rollname       TYPE clike
        t_cell_control TYPE ty_t_cell_control OPTIONAL
      RETURNING
        VALUE(result)  TYPE string.

    "! one cell control of a table row - into a cell or a VBox
    CLASS-METHODS xml_build_cell_control
      IMPORTING
        i_client  TYPE REF TO z2ui5_if_client
        i_data    TYPE REF TO data
        i_control TYPE string
        i_layout  TYPE REF TO z2ui5_cl_layo_manager=>ty_s_positions
        i_xml     TYPE REF TO z2ui5_cl_ui5_view_builder.

    "! the cell of a column with i_sub_col_controls: the value or the
    "! control, the text subcolumns and the control subcolumns - in a VBox
    "! when there is more than one control
    CLASS-METHODS xml_build_cell_stacked
      IMPORTING
        i_client         TYPE REF TO z2ui5_if_client
        i_data           TYPE REF TO data
        i_layout         TYPE REF TO z2ui5_cl_layo_manager
        !position        TYPE REF TO z2ui5_cl_layo_manager=>ty_s_positions
        i_t_cell_control TYPE ty_t_cell_control
        i_xml            TYPE REF TO z2ui5_cl_ui5_view_builder.

    "! the text of the subcolumns of a column (`Label: value`, one per line);
    "! with skip_controls the subcolumns that are cell controls are left out
    CLASS-METHODS sub_col_text
      IMPORTING
        i_layout         TYPE REF TO z2ui5_cl_layo_manager
        !position        TYPE z2ui5_cl_layo_manager=>ty_s_positions
        skip_controls    TYPE abap_bool DEFAULT abap_false
        i_t_cell_control TYPE ty_t_cell_control OPTIONAL
      RETURNING
        VALUE(result)    TYPE string.

    "! the header of a column: its label, with i_col_sort a link that sorts
    "! the table by the column
    CLASS-METHODS xml_build_column_header
      IMPORTING
        i_client  TYPE REF TO z2ui5_if_client
        i_layout  TYPE REF TO z2ui5_cl_layo_manager
        !position TYPE REF TO z2ui5_cl_layo_manager=>ty_s_positions
        i_index   TYPE i
        i_sort    TYPE abap_bool
        i_class   TYPE string
        i_column  TYPE REF TO z2ui5_cl_ui5_view_builder.

    "! the sortIndicator of a column: an expression over the path of the
    "! layout's SORTING of the column (ASCENDING / DESCENDING)
    CLASS-METHODS sort_indicator
      IMPORTING
        path          TYPE string
      RETURNING
        VALUE(result) TYPE string.

    "! the binding of the row colour - i_row_color as a path relative to
    "! the row
    CLASS-METHODS row_color_binding
      IMPORTING
        !field        TYPE string
      RETURNING
        VALUE(result) TYPE string.

    "! the components of a structured column of the table (empty for any
    "! other column, or when the type cannot be read)
    CLASS-METHODS get_t_comp
      IMPORTING
        i_data        TYPE REF TO data
        fname         TYPE clike
      RETURNING
        VALUE(result) TYPE string_table.

    "! the component a property binds: the first of the candidates the
    "! structure has; the first candidate when it has none of them or when
    "! the components are unknown (t_comp empty) - what was bound before
    "! the alternatives
    CLASS-METHODS comp_name
      IMPORTING
        t_comp        TYPE string_table
        primary       TYPE string
        alternative   TYPE string OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

    "! abap_true when the structure has the component - or when the
    "! components are unknown (t_comp empty)
    CLASS-METHODS has_comp
      IMPORTING
        t_comp        TYPE string_table
        !name         TYPE string
      RETURNING
        VALUE(result) TYPE abap_bool.

    "! abap_true when the structure has the component; abap_false when the
    "! components are unknown - for the optional properties a structure of
    "! this addon does not carry
    CLASS-METHODS has_comp_strict
      IMPORTING
        t_comp        TYPE string_table
        !name         TYPE string
      RETURNING
        VALUE(result) TYPE abap_bool.

    "! the event of a cell control whose name is a value of the row:
    "! the framework's wire of an event (z2ui5_if_client=&gt;_event( )) with
    "! the name replaced by the binding of PATH/EVENT and the binding of
    "! PATH/VALUE as its argument
    CLASS-METHODS row_event
      IMPORTING
        i_client      TYPE REF TO z2ui5_if_client
        path          TYPE string
        !event        TYPE string
        !value        TYPE string
        t_comp        TYPE string_table
      RETURNING
        VALUE(result) TYPE string.

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

    "! the binding of a form field - with the digit type when the view
    "! formats the field itself (z2ui5_cl_layo_manager=&gt;digit_type( ))
    CLASS-METHODS value_formatter
      IMPORTING
        i_client      TYPE REF TO z2ui5_if_client
        !value        TYPE any
        !position     TYPE z2ui5_cl_layo_manager=>ty_s_positions
      RETURNING
        VALUE(result) TYPE string.

    "! the core:require of the digit type on a control whose bindings use
    "! it, with the namespace declared on the control itself - the view of
    "! the app may not declare core, or under another prefix
    CLASS-METHODS set_digit_type_require
      IMPORTING
        i_xml TYPE REF TO z2ui5_cl_ui5_view_builder.

    "! abap_true when a column of the layout is bound with the digit type
    CLASS-METHODS check_digit_type
      IMPORTING
        i_layout      TYPE REF TO z2ui5_cl_layo_manager
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS table_value_formatter
      IMPORTING
        !position     TYPE z2ui5_cl_layo_manager=>ty_s_positions
      RETURNING
        VALUE(result) TYPE string.

    "! the cell of a column: its value, followed by the value of its
    "! reference field when that is a column
    CLASS-METHODS cell_text
      IMPORTING
        i_layout      TYPE REF TO z2ui5_cl_layo_manager
        !position     TYPE z2ui5_cl_layo_manager=>ty_s_positions
      RETURNING
        VALUE(result) TYPE string.

ENDCLASS.


CLASS z2ui5_cl_layo_xml_builder IMPLEMENTATION.

  METHOD xml_apply_layout.

    IF i_layout IS NOT BOUND.
      result = i_xml.
      RETURN.
    ENDIF.

    i_layout->prepare( ).

    result = z2ui5_cl_layo_xml_tree=>apply( xml    = i_xml
                                            t_slot = i_layout->get_slots( ) ).

  ENDMETHOD.

  METHOD xml_build_simple_form.

    z2ui5_cl_layo_pop=>render_layout_function( client = i_client
                                               xml    = i_xml
                                               layout = i_layout ).

    DATA(form) = i_xml->ele( n = `SimpleForm` ns = `form`
                     )->a( n = `title` v = i_title
                     )->a( n = `editable` b = abap_true
                     )->a( n = `layout` v = `ResponsiveGridLayout`
                     )->a( n = `labelSpanS` v = `3`
                     )->a( n = `labelSpanM` v = `3`
                     )->a( n = `labelSpanL` v = `3`
                     )->a( n = `labelSpanXL` v = `3`
                     )->a( n = `adjustLabelSpan` b = abap_false
                     )->a( n = `emptySpanXL` v = `4`
                     )->a( n = `emptySpanL` v = `4`
                     )->a( n = `emptySpanM` v = `2`
                     )->a( n = `emptySpanS` v = `0`
                     )->a( n = `columnsXL` v = `1`
                     )->a( n = `columnsL` v = `1`
                     )->a( n = `columnsM` v = `1`
                     )->a( n = `singleContainerFullSize` b = abap_false
                     )->ele( n = `content` ns = `form` ).

    ASSIGN i_data->* TO FIELD-SYMBOL(<data>).

    LOOP AT i_layout->ms_layout-t_layout REFERENCE INTO DATA(layout).

      DATA(lv_index) = sy-tabix.

      FIELD-SYMBOLS <value> TYPE any.
      UNASSIGN <value>.
      ASSIGN COMPONENT layout->fname OF STRUCTURE <data> TO <value>.
      IF <value> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      DATA(grid_layout) = get_grid_layout( layout ).

      DATA(label) = form->ele( `Label`
                        )->a( n = `wrapping` b = abap_false
                        )->a( n = `text` v = i_client->_bind( val       = layout->tlabel
                                                             tab       = i_layout->ms_layout-t_layout
                                                             tab_index = lv_index )
                        )->a( n = `labelFor` v = ` ` ).

      set_layout_for_element( i_xml = label
                              span  = grid_layout-label ).

      IF layout->rollname CP `*_XML_S_ICON`.

        DATA(hbox) = form->ele( `HBox`
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

        hbox = form->ele( `HBox`
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

        hbox = form->ele( `HBox`
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

        hbox = form->ele( `HBox`
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

        hbox = form->ele( `HBox`
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

        DATA(input) = form->ele( `Input`
                          )->a( n = `visible` v = i_client->_bind( val       = layout->visible
                                                                   tab       = i_layout->ms_layout-t_layout
                                                                   tab_index = lv_index )
                          )->a( n = `value` v = value_formatter( i_client = i_client
                                                                 value    = <value>
                                                                 position = layout->* )
                          )->a( n = `enabled` b = abap_false
                          )->a( n = `width` v = i_client->_bind( val       = layout->width
                                                                 tab       = i_layout->ms_layout-t_layout
                                                                 tab_index = lv_index ) ).

        IF z2ui5_cl_layo_manager=>digit_type( layout->* ) = abap_true.
          set_digit_type_require( input ).
        ENDIF.

        set_layout_for_element( i_xml = input
                                span  = grid_layout-value ).

      ENDIF.

      IF layout->reference_field IS NOT INITIAL.

        FIELD-SYMBOLS <ref_value> TYPE any.
        UNASSIGN <ref_value>.
        ASSIGN COMPONENT layout->reference_field OF STRUCTURE <data> TO <ref_value>.
        IF <ref_value> IS NOT ASSIGNED.
          CONTINUE.
        ENDIF.

        DATA(ref_field) = REF #( i_layout->ms_layout-t_layout[ fname = layout->reference_field ] OPTIONAL ).
        IF ref_field IS INITIAL.
          CONTINUE.
        ENDIF.

        DATA(ref_input) = form->ele( `Input`
                              )->a( n = `visible` v = i_client->_bind( val       = layout->visible
                                                                       tab       = i_layout->ms_layout-t_layout
                                                                       tab_index = lv_index )
                              )->a( n = `value` v = value_formatter( i_client = i_client
                                                                     value    = <ref_value>
                                                                     position = ref_field->* )
                              )->a( n = `enabled` b = abap_false ).

        IF z2ui5_cl_layo_manager=>digit_type( ref_field->* ) = abap_true.
          set_digit_type_require( ref_input ).
        ENDIF.

        set_layout_for_element( i_xml = ref_input
                                span  = grid_layout-ref_field ).

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
      " the reference field occupies two columns on the S breakpoint (S2)
      DATA(ref_size_s) = 2.
      result-ref_field = |XL1 L1 M1 S2|.

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
      DATA(value_s) = |S{ layout->grid_value_s - ref_size_s }|.
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

    ASSIGN i_data->* TO FIELD-SYMBOL(<tab>).

    DATA(table) = i_xml->ele( `Table`
                      )->a( n = `growing` b = xsdbool( i_growingthreshold <> space )
                      )->a( n = `growingThreshold` v = i_growingthreshold
                      )->a( n = `width` v = `auto`
                      )->a( n = `mode` v = COND #( WHEN i_sel_mode = space THEN `None` ELSE i_sel_mode  )
                      )->a( n = `items` v = i_client->_bind( <tab> )
                      )->a( n = `selectionChange` v = i_client->_event( COND string( WHEN i_sel_event IS INITIAL
                                                                                     THEN `SELECTION_CHANGE`
                                                                                     ELSE i_sel_event ) ) ).

    " the cells below bind digit sequences with a type their row template
    " inherits from here
    IF check_digit_type( i_layout ) = abap_true.
      set_digit_type_require( table ).
    ENDIF.

    IF i_toolbar = abap_true.

      DATA(toolbar) = table->ele( `headerToolbar`
                          )->ele( `OverflowToolbar` ).

      IF i_headertext IS NOT INITIAL.
        toolbar->tag( `Title`
            )->a( n = `text` v = i_headertext
            )->a( n = `level` v = `H2` ).
      ENDIF.

      toolbar->tag( `ToolbarSpacer` ).

      IF i_search_value IS SUPPLIED.

        ASSIGN i_search_value->* TO FIELD-SYMBOL(<search>).

        toolbar->tag( `SearchField`
            )->a( n = `value` v = i_client->_bind( <search> )
            )->a( n = `search` v = i_client->_event( 'SEARCH' )
            )->a( n = `change` v = i_client->_event( 'SEARCH' )
            )->a( n = `id` v = `SEARCH`
            )->a( n = `width` v = `17.5rem` ).
      ENDIF.

      z2ui5_cl_layo_pop=>render_layout_function( client = i_client
                                                 xml    = toolbar
                                                 layout = i_layout ).

    ELSE.

      " no toolbar: the header text is the table's own, set before its first
      " child; the layout is prepared as the settings button would
      IF i_headertext IS NOT INITIAL.
        table->a( n = `headerText` v = i_headertext ).
      ENDIF.

      i_layout->prepare( ).

    ENDIF.

    DATA(columns) = table->ele( `columns` ).

    LOOP AT i_layout->ms_layout-t_layout REFERENCE INTO DATA(layout).
      DATA(lv_index) = sy-tabix.

      DATA(column) = columns->ele( `Column`
                             )->a( n = `visible` v = i_client->_bind( val       = layout->visible
                                                                      tab       = i_layout->ms_layout-t_layout
                                                                      tab_index = lv_index )
                             )->a( n = `mergeDuplicates` v = i_client->_bind( val       = layout->merge
                                                                              tab       = i_layout->ms_layout-t_layout
                                                                              tab_index = lv_index )
                             )->a( n = `width` v = i_client->_bind( val       = layout->width
                                                                    tab       = i_layout->ms_layout-t_layout
                                                                    tab_index = lv_index ) ).

      xml_build_column_header( i_client = i_client
                               i_layout = i_layout
                               position = layout
                               i_index  = lv_index
                               i_sort   = i_col_sort
                               i_class  = i_col_sort_class
                               i_column = column ).

    ENDLOOP.

    DATA(column_list_item) = columns->end(
                                 )->ele( `items`
                                 )->ele( `ColumnListItem`
                                 )->a( n = `vAlign` v = `Middle`
                                 )->a( n = `selected` v = COND #( WHEN i_sel_bind_to = space
                                                              THEN ``
                                                              ELSE |\{{ z2ui5_cl_ui5_view_builder=>component_path( i_sel_bind_to ) }\}| )
                                 )->a( n = `type` v = COND #( WHEN i_col_type = space THEN `Inactive` ELSE i_col_type  )
                                 )->a( n = `press` v = i_client->_event(
                                               val   = 'ROW_SELECT'
                                               t_arg = VALUE #( ( COND #( WHEN i_col_bind_to = space
                                                                          THEN ``
                                                                          ELSE |$\{{ z2ui5_cl_ui5_view_builder=>component_path( i_col_bind_to ) }\}| )  ) ) ) ).

    " the row colour: custom data written to the DOM of the row (tr), the
    " app's CSS colours it by the key
    IF i_row_color IS NOT INITIAL.
      column_list_item->ele( `customData`
          )->tag( n = `CustomData` ns = `core`
          )->a( n = `xmlns:core` v = `sap.ui.core`
          )->a( n = `key` v = `color`
          )->a( n = `value` v = row_color_binding( i_row_color )
          )->a( n = `writeToDom` b = abap_true ).
    ENDIF.

    DATA(cells) = column_list_item->ele( `cells` ).

    LOOP AT i_layout->ms_layout-t_layout REFERENCE INTO layout.

      DATA(control) = cell_control( rollname       = layout->rollname
                                    t_cell_control = i_t_cell_control ).

      IF i_sub_col_controls = abap_true.

        xml_build_cell_stacked( i_client         = i_client
                                i_data           = i_data
                                i_layout         = i_layout
                                position         = layout
                                i_t_cell_control = i_t_cell_control
                                i_xml            = cells ).

      ELSEIF control <> cs_cell_control-text.

        xml_build_cell_control( i_client  = i_client
                                i_data    = i_data
                                i_control = control
                                i_layout  = layout
                                i_xml     = cells ).

      ELSEIF layout->t_sub_col IS NOT INITIAL.

        cells->ele( `ObjectIdentifier`
            )->a( n = `title` v = cell_text( i_layout = i_layout
                                             position = layout->* )
            )->a( n = `text` v = sub_col_text( i_layout = i_layout
                                               position = layout->* ) ).

      ELSE.
        cells->ele( `ObjectIdentifier`
            )->a( n = `text` v = cell_text( i_layout = i_layout
                                            position = layout->* ) ).
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD on_event_column_sort.

    IF layout IS NOT BOUND OR client IS NOT BOUND.
      RETURN.
    ENDIF.

    IF client->get( )-event <> cv_event_column_sort.
      RETURN.
    ENDIF.

    " the event of another table of the same view
    IF client->get_event_arg( 1 ) <> layout->ms_layout-s_head-guid.
      RETURN.
    ENDIF.

    IF layout->toggle_sorting( client->get_event_arg( 2 ) ) = abap_false.
      RETURN.
    ENDIF.

    layout->sort( data = data ).

    result = abap_true.

  ENDMETHOD.

  METHOD xml_build_column_header.

    IF i_sort = abap_false.
      i_column->tag( `Text`
          )->a( n = `text` t = position->tlabel ).
      RETURN.
    ENDIF.

    " the standard sort icon of the column, bound to the sorting of the
    " layout - it follows the click without a new view
    i_column->a( n = `sortIndicator` v = sort_indicator( i_client->_bind( val       = position->sorting
                                                                         tab       = i_layout->ms_layout-t_layout
                                                                         tab_index = i_index
                                                                         path      = abap_true ) ) ).

    DATA(link) = i_column->ele( `Link`
                         )->a( n = `text` t = position->tlabel
                         )->a( n = `wrapping` b = abap_true
                         )->a( n = `press` v = i_client->_event( val   = cv_event_column_sort
                                                                 t_arg = VALUE #( ( CONV #( i_layout->ms_layout-s_head-guid ) )
                                                                                  ( CONV #( position->fname ) ) ) ) ).

    IF i_class IS NOT INITIAL.
      link->a( n = `class` v = i_class ).
    ENDIF.

  ENDMETHOD.

  METHOD sort_indicator.

    result = |\{= $\{{ path }\} === 'ASCENDING' ? 'Ascending' : $\{{ path }\} === 'DESCENDING' ? 'Descending' : 'None' \}|.

  ENDMETHOD.

  METHOD row_color_binding.

    " CELL_COLOR-COLOR is the level CELL_COLOR of the row and its member
    " COLOR, a namespaced /ABC/COLOR the level ABC - relative to the row
    result = |\{{ z2ui5_cl_ui5_view_builder=>component_path( replace( val  = field
                                                                       sub  = `-`
                                                                       with = `/`
                                                                       occ  = 0 ) ) }\}|.

  ENDMETHOD.

  METHOD cell_control.

    LOOP AT t_cell_control INTO DATA(entry).
      IF rollname CP entry-rollname.
        result = entry-control.
        RETURN.
      ENDIF.
    ENDLOOP.

    IF rollname CP `*_XML_S_ICON`.
      result = cs_cell_control-icon.
    ELSEIF rollname CP `*_XML_S_RADIALCHART`.
      result = cs_cell_control-radial_chart.
    ELSEIF rollname CP `*_XML_S_PROGRESSIND`.
      result = cs_cell_control-progress_ind.
    ELSEIF rollname CP `*_XML_S_STATUSIND`.
      result = cs_cell_control-status_ind.
    ELSEIF rollname CP `*_XML_S_GENERICTAG`.
      result = cs_cell_control-generic_tag.
    ELSEIF rollname CP `*_XML_S_SWITCH`.
      result = cs_cell_control-switch.
    ELSEIF rollname CP `*_XML_S_INPUT`.
      result = cs_cell_control-input.
    ELSEIF rollname CP `*_XML_S_BUTTON`.
      result = cs_cell_control-button.
    ELSE.
      result = cs_cell_control-text.
    ENDIF.

  ENDMETHOD.

  METHOD xml_build_cell_control.

    " only the controls that bind optional or alternative components look
    " at the structure
    CASE i_control.

      WHEN cs_cell_control-icon.

        xml_build_icon( i_client = i_client
                        i_layout = i_layout
                        i_xml    = i_xml
                        i_t_comp = get_t_comp( i_data = i_data
                                               fname  = i_layout->fname ) ).

      WHEN cs_cell_control-radial_chart.

        xml_build_radial_microchart( i_layout = i_layout
                                     i_client = i_client
                                     i_xml    = i_xml
                                     i_t_comp = get_t_comp( i_data = i_data
                                                            fname  = i_layout->fname ) ).

      WHEN cs_cell_control-progress_ind.

        xml_build_progress_indicator( i_layout = i_layout
                                      i_client = i_client
                                      i_xml    = i_xml ).

      WHEN cs_cell_control-status_ind.

        xml_build_status_indicator( i_layout = i_layout
                                    i_client = i_client
                                    i_xml    = i_xml
                                    i_t_comp = get_t_comp( i_data = i_data
                                                           fname  = i_layout->fname ) ).

      WHEN cs_cell_control-generic_tag.

        xml_build_generic_tag( i_layout = i_layout
                               i_client = i_client
                               i_xml    = i_xml ).

      WHEN cs_cell_control-switch.

        xml_build_switch( i_client = i_client
                          i_layout = i_layout
                          i_xml    = i_xml
                          i_t_comp = get_t_comp( i_data = i_data
                                                 fname  = i_layout->fname ) ).

      WHEN cs_cell_control-input.

        xml_build_input( i_layout = i_layout
                         i_xml    = i_xml
                         i_t_comp = get_t_comp( i_data = i_data
                                                fname  = i_layout->fname ) ).

      WHEN cs_cell_control-button.

        xml_build_button( i_client = i_client
                          i_layout = i_layout
                          i_xml    = i_xml
                          i_t_comp = get_t_comp( i_data = i_data
                                                 fname  = i_layout->fname ) ).

    ENDCASE.

  ENDMETHOD.

  METHOD xml_build_cell_stacked.

    DATA(control) = cell_control( rollname       = position->rollname
                                  t_cell_control = i_t_cell_control ).
    DATA(sub_col) = sub_col_text( i_layout         = i_layout
                                  position         = position->*
                                  skip_controls    = abap_true
                                  i_t_cell_control = i_t_cell_control ).

    " the subcolumns that are controls
    DATA t_sub_control TYPE STANDARD TABLE OF REF TO z2ui5_cl_layo_manager=>ty_s_positions WITH EMPTY KEY.
    LOOP AT position->t_sub_col INTO DATA(subcol).
      IF NOT line_exists( i_layout->ms_layout-t_layout[ fname = subcol-fname ] ).
        CONTINUE.
      ENDIF.
      DATA(line) = REF #( i_layout->ms_layout-t_layout[ fname = subcol-fname ] ).
      IF cell_control( rollname       = line->rollname
                       t_cell_control = i_t_cell_control ) <> cs_cell_control-text.
        INSERT line INTO TABLE t_sub_control.
      ENDIF.
    ENDLOOP.

    " a cell takes one control - more than one are stacked in a VBox
    DATA(cell) = i_xml.
    IF t_sub_control IS NOT INITIAL OR ( control <> cs_cell_control-text AND sub_col IS NOT INITIAL ).
      cell = i_xml->ele( `VBox` ).
    ENDIF.

    IF control <> cs_cell_control-text.

      xml_build_cell_control( i_client  = i_client
                              i_data    = i_data
                              i_control = control
                              i_layout  = position
                              i_xml     = cell ).

      IF sub_col IS NOT INITIAL.
        cell->tag( `ObjectIdentifier`
            )->a( n = `text` v = sub_col ).
      ENDIF.

    ELSEIF sub_col IS NOT INITIAL.

      cell->tag( `ObjectIdentifier`
          )->a( n = `title` v = cell_text( i_layout = i_layout
                                           position = position->* )
          )->a( n = `text` v = sub_col ).

    ELSE.

      cell->tag( `ObjectIdentifier`
          )->a( n = `text` v = cell_text( i_layout = i_layout
                                          position = position->* ) ).

    ENDIF.

    LOOP AT t_sub_control INTO line.
      xml_build_cell_control( i_client  = i_client
                              i_data    = i_data
                              i_control = cell_control( rollname       = line->rollname
                                                        t_cell_control = i_t_cell_control )
                              i_layout  = line
                              i_xml     = cell ).
    ENDLOOP.

  ENDMETHOD.

  METHOD sub_col_text.

    " the work areas of the subcolumns and reference fields
    DATA line TYPE z2ui5_cl_layo_manager=>ty_s_positions.
    DATA ref  TYPE z2ui5_cl_layo_manager=>ty_s_positions.

    LOOP AT position-t_sub_col INTO DATA(subcol).

      " a subcolumn that names no position (one added in the popup and
      " left empty, or a field the structure no longer has) is left out -
      " the work area kept the previous row and repeated it
      IF NOT line_exists( i_layout->ms_layout-t_layout[ fname = subcol-fname ] ).
        CONTINUE.
      ENDIF.
      line = i_layout->ms_layout-t_layout[ fname = subcol-fname ].

      IF skip_controls = abap_true AND cell_control( rollname       = line-rollname
                                                     t_cell_control = i_t_cell_control ) <> cs_cell_control-text.
        CONTINUE.
      ENDIF.

      " the label is literal text inside a value that carries bindings
      DATA(column) = |{ z2ui5_cl_ui5_view_builder=>escape_literal( line-tlabel ) }: { table_value_formatter( line ) }|.

      " a reference field that is no column is left out - a failed READ
      " kept the previous one in the work area
      IF     line-reference_field IS NOT INITIAL
         AND line_exists( i_layout->ms_layout-t_layout[ fname = line-reference_field ] ).
        ref = i_layout->ms_layout-t_layout[ fname = line-reference_field ].
        column = |{ column } { table_value_formatter( ref ) }|.
      ENDIF.

      IF result IS INITIAL.
        result = column.
      ELSE.
        result = |{ result }{ cl_abap_char_utilities=>cr_lf }{ column }|.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD get_t_comp.

    TRY.
        DATA(t_attri) = z2ui5_cl_layo_context=>rtti_get_t_attri_by_any( i_data ).
        IF NOT line_exists( t_attri[ name = fname ] ).
          RETURN.
        ENDIF.
        DATA(attri) = t_attri[ name = fname ].
        IF attri-type->kind <> cl_abap_typedescr=>kind_struct.
          RETURN.
        ENDIF.
        DATA(struct) = CAST cl_abap_structdescr( attri-type ).
        LOOP AT struct->components INTO DATA(comp).
          INSERT CONV string( comp-name ) INTO TABLE result.
        ENDLOOP.
      CATCH cx_root.
        CLEAR result.
    ENDTRY.

  ENDMETHOD.

  METHOD comp_name.

    result = primary.

    IF t_comp IS INITIAL OR alternative IS INITIAL.
      RETURN.
    ENDIF.

    IF line_exists( t_comp[ table_line = primary ] ).
      RETURN.
    ENDIF.

    IF line_exists( t_comp[ table_line = alternative ] ).
      result = alternative.
    ENDIF.

  ENDMETHOD.

  METHOD has_comp.

    result = xsdbool( t_comp IS INITIAL OR line_exists( t_comp[ table_line = name ] ) ).

  ENDMETHOD.

  METHOD has_comp_strict.

    result = xsdbool( line_exists( t_comp[ table_line = name ] ) ).

  ENDMETHOD.

  METHOD row_event.

    " the framework writes the wire - its function and how it passes an
    " argument; only the quoted name is replaced by the binding of the row's
    " event name, which the framework cannot write
    CONSTANTS placeholder TYPE string VALUE `LAYO_ROW_EVENT`.

    DATA t_arg TYPE string_table.

    IF has_comp( t_comp = t_comp
                 name   = value ) = abap_true.
      INSERT |$\{{ path }/{ value }\}| INTO TABLE t_arg.
    ENDIF.

    result = i_client->_event( val   = placeholder
                               t_arg = t_arg ).

    result = replace( val  = result
                      sub  = |'{ placeholder }'|
                      with = |$\{{ path }/{ event }\}| ).

  ENDMETHOD.

  METHOD xml_build_switch.

    " declared, not inline: the 702 downport needs the type
    DATA path TYPE string.
    path = z2ui5_cl_ui5_view_builder=>component_path( i_layout->fname ).

    DATA(switch) = i_xml->ele( `Switch` ).

    IF has_comp( t_comp = i_t_comp name = `STATE` ) = abap_true.
      switch->a( n = `state` v = |\{{ path }/STATE\}| ).
    ENDIF.
    IF has_comp( t_comp = i_t_comp name = `CUSTOMTEXTON` ) = abap_true.
      switch->a( n = `customTextOn` v = |\{{ path }/CUSTOMTEXTON\}| ).
    ENDIF.
    IF has_comp( t_comp = i_t_comp name = `CUSTOMTEXTOFF` ) = abap_true.
      switch->a( n = `customTextOff` v = |\{{ path }/CUSTOMTEXTOFF\}| ).
    ENDIF.
    IF has_comp( t_comp = i_t_comp name = `ENABLED` ) = abap_true.
      switch->a( n = `enabled` v = |\{{ path }/ENABLED\}| ).
    ENDIF.
    IF has_comp( t_comp = i_t_comp name = `TYPE` ) = abap_true.
      " an empty TYPE is no value of the enum - UI5 rejects it and the view breaks
      switch->a( n = `type` v = |\{= $\{{ path }/TYPE\} \|\| 'Default' \}| ).
    ENDIF.
    IF has_comp( t_comp = i_t_comp name = `CHANGE` ) = abap_true.
      switch->a( n = `change` v = row_event( i_client = i_client
                                             path     = path
                                             event    = `CHANGE`
                                             value    = `CHANGE_VALUE`
                                             t_comp   = i_t_comp ) ).
    ENDIF.

  ENDMETHOD.

  METHOD xml_build_input.

    " declared, not inline: the 702 downport needs the type
    DATA path TYPE string.
    path = z2ui5_cl_ui5_view_builder=>component_path( i_layout->fname ).

    DATA(input) = i_xml->ele( `Input` ).

    IF has_comp( t_comp = i_t_comp name = `VALUE` ) = abap_true.
      input->a( n = `value` v = |\{{ path }/VALUE\}| ).
    ENDIF.
    IF has_comp( t_comp = i_t_comp name = `PLACEHOLDER` ) = abap_true.
      input->a( n = `placeholder` v = |\{{ path }/PLACEHOLDER\}| ).
    ENDIF.
    IF has_comp( t_comp = i_t_comp name = `ENABLED` ) = abap_true.
      input->a( n = `enabled` v = |\{{ path }/ENABLED\}| ).
    ENDIF.
    IF has_comp( t_comp = i_t_comp name = `EDITABLE` ) = abap_true.
      input->a( n = `editable` v = |\{{ path }/EDITABLE\}| ).
    ENDIF.
    IF has_comp( t_comp = i_t_comp name = `VISIBLE` ) = abap_true.
      input->a( n = `visible` v = |\{{ path }/VISIBLE\}| ).
    ENDIF.

  ENDMETHOD.

  METHOD xml_build_button.

    " declared, not inline: the 702 downport needs the type
    DATA path TYPE string.
    path = z2ui5_cl_ui5_view_builder=>component_path( i_layout->fname ).

    DATA(button) = i_xml->ele( `Button` ).

    IF has_comp( t_comp = i_t_comp name = `TEXT` ) = abap_true.
      button->a( n = `text` v = |\{{ path }/TEXT\}| ).
    ENDIF.
    IF has_comp( t_comp = i_t_comp name = `ICON` ) = abap_true.
      button->a( n = `icon` v = |\{{ path }/ICON\}| ).
    ENDIF.
    IF has_comp( t_comp = i_t_comp name = `TYPE` ) = abap_true.
      " an empty TYPE is no value of the enum - UI5 rejects it and the view breaks
      button->a( n = `type` v = |\{= $\{{ path }/TYPE\} \|\| 'Default' \}| ).
    ENDIF.
    IF has_comp( t_comp = i_t_comp name = `PRESS` ) = abap_true.
      button->a( n = `press` v = row_event( i_client = i_client
                                            path     = path
                                            event    = `PRESS`
                                            value    = `PRESS_VALUE`
                                            t_comp   = i_t_comp ) ).
    ENDIF.

  ENDMETHOD.

  METHOD cell_text.

    result = table_value_formatter( position ).

    IF position-reference_field IS INITIAL.
      RETURN.
    ENDIF.

    " a reference field that is no column is left out - a failed READ kept
    " the previous one in the work area
    IF line_exists( i_layout->ms_layout-t_layout[ fname = position-reference_field ] ).
      DATA(ref) = i_layout->ms_layout-t_layout[ fname = position-reference_field ].
      result = |{ result } { table_value_formatter( ref ) }|.
    ENDIF.

  ENDMETHOD.

  METHOD table_value_formatter.

    DATA path TYPE string.

    " relative to the row: a namespaced column (/CWM/XCWMAT) is a level of
    " the row in the model, {CWM/XCWMAT} - {/CWM/XCWMAT} would be absolute
    path = z2ui5_cl_ui5_view_builder=>component_path( position-fname ).

    IF z2ui5_cl_layo_manager=>digit_type( position ) = abap_true.
      " 000000004711 shown as 4711 by the browser, the data stays internal
      result = z2ui5_cl_layo_manager=>digit_type_binding( path     = path
                                                          position = position ).
    ELSE.
      result = |\{{ path }\}|.
    ENDIF.

  ENDMETHOD.

  METHOD set_digit_type_require.

    i_xml->a( n = `xmlns:core` v = `sap.ui.core`
        )->a( n = `core:require` v = z2ui5_cl_layo_manager=>digit_type_require( ) ).

  ENDMETHOD.

  METHOD check_digit_type.

    LOOP AT i_layout->ms_layout-t_layout INTO DATA(position).
      IF z2ui5_cl_layo_manager=>digit_type( position ) = abap_true.
        result = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD xml_build_icon.

    " declared, not inline: the 702 downport needs the type
    DATA path TYPE string.

    " Table case
    IF i_data IS NOT SUPPLIED.

      path = z2ui5_cl_ui5_view_builder=>component_path( i_layout->fname ).

      " ICON_SIZE of z2ui5_xml_s_icon, or SIZE; COLOR and the event PRESS /
      " PRESS_VALUE when the structure has them
      DATA(icon) = i_xml->ele( n = `Icon` ns = `core`
                       )->a( n = `src` v = |\{{ path }/SRC\}|
                       )->a( n = `size` v = |\{{ path }/{ comp_name( t_comp      = i_t_comp
                                                                      primary     = `ICON_SIZE`
                                                                      alternative = `SIZE` ) }\}| ).

      IF has_comp_strict( t_comp = i_t_comp name = `COLOR` ) = abap_true.
        icon->a( n = `color` v = |\{{ path }/COLOR\}| ).
      ENDIF.

      IF has_comp_strict( t_comp = i_t_comp name = `PRESS` ) = abap_true.
        icon->a( n = `press` v = row_event( i_client = i_client
                                            path     = path
                                            event    = `PRESS`
                                            value    = `PRESS_VALUE`
                                            t_comp   = i_t_comp ) ).
      ENDIF.

    ELSE.

      ASSIGN i_data->* TO FIELD-SYMBOL(<data>).

      ASSIGN COMPONENT |{ i_layout->fname }-SRC| OF STRUCTURE <data> TO FIELD-SYMBOL(<src>).
      IF <src> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      ASSIGN COMPONENT |{ i_layout->fname }-ICON_SIZE| OF STRUCTURE <data> TO FIELD-SYMBOL(<size>).
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

    " Table case
    IF i_data IS NOT SUPPLIED.

      i_xml->tag( n = `RadialMicroChart` ns = `mchart`
          )->a( n = `size` v = |\{{ z2ui5_cl_ui5_view_builder=>component_path( i_layout->fname ) }/{ comp_name( t_comp      = i_t_comp
                                                                                                                  primary     = `RADIALMICROCHART_SIZE`
                                                                                                                  alternative = `SIZE` ) }\}|
          )->a( n = `percentage` v = |\{{ z2ui5_cl_ui5_view_builder=>component_path( i_layout->fname ) }/PERCENTAGE\}|
          )->a( n = `valueColor` v = |\{{ z2ui5_cl_ui5_view_builder=>component_path( i_layout->fname ) }/VALUECOLOR\}|
          )->a( n = `hideOnNoData` v = |\{{ z2ui5_cl_ui5_view_builder=>component_path( i_layout->fname ) }/HIDEONNODATA\}| ).

    ELSE.

      ASSIGN i_data->* TO FIELD-SYMBOL(<data>).

      ASSIGN COMPONENT |{ i_layout->fname }-RADIALMICROCHART_SIZE| OF STRUCTURE <data> TO FIELD-SYMBOL(<size>).
      IF <size> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      ASSIGN COMPONENT |{ i_layout->fname }-PERCENTAGE| OF STRUCTURE <data> TO FIELD-SYMBOL(<percentage>).
      IF <percentage> IS NOT ASSIGNED.
        RETURN.
      ENDIF.
      ASSIGN COMPONENT |{ i_layout->fname }-VALUECOLOR| OF STRUCTURE <data> TO FIELD-SYMBOL(<valuecolor>).
      IF <valuecolor> IS NOT ASSIGNED.
        RETURN.
      ENDIF.
      ASSIGN COMPONENT |{ i_layout->fname }-HIDEONNODATA| OF STRUCTURE <data> TO FIELD-SYMBOL(<hideonnodata>).
      IF <hideonnodata> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      i_xml->tag( n = `RadialMicroChart` ns = `mchart`
          )->a( n = `size` v = i_client->_bind( val = <size> )
          )->a( n = `percentage` v = i_client->_bind( val = <percentage> )
          )->a( n = `valueColor` v = i_client->_bind( val = <valuecolor> )
          )->a( n = `hideOnNoData` v = i_client->_bind( val = <hideonnodata> ) ).

    ENDIF.

    result = i_xml.

  ENDMETHOD.

  METHOD xml_build_progress_indicator.

    " Table case
    IF i_data IS NOT SUPPLIED.

      i_xml->tag( `ProgressIndicator`
          )->a( n = `class` v = `sapUiSmallMarginBottom`
          )->a( n = `percentValue` v = |\{{ z2ui5_cl_ui5_view_builder=>component_path( i_layout->fname ) }/PERCENTVALUE\}|
          )->a( n = `displayValue` v = |\{{ z2ui5_cl_ui5_view_builder=>component_path( i_layout->fname ) }/DISPLAYVALUE\}|
          )->a( n = `showValue` v = |\{{ z2ui5_cl_ui5_view_builder=>component_path( i_layout->fname ) }/SHOWVALUE\}|
          )->a( n = `state` v = |\{{ z2ui5_cl_ui5_view_builder=>component_path( i_layout->fname ) }/STATE\}| ).

    ELSE.

      ASSIGN i_data->* TO FIELD-SYMBOL(<data>).

      ASSIGN COMPONENT |{ i_layout->fname }-PERCENTVALUE| OF STRUCTURE <data> TO FIELD-SYMBOL(<percentvalue>).
      IF <percentvalue> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      ASSIGN COMPONENT |{ i_layout->fname }-DISPLAYVALUE| OF STRUCTURE <data> TO FIELD-SYMBOL(<displayvalue>).
      IF <displayvalue> IS NOT ASSIGNED.
        RETURN.
      ENDIF.
      ASSIGN COMPONENT |{ i_layout->fname }-SHOWVALUE| OF STRUCTURE <data> TO FIELD-SYMBOL(<showvalue>).
      IF <showvalue> IS NOT ASSIGNED.
        RETURN.
      ENDIF.
      ASSIGN COMPONENT |{ i_layout->fname }-STATE| OF STRUCTURE <data> TO FIELD-SYMBOL(<state>).
      IF <state> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

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

    " We want to build a Table!
    IF i_data IS NOT SUPPLIED.

      DATA(status_indicator) = i_xml->ele( n = `StatusIndicator` ns = `si`
                                   )->a( n = `class` v = |\{{ z2ui5_cl_ui5_view_builder=>component_path( i_layout->fname ) }/CLASS\}|
                                   )->a( n = `size` v = |\{{ z2ui5_cl_ui5_view_builder=>component_path( i_layout->fname ) }/{ comp_name( t_comp      = i_t_comp
                                                                                                                                    primary     = `STATUSINDICATOR_SIZE`
                                                                                                                                    alternative = `SIZE` ) }\}|
                                   )->a( n = `value` v = |\{{ z2ui5_cl_ui5_view_builder=>component_path( i_layout->fname ) }/VALUE\}| ).

      DATA(thresholds) = status_indicator->ele( n = `propertyThresholds` ns = `si` ).

      thresholds->ele( n = `PropertyThreshold` ns = `si`
          )->a( n = `fillColor` v = `Good`
          )->a( n = `toValue` v = |\{{ z2ui5_cl_ui5_view_builder=>component_path( i_layout->fname ) }/FILLCOLOR_GOOD\}| ).

      thresholds->ele( n = `PropertyThreshold` ns = `si`
          )->a( n = `fillColor` v = `Critical`
          )->a( n = `toValue` v = |\{{ z2ui5_cl_ui5_view_builder=>component_path( i_layout->fname ) }/FILLCOLOR_CRITICAL\}| ).

      thresholds->ele( n = `PropertyThreshold` ns = `si`
          )->a( n = `fillColor` v = `Error`
          )->a( n = `toValue` v = |\{{ z2ui5_cl_ui5_view_builder=>component_path( i_layout->fname ) }/FILLCOLOR_ERROR\}| ).

      status_indicator->ele( n = `ShapeGroup` ns = `si`
          )->ele( n = `LibraryShape` ns = `si`
          )->a( n = `shapeId` v = |\{{ z2ui5_cl_ui5_view_builder=>component_path( i_layout->fname ) }/SHAPEID\}| ).

    ELSE.

      ASSIGN i_data->* TO FIELD-SYMBOL(<data>).

      ASSIGN COMPONENT |{ i_layout->fname }-VALUE| OF STRUCTURE <data> TO FIELD-SYMBOL(<value>).
      IF <value> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      ASSIGN COMPONENT |{ i_layout->fname }-CLASS| OF STRUCTURE <data> TO FIELD-SYMBOL(<class>).
      IF <class> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      ASSIGN COMPONENT |{ i_layout->fname }-STATUSINDICATOR_SIZE| OF STRUCTURE <data> TO FIELD-SYMBOL(<size>).
      IF <size> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      status_indicator = i_xml->ele( n = `StatusIndicator` ns = `si`
                             )->a( n = `class` v = i_client->_bind( val = <class> )
                             )->a( n = `size` v = i_client->_bind( val = <size> )
                             )->a( n = `value` v = i_client->_bind( val = <value> )
                             )->a( n = `visible` b = i_layout->visible ).

      thresholds = status_indicator->ele( n = `propertyThresholds` ns = `si` ).

      ASSIGN COMPONENT |{ i_layout->fname }-FILLCOLOR_GOOD| OF STRUCTURE <data> TO FIELD-SYMBOL(<fillcolor_good>).
      IF <fillcolor_good> IS NOT ASSIGNED.
        RETURN.
      ENDIF.
      ASSIGN COMPONENT |{ i_layout->fname }-FILLCOLOR_CRITICAL| OF STRUCTURE <data> TO FIELD-SYMBOL(<fillcolor_critical>).
      IF <fillcolor_critical> IS NOT ASSIGNED.
        RETURN.
      ENDIF.
      ASSIGN COMPONENT |{ i_layout->fname }-FILLCOLOR_ERROR| OF STRUCTURE <data> TO FIELD-SYMBOL(<fillcolor_error>).
      IF <fillcolor_error> IS NOT ASSIGNED.
        RETURN.
      ENDIF.
      ASSIGN COMPONENT |{ i_layout->fname }-SHAPEID| OF STRUCTURE <data> TO FIELD-SYMBOL(<shapeid>).
      IF <shapeid> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      thresholds->ele( n = `PropertyThreshold` ns = `si`
          )->a( n = `fillColor` v = `Good`
          )->a( n = `toValue` v = i_client->_bind( val = <fillcolor_good> ) ).

      thresholds->ele( n = `PropertyThreshold` ns = `si`
          )->a( n = `fillColor` v = `Critical`
          )->a( n = `toValue` v = i_client->_bind( val = <fillcolor_critical> ) ).

      thresholds->ele( n = `PropertyThreshold` ns = `si`
          )->a( n = `fillColor` v = `Error`
          )->a( n = `toValue` v = i_client->_bind( val = <fillcolor_error> ) ).

      status_indicator->ele( n = `ShapeGroup` ns = `si`
          )->ele( n = `LibraryShape` ns = `si`
          )->a( n = `shapeId` v = i_client->_bind( val = <shapeid> ) ).

    ENDIF.

    result = i_xml.

  ENDMETHOD.

  METHOD xml_build_generic_tag.

    " Table case
    IF i_data IS NOT SUPPLIED.

      i_xml->ele( `GenericTag`
          )->a( n = `text` v = |\{{ z2ui5_cl_ui5_view_builder=>component_path( i_layout->fname ) }/TEXT\}|
          )->a( n = `design` v = |\{{ z2ui5_cl_ui5_view_builder=>component_path( i_layout->fname ) }/DESIGN\}|
          )->a( n = `status` v = |\{{ z2ui5_cl_ui5_view_builder=>component_path( i_layout->fname ) }/STATUS\}| ).

    ELSE.

      ASSIGN i_data->* TO FIELD-SYMBOL(<data>).

      ASSIGN COMPONENT |{ i_layout->fname }-TEXT| OF STRUCTURE <data> TO FIELD-SYMBOL(<text>).
      IF <text> IS NOT ASSIGNED.
        RETURN.
      ENDIF.

      ASSIGN COMPONENT |{ i_layout->fname }-DESIGN| OF STRUCTURE <data> TO FIELD-SYMBOL(<design>).
      IF <design> IS NOT ASSIGNED.
        RETURN.
      ENDIF.
      ASSIGN COMPONENT |{ i_layout->fname }-STATUS| OF STRUCTURE <data> TO FIELD-SYMBOL(<status>).
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

    IF z2ui5_cl_layo_manager=>digit_type( position ) = abap_true.
      result = z2ui5_cl_layo_manager=>digit_type_binding( path     = i_client->_bind_path( value )
                                                          position = position ).
    ELSE.
      result = i_client->_bind( value ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
