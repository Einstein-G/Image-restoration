function frame_acc = pull_frame_acc(file_name)
    fid = fopen([file_name, '.xml'], 'r');
    XMLdata = fscanf(fid, '%s');
    frame_acc_expression = '\w*FrameAccumulation="(\d*)';
    frame_acc_matches = regexp(XMLdata, frame_acc_expression, 'tokens');
    frame_acc_array = {};
    for i = 1:length(frame_acc_matches)
        frame_acc_array{end + 1} = cell2mat(frame_acc_matches{i});
    end
    frame_acc = str2double(cell2mat(unique(frame_acc_array)));
    fclose(fid);
end