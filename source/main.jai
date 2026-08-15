#placeholder DEBUG;

#import "Basic"()(
    MEMORY_DEBUGGER                 = DEBUG,
    TEMP_ALLOCATOR_OVERWRITE_MEMORY = DEBUG,
);

#import "File";

Config :: #import,file "config.jai";
Lexer  :: #import,file "lexer.jai";

main :: () {
    #if DEBUG {
        defer report_memory_leaks();
    }

    error, config := Config.make_config_from_arguments();
    if error {
        terminate("Failed: %\n", error);
    }
    defer Config.destroy_config(config);

    source, ok := read_entire_file(config.file_path);
    if !ok {
        terminate("Failed to read '%'\n", config.file_path);
    }
    defer free(source);

    error =, tokens := Lexer.tokenize(source);
    if error {
        terminate("Failed: %\n", error);
    }
    defer array_free(tokens);

    for token: tokens {
        print("%\n", token);
    }
}

terminate :: (format_string: string, args: ..Any) {
    print(format_string, ..args);

    exit(1);
}
