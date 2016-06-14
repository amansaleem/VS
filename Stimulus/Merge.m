function myScreenStim = Merge( myScreenInfo, myScreenStim1, myScreenStim2)
% Merges two stimuli
% 
% Amplitudes are halved
% 
% BilinearFiltering off wins over on
% It ignores BackgroundColor and BackgroundPersists
%
% 2014-03 MC and ICL modified to deal with different nframes in two stimuli

%% check if it can be done

if (myScreenStim1.nFrames ~= myScreenStim2.nFrames)
    fprintf('WARNING we are merging stimuli of different duration\n');
end

if (myScreenStim1.MinusOneToOne ~= myScreenStim2.MinusOneToOne)
    fprintf('Cannot merge two stimuli of different MinusOneToOne\n');
end

if ~isempty(myScreenStim1.WaveStim) && ~isempty(myScreenStim2.WaveStim)
    fprintf('Cannot merge two stimuli that both have waves\n');
end

%% go for it

myScreenStim = ScreenStim;

myScreenStim.Type       = [ myScreenStim1.Type ' + ' myScreenStim2.Type ];
myScreenStim.Parameters = [ myScreenStim1.Parameters; myScreenStim2.Parameters ];
myScreenStim.MinusOneToOne = myScreenStim1.MinusOneToOne;
n    = min(myScreenStim1.nFrames,myScreenStim2.nFrames); % introduced 2014-03-25 for robustness
myScreenStim.nFrames = n;
myScreenStim.nTextures  = myScreenStim1.nTextures + myScreenStim2.nTextures;
myScreenStim.nImages    = myScreenStim1.nImages + myScreenStim2.nImages;
myScreenStim.ImageSequence  = [myScreenStim1.ImageSequence(1:n); myScreenStim1.nImages + myScreenStim2.ImageSequence(1:n)];
myScreenStim.Orientations   = [myScreenStim1.Orientations(1:n); myScreenStim2.Orientations(1:n)];
myScreenStim.SourceRects    = cat(2,myScreenStim1.SourceRects(:,:,1:n), myScreenStim2.SourceRects(:,:,1:n));
myScreenStim.DestRects      = cat(2,myScreenStim1.DestRects(:,:,1:n),   myScreenStim2.DestRects(:,:,1:n));

myScreenStim.Amplitudes     = [myScreenStim1.Amplitudes(1:n);   myScreenStim2.Amplitudes(1:n)];

ImageTextures1 = cell(myScreenStim1.nImages,1);
ImageTextures2 = cell(myScreenStim2.nImages,1);
for iImage = 1:myScreenStim1.nImages
    ImageTextures1{iImage} = ...
        Screen('GetImage', myScreenStim1.ImagePointers(iImage),[],[],myScreenStim.MinusOneToOne,3);
end
for iImage = 1:myScreenStim2.nImages
    ImageTextures2{iImage} = ...
        Screen('GetImage', myScreenStim2.ImagePointers(iImage),[],[],myScreenStim.MinusOneToOne,3);
end

DangerFlag = false;
for iFrame = 1:myScreenStim.nFrames
    ScaledImage1 = myScreenStim1.Amplitudes(:,iFrame)*ImageTextures1{myScreenStim1.ImageSequence(:,iFrame)};
    ScaledImage2 = myScreenStim2.Amplitudes(:,iFrame)*ImageTextures2{myScreenStim2.ImageSequence(:,iFrame)};
    if any(abs(ScaledImage1(:))>=0.5) || any(abs(ScaledImage2(:))>=0.5)
        DangerFlag = 1;
        break
    end
end
if DangerFlag
    fprintf('\n\n\nCareful! there is a potential for contrast > 1...\n\n\n');
end

myScreenStim = myScreenStim.LoadImageTextures(myScreenInfo, [ImageTextures1;ImageTextures2]);

if ~isempty(myScreenStim1.WaveStim)
    myScreenStim.WaveStim = myScreenStim1.WaveStim;
end
if ~isempty(myScreenStim2.WaveStim)
    myScreenStim.WaveStim = myScreenStim2.WaveStim;
end

bilinear1 = 1;
if myScreenStim1.BilinearFiltering == 0;
    bilinear1 = 0;
end
bilinear2 = 1;
if myScreenStim2.BilinearFiltering == 0;
    bilinear2 = 0;
end
myScreenStim.BilinearFiltering = min(bilinear1,bilinear2);

return

%% test it

myScreenStim.Show(myScreenInfo) %#ok<UNRCH>
Play(myScreenStim,myScreenInfo);

