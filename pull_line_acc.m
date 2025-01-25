function line_acc = pull_line_acc(file_name)
    fid = fopen([file_name, '.xml'], 'r');
    XMLdata = fscanf(fid, '%s');
    line_acc_expression = '\w*Line_Accumulation="(\d*)';
    line_acc_matches = regexp(XMLdata, line_acc_expression, 'tokens');
    line_acc_array = {};
    for i = 1:length(line_acc_matches)
        line_acc_array{end + 1} = cell2mat(line_acc_matches{i});
    end
    line_acc = str2double(cell2mat(unique(line_acc_array)));
    fclose(fid);
end