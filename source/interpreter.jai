interpret :: (ast: Model.AST, node_index: int) -> error: string, float64 {
    node := ast.expressions[node_index];

    if #complete node.kind == {
        case .INTEGER;
            return "", cast(float64, node.integer.value);
        case .FLOAT;
            return "", node._float.value;
        case .GROUPING;
            error, result := interpret(ast, node.grouping.index);
            return error, result;
        case .BINARY_OPERATOR;
            error, left_value := interpret(ast, node.binary_operator.lhs_index);
            if error {
                return error, -1;
            }

            error =, right_value := interpret(ast, node.binary_operator.rhs_index);
            if error {
                return error, -1;
            }

            if node.binary_operator.op.type == {
                case .PLUS;
                    return "", left_value + right_value;
                case .MINUS;
                    return "", left_value - right_value;
                case .STAR;
                    return "", left_value * right_value;
                case .SLASH;
                    return "", left_value / right_value;
            }
        case .UNARY_OPERATOR;
            error, operand := interpret(ast, node.unary_operator.operand_index);
            if error {
                return error, -1;
            }

            if node.unary_operator.op.type == {
                case .PLUS;
                    return "", +operand;
                case .MINUS;
                    return "", -operand;
                case .NOT;
                    return "The NOT operator is not supported yet", -1;
            }
    }

    return "Somehow your stinky code had a node that is unknown for the interpreter", -1;
}



#scope_file

#import "Basic";
Model :: #import,file "model.jai";
#import,file "token.jai";
