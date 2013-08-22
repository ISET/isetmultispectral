function [rgb,model,mosaicType] = nefRead(fname,sampleRate,returnMosaic,model)
%Decode image data from Nikon .NEF file, return rgb or full mosaic
%
%  [rgb,model,mosaicType] = nefRead(fname,sampleRate,returnMosaic)
%
% NOTE:  The returned data are uint16 as acquired by the camera.
%
% fname -- NEF file name.  If not supplied, you will be queried.
% sampleRate  - How to downsample the image.  
%    if sampleRate = 2, then you leave out the missing samples from the Bayer
%    sampling mosaic.  If you downsample by 1, then the R,G,B fields have a
%    0 at the locations of the missing elements. Downsampling by higher
%    values (e.g. 4) skips every other value.
%
% returnMosaic: 
%   0 (default) - the returned data are in RGB format with four color
%   dimensions: r,g1,b,g2. 
%   1 - the data are returned in a  single plane, not an RGB image.  In
%   this case, no subsampling of the image data is allowed. 
%   2 - the data are turned in a 3D RGB image in which the G field is
%   assigned the average of the two G fields. 
%
%  model:  D70 (default) or D100 are currently supported 
%
% The fname is normally a full path name. 
% 
% Examples:
%  pDir = 'C:\u\brian\Matlab\PDC\Applications\MultiCapture\Data\Images';
%  fName = 'macbeth_tg_nofil_3.NEF';
%  fullName = fullfile(pDir,fName);
%  [rgbg,model] = nefRead(fullName,1);
%
%  The full mosaic, not in RGB format, is returned like this
%
%  mosaic = nefRead(fullName,1,1);
%
%
% Author: FX, BW

if ieNotDefined('fname'),        
    fname = vcSelectDataFile('stayput','r','nef','select NEF file');
    if isempty(fname), disp('Canceled'); end
end
if ieNotDefined('sampleRate'),   sampleRate = 2;   end
if ieNotDefined('returnMosaic'), returnMosaic = 0; end
if ieNotDefined('model'),        model = 'D70';    end

% We have started identifying the camera model based on a parameter.
% In the past, we used the size of the NEF file - TO MANUALLY COMPARE AND
% ADD FOR NEW MODELS such as the D200
% if(filesize > 4*(2^20) && filesize < 5*(2^20)) 
% between 4-5mb is the size of a D70 NEF file
switch(lower(model))
    case 'd70'
        [mosaic,model] = rawCamFileReadD70(fname);
    case 'd100'
        [mosaic,model] = rawCamFileReadD100(fname);
    case 'd2Xs'
        [mosaic,model] = rawCamFileReadD2Xs(fname);
    case 'd1'
%        [mosaic,model] = rawCamFileReadD1(fname);
end

% Different cameras have different dll files & mosaic formats (to
% add for D200)
switch lower(model)
    case 'd100'
        mosaicType = 'grbg';
    case 'd1'
        mosaicType = 'bggr';
    case 'd70'
        mosaicType = 'bggr';
%    case 'd2Xs'
%        mosaicType = ''%% find out
    otherwise
        error('Unknown camera type');

end

mosaic = mosaic';

if returnMosaic == 0
    % Default:  sends back an RGBG image in four planes
    rgb = mosaic2DenseRGBG(mosaic,mosaicType,sampleRate);
elseif (returnMosaic == 1)
    % Return in a single plane RGBG
    if (sampleRate == 1),
        warning('No subsampling in mosaic mode.');  %#ok<WNTAG>
    end
    rgb = mosaic;
elseif returnMosaic == 2
    % Returns a three plane RGB image with G1 and G2 averaged
    rgb = mosaic2DenseRGBG(mosaic,mosaicType,sampleRate);
    rgb(:,:,2) = rgb(:,:,2)/2 + rgb(:,:,4)/2;
    rgb(:,:,4) = [];   % Clears the fourth plane
end

return;

%-----------------------------
function rgb = mosaic2DenseRGBG(mosaic,mosaicType,sampleRate)
%Take the raw data into a reduced RGB style image.
%The reduction is based on the sampleRate and mosaicType
%
% rgb = mosaic2DenseRGBG(mosaic,mosaicType,sampleRate)
%
%Author:  BW, FX

% An alternative:  h = fspecial('gaussian',sampleRate,sampleRate/3)
switch lower(mosaicType)
    case 'grbg'
        % D100 case
        cPlane = [2 1 3 4]; 
    case 'bggr'
        % D70 case
        cPlane = [3 2 4 1];
    otherwise,
        disp('Unknown mosaic type');
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
