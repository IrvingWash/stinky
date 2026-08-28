// Compiles stinky code into a set of made up instructions

compile :: (ast: Model.AST) -> error: string, [..]Instruction {
    push_allocator(temp);

    compiler: Compiler;

    array_add(
        *compiler.code,
        Instruction.{
            kind = .LABEL,
            label = {
                name = "START",
            },
        },
    );

    for statement: ast.statements {
        error := compile_statement(statement, *compiler);
        if error {
            return error, compiler.code;
        }
    }

    array_add(
        *compiler.code,
        Instruction.{
            kind = .HALT,
            halt = {},
        },
    );

    return "", compiler.code;
}

pretty_print_code :: (code: [..]Instruction) {
    builder: String_Builder;

    print(*builder, "=== Code ===\n");

    depth: int;

    for instruction: code {
        prettify_instruction(instruction, *builder, *depth);
    }

    print(builder_to_string(*builder,, temp));
}



#scope_file

Symbol :: struct {
    name:        string;
    scope_depth: int;
}

Compiler :: struct {
    code:          [..]Instruction;
    globals:       [..]Symbol; // Right now we need this ONLY to make sure that an identifier was declared before it was used in an expression
    locals:        [..]Symbol; // ^
    scope_depth:   int;
    label_counter: int;
}

compile_statement :: (node: Model.Statement, compiler: *Compiler) -> error: string {
    if #complete node.kind == {
        case .PRINT;
            error := compile_expression(node.print.expression, compiler);
            if error {
                return error;
            }

            array_add(
                *compiler.code,
                Instruction.{
                    kind = .PRINT,
                    print = {},
                }
            );
        case .PRINTLN;
            error := compile_expression(node.println.expression, compiler);
            if error {
                return error;
            }
            array_add(
                *compiler.code,
                Instruction.{
                    kind = .PRINTLN,
                    println = {},
                }
            );
        case .IF;
            error := compile_expression(node._if.test, compiler);
            if error {
                return error;
            }

            then_label := add_label(compiler);
            else_label := add_label(compiler);
            exit_label := add_label(compiler);

            array_add(
                *compiler.code,
                Instruction.{
                    kind = .JMPZ,
                    jmpz = {
                        label_name = else_label,
                    },
                }
            );
            array_add(
                *compiler.code,
                Instruction.{
                    kind = .LABEL,
                    label = {
                        name = then_label,
                    },
                },
            );

            compiler.scope_depth += 1;
            for then_statement: node._if.then_statements {
                error := compile_statement(then_statement, compiler);
                if error {
                    return error;
                }
            }
            descope(compiler);

            array_add(
                *compiler.code,
                Instruction.{
                    kind = .JMP,
                    jmp = {
                        label_name = exit_label,
                    },
                }
            );
            array_add(
                *compiler.code,
                Instruction.{
                    kind = .LABEL,
                    label = {
                        name = else_label,
                    },
                },
            );

            compiler.scope_depth += 1;
            for else_statement: node._if.else_statements {
                error := compile_statement(else_statement, compiler);
                if error {
                    return error;
                }
            }
            descope(compiler);

            array_add(
                *compiler.code,
                Instruction.{
                    kind = .LABEL,
                    label = {
                        name = exit_label,
                    },
                },
            );
        case .ASSIGNMENT;
            if node.assignment.left.kind != .IDENTIFIER {
                return make_error("Expected the left hand side of an assignment to be an identifier", node.assignment.line_number);
            }

            error := compile_expression(node.assignment.right, compiler);
            if error {
                return error;
            }

            ok, symbol, slot := get_symbol(compiler, node.assignment.left.identifier.name);
            if !ok {
                symbol = Symbol.{
                    name = node.assignment.left.identifier.name,
                    scope_depth = compiler.scope_depth,
                };

                if symbol.scope_depth > 0 {
                    array_add(*compiler.locals, symbol);
                    slot = compiler.locals.count - 1;
                } else {
                    array_add(*compiler.globals, symbol);
                    slot = compiler.globals.count - 1;
                }
            }

            if symbol.scope_depth > 0 {
                array_add(
                    *compiler.code,
                    Instruction.{
                        kind = .STORE_LOCAL,
                        store_local = {
                            slot = slot,
                        },
                    },
                );
            } else {
                array_add(
                    *compiler.code,
                    Instruction.{
                        kind = .STORE_GLOBAL,
                        store_global = {
                            name = symbol.name,
                        },
                    },
                );
            }
        case .LOCAL_ASSIGNMENT;
            assert(false, "local");
        case .WHILE;
            test_label := add_label(compiler);
            body_label := add_label(compiler);
            exit_label := add_label(compiler);

            array_add(
                *compiler.code,
                Instruction.{
                    kind = .LABEL,
                    label = {
                        name = test_label,
                    },
                },
            );

            error := compile_expression(node._while.test, compiler);
            if error {
                return error;
            }

            array_add(
                *compiler.code,
                Instruction.{
                    kind = .JMPZ,
                    jmpz = {
                        label_name = exit_label,
                    },
                }
            );

            array_add(
                *compiler.code,
                Instruction.{
                    kind = .LABEL,
                    label = {
                        name = body_label,
                    },
                },
            );

            compiler.scope_depth += 1;
            for statement: node._while.statements {
                error := compile_statement(statement, compiler);
                if error {
                    return error;
                }
            }
            descope(compiler);

            array_add(
                *compiler.code,
                Instruction.{
                    kind = .JMP,
                    jmp = {
                        label_name = test_label,
                    },
                }
            );

            array_add(
                *compiler.code,
                Instruction.{
                    kind = .LABEL,
                    label = {
                        name = exit_label,
                    },
                },
            );

        case .FOR;
            assert(false, "for");
        case .FUNCTION_DECLARATION;
            assert(false, "func decl");
        case .PARAMETER_DECLARATION;
            assert(false, "param decl");
        case .FUNCTION_CALL;
            assert(false, "func call");
        case .RETURN;
            assert(false, "return");
    }

    return "";
}

compile_expression :: (node: *Model.Expression, compiler: *Compiler) -> error: string {
    if #complete node.kind == {
        case .INTEGER;
            array_add(
                *compiler.code,
                Instruction.{
                    kind = .PUSH,
                    push = {
                        value = {
                            kind = .NUMBER,
                            number = cast(float64, node.integer.value),
                        }
                    }
                },
            );
        case .FLOAT;
            array_add(
                *compiler.code,
                Instruction.{
                    kind = .PUSH,
                    push = {
                        value = {
                            kind = .NUMBER,
                            number = node._float.value,
                        }
                    }
                },
            );
        case .BINARY_OPERATOR;
            error := compile_expression(node.binary_operator.lhs, compiler);
            if error {
                return error;
            }

            error = compile_expression(node.binary_operator.rhs, compiler);
            if error {
                return error;
            }

            if node.binary_operator.op.type == {
                case .PLUS;
                    array_add(
                        *compiler.code,
                        Instruction.{
                            kind = .ADD,
                            add = {},
                        },
                    );
                case .MINUS;
                    array_add(
                        *compiler.code,
                        Instruction.{
                            kind = .SUB,
                            sub = {},
                        },
                    );
                case .STAR;
                    array_add(
                        *compiler.code,
                        Instruction.{
                            kind = .MUL,
                            mul = {},
                        },
                    );
                case .SLASH;
                    array_add(
                        *compiler.code,
                        Instruction.{
                            kind = .DIV,
                            div = {},
                        },
                    );
                case .MODULO;
                    array_add(
                        *compiler.code,
                        Instruction.{
                            kind = .MOD,
                            mod = {},
                        },
                    );
                case .CARET;
                    array_add(
                        *compiler.code,
                        Instruction.{
                            kind = .EXP,
                            exp = {},
                        },
                    );
                case .LESS;
                    array_add(
                        *compiler.code,
                        Instruction.{
                            kind = .LT,
                            lt = {},
                        },
                    );
                case .GREATER;
                    array_add(
                        *compiler.code,
                        Instruction.{
                            kind = .GT,
                            gt = {},
                        },
                    );
                case .LESS_EQUALS;
                    array_add(
                        *compiler.code,
                        Instruction.{
                            kind = .LE,
                            le = {},
                        },
                    );
                case .GREATER_EQUALS;
                    array_add(
                        *compiler.code,
                        Instruction.{
                            kind = .GE,
                            ge = {},
                        },
                    );
                case .EQUALS_EQUALS;
                    array_add(
                        *compiler.code,
                        Instruction.{
                            kind = .EQ,
                            eq = {},
                        },
                    );
                case .NOT_EQUALS;
                    array_add(
                        *compiler.code,
                        Instruction.{
                            kind = .NE,
                            ne = {},
                        },
                    );
            }
        case .LOGICAL_OPERATOR;
            error := compile_expression(node.logical_operator.lhs, compiler);
            if error {
                return error;
            }

            error = compile_expression(node.logical_operator.rhs, compiler);
            if error {
                return error;
            }

            if node.logical_operator.op.type == {
                case .AND;
                    array_add(
                        *compiler.code,
                        Instruction.{
                            kind = .AND,
                            and = {},
                        },
                    );
                case .OR;
                    array_add(
                        *compiler.code,
                        Instruction.{
                            kind = .OR,
                            or = {},
                        },
                    );
            }
        case .UNARY_OPERATOR;
            error := compile_expression(node.unary_operator.operand, compiler);
            if error {
                return error;
            }

            if node.unary_operator.op.type == {
                case .NOT;
                    array_add(
                        *compiler.code,
                        Instruction.{
                            kind = .PUSH,
                            push = {
                                value = {
                                    kind = .BOOL,
                                    _bool = true,
                                },
                            },
                        },
                    );
                    array_add(
                        *compiler.code,
                        Instruction.{
                            kind = .XOR,
                            xor = {},
                        },
                    );
                case .MINUS;
                    array_add(
                        *compiler.code,
                        Instruction.{
                            kind = .NEG,
                            neg = {},
                        },
                    );
            }
        case .GROUPING;
            error := compile_expression(node.grouping.expression, compiler);
            if error {
                return error;
            }
        case .BOOL;
            array_add(
                *compiler.code,
                Instruction.{
                    kind = .PUSH,
                    push = {
                        value = {
                            kind = .BOOL,
                            _bool = node._bool.value,
                        }
                    }
                },
            );
        case .STRING;
            array_add(
                *compiler.code,
                Instruction.{
                    kind = .PUSH,
                    push = {
                        value = {
                            kind = .STRING,
                            _string = node._string.value,
                        }
                    }
                },
            );
        case .IDENTIFIER;
            ok, symbol, slot := get_symbol(compiler, node.identifier.name);
            if !ok {
                return make_error(tprint("Undeclared identifier %", node.identifier.name), node.identifier.line_number);
            }

            if symbol.scope_depth > 0 {
                array_add(
                    *compiler.code,
                    Instruction.{
                        kind = .LOAD_LOCAL,
                        load_local = {
                            slot = slot,
                        },
                    },
                );
            } else {
                array_add(
                    *compiler.code,
                    Instruction.{
                        kind = .LOAD_GLOBAL,
                        load_global = {
                            name = symbol.name,
                        },
                    },
                );
            }
        case .FUNCTION_CALL;
            assert(false, "func call");
    }

    return "";
}

add_label :: (compiler: *Compiler) -> string {
    compiler.label_counter += 1;

    return tprint("__LABEL_%", compiler.label_counter);
}

get_symbol :: (compiler: *Compiler, name: string) -> ok: bool, Symbol, slot: int {
    for symbol: compiler.locals {
        if symbol.name == name {
            return true, symbol, it_index;
        }
    }

    for symbol: compiler.globals {
        if symbol.name == name {
            return true, symbol, it_index;
        }
    }

    return false, {}, -1;
}

descope :: (compiler: *Compiler) {
    compiler.scope_depth -= 1;

    for < symbol: compiler.locals {
        if compiler.scope_depth == symbol.scope_depth {
            break;
        }

        remove symbol;

        array_add(
            *compiler.code,
            Instruction.{
                kind = .POP,
                pop = {},
            },
        );
    }
}

make_error :: (message: string, line_number: int) -> string {
    return tprint("Compilation error (line %): %", line_number, message);
}

#import "Basic";
Model :: #import,file "model.jai";
#import,file "instructions.jai";
