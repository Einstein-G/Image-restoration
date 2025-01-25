function results_container = calculate_metrics_intensity(roi_names,...
                                    file_identifiers, image_array,...
                                    mask_array, analysis_info_container)
    
    %Calculate intensity metrics for a given experiment

    results_container = containers.Map;
    for i = 1:length(roi_names)
        roi_name = roi_names{i};
        roi_file_identifiers = {};
        for j = 1:length(file_identifiers)
            file_identifier = file_identifiers{j};
            if contains(file_identifier, roi_name)
                roi_file_identifiers{end + 1} = file_identifier;
            end
        end
        mask_keys = keys(mask_array);
        for j = 1:length(mask_keys)
            key = mask_keys{j};
            if contains(key, roi_name) && contains(key, 'ALL')
                roi_mask_key = key;
            end
        end
        roi_mask = mask_array(roi_mask_key);
        analysis_info_container_keys = keys(analysis_info_container);
        roi_container = containers.Map;
        for j = 1:length(analysis_info_container_keys)
            analysis_type = analysis_info_container_keys{j};
            if strcmp(analysis_type, 'BETA')
                beta_analysis_info = analysis_info_container(analysis_type);
                for k = 1:length(beta_analysis_info)
                    if sum(contains(beta_analysis_info{k}, 'NADH'))
                        nadh_info_idx = k;
                    end
                end
                nadh_info = beta_analysis_info{nadh_info_idx};
                nadh_wavelength = nadh_info{2};
                nadh_detector = nadh_info{3};
                for k = 1:length(roi_file_identifiers)
                    roi_file_identifier = roi_file_identifiers{k};
                    if contains(roi_file_identifier, nadh_wavelength)
                        nadh_file_identifier = roi_file_identifier;
                    end
                end
                [~, nadh_file_identifier_detectors, ~, ~] =...
                                organize_channels(nadh_file_identifier);
                nadh_file_channel_idx =...
                            find(contains(nadh_file_identifier_detectors,...
                                                    nadh_detector));
                nadh_file_identifier_images =...
                                        image_array(nadh_file_identifier);
                nadh_image_array =...
                        pull_ref_channel_images(nadh_file_identifier_images,...
                                                    nadh_file_channel_idx);
                nadh_image_array = squeeze(nadh_image_array);
                nadh_image_array_masked = nadh_image_array .* roi_mask;
                for k = 1:length(beta_analysis_info)
                    if sum(contains(beta_analysis_info{k}, 'CELLSIZE'))
                        cell_size_info_idx = k;
                    end
                end
                cell_size_info = beta_analysis_info{cell_size_info_idx};
                cell_size = str2double(cell_size_info(2));
                [column_length_meters, row_length_meters] =...
                                pull_im_dims_meters(nadh_file_identifier);
                fov = mean([column_length_meters,...
                                                row_length_meters]) * 10^6;
                [beta , clone_stamp_array] =...
                                PSDanalysis(nadh_image_array_masked, 5,...
                                0, cell_size, fov);
                beta_results_table = array2table(-beta',...
                                                'VariableNames', {'beta'});
                roi_container(analysis_type) = beta_results_table;
            elseif strcmp(analysis_type, 'REDOX')
                redox_analysis_info = analysis_info_container(analysis_type);
                for k = 1:length(redox_analysis_info)
                    if sum(contains(redox_analysis_info{k}, 'NADH'))
                        nadh_info_idx = k;
                    elseif sum(contains(redox_analysis_info{k}, 'FAD'))
                        fad_info_idx = k;
                    end
                end
                nadh_info = redox_analysis_info{nadh_info_idx};
                nadh_wavelength = nadh_info{2};
                nadh_detector = nadh_info{3};
                fad_info = redox_analysis_info{fad_info_idx};
                fad_wavelength = fad_info{2};
                fad_detector = fad_info{3};
                for k = 1:length(roi_file_identifiers)
                    roi_file_identifier = roi_file_identifiers{k};
                    if contains(roi_file_identifier, nadh_wavelength)
                        nadh_file_identifier = roi_file_identifier;
                    elseif contains(roi_file_identifier, fad_wavelength)
                        fad_file_identifier = roi_file_identifier;
                    end
                end
                [~, nadh_file_identifier_detectors, ~, ~] =...
                                organize_channels(nadh_file_identifier);
                nadh_file_channel_idx =...
                            find(contains(nadh_file_identifier_detectors,...
                                                    nadh_detector));
                nadh_file_identifier_images =...
                                        image_array(nadh_file_identifier);
                nadh_image_array =...
                        pull_ref_channel_images(nadh_file_identifier_images,...
                                                    nadh_file_channel_idx);
                nadh_image_array = squeeze(nadh_image_array);
                [~, fad_file_identifier_detectors, ~, ~] =...
                                organize_channels(fad_file_identifier);
                fad_file_channel_idx =...
                            find(contains(fad_file_identifier_detectors,...
                                                    fad_detector));
                fad_file_identifier_images =...
                                        image_array(fad_file_identifier);
                fad_image_array =...
                        pull_ref_channel_images(fad_file_identifier_images,...
                                                    fad_file_channel_idx);
                fad_image_array = squeeze(fad_image_array);
                for k = 1:length(redox_analysis_info)
                    if sum(contains(redox_analysis_info{k}, 'CALCMETHOD'))
                        calc_method_info_idx = k;
                    end
                end
                calc_method_info = redox_analysis_info{calc_method_info_idx};
                calc_method = calc_method_info{2};
                [rr_map, mean_rr, med_rr, IQR_rr, std_rr, CoV_rr] =...
                                calcRedoxMap(nadh_image_array,...
                                fad_image_array, roi_mask, calc_method);
                rr_results =...
                    horzcat(mean_rr', med_rr', IQR_rr', std_rr', CoV_rr');
                
                rr_results_table = array2table(rr_results,...
                            'VariableNames', {'mean_rr', 'median_rr',...
                            'rr_iqr', 'rr_std', 'coeff_of_var_rr'});
                roi_container(analysis_type) = rr_results_table;
            end
        end
        roi_container_keys = keys(roi_container);
        final_table = {};
        for j = 1:length(roi_container_keys)
            key = roi_container_keys{j};
            temp_table = roi_container(key);
            final_table = horzcat(final_table, temp_table);
        end
        results_container(roi_name) = final_table;
        results_container([roi_name, '_rr']) = rr_map;
    end
end