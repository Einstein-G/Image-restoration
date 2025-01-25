function [num_active_detectors, unique_detectors] =...
                                determine_active_detectors(file_name)
    fid = fopen([file_name, '.xml'], 'r');
    XMLdata = fscanf(fid, '%s');
    expression = '\w*"ChannelName="(\w*)"IsActive="1"';
    all_matches = regexp(XMLdata, expression, 'tokens');
    all_detectors = {};
    for i = 1:length(all_matches)
        all_detectors{end + 1} = cell2mat(all_matches{i});
    end
    keep_detectors = {};
    for i = 1:length(all_detectors)
        detector_name = all_detectors{i};
        detector_expression = ['\w*LUT_List.*?"ChannelName="',...
                detector_name, '"IsActive="(\d*)'];
        detector_match = regexp(XMLdata, detector_expression, 'tokens');
        if str2double(cell2mat(detector_match{1}))
            keep_detectors{end + 1} = detector_name;
        end
    end
    unique_detectors = unique(keep_detectors, 'stable');
    num_active_detectors = length(unique_detectors);
    fclose(fid);
end