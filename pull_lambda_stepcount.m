function lambda_stepcount = pull_lambda_stepcount(file_name)
    fid = fopen([file_name, '.xml'], 'r');
    XMLdata = fscanf(fid, '%s');
    lambda_stepcount_expression = '\w*LambdaDetectionStepCount="(\d*)"';
    lambda_stepcount_matches = regexp(XMLdata, lambda_stepcount_expression, 'tokens');
    lambda_stepcount_array = {};
    for i = 1:length(lambda_stepcount_matches)
        lambda_stepcount_array{end + 1} = cell2mat(lambda_stepcount_matches{i});
    end
    lambda_stepcount = str2double(cell2mat(unique(lambda_stepcount_array)));
    fclose(fid);
end