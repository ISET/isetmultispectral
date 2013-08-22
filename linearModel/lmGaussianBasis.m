function [gBasis,wavelength] = lmGaussianBasis(nBases, stdDev, gShifts, wavelength)
%   
%   [gBasis,wavelength] = lmGaussianBasis(nBases, stdDev, gShifts, wavelength)
%
% Author: ImagEval
% Purpose:
%    Build a set of Gaussian-like basis functions to span the color signal.
%    For example, nBases = 5 produces five curves.  The area under all of
%    the curves is 1. 
%
%    By default, the first curve has a Gaussian peak at the lowest
%    wavelength and extends only in the higher wavelengths.  The last curve
%    has its Gaussian peak at the highest wavelength, and extends towards
%    the lower wavelengths. The Gaussians in the middle are just plain old
%    Gaussians
%
%    You can specify the amount of shifting and the standard deviations, or
%    you can use the defaults.
%
%    N.B.  These bases are not orthogonal.  If you want to orthogonalize
%    them, you must do that separately.  They are, however, independent.

%
% Examples:
%
%        gBasis = lmGaussianBasis(5, [], [], 400:10:700);
%        gBasis = lmGaussianBasis(7, [], [], 400:10:700);
%        [gBasis,wavelength] = lmGaussianBasis(5, 2);
%        [gBasis,wavelength] = lmGaussianBasis(5, 2, [], 400:4:700);

if ~exist('wavelength','var') | isempty(wavelength)
    wavelength = 400:10:700;
    warning('Setting wavelength to 400:10:700');
end

if ~exist('nBases','var') | isempty(nBases)
    nBases = 1;
end

nWave = length(wavelength);
if ~exist('stdDev','var') | isempty(stdDev)
    stdDev = nWave/(nBases*2);
end

% Gaussians, shifted along the axis
if ~exist('gShifts','var') | isempty(gShifts)
    
    % Set the shifts so the peak of the first and last are at the upper
    % bounds of the wavelength range.
    stepSize = nWave/(nBases - 1);
    gShifts = [-(nWave/2):stepSize:(nWave/2)];
    gShifts = round(gShifts - mean(gShifts));

    % By default, we truncate the upper and lower ones so they are
    % half-Gaussians.  
    setTruncate = 1;
else
    % If the user told us where to shift, don't truncate???  This can lead
    % to wrap-around, though ....
    setTruncate = 0;
    warning('There may be wrap-around on the Gaussian bases.');
end

for ii = 1:nBases
    gBasis(:,ii) = circshift(fspecial('Gaussian',[nWave,1],stdDev),gShifts(ii));
end

if setTruncate
    gBasis([round(nWave/2):nWave],1) = 0;
    gBasis([1:round(nWave/2)],end) = 0;
end

return;
