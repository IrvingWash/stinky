AST :: struct {
    expressions: [..]Model.Expression;
    root_index:  int = -1;
}

make_ast :: (tokens: []Token) -> error: string, AST {
    ast: AST;

    if tokens.count < 1 {
        return "Your stinky code doesn't contain any tokens, so we are unable to parse them, sorry!", ast;
    }

    current_index: int;

    error:, ast.root_index = get_expression(tokens, *current_index, *ast.expressions);
    return error, ast;
}

destroy_ast :: (ast: *AST) {
    array_free(ast.expressions);
    ast.* = {};
}

pretty_print_ast :: (ast: AST) {
    builder: String_Builder;

    print(*builder, "AST: \n");

    pretty_print_expression(ast, ast.root_index, 0, *builder);

    print(builder_to_string(*builder,, temp));
}



#scope_file

// <expr> ::= <term> (('+' | '-') <term>)*
get_expression :: (tokens: []Token, current_index: *int, expressions: *[..]Model.Expression) -> error: string, int {
    error, lhs_index := get_term(tokens, current_index, expressions);
    if error {
        return error, -1;
    }

    while (
        current_index.* < tokens.count
        && (
            tokens[current_index.*].type == .PLUS
            || tokens[current_index.*].type == .MINUS
        )
    ) {
        current_index.* += 1;

        expression: Model.Expression;
        expression.kind = .BINARY_OPERATOR;
        expression.binary_operator = Model.Binary_Operator.{
            lhs_index = lhs_index,
            op = tokens[current_index.* - 1],
            line_number = tokens[current_index.* - 1].line_number,
        };
        error, rhs_index := get_term(tokens, current_index, expressions);
        if error {
            return error, -1;
        }
        expression.binary_operator.rhs_index = rhs_index;

        array_add(expressions, expression);
        lhs_index = expressions.count - 1;
    }

    return "", lhs_index;
}

// <term> ::= <factor> (('*' | '/') <factor>)*
get_term :: (tokens: []Token, current_index: *int, expressions: *[..]Model.Expression) -> error: string, int {
    error, lhs_index := get_factor(tokens, current_index, expressions);
    if error {
        return error, -1;
    }

    while (
        current_index.* < tokens.count
        && (
            tokens[current_index.*].type == .STAR
            || tokens[current_index.*].type == .SLASH
        )
    ) {
        current_index.* += 1;

        expression: Model.Expression;
        expression.kind = .BINARY_OPERATOR;
        expression.binary_operator = Model.Binary_Operator.{
            lhs_index = lhs_index,
            op = tokens[current_index.* - 1],
            line_number = tokens[current_index.* - 1].line_number,
        };
        error, rhs_index := get_factor(tokens, current_index, expressions);
        if error {
            return error, -1;
        }
        expression.binary_operator.rhs_index = rhs_index;

        array_add(expressions, expression);
        lhs_index = expressions.count - 1;
    }

    return "", lhs_index;
}

// <factor> ::= <unary>
get_factor :: (tokens: []Token, current_index: *int, expressions: *[..]Model.Expression) -> error: string, int {
    error, index := get_unary(tokens, current_index, expressions);
    return error, index;
}

// <unary> ::= ('+' | '-' | '~') <unary> | <primary>
get_unary :: (tokens: []Token, current_index: *int, expressions: *[..]Model.Expression) -> error: string, int {
    if (
        tokens[current_index.*].type == .NOT
        || tokens[current_index.*].type == .MINUS
        || tokens[current_index.*].type == .PLUS
    ) {
        current_index.* += 1;

        expression: Model.Expression;
        expression.kind = .UNARY_OPERATOR;
        expression.unary_operator = Model.Unary_Operator.{
            op = tokens[current_index.* - 1],
            line_number = tokens[current_index.* - 1].line_number,
        };
        error, operand_index := get_unary(tokens, current_index, expressions);
        if error {
            return error, -1;
        }
        expression.unary_operator.operand_index = operand_index;

        array_add(expressions, expression);

        return "", expressions.count - 1;
    } else {
        error, index := get_primary(tokens, current_index, expressions);
        return error, index;
    }
}

// <primary> ::= <integer> | <float> | '(' <expr> ')'
get_primary :: (tokens: []Token, current_index: *int, expressions: *[..]Model.Expression) -> error: string, int {
    expression: Model.Expression;

    starting_token := tokens[current_index.*];

    if starting_token.type == {
        case .INTEGER;
            current_index.* += 1;

            expression.kind = .INTEGER;
            expression.integer = Model.Integer.{
                value = string_to_int(tokens[current_index.* - 1].lexeme),
                line_number = tokens[current_index.* - 1].line_number,
            };
        case .FLOAT;
            current_index.* += 1;

            expression.kind = .FLOAT;
            expression._float = Model.Float.{
                value = string_to_float(tokens[current_index.* - 1].lexeme),
                line_number = tokens[current_index.* - 1].line_number,
            };
        case .L_PAREN;
            current_index.* += 1;

            error, grouping_expression_index := get_expression(tokens, current_index, expressions);
            if error {
                return error, -1;
            }

            if (
                current_index.* >= tokens.count
                || tokens[current_index.*].type != .R_PAREN
            ) {
                return make_parsing_error("Unterminated paren", starting_token.line_number),
                    -1;
            }
            current_index.* += 1;

            expression.kind = .GROUPING;
            expression.grouping = Model.Grouping.{
                index = grouping_expression_index,
                line_number = tokens[current_index.* - 1].line_number,
            };
        case;
            return make_parsing_error("Unexpected error while trying to parse a primary expression", starting_token.line_number),
                -1;
    }

    array_add(expressions, expression);

    return "", expressions.count - 1;
}

make_parsing_error :: (error: string, line_number: int) -> string {
    return sprint("Parsing error on line %: %", line_number, error);
}

pretty_print_expression :: (ast: AST, index: int, depth: int, builder: *String_Builder) {
    for 1..depth {
        print(builder, "    ");
    }

    expression := ast.expressions[index];

    if expression.kind == {
        case .INTEGER;
            print(builder, "(%)\n", expression.integer.value);
        case .FLOAT;
            print(builder, "(%)\n", expression._float.value);
        case .BINARY_OPERATOR;
            print(builder, "(%)\n", expression.binary_operator.op.lexeme);
            pretty_print_expression(ast, expression.binary_operator.lhs_index, depth + 1, builder);
            pretty_print_expression(ast, expression.binary_operator.rhs_index, depth + 1, builder);
        case .UNARY_OPERATOR;
            print(builder, "(%)\n", expression.unary_operator.op.lexeme);
            pretty_print_expression(ast, expression.unary_operator.operand_index, depth + 1, builder);
        case .GROUPING;
            print(builder, "(())\n");
            pretty_print_expression(ast, expression.grouping.index, depth + 1, builder);
    }
}

#import "Basic";
#import,file "token.jai";
Model :: #import,file "model.jai";
