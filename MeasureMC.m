% Script:  MeasureMC
%
% Author: ImagEval Purpose:
%    Assess how well we are converting the HDR Nikon NEF data into
%    multispectral files used as input for vCamera-2.0.
%    
%    To run this script, you must first step through CombineColor to create the
%    necessary global variables.  These are the multi-capture HDR image
%    (mcHDRImage), the sensor data (sensor) and the csBasis.

% colorSignalBasis = csBasis.basis;
colorSignalBasis = csBasis.basis;
wavelength = csBasis.wave;
% figure(3); plot(wavelength,colorSignalBasis)

% This is the conversion matrix used in mcCamera2CSBasis();
A = sensor' * colorSignalBasis;
[s,v,d] = svd(A);
tol = v(1)*0.01;
cam2cs = pinv(A,tol);

% With graphical input, read the camera responses to all 24 Macbeth color
% patches. We do this in the order of upper left down to lower right with
% the gray series on the bottom and white on the left.
% figure(1); imageSPD(mcHDRImage.^(1/2.2))
% for ii=1:24
%     rect = round(getrect(gcf));
%     cmin = rect(1); cmax = rect(1)+rect(3);
%     rmin = rect(2); rmax = rect(2)+rect(4);
%     r = rmin:rmax; c = cmin:cmax;
%     temp = mcHDRImage(r,c,:); w = size(temp,3);
%     temp = reshape(temp,length(r)*length(c),w);
%     fprintf('Select %.0f\t',ii);
%     sensorMean(:,ii) = mean(temp)';
% end
% save sensorMeanFluoresenct sensorMean
load C:\Joyce\Matlab\DigitalCameraSimulators\PDC\Applications\Data\Multicapture\sensorMeanFluorescent
% load sensorMeanTungsten

% We know we have a problem with the absolute scaling.  At the moment we
% are handling this problem by setting the scene luminance within vCamera
% itself.  Here, we simply scale the estimated levels so that the maximum
% value in the scene is 100.
estimatedSignal = colorSignalBasis*cam2cs*sensorMean;
estimatedSignal = estimatedSignal/mean(estimatedSignal(:));

% This is the white patch, in case you want to look at just one.
% figure(2); plot(wavelength,estimatedSignal(:,19))
% hold on;   plot(wavelength,macbethTG(:,19)); 

% Which illuminant or input file are we using?
fname = 'macbethFL';

measuredSignal = vcReadSpectra(fname,wavelength);
measuredSignal = measuredSignal/mean(measuredSignal(:));

% Now you can plot all of the measured signals and the estimated signals in
% the same figure.
figure(2);
mx =max(measuredSignal(:));
for ii=1:24 
    subplot(4,6,ii), 
    plot(wavelength,measuredSignal(:,ii),'r-',...
        wavelength,estimatedSignal(:,ii),'b--'); 
    set(gca,'ylim',[0,mx]);
end

% If you want to make a figure of the sensors, run this code.
figure(3)
for ii=1:9 
    subplot(3,3,ii), 
    plot(wavelength,sensor(:,ii)); 
    set(gca,'ylim',[0 1]); 
end


% To verify the coefficients with respect to the measurements, we can run
% this code.  This basically confirms that cam2cs*mcHDRImage equals mcCOEFF
% 

figure(1); imageSPD(abs(mcCOEF).^(1/2.2))
rect = round(getrect(gcf));
cmin = rect(1); cmax = rect(1)+rect(3);
rmin = rect(2); rmax = rect(2)+rect(4);
r = rmin:rmax; c = cmin:cmax;
temp = mcCOEF(r,c,:); w = size(temp,3);
temp = reshape(temp,length(r)*length(c),w);
coef = mean(temp)';
figure(2); plot(colorSignalBasis*coef)