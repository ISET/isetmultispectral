function [res,exp_time,meanmaxrgb] = nkCapture(dirName, ModelName)
% Capture one image with a Nikon camera
%
%    [res, exp_time,meanmaxrgb] = ieFindExposureTime(dirName, ModelName)
% 
% res:  A binary variable indicating whether or not the data are saturated
% exp_time:  Exposure time in units of seconds
% meanmaxrgb: The mean of max rgb values in the NEF file (used to check for
% saturation and determine best exposure time
%
% Example:
%   nefImage = nkCapture(nk);
%
% Programming:  This routine name should be changed to nefGet

% if ieNotDefined('dirName'), error('Directory name required'); end
% if ieNotDefined('ModelName'), error('Nikon model name (D100, D70) required'); end
% 
% rmdir(dirName,'s')
% mkdir(dirName);

namestr = sprintf('%s-%s',nkGet(nk,'model'),datestr(now,30));

% newNamePrefix=[ModelName '_' namestr '_'];
% newStart=0;
    
%ieSendButtonClick1('Nikon Capture Camera Control', strDirection);

% The NEF files captured by different cameras have different file sizes (to
% add for D200)
switch lower(ModelName)
    case 'd100'
        filesize = 9*(2^20); %Ex: Size of a D100's NEF is over 9mb
    case 'd70'
        filesize = 4*(2^20);
    otherwise
        disp('Unknown camera type');
end

dirName = nkGet(nk,'
timeout = 90;
for ii=1:1;
    time1 = now();
    ieSendButtonClick('Nikon Capture Camera Control', 'Shoot');
    % Wait for a new NEF file to show up in the output directory, then wait
    % for it to be done saving (as best we can ascertain). The new NEF file
    % should be larger than 'filesize', and have a timestamp after time1.
    fileinfo = pollUntilFileDoneSaving(sprintf('%s/%s',dirName,'*.nef'), 1, time1, filesize, timeout);
    disp(fileinfo);

end;        

if (isempty(fileinfo))
    error('Didn''t find a new image file in time:');
end    
    
newnames = ieRenameFilesInDirectory(dirName, newNamePrefix, newStart);

[res,meanmaxrgb] = isSaturated(newnames, ModelName);
fileinfo = nefInfo(newnames{1});
exp_time = fileinfo.ExposureTime;

%-------------------------------------------------
function [res,meanmaxrgb]=isSaturated(filenames, ModelName)
% Checks whether Nikon RAW file contains saturated image data.

% Check the comments below
mmaxrgb = zeros(1);
for ii=1:1;
    
    [raw] = double(nefRead(filenames{1}, 1));
       
    % Average the two G channels into the first one.
    % (I wonder if this is bad for checking saturation -gregng)
    raw(:, :, 2)=(raw(:, :, 2)+raw(:, :, 4))/2;

    rgb=raw(:, :, 1:3);
    clear raw;

    % rgb1(:, :, 1)=medfilt2(rgb(:, :, 1), [3, 3]);
    % rgb1(:, :, 2)=medfilt2(rgb(:, :, 2), [3, 3]);
    % rgb1(:, :, 3)=medfilt2(rgb(:, :, 3), [3, 3]);

    %disp(max(rgb(:)));

    mmaxrgb(ii)=max(rgb(:));

end;
meanmaxrgb = mean(mmaxrgb);
res=(meanmaxrgb>2^12*0.9);

return

%Proposed revision: gregng 4/26/06
% for ii=1:1;
% 
%     [raw]=nefread(filenames{ii}, 1);
% 
%     % channel 1: red
%     % channel 2: green
%     % channel 3: blue
%     % channel 4: green again
% 
%     mmaxrgb(ii)=double(max(raw(:)));
% 
% end;
% 
% res=(mean(mmaxrgb)>((2^12)*0.9));

% Original code: 4/26/2006.
% This code did averaging of the two G bayer channels, which I think is
% probably a mistake.
%
% This routine could probably use some optimization.
% * We shouldn't need to change this to a double.  That might help speed.
%
% I assume that the multiple imagenames are so that we can do averaging or
% take data from multiple images if we need.
% -- gregng
% 