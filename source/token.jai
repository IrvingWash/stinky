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
    MODULO;
    HASH;
    NOT;
    LESS;
    GREATER;
    COLON;

    EQUALS_EQUALS;
    NOT_EQUALS;
    LESS_EQUALS;
    GREATER_EQUALS;
    ASSIGN; // :=

    INTEGER;
    FLOAT;
    STRING;
    IDENTIFIER;
}
