function [channel_array, detector_names, num_seqs, num_active_detectors]...
                                            = organize_channels(file_name)
    num_seqs = determine_num_seqs(file_name);
    [num_active_detectors, detector_names] =...
                                determine_active_detectors(file_name);
    channel_array = cell(num_seqs, num_active_detectors);
    count = 0;
    for i = 1:num_seqs
        for j = 1:num_active_detectors
            channel_array{i, j} = ['ch', sprintf('%02d', count)];
            count = count + 1;
        end
    end
end