function sensor = combineSensorsFilters(camera,filterList);
%
%    sensor = combineSensorsFilters(camera,filterList);
%
% Combine the camera sensors (column of camera) with  filters in the columns of
% filterList
%

sensor = camera;

for ii=1:size(filterList,2)
    sensor = [sensor, diag(filterList(:,ii))*camera];
end

return;
