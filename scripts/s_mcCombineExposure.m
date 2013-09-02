% s_mcCombineExposure (Script)
%
% Create and save HDR files from several exposure durations. The files are
% written out with an *HDR.mat format. We assume that there are several
% sets of such files, each taken through some color filter.
%
% These several HDR files can then be combined using CombineColors The
% output file names are stored in the cell array hdrFiles{}. This variable
% and nFilters are needed in the script CombineColors.


%% General parameters
%
% Several different exposure durations are read.  These will be saved as
% one HDR image for each color filter.

sampleRate = 2;           % Subsample and blur a little
scaleIntensityFlag = 0;
imgDir = [];  % Ask the user to click

%% To force the user to select the image directory, run this
% Otherwise, imgDir could be set to the image directory
% imgDir = 'C:\Users\wandell\Documents\GitHub\multispectral\data\images\Feng_Office\nefData;

% Figure out where the files are kept if the imgDir is not yet set.
if ~exist('imgDir','var') || isempty(imgDir)
    imgDir = uigetdir('', 'Directory of NEF files');
    if isequal(imgDir,0), imgDir = []; end
end

% Fancy filter names, used for saving combined exposure files
filterNames = {'No Filter','Tiffen Red 29','Tiffen Deep yellow 15'};
nFilters = length(filterNames);

%  Extensions put in the file names for the data acquired with each of the
%  filters.  Used for finding the .NEF files.
filterFileNames = {'*_nofil*.NEF','*_red*.NEF','*_yellow*.NEF'};

curDir = pwd;
chdir(imgDir);
fnames = cell(nFilters,1);
nFilters = 0;
for ii=1:3
    tmp = dir(filterFileNames{ii});
    names = cell(1,length(tmp));
    for jj=1:length(tmp), names{jj} = fullfile(imgDir,tmp(jj).name); end
    if ~isempty(names), nFilters = nFilters+1; fnames{nFilters} = names; end
end
chdir(curDir);

%% Collect up the files across exposures

hdrFiles = cell(nFilters,1);
for ii = 1:nFilters
    % Collect the images using a single color filter at multiple exposures
    [camRGB, vcInfo] = nefCombineFiles(fnames{ii},sampleRate,scaleIntensityFlag,imgDir);
    % vcNewGraphWin; imagescRGB(camRGB(:,:,1:3).^(1/2.2));
    
    % Figure out the last place we were and save it for the next file read
    [nefDir,tmp] = fileparts(vcInfo.fnames{end});
    
    % Determine the exposure duration for each of the images from the header
    % of the NEF files.
    nExposures = length(vcInfo.fnames);  
    exposures = zeros(nExposures,1);
    for jj=1:nExposures, exposures(jj) = vcInfo.info{jj}.ExposureTime; end
    
    % Combine all of the exposure durations using one of the filters into a
    % single, high dynamic range image.  We could ask the user for this
    % number. It is set here by hand, for the moment.
    [r,c,w] = size(camRGB);
    hdrImage = zeros(r,c,3);
    for jj= 1:3
        cols = (1:3:(3*nExposures)) + (jj - 1);
        images = uint16(camRGB(:,:,cols));
        hdrImage(:,:,jj) = mcCombineExposures(images,exposures,[]);
    end
    % vcNewGraphWin; imagescRGB(hdrImage.^(1/4));
    
    % The output file name is filterName-hdr. The data are integrated
    % across multiple exposures.
    hdrComment = filterNames{ii};
    fname = sprintf('%s-hdr',filterNames{ii});
    
    hdrFiles{ii} = mcWriteHDR(imgDir,fname,hdrImage,vcInfo, hdrComment);
    
end

eMetaData = fullfile(imgDir,'eMetaData');
save(eMetaData,'hdrFiles','filterNames');

%% End

