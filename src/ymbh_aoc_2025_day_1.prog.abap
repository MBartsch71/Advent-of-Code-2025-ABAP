REPORT ymbh_aoc_2025_day_1.

CLASS secret_entrance DEFINITION FINAL.

  PUBLIC SECTION.
    METHODS constructor.

    METHODS zeros RETURNING VALUE(result) TYPE i.
    METHODS process IMPORTING input_data TYPE stringtab.

  PRIVATE SECTION.
    DATA current_value TYPE i.
    DATA zero_count TYPE i.

    METHODS turn IMPORTING direction TYPE string.
    METHODS check_zero_count_increase.
    METHODS check_counter_wrap_around.
    METHODS update_current_value IMPORTING direction_indicator TYPE string.

ENDCLASS.

CLASS secret_entrance IMPLEMENTATION.

  METHOD constructor.
    current_value = 50.
  ENDMETHOD.

  METHOD zeros.
    result = zero_count.
  ENDMETHOD.

  METHOD process.
    LOOP AT input_data REFERENCE INTO DATA(line).
      turn( line->* ).
    ENDLOOP.
  ENDMETHOD.

  METHOD turn.
    DATA(direction_indicator) = substring( val = direction off = 0 len = 1 ).
    DATA(value) = substring( val = direction off = 1 len = strlen( direction ) - 1 ).

    DO value TIMES.
      check_zero_count_increase( ).
      check_counter_wrap_around( ).
      update_current_value( direction_indicator ).
    ENDDO.
  ENDMETHOD.

  METHOD check_counter_wrap_around.
    IF current_value = -1.
      current_value = 99.
    ELSEIF current_value = 101.
      current_value = 1.
    ENDIF.
  ENDMETHOD.

  METHOD check_zero_count_increase.
    IF current_value = 0 OR current_value = 100.
      zero_count += 1.
    ENDIF.
  ENDMETHOD.

  METHOD update_current_value.
    current_value = SWITCH #( direction_indicator
                                WHEN 'L' THEN current_value - 1
                                WHEN 'R' THEN current_value + 1 ).
  ENDMETHOD.

ENDCLASS.


CLASS test_secret_entrance DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA cut TYPE REF TO secret_entrance.

    METHODS setup.

    METHODS after_input_data_zcount_3 FOR TESTING.
    METHODS after_big_numbers_zcount_4 FOR TESTING.

ENDCLASS.

CLASS test_secret_entrance IMPLEMENTATION.

  METHOD setup.
    cut = NEW #( ).
  ENDMETHOD.

  METHOD after_input_data_zcount_3.
    DATA(input_data) = VALUE stringtab( ( |L68| )
                                        ( |L30| )
                                        ( |R48| )
                                        ( |L5| )
                                        ( |R60| )
                                        ( |L55| )
                                        ( |L1| )
                                        ( |L99| )
                                        ( |R14| )
                                        ( |L82| ) ).
    cut->process( input_data ).
    cl_abap_unit_assert=>assert_equals( exp = 6 act = cut->zeros( ) ).
  ENDMETHOD.

  METHOD after_big_numbers_zcount_4.
    DATA(input_data) = VALUE stringtab( ( |R52| )
                                        ( |L204| )
                                        ( |R2| ) ).
    cut->process( input_data ).
    cl_abap_unit_assert=>assert_equals( exp = 4 act = cut->zeros( ) ).
  ENDMETHOD.

ENDCLASS.


START-OF-SELECTION.
  DATA(input_data) = NEW zcl_mbh_file_upload( )->file_upload_in_stringtab( ).
  DATA(secret_entrance) = NEW secret_entrance( ).
  secret_entrance->process( input_data ).


  WRITE /: |The result of part 1 is: { secret_entrance->zeros( ) }|.
