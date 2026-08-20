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

    apply_depth :: (builder: *String_Builder, depth: int) {
        for 1..depth {
            print(builder, "    ");
        }
    }

    for instruction: code {
        if #complete instruction.kind == {
            case .PUSH;
                apply_depth(*builder, depth);
                print(*builder, "PUSH ");
                if #complete instruction.push.value.kind == {
                    case .NUMBER;
                        print(*builder, "%\n", instruction.push.value.number);
                    case .STRING;
                        print(*builder, "%\n", instruction.push.value._string);
                    case .BOOL;
                        print(*builder, "%\n", instruction.push.value._bool);
                }
            case .ADD;
                apply_depth(*builder, depth);
                print(*builder, "ADD\n");
            case .SUB;
                apply_depth(*builder, depth);
                print(*builder, "SUB\n");
            case .PRINT;
                apply_depth(*builder, depth);
                print(*builder, "PRINT\n");
            case .PRINTLN;
                apply_depth(*builder, depth);
                print(*builder, "PRINTLN\n");
            case .MUL;
                apply_depth(*builder, depth);
                print(*builder, "MUL\n");
            case .DIV;
                apply_depth(*builder, depth);
                print(*builder, "DIV\n");
            case .MOD;
                apply_depth(*builder, depth);
                print(*builder, "MOD\n");
            case .EXP;
                apply_depth(*builder, depth);
                print(*builder, "EXP\n");
            case .LT;
                apply_depth(*builder, depth);
                print(*builder, "LT\n");
            case .GT;
                apply_depth(*builder, depth);
                print(*builder, "GT\n");
            case .LE;
                apply_depth(*builder, depth);
                print(*builder, "LE\n");
            case .GE;
                apply_depth(*builder, depth);
                print(*builder, "GE\n");
            case .EQ;
                apply_depth(*builder, depth);
                print(*builder, "EQ\n");
            case .NE;
                apply_depth(*builder, depth);
                print(*builder, "NE\n");
            case .LABEL;
                depth += 1;
                print(*builder, "%:\n", instruction.label.name);
            case .HALT;
                apply_depth(*builder, depth);
                print(*builder, "HALT\n");
            case .OR;
                apply_depth(*builder, depth);
                print(*builder, "OR\n");
            case .AND;
                apply_depth(*builder, depth);
                print(*builder, "AND\n");
            case .XOR;
                apply_depth(*builder, depth);
                print(*builder, "XOR\n");
            case .NEG;
                apply_depth(*builder, depth);
                print(*builder, "NEG\n");
        }
    }

    print(builder_to_string(*builder,, temp));
}



#scope_file

Instruction :: union kind: Instruction_Kind {
    .PUSH,,    push:    Push_Instruction;
    .ADD,,     add:     No_Operand_Instruction;
    .SUB,,     sub:     No_Operand_Instruction;
    .PRINT,,   print:   No_Operand_Instruction;
    .PRINTLN,, println: No_Operand_Instruction;
    .MUL,,     mul:     No_Operand_Instruction;
    .DIV,,     div:     No_Operand_Instruction;
    .MOD,,     mod:     No_Operand_Instruction;
    .EXP,,     exp:     No_Operand_Instruction;
    .LT,,      lt:      No_Operand_Instruction;
    .GT,,      gt:      No_Operand_Instruction;
    .LE,,      le:      No_Operand_Instruction;
    .GE,,      ge:      No_Operand_Instruction;
    .EQ,,      eq:      No_Operand_Instruction;
    .NE,,      ne:      No_Operand_Instruction;
    .LABEL,,   label:   Label_Instruction;
    .HALT,,    halt:    No_Operand_Instruction;
    .AND,,     and:     No_Operand_Instruction;
    .OR,,      or:      No_Operand_Instruction;
    .XOR,,     xor:     No_Operand_Instruction;
    .NEG,,     neg:     No_Operand_Instruction;
}

Instruction_Kind :: enum {
    PUSH;
    ADD;
    SUB;
    PRINT;
    PRINTLN;
    MUL;
    DIV;
    MOD;
    EXP;
    LT;
    GT;
    LE;
    GE;
    EQ;
    NE;
    LABEL;
    HALT;
    AND;
    OR;
    XOR;
    NEG;
}

Push_Instruction :: struct {
    value:  Value;
}

No_Operand_Instruction :: struct {}

Label_Instruction :: struct {
    name: string;
}

Value :: union kind: Value_Type {
    .NUMBER,, number:  float64;
    .STRING,, _string: string;
    .BOOL,,   _bool:   bool;
}

Value_Type :: enum {
    NUMBER;
    STRING;
    BOOL;
}

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
                case .EQUALS;
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
                                    kind = .NUMBER,
                                    number = 1,
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
            assert(false, "group");
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
