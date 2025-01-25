function [keep_power] = power_search(file_identifier, lambda)
    fileid = fopen([file_identifier,'.xml'], 'r');
    XMLdata = fscanf(fileid, '%s');
    expression = ['\<LaserLineSetting.*?LaserLine="', lambda,...
                                        '".*?IntensityDev="(\d*.\d*).*?"'];
    power_array = regexp(XMLdata, expression, 'tokens');
    keep_power = {};
    for i = 1:length(power_array)
        keep_power{end + 1} = power_array{i}{1};
    end
    keep_power = unique(str2double(keep_power), 'sorted');
    keep_power = keep_power(~isnan(keep_power));
    fclose(fileid);
end