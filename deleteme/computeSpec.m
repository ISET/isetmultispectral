function [ coef ] = computeSpec( sensor, bases, resp)
% computeSpec : find the best estimation of spectral data
%
% [ coef ] = computeSpec( sensor, bases, resp)
%
% Estimate the spectral of input color signals based on linear model
%
% spec: Estimated spectral of input color signal
%
% sensor: spectral response of sensor (with and without filters)
%  bases: base functions for input color signals  
%   resp: sensor response 
%
% Written by  : Feng Xiao
% Last Updated: 04-23-03

A = sensor' * bases;
ss = size(resp);

dims = ndims(resp);
r = reshape(resp, [ss(1), prod(ss)/ss(1)]);

coef = pinv(A)*r;
% spec = bases*coef;

if dims>1
    coef = reshape(coef,[size(coef,1) ss(2:end)]);
end

end

