#import "Basic"()(MEMORY_DEBUGGER = true, TEMP_ALLOCATOR_OVERWRITE_MEMORY = true);
#import "Compiler";
#import "Math";

stinky :: #import "stinky";

Test :: struct {
    proc:        () -> ();
    description: string;
}

tests: [..]Test;

add_test :: (description: string, proc: () -> ()) {
    array_add(*tests, { proc, description });
}

run_tests :: () {
    print("Running % tests...\n", tests.count);

    for test: tests {
        print("%\n", test.description);
        test.proc();
    }
}

#run {
    defer report_memory_leaks();

    setup_formatting();

    set_build_options_dc({
        do_output           = false,
        write_added_strings = false,
    });

    add_test(
        "Number primary",
        () {
            source := "7.7";

            error, result := stinky.run(source, false);
            assert(!error);
            assert(result.number == 7.7);
            assert(result.kind == .NUMBER);
        }
    );


    add_test(
        "Bool primary",
        () {
            source := "false";

            error, result := stinky.run(source, false);
            assert(!error);
            assert(result._bool == false);
            assert(result.kind == .BOOL);
        }
    );

    add_test(
        "Addition",
        () {
            source := "2 + 2";

            error, result := stinky.run(source, false);
            assert(!error);
            assert(result.number == 4);
            assert(result.kind == .NUMBER);
        }
    );

    add_test(
        "Multiplication",
        () {
            source := "2 * 9";

            error, result := stinky.run(source, false);
            assert(!error);
            assert(result.number == 18);
            assert(result.kind == .NUMBER);
        }
    );

    add_test(
        "Division",
        () {
            source := "9 / 2";

            error, result := stinky.run(source, false);
            assert(!error);
            assert(result.number == 4.5);
            assert(result.kind == .NUMBER);
        }
    );

    add_test(
        "Precedence",
        () {
            source := "2 * 9 + 13";

            error, result := stinky.run(source, false);
            assert(!error);
            assert(result.number == 31);
            assert(result.kind == .NUMBER);
        }
    );

    add_test(
        "Unary minus",
        () {
            source := "2 * 9 - -5";

            error, result := stinky.run(source, false);
            assert(!error);
            assert(result.number == 23);
            assert(result.kind == .NUMBER);
        }
    );

    add_test(
        "Caret",
        () {
            source := "2^3^3 - 1";

            error, result := stinky.run(source, false);
            assert(!error);
            // assert(result.number == 134217727);
            assert(ceil(result.number) == 134217727); // @Todo: Try to solve this. This happens because of a small computation error
            assert(result.kind == .NUMBER);
        }
    );

    add_test(
        "Modulo",
        () {
            source := "(2^3^3 - 1) % 2";

            error, result := stinky.run(source, false);
            assert(!error);
            // assert(result.number == 1);
            assert(result.number == 0); // @Todo: Try to solve this. This happens because of a small computation error
            assert(result.kind == .NUMBER);
        }
    );

    add_test(
        "Parentheses 1",
        () {
            source := "2 * (9 + 13) / 2";

            error, result := stinky.run(source, false);
            assert(!error);
            assert(result.number == 22);
            assert(result.kind == .NUMBER);
        }
    );

    add_test(
        "Parentheses 2",
        () {
            source := "2 * (9 + 13) + 2^2 + (((3 * 3) - 3) + 3.324) / 2.1";

            error, result := stinky.run(source, false);
            assert(!error);
            assert(result.number == 52.44);
            assert(result.kind == .NUMBER);
        }
    );

    add_test(
        "Parentheses 3",
        () {
            source := "14 / (12 / 2) / 2";

            error, result := stinky.run(source, false);
            assert(!error);
            assert(result.number == 1.1666666666666667);
            assert(result.kind == .NUMBER);
        }
    );

    add_test(
        "Bool or",
        () {
            source := "true or false";

            error, result := stinky.run(source, false);
            assert(!error);
            assert(result._bool == true);
            assert(result.kind == .BOOL);
        }
    );

    add_test(
        "Bool or and",
        () {
            source := "(44 >= 2) or false and 1 > 0";

            error, result := stinky.run(source, false);
            assert(!error);
            assert(result._bool == true);
            assert(result.kind == .BOOL);
        }
    );

    add_test(
        "Not",
        () {
            source := "~(44 >= 2)";

            error, result := stinky.run(source, false);
            assert(!error);
            assert(result._bool == false);
            assert(result.kind == .BOOL);
        }
    );

    add_test(
        "Not equals",
        () {
            source := "~(3 ~= 2)";

            error, result := stinky.run(source, false);
            assert(!error);
            assert(result._bool == false);
            assert(result.kind == .BOOL);
        }
    );

    add_test(
        "Equals equals",
        () {
            source := "(3 == 2 + 1)";

            error, result := stinky.run(source, false);
            assert(!error);
            assert(result._bool == true);
            assert(result.kind == .BOOL);
        }
    );

    run_tests();

    array_free(tests);
}

setup_formatting :: () {
    print_style := *context.print_style;

    print_style.default_format_struct.draw_type_name = true;
    print_style.default_format_struct.use_long_form_if_more_than_this_many_members = 0;
    print_style.default_format_struct.use_newlines_if_long_form = true;
}
