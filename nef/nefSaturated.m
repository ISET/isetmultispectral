function [res,meanmaxrgb]=nefSaturated(filenames, ModelName)
% Checks whether Nikon RAW file contains saturated image data.

%  Needs to be re-written - BW

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