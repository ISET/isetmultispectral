function [camRGB, vcInfo] = nefCombineFiles(fnames,sampleRate,scaleIntensityFlag,imgDir)
% Combine Nikon data (NEF files) from several images into one variable
% (camRGB)
%
%  [camRGB, vcInfo] = nefCombineFiles([fnames],[sampleRate], ...
%                        [scaleIntensityFlag],[imgDir])
%
% The returned camRGB data are in RGB format.  All of the data from all
% of the files are combined into the camRGB variable.  Its dimensions are
% [row,col,3,length(fnames)].
%
% Also, a structure vcInfo is returned.  This structure contains the
% NEF file names and the spatial sampling rate information.
%
% If fnames is empty, the user select the files from a GUI.
%
% scaleIntensityFlag:   Adjust the data for the exposure duration and
% fnumber.  Often this operation is done in another routine
% (mcCombineExposures), though.  So, the default here is 0 (don't adjust).
%
% Algorithm: The original image array in a NEF file (mosaicked) is
% [2024,3034]. These data are converted to a 3D data set that is
% [1012,1517], with RGB.  The two G values are averaged.
%
% The default sampleRate (2), produces an 506x759 image size. 
%
% Various sampleRates produce spatial images of
%    sampleRate = 1: 1012x1517
%    sampleRate = 2:  506x759
%    sampleRate = 3:  338x506
%    sampleRate = 4:  253x380
%
% Example:
%  scaleIntensityFlag = 0;
%  sampleRate = 4; 
%  imgDir ='C:\u\brian\Matlab\PDC\Applications\MultiCapture\MacbethTungstenLab'
%  rgb = nefCombineFiles([],sampleRate,scaleIntensityFlag,imgDir);
% 
% FX/BW Copyright scienlab 2004

%% Get the names of several NEF files
if ieNotDefined('imgDir'),             imgDir = pwd; end
if ieNotDefined('fnames'),             fnames = ieReadMultipleFileNames(imgDir);  end
if ieNotDefined('sampleRate'),         sampleRate = 1;  end
if ieNotDefined('scaleIntensityFlag'), scaleIntensityFlag = 1; end

vcInfo.fnames = fnames;
vcInfo.sampleRate = sampleRate;
vcInfo.scaleIntensityFlag = scaleIntensityFlag;
nFiles = length(fnames);

%%
waitFigure = waitbar(0, sprintf('Combining %.0f NEF files (%s)',nFiles));  

for ii=1:length(fnames)
    info = nefInfo(fnames{ii});
    vcInfo.info{ii} = info;
    
    [p,n] =  fileparts(fnames{ii});
    updatedTitle = sprintf('Combining %.0f NEF files (%s)',nFiles,strrep(n,'_','-'));
    waitbar(ii/nFiles,waitFigure,updatedTitle);
    
    % The return is an RGBG image
    [raw, mosaicType] = nefRead(fnames{ii},sampleRate,0);
    % vcNewGraphWin; imagescRGB(double(raw(:,:,1:3)).^(1/2.2));

    % Average the two green pixels
    raw(:,:,2) = ...
        uint16(  (double(raw(:,:,2)) + double(raw(:,:,4))) / 2 );
    
    % We assume that there are three color filters.  If there are not, the
    % code breaks here.  The general code would be
    % firstCol = (ii-1)*nFilters + 1; lastCol = firstCol + (nFilters-1);
    
    if scaleIntensityFlag  
        % Correct for exposure duration and fnumber.  Returned values are
        % approximately linear with intensity.
        ratio = info.ExposureTime/info.FNumber^2;
        camRGB(:,:,:,ii) = double(raw(:,:,1:3))/ratio;
        % firstCol = (ii-1)*3 + 1;  lastCol = firstCol + 2; camRGB(:,:,firstCol:lastCol) = double(raw(:,:,1:3))/ratio;
    else
        % Don't correct for exposure or f-number, this work will be done elsewhere, say in
        % mexCreateHDRI
        camRGB(:,:,:,ii) = double(raw(:,:,1:3));
    end

end

close(waitFigure);

end

