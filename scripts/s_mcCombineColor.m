% s_combineColor (Script)
%
% Integrate multiple color filter HDR files into a *COEF.mat file. The
% coefficients in this file represent the original camera data with respect
% to a set of basis coefficients combined herein.  
%
% The files created by this script are used to represent multispectral
% scenes. 
%
% Here, we build linear models of the color signal on a photon basis, as
% well. The coefficients of the HDRS image are defined with respect to
% these photon-based basis functions.  They are photon based because we
% build them using the photon-based description of the illuminant.
%
% BW/JEF Scienlab team 2005

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
csBasis.wave = wavelength;
nBases = 5;


% This routine combines the high dynamic range files created by CombineExposure into a
% single [r,c,3*Nexposure] matrix. 
% hdrFiles = [];
[mcHDRImage, hdrComments] = mcCombineHDRFiles(hdrFiles);

%% Now we determine how to do the estimation - normally with knownlight
basisType = 'knownlight';
switch basisType
    case 'rollYourOwn'

        % Select the lights and surfaces for your own basis set.
        
        % lightList = {'A','B','C','D50','D55','D65','D75','FL11','FL2','FL7',...
        %         'SimonFraserIlluminants','OfficeFL','Vivitar'};
        lightList = {'A','B','C','D50','D55','D65','D75'};
        basisLights = lmLookupSignals(lightList, 'illuminants', wavelength,1);
        
        surfaceList = {'Clothes','Food','Hair','Objects','Nature','Paint','macbethChart'};
        % This one has a NaN in it.  surfaceList = {'SkinReflectance'}
        surfaces = lmLookupSignals(surfaceList, 'surfaces', wavelength,0);

        % Build four basis representation
        csBasis.basis = lmColorSignalBasis(basisLights,surfaces,nBases);
        % plot(csBasis.wave,csBasis.basis,'-')
        
    case 'Gaussian'
        % Build Gaussian basis functions instead of computing them as above 
        csBasis.basis(:,[1,2]) = lmDCBasis(csBasis.wave,1);
        csBasis.basis(:,(3:nBases)) = ...
            lmGaussianBasis( (nBases - 2), [], [], csBasis.wave);
        
        lightList   = 'Gaussian basis functions.'
        surfaceList = 'Gaussian basis functions.'
        
    case 'knownlight'
        
        % Read scene illuminant information
        % Scene illuminant is one of the basis functions
        
        % Create a constant basis and a ramp basis
        csBasis.basis(:,[1,2]) = lmDCBasis(csBasis.wave,1);
        
        % Read an illuminant file - make sure that the illuminant file is
        % called "illuminant"
        imgDir  = fileparts(hdrFiles{1});
        illName = fullfile(imgDir,'illuminant');
        % foo = load(illName);
        % comment = 'Tungsten illumination in PR-650 units';
        % ieSaveSpectralFile(foo.wavelength,foo.tungsten,comment,illName);
        basisLights = vcReadSpectra(illName,wavelength);
        basisLights = Energy2Quanta(wavelength,basisLights);
        % plot(wavelength,basisLights)
        
       % surfaceList = {'Clothes','Food','Hair','Objects','Nature','Paint','macbethChart'};
        surfaceList = {'macbethChart'};
        % This one has a NaN in it.  surfaceList = {'SkinReflectance'}
        surfaces = lmLookupSignals(surfaceList, 'surfaces', csBasis.wave,0);
        
        % Build the color signal basis functions. These basis functions are
        % created by multiplying surface basis functions (in this case,
        % derived from Macbeth ColorChecker - see surfaceList above) with
        % the illuminant basis.  They don't really have units.
        csBasis.basis(:,(3:nBases)) = lmColorSignalBasis(basisLights,surfaces,nBases-2);
        % plot(csBasis.wave,csBasis.basis,'-')
        % xlabel('Wavelength(nm)');  

    otherwise
        error('Unknown method of computing bases')
end

%% Sensor description - derived from one of the filters
sensorDescription{1} = {'D100'};
for ii=1:nFilters
    sensorDescription{ii+1} = hdrComments{ii};
end

% D100 = specQuery('sensors','D100',wavelength)/10000;
% D100 = vcReadSpectra(fullfile('MultiCapture','Data','Sensors','NikonD100'),wavelength);
D100 = vcReadSpectra(fullfile(mcRootPath,'Data','Sensors','NikonD100')',wavelength);

sensor = [];
for ii=1:nFilters
    filterName = hdrComments{ii};
    if ~strcmp(filterName,'No Filter')        
        % filter = vcReadSpectra(fullfile('MultiCapture','Data','Filters',filterName),wavelength);
        filter = vcReadSpectra(fullfile(mcRootPath,'Data','Filters',filterName),wavelength);
        sensor = [sensor D100.*repmat(filter,[1 3])];
    else
        sensor = [sensor D100];
    end
end
% plot(wavelength,sensor)

%% For MeasureMC, you can stop here.

% Here, we convert the HDR image into a set of coefficients with respect to
% the HDR image data and the color signal basis functions in photons.
mcCOEF = mcCamera2CSBasis(sensor, csBasis.basis, mcHDRImage);

% We want the photons ( = basis*mcCOEFF) to have proper level of photons.
% By proper we mean that dividing by the illuminant would produce
% reflectance estimates in the range [0-0.9].
%
% We do this allowing 3 percent of the image to be specular.
% We scale the photons so that the 97th percentile of the image has a
% reflectance of 0.9.
%
% Here are the unscaled photons
tmp = imageLinearTransform(mcCOEF,csBasis.basis');

% Read the illuminant data and convert it to Photons.
illFile = fullfile(imgDir,'illuminant.mat');
[illuminant.data,illuminant.wavelength,illuminant.comment] = ...
    vcReadSpectra(illFile,wavelength);
% plot(illuminant.wavelength,illuminant.data)
% ylabel('Energy')
if isempty(illuminant.data)
    warning('Bad illuminant format.'); 
    illuminant = []; 
end
illuminantPhotons = Energy2Quanta(wavelength,illuminant.data);

% Make tmp an estimate of the reflectances by dividing the illuminant out
for ii=1:length(wavelength)
    tmp(:,:,ii) = tmp(:,:,ii)/illuminantPhotons(ii);
end

% Scale the coefficients so that the estimated reflectance will have a 97th
% percentile of 0.9 .
r = prctile(tmp(:),97);
mcCOEF = 0.9*(mcCOEF/r);

% imagescRGB(mcCOEF(:,:,1:3),1/2.2)

% Create a comment for the file.
clear comment;
comment.filters = hdrComments{1};
comment.sensors = sensorDescription;
comment.nBases = size(csBasis.basis,2);
comment.basisSurfaces = surfaceList;

% Write out the file with the coefficient and basis information
[p,n] = fileparts(imgDir);
fname = sprintf('%s-hdrs',n);
fname = fullfile(p,fname);  % Create the full path name
ieSaveMultiSpectralImage(fname,mcCOEF,csBasis,comment,[],illuminant);
fprintf('Saved %s\n',fname)

% scene = sceneFromFile(fname,'multispectral',100);
% vcAddAndSelectObject(scene);
% sceneWindow
%%%%%%%%%%%%%%%%%%%%%%% End Script %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%