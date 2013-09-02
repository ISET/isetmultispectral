function signals = lmLookupSignals(fNames, wavelength, normalize)
%
%  signals = lmLookupSignals(signalList, wavelength)
%
% Caclulate the spectral base functions for color signals based on the
% assumption of surfaces and lighting statistics
%
% Example:
%   lights = lmLookupSignals({'FL7','Vivitar'}, 'illuminants',[400:10:700],1);
%   lights = lmLookupSignals({'FL7','Vivitar'}, 'illuminants',[400:10:700],1);
%
% FX, BW Imageval Consulting, LLC 2005

%% Parameter check
if ~exist('wavelength','var'),  wavelength = 400:10:700; end
if ~exist('normalize','var'),  normalize = 0; end

%% Read in all the signals from the data base
signals = [];
for ii=1:length(fNames)
    signals  =  [signals,vcReadSpectra(fNames{ii},wavelength)];
end

if normalize
    % normalize the total energy 
    signals = signals/diag(sum(signals));
end

end


