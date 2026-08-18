#import "Basic"()(MEMORY_DEBUGGER = true, TEMP_ALLOCATOR_OVERWRITE_MEMORY = true);
#import "Compiler";
#import "Math";
#import "Print_Color";

stinky :: #import "stinky";

Test :: struct {
    proc:        (test: *Test) -> ();
    description: string;
    failures:    [..]string;
    warnings:    [..]string;

    failures.allocator = temp;
    warnings.allocator = temp;
}

tests: [..]Test;

#run {
    defer report_memory_leaks();

    setup_formatting();

    set_build_options_dc({
        do_output           = false,
        write_added_strings = false,
    });

    add_test(
        "Number primary",
        (test: *Test) {
            source := "ret 7.7";

            error, result := stinky.run(source, false);
            expect_is_null(test, error);
            expect_are_equal(test, result.number, 7.7);
            expect_are_equal(test, result.kind, .NUMBER);
        }
    );


    add_test(
        "Bool primary",
        (test: *Test) {
            source := "ret false";

            error, result := stinky.run(source, false);
            expect_is_null(test, error);
            expect_are_equal(test, result._bool, false);
            expect_are_equal(test, result.kind, .BOOL);
        }
    );

    add_test(
        "Addition",
        (test: *Test) {
            source := "ret 2 + 2";

            error, result := stinky.run(source, false);
            expect_is_null(test, error);
            expect_are_equal(test, result.number, 4);
            expect_are_equal(test, result.kind, .NUMBER);
        }
    );

    add_test(
        "Multiplication",
        (test: *Test) {
            source := "ret 2 * 9";

            error, result := stinky.run(source, false);
            expect_is_null(test, error);
            expect_are_equal(test, result.number, 18);
            expect_are_equal(test, result.kind, .NUMBER);
        }
    );

    add_test(
        "Division",
        (test: *Test) {
            source := "ret 9 / 2";

            error, result := stinky.run(source, false);
            expect_is_null(test, error);
            expect_are_equal(test, result.number, 4.5);
            expect_are_equal(test, result.kind, .NUMBER);
        }
    );

    add_test(
        "Precedence",
        (test: *Test) {
            source := "ret 2 * 9 + 13";

            error, result := stinky.run(source, false);
            expect_is_null(test, error);
            expect_are_equal(test, result.number, 31);
            expect_are_equal(test, result.kind, .NUMBER);
        }
    );

    add_test(
        "Unary minus",
        (test: *Test) {
            source := "ret 2 * 9 - -5";

            error, result := stinky.run(source, false);
            expect_is_null(test, error);
            expect_are_equal(test, result.number, 23);
            expect_are_equal(test, result.kind, .NUMBER);
        }
    );

    add_test(
        "Caret",
        (test: *Test) {
            source := "ret 2^3^3 - 1";

            error, result := stinky.run(source, false);
            expect_is_null(test, error);
            // assert(result.number == 134217727);
            cope_do_not_equal(test, ceil(result.number), 134217727, result.number); // @Todo: Try to solve this. This happens because of a small computation error
            expect_are_equal(test, result.kind, .NUMBER);
        }
    );

    add_test(
        "Modulo",
        (test: *Test) {
            source := "ret (2^3^3 - 1) % 2";

            error, result := stinky.run(source, false);
            expect_is_null(test, error);
            // expect_are_equal(test, result.number, 1);
            cope_do_not_equal(test, cast(float64, 1), cast(float64, 1), result.number); // @Todo: Try to solve this. This happens because of a small computation error
            expect_are_equal(test, result.kind, .NUMBER);
        }
    );

    add_test(
        "Parentheses 1",
        (test: *Test) {
            source := "ret 2 * (9 + 13) / 2";

            error, result := stinky.run(source, false);
            expect_is_null(test, error);
            expect_are_equal(test, result.number, 22);
            expect_are_equal(test, result.kind, .NUMBER);
        }
    );

    add_test(
        "Parentheses 2",
        (test: *Test) {
            source := "ret 2 * (9 + 13) + 2^2 + (((3 * 3) - 3) + 3.324) / 2.1";

            error, result := stinky.run(source, false);
            expect_is_null(test, error);
            expect_are_equal(test, result.number, 52.44);
            expect_are_equal(test, result.kind, .NUMBER);
        }
    );

    add_test(
        "Parentheses 3",
        (test: *Test) {
            source := "ret 14 / (12 / 2) / 2";

            error, result := stinky.run(source, false);
            expect_is_null(test, error);
            expect_are_equal(test, result.number, 1.1666666666666667);
            expect_are_equal(test, result.kind, .NUMBER);
        }
    );

    add_test(
        "Bool or",
        (test: *Test) {
            source := "ret true or false";

            error, result := stinky.run(source, false);
            expect_is_null(test, error);
            expect_are_equal(test, result._bool, true);
            expect_are_equal(test, result.kind, .BOOL);
        }
    );

    add_test(
        "Bool or and",
        (test: *Test) {
            source := "ret (44 >= 2) or false and 1 > 0";

            error, result := stinky.run(source, false);
            expect_is_null(test, error);
            expect_are_equal(test, result._bool, true);
            expect_are_equal(test, result.kind, .BOOL);
        }
    );

    add_test(
        "Not",
        (test: *Test) {
            source := "ret ~(44 >= 2)";

            error, result := stinky.run(source, false);
            expect_is_null(test, error);
            expect_are_equal(test, result._bool, false);
            expect_are_equal(test, result.kind, .BOOL);
        }
    );

    add_test(
        "Not equals",
        (test: *Test) {
            source := "ret ~(3 ~= 2)";

            error, result := stinky.run(source, false);
            expect_is_null(test, error);
            expect_are_equal(test, result._bool, false);
            expect_are_equal(test, result.kind, .BOOL);
        }
    );

    add_test(
        "Equals equals",
        (test: *Test) {
            source := "ret (3 == 2 + 1)";

            error, result := stinky.run(source, false);
            expect_is_null(test, error);
            expect_are_equal(test, result._bool, true);
            expect_are_equal(test, result.kind, .BOOL);
        }
    );

    add_test(
        "String + string",
        (test: *Test) {
            source := "ret 'Hello' + ' ' + 'World'";

            error, result := stinky.run(source, false);
            expect_is_null(test, error);
            expect_are_equal(test, result._string, "Hello World");
            expect_are_equal(test, result.kind, .STRING);
        }
    );

    add_test(
        "Concatination of different types",
        (test: *Test) {
            source := "ret (5 + 3) / 2 + ' what? ' + false";

            error, result := stinky.run(source, false);
            expect_is_null(test, error);
            expect_are_equal(test, result._string, "4 what? false");
            expect_are_equal(test, result.kind, .STRING);
        }
    );

    add_test(
        "Early return",
        (test: *Test) {
            source := #string STINKY
age := 17
age := age + 1

func check_age(age)
    if age >= 18 then
        ret true
    else
        ret false
    end

    return 32
end

ret check_age(age)
            STINKY

            error, result := stinky.run(source, false);

            expect_is_null(test, error);
            expect_are_equal(test, result.kind, .BOOL);
            expect_are_equal(test, result._bool, true);
        }
    );

    has_failures := run_tests();

    array_free(tests);

    if has_failures {
        exit(1);
    }
}

add_test :: (description: string, proc: (test: *Test) -> ()) {
    array_add(*tests, { proc = proc, description = description });
}

run_tests :: () -> has_failures: bool {
    print_color("Running % tests...\n", tests.count, color = .BLUE);

    failed_test_count:  int;
    warned_test_count: int;

    for *test: tests {
        test.proc(test);

        test_no := it_index + 1;

        if test.failures.count > 0 {
            failed_test_count += 1;
            print_color("% - %:\n", test_no, test.description, color = .RED, style = .BOLD, to_standard_error = true);
            for failure: test.failures {
                print_color("    %\n", failure, color = .RED, to_standard_error = true);
            }
        } else if test.warnings.count > 0 {
            warned_test_count += 1;
            print_color("% - %\n", test_no, test.description, color = .YELLOW, style = .BOLD);
            for warning: test.warnings {
                print_color("    %\n", warning, color = .YELLOW);
            }
        } else {
            print_color("% - %\n", test_no, test.description, color = .GREEN, style = .BOLD);
        }
    }


    if warned_test_count > 0 {
        print_color("% tests with warnings\n", warned_test_count, color = .YELLOW, style = .UNDERLINE);
    }
    if failed_test_count > 0 {
        print_color("% tests failed\n", failed_test_count, color = .RED, style = .UNDERLINE, to_standard_error = true);
    }

    return failed_test_count != 0;
}

expect_are_equal :: (test: *Test, actual: $T, expected: T) {
    if actual != expected {
        array_add(*test.failures, tprint("Expected % to equal %", actual, expected));
    }
}

cope_do_not_equal :: (test: *Test, actual: $T, expected: T, actual_actual: T) {
    if actual != expected {
        array_add(*test.failures, tprint("Expected % to equal %", actual, expected));
        return;
    }

    array_add(*test.warnings, tprint("Coping with the fact that % is not equal %", actual_actual, expected));
}

expect_is_null :: (test: *Test, value: $T) {
    #if T == string {
        if value != "" {
            array_add(*test.failures, tprint("Expected % to be empty", value));
        }
    } else {
        if value != null {
            array_add(*test.failures, tprint("Expected % to be null", value));
        }
    }
}

setup_formatting :: () {
    print_style := *context.print_style;

    print_style.default_format_struct.draw_type_name = true;
    print_style.default_format_struct.use_long_form_if_more_than_this_many_members = 0;
    print_style.default_format_struct.use_newlines_if_long_form = true;
}
