"! The authorization decision of layout-management, and the default when the
"! system has not made one of its own. check( ) is what the layout popup asks;
"! it goes to the instance set with set_instance( ), else to the one class in
"! the system that implements z2ui5_if_layo_auth (found by its interface, like
"! abap2UI5's user exit), else to this class: own layouts yes, shared layouts
"! no, deleting only what one owns.
CLASS z2ui5_cl_layo_auth DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_layo_auth.

    "! the decision for the current user - see z2ui5_if_layo_auth=&gt;cs_action
    CLASS-METHODS check
      IMPORTING
        !action       TYPE string
        !head         TYPE z2ui5_t_11
      RETURNING
        VALUE(result) TYPE abap_bool.

    "! the active implementation: the one set, else the one found, else this class
    CLASS-METHODS get_instance
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_layo_auth.

    "! replaces the lookup - for a test, or for an installation that wants to
    "! choose the class itself instead of being found. An unbound reference
    "! restores the lookup
    CLASS-METHODS set_instance
      IMPORTING
        !val TYPE REF TO z2ui5_if_layo_auth OPTIONAL.

  PROTECTED SECTION.

  PRIVATE SECTION.
    CLASS-DATA gi_instance TYPE REF TO z2ui5_if_layo_auth.
    CLASS-DATA gv_looked_up TYPE abap_bool.

    "! the name of the class implementing the interface, empty when there is
    "! none but the shipped one; never raises
    CLASS-METHODS lookup_class
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS type_name_of
      IMPORTING
        !val          TYPE any
      RETURNING
        VALUE(result) TYPE string.

ENDCLASS.


CLASS z2ui5_cl_layo_auth IMPLEMENTATION.

  METHOD check.

    DATA li_auth TYPE REF TO z2ui5_if_layo_auth.

    li_auth = get_instance( ).
    result = li_auth->check_authorized( action = action
                                        head   = head ).

  ENDMETHOD.

  METHOD get_instance.

    DATA li_auth TYPE REF TO z2ui5_if_layo_auth.
    DATA lv_class TYPE string.

    IF gi_instance IS BOUND.
      result = gi_instance.
      RETURN.
    ENDIF.

    " the lookup is a repository read - once per session is enough, and a
    " system without an implementation answers the same every time
    IF gv_looked_up = abap_false.
      gv_looked_up = abap_true.
      lv_class = lookup_class( ).
      IF lv_class IS NOT INITIAL.
        TRY.
            CREATE OBJECT li_auth TYPE (lv_class).
            gi_instance = li_auth.
          CATCH cx_root ##NO_HANDLER.
            " a class that cannot be created (abstract, no public constructor)
            " leaves the default in place
        ENDTRY.
      ENDIF.
    ENDIF.

    IF gi_instance IS NOT BOUND.
      CREATE OBJECT gi_instance TYPE z2ui5_cl_layo_auth.
    ENDIF.

    result = gi_instance.

  ENDMETHOD.

  METHOD set_instance.

    gi_instance = val.
    " an unbound reference restores the lookup
    gv_looked_up = abap_false.

  ENDMETHOD.

  METHOD lookup_class.

    " the names come from typed, unbound references and not from literals:
    " the compiler checks them, and the namespace rename (abaplint --rename)
    " rewrites them - a literal survives the rename and then names an
    " interface that no longer exists
    DATA li_auth    TYPE REF TO z2ui5_if_layo_auth.
    DATA lo_shipped TYPE REF TO z2ui5_cl_layo_auth.
    DATA lv_intf    TYPE string.
    DATA lv_shipped TYPE string.
    DATA lt_class   TYPE z2ui5_cl_util=>ty_t_classes.
        DATA temp1 TYPE string.
        DATA temp2 TYPE z2ui5_cl_util=>ty_s_class_descr.

    TRY.
        lv_intf    = type_name_of( li_auth ).
        lv_shipped = type_name_of( lo_shipped ).

        lt_class = z2ui5_cl_util=>rtti_get_classes_impl_intf( lv_intf ).
        DELETE lt_class WHERE classname = lv_shipped.

        " reproducible when a system carries more than one: the first by name
        SORT lt_class BY classname.

        CLEAR temp1.

        READ TABLE lt_class INTO temp2 INDEX 1.
        IF sy-subrc = 0.
          temp1 = temp2-classname.
        ENDIF.
        result = temp1.

      CATCH cx_root ##NO_HANDLER.
        " no repository access, no implementation: the default applies
    ENDTRY.

  ENDMETHOD.

  METHOD type_name_of.

    DATA lo_descr TYPE REF TO cl_abap_typedescr.
    DATA lo_ref   TYPE REF TO cl_abap_refdescr.

    lo_descr = cl_abap_typedescr=>describe_by_data( val ).
    lo_ref ?= lo_descr.
    result = lo_ref->get_referenced_type( )->get_relative_name( ).

  ENDMETHOD.

  METHOD z2ui5_if_layo_auth~check_authorized.
        DATA temp1 TYPE xsdboolean.
        DATA temp2 TYPE xsdboolean.

    " the default: a user owns his layouts and nothing else. Shared layouts
    " belong to every user of the app, so saving one needs a decision the
    " addon cannot make - a class implementing z2ui5_if_layo_auth makes it
    CASE action.
      WHEN z2ui5_if_layo_auth=>cs_action-save_own.

        temp1 = boolc( head-uname = sy-uname ).
        result = temp1.
      WHEN z2ui5_if_layo_auth=>cs_action-save_shared.
        result = abap_false.
      WHEN z2ui5_if_layo_auth=>cs_action-delete.

        temp2 = boolc( head-uname IS NOT INITIAL AND head-uname = sy-uname ).
        result = temp2.
      WHEN OTHERS.
        result = abap_false.
    ENDCASE.

  ENDMETHOD.

ENDCLASS.
