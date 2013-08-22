function nk = nkSet(nk,param,val,varargin)
% Set a Nikon camera object value
%
%     nk = nkSet(nk,param,val,varargin)
%
% Examples:
%   nk = nkCreate;
%   nk = nkSet(nk,'exposure',1);       % Unit is seconds
%   nk = nkSet(nk,'exposure',1, 0.5);  % Unit is seconds
%

% ERROR ENCOUNTERED because of floating point precision - to convert all to
% double with standard precision - that should fix most of the bugs so far

switch(lower(param))
    case {'type'}
        nk.type = 'Nikon camera';
    case {'model','cameramodel'}
        nk.model = val;
    case {'tempdir','tempdirname'}
        nk.tempDir = val;
    case {'imagedir','imgdir','imgdirname','imagedirname'}
        nk.imageDir = val;
    case {'infofilename'}
        % This is the image we captured to learn about the camera
        nk.infoFileName = val;
    case {'exposure','etime','exposuretime'}
        % Set the exposure on the camera
        nk.eTime = val;
    case {'exposureoncamera'}
        % nkSet(nk,'exposureoncamera',0.02);
        % This sends clicks to Nikon Capture to change the current eTime to
        % a new eTime on the camera.
        if isempty(varargin),
            % If we didn't know the current exposure, we don't send it in
            % and nkExposure takes a picture to figure out the current
            % exposure.
            trueTime = nkExposure(nk,val);
        else
            % When we know the current exposure on the camera, we send it
            % in and it computes the number of clicks needed.
            trueTime = nkExposure(nk,val,varargin{1});
        end
        fprintf('Setting etime to %f\n',trueTime)
        nk = nkSet(nk,'etime',trueTime);

    otherwise
        error('Unknown parameter:  %s',param);
end
return;

%---------------------------------------

