
% CorrectIlluminantDataStructure

% This reads in the illuminant file and renames variables
foo = load('illuminant.mat');
data = foo.spectral;
wavelength = foo.wavelength
ieSaveSpectralFile(wavelength,data,comments,'illuminant.mat');