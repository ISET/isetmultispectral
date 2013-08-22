%% function hdri = nefHDRI(fnames,saturation)
%%    create high dynamic range image from Nikon NEF files taken at
%%    different exposures
%%
%%  Input: 
%%      fnames -- names of Nikon NEF files
%%      saturation -- saturation threshold

function hdri = nefHDRI(fnames,saturation)

%% default ISO settings
ISO = 200;  

%% scaling from digital value to approximately cd/m2
DV2CD = 20;

for i=1:length(fnames)
    info = nefinfo(fnames{i});
    ratio(i) = DV2CD*ISO*info.ExposureTime/info.FNumber^2;
    raw = nefread(fnames{i});
    red(:,:,i)=raw(:,:,1);
    green(:,:,i)=raw(:,:,2);
    blue(:,:,i)=raw(:,:,3);
end
    
if ~exist('saturation','var')
    saturation = 3200;
end

hdri(:,:,1) = createHDRI(red,ratio,saturation);
hdri(:,:,2) = createHDRI(green,ratio,saturation);
hdri(:,:,3) = createHDRI(blue,ratio,saturation);

