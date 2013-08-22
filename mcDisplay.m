function RGB = msDisplay(coef,csBasis,phosphors,gam)
%
%  RGB = msDisplay(coef,csBasis,[phosphors],[gam])
%
% Author: FX, BW
% Purpose:
%     Display a multispectral image with coefficients coef with respect to
%     a color signal basis, colorSignalBasis, on a display with phosphor
%     SPDs passed in as phosphors.
%
%     The coefficients are in RGB format.  The bases and phosphors are in
%     the columns of a matrix.  gam is a real number that describes the
%     display gamma.
%
% Examples:
%
%  msDisplay(coef,colorSignalBasis,wave)
%  msDisplay(coef,colorSignalBasis,wave,phosphors,2.2)

wave = csBasis.wave;
colorSignalBasis = csBasis.basis;

if ~exist('gam','var') gam = 1 ; end
if ~exist('phosphors','var') | isempty(phosphors)
    phosphors = vcReadSpectra('displaySPD',wave);
end

[r,c,nCoefs] = size(coef);

XYZ = vcReadSpectra('XYZ',wave,0);

%  XYZ'*phosphors*RGB =  XYZ'*colorSignalBasis*imgCoef;
Coef2RGB = inv(XYZ'*phosphors)*XYZ'*colorSignalBasis;

lRGB = (Coef2RGB * RGB2XWFormat(coef)')';

lRGB = lRGB / max(lRGB(:)); lRGB = ieClip(lRGB,0,1);

RGB = XW2RGBFormat(lRGB,r,c).^(1/gam);

return;



% The color signal basis coefficients map into display RGB
%
% This is FX's original code.  Probably right, buT I don't understand it.
% -- BW
% A = phosphor'*colorSignalBasis;
% 
% 
% ss = size(coef); 
% 
% lrgb = A *reshape(coef,[ss(1) prod(ss)/ss(1)]);
% lrgb = shiftdim(reshape(lrgb, [3 ss(2) ss(3)]),1);
% lrgb = lrgb/max(lrgb(:)); lrgb(lrgb<0)=0;
% LUT = srgbTrans(linspace(0,1,256),'linear2nonlinear');
% rgb = LUT(round(lrgb*255)+1);