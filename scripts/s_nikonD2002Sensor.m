% s_NikonD70_Sensor
%
% Convert a Nikon D70 NEF data file into ISET sensor format.  This
% script illustrates how to import the data from a camera and explore them
% with the ISET metric tools.
%
% In this script, you begin with a Nikon NEF file (that you should
% capture).  Then you read in and crop the data. Finally, you import the
% data into the ISET-Sensor window.
%
% To read the data into ISET, 
%    * Run ISET 
%    * In the Sensor Window use the "File | Load Sensor (.mat)" to read the
%    data. 
%

% Name the NEF image file here.
% At ImagEval we keep one here:
%  www.imageval.com/public/Products/ISET/download/RawSensorData/NikonD70/Macbeth
fullName = vcSelectDataFile('stayput','r');
if isempty(fullName), return; end
[mosaic,model,mosaicType] = nefRead(fullName,1,1,'d200');

% The Nikon data are 12 bit.  We scale them to double so we can set them
% to volts in the sensor
mosaic = double(mosaic)/(2^12);

% The image is big.  So, we usually crop. 
[mosaic2,rect] = imcrop(mosaic);
rect = round(rect);

% Adjust the rect so we fall neatly on the bayer sampling grid.
% We want the (xmin,ymin) values to both be odd. 
if ~isodd(rect(1)), rect(1)=rect(1)+1; end
if ~isodd(rect(2)), rect(2)=rect(2)+1; end

% We want the (width,height) values to both be even.  Matlab's imcrop
% basically adds one more pixel than you want.  So, annoyingly, we must
% make the width and height odd, so we get an even number of pixels out. 
if ~isodd(rect(3)),  rect(3)=rect(3)+1; end
if ~isodd(rect(4)),  rect(4)=rect(4)+1; end

% Make a Nikon D700 style Bayer grid. 
% sensor = sensorCreate('bayer (grbg)');
sensor = sensorCreate('bayer (rggb)');

% Set pixel parameters consistent with my guesses about the D70
pixel  = sensorGet(sensor,'pixel');
pixel  = pixelSet(pixel,'widthandheight',[6.095,6.095]*10^-6);
vSwing = pixelGet(pixel,'voltageSwing');
sensor = sensorSet(sensor,'pixel',pixel);

% Set the color filter spectral curves here, when you have them.
% sensor = sensorSet(sensor,'expTime',info.ExposureTime);

% Attach the volts to the sensor
volts    = imcrop(mosaic,rect)*vSwing;
sensor   = sensorSet(sensor,'size',size(volts));
sensor   = sensorSet(sensor,'volts',volts);

% Save out the sensor file.  This is the file you can load from the
% ISET-Sensor window using the method described at the top of the file.
fullName = vcExportObject(sensor,[],0);

%-----------------------------------------