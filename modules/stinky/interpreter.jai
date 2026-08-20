Stinky_Type :: enum {
    NONE;
    NUMBER;
    STRING;
    BOOL;
}

Stinky_Value :: union kind: Stinky_Type {
    .NONE,,   none:    void;
    .NUMBER,, number:  float64;
    .STRING,, _string: string;
    .BOOL,,   _bool:   bool;
}

interpret :: (ast: Model.AST) -> error: string, Stinky_Value {
    environment: Environment;
    defer deinit(*environment.variables);
    defer deinit(*environment.functions);

    error, value := interpret_statements(ast.statements, *environment);

    return error, value;
}



#scope_file

Environment :: struct {
    variables: Table(string, Stinky_Value);
    functions: Table(string, Stinky_Function);
    parent:    *Environment;

    variables.allocator = temp; // @Todo: maybe we can come up with something more interesting
    functions.allocator = temp;
}

Stinky_Function :: struct {
    declaration: Model.Function_Declaration;
    environment: *Environment;
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

set_local_variable_into_environment :: (name: string, value: Stinky_Value, environment: *Environment) {
    if environment == null {
        return;
    }

    table_set(*environment.variables, name, value);
}

update_or_set_variable_into_environment_recursively :: (name: string, value: Stinky_Value, environment: *Environment) {
    if environment == null {
        return;
    }

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

get_function_from_environment :: (name: string, environment: *Environment) -> ok: bool, Stinky_Function {
    if environment == null {
        return false, .{};
    }

    ok, value := table_find(*environment.functions, name);
    if !ok {
        ok, value = get_function_from_environment(name, environment.parent);
    }

    return ok, value;
}

set_function_into_environment :: (name: string, value: Stinky_Function, environment: *Environment) {
    if environment == null {
        return;
    }

    table_set(*environment.functions, name, value);
}

interpret_statements :: (statements: [..]Model.Statement, environment: *Environment) -> error: string, value: Stinky_Value {
    for node: statements {
        error, value := interpret_statement(node, environment);
        if value.kind != .NONE {
            return "", value;
        }
        if error {
            return error, .{};;
        }
    }

    return "", .{};
}

interpret_statement :: (node: Model.Statement, environment: *Environment) -> error: string, value: Stinky_Value {
    if #complete node.kind == {
        case .RETURN;
            error, value := interpret_expression(node._return.expression, environment);
            return error, value;
        case .FUNCTION_DECLARATION;
            set_function_into_environment(node.function_declaration.name, { node.function_declaration, environment }, environment);
        case .PARAMETER_DECLARATION;
            // Do nothing
        case .FUNCTION_CALL;
            error, value := interpret_expression(node.function_call.expression, environment);
            if error {
                return error, value ;
            }
        case .PRINT;
            error, value := interpret_expression(node.print.expression, environment);
            if error {
                return error, .{};
            }
            if #complete value.kind == {
                case .NONE;
                    print("NONE");
                case .NUMBER;
                    print("%", value.number);
                case .STRING;
                    print("%", value._string);
                case .BOOL;
                    print("%", value._bool);
            }
        case .PRINTLN;
            error, value := interpret_expression(node.println.expression, environment);
            if error {
                return error, .{};
            }
            if #complete value.kind == {
                case .NONE;
                    print("NONE\n");
                case .NUMBER;
                    print("%\n", value.number);
                case .STRING;
                    print("%\n", value._string);
                case .BOOL;
                    print("%\n", value._bool);
            }
        case .IF;
            error, test := interpret_expression(node._if.test, environment);
            if error {
                return error, .{};
            }

            if test.kind != .BOOL {
                return make_error("Expected a stinky if test to evaluate to a bool", node._if.line_number),
                    {};
            }

            if test._bool == true {
                error =, value := interpret_statements(node._if.then_statements, *new_environment(environment));
                if error {
                    return error, .{};
                }
                if value.kind != .NONE {
                    return "", value;
                }
            } else {
                error =, value := interpret_statements(node._if.else_statements, *new_environment(environment));
                if error {
                    return error, .{};
                }
                if value.kind != .NONE {
                    return "", value;
                }
            }
        case .ASSIGNMENT;
            error, right := interpret_expression(node.assignment.right, environment);
            if error {
                return error, .{};
            }

            if node.assignment.left.kind != .IDENTIFIER {
                return make_error("Expected the left side of the assignment to be an identifier", node.assignment.line_number),
                    {};
            }
            _, left_value := get_variable_from_environment(node.assignment.left.identifier.name, environment);
            update_or_set_variable_into_environment_recursively(node.assignment.left.identifier.name, right, environment);
        case .LOCAL_ASSIGNMENT;
            error, right := interpret_expression(node.assignment.right, environment);
            if error {
                return error, .{};
            }

            if node.assignment.left.kind != .IDENTIFIER {
                return make_error("Expected the left side of the assignment to be an identifier", node.assignment.line_number),
                    .{};
            }
            _, left_value := get_variable_from_environment(node.assignment.left.identifier.name, environment);
            set_local_variable_into_environment(node.assignment.left.identifier.name, right, environment);
        case .WHILE;
            while true {
                error, test := interpret_expression(node._while.test, environment);
                if error {
                    return error, {};
                }

                if test.kind != .BOOL {
                    return make_error("Expected a stinky while test to evaluate to a bool", node._while.line_number),
                        .{};
                }

                if test._bool == false {
                    break;
                }

                error =, value := interpret_statements(node._while.statements, *new_environment(environment));
                if error {
                    return error, .{};
                }
                if value.kind != .NONE {
                    return "", value;
                }
            }
        case .FOR;
            error, iterator := interpret_expression(node._for.start, environment);
            if error {
                return error, .{};
            }
            if iterator.kind != .NUMBER {
                return make_error("Expected a stinky for loop iterator to be a number", node._for.line_number),
                    .{};
            }

            error =, end := interpret_expression(node._for.end, environment);
            if error {
                return error, .{};
            }
            if end.kind != .NUMBER {
                return make_error("Expected a stinky for loop end to be a number", node._for.line_number),
                    .{};
            }

            step: float64;
            if node._for.step == null {
                step = 1;
            } else {
                error, stinky_step := interpret_expression(node._for.step, environment);
                if error {
                    return error, .{};
                }
                if stinky_step.kind != .NUMBER {
                    return make_error("Expected a stinky for loop step to be a number", node._for.line_number),
                        .{};
                }

                step = stinky_step.number;
            }

            loop_environment := new_environment(environment);
            if iterator.number < end.number {
                while iterator.number <= end.number {
                    set_local_variable_into_environment(
                        node._for.identifier.identifier.name,
                        iterator,
                        *loop_environment,
                    );

                    error, value := interpret_statements(node._for.statements, *loop_environment);
                    if error {
                        return error, .{};
                    }
                    if value.kind != .NONE {
                        return "", value;
                    }

                    iterator.number += step;
                }
            } else {
                while iterator.number >= end.number {
                    set_local_variable_into_environment(
                        node._for.identifier.identifier.name,
                        iterator,
                        *loop_environment,
                    );

                    error, value := interpret_statements(node._for.statements, *loop_environment);
                    if error {
                        return error, .{};
                    }
                    if value.kind != .NONE {
                        return "", value;
                    }

                    iterator.number += step;
                }
            }
    }

    return "", .{};
}

interpret_expression :: (node: *Model.Expression, environment: *Environment) -> error: string, Stinky_Value {
    if #complete node.kind == {
        case .FUNCTION_CALL;
            ok, function := get_function_from_environment(node.function_call.name, environment);
            if !ok {
                return make_error(tprint("Undeclared function '%'", node.function_call.name), node.function_call.line_number),
                    .{};
            }
            if node.function_call.arguments.count != function.declaration.parameters.count {
                return make_error(tprint("Wrong argument count for function '%'", node.function_call.name), node.function_call.line_number),
                    .{};
            }

            arguments: [..]Stinky_Value;
            arguments.allocator = temp;
            for argument: node.function_call.arguments {
                error, argument_value := interpret_expression(argument, environment);
                if error {
                    return error, .{};
                }

                array_add(*arguments, argument_value);
            }

            function_environment := new_environment(function.environment);

            for parameter: function.declaration.parameters {
                set_local_variable_into_environment(parameter.parameter_declaration.name, arguments[it_index], *function_environment);
            }

            error, value := interpret_statements(function.declaration.statements, *function_environment);
            if error {
                return error, .{};
            }

            return "", value;
        case .IDENTIFIER;
            ok, value := get_variable_from_environment(node.identifier.name, environment);
            if !ok {
                return make_error(tprint("Undeclared identifier '%'", node.identifier.name), node.identifier.line_number),
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
            error, result := interpret_expression(node.grouping.expression, environment);
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
                            case .NONE;
                                return "", {
                                    kind = .STRING,
                                    _string = tprint("%%", left._string, right.none),
                                };
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
                            case .NONE;
                                return "", {
                                    kind = .STRING,
                                    _string = tprint("%%", left.none, right._string),
                                };
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

    return make_error("Somehow your stinky code had a node that is unknown for the interpreter", 0),
        {};
}

make_error :: (message: string, line_number: int) -> string {
    return tprint("Runtime error (line %): %", line_number, message);
}

make_unsupported_operands_error :: (op: string, lhs_type: Stinky_Type, rhs_type: Stinky_Type, line_number: int) -> string {
    return tprint(
        "Runtime error (line %): You are using the '%' operator in your stinky code with '%' and '%', but '%' can't works with these types",
        line_number,
        op,
        lhs_type,
        rhs_type,
        op,
    );
};

make_unsupported_operand_error :: (op: string, operand_type: Stinky_Type, line_number: int) -> string {
    return tprint(
        "Runtime error (line %): You are using the '%' operator in your stinky code with '%', but '%' can't works with that type",
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
