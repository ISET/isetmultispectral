function [newETime, nk] = nkBestExposure(nk,fName)
% Determine longest, non-saturating exposure
%
%    [eTime, nk] = nkBestExposure(nk,[fName])
%
% fName:  Name of scratch file to use for this process.  Defaults to
% bestExposure.
%
% Example:
%    tempDir     = 'C:\nkCaptureTemp';
%    finalDir    = 'C:\nkCaptureFinal';
%    nk          = nkCreate('d70',finalDir,tempDir);
%    [eTime, nk] = nkBestExposure(nk)
%

if ieNotDefined('fName'), fName = 'bestExposure.nef'; end

val = nkGet(nk,'singleImage',fName);
curETime = val.info.ExposureTime;
[isSaturated, maxRGB] = nefCheckSaturation(val.fName);
satValue = nkSaturationValue(val.info.Model);

% Synchronize the nk structure with the exposure time
nk = nkSet(nk,'eTime',curETime);

% Maybe the first image was not saturated
if ~isSaturated

    % Scale so the new exposure is near saturation
    newETime    = curETime * (0.7*satValue)/maxRGB;

    % This sets the nk and the camera exposure
    fprintf('Trying exposure %f\n',newETime);
    nk          = nkSet(nk,'exposureOnCamera',newETime,curETime);
    fprintf('Achieved exposure %f\n',nkGet(nk,'eTime'));

    val                   = nkGet(nk,'singleImage',fName);
    [isSaturated, maxRGB] = nefCheckSaturation(val.fName);

    fprintf('nkBestExposure: Max: %.0f, sat = %.0f\n\n',maxRGB,isSaturated);

else
    % Or, it could have been saturated
    oldETime = curETime;  % Initialize where we divide from
    while isSaturated
        % Divide exposure time by two to get the new exposure below saturation
        newETime    = oldETime/2;

        % This sets the nk and the camera exposure
        fprintf('Trying for exposure %f\n',newETime);
        nk       = nkSet(nk,'exposureOnCamera',newETime,oldETime);
        oldETime = nkGet(nk,'eTime');  % This is the time that was set
        fprintf('Achieved exposure %f\n',oldETime);
        
        % See if data are below saturation
        val         = nkGet(nk,'singleImage',fName);
        [isSaturated,maxRGB] = nefCheckSaturation(val.fName);

        fprintf('nkBestExposure: Max: %.0f, sat = %.0f\n\n',maxRGB,isSaturated);
    end
end

fprintf('\n***New exposure  %f (sec) ***\n\n',nkGet(nk,'eTime'));

return;

% exp_setting = [30,25,20,15,13,10,8,6,5,4,3,2.5,2,1.6,1.3,1, ...
%     0.7692,1/1.6,1/2,1/2.5,.3333,1/4,1/5,.1667,1/8,1/10,.0769,1/15,1/20,...
%     1/25,.0333,1/40,1/50,.0167,1/80,1/100,1/125,1/160,1/200,1/250,.0031,...
%     1/400,1/500,.0016,1/800,1/1000,1/1250,1/1600,1/2000,1/2500,.0003,1/4000];
