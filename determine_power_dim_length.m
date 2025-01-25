function power_dim_length = determine_power_dim_length(dim_identifiers,...
                                                            dim_lengths)
    if isempty(dim_lengths)
            power_dim_length = 1;
    else
        if contains(cell2mat(dim_identifiers), 'z')
            for p = 1:length(dim_identifiers)
                if contains(dim_identifiers{p}, 'z')
                    z_index = p;
                end
            end
            power_dim_length = length(dim_lengths{z_index});
        else
            power_dim_length = length(dim_lengths{1});
        end
    end
end