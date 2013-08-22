function [fullFileName,info] = nkCapture(nk, fName)
% Capture one image with a Nikon camera
%
%    [fullFileName,info] = nkCapture(nk, [fName])
%
% nk is a Nikon camera structure.
% fName is the filename string (should end with .nef).  It is placed in the
% image directory specified in the nk structure (nkGet(nk,'imageDir'));
%
% Example:
%   nk = nkCreate;
%   nefFile = nkCapture(nk);
%   nefFile = nkCapture(nk,'MyImage.nef');
%
% Programming:  This routine name should be changed to nefGet

tmpDir = nkGet(nk,'tempDir');
timeout = 30;
time1 = now();

% There is also a version of this called ieSendButtonClick1.  We are not
% sure about the difference.  This command does not always work.  We need
% to make this more reliable.  Check on Google.
ieSendButtonClick('Nikon Capture Camera Control', 'Shoot');

% Wait for a new NEF file to show up in the output directory, then wait
% for it to be done saving (as best we can ascertain). The new NEF file
% should be larger than 'filesize', and have a timestamp after time1.
tmpFile = fullfile(tmpDir,'*.nef');
fileinfo = pollUntilFileDoneSaving(tmpFile, 1, time1, 0, timeout);

if isempty(fileinfo),
    disp('Time out.  No info.');
    info = [];
else
    disp(fileinfo)
    if ieNotDefined('fName'), fName = fileinfo.name; end
    fullFileName = fullfile(nkGet(nk,'imageDir'),fName);
    tempFile = fullfile(tmpDir,fileinfo.name);
    s = movefile(tempFile,fullFileName);
    if ~s,
        pause(0.5)
        disp('Move file failed');
        if ~exist(tempFile,'file'), 
            error('No tempfile %s\n',tempFile);
        else
            disp('Trying move again')
            s = movefile(tempFile,fullFileName);
            if ~s, 
                error('Failed to move %s twice.  Stopping.\n',tempFile); 
            end
        end

    end
    info = nefInfo(fullFileName);
end

return;

