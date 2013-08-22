function tagName=lookupTagName(tagID)
%
%   tagName=lookupTagName(tagID)
%
%  Author:  From FX ... ask him about this
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% lookup tag name from tag ID

TagTable={ 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%Tags used by IFD0 (main image)%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    'fe','NewSubfileType';  
    '100','ImageWidth';
    '101','ImageHeight';
    '102','BitsPerSample';
    '103','Compression'; %%  unsigned short 1  Shows compression method. '1' means no compression, '6' means JPEG compression. 
    '106','PhotometricInterpretation'; %%  unsigned short 1  Shows the color space of the image data components. '1' means monochrome, '2' means RGB, '6' means YCbCr. 
    '10e','ImageDescription';
    '10f','Make';
    '110','Model';
    '111','StripOffsets';
    '112','Orientation';
    '115','SamplesPerPixel';
    '116','RowsPerStrip'; 
    '117','StripByteConunts';
    '11a','XResolution';
    '11b','YResolution';
    '11c','PlanarConfiguration'; 
    '128','ResolutionUnit';
    '131','Software';
    '132','DateTime';
    '13e','WhitePoint'; %  unsigned rational 2  Defines chromaticity of white point of the image. If the image uses CIE Standard Illumination D65(known as international standard of 'daylight'), the values are '3127/10000,3290/10000'. 
    '13f','PrimaryChromaticities'; %  unsigned rational 6  Defines chromaticity of the primaries of the image. If the image uses CCIR Recommendation 709 primaries, values are '640/1000,330/1000,300/1000,600/1000,150/1000,0/1000'. 
    '211','YCbCrCoefficients'; %  unsigned rational 3  When image format is YCbCr, this value shows a constant to translate it to RGB format. In usual, values are '0.299/0.587/0.114'. 
    '213','YCbCrPositioning'; %  unsigned short 1  When image format is YCbCr and uses 'Subsampling'(cropping of chroma data, all the digicam do that), defines the chroma sample point of subsampling pixel array. '1' means the center of pixel array, '2' means the datum point. 
    '214','ReferenceBlackWhite';%  unsigned rational 6  Shows reference value of black point/white point. In case of YCbCr format, first 2 show black/white of Y, next 2 are Cb, last 2 are Cr. In case of RGB format, first 2 show black/white of R, next 2 are G, last 2 are B. 
    '8298','Copyright';
    '8769','ExifOffset'; %  unsigned long 1  Offset to Exif Sub IFD
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%% Tags used by Exif SubIFD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    '829a','ExposureTime';  
    '829d','FNumber'; 
    '8822','ExposureProgram'; %% '1' means manual control, '2' program normal, '3' aperture priority, '4' shutter priority, '5' program creative (slow program), '6' program action(high-speed program), '7' portrait mode, '8' landscape mode. 
    '8827','ISOSpeedRatings';  
    '9000','ExifVersion';
    '9003','DateTimeOriginal';
    '9004','DateTimeDigitized';
    '9101','ComponentsConfiguration';
    '9102','CompressedBitsPerPixel';
    '9201','ShutterSpeedValue';
    '9202','ApertureValue';
    '9203','BrightnessValue'; %% signed rational 1  Brightness of taken subject, unit is APEX. To calculate Exposure(Ev) from BrigtnessValue(Bv), you must add SensitivityValue(Sv). Ev=Bv+Sv   Sv=log2(ISOSpeedRating/3.125)
    '9204','ExposureBiasValue';
    '9205','MaxApertureValue';
    '9206','SubjectDistance';
    '9207','MeteringMode'; %% Exposure metering method. '0' means unknown, '1' average, '2' center weighted average, '3' spot, '4' multi-spot, '5' multi-segment, '6' partial, '255' other. 
    '9208','LightSource'; %% Light source, actually this means white balance setting. '0' means unknown, '1' daylight, '2' fluorescent, '3' tungsten, '10' flash, '17' standard light A, '18' standard light B, '19' standard light C, '20' D55, '21' D65, '22' D75, '255' other. 
    '9209','Flash'; %% '0' means flash did not fire, '1' flash fired, '5' flash fired but strobe return light not detected, '7' flash fired and strobe return light detected. 
    '920a','FocalLength';  
    '9216','TIFF_EPStandardID';     
    '927c','MakerNote'; %% Maker dependent internal data. Some of maker such as Olympus/Nikon/Sanyo etc. uses IFD format for this area. 
    '9286','UserComment'; %% undefined 
    '9290','SubsecTime';
    '9291','SubsecTimeOriginal';
    '9292','SubsecTimeDigitized';
    'a000','FlashPixVersion'; %% undefined 4  Stores FlashPix version. If the image data is based on FlashPix formar Ver.1.0, value is "0100". Since the type is 'undefined', there is no NULL(0x00) for termination.  
    'a001','ColorSpace'; %% Defines Color Space. DCF image must use sRGB color space so value is always '1'. If the picture uses the other color space, value is '65535':Uncalibrated. 
    'a002','ExifImageWidth';  
    'a003','ExifImageHeight';
    'a004','RelatedSoundFile';
    'a005','ExifInteroperabilityOffset'; %%  unsigned long 1  Extension of "ExifR98", detail is unknown. This value is offset to IFD format data. Currently there are 2 directory entries, first one is Tag0x0001, value is "R98", next is Tag0x0002, value is "0100". 
    'a20e','FocalPlaneXResolution';  
    'a20f','FocalPlaneYResolution';
    'a210','FocalPlaneResolutionUnit';
    'a215','ExposureIndex'; %% Same as ISOSpeedRatings(0x8827) but data type is unsigned rational. Only Kodak's digicam uses this tag instead of ISOSpeedRating, I don't know why(historical reason?).  
    'a217','SensingMethod'; %%  Shows type of image sensor unit. '2' means 1 chip color area sensor, most of all digicam use this type. 
    'a300','FileSource'; %% Indicates the image source. Value '0x03' means the image source is digital still camera. 
    'a301','SceneType';  %%Indicates the type of scene. Value '0x01' means that the image was directly photographed. 
    'a302','CFAPattern'; %% Indicates the Color filter array(CFA) geometric pattern.

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%% Misc Tags %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    '012d','TransferFunction'; %%    unsigned short 3  
    '014a','SubIFDs';
    '8773','InterColorProfile';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%% Nikon MakerNote Tags %%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    '1','Unknown'; 
    '2','ISOSetting'; %% 0,100=ISO100, 0,200=ISO200, 0,400=ISO400;
    '3','ColorMode'; %% 1:Color, 2:Monochrome. 
    '4','Quality'; %% At E900, 1:VGA Basic, 2:VGA Normal, 3:VGA Fine, 4:SXGA Basic, 5:SXGA Normal, 6:SXGA Fine 
    '5','WhiteBalance'; %% 0: Auto, 1:Preset, 2:Daylight, 3:Incandescense, 4:Fluorescence, 5:Cloudy, 6:SpeedLight 
    %'5','ImageAdjustment'; %% 0:Normal, 1:Bright+, 2:Bright-, 3:Contrast+, 4:Contrast-. 
    %'6','CCDSensitivity'; %%  0:ISO80, 2:ISO160, 4:ISO320, 5:ISO100 
    '6','ImageSharpening'; %% Auto,High;
    '7','FocusMode'; %% AF-S: single AF, AF-C: continuous AF
    '8','FlashSetting'; %% Normal,Red-Eye etc
    'a','Unknown';
    'f','ISOSelection'; %% "MANUAL":User selected, "AUTO":Automatically selected. 
    '80','ImageAdjustment'; %% "AUTO", "NORMAL", "CONTRAST(+)" etc. 
    '82','Adapter'; %% "OFF", "FISHEYE 2", "WIDE ADAPTER" etc. 
    '85','ManualFocusDistance'; 
    '86','DigitalZoom';
    '88','AFFocusPosition'; %% '0,0,0,0':Center, '0,1,0,0':Top, '0,2,0,0':Bottom, '0,3,0,0':Left, '0,4,0,0':right 
    '10','DataDump';
    
};

for i=1:length(TagTable)
    if tagID==hex2dec(TagTable(i,1))
        tagName=char(TagTable(i,2));
        return;
    end
end

tagName=['ID_' dec2hex(tagID)];
