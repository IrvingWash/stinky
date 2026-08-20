#module_parameters()(DEBUG: bool = false);

#import "Basic";
#import "String";

Lexer       :: #import,file "lexer.jai";
Parser      :: #import,file "parser.jai";
Interpreter :: #import,file "interpreter.jai";
Compiler    :: #import,file "compiler.jai";
VM          :: #import,file "virtual_machine.jai";

Mode :: enum {
    VM;
    INTERPRETER;
}

run :: (source: string, verbose: bool, mode: Mode) -> error: string, value: Interpreter.Stinky_Value {
    if verbose {
        pretty_print_source(source);
    }

    if verbose {
        print("=== Lexing the stinky code ===\n");
    }
    error, tokens := Lexer.tokenize(source);
    if error {
        return error, {};
    }
    if verbose {
        Lexer.pretty_print_tokens(tokens);
    }

    if verbose {
        print("Parsing the stinky code\n");
    }
    error =, ast := Parser.make_ast(tokens);
    if error {
        return error, {};
    }
    if verbose {
        Parser.pretty_print_ast(ast);
    }

    if #complete mode == {
        case .INTERPRETER;
            if verbose {
                print("=== Interpreting the program ===\n");
            }
            error, value := Interpreter.interpret(ast);
            return error, value;
        case .VM;
            if verbose {
                print("=== Compiling the program for the VM ===\n");
            }
            code := Compiler.compile(ast);
            if verbose {
                Compiler.pretty_print_code(code);
            }

            if verbose {
                print("=== Running the program in the VM ===\n");
            }
            error = VM.execute(code);

            return error, {};
    }
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
