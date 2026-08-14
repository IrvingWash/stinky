tokenize :: (source: string) -> error: string, [..]Token {
    tokens: [..]Token;

    line:    u32 = 1;
    start:   s32;
    next: s32;

    while next < source.count {
        char := source[next];

        start = next;
        next += 1;

        token_type := Token_Type.UNKNOWN;

        if char == {
            case #char " "; #through;
            case #char "\t"; #through;
            case #char "\r";
                continue;

            case #char "\n";
                line += 1;
                continue;

            case #char "#"; // Comment
                while source[next] != "\n" {
                    next += 1;
                }

                continue;
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
            case #char "-";
                token_type = .MINUS;
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
                }
            case #char "!";
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
        }


        lexeme := make_lexeme(source, start, next);

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



#scope_file

#import "Basic";
#import "String";

#import,file "token.jai";
