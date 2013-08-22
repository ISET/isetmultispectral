function dcrawData = nefDCrawWrapper(fname, onlyMetadata)
% Uses Dave Coffin's dcraw script to read image data and metadata
% Usage: data = nefdcrawWrapper(INFILE,ONLYMETADATA)
% - INFILE is a Nikon NEF file
% - Returns image only if ONLYMETADATA=0; else returns metadata
%
% - outfile sample:
%   data =
%             iso: '200'
%         shutter: '1/8000.0 sec'
%        aperture: 'f/0.0'
%     focallength: '0.0 mm'
%         pattern: 'RGGBRGGBRGGBR'
%        rawimage: [2616x3900 uint16]


% Sample output of dcraw -i -v
% Filename: C:\nkCaptureTemp\Img0019.nef
% Timestamp: Wed Jun 13 08:00:06 2007
% Camera: NIKON D2Xs
% ISO speed: 500
% Shutter: 1/15.0 sec
% Aperture: f/0.0
% Focal length: 0.0 mm
% Secondary pixels: no
% Embedded ICC profile: no
% Decodable with dcraw: yes
% Thumb size:  4288 x 2848
% Full size:   4320 x 2868
% Image size:  4320 x 2868
% Output size: 4320 x 2868
% Raw colors: 3
% Filter pattern: RGGBRGGBRGGBRGGB
% Daylight multipliers: 1.789316 0.926890 1.297875
% Camera multipliers: 340.000000 256.000000 498.000000 256.000000

%C = textscan(str,'%*s%*s%*s%*s%s%*s')
%dcraw.model=char(C{1})

% mp - Jun 2007

if ~exist(fname,'file'), error('Nikon NEF file required'); end

if nargin ~= 2,     onlyMetadata = 0;
elseif ~(onlyMetadata == 0 || onlyMetadata == 1 )
    error('onlyMetadata should be either 1 or 0.');
end

%% Read the header
dcrawExe  = fullfile(mcRootPath,'nef','dcraw','dcraw-9.19-ms-64-bit');
[prc,str] = eval(sprintf('dos(''%s -i -v %s'')',dcrawExe,fname)); %#ok<ASGLU>

cameraModelIndex = strfind(str,'Camera');
isoIndex         = strfind(str,'ISO speed');
shutterIndex     = strfind(str,'Shutter');
apertureIndex    = strfind(str,'Aperture');
fIndex           = strfind(str,'Focal Length');
patternIndex     = strfind(str,'Filter pattern');

%% Tell the user what's happening
if isempty(cameraModelIndex)
    disp('dcraw data does not include Camera model');
end
if isempty(isoIndex)
    disp('dcraw data does not include ISO speed');
end
if isempty(shutterIndex)
    disp('dcraw data does not Shutter speed');
end
if isempty(apertureIndex)
    disp('dcraw data does not include Aperture');
end
if isempty(fIndex)
    disp('dcraw data does not include Focal length');
end
if isempty(patternIndex)
    disp('dcraw data does not include CFA pattern ');
end

if ~(isempty(cameraModelIndex) && isempty(isoIndex))
    dcrawData.cameraModel=str(cameraModelIndex+8:isoIndex-2);
end
if ~(isempty(isoIndex) && isempty(shutterIndex))
    dcrawData.iso=str(isoIndex+11:shutterIndex-2);
end
if ~(isempty(apertureIndex) && isempty(shutterIndex))
    dcrawData.shutter=str(shutterIndex+9:apertureIndex-2);
end
if ~(isempty(fIndex) && isempty(apertureIndex))
    dcrawData.aperture=str(apertureIndex+10:fIndex-2);
end
if ~isempty(fIndex)
    dcrawData.focallength=str(fIndex+14:strfind(str,'mm')+1);
end
if ~isempty(patternIndex)
    dcrawData.pattern=str(patternIndex+16:patternIndex+16+12);
end

%% Read the data, if asked
if ~onlyMetadata
    % Generate raw pgm image from the nef file
    eval(sprintf('dos(''%s -D -4 %s'')',dcrawExe,fname));
    % Read it
    dcrawData.rawimage=imread(sprintf('%s.pgm',fname(1:end-4)));
end

end
