function lambda_start = pull_lambda_start(file_name)
    fid = fopen([file_name, '.xml'], 'r');
    XMLdata = fscanf(fid, '%s');
    lambda_start_expression = '\w*LambdaDetectionBegin="(\d*)"';
    lambda_start_matches = regexp(XMLdata, lambda_start_expression, 'tokens');
    lambda_start_array = {};
    for i = 1:length(lambda_start_matches)
        lambda_start_array{end + 1} = cell2mat(lambda_start_matches{i});
    end
    lambda_start = str2double(cell2mat(unique(lambda_start_array)));
    fclose(fid);
end