compile :: (ast: Model.AST) -> [..]Instruction {
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
        compile_statement(statement, *compiler);
    }

    array_add(
        *compiler.code,
        Instruction.{
            kind = .HALT,
            halt = {},
        },
    );

    return compiler.code;
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

Compiler :: struct {
    code:          [..]Instruction;
    label_counter: int;
}

compile_statement :: (node: Model.Statement, compiler: *Compiler) {
    if #complete node.kind == {
        case .PRINT;
            compile_expression(node.print.expression, compiler);
            array_add(
                *compiler.code,
                Instruction.{
                    kind = .PRINT,
                    print = {},
                }
            );
        case .PRINTLN;
            compile_expression(node.print.expression, compiler);
            array_add(
                *compiler.code,
                Instruction.{
                    kind = .PRINTLN,
                    println = {},
                }
            );
        case .IF;
            compile_expression(node._if.test, compiler);

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

            for then_statement: node._if.then_statements {
                compile_statement(then_statement, compiler);
            }

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

            for then_statement: node._if.else_statements {
                compile_statement(then_statement, compiler);
            }

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
            assert(false, "assignment");
        case .LOCAL_ASSIGNMENT;
            assert(false, "local");
        case .WHILE;
            assert(false, "while");
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
}

compile_expression :: (node: *Model.Expression, compiler: *Compiler) {
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
            compile_expression(node.binary_operator.lhs, compiler);
            compile_expression(node.binary_operator.rhs, compiler);
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
            compile_expression(node.logical_operator.lhs, compiler);
            compile_expression(node.logical_operator.rhs, compiler);
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
            compile_expression(node.unary_operator.operand, compiler);

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
            compile_expression(node.grouping.expression, compiler);
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
            assert(false, "ident");
        case .FUNCTION_CALL;
            assert(false, "func call");
    }
}

add_label :: (compiler: *Compiler) -> string {
    compiler.label_counter += 1;

    return tprint("__LABEL_%", compiler.label_counter);
}

make_error :: (format_string: string, args: ..Any) -> string {
    return tprint(format_string, args);
}

#import "Basic";
Model :: #import,file "model.jai";
#import,file "instructions.jai";
