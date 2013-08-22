function result=ieNefDenoising(nefFileNameString, nefIndex, nefCounts, blank, subMethod, cropRect);
% Read in a NEF file and apply both averaging and subtraction-of-background on it. 
%
% function dd=ieNefDenoising(Model,nefFileNameString, nefIndex,
% nefCounts, blank, method);
% 
% Inputs: 
%    nefCounts: the number of images that are used in averaging
%    blank: the background image that is to be subtracted. If it is [],
%    then there is no need for subtraction.
%    method: 0 - we subtract the whole background image pointwise
%            1 - we subtract the mean of the whole background image
%            2 - we subtract the mean of the background of cropped region (if crop region exists)
%    cropRect: region of cropping, [] means don't crop.

if ieNotDefined('cropRect') 
    cropRect=[];
end;

if ieNotDefined('subMethod')
    subMethod=0;
end;

if ieNotDefined('blank')
    blank=[];
end;

if ieNotDefined('nefCounts')
    nefCounts=1;
end;

if ieNotDefined('nefIndex')
    nefIndex=0;
end;

if ieNotDefined('nefFileNameString')
    error('nefFileNameString needed');
end;

% Read NEF images and average
[raw]=double(nefread(sprintf(nefFileNameString, nefIndex), 1));

raw(:, :, 2)=(raw(:, :, 2)+raw(:, :, 4))/2;

dd=raw(:, :, 1:3);

for ii=2:nefCounts;

    [raw]=double(nefread(sprintf(nefFileNameString, nefIndex-1+ii), 1));

    raw(:, :, 2)=(raw(:, :, 2)+raw(:, :, 4))/2;

    dd=dd+raw(:, :, 1:3);

end;

dd=dd/nefCounts;

if isempty(cropRect)
    cropRect=[1, 1, size(dd, 2), size(dd, 1)];
end;

ddC=imcrop(dd, cropRect);
blankC=imcrop(blank, cropRect);

% TODO: These images are pretty big.
% clear dd raw;

% TODO: we can do a little bit better in managing peak memory usage.
if isempty(blank)
    result=ddC;
elseif isequal(subMethod, 0)
    result=ddC-blankC;
elseif isequal(subMethod, 1)
    result(:, :, 1)=ddC(:, :, 1)-mean(mean(blank(:, :, 1)));
    result(:, :, 2)=ddC(:, :, 2)-mean(mean(blank(:, :, 2)));
    result(:, :, 3)=ddC(:, :, 3)-mean(mean(blank(:, :, 3)));
elseif isequal(subMethod, 2)
    result(:, :, 1)=ddC(:, :, 1)-mean(mean(blankC(:, :, 1)));
    result(:, :, 2)=ddC(:, :, 2)-mean(mean(blankC(:, :, 2)));
    result(:, :, 3)=ddC(:, :, 3)-mean(mean(blankC(:, :, 3)));
end;
return;