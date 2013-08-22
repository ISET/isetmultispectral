function s = nkSaturationValue(model)
%Return the saturation level for each Nikon model
%
%   s = nkSaturationValue(model)
%
% It appears that the hardware captures 12 bits and that Nikon capture
% interpolates the values to 14 bits.  Presumably if we do a raw transfer
% (without Nikon Capture) we would get 12 bit data.  With this software we
% appear to get values as high as 2^14.
%
% Example:
%   s = nkSaturationValue;
%

if ieNotDefined('model'), model = 'd100'; end
model = lower(model);

% In raw mode, these models return only 12 bits But the Nikon Capture
% software scales the D70 data through genius-level processing to 14 bits.
% The manual says 16 bits, but I think that is just for processing.  Raw
% data start out as 14 bits and then live on a 16 bit set of values for
% computations.  
if strfind(model,'d100')
    s = 2^14*0.9;       % We think; check these levels
elseif strfind(model,'d70')
    s = 2^14*0.9;
elseif strfind(model,'d2xs')
    s = 2^12*0.9  %% xxx Using dcraw to get 12 bpp - mp
else
    error('Unknown model %s',model);
end

s = round(s);

return;