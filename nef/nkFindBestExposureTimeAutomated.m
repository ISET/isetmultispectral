function [eTime, nk] = nkBestExposure(nk,dirName)
% Determine longest, non-saturating exposure for Nikon
%
%   [eTime, nk] = nkBestExposure(nk,dirName)
%
% dirName is the path to the working directory where the Nikon Capture
% software will save its data.
%




exp_setting = [30,25,20,15,13,10,8,6,5,4,3,2.5,2,1.6,1.3,1, ...
    0.7692,1/1.6,1/2,1/2.5,.3333,1/4,1/5,.1667,1/8,1/10,.0769,1/15,1/20,...
    1/25,.0333,1/40,1/50,.0167,1/80,1/100,1/125,1/160,1/200,1/250,.0031,...
    1/400,1/500,.0016,1/800,1/1000,1/1250,1/1600,1/2000,1/2500,.0003,1/4000];

ModelName = nkGet(nk,'model');
[bIsSaturated, exp_time, meanmaxrgb] = ieFindExposureTime(dirName, ModelName);

%fprintf('%f, %f, %f',bIsSaturated,exp_time,meanmaxrgb);
factor = meanmaxrgb/(2^12*0.9);
bestExp = exp_time/factor;

disp(bestExp);

if(bestExp >= 30)
       nkSet(nk,'exposure',30)
       exp_time = 30;
elseif (bestExp <= 1/4000)
       nkSet(nk,'exposure',1/4000)
       exp_time = 1/4000;
else 
    for i = 1:51
        if(bestExp < exp_setting(i) && bestExp >= exp_setting(i+1) )
            end_setting = i+1;
            break;
        end
    end
    nkSet(nk,'exposure',exp_setting(end_setting),exp_time);
end

[bIsSaturated, exp_time, meanmaxrgb] =ieFindExposureTime(dirName, ModelName);

if ((~bIsSaturated) && (exp_time < 30))

    while (~bIsSaturated)
        ieSendButtonClick1('Nikon Capture Camera Control', 'Left');
        [bIsSaturated, exp_time, meanmaxrgb] =ieFindExposureTime(dirName, ModelName);
    end;
    ieSendButtonClick1('Nikon Capture Camera Control', 'Right');
    [bIsSaturated, exp_time, meanmaxrgb] = ieFindExposureTime(dirName, ModelName);

    return;

else

    while ((bIsSaturated) && (exp_time > 1/4000))
        ieSendButtonClick1('Nikon Capture Camera Control', 'Right');
        [bIsSaturated, exp_time, meanmaxrgb] = ieFindExposureTime(dirName, ModelName);
    end;
    ieSendButtonClick1('Nikon Capture Camera Control', 'Right');
    [bIsSaturated, exp_time, meanmaxrgb] = ieFindExposureTime(dirName, ModelName);
    
    return;

end
