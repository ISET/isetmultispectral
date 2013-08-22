function [msCoef, basis] = mcDeriveBasisAndCoefficients(groups,sampleRate)
%
% function [msCoef, basis] = mcDeriveBasisAndCoefficients(groups,sampleRate)
% 
% Author: FX, BW, JF
%
% Purpose:
%   Derive the high dynamic range, multispectral coefficients from several
%   goups of images (each group corresponds to different filters and each
%   image inside the group corresponds to different exposure setting)
%   The returned image format is [row,col,wave]. the last dimension
%   corresponds to coefs for different basis. 
%
% Input
%   groups: struct array with two fileds 'fnames' and 'filter'
%       .fnames -- names of .NEF files taken at different exposures without
%               changing filter
%       .filter -- name of filter used to take this group images
%               [] for no filter
% 
%   sampleRate: subsample rate (default 2)
%
% Various sampleRates produce spatial images of
%   sampleRate = 1: 1012x1517
%   sampleRate = 2:  506x759
%   sampleRate = 3:  338x506
%   sampleRate = 4:  253x380
%
% Ouput
%   msCoef:
%   basis:
%
% mc stands for multiple capture
% ms stands for multi-spectral
% lm stands for linear model

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Step 1: Select basis functions
wavelength = 400:10:700;
% lightList = {'A','B','C','D50','D55','D65','D75','FL11','FL2','FL7',...
%         'SimonFraserIlluminants','OfficeFL','Vivitar'};
lightList = {'A','B','C','D50','D55','D65','D75'};

lights = lmLookupSignals(lightList, 'illuminants', wavelength,1);
% plot(lights)

surfaceList = {'Clothes','Food','Hair','Objects','Nature','Paint','macbethChart'};
% This one has a NaN in it.  surfaceList = {'SkinReflectance'}
surfaces = lmLookupSignals(surfaceList, 'surfaces', wavelength,0);

nBases = 5;
[basis,cs,sValues] = lmColorSignalBasis(lights,surfaces,nBases);
csBasis.basis = basis;
csBasis.wave = wavelength;

plot(csBasis.wave,csBasis.basis,'-');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Step 2: Compute the basis coefficients using the camera data
%  The data files read in here are created using the script
%  mcCombineExposureColor
%
% Read in a saved data file from that script.

% We need to convert this to vcReadSpectra() format.
D100 = specQuery('sensors','D100',wavelength)/10000;
sensor = [];

for i=1:length(groups)
    gg = groups(i);
    [camRGB, vcInfo] = nefCombineFiles(gg.fnames,sampleRate);
    info = vcInfo.info;
    for k=1:length(info)
        exposures(k) = info{k}.ExposureTime/info{k}.FNumber^2;
    end
    firstCol = (i-1)*3 + 1;  lastCol = firstCol + 2;
    hdrRGB(:,:,firstCol:lastCol) = mcCombineExposures(camRGB,exposures,3200);
   
    if ~isempty(gg.filter)
        filter = specQuery('62mmFilters',gg.filter,wavelength);
    else 
        filter = ones(length(wavelength),1);
    end    
    sensor(:,firstCol:lastCol) = D100.*repmat(filter,[1 3]);    
end

msCoef = mcCamera2CSBasis(sensor, csBasis.basis, hdrRGB);

% mcSaveCoefAndBasis(partialName,msCoef,csBasis,vcInfo)

% To check the spd, try this:
% spd = rgbLinearTransform(msCoef,csBasis');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Step 5: display the constructed multispectral image on a sRGB monitor 
%  phosphor = getSensorSpectral('SRGB',wavelength);
%  I think we should probably be using the xyz2srgb calls in vCamera or IE.
%   For now, though, we are doing it Feng's way.
%
XYZspectral = specQuery('sensors','CIEXYZ',wavelength);
phosphors = XYZspectral * [ 3.2406   -0.9689    0.0557;  -1.5372  1.8758   -0.2040;   -0.4986    0.0415    1.0570];
plot(phosphors)

gam = 2; RGB = mcDisplay(msCoef,csBasis,phosphors,gam);
imagescRGB(RGB);

% Work stopped here ....
