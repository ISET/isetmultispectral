function fullname = nefReadMultipleFileNames(imgDir,prompt)
%
%  fullname = nefReadMultipleFileNames(imgDir,[prompt])
%
% Author: ImagEval
% Purpose:  
%   Read the names of NEF files acquired with a single color filter.
%   Return the file names as full path files in a cell array, fullname{}.

if ~exist('prompt'), prompt = ''; end

if ~exist('imgDir','var') | isempty(imgDir)
    imgDir = uigetdir('', 'Directory of NEF files');
    if isequal(imgDir,0)
        imgDir = [];
        return;
    end
end

d = dir(imgDir);
str = {d.name};
[s,v] = listdlg('PromptString',prompt,'Name','Select files','ListString',str,'ListSize',[240,600]);
if isempty(s), 
    fullname = []; 
    return;
else
    for ii=1:length(s)
        fullname{ii} = fullfile(imgDir,str{s(ii)}); 
    end
end

return;

