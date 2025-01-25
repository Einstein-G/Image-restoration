function num_seqs = determine_num_seqs(file_name)
    fid = fopen([file_name, '.xml'], 'r');
    XMLdata = fscanf(fid, '%s');
    expression = '\w*UserSettingName="Seq.(\d*)';
    seqs = regexp(XMLdata, expression, 'tokens');
    num_seqs = length(seqs);
    if num_seqs == 0
        num_seqs = 1;
    end
    fclose(fid);
end