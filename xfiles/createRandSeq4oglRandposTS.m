%this is part of oglRandpos_sparse2_alphaTS

% % Interpolate these frames 
% frameindex = floor((1:nframes)/p.nfr)+1;
% frameindex(frameindex>round(nstims))=round(nstims); 
% 
% 
% %%
% FrameGlobalAlpha= zeros( 1,round(nstims) ); 
% FrameGlobalAlpha(1,1:floor(nstims/2)*2)=reshape([globalAlpha( 1,(1:floor(nstims/2)) ) / 2;...% notice division by 2
%     zeros( 1,floor(nstims/2) ) ],1,floor(nstims/2)*2);
% 
% oglStim.globalAlpha = FrameGlobalAlpha(frameindex);
% %%
% nframes = ceil(p.dur * myscreen.FrameRate);
% RefractoryTime=2.5;
% RefractoryFrameNum=ceil(RefractoryTime*0.5 *myscreen.FrameRate/p.nfr );
% rand('seed',p.seed+30);
% posIndexBackUp = ceil( rand(1,10*floor(nstims/2))*p.npos);
% posIndex_adapted=zeros(1,floor(nstims/2));
% for iposIndex_adapted=1:length(posIndex_adapted)
%     checkSeq=posIndex_adapted(max(1,iposIndex_adapted-RefractoryFrameNum):...
%         max(1,iposIndex_adapted-1));
%     while sum(checkSeq==posIndexBackUp(iposIndex_adapted))>0 ||...
%             sum(checkSeq==max(1,posIndexBackUp(iposIndex_adapted)-1))>0 ||...
%             sum(checkSeq==min(max(posIndexBackUp),posIndexBackUp(iposIndex_adapted)+1))>0
%         posIndexBackUp(end+1)=posIndexBackUp(iposIndex_adapted);
%         posIndexBackUp(iposIndex_adapted)=[];
%         disp(['adjusting...',num2str(iposIndex_adapted)])
%     end
%     posIndex_adapted(iposIndex_adapted)=posIndexBackUp(iposIndex_adapted);
% end
% PositionIndex = zeros( 1,round(nstims) );
% PositionIndex(1,1:floor(nstims/2)*2)=...
%     reshape([posIndex_adapted;posIndex_adapted],1,floor(nstims/2)*2);
% oglStim.positionIndex=PositionIndex(frameindex);
% for ihist=1:p.npos
%     disp([num2str(ihist),'...',num2str(length(find(posIndex_adapted==ihist))),'/',num2str(length(posIndex_adapted))])
% end
% %% black and white
% rand('seed',p.seed+30);
% SequenceFramestemp= ceil( rand(1,floor(nstims/2))*2);
% SequenceFrames=ones( 1,round(nstims) );
% SequenceFrames(1,1:floor(nstims/2)*2)=...
%     reshape([SequenceFramestemp;SequenceFramestemp],1,floor(nstims/2)*2);
% SequenceFrames(end)=SequenceFrames(end-1);
% oglStim.sequence.frames = SequenceFrames(frameindex);
% 
% for ihist=1:p.nphase
%     disp([num2str(ihist),'...',...
%         num2str(length(find(SequenceFramestemp==ihist))),'/',num2str(length(SequenceFramestemp))])
% end
% 
% 
% %%
% oglStim.ori = difforideg(oriIndex(frameindex(1:nframes)));

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% version 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Interpolate these frames 
frameindex = floor((1:nframes)/p.nfr)+1;
frameindex(frameindex>round(nstims))=round(nstims); 


%% contrast
FrameGlobalAlpha= zeros( 1,round(nstims) ); 
FrameGlobalAlpha(1,1:floor(nstims/2)*2)=reshape([globalAlpha( 1,(1:floor(nstims/2)) ) / 2;...% notice division by 2
    zeros( 1,floor(nstims/2) ) ],1,floor(nstims/2)*2);

oglStim.globalAlpha = FrameGlobalAlpha(frameindex);
%% position
nframes = ceil(p.dur * myscreen.FrameRate);
RefractoryTime=2.5;
RefractoryFrameNum=ceil(RefractoryTime*0.5 *myscreen.FrameRate/p.nfr );
if floor(nstims/2)~=p.npos
    beep
    disp('frame num should be the same with posi num')
    return
end
rand('seed',p.seed+30);
posIndex_adapted = randperm(p.npos)
% posIndex_adapted=ones(1,floor(nstims/2))*(p.npos+1);
% posIndexBackUp = randperm(p.npos);
% posIndex_adapted=ones(1,floor(nstims/2))*(p.npos+1);
% for iposIndex_adapted=1:length(posIndex_adapted)
%     checkSeq=posIndex_adapted(max(1,iposIndex_adapted-RefractoryFrameNum):...
%         max(1,iposIndex_adapted-1));
%     while sum(checkSeq==posIndexBackUp(iposIndex_adapted))>0 ||...
%             sum(checkSeq==max(1,posIndexBackUp(iposIndex_adapted)-1))>0 ||...
%             sum(checkSeq==min(max(posIndexBackUp),posIndexBackUp(iposIndex_adapted)+1))>0
%         posIndexBackUp(end+1)=posIndexBackUp(iposIndex_adapted);
%         posIndexBackUp(iposIndex_adapted)=[];
%         disp(['adjusting...',num2str(iposIndex_adapted)])
%     end
%     posIndex_adapted(iposIndex_adapted)=posIndexBackUp(iposIndex_adapted);
% end
PositionIndex = zeros( 1,round(nstims) );
PositionIndex(1,1:floor(nstims/2)*2)=...
    reshape([posIndex_adapted;posIndex_adapted],1,floor(nstims/2)*2);
oglStim.positionIndex=PositionIndex(frameindex);
% for ihist=1:p.npos
%     disp([num2str(ihist),'...',num2str(length(find(posIndex_adapted==ihist))),'/',num2str(length(posIndex_adapted))])
% end
%% black and white
rand('seed',p.seed+30);
SequenceFramestemp= ceil( rand(1,floor(nstims/2))*2);
SequenceFrames=ones( 1,round(nstims) );
SequenceFrames(1,1:floor(nstims/2)*2)=...
    reshape([SequenceFramestemp;SequenceFramestemp],1,floor(nstims/2)*2);
SequenceFrames(end)=SequenceFrames(end-1);
oglStim.sequence.frames = SequenceFrames(frameindex);

for ihist=1:p.nphase
    disp([num2str(ihist),'...',...
        num2str(length(find(SequenceFramestemp==ihist))),'/',num2str(length(SequenceFramestemp))])
end


%%
oglStim.ori = difforideg(oriIndex(frameindex(1:nframes)));