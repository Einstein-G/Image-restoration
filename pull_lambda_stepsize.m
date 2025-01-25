function lambda_stepsize = pull_lambda_stepsize(file_name)
    fid = fopen([file_name, '.xml'], 'r');
    XMLdata = fscanf(fid, '%s');
    lambda_stepsize_expression = '\w*LambdaDetectionStepSize="(\d*)"';
    lambda_stepsize_matches = regexp(XMLdata, lambda_stepsize_expression, 'tokens');
    lambda_stepsize_array = {};
    for i = 1:length(lambda_stepsize_matches)
        lambda_stepsize_array{end + 1} = cell2mat(lambda_stepsize_matches{i});
    end
    lambda_stepsize = str2double(cell2mat(unique(lambda_stepsize_array)));
    fclose(fid);
end