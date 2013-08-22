function nk = nkCreate(model,dirName,tempdirName,readInfoFlag)
% Create a Nikon object for handling 
%
%    nk = nkCreate(model,dirName,tempdirName,readInfoFlag)
%
% Example
%   nk = nkCreate;
%   nk = nkCreate('D70');
%   nk = nkCreate([],[],[],0);  % Initialize without reading camera info
%

%% Initialize variables
if ieNotDefined('model'), model = 'D100'; disp('Assuming D100'); end

%set default destination directory
if ieNotDefined('dirName'), 
    dirName = fullfile(pwd,'nkFinal'); 
end

if ieNotDefined('tempDirName'),
    %   This depends on which computer you are using  ON the Inspiron 700M, it
    %   is C:.  On the other computer use F:\nkCaptureTemp.
    tempdirName = 'C:\nkCaptureTemp';
end

% Initialize exposure time from the camera
if ieNotDefined('readInfoFlag'), readInfoFlag = 1; end

%% Verify directories
if ~exist(dirName,'dir'), 
    fprintf('Creating %s\n',dirName); 
    if ~mkdir(dirName)
        error('Could not create %s\n',dirName);
    end
end

if ~exist(tempdirName,'dir')
    fprintf('Creating %s\n',tempdirName);
    if ~mkdir(tempdirName);
        error('Could not create temp dir %s\n',tempdirName);
    end
end

%% Create camera
nk.type = 'Nikon camera';
nk = nkSet(nk,'model',model);
nk = nkSet(nk,'tempDir',tempdirName);
nk = nkSet(nk,'imgDir',dirName);

%Set initial exposure time as null because we don't know the actual camera
%exposure time
nk = nkSet(nk,'exposure',1);
val = nkStartNControl;
if val < 1, 
    warning('Problem starting Nikon Control software'); 
else
    disp('Nikon Capture started succesfully')
end
pause(3);

if readInfoFlag
    % Synch the nk structure with the real camera data.  If we figure out how
    % to read parameters, such as aperture, we could synch that too.
    fprintf('** nkCreate: Synching nk object and camera information **\n');
    val = nkGet(nk,'cameraInfo');
    %% Using info from dcraw
    dcrawData=nefDCrawWrapper(fname)
    %%info = nefInfo(val.fName);
    nk = nkSet(nk,'eTime',info.ExposureTime);
    nk = nkSet(nk,'infoFileName',val.fName);
end

return;
