function info = nefInfo(fname)
%Read Nikon D1 .NEF digital camera data file and return its tag information
% 
% Output:
%     info : NEF tag information which includes
%%%           .FNumber
%%%           .ExposureTime
%%%           .ISOSpeedRatings
%%%
%%% Input:
%%%    fname : NEF file name
%%%
% Example:
%   
%%% NEF is an extenstion of TIFF file. Its main IFD(Image File Directory)  
%%% contains TIFF tags. Among them, two tags are very important: 
%%%   Tag 1: ExifOffset (0x8769) used to represent digital camera information
%%%          like FNumber, exposure time and so on
%%%   Tag 2: SubIFDs (0x14A) used to represent CCD RAW data, which usually has 
%%%          2012*1324*12/8 bytes (12 bits/pixel) and resides at the end of NEF file
%%% 
%%%  Nikon D1's CFA (color filter array) is 
%%%
%%%    BGBGBGBGBG
%%%    GRGRGRGRGR
%%%    BGBGBGBGBG
%%%    GRGRGRGRGR 
%%%    BGBGBGBGBG
%%%    GRGRGRGRGR
%%%    BGBGBGBGBG
%%%
%
% Author: Feng Xiao, Stanford University Programable Digital Camera Group
% Date:  08/2000
% modified: 11/2001


info=[];

%% check whether the NEF is little-endian or big-endian
fid = openFile(fname);
if fid==-1, return; end

%%% read the main IFD
info = readMainIFD(fid,info);

%%% read the exif IFD
info = readExifIFD(fid,info);

%%% read Nikon MakerNote IFD
%info=readNikonIFD(fid,info);

fclose(fid);

if ~exist('RGB'), return; end


%% Looks like we don't use this any more to read the RGB.  Just info.

%%% read raw CCD RGB data
% RGB=readRGB(fid,info);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% openFile
%%% NEF files might be little-endian or big-endian.  Start with
%%% little-endian.  If we're wrong, we'll catch it down below and
%%% reopen the file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fid=openFile(fname)

[fid,m] = fopen(fname, 'r', 'ieee-le');

if (fid == -1)
   m
   return;
end

sig = fread(fid, 4, 'uint8')';
if (~isequal(sig, [73 73 42 0]) & ~isequal(sig, [77 77 0 42]))
    error('Not a valid NEF file');
    fclose(fid);
    return;
end

if (sig(1) == 73) %% byte order = 'little-endian';
else              %% byte order = 'big-endian', Must reopen the file.
    pos = ftell(fid);
    fclose(fid);
    fid = fopen(fname, 'r', 'ieee-be');
    fseek(fid, pos, 'bof');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% read the main IFD 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info=readMainIFD(fid,info)

IFDOffset = fread(fid, 1, 'uint32');

if IFDOffset==0
    error('Unknow .NEF format: main IFD offset=0');
    return;
end

info=readIFD(fid,IFDOffset,info);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% read the Exif tag information 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function info=readExifIFD(fid,info)

if ~isfield(info,'ExifOffset')
    error('Unknown .NEF format: ExifOffset doesn''t exist');
end

info=readIFD(fid,info.ExifOffset,info);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% read MakerNote of Nikon digital camera file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function info=readNikonIFD(fid,info)

if ~isfield(info,'MakerNote')
    error('Unknown .NEF format: MakerNote doesn''t exist');
end

info=readIFD(fid,info.MakerNote,info);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%   find the Raw CCD RGB data 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RGB=readRGB(fid,info)

if ~isfield(info,'SubIFDs')
    error('Unknown .NEF format: SubIFDs doesn''t exist');
end

info=readIFD(fid,info.SubIFDs,info);

if ~isfield(info,'StripOffsets')
    error('Unknown .NEF format: StripOffsets doesn''t exist');
end

fseek(fid,info.StripOffsets(1),'bof'); 
tic; RawCCD=uint16(fread(fid,info.ImageWidth*info.ImageHeight,'ubit12')); toc
tic; RawCCD=reshape(RawCCD,info.ImageWidth,info.ImageHeight)'; toc
tic; RGB=uint16(zeros(info.ImageHeight/2,info.ImageWidth/2,4)); toc
tic; RGB(:,:,1)=RawCCD(2:2:end,2:2:end);
RGB(:,:,2)=RawCCD(2:2:end,1:2:end);
RGB(:,:,3)=RawCCD(1:2:end,1:2:end);
RGB(:,:,4)=RawCCD(1:2:end,2:2:end);
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% read any IFD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info=readIFD(fid,IFDOffset,info)

fseek(fid,IFDOffset,'bof');
tagCount= fread(fid,1,'uint16');
tagPos = ftell(fid);

%%% Each tag occupies 12 bytes 

for p = 1:tagCount
   fseek(fid, tagPos, 'bof');
   [tagName,tagValue] = readTag(fid);
   eval(['info.' tagName '=tagValue;']);   
   tagPos = tagPos+12; 
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% read one tag which is 12-byte field with:
%%%     Bytes 0-1  Tag ID
%%%     Bytes 2-3  Tag Type
%%%     Bytes 4-7  Tag Count
%%%     Bytes 8-11 Tag Value or Offset
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ tagName, tagValue ] = readTag ( fid )

tagID = fread(fid,1,'uint16');
%%% Tag types are from 1 to 12, which are: 1--unsigned byte; 2--string; 3--unsigned short; 4--unsigned long; 5--unsigned rational; 
%%%      6--signed; 7--undefined; 8--signed short; 9--signed long; 10--signed rational; 11--float; 12--double;
tagType = fread(fid,1,'uint16'); 
tagCount= fread(fid,1,'uint32');
tagName = nefLookupTagName(tagID);
%[tagName ' ' num2str(tagID) ' ' num2str(tagType) ' ' num2str(tagCount)]

if  tagType > 12 | tagType <1
  error(['Unkown Tag Type: ',num2str(tagType)]); 
end

%%% matlab equivalent data type of each Tag type
format={'uchar','char','uint16','uint32','uint32','char','char','int16','int32','int32','float32','double'};
typeSize=[2 1 1 4 8 1 1 2 4 8 4 8];

%%% decide whether the next 4 bytes are value or offset of value

if tagID==hex2dec('927C')  %% MakerNote in NEF contains Nikon specific information like white balance and so on
    tagValue=fread(fid,1,'uint32');
    return;
end

if typeSize(tagType) * tagCount <= 4  %% read data directly
    tagValue= fread(fid,tagCount,format{tagType});
else
    offset= fread(fid,1,'uint32');
    fseek(fid,offset,'bof');
    
    if (tagType == 5) | (tagType==10)  %% unsigned rational or signed rational  
        tmpValue=fread(fid,2*tagCount,format{tagType});
        %tagValue=tmpValue; 
        for i=1:tagCount
            tagValue(i)=tmpValue(i*2-1)/tmpValue(i*2);
        end
    else
        tagValue=fread(fid,tagCount,format{tagType});
    end
end

if tagType==2 %% string 
  tagValue=char(tagValue);
end

tagValue=tagValue';

