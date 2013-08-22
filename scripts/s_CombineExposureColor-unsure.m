%  s_CombineExposureColor
%
%  This script creates the entire set of multiSpectral images in the HDRS
%  database.
%
%  The entire list of data files are stored in a uniform format in the
%  directories listed in the Excel SpreadSheet 'HDR Files'.
%  
%  This script reads those directories and then processes each one to
%  create multispectral files at three different resolutions.
%
%  This script calls two others. The first script (CombineExposure)
%  combines a set of NEF images acquired with different exposure durations.
%  The second script (CombineColor) combines the HDR files obtained with
%  different color filters into a single MATLAB data file.  The output file
%  will contain multiple downsampled images, derived from images acquired
%  using multiple exposure durations and filters. 
%
%  For example, if we take 3 exposure durations with clear and red filter
%  (total of 6 images), the resulting MATLAB file will contain a data set
%  with 6 color channels.  Each of the six channels will contain an
%  intensity estimate derived by finding the best intensity estimate from
%  the 3 exposure durations.
%
%  The data are processed down to three different resolutions. These are
%  stored in the sub-directories srValue where sr means "spatial
%  resolution" and Value is one of the resolution levels: 
%
%    sampleRate = 2:  sr506x759 
%    sampleRate = 3:  sr338x506 
%    sampleRate = 4:  sr253x380
%
% BW/JEF Copyright Scienlab team 2013

%%

% Set up the parameters for looping through the files and spatial
% resolutions
startDir = 1;
dataRoot = 'C:\Users\Joyce\Matlab\Data\NikonD100_Images\NEF\Data\';
[a,dirNames]= xlsread(fullfile(dataRoot,'HDR Files'));
for ii=1:length(dirNames); dirNames{ii} = fullfile(dataRoot,dirNames{ii}); end
sampRateList = [4,3,2];

for sr = 1:length(sampRateList)
    sampleRate = sampRateList(sr);
    
    for ii=startDir:length(dirNames)
        imgDir = dirNames{ii};
        switch sampleRate
            case 2
                resDir = 'sr506x759';
            case 3
                resDir = 'sr338x506';
            case 4
                resDir = 'sr253x380';
            otherwise
                error('Unknown sample rate')
        end
        
        [p,inDir] = fileparts(imgDir);
        fprintf('File name: %s\nSR:\t%.0f',inDir,sampleRate);

        % Now we have to reset the imgDir so that the output files are
        % written in the proper directory.
        if ~exist(fullfile(imgDir,resDir),'dir'), mkdir(imgDir,resDir); end
        outDir = fullfile(imgDir,resDir);
        [p,outSubdir] = fileparts(outDir);

        % Tell the user what is happening.  Could be prettier.
        fprintf('\n***\nIn dir: %s\nSR:\t%.0f\nOut dir:\t%s\n***\n\n',inDir,sampleRate,outSubdir);

        CombineExposure
        CombineColor
        
    end
end

%%