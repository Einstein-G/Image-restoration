function channel_gains = gain_search(file_identifier, channel_names)
    fid = fopen([file_identifier, '.xml'], 'r');
    XMLdata = fscanf(fid, '%s');
    channel_gains = containers.Map;
    for i = 1:length(channel_names)
        detector_name = channel_names{i};
        if strcmp(detector_name(1), 'A')
            expression = ['\w*LUT_List.*?"ChannelName="', detector_name,...
                '".*?Gain="(\d*.\d).*?"AcquisitionMode="(\d*)'];
        else
            expression = ['\w*LUT_List.*?"ChannelName="', detector_name,...
                '".*?Gain="(\d*.\d)'];
        end
        all_matches = regexp(XMLdata, expression, 'tokens');
        mode_tokens = zeros(1, length(all_matches));
        for j = 1:length(all_matches)
            if strcmp(detector_name(1), 'A')
                mode_tokens(j) = str2double(all_matches{j}{2});
            else
                mode_tokens(j) = 0;
            end
        end
        keep_gains = {};
        for j = 1:length(all_matches)
            if sum(mode_tokens) == 0
                keep_gains{end + 1} = all_matches{j}{1};
            else 
                if str2double(all_matches{j}{2})
                    keep_gains{end + 1} = all_matches{j}{1};
                end
            end
        end
        unique_gains = unique(str2double(keep_gains), 'stable');
        channel_gains(detector_name) = unique_gains;
    end
    fclose(fid);
end