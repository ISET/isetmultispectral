function fullname = mcWriteHDR(imgDir,fname,hdrImage,vcInfo,comment)
%
%   fullname = mcWriteHDR(imgDir,fname,hdrImage,vcInfo,[comment])
%
% Author: ImagEval
% Purpose:
%    Save out a high dynamic range image, hdrImage, in imgDir/fname.  These
%    were acquired using multiple exposure durations with the Nikon
%    D100 camera.
%
%    If imgDir or fname are empty, then the user is prompted to select the
%    directory and filename using a graphical interface.
%
%        hdrImage is RGB (double) 
%        vcInfo is the collection of NEF info files collected as we read
%        the image files
%        comment is an optional comment


if ieNotDefined('comment'), comment = sprintf('No comment.\nDate: %s\n',date); end

% Select the output file name.  The general format should be fnameHDR.mat
%  For exampled, redFilterHDR.mat
%
if isempty('fname') | isempty('imgDir')
    [fname, imgDir] = uiputfile('*hdr.mat', 'Output HDR file name');
    if isequal(fname,0) | isequal(imgDir,0)  
        fullname = [];
        return;
    end
end

fullname = fullfile(imgDir,fname);
save(fullname,'hdrImage','vcInfo','comment')

return;
