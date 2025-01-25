function frame_avg = pull_frame_avg(file_name)
    fid = fopen([file_name, '.xml'], 'r');
    XMLdata = fscanf(fid, '%s');
    frame_avg_expression = '\w*FrameAverage="(\d*)';
    frame_avg_matches = regexp(XMLdata, frame_avg_expression, 'tokens');
    frame_avg_array = {};
    for i = 1:length(frame_avg_matches)
        frame_avg_array{end + 1} = cell2mat(frame_avg_matches{i});
    end
    frame_avg = str2double(cell2mat(unique(frame_avg_array)));
    fclose(fid);
end