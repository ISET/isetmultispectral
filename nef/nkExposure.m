function setTime = nkExposure(nk,desiredETime,currentETime)
%Set Nikon camera exposure time
%
%   setTime = nkExposure(nk,desiredETime,currentETime)
%
% Mainly this routine should be called from nk = nkSet(nk,'exposureTime',val);
% It is possible, if nk has an exposure time field that is correct, to call
% this routine directly.  The exposure time units are seconds.
%
%Example:
%   nk = nkCreate;
%   nk = nkSet(nk,'exposure',0.01);   % Set the exposure time to 10 msec.
%  
%   If you know the field nk.eTime is correct, you can call this using the
%   format:  setTime = nkExposure(nk,0.3);  But, we recommend that you
%   don't because you really have to remember to update the nk structure,
%   too.  So, if you need to run this use:
%
%      setTime = nkExposure(nk,0.3);
%      nk = nkSet(nk,'exposure',setTime);
%

if ieNotDefined('nk'), error('Nikon camera structure required.'); end
if ieNotDefined('currentETime'),
    currentETime = nkGet(nk,'exposureoncamera');
    if isempty(currentETime), error('You must know the current eTime'); end
end
if ieNotDefined('desiredETime'), error('You must set a desired exposure'); end
if desiredETime > 20
    desiredETime = 20;
    warning('Resetting eTime: Exposure time must be 20 sec or less');
end

% Possible exposure times from clicking
expList = [30,25,20,15,13,10,8,6,5,4,3,2.5,2,1.6,1.3,1,...
    0.7692,1/1.6,1/2,1/2.5,.3333,1/4,1/5,.1667,1/8,1/10,.0769,1/15,1/20,1/25,...
    .0333,1/40,1/50,.0167,1/80,1/100,1/125,1/160,1/200,1/250,.0031,1/400,1/500,...
    .0016,1/800,1/1000,1/1250,1/1600,1/2000,1/2500,.0003,1/4000];

% Find the index to the desired exposure time. Set the exposure value to
% the one that is equal or slightly shorter than desiredETime
d = expList - desiredETime;
desiredIndex = find((d <= 0),1,'first');
setTime = expList(desiredIndex);

% Find the current exposure time index 
d = abs(expList - currentETime);
currentIndex = find(d==min(d));

% Find how many clicks we need
if  currentIndex == desiredIndex,  return; end

% Figure out how many clicks you need and then send 'em
nClicks = abs(currentIndex - desiredIndex);
if currentIndex > desiredIndex
    direction = 'Left';
elseif currentIndex < desiredIndex
    direction = 'Right';
end

for ii=1:nClicks, 
    ieSendButtonClick1('Nikon Capture Camera Control', direction); 
    pause(0.05);
end

return;