function [isSaturated, mx] = nefCheckSaturation(nefFile)
% Checks whether Nikon RAW file contains saturated image data.
%
%    [isSaturated, maxRGB] = nefCheckSaturation(nefFile)
%
% Also returns the maximum rgb value it read
%
% Example:
% 
%

if ieNotDefined('nefFile'), error('NEF file required'); end

info = nefInfo(nefFile);
data = nefRead(nefFile,2,0,'D2Xs'); %% xxx 06/14/2007 -- mp

% data(:,:,2) = 0.5*data(:,:,2) + 0.5* data(:,:,4);
% data(:,:,4) = [];
% data        = double(squeeze(data));

mx = max(double(data(:)));

isSaturated = (mx > nkSaturationValue(info.Model));

return;


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

