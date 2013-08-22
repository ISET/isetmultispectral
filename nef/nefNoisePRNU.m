%%
%% Script reads a number of NEF images in a specified folder and calculates
%% photo receptor nonuniformity

clear all;

imDir = '/storage-2/noise_characterization/d200/prnu';


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
%%Size of area that we average over-------
samplePixels=200;
%%------------------------------------------

allImagesR=zeros(samplePixels,samplePixels,nImages);
allImagesG=zeros(samplePixels,samplePixels,nImages);
allImagesB=zeros(samplePixels,samplePixels,nImages);
expDurations=zeros(nImages,1); % 

for imageNumber=1:nImages
    
    imName=nefFiles(imageNumber).name;
    inFile=fullfile(imDir,imName);
    
    disp(sprintf('Reading image %d of %d',imageNumber,nImages));
    
    dcrawData = nefDCrawWrapper(inFile);
    exposure  = dcrawData.shutter; % a string that ends with ' sec'
    tempIndex = findstr(exposure,'sec');
    expDurations(imageNumber) = str2num(exposure(1:tempIndex-2));   
      
    %% Get image from dcraw o/p 
    image=dcrawData.rawimage;
    
    %% ************** This script is for d200-RGGB **********************   
    Ar=image; Ar(2:2:end,:)=[]; Ar(:,2:2:end)=[];
    Ab=image; Ab(1:2:end,:)=[]; Ab(:,1:2:end)=[];
    Ag1=image; Ag1(2:2:end,:)=[]; Ag1(:,1:2:end)=[];
    Ag2=image; Ag2(1:2:end,:)=[]; Ag2(:,2:2:end)=[];
    
    [mm,nn]=size(Ar); % Get size of downsampled image
    
    %% Take RGB values from an area in the center of the image
    startPixel=round(mm/2)-samplePixels/2+1;
    stopPixel=round(mm/2)+samplePixels/2; 
    
    ar  = Ar(startPixel:stopPixel,startPixel:stopPixel);
    ab  = Ab(startPixel:stopPixel,startPixel:stopPixel);
    ag1 = Ag1(startPixel:stopPixel,startPixel:stopPixel);
    ag2 = Ag2(startPixel:stopPixel,startPixel:stopPixel);
    ag  = (ag1+ag2)/2;
    
    allImagesR(:,:,imageNumber)=ar;
    allImagesG(:,:,imageNumber)=ag;
    allImagesB(:,:,imageNumber)=ab;
end

%%Here we find images that have the same expDuration and average them
[uniqExpDurations,startIndices]=unique(expDurations);
nUniqImages=length(startIndices);

allUniqImagesR=zeros(samplePixels,samplePixels,nUniqImages);
allUniqImagesG=zeros(samplePixels,samplePixels,nUniqImages);
allUniqImagesB=zeros(samplePixels,samplePixels,nUniqImages);

for currExpDurationIndex=1:length(startIndices)
    uExposure=find(expDurations==uniqExpDurations(currExpDurationIndex));
    uExposureImagesR=allImagesR(:,:,uExposure);
    uExposureImagesG=allImagesG(:,:,uExposure);
    uExposureImagesB=allImagesB(:,:,uExposure);
    
    allUniqImagesR(:,:,currExpDurationIndex)=mean(uExposureImagesR,3);
    allUniqImagesG(:,:,currExpDurationIndex)=mean(uExposureImagesG,3);
    allUniqImagesB(:,:,currExpDurationIndex)=mean(uExposureImagesB,3);    
end

% Photoreceptor non-uniformity (PRNU) is estimated by analyzing sensor 
% images of a uniform light field captured with different exposure 
% durations.  We measure the increase in mean digital value as exposure 
% duration increases. 
% 
% Do not use images that are dominated by noise or are saturated.
% For other images, calculate the linear rate of increase with exposure 
% duration for each pixel.
% 
% PRNU is the variance in slope across different pixels.  The slope differs
% across the color pixels because they each have different light sensitivity.
% The variance of the slope, measured as a proportion of the mean slope, is 
% the same across the colored pixels.



% Our durations are now in uniqExpDurations
% Corresp. RGB images are in allUniqImagesR/G/B

% Find slopes for each pixel 

% Reject saturated and noisy images (only keep images with mean 
% channel values in the interval [5, 4080]).

meanRs=zeros(nUniqImages,1);
meanGs=zeros(nUniqImages,1);
meanBs=zeros(nUniqImages,1);
for jj=1:nUniqImages
    tempImage=allUniqImagesR(:,:,jj);
    meanRs(jj)=mean(tempImage(:));
    tempImage=allUniqImagesG(:,:,jj);
    meanGs(jj)=mean(tempImage(:));
    tempImage=allUniqImagesB(:,:,jj);
    meanBs(jj)=mean(tempImage(:));
end

% Also specify default values (in case our images don't span dynamic range)
keepRmin=1; keepGmin=1; keepBmin=1;
keepRmax=nUniqImages; keepGmax=nUniqImages; keepBmax=nUniqImages;

keepRmin=find(meanRs<=5);keepRmax=find(meanRs>=4095);
if isempty(keepRmin), keepRmin=1; end
if isempty(keepRmax), keepRmax=nUniqImages; end
keepRindices=keepRmin(end):keepRmax(1);

keepGmin=find(meanGs<=5);keepGmax=find(meanGs>=4095);
if isempty(keepGmin), keepGmin=1; end
if isempty(keepGmax), keepGmax=nUniqImages; end
keepGindices=keepGmin(end):keepGmax(1);

keepBmin=find(meanBs<=5);keepBmax=find(meanBs>=4095);
if isempty(keepBmin), keepBmin=1; end
if isempty(keepBmax), keepBmax=nUniqImages; end
keepBindices=keepBmin(end):keepBmax(1);

allKeptImagesR=allUniqImagesR(:,:,keepRindices); 
allKeptImagesG=allUniqImagesG(:,:,keepGindices);
allKeptImagesB=allUniqImagesB(:,:,keepBindices);
expR=uniqExpDurations(keepRindices);
expG=uniqExpDurations(keepGindices);
expB=uniqExpDurations(keepBindices);

%-------------------------------------------------------------------------

aCoeffsR=zeros(samplePixels); bCoeffsR=zeros(samplePixels);
aCoeffsG=zeros(samplePixels); bCoeffsG=zeros(samplePixels);
aCoeffsB=zeros(samplePixels); bCoeffsB=zeros(samplePixels);

% P = POLYFIT(X,Y,1) finds the coefficients of aX+b that fit the data Y 
%     best in a least-squares sense. P is a row vector of length 2 
%     a=P(1), b=P(2).

for jj=1:samplePixels
    for kk=1:samplePixels
        tempSoln=polyfit(expR,squeeze(allKeptImagesR(jj,kk,:)),1);
        aCoeffsR(jj,kk)=tempSoln(1);
        bCoeffsR(jj,kk)=tempSoln(2);
        
        tempSoln=polyfit(expG,squeeze(allKeptImagesG(jj,kk,:)),1);
        aCoeffsG(jj,kk)=tempSoln(1);
        bCoeffsG(jj,kk)=tempSoln(2);
        
        tempSoln=polyfit(expB,squeeze(allKeptImagesB(jj,kk,:)),1);
        aCoeffsB(jj,kk)=tempSoln(1);
        bCoeffsB(jj,kk)=tempSoln(2);
    end
end
% 
% for jj=1:length(keepGindices)
%     for kk=1:length(keepGindices)
%         tempSoln=polyfit(expG,squeeze(allKeptImagesG(jj,kk,:)),1);
%         aCoeffsG(jj,kk)=tempSoln(1);
%         bCoeffsG(jj,kk)=tempSoln(2);
%     end
% end
% for jj=1:length(keepBindices)
%     for kk=1:length(keepBindices)
%         tempSoln=polyfit(expB,squeeze(allKeptImagesB(jj,kk,:)),1);
%         aCoeffsB(jj,kk)=tempSoln(1);
%         bCoeffsB(jj,kk)=tempSoln(2);
%     end
% end
% 
% 
