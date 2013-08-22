function p = mcRootPath
% Return the string for the multicapture root directory
%
%
% JEF/BW scienlab 2004

fullName = which('mcRootPath');
p = fileparts(fullName);

end
