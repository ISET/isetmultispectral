function val = nkStartNControl
% Start the Nikon Control software or confirm that it is already running
%
% val:  1 if it was already running, 
%       2 if we start it, 
%      -1 if there is a problem
%
% Example:
%    val = nkStartNControl
%

val = -1;

% [prc,str] = dos('tasklist /FI "IMAGENAME eq NControl.exe" /NH /FO CSV');
[prc,str] = dos('tasklist /FI "IMAGENAME eq NControlPro.exe" /NH');%% xxx Changed from NControl.exe
if prc ~= 0, error('DOS command tasklist did not execute properly'); end

if strncmp(str(2:13),'NControlPro.exe',12)  %% xxx Changed from NControl.exe
    disp('NControl is running')
    val = 1;
else
    try
        prc = dos('C:\Program Files\Nikon\Camera Control Pro\NControlPro.exe &')
        %prc = dos('C:\Program Files\Nikon\NCapture4\Control\NControl.exe &');
        if prc ~= 0, error('Failure to start NControlPro.exe.  Check path'); end
        val = 2; %% xxx Changed from NControl.exe
    catch
        val = -1;
    end
end

return;
