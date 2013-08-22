%% Script reads a number of NEF images in a specified folder and calculates
%% dark current noise

clear all;

imDir = '/media/sdb1/work/samsung/noise_characterization/d200ir/read_noise';


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

%% Size of area that we average over
samplePixels=200;
%-----------------------------------

allImagesR=zeros(samplePixels,samplePixels,nImages);
allImagesG=zeros(samplePixels,samplePixels,nImages);
allImagesB=zeros(samplePixels,samplePixels,nImages);

for imageNumber=1:nImages
    
    imName=nefFiles(imageNumber).name;
    inFile=fullfile(imDir,imName);
    
    disp(sprintf('Reading image %d of %d', imageNumber, nImages));

    dcrawData = nefDCrawWrapper(inFile);
    image = dcrawData.rawimage;
    
    %% Separate channels 
    %% ************** This script is for d200-RGGB **********************   
    Ar=image; Ar(2:2:end,:)=[]; Ar(:,2:2:end)=[];
    Ab=image; Ab(1:2:end,:)=[]; Ab(:,1:2:end)=[];
    Ag1=image; Ag1(2:2:end,:)=[]; Ag1(:,1:2:end)=[];
    Ag2=image; Ag2(1:2:end,:)=[]; Ag2(:,2:2:end)=[];
    
    [mm,nn]=size(Ar); % Get size of downsampled image
    %% Take RGB values from an area in the center of the image
    startPixel=round(mm/2)-samplePixels/2+1;
    stopPixel=round(mm/2)+samplePixels/2; 
    ar=Ar(startPixel:stopPixel,startPixel:stopPixel);
    ab=Ab(startPixel:stopPixel,startPixel:stopPixel);
    ag1=Ag1(startPixel:stopPixel,startPixel:stopPixel);
    ag2=Ag2(startPixel:stopPixel,startPixel:stopPixel);
    %ag=(ag1+ag2)/2;
    ag=ag1;
    
    allImagesR(:,:,imageNumber)=ar;
    allImagesG(:,:,imageNumber)=ag;
    allImagesB(:,:,imageNumber)=ab;
end


meanR=mean(allImagesR,3);
stdR=std(allImagesR,0,3);
meanG=mean(allImagesG,3);
stdG=std(allImagesG,0,3);
meanB=mean(allImagesB,3);
stdB=std(allImagesB,0,3);

        
% Dark signal non-uniformity (DSNU) is estimated by averaging multiple
% measurements in the dark using a fixed exposure duration. 
% By averaging over multiple measurements, we minimize the read noise.  
% We then calculate the variance in the mean level across pixels to 
% estimate dark signal non-uniformity.
DSNUr=std(meanR(:));
DSNUg=std(meanG(:));
DSNUb=std(meanB(:));

