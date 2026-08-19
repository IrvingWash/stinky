#module_parameters()(DEBUG: bool = false);

#import "Basic";
#import "String";

Lexer       :: #import,file "lexer.jai";
Parser      :: #import,file "parser.jai";
Interpreter :: #import,file "interpreter.jai";
Compiler    :: #import,file "compiler.jai";

run :: (source: string, verbose: bool) -> error: string {
    if verbose {
        pretty_print_source(source);
    }

    error, tokens := Lexer.tokenize(source);
    if error {
        return tprint("Lexer error: %", error);
    }
    if verbose {
        Lexer.pretty_print_tokens(tokens);
    }

    error =, ast := Parser.make_ast(tokens);
    if error {
        return tprint("Parser error: %", error);
    }
    if verbose {
        Parser.pretty_print_ast(ast);
    }

    error =, value := Interpreter.interpret(ast);
    if error {
        return tprint("Runtime error: %", error);
    }

    code := Compiler.compile(ast);
    if error {
        return tprint("Compiler error: %", error);
    }
    if verbose {
        Compiler.pretty_print_code(code);
    }

    return "";
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
