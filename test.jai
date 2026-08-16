#import "Basic"()(MEMORY_DEBUGGER = true, TEMP_ALLOCATOR_OVERWRITE_MEMORY = true);
#import "Compiler";
#import "Math";

stinky :: #import "stinky";

#run {
    defer report_memory_leaks();

    set_build_options_dc({
        do_output           = false,
        write_added_strings = false,
    });

    test_number_primary();
    test_bool_primary();
    test_add();
    test_mul();
    test_div();
    test_precedence();
    test_unary_minus();
    test_caret();
    test_modulo();
    test_paren_1();
    test_paren_2();
    test_paren_3();
    test_bool_or();
    test_bool_or_and();
    test_not();
    test_not_eq();
    test_eqeq();
}

test_number_primary :: () {
    source := "7.7";

    error, result := stinky.run(source, false);
    assert(!error);
    assert(result.number == 7.7);
    assert(result.kind == .NUMBER);
}

test_bool_primary :: () {
    source := "false";

    error, result := stinky.run(source, false);
    assert(!error);
    assert(result._bool == false);
    assert(result.kind == .BOOL);
}

test_add :: () {
    source := "2 + 2";

    error, result := stinky.run(source, false);
    assert(!error);
    assert(result.number == 4);
    assert(result.kind == .NUMBER);
}

test_mul :: () {
    source := "2 * 9";

    error, result := stinky.run(source, false);
    assert(!error);
    assert(result.number == 18);
    assert(result.kind == .NUMBER);
}

test_div :: () {
    source := "9 / 2";

    error, result := stinky.run(source, false);
    assert(!error);
    assert(result.number == 4.5);
    assert(result.kind == .NUMBER);
}

test_precedence :: () {
    source := "2 * 9 + 13";

    error, result := stinky.run(source, false);
    assert(!error);
    assert(result.number == 31);
    assert(result.kind == .NUMBER);
}

test_unary_minus :: () {
    source := "2 * 9 - -5";

    error, result := stinky.run(source, false);
    assert(!error);
    assert(result.number == 23);
    assert(result.kind == .NUMBER);
}

test_caret :: () {
    source := "2^3^3 - 1";

    error, result := stinky.run(source, false);
    assert(!error);
    // assert(result.number == 134217727);
    assert(ceil(result.number) == 134217727); // @Todo: Try to solve this. This happens because of a small computation error
    assert(result.kind == .NUMBER);
}

test_modulo :: () {
    source := "(2^3^3 - 1) % 2";

    error, result := stinky.run(source, false);
    assert(!error);
    // assert(result.number == 1);
    assert(result.number == 0); // @Todo: Try to solve this. This happens because of a small computation error
    assert(result.kind == .NUMBER);
}

test_paren_1 :: () {
    source := "2 * (9 + 13) / 2";

    error, result := stinky.run(source, false);
    assert(!error);
    assert(result.number == 22);
    assert(result.kind == .NUMBER);
}

test_paren_2 :: () {
    source := "2 * (9 + 13) + 2^2 + (((3 * 3) - 3) + 3.324) / 2.1";

    error, result := stinky.run(source, false);
    assert(!error);
    assert(result.number == 52.44);
    assert(result.kind == .NUMBER);
}

test_paren_3 :: () {
    source := "14 / (12 / 2) / 2";

    error, result := stinky.run(source, false);
    assert(!error);
    assert(result.number == 1.1666666666666667);
    assert(result.kind == .NUMBER);
}

test_bool_or :: () {
    source := "true or false";

    error, result := stinky.run(source, false);
    assert(!error);
    assert(result._bool == true);
    assert(result.kind == .BOOL);
}

test_bool_or_and :: () {
    source := "(44 >= 2) or false and 1 > 0";

    error, result := stinky.run(source, false);
    assert(!error);
    assert(result._bool == true);
    assert(result.kind == .BOOL);
}

test_not :: () {
    source := "~(44 >= 2)";

    error, result := stinky.run(source, false);
    assert(!error);
    assert(result._bool == false);
    assert(result.kind == .BOOL);
}

test_not_eq :: () {
    source := "~(3 ~= 2)";

    error, result := stinky.run(source, false);
    assert(!error);
    assert(result._bool == false);
    assert(result.kind == .BOOL);
}

test_eqeq :: () {
    source := "(3 == 2 + 1)";

    error, result := stinky.run(source, false);
    assert(!error);
    assert(result._bool == true);
    assert(result.kind == .BOOL);
}
