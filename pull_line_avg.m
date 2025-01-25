function line_avg = pull_line_avg(file_name)
    fid = fopen([file_name, '.xml'], 'r');
    XMLdata = fscanf(fid, '%s');
    line_avg_expression = '\w*LineAverage="(\d*)';
    line_avg_matches = regexp(XMLdata, line_avg_expression, 'tokens');
    line_avg_array = {};
    for i = 1:length(line_avg_matches)
        line_avg_array{end + 1} = cell2mat(line_avg_matches{i});
    end
    line_avg = str2double(cell2mat(unique(line_avg_array)));
    fclose(fid);
end