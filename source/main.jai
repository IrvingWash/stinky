#placeholder DEBUG;

#import "Basic"()(
    MEMORY_DEBUGGER                 = DEBUG,
    TEMP_ALLOCATOR_OVERWRITE_MEMORY = DEBUG,
);

#import "File";
#import "Print_Color";

Config      :: #import,file "config.jai";
Lexer       :: #import,file "lexer.jai";
Parser      :: #import,file "parser.jai";
Interpreter :: #import,file "interpreter.jai";

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
    #if DEBUG {
        print("================================================================================\n");
        print("Source:\n");
        print("================================================================================\n");
        print(source);
    }

    #if DEBUG {
        print("================================================================================\n");
        print("Running the lexer...\n");
        print("================================================================================\n");
    }
    error =, tokens := Lexer.tokenize(source);
    if error {
        terminate("Failed: %\n", error);
    }
    defer array_free(tokens);
    #if DEBUG {
        Lexer.pretty_print_tokens(tokens);
    }

    #if DEBUG {
        print("================================================================================\n");
        print("Running the parser...\n");
        print("================================================================================\n");
    }
    error =, ast := Parser.make_ast(tokens);
    if error {
        terminate("Failed: %\n", error);
    }
    defer Parser.destroy_ast(*ast);
    #if DEBUG {
        Parser.pretty_print_ast(ast);
    }

    #if DEBUG {
        print("================================================================================\n");
        print("Running the interpreter...\n");
        print("================================================================================\n");
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

setup_formatting :: () {
    print_style := *context.print_style;

    print_style.default_format_struct.draw_type_name = true;
    print_style.default_format_struct.use_long_form_if_more_than_this_many_members = 0;
    print_style.default_format_struct.use_newlines_if_long_form = true;
}
