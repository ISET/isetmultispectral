function [coef,basis,imgMean] = mcCreateMultispectralBases(imgMS,wave,nDim)
% Create an ISET multispectral image from a raw multispectral array
%
%   [coef,basis,imgMean] = mcCreateMultispectralBases(imgMS,wave,nDim)
%
% imgMS is either a (row,col,wave) multispectral 3D matrix or it is a
% filename that contains a variable named spectralImage with such a 3D
% matrix.
%
% imgMS: Multispectral image
% wave:  Wavelengths in nm
% nDim:  Number of basis functions
%
% We compute the principal components of all the spectral data in this 3D
% array, and we return the coefficients, basis functions, and image mean.
%
% Example:
% Load M x N x 173 spectral image and reduce its size for debugging 
%   cd('/home/parmar/samsung/algs/multispectral_images') 
%   tmp = load('spectralImageFruit');
%   img = tmp.spectralImage(1:4:end,1:4:end,:);
%   figure(2); imagesc(sum(img,3)); axis image; colormap(gray(256));
%   wave = 380:4:1068;
%   [coef,basis,imgMean] = mcCreateMultispectralBases(img,wave,10);
%  
% To reconstruct the 3D array data
%
%    img2 = imageLinearTransform(coef,basis.basis');
%    [img2,r,c] = RGB2XWFormat(img2);
%    img2 = repmat(imgMean(:),1,r*c) + img2';
%    img2 = XW2RGBFormat(img2',r,c);
%    figure(2); imagesc(sum(img2,3)); colormap(gray); axis image
%
% To save the image for ISET reading you can call
%  
%    comment = 'Infrared, fruit bowl, 2007-08, tungsten';
%    fullName = ieSaveMultiSpectralImage('',coef,basis,comment,imgMean);
%
%    tmp = vcReadImage;
%    figure(1); imagesc(sum(tmp,3)); colormap(gray); axis image
%    figure(3); plot(tmp(1:3:end),img(1:3:end),'.')
%    figure(3); hist( (tmp(:) - img(:)) / max(img(:)) ,100);
%

% Process input arguments
if ieNotDefined('wave'),  error('Wavelength samples required'); end
if ieNotDefined('imgMS'), imgMS = vcSelectImage; end
if ieNotDefined('nDim'),  nDim = ieReadNumber('Dimension',5,'%.0f'); end
if ischar(imgMS),         tmp = load(imgMS); imgMS = tmp.spectralImage; end

% Make the image into a set of spectral vectors in the columns of imgXW
% The rows are different spatial positions
% The columns are different wavelengths.
[imgXW,r,c,w] = RGB2XWFormat(imgMS);
clear imgMS

% Matlab statistics toolbox to compute the principal components
% [bas, coef] = princomp(imgXW);

% Alternative calculation method
imgMean  = mean(imgXW,1)';
imgXW     = imgXW - repmat(imgMean',size(imgXW,1),1);
[U, S, V] = svds(imgXW'*imgXW, nDim);
% vcNewGraphWin; plot(wave,U)

% Create the return variables
% bas(:,((nDim+1):end)) = [];
basis.wave = wave;
basis.basis = U;

% coef(:,((nDim+1):end))  = [];
coef = imgXW*U;
coef = XW2RGBFormat(coef,r,c);

return;



%% Energy concentration

s1=sum((pcVar));
s2=sum(pcVar(1:3));
eConc=100*s2/s1;

%% Plot first 3 principal components

xx=380:4:1068;
xx=1:173;

figure
plot(xx,V(:,1),'LineWidth',3,'Color',[0 0 0],'LineStyle','-')
hold on;
plot(xx,V(:,2),'LineWidth',3,'Color',[0 0 0],'LineStyle','--')
plot(xx,V(:,3),'LineWidth',3,'Color',[0 0 0],'LineStyle',':');
plot(xx,V(:,4),'LineWidth',4,'Color',[0 0 0],'LineStyle',':');
hold off

%% Plot Eigenvalues 
%ss=zeros(31);
eConc=zeros(31,1);
ss=zeros(31,1);
for ii=1:31
    ss(ii)=sum((pcVar(1:ii)));
    eConc(ii)=100*ss(ii)/s1;
end
figure,
plot(eConc)
figure, plot(sqrt(pcVar),'x')

%% 
pcscore=Sc*V;
nDim = 7;
[res,Schat]=pcares(Sc,nDim);

[m,n]=size(res); normError=[]; resT=[];
for kk=1:m
normError = [normError; (res(kk,:)*res(kk,:)')];
resT = [resT; Sc(kk,:)*Sc(kk,:)'];
end

mse=mean(normError)/mean(resT)
10*log(mse)
%A1 = load('Data/betaMatrix_noScattering.dat');

figure
%wavelength=400:10:700;
wavelength=xx;
xample=30
plot(wavelength,Sc(xample,:)+Sm); 
hold on; 
plot(wavelength,Schat(xample,:)+Sm,'--')
xample=20
plot(wavelength,Sc(xample,:)+Sm); 
plot(wavelength,Schat(xample,:)+Sm,'--')
%set(gca,'xLim',[380 720])

set(gca,'FontSize',16,'FontWeight','bold')

plot(Sc(1,:)); hold on; plot(Schat(1,:))