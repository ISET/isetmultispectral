function [mcHDRImage,comments] = mcCombineHDRFiles(fullnames)
%Read several HDR data files and return the data
%  
%   [mcHDRImage,comments] = mcCombineHDRFiles(fullnames);
%
% The data are returned as a 3D matrix.  The input fullnames is a
% cell array with the full path. 
%
% The data format is a [r,c,3*Nexposure] matrix.
% The comment fields in each of the files can be returned 
% in the cell array, comments.
%
% Example:
%   [mcHDRImage,comments] = mcCombineHDRFiles;
%

%%
if ieNotDefined('fullnames'), fullnames =  ieReadMultipleFileNames;  end

%% Initiate mcHDRImage with the first image
load(fullnames{1},'hdrImage','comment');
comments = cell(length(fullnames),1);

comments{1} = comment;
r = size(hdrImage,1);
c = size(hdrImage,2);
mcHDRImage = zeros(r,c,3*length(fullnames));
mcHDRImage(:,:,1:3) = hdrImage;

%% Concatenate the remaining images
for ii=2:length(fullnames)
    load(fullnames{ii},'hdrImage','comment');
    comments{ii} = comment;
    cPlanes = (3*(ii-1) + 1):(3*ii);
    mcHDRImage(:,:,cPlanes) = hdrImage;
end

end

