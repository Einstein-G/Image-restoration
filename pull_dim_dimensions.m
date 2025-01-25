function dim_dimensions = pull_dim_dimensions(dim_lengths)
    dim_array = cellfun(@(x) size(x, 1), dim_lengths, 'UniformOutput',...
                    false);
    dim_dimensions = cell2mat(dim_array);
end