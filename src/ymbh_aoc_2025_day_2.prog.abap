REPORT ymbh_aoc_2025_day_2.

CLASS gift_shop DEFINITION FINAL.

  PUBLIC SECTION.

    METHODS constructor IMPORTING input_data TYPE stringtab.
    METHODS process.

    METHODS get_result_list RETURNING VALUE(result) TYPE stringtab.
    METHODS get_result_sum RETURNING VALUE(result) TYPE decfloat34.

  PRIVATE SECTION.
    TYPES integers TYPE TABLE OF decfloat34 WITH EMPTY KEY.

    DATA input_data TYPE stringtab.
    DATA result_tab TYPE stringtab.
    DATA result_sum TYPE decfloat34.

    METHODS is_duplicated_id IMPORTING number        TYPE decfloat34
                             RETURNING VALUE(result) TYPE abap_bool.
    METHODS check_range IMPORTING input_range   TYPE string
                        RETURNING VALUE(result) TYPE stringtab.

ENDCLASS.

CLASS gift_shop IMPLEMENTATION.

  METHOD constructor.
    me->input_data = input_data.
  ENDMETHOD.

  METHOD process.
    result_tab = VALUE #( FOR line IN input_data
                            ( LINES OF check_range( line ) ) ).

    LOOP AT result_tab INTO DATA(result_line).
      result_sum = result_sum + result_line.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_result_list.
    result = result_tab.
  ENDMETHOD.

  METHOD get_result_sum.
    result = result_sum.
  ENDMETHOD.

  METHOD check_range.
    SPLIT input_range AT '-' INTO TABLE DATA(ranges).

    DATA(start) = CONV decfloat34( ranges[ 1 ] ).
    DATA(end) = CONV decfloat34( ranges[ 2 ] ).

    result = VALUE #( FOR i = start THEN i + 1 UNTIL i > end
                        LET value = COND string( WHEN is_duplicated_id( i )
                                                    THEN i
                                                    ELSE 0 )
                        IN
                        ( condense( value )  ) ).
    DELETE result WHERE table_line = 0.
  ENDMETHOD.

  METHOD is_duplicated_id.
    DATA(check_number) = condense( CONV string( number ) ).
    FIND ALL OCCURRENCES OF PCRE '^(.+)\1+$' IN check_number RESULTS DATA(matches).
    IF matches IS NOT INITIAL.
      result = abap_true.
    ENDIF.
  ENDMETHOD.

ENDCLASS.


CLASS test_gift_shop DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA input_data TYPE stringtab.
    DATA cut TYPE REF TO gift_shop.

    METHODS setup.

    METHODS detect_duplicates_in_range_tbl FOR TESTING.
    METHODS sum_of_duplictes_should_match FOR TESTING.

ENDCLASS.


CLASS test_gift_shop IMPLEMENTATION.

  METHOD setup.
    DATA(input_data) = VALUE stringtab( ( |11-22| )
                                        ( |95-115| )
                                        ( |998-1012| )
                                        ( |1188511880-1188511890| )
                                        ( |222220-222224| )
                                        ( |1698522-1698528| )
                                        ( |446443-446449| )
                                        ( |38593855-38593862| )
                                        ( |565653-565659| )
                                        ( |824824821-824824827| )
                                        ( |2121212118-2121212124| ) ).
    cut = NEW #( input_data ).
  ENDMETHOD.

  METHOD detect_duplicates_in_range_tbl.
    DATA(expected_values) = VALUE stringtab( ( |11| )
                                             ( |22| )
                                             ( |99| )
                                             ( |111| )
                                             ( |999| )
                                             ( |1010| )
                                             ( |1188511885| )
                                             ( |222222| )
                                             ( |446446| )
                                             ( |38593859| )
                                             ( |565656| )
                                             ( |824824824| )
                                             ( |2121212121| ) ).
    cut->process( ).
    cl_abap_unit_assert=>assert_equals( exp = expected_values act = cut->get_result_list( ) ).

  ENDMETHOD.

  METHOD sum_of_duplictes_should_match.
    cut->process( ).
    cl_abap_unit_assert=>assert_equals( exp = 4174379265 act = cut->get_result_sum( ) ).
  ENDMETHOD.

ENDCLASS.


START-OF-SELECTION.
  DATA(input_string) = NEW zcl_mbh_file_upload( )->file_upload_in_string( ).
  SPLIT input_string AT ',' INTO TABLE DATA(input_data).
  DATA(gift_shop) = NEW gift_shop( input_data ).
  gift_shop->process( ).

  WRITE / |Result part 1: { gift_shop->get_result_sum( ) }|.
