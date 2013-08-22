function val = nkGet(nk,param,varargin)
% Get information from a Nikon camera structure
%
%    val = nkGet(nk,param,varargin)
%
% To capture an image (or best unsaturated image) using the NikonCapture
% software or query for a current setting such as the exposure time
%
% Examples:
%   nkGet('singleImage')
%   nkGet('bestImage')
%   exposure_time = nkGet(nk,'exposure')
%
%

if ieNotDefined('nk'), error('Nikon camera object required'); end
if ieNotDefined('param'), error('Parameter required'); end
val = [];

switch (lower(param))
    case 'type'
        if isfield(nk,'type'), val = nk.type; end
    case {'model'}
        if isfield(nk,'model'), val = nk.model; end
    case {'tempdir'}
        if isfield(nk,'tempDir'), val = nk.tempDir; end
    case {'imagedir','imgdir'}
        if isfield(nk,'imageDir'), val = nk.imageDir; end

    case {'exposure','etime','exposuretime'}
        if isfield(nk,'eTime'), val = nk.eTime; end
        
    case {'exposurefromcamera','exposureoncamera'}
        [nefFile, info] = nkCapture(nk,'deleteMe.nef');
        val = info.ExposureTime;
        curETime = nkGet(nk,'etime');
        if val ~= curETime, 
            warning('nk structure etime inconsistent with camera'); 
        end
        delete(nefFile);
        
    case {'camerainfo','info'}
        fName = ['CreateFile-',datestr(now,30),'.nef'];
        [fName,info] = nkCapture(nk,fName);
        val.fName = fName;
        val.info = info;
        
    case {'singleimage'}
        % Returns the file name for the image, not the image itself
        if isempty(varargin),
            fName = ['nkGet-',datestr(now,30),'.nef'];
        else
            fName = varargin{1};
        end
        [fName,info] = nkCapture(nk,fName);
        val.fName = fName;
        val.info = info;

    case {'bestimage','bestexposureimage'}
        tempdirName = nkGet(nk,'tempDir');
        dirName = nkGet(nk,'imageDir');

        ieFindBestExposureTimeAutomated(nk,tempdirName);

        %save the picture taken at the best exposure setting in the destination
        %directory
        sourcefile = [tempdirName,'\*'];
        val = copyfile(sourcefile,dirName);
        
    otherwise
        error('Unknown param: %s',param);
end

return;
