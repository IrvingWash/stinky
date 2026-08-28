Config :: struct {
    file_path: string;
    verbose:   bool;
    mode:      stinky.Mode;
}

Possible_Flags :: struct {
    VERBOSE          :: "--verbose";
    MODE_VM          :: "--vm";
    MODE_INTERPRETER :: "--interpreter";
}

make_config_from_arguments :: () -> error: string, Config {
    config: Config;

    arguments := array_view(get_command_line_arguments(,, temp), 1);

    // File path
    config.file_path = copy_string(arguments[0]);

    // Flags
    for flag: array_view(arguments, 1) {
        if flag == {
            case Possible_Flags.VERBOSE;
                config.verbose = true;
            case Possible_Flags.MODE_VM;
                config.mode = .VM;
            case Possible_Flags.MODE_INTERPRETER;
                config.mode = .INTERPRETER;
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
stinky :: #import "stinky";
