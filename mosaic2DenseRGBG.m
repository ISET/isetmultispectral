function rgb = mosaic2DenseRGBG(mosaic,mosaicType,sampleRate)
%Take the raw data into a reduced RGB style image.
%The reduction is based on the sampleRate and mosaicType
%
% rgb = mosaic2DenseRGBG(mosaic,mosaicType,sampleRate)
%
%Author:  BW, FX

% An alternative:  h = fspecial('gaussian',sampleRate,sampleRate/3)
switch lower(mosaicType)
    case 'gbrg'
        % The color plane order as read in needs to become [3,1,4,2]
        cPlane = [2 1 3 4]; %[3,1,4,2];
    case 'bggr'
         cPlane = [1 2 4 3];  % Check this!  Nikon D70 case
    case ''
        cPlane = [4,2,3,1];
    otherwise,
        error('Unknown mosaic type');
        
end

if sampleRate > 1   % Average and copy into the RGBG order
    h = fspecial('average',sampleRate);
    cnt = 0;
    fprintf('Filtering and subsampling color planes.\n');
    for ii=1:2
        for jj=1:2
            tmp = imfilter(mosaic(ii:2:end,jj:2:end),h);
            cnt = cnt+1;
            rgb(:,:,cPlane(cnt)) = tmp(1:sampleRate:end,1:sampleRate:end);
        end
    end
else  % No filtering needed, just copy into the RGBG order
    cnt = 0;
    fprintf('Copying color planes.\n');
    for ii=1:2
        for jj=1:2
            cnt = cnt+1;
            rgb(:,:,cPlane(cnt)) = mosaic(ii:2:end,jj:2:end);
        end
    end
end

return;