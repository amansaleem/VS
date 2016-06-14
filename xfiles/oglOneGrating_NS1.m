function oglStim = oglOneGrating_NS1(pars,myscreen,flagNoTextures)
% One grating, drifting or flickering, in disks or annuli or rectangles
%
% oglStim =  oglOneGrating_IC1013(pars,myscreen)
% where pars is
% [  dur ...
%    tf1 sf1 tph1 sph1 c1 ori1 dima1 dimb1 x1 y1 flick1 sqwv1 duty1 shape1 ]
%
% sqwv = 1 for square waves, 0 for sin waves
% duty is the duty cycle in percent (normal is 100)
% shape = 0 for annulus, 1 for rectangle
% dima, dimb are inner and outer diameters (for annuli) or dimensions x and y (for rectangles)
%
% oglStim = oglOneGrating_IC1013(pars,myscreen,flagNoTextures) lets you specify
% whether you don't want textures (DEFAULT: flagNoTextures = false).
%
% History:
% vmovie2gratinterok.x (old fashioned interleaved stimulus)
% oglMovie2Grat.x (OpenGL version needing lots of textures)
% oglMovie2GratLin.x (with alpha blending but bug in drifting gratings)
% oglTwoGratings (this file): fixed bug, done away with fake interleaving
%
% MC 2010-02-05 started it (not functional yet)
% IC 2013-10	oglOneGrating_IC1013 - one grating only

%% parse the parameters

if nargin < 3
    flagNoTextures = false;
end

dur 	= pars(1)/10; % s, duration

ipar = 1;
sinpars = [struct; struct];
for igrat = 1
    sinpars(igrat).tfreq	 	= pars(ipar+1)/10;              % Hz
    sinpars(igrat).sfreq  		= pars(ipar+2)/100;             % cpd
    sinpars(igrat).tempphase  	= pars(ipar+3) * (pi/180);      % radians
    sinpars(igrat).spatphase  	= pars(ipar+4) * (pi/180);      % radians
    sinpars(igrat).contrast 	= pars(ipar+5)/100;             % percent
    sinpars(igrat).orientation 	= pars(ipar+6);                 % deg
    sinpars(igrat).dima			= ceil (ltdeg2pix(pars(ipar+7)/10,myscreen)); % deg
    sinpars(igrat).dimb			= floor(ltdeg2pix(pars(ipar+8)/10,myscreen)); % deg
    sinpars(igrat).x	 		= ltdeg2pix(pars(ipar+ 9)/10,myscreen); % deg
    sinpars(igrat).y		 	= ltdeg2pix(pars(ipar+10)/10,myscreen); % deg
    sinpars(igrat).flicker 		= pars(ipar+11);
    sinpars(igrat).sqwv 		= pars(ipar+12);
    sinpars(igrat).duty  		= pars(ipar+13)/100;
    sinpars(igrat).shape  		= pars(ipar+14); % 0 = circle; 1 = rect
    ipar = 15;
end

nframes = round(myscreen.FrameRate * dur);

%% Fundamental fields

oglStim = oglStimNew(); % preallocate so you have correct order of parameters

oglStim.Generation = 3; % 3rd gen (1 = pre-OpenGL, 2 = partial OpenGL, 3 = fuller OpenGL)
oglStim.Type = 'oglOneGrating_NS1';
oglStim.Pars = pars;
oglStim.FlagMinusOneToOne = true;
oglStim.TextureParameters = setdiff((1:length(pars)),[6 7 10 11 20 21 24 25]); %% IC ???

%% Define fields ori, globalAlpha, and position

oglStim.ori = [sinpars(:).orientation]'*ones(1,nframes);
oglStim.globalAlpha = [sinpars(:).contrast]'*ones(1,nframes) /2;
% notice division by two otherwise it does not work...

oglStim.position = zeros(2,4);

for igrat = 1
    switch sinpars(igrat).shape
        case 0
            % it is an annulus
            maxrad = max(1, sinpars(igrat).dimb/2);
            nx = ceil(2*maxrad);
            ny = ceil(2*maxrad);
        case 1
            % it is a rectangle
            nx = max(1,sinpars(igrat).dima);
            ny = max(1,sinpars(igrat).dimb);
    end
    
    % The position vector
    x = round(sinpars(igrat).x + myscreen.Xmax/2 - nx/2);
    y = round(sinpars(igrat).y + myscreen.Ymax/2 - ny/2);
    oglStim.position(igrat,:) = [x y x+nx y+ny];
end

if flagNoTextures
    return
end

%% Define Frames and FrameSequence for each component grating

Frames          = cell(2,1);
FrameSequence   = cell(2,1);
tic
for igrat = 1
    
    t = 0.001; % threshold
    if sinpars(igrat).duty<1
        beta = log(t)/log(cos( sinpars(igrat).duty*pi/2 ));
    else
        beta = 1;
    end
    
    % Spatial frequency in cycles/pixel
    PixPerCycle = ltdeg2pix(1/sinpars(igrat).sfreq,myscreen);
    sinpars(igrat).frequency = 1/PixPerCycle; % sf in cycles/pix
    
    nx = diff(oglStim.position(igrat,[1 3]));
    ny = diff(oglStim.position(igrat,[2 4]));
    
    % Make a grid of x and y
    [xx,yy] = meshgrid(1-nx/2:nx/2,1-ny/2:ny/2);
    
    % Image of the spatial phase of the stimulus (in radians)
    AngFreqs = -2*pi* sinpars(igrat).frequency * xx + sinpars(igrat).spatphase;
    
    switch sinpars(igrat).shape
        case 0
            % an annulus
            dd = sqrt(xx.^2+yy.^2);
            WindowImage = double(dd >= sinpars(igrat).dima/2 & dd <= sinpars(igrat).dimb/2);
        case 1
            % a rectangle
            WindowImage = double(ones(size(xx)));
    end
    
    % The temporal phase of the response
    
    nFramesInPeriod = round(myscreen.FrameRate / sinpars(igrat).tfreq);
    TemporalPhase = 2*pi*(0:(nFramesInPeriod-1))/nFramesInPeriod + sinpars(igrat).tempphase;
    
    ActualFrequency = myscreen.FrameRate/nFramesInPeriod;
    if abs(ActualFrequency/sinpars(igrat).tfreq-1)>0.1
        fprintf(1,'Frequency %d is %2.2f rather than %2.0f Hz\n', ...
            igrat, ActualFrequency, sinpars(igrat).tfreq);
    end
    
    % Make movies
    fprintf(1,' Frames for grating %d...', igrat);
    if sinpars(igrat).flicker
        % flickering
        ContrastTrace = sin(TemporalPhase);
        ContrastImage = sin(AngFreqs);
        ContrastImage = sign(ContrastImage).*abs(ContrastImage).^beta;
        if sinpars(igrat).sqwv
            ContrastImage = (ContrastImage>0.01)-(ContrastImage<-0.01);
        end
        Frames{igrat} = cell(nFramesInPeriod,1);
        for iframe = 1:nFramesInPeriod
            Frames{igrat}{iframe} = ContrastTrace(iframe) .* ContrastImage .* WindowImage;
        end
    else
        % drifting
        for iframe = 1:nFramesInPeriod
            ContrastImage = sin( AngFreqs + TemporalPhase(iframe));
            ContrastImage = sign(ContrastImage).*abs(ContrastImage).^beta;
            if sinpars(igrat).sqwv
                ContrastImage = (ContrastImage>eps)-(ContrastImage<-eps);
            end
            Frames{igrat}{iframe} = ContrastImage  .* WindowImage;
        end
    end
    
    % the frame sequence
    FrameSequence{igrat} = 1+mod(1:nframes,nFramesInPeriod);
   toc 
end

%% merge the stimuli

% probably obsolete
oglStim.nperiods             = 1; 

% plobably important 
oglStim.srcRect = cell(1*nframes,1);

oglStim.frames   = {[Frames{1}(:)]};

% probably obsolete
% IC won't work if commented out
oglStim.luts     =  { repmat([128 255 0 1:253]',1,3) }';

% important
oglStim.sequence.frames = [ FrameSequence{1} ];
oglStim.sequence.frames = oglStim.sequence.frames(:);

% probably obsolete
% IC won't work if commented out
oglStim.sequence.luts   = [ ones(1,nframes) ];
oglStim.sequence.luts   = oglStim.sequence.luts  (:);

% probably important
oglStim.positionIndex = repmat([1], nframes, 1);

fprintf(1,'\n');

return


%% TO TEST IT:

% [  dur ...
%    tf1 sf1 tph1 sph1 c1 ori1 dima1 dimb1 x1 y1 flick1 sqwv1 duty1 shape1 ]

myscreen = ltScreenInitialize(2); %#ok<UNRCH>
myscreen.Dist = 20;
ltLoadCalibration(myscreen);

% ltClearStimulus(Stim,'nowarnings');

pars = [ 20 ...
	    10 10 180  0  50   0  100 300 0 0 1 1 100 0 ];

pars = [ 20 ...
	    25 10   0  0  50  90  100 300 0 0 0 0 100 0 ];

Stim = oglStimMake('oglOneGrating_IC1013',pars, myscreen);
oglStimPlay(myscreen,Stim);

newpars = [ 20 ...
	       25 10   0  0 25  45  100 300 200 0 0 0 100 0 ];

Stim = oglStimUpdateDisplayParameters(Stim,newpars,myscreen);

oglStimPlay(myscreen,Stim);

ltClearLoadedTextures;

ltClearStimulus(Stim,'nowarnings');

Screen('CloseAll');
