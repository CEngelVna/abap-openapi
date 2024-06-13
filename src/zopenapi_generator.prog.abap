*&---------------------------------------------------------------------*
*& Report zopenapi_generator
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zopenapi_generator.

SELECTION-SCREEN BEGIN OF BLOCK b1.

  PARAMETERS:
      p_clas TYPE seoclsname,
      p_intf TYPE seoclsname,
      p_pfad TYPE file_table-filename.

SELECTION-SCREEN END OF BLOCK b1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_pfad.
  DATA it_files TYPE filetable.
  DATA lv_rc    TYPE i.

  TRY.

      cl_gui_frontend_services=>file_open_dialog( EXPORTING file_filter = |JSON (*.json)|
                                                  CHANGING  file_table  = it_files
                                                            rc          = lv_rc ).
      IF lv_rc > 0.
        p_pfad = it_files[ 1 ]-filename.
      ENDIF.

    CATCH cx_root INTO DATA(e_text).
      MESSAGE e_text->get_text( ) TYPE 'I'.

  ENDTRY.

START-OF-SELECTION.
  DATA data_tab TYPE string_table.

  cl_gui_frontend_services=>gui_upload( EXPORTING filename     = CONV #( p_pfad )
                                                  read_by_line = abap_true
                                        CHANGING  data_tab     = data_tab ). " Transfer table for file contents
  IF sy-subrc <> 0.
  ENDIF.

*NEW /ui2/cl_abap2json( )->table2json( data_tab )

*cl_bcs_convert=>raw_to_string( data_tab ).
*CATCH cx_bcs. " BCS: General Exceptions

CONCATENATE LINES OF data_tab INTO data(json).

  DATA(response) = zcl_oapi_generator=>generate_v1(
      VALUE #( class_name = p_clas interface_name = p_intf json = json ) ).

  cl_demo_output=>new(
*          mode = html_mode
  )->display( data = response-clas
              name = 'Client Class'  " Name
  )->display( data = response-intf
              name = 'Interface' ). " Name
