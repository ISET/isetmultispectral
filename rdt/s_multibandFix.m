%% Fix the four files JEF identified in the multiband directory.
%
%  2004/Fruit_visible - banana reflectance is too high
%  2009/FruitPlatter - banana reflectance is too low
%  2009/EscherCalib-1 - red dog is too high - compare to red dog in the MacbethTungstenLab
%  2008/CaucasianFemale-1 reflectance is too high
% 
% JEF/BW


%% 
rd = RdtClient('isetbio');

% Needed for when we place the corrected data back
rd.credentialsDialog;

% This is where the data are
rd.crp('/resources/scenes/multiband/scien');

cd(fullfile(isetRootPath,'local','fix'));

%% 2004/Fruit_visible banana reflectance is too high

rd.crp('/resources/scenes/multiband/scien/2004');
sList = rd.listArtifacts;
for ii=1:length(sList)
    fprintf('%d: %s\n',ii,sList(ii).artifactId);
end

% Fruit_visible is 4
data = rd.readArtifact(sList(4).artifactId);
scene = sceneFromBasis(data);
ieAddObject(scene); sceneWindow;

% We plotted the banana, and the reflectance was too high.
% So we increased the illuminant
ill = sceneGet(scene,'illuminant photons');
scene2 = sceneSet(scene,'illuminant photons',1.15*ill);
ieAddObject(scene2); sceneWindow;

% Now, write out scene2 as
nBases = size(data.mcCOEF,3);
mType = 'canonical';
fullFile = fullfile(pwd,[sList(4).artifactId,'.mat']);
vExplained = sceneToFile(fullFile,scene,nBases,mType);
fprintf('Variance explained %0.3f\n',vExplained);

% I suggest deleting the file on the web-page and then uploading this
rd.publishArtifact(fullFile);


%%  2008/CaucasianFemale reflectance is too high

rd.crp('/resources/scenes/multiband/scien/2008');
sList = rd.listArtifacts;
for ii=1:length(sList)
    fprintf('%d: %s\n',ii,sList(ii).artifactId);
end

% Caucasion Female is 6
data = rd.readArtifact(sList(6).artifactId);
scene = sceneFromBasis(data);
ieAddObject(scene); sceneWindow;

% We the skin reflectance; a bit high.  So, we 
% So we increased the illuminant
ill = sceneGet(scene,'illuminant photons');
scene2 = sceneSet(scene,'illuminant photons',1.5*ill);
ieAddObject(scene2); sceneWindow;

% Now, write out scene2 as
nBases = size(data.mcCOEF,3);
mType = 'canonical';
fullFile = fullfile(pwd,[sList(6).artifactId,'.mat']);
vExplained = sceneToFile(fullFile,scene,nBases,mType);
fprintf('Variance explained %0.3f\n',vExplained);

% I suggest deleting the file on the web-page and then uploading this
rd.publishArtifact(fullFile);

%%  2009/FruitPlatter - banana reflectance is too low

rd.crp('/resources/scenes/multiband/scien/2009');
sList = rd.listArtifacts;
for ii=1:length(sList)
    fprintf('%d: %s\n',ii,sList(ii).artifactId);
end

% Use number 3
data = rd.readArtifact(sList(3).artifactId);
scene = sceneFromBasis(data);
ieAddObject(scene); sceneWindow;

% We the skin reflectance; a bit high.  So, we 
% So we increased the illuminant
ill = sceneGet(scene,'illuminant photons');
scene2 = sceneSet(scene,'illuminant photons',.5*ill);
ieAddObject(scene2); sceneWindow;

% Now, write out scene2 as
nBases = size(data.mcCOEF,3);
mType = 'canonical';
fullFile = fullfile(pwd,[sList(3).artifactId,'.mat']);
vExplained = sceneToFile(fullFile,scene,nBases,mType);
fprintf('Variance explained %0.3f\n',vExplained);

% I suggest deleting the file on the web-page and then uploading this
rd.publishArtifact(fullFile);


%%  2009/EscherCalib-1 - red dog is too high - compare to red dog in the MacbethTungstenLab

% Use number 2
data = rd.readArtifact(sList(2).artifactId);
scene = sceneFromBasis(data);
ieAddObject(scene); sceneWindow;

% We decided not to fix it because the white target is about right.  The
% dog reflectance is too high because the illumination is higher on that
% part of the scene.


