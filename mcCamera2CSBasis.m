function coef  = mcCamera2CSBasis(sensor, colorSignalBasis, mcHDRImage)
%
%   coef = mcCamera2CSBasis(sensor, colorSignalBasis, mcHDRImage)
%
%Author: FX, BW
%Purpose:
%    Compute the basis coefficients from knowledge of 
%    the sensor responsivities, sensor
%    the color signal basis functions, colorSignalBasis,
%    and the camera response, RGB.
%

% Form the matrix that maps basis coefficients into sensor responses.  
%
% The color filters may not be very independent of one another.  So, we
% take care to measure the singular coefficients
% limit singularity problems, we only use these greater than 0.01 of the
% max singular value.
%
%  These equations are written as RGB = sensor' * basis * coef
%  To estimate coef, we compute assuming RGB in columns and coef in
%  columns. Recall that the XW format, though, has the RGB and coef in
%  rows.  So, we must account for this below.

% for ii=1:9, plot(sensor(:,ii)); set(gca,'ylim',[0 1]); pause; end
% plot(wavelength,colorSignalBasis)

% The matrix cam2cs will convert a column vector of camera measurements
% into the color signal coefficients.  So, if d is a column vector of
% camera measurements, cam2cs*d is a set of coefficients.
A = sensor' * colorSignalBasis;
[s,v,d] = svd(A);
tol = v(1)*0.01;
cam2cs = pinv(A,tol);

[r,c,w] = size(mcHDRImage);
XW = RGB2XWFormat(mcHDRImage);

% Here is where we put XW data into rows, and then we put the coef values
% back into rows when we are done.
coef = (cam2cs*XW')';
coef = XW2RGBFormat(coef,r,c);

return;