function [column_length, row_length] = pull_im_dims_pixels(file_name)
    fid = fopen([file_name, '.xml'], 'r');
    XMLdata = fscanf(fid, '%s');
    column_expression = '\w*DimID="1"NumberOfElements="(\d*)';
    row_expression = '\w*DimID="2"NumberOfElements="(\d*)';
    column_lengths = regexp(XMLdata, column_expression, 'tokens');
    row_lengths = regexp(XMLdata, row_expression, 'tokens');
    column_lengths_array = {};
    for i = 1:length(column_lengths)
        column_lengths_array{end + 1} = cell2mat(column_lengths{i});
    end
    column_length = str2double(cell2mat(unique(column_lengths_array)));
    row_lengths_array = {};
    for i = 1:length(row_lengths)
        row_lengths_array{end + 1} = cell2mat(row_lengths{i});
    end
    row_length = str2double(cell2mat(unique(row_lengths_array)));
    fclose(fid);
end