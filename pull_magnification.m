function objective_magnification = pull_magnification(file_name)
    fid = fopen([file_name, '.xml'], 'r');
    XMLdata = fscanf(fid, '%s');
    mag_expression = '\w*Magnification="(\d*)';
    mag_matches = regexp(XMLdata, mag_expression, 'tokens');
    mag_array = {};
    for i = 1:length(mag_matches)
        mag_array{end + 1} = cell2mat(mag_matches{i});
    end
    objective_magnification = str2double(cell2mat(unique(mag_array)));
    fclose(fid);
end