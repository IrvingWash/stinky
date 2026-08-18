make_ast :: (tokens: []Token) -> error: string, Model.AST {
    if tokens.count < 1 {
        return "Your stinky code doesn't contain any tokens, so we are unable to parse them, sorry!", {};
    }

    ast: Model.AST;

    pool := New(Flat_Pool);
    ast.allocator = {
        proc = flat_pool_allocator_proc,
        data = pool,
    };

    push_allocator(ast.allocator);

    current_index: int;

    error:, ast.statements = get_program(tokens, *current_index);

    return error, ast;
}

destroy_ast :: (ast: *Model.AST) {
    fini(ast.allocator.data);
    free(ast.allocator.data);

    ast.* = {};
}

pretty_print_ast :: (ast: Model.AST) {
    builder: String_Builder;
    
    print(*builder, "=== AST ===\n");

    for statement: ast.statements {
        pretty_print_statement(*builder, statement, 0);
    }

    print(*builder, "\n");

    print(builder_to_string(*builder,, temp));
}



#scope_file

// <program> ::= <statement>*
get_program :: (tokens: []Token, current_index: *int) -> error: string, [..]Model.Statement {
    error, statements := get_statements(tokens, current_index);
    return error, statements;
}

get_statements :: (tokens: []Token, current_index: *int) -> error: string, [..]Model.Statement {
    statements: [..]Model.Statement;

    while (
        current_index.* < tokens.count
        && (
            tokens[current_index.*].type != .ELSE
            && tokens[current_index.*].type != .THEN
            && tokens[current_index.*].type != .END
        )
    ) {
        error, statement := get_statement(tokens, current_index);
        if error {
            return error, statements;
        }

        array_add(*statements, statement);
    }

    return "", statements;
}

get_statement :: (tokens: []Token, current_index: *int) -> error: string, Model.Statement {
    if tokens[current_index.*].type == {
        case .PRINT;
            error, statement := get_print_statement(tokens, current_index);
            return error, statement;
        case .PRINTLN;
            error, statement := get_println_statement(tokens, current_index);
            return error, statement;
        case .IF;
            error, statement := get_if_statement(tokens, current_index);
            return error, statement;
        case .WHILE;
            error, statement := get_while_statement(tokens, current_index);
            return error, statement;
        case .FOR;
            error, statement := get_for_statement(tokens, current_index);
            return error, statement;
        case .FUNC;
            error, statement := get_function_declaration(tokens, current_index);
            return error, statement;
        case;
            error, left := get_expression(tokens, current_index);
            if error {
                return error, .{};
            }

            if current_index.* < tokens.count && tokens[current_index.*].type == .ASSIGN {
                current_index.* += 1;

                error, right := get_expression(tokens, current_index);
                if error {
                    return error, .{};
                }

                assignment: Model.Statement;
                assignment.kind = .ASSIGNMENT;
                assignment.assignment.left = left;
                assignment.assignment.right = right;
                assignment.line_number = tokens[current_index.* - 1].line_number;

                return "", assignment;
            } else {
                function_call_statement: Model.Statement;
                function_call_statement.kind = .FUNCTION_CALL_STATEMENT;
                function_call_statement.function_call_statement.expression = left;
                function_call_statement.function_call_statement.line_number = tokens[current_index.* - 1].line_number;

                return "", function_call_statement;
            }
    }
}

// <print_statement> ::= "print" <expression>
get_print_statement :: (tokens: []Token, current_index: *int) -> error: string, Model.Statement {
    if tokens[current_index.*].type == .PRINT {
        current_index.* += 1;
        error, expression := get_expression(tokens, current_index);
        if error {
            return error, .{};
        }

        statement: Model.Statement;
        statement.kind = .PRINT;
        statement.print_statement.line_number = tokens[current_index.* - 1].line_number;
        statement.print_statement.value = expression;

        return "", statement;
    }

    return make_parsing_error("Expected a stinky print statement", tokens[current_index.*].line_number), .{};
}

// <println_statement> ::= "println" <expression>
get_println_statement :: (tokens: []Token, current_index: *int) -> error: string, Model.Statement {
    if tokens[current_index.*].type == .PRINTLN {
        current_index.* += 1;
        error, expression := get_expression(tokens, current_index);
        if error {
            return error, .{};
        }

        statement: Model.Statement;
        statement.kind = .PRINTLN;
        statement.print_statement.line_number = tokens[current_index.* - 1].line_number;
        statement.print_statement.value = expression;

        return "", statement;
    }

    return make_parsing_error("Expected a stinky print statement", tokens[current_index.*].line_number), .{};
}

// <if_statement> ::= 'if' <expression> 'then' <statement>* (else <statement>*)? 'end'
get_if_statement :: (tokens: []Token, current_index: *int) -> error: string, Model.Statement {
    error := try_to_consume_token(.IF, tokens, current_index);
    if error {
        return error, .{};
    }

    line_number := tokens[current_index.* - 1].line_number;

    // Get test
    error =, test := get_expression(tokens ,current_index);
    if error {
        return error, .{};
    }

    error = try_to_consume_token(.THEN, tokens, current_index);
    if error {
        return error, .{};
    }

    // Get then statements
    error =, then_statements := get_statements(tokens, current_index);
    if error {
        return error, .{};
    }

    // Check for ELSE token and get else statements
    else_statements: [..]Model.Statement;
    if current_index.* < tokens.count && tokens[current_index.*].type == .ELSE {
        current_index.* += 1;

        error, else_statements = get_statements(tokens, current_index);
        if error {
            return error, .{};
        }
    }

    error = try_to_consume_token(.END, tokens, current_index);
    if error {
        return error, .{};
    }

    statement: Model.Statement;
    statement.kind = .IF;
    statement.if_statement.test = test;
    statement.if_statement.then_statements = then_statements;
    statement.if_statement.else_statements = else_statements;
    statement.if_statement.line_number = line_number;

    return "", statement;
}

// <while_statement> ::= 'while' <expression> 'then' <statement>* 'end'
get_while_statement :: (tokens: []Token, current_index: *int) -> error: string, Model.Statement {
    error := try_to_consume_token(.WHILE, tokens, current_index);
    if error {
        return error, .{};
    }

    line_number := tokens[current_index.* - 1].line_number;

    // Get test expression
    error =, test := get_expression(tokens, current_index);
    if error {
        return error, .{};
    }

    error = try_to_consume_token(.DO, tokens, current_index);
    if error {
        return error, .{};
    }

    // Get while statements
    error =, while_statements := get_statements(tokens, current_index);
    if error {
        return error, .{};
    }

    error = try_to_consume_token(.END, tokens, current_index);
    if error {
        return error, .{};
    }

    statement: Model.Statement;
    statement.kind = .WHILE;
    statement.while_statement.test = test;
    statement.while_statement.statements = while_statements;
    statement.while_statement.line_number = line_number;

    return "", statement;
}

// <for_statement> ::= 'for' <identifier> ':=' <start> ',' <end> ',' (',' <increment>)? 'do' <statement>* 'end'
get_for_statement :: (tokens: []Token, current_index: *int) -> error: string, Model.Statement {
    error := try_to_consume_token(.FOR, tokens, current_index);
    if error {
        return error, .{};
    }

    line_number := tokens[current_index.* - 1].line_number;

    error =, identifier := get_primary(tokens, current_index);
    if error {
        return error, .{};
    }

    error = try_to_consume_token(.ASSIGN, tokens, current_index);
    if error {
        return error, .{};
    }

    error =, start := get_expression(tokens, current_index);
    if error {
        return error, .{};
    }

    error = try_to_consume_token(.COMMA, tokens, current_index);
    if error {
        return error, .{};
    }

    error =, end := get_expression(tokens, current_index);
    if error {
        return error, .{};
    }

    step: *Model.Expression;
    if current_index.* < tokens.count && tokens[current_index.*].type == .COMMA {
        current_index.* += 1;

        error, step = get_expression(tokens, current_index);
        if error {
            return error, .{};
        }
    }

    error = try_to_consume_token(.DO, tokens, current_index);
    if error {
        return error, .{};
    }

    error =, for_statements := get_statements(tokens, current_index);
    if error {
        return error, .{};
    }

    error = try_to_consume_token(.END, tokens, current_index);
    if error {
        return error, .{};
    }

    statement: Model.Statement;
    statement.kind = .FOR;
    statement.for_statement.line_number = line_number;
    statement.for_statement.identifier = identifier;
    statement.for_statement.start = start;
    statement.for_statement.end = end;
    statement.for_statement.step = step;
    statement.for_statement.statements = for_statements;

    return "", statement;
}

// <function_declaration> ::= 'func' <name> '('<parameters>?')' <statements> 'end'
get_function_declaration :: (tokens: []Token, current_index: *int) -> error: string, Model.Statement {
    error := try_to_consume_token(.FUNC, tokens, current_index);
    if error {
        return error, .{};
    }

    line_number := tokens[current_index.* - 1].line_number;

    name := tokens[current_index.*];
    if error {
        return error, .{};
    }
    if name.type != .IDENTIFIER {
        return make_parsing_error("Expected an identifier after 'func'", line_number),
            .{};
    }
    current_index.* += 1;

    error = try_to_consume_token(.L_PAREN, tokens, current_index);
    if error {
        return error, .{};
    }

    error =, parameters := get_parameters(tokens, current_index);
    if error {
        return error, .{};
    }

    error = try_to_consume_token(.R_PAREN, tokens, current_index);
    if error {
        return error, .{};
    }

    error =, statements := get_statements(tokens, current_index);
    if error {
        return error, .{};
    }

    error = try_to_consume_token(.END, tokens, current_index);
    if error {
        return error, .{};
    }

    statement: Model.Statement;
    statement.kind = .FUNCTION_DECLARATION;
    statement.function_declaration.line_number = line_number;
    statement.function_declaration.name = name.lexeme;
    statement.function_declaration.parameters = parameters;
    statement.function_declaration.statements = statements;

    return "", statement;
}

// <parameters> ::= <identifier> (',' <identifier>)*
get_parameters :: (tokens: []Token, current_index: *int) -> error: string, [..]Model.Statement {
    MAX_PARAMS_COUNT :: 255;

    parameters: [..]Model.Statement;
    while current_index.* < tokens.count && tokens[current_index.*].type != .R_PAREN {
        if parameters.count >= MAX_PARAMS_COUNT {
            return make_parsing_error("Too many parameters", tokens[current_index.*].line_number),
                parameters;
        }

        name := tokens[current_index.*];
        if name.type != .IDENTIFIER {
            return make_parsing_error("Expected an identifier", tokens[current_index.*].line_number),
                parameters;
        }
        current_index.* += 1;

        statement: Model.Statement;
        statement.kind = .PARAMETER_DECLARATION;
        statement.parameter_declaration.name = name.lexeme;
        statement.parameter_declaration.line_number = tokens[current_index.* - 1].line_number;

        array_add(*parameters, statement);

        if current_index.* < tokens.count && tokens[current_index.*].type != .R_PAREN {
            error := try_to_consume_token(.COMMA, tokens, current_index);
            if error {
                return error, parameters;
            }
        }
    }

    return "", parameters;
}

get_expression :: (tokens: []Token, current_index: *int) -> error: string, *Model.Expression {
    error, expression := get_logical_or(tokens, current_index);

    return error, expression;
}

// <logical_or> ::= <logical_and> ('or' <logical_and>)*
get_logical_or :: (tokens: []Token, current_index: *int) -> error: string, *Model.Expression {
    error, lhs := get_logical_and(tokens, current_index);
    if error {
        return error, null;
    }

    while (
        current_index.* < tokens.count
        && tokens[current_index.*].type == .OR
    ) {
        current_index.* += 1;

        expression := New(Model.Expression);
        expression.kind = .LOGICAL_OPERATOR;
        expression.logical_operator = Model.Logical_Operator.{
            lhs = lhs,
            op = tokens[current_index.* - 1],
            line_number = tokens[current_index.* - 1].line_number,
        };
        error, rhs := get_logical_and(tokens, current_index);
        if error {
            return error, null;
        }
        expression.logical_operator.rhs = rhs;

        lhs = expression;
    }

    return "", lhs;
};

// <logical_and> ::= <equality> ('and' <equality>)*
get_logical_and :: (tokens: []Token, current_index: *int) -> error: string, *Model.Expression {
    error, lhs := get_equality(tokens, current_index);
    if error {
        return error, null;
    }

    while (
        current_index.* < tokens.count
        && tokens[current_index.*].type == .AND
    ) {
        current_index.* += 1;

        expression := New(Model.Expression);
        expression.kind = .LOGICAL_OPERATOR;
        expression.logical_operator = Model.Logical_Operator.{
            lhs = lhs,
            op = tokens[current_index.* - 1],
            line_number = tokens[current_index.* - 1].line_number,
        };
        error, rhs := get_equality(tokens, current_index);
        if error {
            return error, null;
        }
        expression.logical_operator.rhs = rhs;

        lhs = expression;
    }

    return "", lhs;
}

// <equality> ::= <comparison> (('~=' | '==') <comparison>)*
get_equality :: (tokens: []Token, current_index: *int) -> error: string, *Model.Expression {
    error, lhs := get_comparison(tokens, current_index);
    if error {
        return error, null;
    }

    while (
        current_index.* < tokens.count
        && (
            tokens[current_index.*].type == .EQUALS_EQUALS
            || tokens[current_index.*].type == .NOT_EQUALS
        )
    ) {
        current_index.* += 1;

        expression := New(Model.Expression);
        expression.kind = .BINARY_OPERATOR;
        expression.binary_operator = Model.Binary_Operator.{
            lhs = lhs,
            op = tokens[current_index.* - 1],
            line_number = tokens[current_index.* - 1].line_number,
        };

        error, rhs := get_comparison(tokens, current_index);
        if error {
            return error, null;
        }

        expression.binary_operator.rhs = rhs;

        lhs = expression;
    }

    return "", lhs;
}

// <comparison> ::= <addition> (('>' | '>=' | '<' | '<=') <addition>)*
get_comparison :: (tokens: []Token, current_index: *int) -> error: string, *Model.Expression {
    error, lhs := get_addition(tokens, current_index);
    if error {
        return error, null;
    }

    while (
        current_index.* < tokens.count
        && (
            tokens[current_index.*].type == .GREATER
            || tokens[current_index.*].type == .GREATER_EQUALS
            || tokens[current_index.*].type == .LESS
            || tokens[current_index.*].type == .LESS_EQUALS
        )
    ) {
        current_index.* += 1;

        expression := New(Model.Expression);
        expression.kind = .BINARY_OPERATOR;
        expression.binary_operator = Model.Binary_Operator.{
            lhs = lhs,
            op = tokens[current_index.* - 1],
            line_number = tokens[current_index.* - 1].line_number,
        };
        error, rhs := get_addition(tokens, current_index);
        if error {
            return error, null;
        }

        expression.binary_operator.rhs = rhs;

        lhs = expression;
    }

    return "", lhs;
}

// <addition> ::= <multiplication> (('+' | '-') <multiplication>)*
get_addition :: (tokens: []Token, current_index: *int) -> error: string, *Model.Expression {
    error, lhs := get_multiplication(tokens, current_index);
    if error {
        return error, null;
    }

    while (
        current_index.* < tokens.count
        && (
            tokens[current_index.*].type == .PLUS
            || tokens[current_index.*].type == .MINUS
        )
    ) {
        current_index.* += 1;

        expression := New(Model.Expression);
        expression.kind = .BINARY_OPERATOR;
        expression.binary_operator = Model.Binary_Operator.{
            lhs = lhs,
            op = tokens[current_index.* - 1],
            line_number = tokens[current_index.* - 1].line_number,
        };
        error, rhs := get_multiplication(tokens, current_index);
        if error {
            return error, null;
        }
        expression.binary_operator.rhs = rhs;

        lhs = expression;
    }

    return "", lhs;
}

// <multiplication> ::= <modulo> (('*' | '/') <modulo>)*
get_multiplication :: (tokens: []Token, current_index: *int) -> error: string, *Model.Expression {
    error, lhs := get_modulo(tokens, current_index);
    if error {
        return error, null;
    }

    while (
        current_index.* < tokens.count
        && (
            tokens[current_index.*].type == .STAR
            || tokens[current_index.*].type == .SLASH
        )
    ) {
        current_index.* += 1;

        expression := New(Model.Expression);
        expression.kind = .BINARY_OPERATOR;
        expression.binary_operator = Model.Binary_Operator.{
            lhs = lhs,
            op = tokens[current_index.* - 1],
            line_number = tokens[current_index.* - 1].line_number,
        };
        error, rhs := get_modulo(tokens, current_index);
        if error {
            return error, null;
        }
        expression.binary_operator.rhs = rhs;

        lhs = expression;
    }

    return "", lhs;
}

// <modulo> ::= <unary> ('%' <unary>)*
get_modulo :: (tokens: []Token, current_index: *int) -> error: string, *Model.Expression {
    error, lhs := get_unary(tokens, current_index);
    if error {
        return error, null;
    }

    while (
        current_index.* < tokens.count
        && tokens[current_index.*].type == .MODULO
    ) {
        current_index.* += 1;

        expression := New(Model.Expression);
        expression.kind = .BINARY_OPERATOR;
        expression.binary_operator = Model.Binary_Operator.{
            lhs = lhs,
            op = tokens[current_index.* - 1],
            line_number = tokens[current_index.* - 1].line_number,
        };
        error, rhs := get_unary(tokens, current_index);
        if error {
            return error, null;
        }
        expression.binary_operator.rhs = rhs;

        lhs = expression;
    }

    return "", lhs;
}

// <unary> ::= ('+' | '-' | '~')* <exponent>
get_unary :: (tokens: []Token, current_index: *int) -> error: string, *Model.Expression {
    if (
        current_index.* < tokens.count
        && (
            tokens[current_index.*].type == .NOT
            || tokens[current_index.*].type == .MINUS
            || tokens[current_index.*].type == .PLUS
        )
    ) {
        current_index.* += 1;

        expression := New(Model.Expression);
        expression.kind = .UNARY_OPERATOR;
        expression.unary_operator = Model.Unary_Operator.{
            op = tokens[current_index.* - 1],
            line_number = tokens[current_index.* - 1].line_number,
        };
        error, operand := get_unary(tokens, current_index);
        if error {
            return error, null;
        }
        expression.unary_operator.operand = operand;

        return "", expression;
    } else {
        error, expression := get_exponent(tokens, current_index);
        return error, expression;
    }
}

// <exponent> ::= <primary> ('^' <exponent>)*
get_exponent :: (tokens: []Token, current_index: *int) -> error: string, *Model.Expression {
    error, lhs := get_primary(tokens, current_index);
    if error {
        return error, null;
    }

    while (
        current_index.* < tokens.count
        && tokens[current_index.*].type == .CARET
    ) {
        current_index.* += 1;

        expression := New(Model.Expression);
        expression.kind = .BINARY_OPERATOR;
        expression.binary_operator = Model.Binary_Operator.{
            lhs = lhs,
            op = tokens[current_index.* - 1],
            line_number = tokens[current_index.* - 1].line_number,
        };
        error, rhs := get_exponent(tokens, current_index);
        if error {
            return error, null;
        }
        expression.binary_operator.rhs = rhs;

        lhs = expression;
    }

    return "", lhs;
}

/*
<primary> ::= <integer>
    | <float>
    | <bool>
    | <string>
    | <identifier>
    | '(' <expr> ')'
*/
get_primary :: (tokens: []Token, current_index: *int) -> error: string, *Model.Expression {
    expression := New(Model.Expression);

    if current_index.* >= tokens.count {
        return make_parsing_error("Expected a primary expression", peek_pointer(tokens).line_number),
            null;
    }

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
                value = string_to_float64(tokens[current_index.* - 1].lexeme),
                line_number = tokens[current_index.* - 1].line_number,
            };
        case .TRUE;
            current_index.* += 1;

            expression.kind = .BOOL;
            expression._bool = Model.Bool.{
                value = true,
                line_number = tokens[current_index.* - 1].line_number,
            };
        case .FALSE;
            current_index.* += 1;

            expression.kind = .BOOL;
            expression._bool = Model.Bool.{
                value = false,
                line_number = tokens[current_index.* - 1].line_number,
            };
        case .STRING;
            current_index.* += 1;
            expression.kind = .STRING;
            expression._string = Model.String.{
                value = tokens[current_index.* - 1].lexeme,
                line_number = tokens[current_index.* - 1].line_number,
            };
        case .IDENTIFIER;
            current_index.* += 1;

            if tokens[current_index.*].type == .L_PAREN {  // It's a function call
                current_index.* += 1;
                name := tokens[current_index.* - 2].lexeme;

                error, arguments := get_arguments(tokens, current_index);
                if error {
                    return error, null;
                }

                error = try_to_consume_token(.R_PAREN, tokens, current_index);
                if error {
                    return error, null;
                }

                expression.kind = .FUNCTION_CALL;
                expression.function_call = Model.Function_Call.{
                    line_number = tokens[current_index.* - 1].line_number,
                    name = name,
                    arguments = arguments,
                };
            } else {
                expression.kind = .IDENTIFIER;
                expression.identifier = Model.Identifier.{
                    name = tokens[current_index.* - 1].lexeme,
                    line_number = tokens[current_index.* - 1].line_number,
                };
            }
        case .L_PAREN;
            current_index.* += 1;

            error, grouping_expression := get_expression(tokens, current_index);
            if error {
                return error, null;
            }

            if (
                current_index.* >= tokens.count
                || tokens[current_index.*].type != .R_PAREN
            ) {
                return make_parsing_error("Unterminated paren", starting_token.line_number),
                    null;
            }
            current_index.* += 1;

            expression.kind = .GROUPING;
            expression.grouping = Model.Grouping.{
                value = grouping_expression,
                line_number = tokens[current_index.* - 1].line_number,
            };
        case;
            return make_parsing_error("Unexpected error while trying to parse a primary expression", starting_token.line_number),
                null;
    }

    return "", expression;
}

// <arguments> ::= <expression>(',' <expression>)*
get_arguments :: (tokens: []Token, current_index: *int) -> error: string, [..]*Model.Expression {
    arguments: [..]*Model.Expression;
    while current_index.* < tokens.count && tokens[current_index.*].type != .R_PAREN {
        error, argument := get_expression(tokens, current_index);
        if error {
            return error, arguments;
        }

        array_add(*arguments, argument);

        if current_index.* < tokens.count && tokens[current_index.*].type != .R_PAREN {
            error := try_to_consume_token(.COMMA, tokens, current_index);
            if error {
                return error, arguments;
            }
        }
    }

    return "", arguments;
}

try_to_consume_token :: (token_type: Token_Type, tokens: []Token, current_index: *int) -> error: string {
    if current_index.* >= tokens.count {
        return make_parsing_error(tprint("Expected a stinky % statement, but reached the end of the file", token_type), peek_pointer(tokens).line_number);
    }
    if tokens[current_index.*].type != token_type {
        return make_parsing_error(tprint("Expected a stinky % statement", token_type), tokens[current_index.*].line_number);
    }

    current_index.* += 1;

    return "";
}

make_parsing_error :: (error: string, line_number: int) -> string {
    return tprint("Parsing error on line %: %", line_number, error);
}

pretty_print_statement :: (builder: *String_Builder, statement: Model.Statement, depth: int) {
    for 0..depth - 1 {
        print(builder, "    ");
    }
    if depth > 0 {
        print(builder, "|___");
    }

    if #complete statement.kind == {
        case .PRINT;
            print(builder, "(print)\n");
            pretty_print_expression(builder, statement.print_statement.value, depth + 1);
        case .PRINTLN;
            print(builder, "(println)\n");
            pretty_print_expression(builder, statement.println_statement.value, depth + 1);
        case .IF;
            print(builder, "(if)\n");
            pretty_print_expression(builder, statement.if_statement.test, depth + 1);
            for statement: statement.if_statement.then_statements {
                pretty_print_statement(builder, statement, depth + 1);
            }
            for statement: statement.if_statement.else_statements {
                pretty_print_statement(builder, statement, depth + 1);
            }
        case .ASSIGNMENT;
            print(builder, "(:=)\n");
            pretty_print_expression(builder, statement.assignment.left, depth + 1);
            pretty_print_expression(builder, statement.assignment.right, depth + 1);
        case .WHILE;
            print(builder, "(while)\n");
            pretty_print_expression(builder, statement.while_statement.test, depth + 1);
            for statement: statement.while_statement.statements {
                pretty_print_statement(builder, statement, depth + 1);
            }
        case .FOR;
            print(builder, "(for)\n");
            pretty_print_expression(builder, statement.for_statement.identifier, depth + 1);
            pretty_print_expression(builder, statement.for_statement.start, depth + 1);
            pretty_print_expression(builder, statement.for_statement.end, depth + 1);
            pretty_print_expression(builder, statement.for_statement.step, depth + 1);
            for statement: statement.for_statement.statements {
                pretty_print_statement(builder, statement, depth + 1);
            }
        case .FUNCTION_DECLARATION;
            print(builder, "(func %)\n", statement.function_declaration.name);
            for statement: statement.function_declaration.parameters {
                pretty_print_statement(builder, statement, depth + 1);
            }
            for statement: statement.function_declaration.statements {
                pretty_print_statement(builder, statement, depth + 1);
            }
        case .PARAMETER_DECLARATION;
            print(builder, "(param %)\n", statement.parameter_declaration.name);
        case .FUNCTION_CALL_STATEMENT;
            print(builder, "(func call)\n");
            pretty_print_expression(builder, statement.function_call_statement.expression, depth + 1);
    }
}

pretty_print_expression :: (builder: *String_Builder, expression: *Model.Expression, depth: int) {
    for 0..depth - 1 {
        print(builder, "    ");
    }
    if depth > 0 {
        print(builder, "|___");
    }

    if expression == null {
        print(builder, "null\n");
        return;
    }

    if #complete expression.kind == {
        case .INTEGER;
            print(builder, "(%)\n", expression.integer.value);
        case .FLOAT;
            print(builder, "(%)\n", expression._float.value);
        case .BINARY_OPERATOR;
            print(builder, "(%)\n", expression.binary_operator.op.lexeme);
            pretty_print_expression(builder, expression.binary_operator.lhs, depth + 1);
            pretty_print_expression(builder, expression.binary_operator.rhs, depth + 1);
        case .LOGICAL_OPERATOR;
            print(builder, "(%)\n", expression.logical_operator.op.lexeme);
            pretty_print_expression(builder, expression.logical_operator.lhs, depth + 1);
            pretty_print_expression(builder, expression.logical_operator.rhs, depth + 1);
        case .UNARY_OPERATOR;
            print(builder, "(%)\n", expression.unary_operator.op.lexeme);
            pretty_print_expression(builder, expression.unary_operator.operand, depth + 1);
        case .GROUPING;
            print(builder, "(())\n");
            pretty_print_expression(builder, expression.grouping.value, depth + 1);
        case .BOOL;
            print(builder, "(%)\n", expression._bool.value);
        case .STRING;
            print(builder, "(%)\n", expression._string.value);
        case .IDENTIFIER;
            print(builder, "(%)\n", expression.identifier.name);
        case .FUNCTION_CALL;
            print(builder, "(%)\n", expression.function_call.name);
            for argument: expression.function_call.arguments {
                pretty_print_expression(builder, argument, depth + 1);
            }
    }
}

#import "Basic";
#import,file "token.jai";
Model :: #import,file "model.jai";
#import "Flat_Pool";
