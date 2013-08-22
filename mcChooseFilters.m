% Choose filters to measure hyperspectral data using D100 camera 
% Based on findBestFilters by FX

clear all; close all;

% Read in the D100 sensor spectral response 
wavelength = 400:5:700;
D100 = specQuery('sensors','D100',wavelength)/10000;

% Read in the options for the filters to be placed in front of the camera.
allFilters = specQuery('62mmFilters');
for i=1:length(allFilters)
    filters(:,i) = specQuery('62mmFilters',allFilters(i).name,wavelength);
end

% Read in the illuminants we will evaluate
A =     specQuery('illuminants','A',wavelength);
B =     specQuery('illuminants','B',wavelength);
C =     specQuery('illuminants','C',wavelength);
D50 =   specQuery('illuminants','D50',wavelength);
D55 =   specQuery('illuminants','D55',wavelength);
D65 =   specQuery('illuminants','D65',wavelength);
D75 =   specQuery('illuminants','D75',wavelength);
FL11 =   specQuery('illuminants','FL11',wavelength);
FL2 =   specQuery('illuminants','FL2',wavelength);
FL7 =   specQuery('illuminants','FL7',wavelength);
SimonFraserIlluminants =   specQuery('illuminants','SimonFraserIlluminants',wavelength);
OfficeFL =   specQuery('illuminants','OfficeFL',wavelength);
Vivitar =   specQuery('illuminants','Vivitar',wavelength);
lights = [Vivitar,OfficeFL,SimonFraserIlluminants,FL7,FL2,FL11,D75,D65,D55,D50,C,B,A];


% SPDs of common light sources
% allLights = specQuery('illuminants');
% for i=1:length(allLights)
%     light(:,i) = specQuery('illuminants',allLights(i).name,wavelength);
% end

% normalize the total energy for each light
mx = max(lights);
lights = lights*diag(1./mx);
% plot(light)

% Read in the surface spectral reflectances
clothes = specQuery('surfaces','Clothes',wavelength);
food = specQuery('surfaces','Food',wavelength);
hair = specQuery('surfaces','Hair',wavelength);
objects = specQuery('surfaces','Objects',wavelength);
nature = specQuery('surfaces','Nature',wavelength);
paint = specQuery('surfaces','Paint',wavelength);
skin = specQuery('surfaces','SkinReflectance',wavelength);
macbeth = specQuery('surfaces','macbethChart',wavelength);
% allSurfaces = specQuery('surfaces');
%check the data for skin - svd is not working for skin 
surfaces = [macbeth,clothes,food,hair,objects,nature,paint];

% Using the list of lights and surfaces, create the set of color signals
nBases = 6;
[colorSignalBasis, colorSignals, sValues] = lmColorSignalBasis(lights,surfaces,nBases);
% figure; plot(colorSignalBasis);

% EVALUATE LINEAR MODEL FOR SURFACES
% To figure out the percent variance accounted for, we should be able to do
% something like this, no?  It would be proper to have all the sValues,
% though.
for ii=1:nBases
    explained(ii) = sum(sValues(1:ii))/sum(sValues);
end

% These are the coefficients.  We will try to estimate them from the D100 responses.
coef = colorSignalBasis'*colorSignals;

% Computing the mse between the linear model and the color signals
% for kk=1:nBases
%     dd = colorSignals - colorSignalBasis(:,1:kk)*coef(1:kk,:);
%     dd = sum(dd.^2);
%     err(kk) = mean(dd);
% end
% figure; semilogy(err/sum(err),'*-');
% error include fluorescent lights
%   0.4918    0.2818    0.1014    0.0523    0.0288    0.0177    0.0105    0.0075    0.0051    0.0031
% error exclude fluorescent 
%   0.7281    0.1769    0.0434    0.0214    0.0128    0.0067    0.0043    0.0030    0.0020    0.0014
 
% Now, build a set of filters and their responses to the color signals.
noiseSD = 0.03;
err = zeros(27,27); 
err2 = zeros(27,27);
for ii=1:27
    for jj=(ii+1):27
        filterList = filters(:,[ii,jj]);
        sensor = combineSensorsFilters(D100,filterList);
        
        resp   = sensor'*colorSignals;
        resp   = resp + noiseSD*randn(size(resp));
        
        % Now, ask how well we can recover the coefficients from these responses.
        % Specifically, we want coeff = E*resp, so we are looking for
        % coeff*pinv(resp), so A/B  is roughtly B*INV(A)
        E = coef/resp;
        estCoef = E*resp;
        
        % Here are the differences between the real and estimated color signals.
        errEst = colorSignalBasis*(coef - estCoef);
%         clf; plot(wavelength,errEst,'r-'); hold on
%         plot(wavelength,filterList,'b-'); 
%         set(gca,'ylim',[-.3 1.0]); 
%         pause
        v= (coef - estCoef);
        err(ii,jj) = norm(v(:));
        err2(ii,jj) = norm(v);
    end
end

figure; imagesc(err); colorbar;
figure; imagesc(err2); colorbar;

figure; plot(D100);
hold on
plot(filters(:,24),'k')
