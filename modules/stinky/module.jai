#module_parameters()(DEBUG: bool = false);

#import "Basic";
#import "Print_Color";
#import "String";

Lexer       :: #import,file "lexer.jai";
Parser      :: #import,file "parser.jai";
Interpreter :: #import,file "interpreter.jai";

run :: (source: string, verbose: bool) -> error: string, value: Interpreter.Stinky_Value {
    if verbose {
        pretty_print_source(source);
    }

    error, tokens := Lexer.tokenize(source);
    if error {
        terminate("Failed: %\n", error);
    }
    defer array_free(tokens);
    if verbose {
        Lexer.pretty_print_tokens(tokens);
    }

    error =, ast := Parser.make_ast(tokens);
    if error {
        terminate("Failed: %\n", error);
    }
    defer Parser.destroy_ast(*ast);
    if verbose {
        Parser.pretty_print_ast(ast);
    }

    error =, result := Interpreter.interpret(ast, ast.root_index);
    if error {
        terminate("Failed: %\n", error);
    }
    if DEBUG {
        print("%\n", result);
    }

    return error, result;
}



#scope_file

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

    print(builder_to_string(*builder,, temp));
}
