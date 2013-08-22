function fullname = nefWriteFileName
%
%  fullname = nefWriteFileName
%
% Author: BW
% Purpose:  
%   Specify the name of a .MAT output file used to store an imagea combined
%   from a couple of NEF files for multispectral applications.

curDir = pwd;
chdir(fullfile(pdcRootPath,'Data','MultiSpectralImages'));

[fname, pname] = uiputfile('*.mat', 'Choose .MAT outfile name.')
if isequal(fname,0)
    fullname = [];  
else
    fullname = fullfile(pname,fname);
end

chdir(curDir);

return;

