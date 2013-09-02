%  s_mcCombineExposureColor
%
%  This is the main script used to create the MultiSpectral images in the
%  HDRS database.
%
%  The first script combines a set of NEF images acquired with different
%  exposure durations. The second script combines the HDR files obtained
%  with different color filters into a single MATLAB data file.  The output
%  file will contain multiple downsampled images, derived from images
%  acquired using multiple exposure durations and filters. 
%
%  For example, if we take 3 exposure durations with clear and red filter
%  (total of 6 images), the resulting MATLAB file will contain a data set
%  with 6 color channels.  Each of the six channels will contain an
%  intensity estimate derived by finding the best intensity estimate from
%  the 3 exposure durations.

%% To start:

% Add the github repository multispectral to your path
%
% Change into the directory with the data
% nefDir = fullfile(mcRootPath,'data','images','Feng_Office','nefData');
% chdir(nefDir)

% Combines multiple exposure durations for each of the color filters
s_mcCombineExposure;

%%
%
% load(hdrFiles{ii});
% vcNewGraphWin; imagescRGB(hdrImage.^(1/4));

% Combines the color filters into a single multispectral file
s_mcCombineColor

