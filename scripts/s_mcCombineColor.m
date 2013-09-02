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

%% Read in the exposure meta data and set nFilters

load(eMetaData)
hdrFiles
nFilters = length(filterNames);

%% We have hdrFiles, so we combine them
wavelength = (400:10:700);

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

%%  Read the illuminant and build indoor color signals basis functions  
imgDir      = fileparts(hdrFiles{1});
illName     = fullfile(imgDir,'illuminant');
load(illName,'illuminant');

ilWave = illuminantGet(illuminant,'wave');
inIllP   = illuminantGet(illuminant,'photons');
inIllP   = interp1(ilWave,inIllP,wavelength);
% vcNewGraphWin; plot(wavelength,illP)

inBasis = mcBasisCreate(inIllP,nBases,wavelength);
% vcNewGraphWin; plot(inBasis.wave,inBasis.basis)

%% Calculate multicapture basis coefficients for radiance

% Convert the HDR image data to coefficients with respect to the color
% signal basis functions (in photons)
[mcCOEF,err]    = mcCamera2CSBasis(sensor, inBasis.basis, mcHDRImage);
% vcNewGraphWin; imagesc(err); title('Fluorescent basis fit to data')

% predicted = imageLinearTransform(mcCOEF,inBasis.basis'*sensor);
% vcNewGraphWin; plot(mcHDRImage(:),predicted(:),'.'); grid on; axis equal

% We should check that the spd estimates are positive!
%  spd = imageLinearTransform(mcCOEF,inBasis.basis');
%  vcNewGraphWin; imageSPD(spd,wavelength,1/3);
%  vcNewGraphWin; plot(inBasis.wave,inBasis.basis);
%  vcNewGraphWin; hist(spd(:),500); l = spd(:) < 0; sum(l)/length(l)

%% Create a comment and save the file.
clear comment;
comment.filters = filterNames;
comment.sensors = sensorDescription;
comment.nBases = size(inBasis.basis,2);
comment.basisSurfaces = fNames;

% Write out the file with the coefficient and basis information
[p,n] = fileparts(imgDir);
fname = sprintf('%s-%d-hdrs',n,nBases);
fname = fullfile(p,fname);  % Create the full path name

% spd = imageLinearTransform(mcCOEF,csBasis.basis');
% vcNewGraphWin; imageSPD(spd,wavelength);
ieSaveMultiSpectralImage(fname,mcCOEF,inBasis,comment,[],illuminant);
fprintf('Saved %s\n',fname)

% Read it back in and look
scene = sceneFromFile(fname,'multispectral',100);
vcAddAndSelectObject(scene); sceneWindow;

%% Figure out the high luminance portion
lum = sceneGet(scene,'luminance');
% vcNewGraphWin; mesh(lum)
% vcNewGraphWin; imagesc(lum)

% For window scenes use 100 cd/m2 and for outdoor shadow use 20 cd/m2
inBright = (lum > 100);  % Window points
g = fspecial('gaussian',21,7); % g = g/max(g(:));
inBright = conv2(double(inBright),g,'same');
c = 0.5;
inBright(inBright > c)  = 1;
inBright(inBright <= c) = 0;
inBright = logical(inBright);
% vcNewGraphWin; imagesc(inWindow); colormap(gray)

%% Suppose the basis functions in this section of the window are
% Build the basis functions for the color signals.

illuminant = illuminantCreate('d65');
ilWave = illuminantGet(illuminant,'wave');
dayIllP   = illuminantGet(illuminant,'photons');
dayIllP   = interp1(ilWave,dayIllP,wavelength);
% vcNewGraphWin; plot(wavelength,illP)

dayBasis = mcBasisCreate(dayIllP,nBases,wavelength);
%  vcNewGraphWin; plot(dayBasis.wave,dayBasis.basis);


%% Now fit the whole data set with D65
[mcCOEFDaylight,errDay]    = mcCamera2CSBasis(sensor, dayBasis.basis, mcHDRImage);
% vcNewGraphWin; imagesc(errDay); title('D65 basis fit to data')

%% Build one integrated coefficient and basis structure
[mcCOEF,r,c]   = RGB2XWFormat(mcCOEF);
mcCOEFDaylight = RGB2XWFormat(mcCOEFDaylight);

% Zero out the coefficients not relevant to each part of coefficients
% mask is the part in the window
mcCOEF(inBright,:) = 0;          % Room points get 0 in window area
mcCOEFDaylight(~inBright,:) = 0; % Window points get 0 in room area

% Figure out illuminant levels
% We scale the illuminant levels so that the highest reflectance is 0.9.
% Calculate photons, divide by illuminant, to get reflectance
% Then scale so that max reflectance is 0.9.
ref = (mcCOEF*inBasis.basis')*diag(1./inIllP(:));
s = prctile(ref(:),92);
inIllP = (s)*inIllP;

ref = (mcCOEFDaylight*dayBasis.basis')*diag(1./dayIllP(:));
s = prctile(ref(:),99);
dayIllP = (s)*dayIllP;

coef = [mcCOEF, mcCOEFDaylight];
coef = XW2RGBFormat(coef,r,c);

%% Merge bases
clear basis
basis.wave = wavelength;
basis.basis = [inBasis.basis,dayBasis.basis];

%% Set mean luminance to about 50 cd/m2.  Adjust both coefs and lights.
p = RGB2XWFormat(coef)*basis.basis';
p = mean(p,1);
mLum = ieLuminanceFromPhotons(p,wavelength);
s = 100/mLum;
coef = coef*s;
dayIllP = dayIllP*s;
inIllP  = inIllP*s;

%% Make the space varying illuminant
illP = zeros(r*c,length(wavelength));
inBright = RGB2XWFormat(inBright);

% Assign to the illuminant (spatial), point by oint
illP(inBright,:)   = repmat(dayIllP(:)',sum(inBright),1);
illP(~inBright,:)  = repmat(inIllP(:)',sum(~inBright),1);
illP = XW2RGBFormat(illP,r,c);
% vcNewGraphWin; imageSPD(illP,wavelength,1/3);

il = illuminantCreate;
il = illuminantSet(il,'wave',wavelength);
il = illuminantSet(il,'photons',illP);


%% Save the merged data
clear comment;
comment.filters = filterNames;
comment.sensors = sensorDescription;
comment.nBases = size(basis.basis,2);

% Write out the file with the coefficient and basis information
[p,n] = fileparts(imgDir);
fname = sprintf('Merged-%s-%d-hdrs',n,nBases);
fname = fullfile(p,fname);  % Create the full path name

% spd = imageLin100earTransform(mcCOEF,csBasis.basis');
% vcNewGraphWin; imageSPD(spd,wavelength);
ieSaveMultiSpectralImage(fname,coef,basis,comment,[],il);
fprintf('Saved %s\n',fname)

% Read it back in and look
scene = sceneFromFile(fname,'multispectral',100);
vcAddAndSelectObject(scene); sceneWindow;

%% End  