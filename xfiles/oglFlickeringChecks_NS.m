function oglStim = oglFlickeringChecks_NS(pars, myscreen, flagNoTextures)
% Flickering checkerboards set at a particular width and center. check size
% defined and tf defined.
%
% oglStim =  oglFlickeringChecks(pars,myscreen)
% where pars is
% [  dur tf contrast checksize width ctr sqwv]
%
% oglStim = oglFlickeringChecks(pars,myscreen,flagNoTextures) lets you specify
% whether you don't want textures (DEFAULT: flagNoTextures = false).
%
% Mush, 3/2014: This is exatly the same as oglFlickeringChecks, except that
% line 42 was switched from ">" to ">=". This was done becasued after
% upgrading to Win7 and newer version of matlab oglFlickeringChecks stopped working.
%% parse the parameters

if nargin < 3
    flagNoTextures = false;
end

dur       = pars(1)/10;  % s,   duration
tf        = pars(2)/10;  % hz,  temporal frequency
cont      = pars(3)/100; % (%), contrast (percent)
checkSize = pars(4)/10;  % size of checks in deg
width     = pars(5)/10;  % width of checkerboard in deg
ctr       = pars(6)/10;  % center of checkerboard in deg
sqwv      = pars(7);     % temporal wave flag (1=square wave; 0=sin wave)
tstart       = pars(8)/10;  % s,   start of checks
tend       = pars(9)/10;  % s,   end of checks

% checksize, width, ctr in px
checkSizePx = round(ltdeg2pix(checkSize, myscreen));
widthPx     = round(ltdeg2pix(width    , myscreen));
ctrPx       = round(ltdeg2pix(ctr      , myscreen));

% duration in frames
nframes = round(myscreen.FrameRate * dur);
nFramesInPeriod = round(myscreen.FrameRate / tf);
nframes = nFramesInPeriod * round(nframes / nFramesInPeriod);

% compute temporal frequency stuff
tphasedeg = 0; % force temporal phase to be in sin phase
tphase = tphasedeg*pi/180;
TemporalPhase = 2*pi*(0:(nFramesInPeriod-1))/nFramesInPeriod + tphase;
ZeroCross = find(tphase>=TemporalPhase,1,'last');
ContrastTracePeriod = circshift(sin(TemporalPhase)',ZeroCross)';
ContrastTrace = repmat(ContrastTracePeriod,1,nframes/nFramesInPeriod);

%% Fundamental fields

oglStim = oglStimNew(); % preallocate so you have correct order of parameters

oglStim.Generation = 3; % 3rd gen (1 = pre-OpenGL, 2 = partial OpenGL, 3 = fuller OpenGL)
oglStim.Type = 'oglFlickeringChecks_NS';
oglStim.Pars = pars;
oglStim.FlagMinusOneToOne = true;
oglStim.TextureParameters = setdiff((1:length(pars)),[3]);

%% Define fields ori and position and globalAlpha (blending with contrast)

% the orientation vector
oglStim.ori = zeros(1,nframes);

% The position vector
xbeg = ctrPx + myscreen.Xmax/2 - widthPx/2;
xend = ctrPx + myscreen.Xmax/2 + widthPx/2;
ybeg = 0   + myscreen.Ymax/2 - myscreen.Ymax/2;
yend = 0   + myscreen.Ymax/2 + myscreen.Ymax/2;
position = [xbeg ybeg xend yend]; % in pixels
oglStim.position = repmat(position,nframes,1);
oglStim.position = repmat(position,2,1);

% the globalAlpha vector
if sqwv % square wave
    oglStim.globalAlpha = cont * ones(1,nframes) / 2;
else % sine wave
    oglStim.globalAlpha = cont * abs(ContrastTrace) / 2;
end
% notice division by two otherwise it does not work...



if flagNoTextures
    return
end

%% Define Frames and FrameSequence for each component grating

% how many checks
nChecksX = round(widthPx       / checkSizePx);
nChecksY = round(myscreen.Ymax / checkSizePx);

% make checkerboard
stimImg = double(checkerboard(checkSizePx, ceil(nChecksY/2), ceil(nChecksX/2)) > 0.5);
stimImg = stimImg*2-1;

% compute temporal frequency stuff
ActualFrequency = myscreen.FrameRate/nFramesInPeriod;
if abs(ActualFrequency/tf-1)>0.1
    fprintf(1,'Frequency %d is %2.2f rather than %2.0f Hz\n', ...
        igrat, ActualFrequency, tf);
end
    
% Make movies
Frames          = cell(1,1);
FrameSequence   = cell(1,1);
% just make 2 frames, one for each sign of the checkerboard. 
Frames{1} = cell(2,1);
Frames{1}{1} =  1 .* stimImg;
Frames{1}{2} = -1 .* stimImg;
Frames{1}{3} = 0.*stimImg; % empty, for use in keeping it turned off
% the frame sequence
FrameSequencePeriod = circshift([ones(1,floor(nFramesInPeriod/2)) 2*ones(1,ceil(nFramesInPeriod/2))]',ZeroCross)';
FrameSequence{1} = repmat(FrameSequencePeriod,1,nframes/nFramesInPeriod);

if tstart>0
    numStartFrames = round(tstart*myscreen.FrameRate);
    FrameSequence{1}(1:numStartFrames) = 3;
end

if tend<dur
    numEndFrames = round((dur-tend)*myscreen.FrameRate);
    FrameSequence{1}(end-numEndFrames:end) = 3;
end

%% merge the stimuli

% probably obsolete
oglStim.nperiods             = 1; 

% plobably important 
oglStim.srcRect = cell(1*nframes,1);
% oglStim.srcRect = [];
% is this unused? what is it???

oglStim.frames   = {Frames{1}(:)};

% probably obsolete
oglStim.luts     =  {repmat([128 255 0 1:253]',1,3)}';

% important
oglStim.sequence.frames = FrameSequence{1};
oglStim.sequence.frames = oglStim.sequence.frames(:);

% probably obsolete
oglStim.sequence.luts   = ones(1,nframes);
oglStim.sequence.luts   = oglStim.sequence.luts(:);

% probably important
oglStim.positionIndex = ones(1,nframes)';

fprintf(1,'\n');

return

%% To test it in StimBox

myscreen = ltScreenInitialize(2);
myscreen.Dist = 28.5;
ltLoadCalibration(myscreen);

%      [ dur tf  cont  checkSize width  ctr sqwv ]
pars = [  70 10   100        100   600 -400    1  30  40];
% pars = [  40 10    30        125   750 -400    1 ];

Stim = oglStimMake('oglFlickeringChecks_NS',pars, myscreen);
oglStimPlay(myscreen,Stim);

% new pars are old pars
newpars = pars;
Stim = oglStimUpdateDisplayParameters(Stim,newpars,myscreen);
oglStimPlay(myscreen,Stim);

% double contrast otherwise new pars are old pars
newpars = pars; newpars(3) = min(pars(3)*2,100);
Stim = oglStimUpdateDisplayParameters(Stim,newpars,myscreen);
oglStimPlay(myscreen,Stim);

% change pars
%         [ dur tf  cont  checkSize width  ctr sqwv ]
newpars = [  20 20   100        125   600  400    1 ];
Stim = oglStimUpdateDisplayParameters(Stim,newpars,myscreen);
oglStimPlay(myscreen,Stim);

ltClearStimulus(Stim,'nowarnings'); 

Screen('CloseAll');
