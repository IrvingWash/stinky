tokenize :: (source: string) -> error: string, [..]Token {
    tokens: [..]Token;

    line:  u32 = 1;
    start: s32;
    next:  s32;

    while next < source.count {
        char := source[next];

        start = next;
        next += 1;

        lexeme: string;
        token_type := Token_Type.UNKNOWN;

        if char == {
            case #char " "; #through;
            case #char "\t"; #through;
            case #char "\r";
                continue;

            case #char "\n";
                line += 1;
                continue;

            case #char "-"; // Minus or comment
                if source[next] != #char "-" {
                    token_type = .MINUS;
                } else {
                    while source[next] != #char "\n" {
                        next += 1;
                    }

                    continue;
                }
            case #char "(";
                token_type = .L_PAREN;
            case #char ")";
                token_type = .R_PAREN;
            case #char "{";
                token_type = .L_CURLY;
            case #char "}";
                token_type = .R_CURLY;
            case #char "[";
                token_type = .L_SQUARE;
            case #char "]";
                token_type = .R_SQUARE;
            case #char ".";
                token_type = .DOT;
            case #char ",";
                token_type = .COMMA;
            case #char "+";
                token_type = .PLUS;
            case #char "*";
                token_type = .STAR;
            case #char "^";
                token_type = .CARET;
            case #char "/";
                token_type = .SLASH;
            case #char ";";
                token_type = .SEMICOLON;
            case #char "?";
                token_type = .QUESTION;
            case #char "%";
                token_type = .MODULO;
            case #char "=";
                if source[next] == #char "=" {
                    token_type = .EQUALS_EQUALS;
                    next += 1;
                } else {
                    token_type = .EQUALS;
                }
            case #char "~";
                if source[next] == #char "=" {
                    token_type = .NOT_EQUALS;
                    next += 1;
                } else {
                    token_type = .NOT;
                }
            case #char "<";
                if source[next] == #char "=" {
                    token_type = .LESS_EQUALS;
                    next += 1;
                } else {
                    token_type = .LESS;
                }
            case #char ">";
                if source[next] == #char "=" {
                    token_type = .GREATER_EQUALS;
                    next += 1;
                } else {
                    token_type = .GREATER;
                }
            case #char ":";
                if source[next] == #char "=" {
                    token_type = .ASSIGN;
                    next += 1;
                } else {
                    token_type = .COLON;
                }
            case #char "\""; #through; // String literals
            case #char "'";
                while source[next] != char {
                    next += 1;

                    if next >= source.count {
                        return sprint("Unterminated string literal at line '%': '%'", line, make_lexeme(source, start, next)),
                            tokens;
                    }
                }

                next += 1;
                token_type = .STRING;
            case;
                if is_alpha(char) { // Identifiers and keywords
                    while is_alnum(source[next]) {
                        next += 1;
                    }

                    lexeme = make_lexeme(source, start, next);

                    is_keyword: bool;
                    for keyword: KEYWORDS {
                        if keyword.lexeme == lexeme {
                            is_keyword = true;
                            token_type = keyword.token_type;
                            break;
                        }
                    }

                    if !is_keyword {
                        token_type = .IDENTIFIER;
                    }
                } else if is_digit(char) { // Integers and floats
                    while is_digit(source[next]) {
                        next += 1;
                    }

                    if source[next] == #char "." {
                        next += 1;

                        while is_digit(source[next]) {
                            next += 1;
                        }

                        token_type = .FLOAT;
                    } else {
                        token_type = .INTEGER;
                    }
                }
        }

        if !lexeme {
            lexeme = make_lexeme(source, start, next);
        }

        if token_type == .UNKNOWN {
            return sprint("Unexpected token '%' at line %", lexeme, line), tokens;
        }

        array_add(
            *tokens,
            Token.{
                token_type,
                lexeme,
                line,
            }
        );
    }

    return "", tokens;
}

pretty_print_tokens :: (tokens: []Token) {
    builder: String_Builder;

    print(*builder, "Tokens: \n");

    for token: tokens {
        if it_index != tokens.count - 1 {
            print(*builder, "% ", token.lexeme);
        } else {
            print(*builder, "%", token.lexeme);
        }
    }

    print(*builder, "\n");

    print(builder_to_string(*builder,, temp));
}



#scope_file

make_lexeme :: (source: string, start: s32, last: s32) -> string {
    return string.{ last - start, *source[start] };
}

#import "Basic";
#import "String";

#import,file "token.jai";
