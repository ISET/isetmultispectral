% s_mcCombineColor (Script)
%
% Integrate multiple  HDR files obtained through different colored filters
% into a single multispectral file. The file contains coefficients and
% spectral basis functions such that the 
%
%   Coefficients times basis functions are the spectral radiance, and 
%   The photon radiance predicts the camera data
%
% The files created by this script are used to represent multispectral
% scenes in ISET.
%
% BW/JEF Copyright Imageval LLC 2005

%% Check to see if we have the variable hdrFiles
if ~exist('hdrFiles','var') 
    warndlg('No hdrFiles listed.  User will be queried.');
    hdrFiles = [];
end

if ~exist('nFilters','var')
    warndlg('This script requires the variable nFilters.  Enter the value at the Matlab prompt.');
    nFilters = input('Number of color filters:  ');
end

%% We have hdrFiles, so we combine them
wavelength = (400:10:700);
clear csBasis;
csBasis.wave = wavelength;
nBases = 5;  % Good for Feng_Office

% This routine combines the high dynamic range files created by
% s_mcCombineExposure into a single 
% [r,c,3*nFilters] matrix. 
%
[mcHDRImage, filterNames] = mcCombineHDRFiles(hdrFiles);
% vcNewGraphWin; imagescRGB(mcHDRImage(:,:,1:3).^(1/2.2));

%% Load the sensor spectral responsivitiy for each of the filter data sets
sensorDescription = cell(nFilters ,1);
sensorDescription{1} = {'D100'};
for ii=1:nFilters
    sensorDescription{ii} = filterNames{ii};
end

% Build up the filters.  The description has the order.
sensor = zeros(length(wavelength),nFilters*3);
D100 = vcReadSpectra(fullfile(mcRootPath,'Data','Sensors','NikonD100')',wavelength);
for ii=1:nFilters
    start = 3*(ii-1)+1;
    filterName = filterNames{ii};
    fprintf('Loading sensor for: %s\n',filterName);
    if ~strcmp(filterName,'No Filter')        
        filter = vcReadSpectra(fullfile(mcRootPath,'Data','Filters',filterName),wavelength);
        sensor(:,start:(start+2)) = D100 .* repmat(filter,[1 3]);
    else
        sensor(:,start:(start+2)) = D100;
    end
end

% Check the sensor data
% vcNewGraphWin; 
% plot(wavelength,sensor(:,1:3))
% plot(wavelength,sensor(:,4:6))
% plot(wavelength,sensor(:,7:9))
% plot(wavelength,sensor)

%%  Read in the illuminant and build the basis functions for the color signals.
imgDir      = fileparts(hdrFiles{1});
illName     = fullfile(imgDir,'illuminant');
load(illName,'illuminant');
illuminantPhotons = illuminantGet(illuminant,'photons');
ilWave            = illuminantGet(illuminant,'wave');
illuminantPhotons = interp1(ilWave,illuminantPhotons,wavelength);
% vcNewGraphWin; plot(wavelength,illuminantPhotons)

% Create a constant basis and a ramp basis
csBasis.basis(:,[1,2]) = lmDCBasis(csBasis.wave,1);

fNames = {'Clothes_Vhrel','Food_Vhrel','Hair_Vhrel', ...
'Objects_Vhrel','Nature_Vhrel','DupontPaintChip_Vhrel','macbethChart'};
% fNames = {'macbethChart'};
surfaces = lmLookupSignals(fNames, csBasis.wave,0);

% Build the color signal basis functions by multiplying surface
% basis functions (in this case, derived from surfaceList above)
% with the illuminant basis.  They don't really have units.
csBasis.basis(:,(3:nBases)) = lmColorSignalBasis(illuminantPhotons(:),surfaces,nBases-2);

% vcNewGraphWin; 
% plot(csBasis.wave,csBasis.basis,'-'); xlabel('Wavelength(nm)');

%% Calculate multicapture basis coefficients for radiance

% Here, we convert the HDR image into a set of coefficients with respect to
% the HDR image data and the color signal basis functions in photons.
mcCOEF    = mcCamera2CSBasis(sensor, csBasis.basis, mcHDRImage);

% predicted = imageLinearTransform(mcCOEF,csBasis.basis'*sensor);
% vcNewGraphWin; plot(mcHDRImage(:),predicted(:),'.'); grid on; axis equal

% We should check that the spd estimates are positive!
%  spd = imageLinearTransform(mcCOEF,csBasis.basis');
%  vcNewGraphWin; imageSPD(spd,wavelength,1/3);
%  vcNewGraphWin; plot(csBasis.wave,csBasis.basis);
%  vcNewGraphWin; hist(spd(:),500); l = spd(:) < 0; sum(l)/length(l)

%% Separate out bright part and dark part, build different basis

% % Here are the unscaled photons
% tmp = imageLinearTransform(mcCOEF,csBasis.basis');
% for ii=1:length(wavelength)
%     tmp(:,:,ii) = tmp(:,:,ii)/illuminantPhotons(ii);
% end
% 
% % Scale the coefficients so that the estimated reflectance will have a 97th
% % percentile of 0.9 .
% r = prctile(tmp(:),97);
% mcCOEF = 0.9*(mcCOEF/r);

%% Create a comment for the file.
clear comment;
comment.filters = filterNames;
comment.sensors = sensorDescription;
comment.nBases = size(csBasis.basis,2);
comment.basisSurfaces = fNames;

% Write out the file with the coefficient and basis information
[p,n] = fileparts(imgDir);
fname = sprintf('%s-%d-hdrs',n,nBases);
fname = fullfile(p,fname);  % Create the full path name

% spd = imageLinearTransform(mcCOEF,csBasis.basis');
% vcNewGraphWin; imageSPD(spd,wavelength);
ieSaveMultiSpectralImage(fname,mcCOEF,csBasis,comment,[],illuminant);
fprintf('Saved %s\n',fname)

% Read it back in and look
scene = sceneFromFile(fname,'multispectral',100);
vcAddAndSelectObject(scene); sceneWindow;

%% Figure out the high luminance portion
lum = sceneGet(scene,'luminance');
vcNewGraphWin; mesh(lum)
vcNewGraphWin; imagesc(lum)
mask = (lum > 100);  % Window points
imagesc(mask)
colormap(gray)


%% Suppose the basis functions in this section of the window are
% Build the basis functions for the color signals.
illuminant = illuminantCreate('d65');
illuminantPhotons = illuminantGet(illuminant,'photons');
ilWave            = illuminantGet(illuminant,'wave');
illuminantPhotons = interp1(ilWave,illuminantPhotons,wavelength);
% vcNewGraphWin; plot(wavelength,illuminantPhotons)

% Create a constant basis and a ramp basis
csBasis.basis(:,[1,2]) = lmDCBasis(csBasis.wave,1);

fNames = {'Clothes_Vhrel','Food_Vhrel','Hair_Vhrel', ...
'Objects_Vhrel','Nature_Vhrel','DupontPaintChip_Vhrel','macbethChart'};
% fNames = {'macbethChart'};
surfaces = lmLookupSignals(fNames, csBasis.wave,0);

% Build the color signal basis functions by multiplying surface
% basis functions (in this case, derived from surfaceList above)
% with the illuminant basis.  They don't really have units.
csBasis.basis(:,(3:nBases)) = lmColorSignalBasis(illuminantPhotons(:),surfaces,nBases-2);

%  vcNewGraphWin; plot(csBasis.wave,csBasis.basis);


%% Now fit the whole data set with D65
mcCOEFDaylight    = mcCamera2CSBasis(sensor, csBasis.basis, mcHDRImage);

% Create a spatial-spectral illuminant that matches the image size
ilSS = illuminantSS(illuminant,r,c);

% How will we use the second set of basis functions?  We could append and
% have 10 basis functions and make mcCOEF(r,c,A Lot)



%% End  