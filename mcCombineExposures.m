function hdr = mcCombineExposures(images,exposures,saturation,motionFlag)
%Create high dynamic range image from several exposure durations.  
%
%  hdr = mcCombineExposures(images,exposures,saturation,motionFlag)
%
%  Input: 
%      images --     3D matrix (r, c, exposure)
%      exposures --  exposure duration for each frame 
%      saturation -- saturation threshold
%      motionFlag -- motion detection (1,0) (not implemented yet)
%
%
% FX/BW Imageval Consulting LLC, 2005
%% 

% TODO:  Brainard and Zhang have a published algorithm for handling
% saturation cases that we should try to implement here (or elsewhere) in
% the ISET calculations. 

%%
if ~isa(images,'uint16') && ~isa(images,'int16')
    scale = double(max(images(:)))/(2^16-1);
    images = uint16(double(images)/scale);
else 
    scale =1;
end

if ieNotDefined('saturation')
    % We treat saturation as 75% of the maximum.  This should be a flag.
    mmax = double(max(images(:)));
    bits = ceil(log2(mmax+1));
    saturation = 2^bits*0.75;
end

%%
ss = size(images);

if ss(end) ~= length(exposures)
    error('The number of exposures does not equal the number of images.');
end

images = reshape(images,prod(ss)/ss(end),ss(end));

% mexCreateHDRI assumes exposure values in ascending order, so we have to
% reshuffle them if necessary
[exposures, index] = sort(exposures);
dd = index(:) - (1:length(index))';
if sum(abs(dd))~=0
    tmp = images;
    for i=1:length(index) 
        images(:,i) = tmp(:,index(i));
    end
end

exposures = exposures(:)';   % Must be a row vector
hdr = mexCreateHDRI(images,exposures,saturation); 

hdr = reshape(hdr,ss(1:end-1));
hdr = hdr*scale;

end
