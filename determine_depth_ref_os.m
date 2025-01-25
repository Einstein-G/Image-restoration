function ref_os_index = determine_depth_ref_os(im_stack)
    
    %Determine which optical section to use as reference for depth 

    num_depths = size(im_stack, 3);
    summed_intensity_array = zeros(1, num_depths);
    for i = 1:num_depths
        os = im_stack(:, :, i);
        os_array = os(:);
        summed_intensity_array(i) = sum(os_array);
    end
    [~, ref_os_index] = max(summed_intensity_array);
end