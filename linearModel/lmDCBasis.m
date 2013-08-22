function basis = lmDCBasis(wavelength,rampFlag)
%
%  basis = lmDCBasis(wavlength,rampFlag)
%
%Author: ImagEval
%Purpose:
%   Return a constant basis and perhaps a ramp basis, too
%
%   basis = lmDCBasis([400:10:700],1);

% DC and linear ramp
nWave = length(wavelength);
basis(:,1) = ones(nWave,1);
basis(:,1) = basis/sum(basis(:,1));

if rampFlag
    basis(:,2) = [1:nWave]';
    basis(:,2) = basis(:,2)/sum(basis(:,2));
end

return;
