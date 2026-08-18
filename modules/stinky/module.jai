#module_parameters()(DEBUG: bool = false);

#import "Basic";
#import "String";

Lexer       :: #import,file "lexer.jai";
Parser      :: #import,file "parser.jai";
Interpreter :: #import,file "interpreter.jai";

run :: (source: string, verbose: bool) -> error: string, Interpreter.Stinky_Value {
    if verbose {
        pretty_print_source(source);
    }

    error, tokens := Lexer.tokenize(source);
    if error {
        return tprint("Lexer error: %", error), .{};
    }
    defer array_free(tokens);
    if verbose {
        Lexer.pretty_print_tokens(tokens);
    }

    error =, ast := Parser.make_ast(tokens);
    if error {
        return tprint("Parser error: %", error), .{};
    }
    defer Parser.destroy_ast(*ast);
    if verbose {
        Parser.pretty_print_ast(ast);
    }

    error =, value := Interpreter.interpret(ast);
    if error {
        return tprint("Runtime error: %", error), .{};
    }

    return "", value;
}



#scope_file

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
