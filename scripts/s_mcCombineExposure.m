% CombineExposure (Script)
%
% Create and save HDR files from several exposure durations. The files are
% written out with an *HDR.mat format. We assume that there are several
% sets of such files, each taken through some color filter.
%
% These several HDR files can then be combined using CombineColors The
% output file names are stored in the cell array hdrFiles{}. This variable
% and nFilters are needed in the script CombineColors.

%% To force selection of the image directory, run this

imgDir = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Read camera images from a particular filter condition and several
%  different exposure durations.  These will be saved as one HDR image.
%

scaleIntensityFlag = 0;

% The sample rate determines the size of the final spatial image.
if ~exist('sampleRate','var') || isempty(sampleRate)
    disp('Using sample rate of 2')
    sampleRate = 2;
end

% Figure out where the files are kept if the imgDir is not yet set.
if ~exist('imgDir','var') || isempty(imgDir)
    imgDir = uigetdir('', 'Directory of NEF files');
    if isequal(imgDir,0), imgDir = []; end
end

% Fancy filter names, used for saving combined exposure files
filterNames = {'No Filter','Tiffen Red 29','Tiffen Deep yellow 15'};

%  Extensions put in the file names for the data acquired with each of the
%  filters.  Used for finding the .NEF files.
filterFileNames = {'*_nofil*','*_red*','*_yellow*'};

curDir = pwd;
chdir(imgDir);
clear fnames
nFilters = 0;
for ii=1:3
    tmp = dir(filterFileNames{ii});
    names = cell(1,length(tmp));
    for jj=1:length(tmp), names{jj} = fullfile(imgDir,tmp(jj).name); end
    if ~isempty(names), nFilters = nFilters+1; fnames{nFilters} = names; end
end
chdir(curDir);

%% Collect up the files across exposures

for ii = 1:nFilters
    % Collect the images using a single color filter at multiple exposures
    [camRGB, vcInfo] = nefCombineFiles(fnames{ii},sampleRate,scaleIntensityFlag,imgDir);
    
    % Figure out the last place we were and save it for the next file read
    [nefDir,tmp] = fileparts(vcInfo.fnames{end});
    
    % Determine the exposure duration for each of the images from the header
    % of the NEF files.
    nExposures = length(vcInfo.fnames);  clear exposures
    for jj=1:nExposures, exposures(jj) = vcInfo.info{jj}.ExposureTime; end
    
    % Combine all of the exposure durations using one of the filters into a
    % single, high dynamic range image.  We could ask the user for this number.
    % It is set here by hand, for the moment.
    [r,c,w] = size(camRGB);
    hdrImage = zeros(r,c,3);
    for jj= 1:3
        cols = [1:3:(3*nExposures)] + (jj - 1);
        images = uint16(camRGB(:,:,cols));
        hdrImage(:,:,jj) = mcCombineExposures(images,exposures,[]);
    end
    
    % imagescRGB(hdrImage.^(1/2.2))
    
    % The output file name is filterName-hdr. The data are integrated
    % across multiple exposures.

    hdrComment = filterNames{ii};
    fname = sprintf('%s-hdr',filterNames{ii});
    hdrFiles{ii} = mcWriteHDR(imgDir,fname,hdrImage,vcInfo, hdrComment);
    
end

