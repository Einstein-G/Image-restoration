function lambda_band = pull_lambda_bandwidth(file_name)
    fid = fopen([file_name, '.xml'], 'r');
    XMLdata = fscanf(fid, '%s');
    lambda_band_expression = '\w*LambdaDetectionBandWidth="(\d*)"';
    lambda_band_matches = regexp(XMLdata, lambda_band_expression, 'tokens');
    lambda_band_array = {};
    for i = 1:length(lambda_band_matches)
        lambda_band_array{end + 1} = cell2mat(lambda_band_matches{i});
    end
    lambda_band = str2double(cell2mat(unique(lambda_band_array)));
    fclose(fid);
end