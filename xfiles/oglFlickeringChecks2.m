function oglStim = oglFlickeringChecks2(pars, myscreen, flagNoTextures)
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
% IC, 30/10/2015: The code is changed so the sequence shown is checker (+ve) - 
% gray - checker (-ve) - so on so forth.

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

%% Fundamental fields

oglStim = oglStimNew(); % preallocate so you have correct order of parameters

oglStim.Generation = 3; % 3rd gen (1 = pre-OpenGL, 2 = partial OpenGL, 3 = fuller OpenGL)
oglStim.Type = 'oglFlickeringChecks';
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

% notice division by two otherwise it does not work...
oglStim.globalAlpha = cont * ones(1,nframes) / 2;

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
% 3 frames, one for each index of FrameSequence. 
Frames{1} = cell(3,1);
Frames{1}{1} =  1 .* stimImg;
Frames{1}{2} = 0 .* stimImg;
Frames{1}{3} =  -1 .* stimImg;
% the frame sequence
a=[]; for i=1:4
 if i==1, a = cat(2,a,ones(1,floor(nFramesInPeriod/2)));       
 elseif i==2, a = cat(2,a,2.*ones(1,ceil(nFramesInPeriod/2)));
 elseif i==3, a = cat(2,a,3*ones(1,floor(nFramesInPeriod/2)));
 else i==4, a = cat(2,a,2.*ones(1,ceil(nFramesInPeriod/2))); 
 end
end
sprintf('ble,%d,%d',nFramesInPeriod,length(a)), 
FrameSequencePeriod = []; FrameSequencePeriod = a;
if mod(nframes, 2*nFramesInPeriod)~=0
 frame_Seq = []; 
 frame_Seq = repmat(FrameSequencePeriod,1,round(nframes/(2*nFramesInPeriod)));
 FrameSequence{1} = frame_Seq(1,1:nframes);
else
 FrameSequence{1} = repmat(FrameSequencePeriod,1,nframes/(2*nFramesInPeriod));
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

