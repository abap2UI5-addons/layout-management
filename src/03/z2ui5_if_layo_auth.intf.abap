"! The authorization hook of layout-management: who may save a layout that
"! every user sees, and who may delete one. The addon ships no authorization
"! object - an AUTHORITY-CHECK against an object that does not exist in the
"! customer system is always refused, and a .suso cannot be written by hand for
"! every release the addon runs on. Instead a system decides through a class
"! that implements this interface: the layout popup finds it by its interface
"! (the way abap2UI5 finds its user exit), creates it and asks it before every
"! write that reaches beyond the user's own layouts. Without such a class the
"! shipped default z2ui5_cl_layo_auth applies: a user may save and delete his
"! own layouts, and nobody may save a shared one.
"! Only one implementing class may exist in a system - the lookup takes the
"! first by name and the result is not what two authors intended.
INTERFACE z2ui5_if_layo_auth
  PUBLIC.

  CONSTANTS:
    BEGIN OF cs_action,
      "! a layout with the user's own name on it (uname = sy-uname)
      save_own    TYPE string VALUE `SAVE_OWN`,
      "! a layout without a user - offered to, and loaded as default by, every user
      save_shared TYPE string VALUE `SAVE_SHARED`,
      "! head-uname carries the owner as the database has it - blank for a shared layout
      delete      TYPE string VALUE `DELETE`,
    END OF cs_action.

  "! abap_true when the current user may perform the action on the layout
  "! head - its handles say which app and table it belongs to, its uname who
  "! owns it. A denial ends in a message to the user and nothing is written.
  METHODS check_authorized
    IMPORTING
      !action       TYPE string
      !head         TYPE z2ui5_t_11
    RETURNING
      VALUE(result) TYPE abap_bool.

ENDINTERFACE.
