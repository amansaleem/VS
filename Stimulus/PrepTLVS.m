
function [screenInfo,waveOutSess] = PrepTLVS
% PREPTLVS does the basic preps that tlVs would do so you can test xfiles
% 
% [screenInfo,waveOutSess] = PrepTLVS
%
% Example:
% SetDefaultDirs;
% [screenInfo,waveOutSess] = PrepTLVS;
% stim = ScreenStim.Make(screenInfo, 'vdriftsin100', [10 20 20 50 30 0 0 200]);
% stim.WaveStim.SampleRate = 1000;
% stim.WaveStim.Waves = 1*ones(1000,2);
% stim.show(screenInfo, [], waveOutSess, []);
%
% 2014-09 MC WROTE IT AT HOME BUT NEVER TESTED IT -- MAY BE BUGGY

rigInfo = RigInfoGet; % Get this rig's settings
screenInfo = ScreenInfo(rigInfo);
screenInfo = screenInfo.CalibrationLoad;
daqInfo = rigInfo.WaveInfo; % Prepare the DAQ for outputs

if ~isempty(daqInfo.DAQAdaptor)
    % session for delivering output waveforms, aligned to stimulus onset
    waveOutSess = daq.createSession(daqInfo.DAQAdaptor);
else
    waveOutSess = [];
end
