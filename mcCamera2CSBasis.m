function coef  = mcCamera2CSBasis(sensor, sigBasis, mcHDRRGB)
% Compute the coefficients so that coef*sigBasis' approximates the photons.
%
%   coef = mcCamera2CSBasis(sensor, sigBasis, mcHDRRGB)
%
% sensor:   Sensor spectral response in columns
% sigBasis: Signal basis functions
% mcHDRRGB: Multicapture, HDR image in RGB format
%
% coef is returned in RGB format
%
% We use the sensor responsivities, the color signal basis functions,
% sigBasis, and the sensor responsivity. These equations are written as
%
%         mcHDRXW = coef * sigBasis' * sensor;
%
% The image coefficients are returned in a form where this works
%
%    photons = imageLinearTransform(coef,sigBasis');
%
% The code in imageLinearTransform reads coef and sigBasis and computes 
%    coef    = RGB2XWFormat(coef);
%    photons = coef*sigBasis';
%    photons = XW2RGBFormat(photons,r,c);
%
% So, here, we find
%
%         coef = mcHDRXW * pinv((sigBasis'*sensor),tol);
%
% Because the color filters are not always independent of one another we
% take care to measure the singular coefficients limit singularity
% problems, we only use these greater than 0.01 of the max singular value.
%
% (Maybe we should do this with a ridge regression instead).
%
% See also:  s_mcCombineColor
%
% FX/BW Copyright Imageval Consulting, LLC 2005

%% Should check parameters
if ieNotDefined('sensor'), error('Sensor sensitivities required.'); end
if ieNotDefined('sigBasis'), error('Color signal basis required'); end
if ieNotDefined('mcHDRRGB'), error('multicapture HDR RGB image required.'); end

%% Convert the HDR image to XW format and apply the matrix

% If d is a row vector of camera data, such as in XW format
% So, coef*sigBasis'*sensor  is the predicted camera data, mcHDRXW
% Notice that coef*sigBasis' is the photon image and coef*sigBasis'*sensor
% is the predicted camera data, mcHDRXW

% We put the data into XW format
[mcHDRXW,r,c] = RGB2XWFormat(mcHDRRGB);

% Calculate coefs
coef = mcHDRXW * pinv(sigBasis'*sensor);

% predicted = coef*sigBasis'*sensor;
% vcNewGraphWin; plot(predicted(:),mcHDRXW(:),'.')

% Put coefs into RGB format 
coef = XW2RGBFormat(coef,r,c);

%% To check, put the coef into photon space and then multiply by sensor
% This should get us the camera data
%   predicted = imageLinearTransform(coef,sigBasis'*sensor);
%   vcNewGraphWin; plot(predicted(:),mcHDRRGB(:),'.'); grid on; axis equal
%
% Another problem, however, is that we are getting solutions with negative
% photons.
%   spd = imageLinearTransform(coef,sigBasis');
%   vcNewGraphWin; hist(spd(:),500);
%   min(spd(:)), max(spd(:))

end
