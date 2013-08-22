function [img, info ] = nefReadExposureValue(fName, model, sampleRate, returnMosaic)
% Read in a NEF file, scaling return by exposure value (f#^2/expDur)
%
% [img, info]=nefReadExposureValue(fName, modelsampleRate, returnMosaic)
% 
% The returned data are divided by the exposure duration (in sec) and
% multiplied by the f-number squared. This quantity (f#^2/Exp) is
% proportional corrects for the duration and aperture scaling effects.
%
% In the case of the magnifying, inverted 20mm lens, however, we just
% divide by the exposure duration and leave out the f-number corretion.  We
% should find the f# of that lens and use it, rather than leaving it out!
%
% The blank image should be taken with the same exposure duration as the
% NEF image, and it should be cropped to the same size.
%
% Inputs: 
%    fName:         File name
%    model:         Nikon model
%    sampleRate:    See nefRead
%    returnMosaic:  See nefRead
%
% Example:
%  [img, info] = nefReadExposureValue('CRT-firstWhite.nef','d70');
%

if ieNotDefined('fName'), error('fName needed'); end
if ieNotDefined('model'),             model = 'd70'; end
if ieNotDefined('sampleRate'),        sampleRate = 1; end
if ieNotDefined('returnMosaic'),      returnMosaic = 2; end

% Read NEF images and average
img = double(nefRead(fName, sampleRate, returnMosaic, model));

% We divided by the exposure time in secs and we multiply by the square of
% the f-number.  This produces a raw value that is proportional to the
% exposure value of the sensor. 
info   = nefInfo(fName); 

% We need the f-number of the magnifying, inverting 20mm lens.  For now we
% don't use an fNumber in that case.  The info doesn't have the f# (setting
% it to 0) so we can trap that condition
if info.FNumber == 0 ,     ratio = info.ExposureTime;
else                       ratio = (info.ExposureTime/info.FNumber^2);
end
img = img/ratio;

return;
