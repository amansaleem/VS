function [oglStim, NoisePars] = oglRandpos_dense2(pars,myscreen,~)% [Stim, NoisePars] =  oglRandpos_sparse2(pars,myscreen);%% Parameters are :% [dur c barwdth baseori nori nphase seed nfr bprob ac aprob apos]%% oglStim = oglRandpos_dense2(pars,myscreen,~) is because a vs subfunction% (oglStimUpdateParameters) works by calling the function that generates% stimuli with a flag about if it needs to make new textures or not. this% part is avoided here because much of this function needs to run before% the positions are known anyway. might not be totally optimal but it works% 2010-06 ND created based on oglRandpos.m% 2010-07 ND extended from oglRandpos_dense with added functionality to%            restrict stimulus set to a portion of the screen using the last two pars% ------ parse the parametersp.dur 		= pars(1)/10; % duration.p.c			= pars(2)/100; % contrastp.barwdth   = ceil(ltdeg2pix(pars(3)/10,myscreen)); % width of bar (deg/10).p.density   = pars(4); % measure of how many bars to put on at one time in % 0 means 1 at a time 100 means all at oncep.baseori   = pars(5); % base orientation in degreesp.seed		= pars(6); % the seed of random number generatorp.nfr		= pars(7); % the number of interpolated framesp.bprob		= pars(8)./100; %the probability of a blank screen (in %)% p.ac        = pars(9)/100; % delta adapter contrast% p.aprob     = pars(10)/100; % delta adapter prob% p.apos      = pars(11); % adapter positionp.arraywdth   = ceil(ltdeg2pix(pars(9)/10,myscreen)); % array width (converted from deg*10 to pixels)p.xx           = ceil(ltdeg2pix(pars(10)/10,myscreen)); % horizontal array center (converted from deg*10 to pixels)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% have not implemented any adapter as of yet. might not make sense to do at all% the blank is also not implemented wel yet. does it even make sense to have it?%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fundamental fieldsoglStim = oglStimNew(); % preallocate so you have correct order of parametersoglStim.Generation = 3; % 3rd gen (1 = pre-OpenGL, 2 = partial OpenGL, 3 = fuller OpenGL)oglStim.Type = 'oglRandpos_dense2';oglStim.Pars = pars;oglStim.FlagMinusOneToOne = true;oglStim.TextureParameters = 1:length(pars);%% % Make a grid of x and ynx = p.barwdth; % width of the barp.barlgth = round(sqrt(myscreen.Ymax^2 + myscreen.Xmax^2)); % diagonal of screen (max length conceivable)ny = p.barlgth;[xx,yy] = meshgrid(1-nx/2:nx/2,1-ny/2:ny/2);% home positions% center of screen. could be a parameter in future if want to limit portion% of screen on which you show stimuli so that you don't waste a lot of% stimuli. in that case would have to change the automatic calculation of% stimulus position and numberp.x = 0; p.y = 0; % this is how much to offset the positions byp.offx = 0.5*(myscreen.Xmax - p.arraywdth) + p.xx;p.ctrscreenxoffset = p.offx - p.xx;% Compute the orientations of the stimulidori = 0;p.nori = 1;diffori = zeros(1,p.nori);diffori(1) = 0 + pi*(p.baseori)/180; % base orientation after converting to radiansfor iori = 2:p.nori	diffori(iori) = diffori(iori-1) + dori;enddiffori = mod(diffori,2*pi); % these are the orientations used, expressed as anglesdifforideg = diffori * 180 / pi; % convert to deg% Compute the positions of the stimuli% use this if using whole screen% p.npos = ceil(myscreen.Xmax/p.barwdth);% use this if restricting stimuli to only portion of screenp.npos = ceil(p.arraywdth/p.barwdth);if p.npos < 2    p.npos = 1;    diffpos = 0;else    adjuster = 0;    spacing_not_enough = true;    while spacing_not_enough        adjuster = adjuster+1;        % use this if using whole screen        % dpos = round((myscreen.Xmax-p.barwdth)./(p.npos-1-adjuster));        % use this if restricting stimuli to only portion of screen        dpos = round((p.arraywdth-p.barwdth)./(p.npos-1-adjuster));        diffpos = -dpos*(p.npos-1)/2:(p.barwdth+1):dpos*(p.npos-1)/2;        if all(diff(diffpos)>p.barwdth), spacing_not_enough = false; end    endendp.npos = length(diffpos);% now shift so stimuli are in center of screendiffpos = diffpos+p.offx;% now make some use of the density parameter now that we know what max% number of stimuli can bedensity_interpolator = linspace(0,100,p.npos);nstimsatonce = find(hist(p.density,density_interpolator));%  the phases of the stimuli - just use 0 and pi for white and black stimulidiffph = [0 pi];p.nphase = size(diffph,2);% MAKE ALL THE FRAMESmymovie = cell(p.nphase,1);iframe = 0;% make it a uniform fieldthissf = 0;% thissf = 1./ltdeg2pix(1/p.sf,myscreen); % sf in cycles/pixfor iph = 1:p.nphase    iframe = iframe+1;    thisori = 0; % stimulus will be rotated during presentation    thisphase = diffph(iph);    % make the stimulus aperture    angfreq = -2*pi*thissf*( cos(thisori).*xx + sin(thisori).*yy );    % introduce a phase correction for the offset of the window.    % phzcorr = 2.*pi.*thispos.*thissf; OBSOLETE    % EDITED BY MC AND AB 2006-03-20: sin TO cos    % movieimage = p.c * cos( phzcorr + thisphase + angfreq );    movieimage = p.c * cos(thisphase + angfreq);    mymovie{iframe} = uint8(round(( movieimage + 1 )*126 + 2));    mymovie{iframe} = movieimage;    % and at this point movieimage goes bet 2 and 254endnblnk = 0;if p.bprob > 0	ngrat = p.nori*p.nphase.*p.npos; % keep ngrat like it was because blank probability refers to to all possible combinations	nblnk = round(ngrat.*(1/p.bprob-1).^-1);    % make 1 frame for the blank stim    iframe = iframe+1;    movieimage = zeros(size(xx));    mymovie{iframe} = uint8(round((movieimage + 1)*126 + 2));    mymovie{iframe} = movieimage;    % and at this point movieimage contains gray (128)end% That's it for the framesoglStim.frames{1} = mymovie;% % MAKE ALL THE LUTSlinClut = [ [128 128 128]; [255 255 255]; [ 0 0 0]; round(linspace(0,255,253))'*[1 1 1] ];for istimsatonce = 1:nstimsatonce    oglStim.luts{istimsatonce,1} = linClut;end% The number of frames in the entire stimulusnframes = ceil(p.dur * myscreen.FrameRate);oglStim.sequence.luts = repmat(1:nstimsatonce,1,nframes)';% The position of the stimulus% First: center the stim where the user wants itx1 = round(p.arraywdth/2) - round(p.barwdth/2);y1 = round(myscreen.Ymax/2) - round(p.barlgth/2);x2 = round(p.arraywdth/2) + round(p.barwdth/2);y2 = round(myscreen.Ymax/2) + round(p.barlgth/2);% use the following if filling whole screen with stimuli% x1 = round(myscreen.Xmax/2) - round(p.barwdth/2);% x2 = round(myscreen.Xmax/2) + round(p.barwdth/2);homePos = OffsetRect([ x1 y1 x2 y2 ],p.x,p.y);% Now: shift the stim relative to thatframePos = cell(p.nori,1);for iori = 1 : p.nori    framePos{iori} = zeros(p.npos,4);    for ipos = 1 : p.npos        shiftX = cos(diffori(iori)) * diffpos(ipos);        shiftY = sin(diffori(iori)) * diffpos(ipos);        framePos{iori}(ipos,:) = OffsetRect(homePos, shiftX, shiftY);    endend%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% not sure what to do if have more than one orientation. probably have to% have another set for that. but won't worry about that here.oglStim.position = framePos{1};% oglStim.offset = [p.x p.y];%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% The number of images that contain a gratingngrat = p.nori*p.nphase*p.npos+nblnk;% The sequence of frames (position and spatial phase)frameseq = zeros(nstimsatonce, nframes);% DEFINE THE RANDOM SEQUENCE OF THE FRAMES% Set the seed, and select the Matlab 4 rand num generatorrand('seed',p.seed);stimseq = min(ngrat ,ceil(rand(nstimsatonce,nframes)*ngrat)); % number of frames temporaryframeseq(stimseq > ngrat-nblnk) = length(mymovie); % blank framesnstimPerPhase = p.nori*p.npos;for iphase = 1 : p.nphase    frameseq(stimseq > (iphase-1)*nstimPerPhase & stimseq <= iphase*nstimPerPhase) = iphase;end% The sequence of orientations and positionsrand('seed',p.seed+10);oriIndex = ceil(rand(nstimsatonce,nframes)*p.nori);rand('seed',p.seed+20);% fill up by randomly sequencing 1:p.npos and then select just the first 1:nstimsatonceposIndex_temp = zeros(nframes,p.npos);for iframe = 1:nframes    posIndex_temp(iframe,:) = randperm(p.npos);endposIndex = posIndex_temp(:,1:nstimsatonce)';% Interpolate these frames frameindex = floor(1:1/p.nfr:nframes);PosFrames = posIndex(:,frameindex(1:nframes));oglStim.positionIndex = PosFrames(:);SequenceFrames = frameseq(:,frameindex(1:nframes));oglStim.sequence.frames = SequenceFrames(:);oglStim.ori = difforideg(oriIndex(:,frameindex(1:nframes)));% The number of times you want to see the movie		oglStim.nperiods = 1;oglStim.globalAlpha = ones(nstimsatonce,nframes);oglStim.srcRect = cell(nstimsatonce*nframes,1);%% Noise Parameters --> gets the random stimulus sequencesdiffpos_deg = ltpix2deg(oglStim.position(:,1)+unique(diff(diffpos)) - (p.ctrscreenxoffset+p.arraywdth/2),myscreen)';NoisePars.sequence.positions = reshape(oglStim.positionIndex,nstimsatonce,[]);NoisePars.sequence.frames = reshape(oglStim.sequence.frames,nstimsatonce,[]);NoisePars.possible.positions = oglStim.position;NoisePars.possible.frames = unique(frameseq);% compute the parameters of each unique stimulusiImage = 0; % unique combination of ori, pos, phaseiMovieFrame = 0; % unique frames computedfor iph = 1:p.nphase    iMovieFrame = iMovieFrame + 1;    for ipos = 1:p.npos        for iori = 1:p.nori            iImage = iImage+1;            NoisePars.ori(  iImage) = diffori(iori)/pi*180;            NoisePars.pos(  iImage) = diffpos_deg(ipos); % pos in deg            NoisePars.phase(iImage) = diffph(iph)/pi*180;            NoisePars.c(    iImage) = p.c;            NoisePars.sf(   iImage) = 0;            % images with different ori and pos share the same MovieFrame            NoisePars.iMovieFrame( iImage ) = iMovieFrame;        end    endendif p.bprob > 0    iMovieFrame = iMovieFrame + 1; % one MovieFrame for the blank stimulus    % the blank frame    for ibl = 1        iImage = iImage+1;        NoisePars.ori(iImage) = NaN;        NoisePars.pos(iImage) = NaN;        NoisePars.phase(iImage) = NaN;        NoisePars.c(iImage) = 0;        NoisePars.sf(iImage) = NaN;        NoisePars.iMovieFrame( iImage ) = iMovieFrame;    endend% build the virtual sequenceNoisePars.VirtualSequence=NaN(1,nframes);if p.bprob>0    NoisePars.VirtualSequence(NoisePars.sequence.frames==3) = find(NoisePars.iMovieFrame==3);endfor iframe = 1:nframes    tempix = find( NoisePars.sequence.frames(iframe) == NoisePars.iMovieFrame & ...        diffpos_deg(NoisePars.sequence.positions(iframe)) == NoisePars.pos );    if ~isempty(tempix)        NoisePars.VirtualSequence(iframe) = tempix;    endendreturn%% -------------------------------------------------------------% Code to test the functionwhichScreen = 2;myscreen = ltScreenInitialize(whichScreen);myscreen.Dist = 28;ltLoadCalibration(myscreen);% myscreen = ScreenLogLoad('F100617',1,2,'stim');myscreen = ScreenLogLoad('M100722',1,11,'stim');%%% The parametersdur 		= 100; % sec*10c			= 75; % contrast in %barwdth		= 50; % bar widthdensity     = 80; % how many bars to use at oncebaseori     = 0; %starting orientation in sequenceseed		= 2; % the seed of random number generatornfr			= 10; % the number of interpolated framesbprob       = 0; % percent chance that the stimulus is blankarraywdth   = 350; % width of stimulus set in degrees*10x           = 166; % x-center of stimulus set in degrees*10 from center of screenpars_dense = [dur c barwdth density baseori seed nfr bprob arraywdth x];Stim_dense = oglStimMake('oglRandpos_dense2',pars_dense, myscreen);%%oglStimPlay(myscreen,Stim_dense);%%ltClearStimulus(Stim_dense,'nowarnings');Screen('CloseAll');