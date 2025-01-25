function files_OI = load_files(keyword)
    dir_files = dir;
    files_OI = {};
    for i = 1:length(dir_files)
        dir_file_name = dir_files(i).name;
        if contains(dir_file_name, keyword)
            files_OI{end + 1} = dir_file_name;
        end
    end
end