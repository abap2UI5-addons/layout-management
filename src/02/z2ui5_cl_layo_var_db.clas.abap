CLASS z2ui5_cl_layo_var_db DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_s_db TYPE z2ui5_t_13.
    TYPES ty_t_db TYPE STANDARD TABLE OF z2ui5_t_13 WITH EMPTY KEY.

    CLASS-METHODS db_read_default
      IMPORTING
        s_info        TYPE z2ui5_t_13
      RETURNING
        VALUE(result) TYPE ty_s_db.

    CLASS-METHODS db_read
      IMPORTING
        s_info        TYPE z2ui5_t_13
      RETURNING
        VALUE(result) TYPE ty_t_db.

    CLASS-METHODS db_save
      IMPORTING
        s_info TYPE z2ui5_t_13
        data   TYPE data.

    "! abap_true when a variant of the name in s_info exists in its scope -
    "! the same user (or shared) and handles - which db_save( ) replaces
    CLASS-METHODS db_check_exists
      IMPORTING
        s_info        TYPE z2ui5_t_13
      RETURNING
        VALUE(result) TYPE abap_bool.

    "! deletes a variant of the current user. A variant saved for every user
    "! (no user) is left: the table does not say who saved it, so nobody
    "! could be told from everybody else
    CLASS-METHODS db_delete
      IMPORTING
        uuid          TYPE z2ui5_t_13-uuid
      RETURNING
        VALUE(result) TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
    "! the variant of the name in s_info in its scope, initial when none
    CLASS-METHODS get_uuid
      IMPORTING
        s_info        TYPE z2ui5_t_13
      RETURNING
        VALUE(result) TYPE z2ui5_t_13-uuid.

ENDCLASS.


CLASS z2ui5_cl_layo_var_db IMPLEMENTATION.

  METHOD db_read.

    " the user's own variants and the ones saved for everybody (no user),
    " of exactly this caller - all three handles. The own ones also for a
    " caller without var_check_user: "User specific" in the save popup
    " stores a variant under the user then, and db_read_default( ) applies
    " it - it has to be in the list as well
    IF s_info-uname IS INITIAL.
      DATA(lv_uname) = sy-uname.
    ELSE.
      lv_uname = s_info-uname.
    ENDIF.

    SELECT * FROM z2ui5_t_13
      WHERE ( uname = @lv_uname OR uname = @space )
        AND handle01 = @s_info-handle01
        AND handle02 = @s_info-handle02
        AND handle03 = @s_info-handle03
      ORDER BY PRIMARY KEY
      INTO CORRESPONDING FIELDS OF TABLE @result ##SUBRC_OK.

  ENDMETHOD.

  METHOD db_save.

    DATA(ls_db) = s_info.

    " saving under a name that exists replaces that variant
    ls_db-uuid = get_uuid( s_info ).
    IF ls_db-uuid IS INITIAL.
      ls_db-uuid = z2ui5_cl_layo_context=>uuid_get_c32( ).
    ENDIF.

    ls_db-data = z2ui5_cl_layo_context=>xml_stringify( data ).

    " one default per scope - same user (or shared) and handles: a new
    " default takes the flag from the variant that had it
    IF ls_db-check_def = abap_true.
      UPDATE z2ui5_t_13 SET check_def = @abap_false
        WHERE uname    = @s_info-uname
          AND handle01 = @s_info-handle01
          AND handle02 = @s_info-handle02
          AND handle03 = @s_info-handle03
          AND uuid    <> @ls_db-uuid ##SUBRC_OK.
    ENDIF.

    MODIFY z2ui5_t_13 FROM @ls_db ##SUBRC_OK.
    COMMIT WORK AND WAIT.

  ENDMETHOD.

  METHOD db_check_exists.

    result = xsdbool( get_uuid( s_info ) IS NOT INITIAL ).

  ENDMETHOD.

  METHOD get_uuid.

    SELECT SINGLE uuid FROM z2ui5_t_13
      WHERE uname    = @s_info-uname
        AND handle01 = @s_info-handle01
        AND handle02 = @s_info-handle02
        AND handle03 = @s_info-handle03
        AND name     = @s_info-name
      INTO @result ##SUBRC_OK.                          "#EC CI_NOORDER

  ENDMETHOD.

  METHOD db_delete.

    IF uuid IS INITIAL.
      RETURN.
    ENDIF.

    DELETE FROM z2ui5_t_13 WHERE uuid  = @uuid
                             AND uname = @sy-uname.
    result = xsdbool( sy-subrc = 0 ).
    IF result = abap_true.
      COMMIT WORK AND WAIT.
    ENDIF.

  ENDMETHOD.

  METHOD db_read_default.

    IF s_info-uname IS INITIAL.
      DATA(lv_uname) = sy-uname.
    ELSE.
      lv_uname = s_info-uname.
    ENDIF.

    SELECT SINGLE * FROM z2ui5_t_13
      WHERE uname     = @lv_uname
        AND handle01  = @s_info-handle01
        AND handle02  = @s_info-handle02
        AND handle03  = @s_info-handle03
        AND check_def = @abap_true
      INTO CORRESPONDING FIELDS OF @result.             "#EC CI_NOORDER

    IF sy-subrc = 0.
      RETURN.
    ENDIF.

    SELECT SINGLE * FROM z2ui5_t_13
      WHERE uname     = @space
        AND handle01  = @s_info-handle01
        AND handle02  = @s_info-handle02
        AND handle03  = @s_info-handle03
        AND check_def = @abap_true
      INTO CORRESPONDING FIELDS OF @result ##SUBRC_OK.  "#EC CI_NOORDER

  ENDMETHOD.

ENDCLASS.
