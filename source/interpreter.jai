interpret :: (ast: Model.AST, node_index: int) -> error: string, Stinky_Value {
    node := ast.expressions[node_index];

    if #complete node.kind == {
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
            error, result := interpret(ast, node.grouping.index);
            return error, result;
        case .BINARY_OPERATOR;
            error, left := interpret(ast, node.binary_operator.lhs_index);
            if error {
                return error, {};
            }

            error =, right := interpret(ast, node.binary_operator.rhs_index);
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
                    } else if left.kind == .STRING || right.kind == .STRING {
                        return "", {
                            kind = .STRING,
                            _string = tprint("%%", left._string, right._string),
                        };
                    } else {
                        return make_unsupported_operands_error("+", left.kind, right.kind),
                            {};
                    }
                case .MINUS;
                    if left.kind == .NUMBER && right.kind == .NUMBER {
                        return "", {
                            kind = .NUMBER,
                            number = left.number - right.number,
                        };
                    } else {
                        return make_unsupported_operands_error("-", left.kind, right.kind),
                            {};
                    }
                case .STAR;
                    if left.kind == .NUMBER && right.kind == .NUMBER {
                        return "", {
                            kind = .NUMBER,
                            number = left.number * right.number,
                        };
                    } else {
                        return make_unsupported_operands_error("*", left.kind, right.kind),
                            {};
                    }
                case .SLASH;
                    if left.kind == .NUMBER && right.kind == .NUMBER {
                        return "", {
                            kind = .NUMBER,
                            number = left.number / right.number,
                        };
                    } else {
                        return make_unsupported_operands_error("/", left.kind, right.kind),
                            {};
                    }
            }
        case .UNARY_OPERATOR;
            error, operand := interpret(ast, node.unary_operator.operand_index);
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
                        return make_unsupported_operand_error("+", operand.kind),
                            {};
                    }
                case .MINUS;
                    if operand.kind == .NUMBER {
                        return "", {
                            kind = .NUMBER,
                            number = -operand.number,
                        };
                    } else {
                        return make_unsupported_operand_error("-", operand.kind),
                            {};
                    }
                case .NOT;
                    if operand.kind == .BOOL {
                        return "", {
                            kind = .BOOL,
                            _bool = !operand._bool,
                        };
                    } else {
                        return make_unsupported_operand_error("~", operand.kind),
                            {};
                    }
            }
    }

    return "Somehow your stinky code had a node that is unknown for the interpreter", {};
}



#scope_file

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

make_unsupported_operands_error :: (op: string, lhs_type: Stinky_Type, rhs_type: Stinky_Type) -> string {
    return tprint("You are using the '%' operator in your stinky code with '%' and '%', but '%' can't works with these types", op, lhs_type, rhs_type, op);
};

make_unsupported_operand_error :: (op: string, operand_type: Stinky_Type) -> string {
    return tprint("You are using the '%' operator in your stinky code with '%', but '%' can't works with that type", op, operand_type, op);
}

#import "Basic";
Model :: #import,file "model.jai";
#import,file "token.jai";
