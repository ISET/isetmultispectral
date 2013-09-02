function [coef,err]  = mcCamera2CSBasis(sensor, sigBasis, mcHDRRGB, lambda)
% Compute the coefficients so that coef*sigBasis' approximates the photons.
%
%   [coef,err]  = mcCamera2CSBasis(sensor, sigBasis, mcHDRRGB, lambda)
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
if ieNotDefined('lambda'), lambda = 1; end

%% Convert the HDR image to XW format and apply the matrix

% If d is a row vector of camera data, such as in XW format
% So, coef*sigBasis'*sensor  is the predicted camera data, mcHDRXW
% Notice that coef*sigBasis' is the photon image and coef*sigBasis'*sensor
% is the predicted camera data, mcHDRXW

% We put the data into XW format
[mcHDRXW,r,c] = RGB2XWFormat(mcHDRRGB);

%% Robust regression - used to do it this way.  
% But it seems like the ridge is doing better for us.  Some day, I will
% have to figure out how to set the lambda
%
% % Calculate coefs
% v = svd(sigBasis'*sensor);
% tol = v*0.01;
% coef = mcHDRXW * pinv(sigBasis'*sensor,tol);
% 
% % predicted = coef*sigBasis'*sensor;
% % vcNewGraphWin; plot(predicted(:),mcHDRXW(:),'.')
% 
% % Put coefs into RGB format 
% coef = XW2RGBFormat(coef,r,c);

%% Ridge regression
%
%  MCHDRWX = sensor'*sigBasis*coef (notice flip of XW for WX)
%
A = sensor'*sigBasis;

% ||A*coef - MCHDRWX || + ||coef||^2
% coef = inv(A'*A + eye(size(A,2)))*A'*MCHDRWX;
% coef = ((A'*A + eye(size(A,2)))*A') \ MCHDRWX;
MCHDRWX = mcHDRXW';
coef = (A'*A + lambda*eye(size(A,2)))\(A'*MCHDRWX);

%  For sceneFromFile we store the transpose, coef'
coef = XW2RGBFormat(coef',r,c);

%% Predicted and measured camera data
%
%   predicted = imageLinearTransform(coef,sigBasis'*sensor);
%   vcNewGraphWin; plot(predicted(:),mcHDRRGB(:),'.'); grid on; axis equal
%

if nargout > 1
    predicted = imageLinearTransform(coef,sigBasis'*sensor);
    [err,r,c] = RGB2XWFormat(predicted - mcHDRRGB);
    mn = RGB2XWFormat(mean(mcHDRRGB,3));
    err = bsxfun(@rdivide,err,mn);
    E = zeros(size(err,1),1);
    for ii=1:size(err,1)
        E(ii) = norm(err(ii,:));
    end
    err = XW2RGBFormat(E,r,c);
    % vcNewGraphWin; imagesc(err)
end

%% Another problem: we sometimes get solutions with negative photons.
%
%   spd = imageLinearTransform(coef,sigBasis');
%   vcNewGraphWin; hist(spd(:),500);
%   min(spd(:)), max(spd(:))
%   l = spd(:) < 0; sum(l)/length(l)
%

end
