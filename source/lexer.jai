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
                token_type = .PERCENT;
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

Token :: struct {
    type:   Token_Type;
    lexeme: string;
    line:   u32;
}

Token_Type :: enum {
    UNKNOWN;

    PLUS;
    MINUS;
    STAR;
    L_PAREN;
    R_PAREN;
    L_CURLY;
    R_CURLY;
    L_SQUARE;
    R_SQUARE;
    DOT;
    COMMA;
    CARET;
    SLASH;
    SEMICOLON;
    QUESTION;
    PERCENT;
    HASH;
}

make_lexeme :: (source: string, start: s32, last: s32) -> string {
    return string.{ last - start, *source[start] };
}

#import "Basic";
#import "String";
