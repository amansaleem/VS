function oglStim = oglFlickeringChecksTimed(pars, myscreen, flagNoTextures)
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
% History:
% flickeringChecks.x (old fashioned stimulus that fills screen)
% 10-2013 MK made the timed version of oglFlickeringChecks with gray screen
% before and after (e.g. to allow specific timing with optical stimulation)

%% checking the input arguments


if nargin < 3
    flagNoTextures = false;
end

%% The parameters and their definition

pp = cell(1,1);
pp{1}  = {'dur',         'Overall duration (s*10)',             50,1,600};
pp{2}  = {'tf',          'Flicker temporal frequency (Hz*10)',  20,1,160};
pp{3}  = {'cont',        'Contrast (%)',                        100,0,100};
pp{4}  = {'checkSize',   'Single square size (deg*10)',         145,5,900};
pp{5}  = {'width',       'Stimulus width (deg*10)',             580,5,1800};
pp{6}  = {'ctr',         'Stimulus centre (deg*10)',            0,-900,900};
pp{7}  = {'sqwv',        'Sine (0) or Square (1)',              1, 0, 1};
pp{8}  = {'tstart',      'Stim start time (s*10)',              10,0,600};
pp{9}  = {'tend',        'Stim end time (s*10)',                30,0,600};

x = XFile('oglFlickeringChecksTimed',pp);
% x.Write; % call this ONCE: it writes the .x file

%% parse the parameters

if ~exist('pars', 'var') || isempty(pars)
    pars = x.ParDefaults;
end

dur       = pars(1)/10;  % s,   duration
tf        = pars(2)/10;  % hz,  temporal frequency
cont      = pars(3)/100; % (%), contrast (percent)
checkSize = pars(4)/10;  % size of checks in deg
width     = pars(5)/10;  % width of checkerboard in deg
ctr       = pars(6)/10;  % center of checkerboard in deg
sqwv      = pars(7);     % temporal wave flag (1=square wave; 0=sin wave)
tstart    = pars(8)/10;  % s, start time of the checks stimulus
tend      = pars(9)/10;  % s, end time of the checks stimulus
% checksize, width, ctr in px
checkSizePx = round(ltdeg2pix(checkSize, myscreen));
widthPx     = round(ltdeg2pix(width    , myscreen));
ctrPx       = round(ltdeg2pix(ctr      , myscreen));

% duration in frames
nframes = round(myscreen.FrameRate * dur);
if ~mod(nframes, 2)
    % we want an odd number of frames if the SyncSquare is Flickering.
    nframes=nframes+1;
end
% debug only
% fprintf('FlickCheckTimed: %d frames initially\n', nframes);

stimDur=tend-tstart;
firstStimFrame=floor(tstart*myscreen.FrameRate)+1;

nFramesStim = round(myscreen.FrameRate * stimDur);
nFramesInPeriod = round(myscreen.FrameRate / tf);
nFramesStim = nFramesInPeriod * round(nFramesStim / nFramesInPeriod);

% compute temporal frequency stuff
tphasedeg = 0; % force temporal phase to be in sin phase
tphase = tphasedeg*pi/180;
TemporalPhase = 2*pi*(0:(nFramesInPeriod-1))/nFramesInPeriod + tphase;
ZeroCross = find(tphase>TemporalPhase,1,'last');
ContrastTracePeriod = circshift(sin(TemporalPhase)',ZeroCross)';
ContrastTraceStim = repmat(ContrastTracePeriod,1,nFramesStim/nFramesInPeriod);

% now inserting the actual stimulus inbetween gray periods (using zero contrast)
ContrastTrace=zeros(1, nframes);
stimIdx=firstStimFrame:firstStimFrame+nFramesStim-1; % position of the actual stimulus in the overall sequence
ContrastTrace(stimIdx)=ContrastTraceStim;

%% Fundamental fields

oglStim = oglStimNew(); % preallocate so you have correct order of parameters

oglStim.Generation = 3; % 3rd gen (1 = pre-OpenGL, 2 = partial OpenGL, 3 = fuller OpenGL)
oglStim.Type = 'oglFlickeringChecksTimed';
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
% just make 3 frames, one for each sign of the checkerboard + one blank 
Frames{1} = cell(3,1);
Frames{1}{1} =  1 .* stimImg;
Frames{1}{2} = -1 .* stimImg;
Frames{1}{3} =  0 .* stimImg;
% the frame sequence
FrameSequencePeriod = circshift([ones(1,floor(nFramesInPeriod/2)) 2*ones(1,ceil(nFramesInPeriod/2))]',ZeroCross)';
FrameSequenceStim = repmat(FrameSequencePeriod,1,nFramesStim/nFramesInPeriod);
FrameSequence{1} = 3*ones(1, nframes);
FrameSequence{1}(stimIdx)=FrameSequenceStim;

% debug only
% fprintf('FlickCheckTimed: %d frames at the end\n', length(FrameSequence{1}));


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
pars = [  40 10   100        100   600 -400    1 ];
pars = [  40 10    30        125   750 -400    1 ];

Stim = oglStimMake('oglFlickeringChecksTimed',pars, myscreen);
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
