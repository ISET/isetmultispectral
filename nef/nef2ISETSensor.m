% This script converts a Nikon NEF data file into ISET sensor format.  This
% permits us to import the data and explore them with the ISET metric
% tools.
%
% To use this script, identify a Nikon NEF file.
% After you read it in, crop the data to the region you want to study
% Export the data to a file
% Run ISET and in the Sensor Window use the Load | Sensor (.mat) to read in
% the data.
%
% You can explore processing methods and metrics as applied to these raw
% data.
%

% Name the image file here.  We could use a GUI to get it
pDir = 'C:\u\brian\Matlab\PDC\Applications\MultiCapture\Data\Images';
fName = 'macbeth_tg_nofil_3.NEF';

'/home/parmar/projects/Pelican/Data/CameraCalibration/RawImages/mc_023.CR2'

%%
fullName = fullfile(pDir,fName);
%%
fullName = '/home/parmar/projects/Pelican/Data/CameraCalibration/RawImages/mc_023.CR2';
[mosaic,model,mosaicType] = nefRead(fullName,1,1);
info = nefInfo(fullName);

% The data come in as 12 bit.  We scale them to double so we can set them
% to volts in the sensor
mosaic = double(mosaic)/(2^12);

% The image is big.  Show an image and take the part you want
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

% Make a Nikon D100 style Bayer grid. 
sensor = sensorCreate('bayer (grbg)');

% Set pixel parameters
pixel = sensorGet(sensor,'pixel');
pixel = pixelSet(pixel,'widthandheight',[6,6]*10^-6);
vSwing = pixelGet(pixel,'voltageSwing');

sensor = sensorSet(sensor,'pixel',pixel);

% Set the color filter spectral curves here, when you have them.
sensor = sensorSet(sensor,'expTime',info.ExposureTime);

% Attach the volts to the sensor
volts = imcrop(mosaic,rect)*vSwing;
sensor = sensorSet(sensor,'size',size(volts));
sensor = sensorSet(sensor,'volts',volts);
fullName = vcExportObject(sensor,[],0);
