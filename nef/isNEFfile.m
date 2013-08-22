function isNEF = isNEFfile(inFile)

% Function checks the filetype of inFile. Returns 1 if inFile is a NEF file
% and 0 if it isn't.

isNEF = 0; % Not a NEF file by default. Will be set to 1 only if 
% filetype is found to be NEF

typeInd = findstr(inFile,'.');

% In case the file name has multiple '.'s, we should always get filetype
% wrt to the last '.'

fileType = inFile(typeInd(end)+1:end);

if strcmp(lower(fileType),'nef')
    isNEF = 1;
end

return

    