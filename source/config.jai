Config :: struct {
    file_path: string;
}

make_config_from_arguments :: () -> error: string, Config {
    config: Config;

    arguments := get_command_line_arguments(,, temp);

    ti_config := cast(*Type_Info_Struct, type_info(Config));

    if ti_config.members.count > arguments.count - 1 {
        return "You need to specify the path to your stinky code file", config;
    }

    config.file_path = copy_string(arguments[1]);

    return "", config;
}

destroy_config :: (config: Config) {
    free(config.file_path);
}



#scope_file

#import "Basic";
