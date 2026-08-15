AST :: struct {
    expressions: [..]Model.Expression;
    root_index:  int = -1;
}

make_ast :: (tokens: []Token) -> AST {
    ast: AST;

    current_index: int;

    ast.root_index = get_expression(tokens, *current_index, *ast.expressions);

    return ast;
}

destroy_ast :: (ast: *AST) {
    array_free(ast.expressions);
    ast.* = {};
}

pretty_print_ast :: (ast: AST) {
    builder: String_Builder;

    pretty_print_expression(ast, ast.root_index, 0, *builder);

    print(builder_to_string(*builder,, temp));
}



#scope_file

// <expr> ::= <term> (('+' | '-') <term>)*
get_expression :: (tokens: []Token, current_index: *int, expressions: *[..]Model.Expression) -> int {
    lhs_index := get_term(tokens, current_index, expressions);

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
            rhs_index = get_term(tokens, current_index, expressions),
        };

        array_add(expressions, expression);
        lhs_index = expressions.count - 1;
    }

    return lhs_index;
}

// <term> ::= <factor> (('*' | '/') <factor>)*
get_term :: (tokens: []Token, current_index: *int, expressions: *[..]Model.Expression) -> int {
    lhs_index := get_factor(tokens, current_index, expressions);

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
            rhs_index = get_factor(tokens, current_index, expressions),
        };

        array_add(expressions, expression);
        lhs_index = expressions.count - 1;
    }

    return lhs_index;
}

// <factor> ::= <unary>
get_factor :: (tokens: []Token, current_index: *int, expressions: *[..]Model.Expression) -> int {
    return get_unary(tokens, current_index, expressions);
}

// <unary> ::= ('+' | '-' | '~') <unary> | <primary>
get_unary :: (tokens: []Token, current_index: *int, expressions: *[..]Model.Expression) -> int {
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
            operand_index = get_unary(tokens, current_index, expressions),
        };

        array_add(expressions, expression);

        return expressions.count - 1;
    } else {
        return get_prime(tokens, current_index, expressions);
    }
}

// <primary> ::= <integer> | <float> | '(' <expr> ')'
get_prime :: (tokens: []Token, current_index: *int, expressions: *[..]Model.Expression) -> int {
    expression: Model.Expression;

    if tokens[current_index.*].type == {
        case .INTEGER;
            current_index.* += 1;

            expression.kind = .INTEGER;
            expression.integer = Model.Integer.{
                value = string_to_int(tokens[current_index.* - 1].lexeme),
            };
        case .FLOAT;
            current_index.* += 1;

            expression.kind = .FLOAT;
            expression._float = Model.Float.{
                value = string_to_float(tokens[current_index.* - 1].lexeme),
            };
        case .L_PAREN;
            current_index.* += 1;

            grouping_expression_index := get_expression(tokens, current_index, expressions);

            if tokens[current_index.*].type != .R_PAREN {
                assert(false); // @Todo
            }
            current_index.* += 1;

            expression.kind = .GROUPING;
            expression.grouping = Model.Grouping.{
                index = grouping_expression_index,
            };
    }

    array_add(expressions, expression);

    return expressions.count - 1;
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
