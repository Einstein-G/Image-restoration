function lambda_end = pull_lambda_end(file_name)
    fid = fopen([file_name, '.xml'], 'r');
    XMLdata = fscanf(fid, '%s');
    lambda_end_expression = '\w*LambdaDetectionEnd="(\d*)"';
    lambda_end_matches = regexp(XMLdata, lambda_end_expression, 'tokens');
    lambda_end_array = {};
    for i = 1:length(lambda_end_matches)
        lambda_end_array{end + 1} = cell2mat(lambda_end_matches{i});
    end
    lambda_end = str2double(cell2mat(unique(lambda_end_array)));
    fclose(fid);
end