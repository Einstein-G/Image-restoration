function [para_set,names] = Parameters(imagename,MetaDataloc)
    cd([MetaDataloc,'\MetaData\']);
    fid=fopen([imagename,'.xml'],'r'); % In the modified files, there was no_Properties in names
%     fid=fopen([imagename,'_Properties.xml'],'r'); % open the file, get file ID
    XMLdata = fscanf(fid, '%s'); % fgetl(fid); % read the file contents (assume text file).
    ActiveGains = '\w*"IsActive="1"Gain="(\d*)';
    Gains = regexp(XMLdata,ActiveGains,'tokens');
    ActiveDetectors = '"(\w+)"IsActive="1"Gain="';
    ActivedetectorName = regexp(XMLdata,ActiveDetectors,'tokens');
    [Unique_Detector,ind,~] = unique(cellfun(@cell2mat,ActivedetectorName,'UniformOutput',false),'stable');
    Activegains = Gains(ind);
    ActiveD = cell(1,length(Unique_Detector)); % % record how many detectors are active
    
    expressiontrans = '\w*Channel"IsActive="1"Gain="(\d*)';
    matchStr_trans = regexp(XMLdata,expressiontrans,'tokens');

    expressionhyd1 = '\w*APD1"IsActive="1"Gain="(\d*)';
    matchStr_hyd1 = regexp(XMLdata,expressionhyd1,'tokens');
    
    
    expressionhyd2 = '\w*APD2"IsActive="1"Gain="(\d*)';
    matchStr_hyd2 = regexp(XMLdata,expressionhyd2,'tokens');
    
    expressionPMT3 = '\w*NDD1"IsActive="1"Gain="(\d*)';
    matchStr_PMT3 = regexp(XMLdata,expressionPMT3,'tokens');
    
    
    expressionPMT4 = '\w*NDD2"IsActive="1"Gain="(\d*)';
    matchStr_PMT4 = regexp(XMLdata,expressionPMT4,'tokens');
    

    checkactive = [{matchStr_trans},{matchStr_hyd1},{matchStr_hyd2},{matchStr_PMT3},{matchStr_PMT4}];
    DetectorNames = ["Transmission","HyD1_525em","HyD2_460em","PMT3","PMT4"];
    init = 1;
    for loops = 1:length(checkactive)
        if isempty(checkactive{loops})~=1
            ActiveD{init} = DetectorNames(loops); % % record how many detectors are active
            init = init+1;
        else
        end
    end

    expressionObj = '\w*Magnification="(\d+\.?\d*)';
    matchStr0 = regexp(XMLdata,expressionObj,'tokens');
    
    expressionLaser = '\w*IntensityDev="(\d+\.?\d*)';
    matchStr2 = regexp(XMLdata,expressionLaser,'tokens');
    expressionLayers = '\w*Sections="(\d*)';
    matchStr3 = regexp(XMLdata,expressionLayers,'tokens');
    
    expressionDim = '\w*InDimension="(\d*)';
    matchStr4 = regexp(XMLdata,expressionDim,'tokens');

  
    FrameAverage = '\w*FrameAverage="(\d*)';
    matchStr5 = regexp(XMLdata,FrameAverage,'tokens');
    FrameAccu = '\w*FrameAccumulation="(\d*)';
    matchStr6 = regexp(XMLdata,FrameAccu,'tokens');
    LineAverage = '\w*LineAverage="(\d*)';
    matchStr7 = regexp(XMLdata,LineAverage,'tokens');
    LineAccu = '\w*Line_Accumulation="(\d*)';
    matchStr8 = regexp(XMLdata,LineAccu,'tokens');



    SeqNum = '\w*UserSettingName="Seq.(\d*)';
    matchStr9 = regexp(XMLdata,SeqNum,'tokens'); % if there are sequence data.
    if isempty(matchStr9)~=1
        SequenceN= str2double (matchStr9{end});
    else
        SequenceN=1;
    end
    
    PowerStart = str2double (matchStr2{6});
    PowerEnd = str2double (matchStr2{end});
    
    if isempty(matchStr3)
        slices = 0;% spectral modes
    else
        slices = str2double (matchStr3{1});
    end
    Dimension = str2double (matchStr4{1});
    frameAve =str2double (matchStr5{1});
    lineAve = str2double (matchStr7{1});
    frameAccu =str2double (matchStr6{1});
    lineAccu = str2double (matchStr8{1});
    Objective = str2double (matchStr0{1});
    %% check if contain Spectra information
    Spec_mode = '\w*ValidLambdaDetectionDefinition="(\d*)"';
    matchStr_Spec = regexp(XMLdata,Spec_mode,'tokens');
    Spec_properties = cell(1,5);
    Spec_properties_Names = ["LambdaStart","LambdaEnd","LambdaStepsize","Emission Number","LambdaWidth"];
    if isempty(matchStr_Spec) ~= 1 % not a spec mode
        if strcmp(matchStr_Spec{1},'1')
            ActiveD = {"Internal_HyD"};
%             expressionPMT5 = '\w*"IsActive="1"Gain="(\d*)';
%             matchStr_PMT5 = regexp(XMLdata,expressionPMT5,'tokens');
            LambdaStart = '\w*LambdaDetectionBegin="(\d*)"';
            matchStr_LambdaStart = regexp(XMLdata,LambdaStart,'tokens');
            LambdaEnd = '\w*LambdaDetectionEnd="(\d*)"';
            matchStr_LambdaEnd = regexp(XMLdata,LambdaEnd,'tokens');
            LambdaStepsize = '\w*LambdaDetectionStepSize="(\d*)"';
            matchStr_LambdaStepsize = regexp(XMLdata,LambdaStepsize,'tokens');
            LambdaEmiNum = '\w*LambdaDetectionStepCount="(\d*)"';
            matchStr_EmiNum = regexp(XMLdata,LambdaEmiNum,'tokens');
            LambdaWidth= '\w*LambdaDetectionBandWidth="(\d*)"';
            matchStr_LambdaWidth = regexp(XMLdata,LambdaWidth,'tokens');
            Spec_properties = [matchStr_LambdaStart{1},matchStr_LambdaEnd{1},matchStr_LambdaStepsize{1},matchStr_EmiNum{1},matchStr_LambdaWidth{1}];

        else

        end
    else
        Spec_properties= [{'0'},{'0'},{'0'},{'0'},{'0'}];
    end
    para_set = [{PowerStart},{PowerEnd},{Dimension},{slices},{frameAve},{lineAve},{frameAccu},{lineAccu},{SequenceN},{Objective},Spec_properties,Activegains];

    names = ["PowerStart","PowerEnd","Dimension","opticalsection","frameAve","lineAve","frameAccu","lineAccu","SequenceN","Objective",Spec_properties_Names,ActiveD];
end