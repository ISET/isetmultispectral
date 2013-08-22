%% mcScaleReflectance
%
% We adjust the mcCOEF so that the illuminant and radiance values produce
% reflectance estimates in the 0,1 range.

%%
fname = 'C:\Users\joyce\Documents\Matlab\SVN\scenedata\NikonWithFilters\HDR_Images\Stanford_Memorial_Church\MemorialChurch2\sr506x759\MemorialChurch2-hdrs.mat';
load(fname);

% We want the photons ( = basis*mcCOEFF) to have proper level of photons.
% By proper we mean that dividing by the illuminant would produce
% reflectance estimates in the range [0-0.9].
%
% We do this allowing 3 percent of the image to be specular.
% We scale the photons so that the 97th percentile of the image has a
% reflectance of 0.9.
%
% Here are the unscaled photons
tmp = imageLinearTransform(mcCOEF,basis.basis');
illuminantPhotons = Energy2Quanta(illuminant.wavelength,illuminant.data);

% Make tmp an estimate of the reflectances by dividing the illuminant out
for ii=1:length(illuminant.wavelength)
    tmp(:,:,ii) = tmp(:,:,ii)/illuminantPhotons(ii);
end

% Scale the coefficients so that the estimated reflectance will have a 97th
% percentile of 0.9.
% If you think there are specularities, set B to 97 rather than 99.
% B = 99;
B = 97;
r = prctile(tmp(:),B);quit

mcCOEF = 0.9*(mcCOEF/r);

% Write out the file with the coefficient and basis information
[p n] = fileparts(fname);
n = sprintf('%s-corrected',n);
newName = fullfile(p,n);

ieSaveMultiSpectralImage(newName,mcCOEF,basis,comment,[],illuminant);
fprintf('Saved %s\n',newName)

%% You can check the scene here
scene = sceneFromFile(newName,'multispectral',100);
vcAddAndSelectObject(scene);
sceneWindow
