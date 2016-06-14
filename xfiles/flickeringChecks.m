function Stim = flickeringChecks(pars, myscreen)
% pars = [checkSize, flickerfreq, contrast, duration]

texture.checkSize = pars(1)/100;
texture.flickerFreq = pars(2)/10;
texture.contrast = pars(3)/100; % convert to %
texture.dur = pars(4)/10;


% duration in frames
nframes = round(myscreen.FrameRate * texture.dur);

% size of check in px
checkSizePx = round(ltdeg2pix(texture.checkSize, myscreen));

% how many checks
nChecksX = ceil(myscreen.Xmax / checkSizePx);
nChecksY = nChecksX;

stimImg = int16(checkerboard(checkSizePx, nChecksX, nChecksY) > 0.5);
% stimImg = checkerboard(checkSizePx, nChecksX, nChecksY) > 0.5;
stimImg(stimImg==0) = -1;
stimImg = stimImg * texture.contrast;
% 
spatialstim{1} = stimImg;

Stim.frames{1}{1} = uint8( spatialstim{1}*126 + 129 );
Stim.frames{1}{2} = uint8( spatialstim{1}*-1*126 + 129 );

% Make the lookup table
Stim.luts{1} = repmat([128 255 0 1:253]',1,3);

% Make sequence
Stim.sequence.frames = ones(1,nframes);
if texture.flickerFreq > 0
    nFramesPerHalfCycle = round((myscreen.FrameRate * 1/texture.flickerFreq)/2); % number of frames per flicker cycle
    if fix(nframes/(nFramesPerHalfCycle*2)) > 0
        Stim.sequence.frames = [ones(1, nFramesPerHalfCycle) ones(1,nFramesPerHalfCycle)+1]; % alternate between frame 1 and 2
        Stim.sequence.frames = repmat(Stim.sequence.frames, 1, fix(nframes/(nFramesPerHalfCycle*2)));
        if mod(nframes,nFramesPerHalfCycle*2) > 0 % append first few frames if there are any left
            Stim.sequence.frames = [Stim.sequence.frames Stim.sequence.frames(1:mod(nframes,nFramesPerHalfCycle*2))];
        end
    end    
end
Stim.sequence.luts = ones(1,nframes);

%Stim.ori = 0;
%Stim.srcRect = [];

% Definition of the drawn rectangle on the screen:
dstRect=[0 0 size(stimImg)];
dstRect=CenterRect(dstRect, myscreen.ScreenRect);

% The position vector
Stim.position(1,:) = dstRect;
Stim.nperiods = 1;
% 

return

%% To test it in VisBox

myscreen = ltScreenInitialize(2);
myscreen.Dist = 30;

checkSize = 25/2*100;
flickerFreq = 5;
contrast = 100;
duration = 60;

Stim = flickeringChecks([checkSize, flickerFreq, contrast, duration], myscreen);

Stim = vsLoadTextures(myscreen, Stim);
vsPlayStimulus(myscreen,Stim);	
	
ltClearStimulus(Stim,'nowarnings'); 

Screen('CloseAll');

%% To test it in StimBox

myscreen = ltScreenInitialize(2);
myscreen.Dist = 30;
ltLoadCalibration(myscreen);

checkSize = 25/2*100;
flickerFreq = 5;
contrast = 100;
duration = 60;

pars = [checkSize, flickerFreq, contrast, duration];

Stim = oglStimMake('flickeringChecks',pars, myscreen);
oglStimPlay(myscreen,Stim);

ltClearStimulus(Stim,'nowarnings'); 

Screen('CloseAll');
