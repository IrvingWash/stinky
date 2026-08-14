#placeholder DEBUG;

#import "Basic"()(
    MEMORY_DEBUGGER                 = DEBUG,
    TEMP_ALLOCATOR_OVERWRITE_MEMORY = DEBUG,
);

#import "File";

#import,file "lexer.jai";
#import,file "config.jai";

main :: () {
    #if DEBUG {
        defer report_memory_leaks();
    }

    error, config := make_config_from_arguments();
    if error {
        terminate("Failed: %\n", error);
    }
    defer destroy_config(config);

    source, ok := read_entire_file(config.file_path);
    if !ok {
        terminate("Failed to read '%'\n", config.file_path);
    }
    defer free(source);

    error =, tokens := tokenize(source);
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
