function mcWriteHDR(imgDir,fname,hdrImage,vcInfo,varargin)
%
%   mcWriteHDR(imgDir,fname,hdrImage,vcInfo,varargin)
%
% Author: ImagEval
% Purpose:
%    Save out a high dynamic range image, hdrImage, in imgDir/fname.  These
%    are being acquired through multiple exposure durations with the Nikon
%    D100 camera.
%
%        hdrImage is RGB (double).
%        vcInfo is the collection of NEF info files collected as we read
%        the image files.
%        varargin can contain other variables that will be stored in the file.        
%
%    If imgDir or fname are empty, then the user is prompted to select the
%    directory and filename using a graphical interface.

% We should probably be using partial path names insttead of this method
curDir = pwd;

if ~exist('imgDir','var') | isempty(imgDir)
    chdir(fullfile(pdcRootPath,'Data','MultiCapture'));
else
    chdir(imgDir);
end

% Select the output file name.  The general format should be fnameHDR.mat
%  For exampled, redFilterHDR.mat
%
[outName, pName] = uiputfile('*hdr.mat', 'Output HDR file name');
if isequal(outName,0) | isequal(pName,0)  
    return;
else
    fullname = fullfile(pName,outName);
end

% This should now read through all of the arguments in varargin, in case we
% decide to add other comment fields and so forth.  Need to figure out how
% to do that.  It is something like this:

% cmd = ['save(fullname ,''hdrImage'',''vcInfo'''];
% for ii = 1:length(varargin)
%     cmd = [cmd,',''',varargin{ii},'''']
% end
% cmd = [cmd,' )'];
% eval(cmd)

save(fullname,'hdrImage','vcInfo')

chdir(curDir);

return;
