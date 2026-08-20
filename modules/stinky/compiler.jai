compile :: (ast: Model.AST) -> [..]Instruction {
    push_allocator(temp);

    code: [..]Instruction;

    array_add(
        *code,
        Instruction.{
            kind = .LABEL,
            label = {
                name = "START",
            },
        },
    );

    for statement: ast.statements {
        compile_statement(statement, *code);
    }

    array_add(
        *code,
        Instruction.{
            kind = .HALT,
            halt = {},
        },
    );

    return code;
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

compile_statement :: (node: Model.Statement, code: *[..]Instruction) {
    if #complete node.kind == {
        case .PRINT;
            compile_expression(node.print.expression, code);
            array_add(
                code,
                Instruction.{
                    kind = .PRINT,
                    print = {},
                }
            );
        case .PRINTLN;
            compile_expression(node.print.expression, code);
            array_add(
                code,
                Instruction.{
                    kind = .PRINTLN,
                    println = {},
                }
            );
        case .IF;
            assert(false, "if");
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

compile_expression :: (node: *Model.Expression, code: *[..]Instruction) {
    if #complete node.kind == {
        case .INTEGER;
            array_add(
                code,
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
                code,
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
            compile_expression(node.binary_operator.lhs, code);
            compile_expression(node.binary_operator.rhs, code);
            if node.binary_operator.op.type == {
                case .PLUS;
                    array_add(
                        code,
                        Instruction.{
                            kind = .ADD,
                            add = {},
                        },
                    );
                case .MINUS;
                    array_add(
                        code,
                        Instruction.{
                            kind = .SUB,
                            sub = {},
                        },
                    );
                case .STAR;
                    array_add(
                        code,
                        Instruction.{
                            kind = .MUL,
                            mul = {},
                        },
                    );
                case .SLASH;
                    array_add(
                        code,
                        Instruction.{
                            kind = .DIV,
                            div = {},
                        },
                    );
                case .MODULO;
                    array_add(
                        code,
                        Instruction.{
                            kind = .MOD,
                            mod = {},
                        },
                    );
                case .CARET;
                    array_add(
                        code,
                        Instruction.{
                            kind = .EXP,
                            exp = {},
                        },
                    );
                case .LESS;
                    array_add(
                        code,
                        Instruction.{
                            kind = .LT,
                            lt = {},
                        },
                    );
                case .GREATER;
                    array_add(
                        code,
                        Instruction.{
                            kind = .GT,
                            gt = {},
                        },
                    );
                case .LESS_EQUALS;
                    array_add(
                        code,
                        Instruction.{
                            kind = .LE,
                            le = {},
                        },
                    );
                case .GREATER_EQUALS;
                    array_add(
                        code,
                        Instruction.{
                            kind = .GE,
                            ge = {},
                        },
                    );
                case .EQUALS_EQUALS;
                    array_add(
                        code,
                        Instruction.{
                            kind = .EQ,
                            eq = {},
                        },
                    );
                case .NOT_EQUALS;
                    array_add(
                        code,
                        Instruction.{
                            kind = .NE,
                            ne = {},
                        },
                    );
            }
        case .LOGICAL_OPERATOR;
            compile_expression(node.logical_operator.lhs, code);
            compile_expression(node.logical_operator.rhs, code);
            if node.logical_operator.op.type == {
                case .AND;
                    array_add(
                        code,
                        Instruction.{
                            kind = .AND,
                            and = {},
                        },
                    );
                case .OR;
                    array_add(
                        code,
                        Instruction.{
                            kind = .OR,
                            or = {},
                        },
                    );
            }
        case .UNARY_OPERATOR;
            compile_expression(node.unary_operator.operand, code);

            if node.unary_operator.op.type == {
                case .NOT;
                    array_add(
                        code,
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
                        code,
                        Instruction.{
                            kind = .XOR,
                            xor = {},
                        },
                    );
                case .MINUS;
                    array_add(
                        code,
                        Instruction.{
                            kind = .NEG,
                            neg = {},
                        },
                    );
            }
        case .GROUPING;
            compile_expression(node.grouping.expression, code);
        case .BOOL;
            array_add(
                code,
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
                code,
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

make_error :: (format_string: string, args: ..Any) -> string {
    return tprint(format_string, args);
}

#import "Basic";
Model :: #import,file "model.jai";
#import,file "instructions.jai";
