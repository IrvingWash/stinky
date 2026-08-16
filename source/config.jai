Config :: struct {
    file_path: string;
    verbose: bool;
}

Possible_Flags :: struct {
    VERBOSE :: "--verbose";
}

make_config_from_arguments :: () -> error: string, Config {
    config: Config;

    arguments := array_view(get_command_line_arguments(,, temp), 1);

    // File path
    if arguments.count < 1 {
        return "You need to specify the path to your stinky code file", config;
    }

    config.file_path = copy_string(arguments[0]);

    // Flags
    for flag: array_view(arguments, 1) {
        if flag == {
            case Possible_Flags.VERBOSE;
                config.verbose = true;
            case;
                return tprint("Unknown flag '%'", flag), config;
        }
    }

    return "", config;
}

destroy_config :: (config: Config) {
    free(config.file_path);
}



#scope_file

#import "Basic";
