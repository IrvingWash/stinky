#placeholder DEBUG;

#import "Basic"()(
    MEMORY_DEBUGGER                 = DEBUG,
    TEMP_ALLOCATOR_OVERWRITE_MEMORY = DEBUG,
);

#import "File";
#import "Print_Color";
#import "String";

Config      :: #import,file "config.jai";
Lexer       :: #import,file "lexer.jai";
Parser      :: #import,file "parser.jai";
Interpreter :: #import,file "interpreter.jai";

VERBOSE :: true;

main :: () {
    #if DEBUG {
        defer report_memory_leaks();
    }

    setup_formatting();

    error, config := Config.make_config_from_arguments();
    if error {
        terminate("Failed: %\n", error);
    }
    defer Config.destroy_config(config);

    source, ok := read_entire_file(config.file_path);
    if !ok {
        terminate("Failed to read '%'\n", config.file_path);
    }
    defer free(source);
    #if VERBOSE {
        pretty_print_source(source);
    }

    error =, tokens := Lexer.tokenize(source);
    if error {
        terminate("Failed: %\n", error);
    }
    defer array_free(tokens);
    #if VERBOSE {
        Lexer.pretty_print_tokens(tokens);
    }

    error =, ast := Parser.make_ast(tokens);
    if error {
        terminate("Failed: %\n", error);
    }
    defer Parser.destroy_ast(*ast);
    #if VERBOSE {
        Parser.pretty_print_ast(ast);
    }

    error =, result := Interpreter.interpret(ast, ast.root_index);
    if error {
        terminate("Failed: %\n", error);
    }
    #if DEBUG {
        print("%\n", result);
    }
}

terminate :: (format_string: string, args: ..Any) {
    print_color(format_string, ..args, .RED, to_standard_error = true);

    exit(1);
}

pretty_print_source :: (source: string) {
    UNIX_SEPARATOR :: "\n";
    WINDOWS_SEPARATOR :: "\r\n";

    #if OS == .WINDOWS {
        separator := WINDOWS_SEPARATOR;
    } else {
        separator := UNIX_SEPARATOR;
    }

    lines := split(source, separator,, temp);

    builder: String_Builder;

    print(*builder, "=== Source ===\n");

    for line: lines {
        print(*builder, "% | %\n",  it_index + 1, line);
    }

    print(*builder, "\n");

    print(builder_to_string(*builder));
}

setup_formatting :: () {
    print_style := *context.print_style;

    print_style.default_format_struct.draw_type_name = true;
    print_style.default_format_struct.use_long_form_if_more_than_this_many_members = 0;
    print_style.default_format_struct.use_newlines_if_long_form = true;
}
