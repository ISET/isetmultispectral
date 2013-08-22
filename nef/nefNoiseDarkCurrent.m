%% Script reads a number of NEF images in a specified folder and calculates
%% dark current noise

clear all;

imDir = '/storage-2/noise_characterization/d200ir/dark_current_2';


% Get the file names from imDir
d = dir(imDir);
nEntries = length(d); 

% Find NEF images in dir
fileType = zeros(nEntries,1);
for kk = 1:nEntries
    fileType(kk) = isNEFfile(fullfile(imDir,d(kk).name));
end
nefFiles = d(fileType == 1);
nImages = length(nefFiles);


% Size of area that we average over 
samplePixels = 200;

% initialize channel arrays
allImagesR   = zeros(samplePixels,samplePixels,nImages);
allImagesG   = zeros(samplePixels,samplePixels,nImages);
allImagesB   = zeros(samplePixels,samplePixels,nImages);
expDurations = zeros(nImages,1); % 

for imageNumber = 1:nImages 
    
    imName = nefFiles(imageNumber).name;
    inFile = fullfile(imDir,imName);
    
    disp(sprintf('Reading image %d of %d', imageNumber, nImages));

    dcrawData = nefDCrawWrapper(inFile);
    exposure = dcrawData.shutter; % This will be a string that ends with ' sec'
    % Convert value in string to float
    tempIndex = findstr(exposure,'sec');
    expDurations(imageNumber) = str2num(exposure(1:tempIndex-2));
    
      
    %% Get image from dcraw o/p 
    image = dcrawData.rawimage;
    
    %% ************** This script is for d200-RGGB **********************   
    % We know the CFA type for the Nikon D200. Only sampled channel values
    % are used in the computation of noise statistics
    Ar=image; Ar(2:2:end,:)=[]; Ar(:,2:2:end)=[];
    Ab=image; Ab(1:2:end,:)=[]; Ab(:,1:2:end)=[];
    Ag1=image; Ag1(2:2:end,:)=[]; Ag1(:,1:2:end)=[];
    Ag2=image; Ag2(1:2:end,:)=[]; Ag2(:,2:2:end)=[];
    
    [mm,nn] = size(Ar); % Get size of downsampled image

    %% Take RGB values from an area in the center of the image
    startPixel = round(mm/2)-samplePixels/2+1;
    stopPixel = round(mm/2)+samplePixels/2; 
    ar = Ar(startPixel:stopPixel,startPixel:stopPixel);
    ab = Ab(startPixel:stopPixel,startPixel:stopPixel);
    ag1= Ag1(startPixel:stopPixel,startPixel:stopPixel);
    ag2= Ag2(startPixel:stopPixel,startPixel:stopPixel);
    ag = ag1; %(ag1+ag2)/2;
    % Let's not average the G channel. We choose one of the 2 green
    % channels so that noise values are not affected
    
    allImagesR(:,:,imageNumber)=ar;
    allImagesG(:,:,imageNumber)=ag;
    allImagesB(:,:,imageNumber)=ab;
end

%% Here we find the images that have the same expDuration and average them
[uniqExpDurations,startIndices] = unique(expDurations);
nUniqImages = length(startIndices);

allUniqImagesR = zeros(samplePixels,samplePixels,nUniqImages);
allUniqImagesG = zeros(samplePixels,samplePixels,nUniqImages);
allUniqImagesB = zeros(samplePixels,samplePixels,nUniqImages);

for currExpDuration = 1:length(startIndices)
    uExposure = find(expDurations == uniqExpDurations(currExpDuration));
    uExposureImagesR = allImagesR(:,:,uExposure);
    uExposureImagesG = allImagesG(:,:,uExposure);
    uExposureImagesB = allImagesB(:,:,uExposure);
    
    allUniqImagesR(:,:,currExpDuration) = mean(uExposureImagesR,3);
    allUniqImagesG(:,:,currExpDuration) = mean(uExposureImagesG,3);
    allUniqImagesB(:,:,currExpDuration) = mean(uExposureImagesB,3);    
end


% Dark voltage is analyzed using a set of images of a dark (zero intensity) 
% field taken with exposure durations ranging between 1 and N milliseconds.  
% For each pixel, we fit
% pixelDN = a + b*duration
% a is the read noise
% b is the dark voltage
% Show histogram of a and b values for each pixel.

% Our durations are now in uniqExpDurations
% Corresp. RGB images are in allUniqImagesR/G/B

% Fit linear model y=Ax+b 
aCoeffsR=zeros(samplePixels);
bCoeffsR=zeros(samplePixels);
aCoeffsG=zeros(samplePixels);
bCoeffsG=zeros(samplePixels);
aCoeffsB=zeros(samplePixels);
bCoeffsB=zeros(samplePixels);

% P = POLYFIT(X,Y,1) finds the coefficients of aX+b that fit the data Y 
%     best in a least-squares sense. P is a row vector of length 2 
%     a=P(1), b=P(2).


for jj=1:samplePixels
    for kk=1:samplePixels
%        augExposures=[ones(nUniqImages,1),...
%            squeeze(allUniqImagesR(jj,kk,:))];
%         tempSoln=augExposures\uniqExpDurations;
        tempSoln = polyfit(uniqExpDurations,...
                    squeeze(allUniqImagesR(jj,kk,:)), 1);
        aCoeffsR(jj,kk)=tempSoln(1);
        bCoeffsR(jj,kk)=tempSoln(2);
        
        tempSoln = polyfit(uniqExpDurations,...
                    squeeze(allUniqImagesG(jj,kk,:)), 1);
        aCoeffsG(jj,kk)=tempSoln(1);
        bCoeffsG(jj,kk)=tempSoln(2);
        
        tempSoln = polyfit(uniqExpDurations,...
                    squeeze(allUniqImagesB(jj,kk,:)), 1);
        aCoeffsB(jj,kk)=tempSoln(1);
        bCoeffsB(jj,kk)=tempSoln(2);
    end
end


