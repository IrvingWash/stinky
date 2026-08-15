#placeholder DEBUG;

#import "Basic"()(
    MEMORY_DEBUGGER                 = DEBUG,
    TEMP_ALLOCATOR_OVERWRITE_MEMORY = DEBUG,
);

#import "File";

Config :: #import,file "config.jai";
Lexer  :: #import,file "lexer.jai";
Parser :: #import,file "parser.jai";

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

    error =, tokens := Lexer.tokenize(source);
    if error {
        terminate("Failed: %\n", error);
    }
    defer array_free(tokens);
    Lexer.pretty_print_tokens(tokens);

    ast := Parser.make_ast(tokens);
    defer Parser.destroy_ast(*ast);
    Parser.pretty_print_ast(ast);
}

terminate :: (format_string: string, args: ..Any) {
    print(format_string, ..args);

    exit(1);
}

setup_formatting :: () {
    print_style := *context.print_style;

    print_style.default_format_struct.draw_type_name = true;
    print_style.default_format_struct.use_long_form_if_more_than_this_many_members = 0;
    print_style.default_format_struct.use_newlines_if_long_form = true;
}
