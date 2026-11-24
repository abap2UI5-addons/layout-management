" the app a table is rendered for: the client binds the table and the
" layout as its public attributes
CLASS ltcl_app DEFINITION FINAL FOR TESTING.
  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_row,
        vbeln    TYPE c LENGTH 10,
        matnr    TYPE c LENGTH 18,
        menge    TYPE p LENGTH 13 DECIMALS 3,
        meins    TYPE c LENGTH 3,
        icon     TYPE z2ui5_xml_s_icon,
        tag      TYPE z2ui5_xml_s_generictag,
        progress TYPE z2ui5_xml_s_progressind,
        radial   TYPE z2ui5_xml_s_radialchart,
        status   TYPE z2ui5_xml_s_statusind,
        selkz    TYPE abap_bool,
      END OF ty_s_row.

    DATA mt_data   TYPE STANDARD TABLE OF ty_s_row WITH EMPTY KEY.
    DATA mv_search TYPE string.
    DATA mo_layout TYPE REF TO z2ui5_cl_layo_manager.
ENDCLASS.

CLASS ltcl_app IMPLEMENTATION.
  METHOD z2ui5_if_app~main ##NEEDED.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_xml_builder DEFINITION DEFERRED.
CLASS z2ui5_cl_layo_xml_builder DEFINITION LOCAL FRIENDS ltcl_xml_builder.

CLASS ltcl_xml_builder DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS cell_plain_name FOR TESTING.
    METHODS cell_namespaced_name FOR TESTING.
    METHODS icon_namespaced_name FOR TESTING.
    METHODS cell_alpha_digit_type FOR TESTING.
    METHODS cell_numc_namespaced FOR TESTING.
    METHODS cell_conversion_switched_off FOR TESTING.
    METHODS cell_other_exit_plain FOR TESTING.
    METHODS require_on_control FOR TESTING.
    METHODS require_only_with_digits FOR TESTING.
    METHODS table_unchanged FOR TESTING.
    METHODS table_unchanged_options FOR TESTING.

    DATA mo_app    TYPE REF TO ltcl_app.
    DATA mi_client TYPE REF TO z2ui5_if_client.
    DATA mo_action TYPE REF TO z2ui5_cl_ui5_action.

    METHODS setup.

    "! a client of the framework for the app
    METHODS client_for
      IMPORTING
        app TYPE REF TO z2ui5_if_app.

    "! the table with the parameters every caller had so far
    METHODS render_table
      IMPORTING
        i_options     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result) TYPE string.

    "! the table as it is rendered today - the output every existing caller
    "! keeps
    METHODS golden_default
      RETURNING
        VALUE(result) TYPE string.

    METHODS golden_options
      RETURNING
        VALUE(result) TYPE string.
ENDCLASS.


CLASS ltcl_xml_builder IMPLEMENTATION.

  METHOD cell_plain_name.

    cl_abap_unit_assert=>assert_equals(
        exp = `{MATNR}`
        act = z2ui5_cl_layo_xml_builder=>table_value_formatter( VALUE #( fname = `MATNR` ) ) ).

  ENDMETHOD.

  METHOD cell_namespaced_name.

    " the model writes /CWM/XCWMAT as a level of the row - a relative path,
    " never {/CWM/XCWMAT}, which UI5 reads from the model root
    cl_abap_unit_assert=>assert_equals(
        exp = `{CWM/XCWMAT}`
        act = z2ui5_cl_layo_xml_builder=>table_value_formatter( VALUE #( fname = `/CWM/XCWMAT` ) ) ).

  ENDMETHOD.

  METHOD icon_namespaced_name.

    " the table case renders bindings only - it reads nothing from the client
    DATA client TYPE REF TO z2ui5_if_client.

    DATA position TYPE z2ui5_cl_layo_manager=>ty_s_positions.
    position-fname = `/CWM/ICON`.
    DATA(view) = z2ui5_cl_ui5_view_builder=>factory( ).

    z2ui5_cl_layo_xml_builder=>xml_build_icon( i_client = client
                                               i_layout = REF #( position )
                                               i_xml    = view ).

    DATA(xml) = view->stringify( ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*src="{CWM/ICON/SRC}"*`
                                         act = xml ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*size="{CWM/ICON/ICON_SIZE}"*`
                                         act = xml ).

  ENDMETHOD.

  METHOD cell_alpha_digit_type.

    " ALPHA on a CHAR column: the browser strips and pads the zeros
    cl_abap_unit_assert=>assert_equals(
        exp = `{path:'VBELN',type:'LayoDigitString',constraints:{isDigitSequence:true,maxLength:10}}`
        act = z2ui5_cl_layo_xml_builder=>table_value_formatter( VALUE #( fname    = `VBELN`
                                                                         convexit = `ALPHA`
                                                                         digits   = 10 ) ) ).

  ENDMETHOD.

  METHOD cell_numc_namespaced.

    cl_abap_unit_assert=>assert_equals(
        exp = `{path:'CWM/NR',type:'LayoDigitString',constraints:{isDigitSequence:true,maxLength:8}}`
        act = z2ui5_cl_layo_xml_builder=>table_value_formatter( VALUE #( fname    = `/CWM/NR`
                                                                         convexit = `NUMC`
                                                                         digits   = 8 ) ) ).

  ENDMETHOD.

  METHOD cell_conversion_switched_off.

    " the user switched the conversion off in the layout popup
    cl_abap_unit_assert=>assert_equals(
        exp = `{VBELN}`
        act = z2ui5_cl_layo_xml_builder=>table_value_formatter( VALUE #( fname       = `VBELN`
                                                                         convexit    = `ALPHA`
                                                                         digits      = 10
                                                                         no_convexit = abap_true ) ) ).

  ENDMETHOD.

  METHOD cell_other_exit_plain.

    " CUNIT, MATN1, ... stay a conversion in ABAP - a plain binding
    cl_abap_unit_assert=>assert_equals(
        exp = `{MATNR}`
        act = z2ui5_cl_layo_xml_builder=>table_value_formatter( VALUE #( fname    = `MATNR`
                                                                         convexit = `MATN1` ) ) ).

  ENDMETHOD.

  METHOD require_on_control.

    DATA(view) = z2ui5_cl_ui5_view_builder=>factory( ).
    DATA(table) = view->ele( `Table` ).

    z2ui5_cl_layo_xml_builder=>set_digit_type_require( table ).

    DATA(xml) = view->stringify( ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*xmlns:core="sap.ui.core"*`
                                         act = xml ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*core:require="{LayoDigitString:*sap/ui/model/odata/type/String*}"*`
                                         act = xml ).

  ENDMETHOD.

  METHOD require_only_with_digits.

    DATA(layout) = NEW z2ui5_cl_layo_manager( ).
    layout->ms_layout-t_layout = VALUE #( ( fname = `MATNR` convexit = `MATN1` )
                                          ( fname = `VBELN` convexit = `ALPHA` digits = 10 no_convexit = abap_true ) ).

    cl_abap_unit_assert=>assert_false( z2ui5_cl_layo_xml_builder=>check_digit_type( layout ) ).

    layout->ms_layout-t_layout[ 2 ]-no_convexit = abap_false.

    cl_abap_unit_assert=>assert_true( z2ui5_cl_layo_xml_builder=>check_digit_type( layout ) ).

  ENDMETHOD.

  METHOD setup.

    mo_app = NEW #( ).
    mo_app->mt_data = VALUE #( ( vbeln = `4711` matnr = `M1` menge = 1 meins = `ST` ) ).

    mo_app->mo_layout = NEW #( ).
    mo_app->mo_layout->ms_layout-s_head-guid = `GUID1`.
    mo_app->mo_layout->ms_layout-t_layout = VALUE #(
        ( fname = `VBELN` rollname = `VBELN` visible = abap_true tlabel = `Order` convexit = `ALPHA` digits = 10
          t_sub_col = VALUE #( ( fname = `MATNR` ) ( fname = `MENGE` ) ( fname = `ICON` ) ) )
        ( fname = `MATNR` rollname = `MATNR` visible = abap_true tlabel = `Material` )
        ( fname = `MENGE` rollname = `MENGE` visible = abap_true tlabel = `Qty` reference_field = `MEINS` )
        ( fname = `MEINS` rollname = `MEINS` tlabel = `Unit` )
        ( fname = `ICON` rollname = `Z2UI5_XML_S_ICON` visible = abap_true tlabel = `Icon`
          t_sub_col = VALUE #( ( fname = `MATNR` ) ) )
        ( fname = `TAG` rollname = `Z2UI5_XML_S_GENERICTAG` tlabel = `Tag` )
        ( fname = `PROGRESS` rollname = `Z2UI5_XML_S_PROGRESSIND` tlabel = `Progress` )
        ( fname = `RADIAL` rollname = `Z2UI5_XML_S_RADIALCHART` tlabel = `Radial` )
        ( fname = `STATUS` rollname = `Z2UI5_XML_S_STATUSIND` tlabel = `Status` )
        ( fname = `SELKZ` rollname = `XSDBOOLEAN` tlabel = `Sel` ) ).

    client_for( mo_app ).

  ENDMETHOD.

  METHOD client_for.

    mo_action = NEW #( val = NEW z2ui5_cl_ui5_handler( val = `` ) ).
    mo_action->mo_app->mo_app = app.
    mi_client = NEW z2ui5_cl_ui5_client( action = mo_action ).

  ENDMETHOD.

  METHOD render_table.

    DATA(view) = z2ui5_cl_ui5_view_builder=>factory( ).

    IF i_options = abap_false.
      z2ui5_cl_layo_xml_builder=>xml_build_table( i_data   = REF #( mo_app->mt_data )
                                                  i_xml    = view
                                                  i_client = mi_client
                                                  i_layout = mo_app->mo_layout ).
    ELSE.
      z2ui5_cl_layo_xml_builder=>xml_build_table( i_data             = REF #( mo_app->mt_data )
                                                  i_xml              = view
                                                  i_client           = mi_client
                                                  i_layout           = mo_app->mo_layout
                                                  i_search_value     = REF #( mo_app->mv_search )
                                                  i_growingthreshold = `50`
                                                  i_headertext       = `Orders`
                                                  i_sel_mode         = `MultiSelect`
                                                  i_sel_bind_to      = `SELKZ`
                                                  i_col_type         = `Active`
                                                  i_col_bind_to      = `VBELN` ).
    ENDIF.

    result = view->stringify( ).

  ENDMETHOD.

  METHOD table_unchanged.

    cl_abap_unit_assert=>assert_equals( exp = golden_default( )
                                        act = render_table( ) ).

  ENDMETHOD.

  METHOD table_unchanged_options.

    cl_abap_unit_assert=>assert_equals( exp = golden_options( )
                                        act = render_table( abap_true ) ).

  ENDMETHOD.

  METHOD golden_default.

    result = `<Table growing="false" growingThreshold="" width="auto" mode="None" items="{/MT_DATA}" sel`
          && `ectionChange=".eB(['SELECTION_CHANGE'])" xmlns:core="sap.ui.core" core:require="{LayoDigit`
          && `String:'sap/ui/model/odata/type/String'}"><headerToolbar><OverflowToolbar><ToolbarSpacer/>`
          && `<Button icon="sap-icon://action-settings" press=".eB(['GUID1'])"/></OverflowToolbar></head`
          && `erToolbar><columns><Column visible="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/0/VISIBLE}" mergeDuplic`
          && `ates="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/0/MERGE}" width="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/0/WID`
          && `TH}"><Text text="Order"/></Column><Column visible="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/1/VISIBL`
          && `E}" mergeDuplicates="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/1/MERGE}" width="{/MO_LAYOUT/MS_LAYOUT`
          && `/T_LAYOUT/1/WIDTH}"><Text text="Material"/></Column><Column visible="{/MO_LAYOUT/MS_LAYOUT`
          && `/T_LAYOUT/2/VISIBLE}" mergeDuplicates="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/2/MERGE}" width="{/M`
          && `O_LAYOUT/MS_LAYOUT/T_LAYOUT/2/WIDTH}"><Text text="Qty"/></Column><Column visible="{/MO_LAY`
          && `OUT/MS_LAYOUT/T_LAYOUT/3/VISIBLE}" mergeDuplicates="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/3/MERGE`
          && `}" width="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/3/WIDTH}"><Text text="Unit"/></Column><Column vis`
          && `ible="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/4/VISIBLE}" mergeDuplicates="{/MO_LAYOUT/MS_LAYOUT/T_`
          && `LAYOUT/4/MERGE}" width="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/4/WIDTH}"><Text text="Icon"/></Colu`
          && `mn><Column visible="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/5/VISIBLE}" mergeDuplicates="{/MO_LAYOU`
          && `T/MS_LAYOUT/T_LAYOUT/5/MERGE}" width="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/5/WIDTH}"><Text text=`
          && `"Tag"/></Column><Column visible="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/6/VISIBLE}" mergeDuplicate`
          && `s="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/6/MERGE}" width="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/6/WIDTH}`
          && `"><Text text="Progress"/></Column><Column visible="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/7/VISIBL`
          && `E}" mergeDuplicates="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/7/MERGE}" width="{/MO_LAYOUT/MS_LAYOUT`
          && `/T_LAYOUT/7/WIDTH}"><Text text="Radial"/></Column><Column visible="{/MO_LAYOUT/MS_LAYOUT/T`
          && `_LAYOUT/8/VISIBLE}" mergeDuplicates="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/8/MERGE}" width="{/MO_`
          && `LAYOUT/MS_LAYOUT/T_LAYOUT/8/WIDTH}"><Text text="Status"/></Column><Column visible="{/MO_LA`
          && `YOUT/MS_LAYOUT/T_LAYOUT/9/VISIBLE}" mergeDuplicates="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/9/MERG`
          && `E}" width="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/9/WIDTH}"><Text text="Sel"/></Column></columns><`
          && `items><ColumnListItem vAlign="Middle" selected="" type="Inactive" press=".eB(['ROW_SELECT'`
          && `])"><cells><ObjectIdentifier title="{path:'VBELN',type:'LayoDigitString',constraints:{isDi`
          && `gitSequence:true,maxLength:10}}" text="Material: {MATNR}&#xD;&#xA;Qty: {MENGE} {MEINS}&#xD`
          && `;&#xA;Icon: {ICON}"/><ObjectIdentifier text="{MATNR}"/><ObjectIdentifier text="{MENGE} {ME`
          && `INS}"/><ObjectIdentifier text="{MEINS}"/><core:Icon src="{ICON/SRC}" size="{ICON/ICON_SIZE`
          && `}"/><GenericTag text="{TAG/TEXT}" design="{TAG/DESIGN}" status="{TAG/STATUS}"/><ProgressIn`
          && `dicator class="sapUiSmallMarginBottom" percentValue="{PROGRESS/PERCENTVALUE}" displayValue`
          && `="{PROGRESS/DISPLAYVALUE}" showValue="{PROGRESS/SHOWVALUE}" state="{PROGRESS/STATE}"/><mch`
          && `art:RadialMicroChart size="{RADIAL/RADIALMICROCHART_SIZE}" percentage="{RADIAL/PERCENTAGE}`
          && `" valueColor="{RADIAL/VALUECOLOR}" hideOnNoData="{RADIAL/HIDEONNODATA}"/><si:StatusIndicat`
          && `or class="{STATUS/CLASS}" size="{STATUS/STATUSINDICATOR_SIZE}" value="{STATUS/VALUE}"><si:`
          && `propertyThresholds><si:PropertyThreshold fillColor="Good" toValue="{STATUS/FILLCOLOR_GOOD}`
          && `"/><si:PropertyThreshold fillColor="Critical" toValue="{STATUS/FILLCOLOR_CRITICAL}"/><si:P`
          && `ropertyThreshold fillColor="Error" toValue="{STATUS/FILLCOLOR_ERROR}"/></si:propertyThresh`
          && `olds><si:ShapeGroup><si:LibraryShape shapeId="{STATUS/SHAPEID}"/></si:ShapeGroup></si:Stat`
          && `usIndicator><ObjectIdentifier text="{SELKZ}"/></cells></ColumnListItem></items></Table>`.

  ENDMETHOD.

  METHOD golden_options.

    result = `<Table growing="true" growingThreshold="50" width="auto" mode="MultiSelect" items="{/MT_DA`
          && `TA}" selectionChange=".eB(['SELECTION_CHANGE'])" xmlns:core="sap.ui.core" core:require="{L`
          && `ayoDigitString:'sap/ui/model/odata/type/String'}"><headerToolbar><OverflowToolbar><Title t`
          && `ext="Orders" level="H2"/><ToolbarSpacer/><SearchField value="{/MV_SEARCH}" search=".eB(['S`
          && `EARCH'])" change=".eB(['SEARCH'])" id="SEARCH" width="17.5rem"/><Button icon="sap-icon://a`
          && `ction-settings" press=".eB(['GUID1'])"/></OverflowToolbar></headerToolbar><columns><Column`
          && ` visible="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/0/VISIBLE}" mergeDuplicates="{/MO_LAYOUT/MS_LAYOU`
          && `T/T_LAYOUT/0/MERGE}" width="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/0/WIDTH}"><Text text="Order"/><`
          && `/Column><Column visible="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/1/VISIBLE}" mergeDuplicates="{/MO_`
          && `LAYOUT/MS_LAYOUT/T_LAYOUT/1/MERGE}" width="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/1/WIDTH}"><Text `
          && `text="Material"/></Column><Column visible="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/2/VISIBLE}" merg`
          && `eDuplicates="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/2/MERGE}" width="{/MO_LAYOUT/MS_LAYOUT/T_LAYOU`
          && `T/2/WIDTH}"><Text text="Qty"/></Column><Column visible="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/3/V`
          && `ISIBLE}" mergeDuplicates="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/3/MERGE}" width="{/MO_LAYOUT/MS_L`
          && `AYOUT/T_LAYOUT/3/WIDTH}"><Text text="Unit"/></Column><Column visible="{/MO_LAYOUT/MS_LAYOU`
          && `T/T_LAYOUT/4/VISIBLE}" mergeDuplicates="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/4/MERGE}" width="{/`
          && `MO_LAYOUT/MS_LAYOUT/T_LAYOUT/4/WIDTH}"><Text text="Icon"/></Column><Column visible="{/MO_L`
          && `AYOUT/MS_LAYOUT/T_LAYOUT/5/VISIBLE}" mergeDuplicates="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/5/MER`
          && `GE}" width="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/5/WIDTH}"><Text text="Tag"/></Column><Column vi`
          && `sible="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/6/VISIBLE}" mergeDuplicates="{/MO_LAYOUT/MS_LAYOUT/T`
          && `_LAYOUT/6/MERGE}" width="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/6/WIDTH}"><Text text="Progress"/><`
          && `/Column><Column visible="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/7/VISIBLE}" mergeDuplicates="{/MO_`
          && `LAYOUT/MS_LAYOUT/T_LAYOUT/7/MERGE}" width="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/7/WIDTH}"><Text `
          && `text="Radial"/></Column><Column visible="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/8/VISIBLE}" mergeD`
          && `uplicates="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/8/MERGE}" width="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/`
          && `8/WIDTH}"><Text text="Status"/></Column><Column visible="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/9/`
          && `VISIBLE}" mergeDuplicates="{/MO_LAYOUT/MS_LAYOUT/T_LAYOUT/9/MERGE}" width="{/MO_LAYOUT/MS_`
          && `LAYOUT/T_LAYOUT/9/WIDTH}"><Text text="Sel"/></Column></columns><items><ColumnListItem vAli`
          && `gn="Middle" selected="{SELKZ}" type="Active" press=".eB(['ROW_SELECT'], ${VBELN})"><cells>`
          && `<ObjectIdentifier title="{path:'VBELN',type:'LayoDigitString',constraints:{isDigitSequence`
          && `:true,maxLength:10}}" text="Material: {MATNR}&#xD;&#xA;Qty: {MENGE} {MEINS}&#xD;&#xA;Icon:`
          && ` {ICON}"/><ObjectIdentifier text="{MATNR}"/><ObjectIdentifier text="{MENGE} {MEINS}"/><Obj`
          && `ectIdentifier text="{MEINS}"/><core:Icon src="{ICON/SRC}" size="{ICON/ICON_SIZE}"/><Generi`
          && `cTag text="{TAG/TEXT}" design="{TAG/DESIGN}" status="{TAG/STATUS}"/><ProgressIndicator cla`
          && `ss="sapUiSmallMarginBottom" percentValue="{PROGRESS/PERCENTVALUE}" displayValue="{PROGRESS`
          && `/DISPLAYVALUE}" showValue="{PROGRESS/SHOWVALUE}" state="{PROGRESS/STATE}"/><mchart:RadialM`
          && `icroChart size="{RADIAL/RADIALMICROCHART_SIZE}" percentage="{RADIAL/PERCENTAGE}" valueColo`
          && `r="{RADIAL/VALUECOLOR}" hideOnNoData="{RADIAL/HIDEONNODATA}"/><si:StatusIndicator class="{`
          && `STATUS/CLASS}" size="{STATUS/STATUSINDICATOR_SIZE}" value="{STATUS/VALUE}"><si:propertyThr`
          && `esholds><si:PropertyThreshold fillColor="Good" toValue="{STATUS/FILLCOLOR_GOOD}"/><si:Prop`
          && `ertyThreshold fillColor="Critical" toValue="{STATUS/FILLCOLOR_CRITICAL}"/><si:PropertyThre`
          && `shold fillColor="Error" toValue="{STATUS/FILLCOLOR_ERROR}"/></si:propertyThresholds><si:Sh`
          && `apeGroup><si:LibraryShape shapeId="{STATUS/SHAPEID}"/></si:ShapeGroup></si:StatusIndicator`
          && `><ObjectIdentifier text="{SELKZ}"/></cells></ColumnListItem></items></Table>`.

  ENDMETHOD.

ENDCLASS.
