interpret :: (ast: Model.AST) -> error: string {
    environment: Environment;
    defer deinit(*environment.variables);

    error := interpret_statements(ast.statements, *environment);

    return error;
}



#scope_file

Environment :: struct {
    variables: Table(string, Stinky_Value);
    parent:    *Environment;

    variables.allocator = temp; // @Todo: maybe we can come up with something more interesting
}

Stinky_Type :: enum {
    NUMBER;
    STRING;
    BOOL;
}

Stinky_Value :: union kind: Stinky_Type {
    .NUMBER,, number:  float64;
    .STRING,, _string: string;
    .BOOL,,   _bool:   bool;
}

new_environment :: (environment: *Environment) -> Environment {
    new: Environment;
    new.parent = environment;

    return new;
}

get_variable_from_environment :: (name: string, environment: *Environment) -> ok: bool, Stinky_Value {
    if environment == null {
        return false, .{};
    }

    ok, value := table_find(*environment.variables, name);
    if !ok {
        ok, value = get_variable_from_environment(name, environment.parent);
    }

    return ok, value;
}

set_variable_into_environment :: (name: string, value: Stinky_Value, environment: *Environment) {
    // Traverse parents to set the variable if it is in a outer scope
    current := environment;
    while current != null {
        does_contain := table_contains(*current.variables, name);
        if does_contain {
            table_set(*current.variables, name, value);

            return;
        } else {
            current = current.parent;
        }
    }

    // Set in the original scope if we didn't find the variable
    table_set(*environment.variables, name, value);
}

interpret_statements :: (statements: Model.Statements, environment: *Environment) -> error: string {
    for node: statements.statements {
        error := interprete_statement(node, environment);
        if error {
            return error;
        }
    }

    return "";
}

interprete_statement :: (node: Model.Statement, environment: *Environment) -> error: string {
    if #complete node.kind == {
        case .PRINT;
            error, value := interpret_expression(node.print_statement.value, environment);
            if error {
                return error;
            }
            if #complete value.kind == {
                case .NUMBER;
                    print("%", value.number);
                case .STRING;
                    print("%", value._string);
                case .BOOL;
                    print("%", value._bool);
            }
        case .PRINTLN;
            error, value := interpret_expression(node.println_statement.value, environment);
            if error {
                return error;
            }
            if #complete value.kind == {
                case .NUMBER;
                    print("%\n", value.number);
                case .STRING;
                    print("%\n", value._string);
                case .BOOL;
                    print("%\n", value._bool);
            }
        case .IF;
            error, test := interpret_expression(node.if_statement.test, environment);
            if error {
                return error;
            }

            if test.kind != .BOOL {
                return tprint("Line %: Expected a stinky if test to evaluate to a bool", node.if_statement.line_number);
            }

            if test._bool == true {
                error = interpret_statements(node.if_statement.then_statements, *new_environment(environment));
                if error {
                    return error;
                }
            } else {
                error = interpret_statements(node.if_statement.else_statements, *new_environment(environment));
                if error {
                    return error;
                }
            }
        case .ASSIGNMENT;
            error, right := interpret_expression(node.assignment.right, environment);
            if error {
                return error;
            }

            if node.assignment.left.kind != .IDENTIFIER {
                return tprint("Line: %: Expected the left side of the assignment to be an identifier", node.assignment.line_number);
            }
            _, left_value := get_variable_from_environment(node.assignment.left.identifier.name, environment);
            set_variable_into_environment(node.assignment.left.identifier.name, right, environment);
        case .WHILE;
            while true {
                error, test := interpret_expression(node.while_statement.test, environment);
                if error {
                    return error;
                }

                if test.kind != .BOOL {
                    return tprint("Line: %: Expected a stinky while test to evaluate to a bool", node.while_statement.line_number);
                }

                if test._bool == false {
                    break;
                }

                error = interpret_statements(node.while_statement.statements, *new_environment(environment));
                if error {
                    return error;
                }
            }
    }

    return "";
}

interpret_expression :: (node: Model.Expression, environment: *Environment) -> error: string, Stinky_Value {
    if #complete node.kind == {
        case .IDENTIFIER;
            ok, value := get_variable_from_environment(node.identifier.name, environment);
            if !ok {
                return tprint("Line %: Undeclared identifier '%'", node.identifier.line_number, node.identifier.name),
                    .{};
            }

            return "", value;
        case .INTEGER;
            return "", {
                kind = .NUMBER,
                number = cast(float64, node.integer.value),
            };
        case .FLOAT;
            return "", {
                kind = .NUMBER,
                number = node._float.value,
            };
        case .BOOL;
            return "", {
                kind = .BOOL,
                _bool = node._bool.value,
            };
        case .STRING;
            return "", {
                kind = .STRING,
                _string = node._string.value,
            };
        case .GROUPING;
            error, result := interpret_expression(node.grouping.value, environment);
            return error, result;
        case .LOGICAL_OPERATOR;
            if node.logical_operator.op.type == {
                case .AND;
                    error, left := interpret_expression(node.logical_operator.lhs, environment);
                    if error {
                        return error, {};
                    }
                    if left.kind != .BOOL {
                        return make_unsupported_operand_error("and", left.kind, node.logical_operator.line_number),
                            {};
                    }
                    if left._bool == false {
                        return "", left;
                    }

                    error =, right := interpret_expression(node.logical_operator.rhs, environment);
                    if error {
                        return error, {};
                    }
                    if right.kind != .BOOL {
                        return make_unsupported_operand_error("and", right.kind, node.logical_operator.line_number),
                            {};
                    }

                    return "", right;
                case .OR;
                    error, left := interpret_expression(node.logical_operator.lhs, environment);
                    if error {
                        return error, {};
                    }
                    if left.kind != .BOOL {
                        return make_unsupported_operand_error("or", left.kind, node.logical_operator.line_number),
                            {};
                    }
                    if left._bool == true {
                        return "", left;
                    }

                    error =, right := interpret_expression(node.logical_operator.rhs, environment);
                    if error {
                        return error, {};
                    }
                    if right.kind != .BOOL {
                        return make_unsupported_operand_error("or", right.kind, node.logical_operator.line_number),
                            {};
                    }

                    return "", right;
            }
        case .BINARY_OPERATOR;
            error, left := interpret_expression(node.binary_operator.lhs, environment);
            if error {
                return error, {};
            }

            error =, right := interpret_expression(node.binary_operator.rhs, environment);
            if error {
                return error, {};
            }

            if node.binary_operator.op.type == {
                case .PLUS;
                    if left.kind == .NUMBER && right.kind == .NUMBER {
                        return "", {
                            kind = .NUMBER,
                            number = left.number + right.number,
                        };
                    } else if left.kind == .STRING {
                        if #complete right.kind == {
                            case .NUMBER;
                                return "", {
                                    kind = .STRING,
                                    _string = tprint("%%", left._string, right.number),
                                };
                            case .BOOL;
                                return "", {
                                    kind = .STRING,
                                    _string = tprint("%%", left._string, right._bool),
                                };
                            case .STRING;
                                return "", {
                                    kind = .STRING,
                                    _string = tprint("%%", left._string, right._string),
                                };
                        }
                    } else if right.kind == .STRING {
                        if #complete left.kind == {
                            case .NUMBER;
                                return "", {
                                    kind = .STRING,
                                    _string = tprint("%%", left.number, right._string),
                                };
                            case .BOOL;
                                return "", {
                                    kind = .STRING,
                                    _string = tprint("%%", left._bool, right._string),
                                };
                            case .STRING;
                                return "", {
                                    kind = .STRING,
                                    _string = tprint("%%", left._string, right._string),
                                };
                        }
                    } else {
                        return make_unsupported_operands_error("+", left.kind, right.kind, node.binary_operator.line_number),
                            {};
                    }
                case .MINUS;
                    if left.kind == .NUMBER && right.kind == .NUMBER {
                        return "", {
                            kind = .NUMBER,
                            number = left.number - right.number,
                        };
                    } else {
                        return make_unsupported_operands_error("-", left.kind, right.kind, node.binary_operator.line_number),
                            {};
                    }
                case .STAR;
                    if left.kind == .NUMBER && right.kind == .NUMBER {
                        return "", {
                            kind = .NUMBER,
                            number = left.number * right.number,
                        };
                    } else {
                        return make_unsupported_operands_error("*", left.kind, right.kind, node.binary_operator.line_number),
                            {};
                    }
                case .SLASH;
                    if left.kind == .NUMBER && right.kind == .NUMBER {
                        return "", {
                            kind = .NUMBER,
                            number = left.number / right.number,
                        };
                    } else {
                        return make_unsupported_operands_error("/", left.kind, right.kind, node.binary_operator.line_number),
                            {};
                    }
                case .MODULO;
                    if left.kind == .NUMBER && right.kind == .NUMBER {
                        return "", {
                            kind = .NUMBER,
                            number = cast(float64, cast(int, left.number) % xx right.number),
                        };
                    } else {
                        return make_unsupported_operands_error("%", left.kind, right.kind, node.binary_operator.line_number),
                            {};
                    }
                case .CARET;
                    if left.kind == .NUMBER && right.kind == .NUMBER {
                        return "", {
                            kind = .NUMBER,
                            number = pow(left.number, right.number),
                        };
                    } else {
                        return make_unsupported_operands_error("^", left.kind, right.kind, node.binary_operator.line_number),
                            {};
                    }
                case .GREATER;
                    if left.kind == .NUMBER && right.kind == .NUMBER {
                        return "", {
                            kind = .BOOL,
                            _bool = left.number > right.number,
                        };
                    } else {
                        return make_unsupported_operands_error(">", left.kind, right.kind, node.binary_operator.line_number),
                            {};
                    }
                case .GREATER_EQUALS;
                    if left.kind == .NUMBER && right.kind == .NUMBER {
                        return "", {
                            kind = .BOOL,
                            _bool = left.number >= right.number,
                        };
                    } else {
                        return make_unsupported_operands_error(">=", left.kind, right.kind, node.binary_operator.line_number),
                            {};
                    }
                case .LESS;
                    if left.kind == .NUMBER && right.kind == .NUMBER {
                        return "", {
                            kind = .BOOL,
                            _bool = left.number < right.number,
                        };
                    } else {
                        return make_unsupported_operands_error("<", left.kind, right.kind, node.binary_operator.line_number),
                            {};
                    }
                case .LESS_EQUALS;
                    if left.kind == .NUMBER && right.kind == .NUMBER {
                        return "", {
                            kind = .BOOL,
                            _bool = left.number <= right.number,
                        };
                    } else {
                        return make_unsupported_operands_error("<=", left.kind, right.kind, node.binary_operator.line_number),
                            {};
                    }
                case .EQUALS_EQUALS;
                    if left.kind == .NUMBER && right.kind == .NUMBER {
                        return "", {
                            kind = .BOOL,
                            _bool = left.number == right.number,
                        };
                    } else if left.kind == .BOOL && right.kind == .BOOL {
                        return "", {
                            kind = .BOOL,
                            _bool = left._bool == right._bool,
                        };
                    } else if left.kind == .STRING && right.kind == .STRING {
                        return "", {
                            kind = .BOOL,
                            _bool = left._string == right._string,
                        };
                    } else {
                        return make_unsupported_operands_error("==", left.kind, right.kind, node.binary_operator.line_number),
                            {};
                    }
                case .NOT_EQUALS;
                    if left.kind == .NUMBER && right.kind == .NUMBER {
                        return "", {
                            kind = .BOOL,
                            _bool = left.number != right.number,
                        };
                    } else if left.kind == .BOOL && right.kind == .BOOL {
                        return "", {
                            kind = .BOOL,
                            _bool = left._bool != right._bool,
                        };
                    } else if left.kind == .STRING && right.kind == .STRING {
                        return "", {
                            kind = .BOOL,
                            _bool = left._string != right._string,
                        };
                    } else {
                        return make_unsupported_operands_error("!=", left.kind, right.kind, node.binary_operator.line_number),
                            {};
                    }
            }
        case .UNARY_OPERATOR;
            error, operand := interpret_expression(node.unary_operator.operand, environment);
            if error {
                return error, {};
            }

            if node.unary_operator.op.type == {
                case .PLUS;
                    if operand.kind == .NUMBER {
                        return "", {
                            kind = .NUMBER,
                            number = +operand.number,
                        };
                    } else {
                        return make_unsupported_operand_error("+", operand.kind, node.unary_operator.line_number),
                            {};
                    }
                case .MINUS;
                    if operand.kind == .NUMBER {
                        return "", {
                            kind = .NUMBER,
                            number = -operand.number,
                        };
                    } else {
                        return make_unsupported_operand_error("-", operand.kind, node.unary_operator.line_number),
                            {};
                    }
                case .NOT;
                    if operand.kind == .BOOL {
                        return "", {
                            kind = .BOOL,
                            _bool = !operand._bool,
                        };
                    } else {
                        return make_unsupported_operand_error("~", operand.kind, node.unary_operator.line_number),
                            {};
                    }
            }
    }

    return "Somehow your stinky code had a node that is unknown for the interpreter", {};
}

make_unsupported_operands_error :: (op: string, lhs_type: Stinky_Type, rhs_type: Stinky_Type, line_number: int) -> string {
    return tprint(
        "Line %: You are using the '%' operator in your stinky code with '%' and '%', but '%' can't works with these types",
        line_number,
        op,
        lhs_type,
        rhs_type,
        op,
    );
};

make_unsupported_operand_error :: (op: string, operand_type: Stinky_Type, line_number: int) -> string {
    return tprint(
        "Line %: You are using the '%' operator in your stinky code with '%', but '%' can't works with that type",
        line_number,
        op,
        operand_type,
        op,
    );
}

#import "Basic";
#import "Math";
#import "Hash_Table";
Model :: #import,file "model.jai";
#import,file "token.jai";
