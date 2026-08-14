Config :: struct {
    file_path: string;
}

make_config_from_arguments :: () -> error: string, Config {
    config: Config;

    ti_config := cast(*Type_Info_Struct, type_info(Config));

    arguments := get_command_line_arguments(,, temp);

    if ti_config.members.count > arguments.count - 1 {
        return "Too few arguments!", config;
    }

    config.file_path = copy_string(arguments[1]);

    return "", config;
}

destroy_config :: (config: Config) {
    free(config.file_path);
}



#scope_file

#import "Basic";
