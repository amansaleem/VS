function Stim = flickeringChecks_stepresp(pars, myscreen)
% pars = [checkSize, contrast, duration]

texture.checkSize = pars(1)/100;
texture.contrast = pars(2)/100; % convert to %
texture.dur = pars(3)/10;


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

Stim.frames{1}{1} = uint8( spatialstim{1}*1*texture.contrast*126 + 129 );
Stim.frames{1}{2} = uint8( spatialstim{1}*0*texture.contrast*126 + 129 );
Stim.frames{1}{3} = uint8( spatialstim{1}*-1*texture.contrast*126 + 129 );
Stim.frames{1}{4} = uint8( spatialstim{1}*0*texture.contrast*126 + 129 );

% Make the lookup table
Stim.luts{1} = repmat([128 255 0 1:253]',1,3);

% Make sequence
Stim.sequence.frames = ones(1,nframes);
if texture.dur > 0
    nFramesPerQuartCycle = round((myscreen.FrameRate * texture.dur)/4); % number of frames per flicker cycle
    if fix(nframes/(nFramesPerQuartCycle*4)) > 0
        Stim.sequence.frames = [ones(1, nFramesPerQuartCycle) ones(1,nFramesPerQuartCycle)+1 ones(1,nFramesPerQuartCycle)+2 ones(1,nFramesPerQuartCycle)+3]; % alternate between frame 1 and 2 but put blanks in between
        Stim.sequence.frames = repmat(Stim.sequence.frames, 1, fix(nframes/(nFramesPerQuartCycle*4)));
        if mod(nframes,nFramesPerQuartCycle*4) > 0 % append first few frames if there are any left
            Stim.sequence.frames = [Stim.sequence.frames Stim.sequence.frames(1:mod(nframes,nFramesPerQuartCycle*4))];
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

%% To test using VisBox

myscreen = ltScreenInitialize(2);
myscreen.Dist = 30;

checkSize = 25/2*100;
flickerFreq = 5;
contrast = 50;
duration = 80;

Stim = flickeringChecks_stepresp([checkSize, contrast, duration], myscreen);

Stim = vsLoadTextures(myscreen, Stim);
vsPlayStimulus(myscreen,Stim);	
	
ltClearStimulus(Stim,'nowarnings'); 

Screen('CloseAll');

%% To test using StimBox

myscreen = ltScreenInitialize(2);
myscreen.Dist = 30;

checkSize = 25/2*100;
flickerFreq = 5;
contrast = 50;
duration = 80;

pars = [checkSize, contrast, duration];

Stim = oglStimMake('oglTwoGratings',pars, myscreen);
oglStimPlay(myscreen,Stim);

ltClearStimulus(Stim,'nowarnings'); 

Screen('CloseAll');

