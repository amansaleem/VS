function RigInfo = RigInfoGet(VsHostName)
% Database of information of various rigs in the lab
%
% RigInfo = GetRigInfo gives you information on the computer you are
% running from.
%
% RigInfo = GetRigInfo(VsHostName) lets you specify the name of the
% computer.
%
% RigInfo has the following fields:
%  VsHostName
%  VsHostCalibrationDir
%  VsDisplayScreen
%  VsDisplayAdaptor
%  MonitorType
%  MonitorSize
%  MonitorNumber
%  DefaultMonitorDistance
%  zpepComputerName
%  zpepComputerIP
%  SyncSquare an object with fields Type, Position, Size
%  WaveInfo
%
% 2011-02 Matteo Carandini extracted from vs and improved
% 2011-07 AA commented out RigInfo.WaveInfo object specifications for
%         zupervision
% 2012-04 MK added ZMAZE rig
% 2012-08 AS added RigInfo.WaveInfo object specifications for
%         zupervision back in to try new NI card
% 2013-09 MC added ScaleOldStimuliFactor

%% deal with arguments

if nargin < 1
  MyDir = pwd;
  cd('C:/');
  [~,VsHostName] = system('hostname');
  VsHostName = VsHostName(1:end-1);
  cd(MyDir);
end

%% defaults

RigInfo.VsHostName = VsHostName;
RigInfo.VsHostCalibrationDir = 'C:\Calibrations\';
RigInfo.VsDisplayScreen = 1;
RigInfo.VsDisplayAdaptor = '';
RigInfo.MonitorType = '';
RigInfo.MonitorSize = NaN; % this is the total size !
RigInfo.MonitorNumber = 1;
RigInfo.DefaultMonitorDistance = 28.5; % cm

RigInfo.VsDisplayRect = []; % empty means whole screen (MC 2013-04-25)
RigInfo.zpepComputerName = '';
RigInfo.zpepComputerIP = '';

% defaults for the sync square
RigInfo.SyncSquare = SyncSquare; % this makes a new object

RigInfo.WaveInfo = WaveInfo; % blank DAQ info object

RigInfo.ScaleOldStimuliFactor = NaN; % MC 2013/09/03 scales "old style" stimuli to save memory

%% database

fprintf('Loading information for VS host %s\n', VsHostName);

switch upper(VsHostName)
  
  case {'ZAP', 'ZOOROPA'}
    % physiology rig 1
    RigInfo.VsDisplayScreen = 2;
    %         RigInfo.MonitorType = 'NEC Multisync LCD 2190UXp';
    RigInfo.MonitorType = 'ProLite B1980SD'; %AP 11-03-14
    RigInfo.MonitorSize = 37.632*3; % cm - long side (measured 17-03-14)
    RigInfo.DefaultMonitorDistance = 19; % cm % DS added on 2014-03-21
    RigInfo.MonitorNumber = 3;
    RigInfo.zpepComputerIP = '144.82.135.48';
    RigInfo.zpepComputerName = 'ZFASTER';
    
    RigInfo.WaveInfo.DAQAdaptor = 'ni'; % CB CHANGED 2014-02-12
    RigInfo.WaveInfo.DAQString = 'Dev1';
    RigInfo.WaveInfo.SampleRate = 250e3; %DS added on 2015-3-25
    %RigInfo.WaveInfo.FrameSyncChannel = ''; %DS added on 2014-02-26
    RigInfo.Geometry = 'Circular'; % DS added on 2014-04-03
    RigInfo.HorizontalSpan = 270; % DS added on 2014-04-03
     %RigInfo.ColorChannels2Use = [0 1 1]; % DS added on 2014-07-11
   
    RigInfo.SyncSquare.Size = 100; %DS recovered on 2014-04-04
    
    % position of sync square
    positionflag=[];
    while isempty(positionflag)
      positionflag=input('Where do you want the sync square?  ({l}eft or {r}ight) >>','s');
      switch positionflag
        case 'l'
          RigInfo.SyncSquare.Position = 'SouthWest';
        case 'r'
          RigInfo.SyncSquare.Position = 'SouthEast';
        otherwise
          positionflag=[];
      end
    end
    % type of sync square
    flickerflag=[];
    while isempty(flickerflag)
      flickerflag=input('Type of sync square?  ({s}teady or {f}licker) >>','s');
      switch flickerflag
        case 's'
          RigInfo.SyncSquare.Type = 'Steady';
        case 'f'
          %                    RigInfo.SyncSquare.Type = 'Flicker';
 %         RigInfo.SyncSquare.Type = 'Flicker-Steady'; %DS on 13.11.1
          RigInfo.SyncSquare.Type = 'Flicker'; %DS on 13.11.1
        otherwise
          flickerflag=[];
      end
    end
    
    %RigInfo.test = 1;
    
    
  case 'ZODIAC4'
    % 2-photon rig
    RigInfo.VsDisplayScreen = 1;
    RigInfo.MonitorType = 'ViewSonic VA916g';
    RigInfo.MonitorSize = 37; % cm - long side
    RigInfo.zpepComputerIP   = '144.82.135.67';
    RigInfo.zpepComputerName = 'ZIZZI';
    RigInfo.WaveInfo.DAQAdaptor = 'nidaq';
    RigInfo.WaveInfo.DAQString = 'Dev1';
    RigInfo.DefaultMonitorDistance = 12.5; % cm
    RigInfo.MonitorNumber = 2;
    % CB added sync square
    RigInfo.SyncSquare.Position = 'SouthWest';
    RigInfo.SyncSquare.Type = 'Flicker'; % or steady?
    
%   case 'ZOOLANDER'
%     % New 2-photon rig
%     RigInfo.VsDisplayScreen = 1;
%     RigInfo.MonitorType = 'Prolite E2273HDS';
%     RigInfo.MonitorSize = 48; % cm - long side
%     RigInfo.zpepComputerIP   = '144.82.135.67';
%     RigInfo.zpepComputerName = 'ZIZZI';
%     RigInfo.WaveInfo.DAQAdaptor = 'ni';
%     RigInfo.WaveInfo.DAQString = 'Dev1';
%     RigInfo.DefaultMonitorDistance = 12.5; % cm
%     RigInfo.MonitorNumber = 0;
%     % CB added sync square
%     RigInfo.SyncSquare.Position = 'SouthWest';
%     RigInfo.SyncSquare.Type = 'Steady'; % or steady?
  case 'ZOOLANDER'
    % MOMmy
    RigInfo.VsDisplayScreen = 2;
    RigInfo.MonitorType = 'RossiScreen';
    RigInfo.MonitorSize = 15.5; % cm - long side
    RigInfo.zpepComputerIP   = '144.82.135.28';
    RigInfo.zpepComputerName = 'Z2P';
    RigInfo.WaveInfo.DAQAdaptor = 'ni';
    RigInfo.WaveInfo.DAQString = 'Dev1';
    RigInfo.DefaultMonitorDistance = 10; % cm
    RigInfo.MonitorNumber = 0;
    % CB added sync square
    RigInfo.SyncSquare.Position = 'SouthWest';
     RigInfo.SyncSquare.Type = 'Steady'; % or steady?    
%    RigInfo.SyncSquare.Type = 'Flicker'; % or steady?    
    
  case 'ZODIAC'
    % mouse behavior boxes
    RigInfo.MonitorType = 'HannsG HX192';
    RigInfo.MonitorSize = 37.5; % cm - long side (measured 071228 LB)
    
  case 'ZUPERVISION'
    % ball rig number 1
    RigInfo.VsDisplayScreen = 2;
    RigInfo.MonitorType = 'Hanns-G HA191';
    RigInfo.MonitorSize = 114.0; % cm - long side (measured 100204)
    RigInfo.MonitorNumber = 3;
    RigInfo.zpepComputerIP   = '144.82.135.38';
    RigInfo.zpepComputerName = 'ZIRKUS';
    RigInfo.DefaultMonitorDistance = 34;
    % RigInfo.SyncSquare.Type = 'Flicker';
    
    %         % this might interfere with reward, etcetera
    RigInfo.WaveInfo.DAQAdaptor = 'nidaq'; %commented out AA, 08-12 AS added it back in to try new NI card
    RigInfo.WaveInfo.DAQString = 'Dev2';
    
  case 'ZUPERDUPER'
    % ball rig number 1
    RigInfo.VsDisplayScreen = 1;
    RigInfo.MonitorType = 'Hanns-G HA191';
    RigInfo.MonitorSize = 114.0; % cm - long side (measured 100204)
    RigInfo.MonitorNumber = 3;
    RigInfo.zpepComputerIP   = '144.82.135.117';
    RigInfo.zpepComputerName = 'ZOO';
    RigInfo.DefaultMonitorDistance = 34;
    % RigInfo.SyncSquare.Type = 'Flicker';
    
    %         % this might interfere with reward, etcetera
    RigInfo.WaveInfo.DAQAdaptor = 'ni'; %commented out AA, 08-12 AS added it back in to try new NI card
    RigInfo.WaveInfo.DAQString = 'Dev1';
  case 'ZEXTRA'
    % physiology rig 2
    RigInfo.VsDisplayScreen = 2;
    RigInfo.MonitorType = 'Iiyama ProLite E2273HDS'; % 2013-03 CB changed
    RigInfo.MonitorSize = 2*48.0; % for 2 screens via MATROX
    %         RigInfo.MonitorType = 'Iiyama ProLite E2607WS';
    %         RigInfo.MonitorSize = 55.0; % cm - long side (measured 100204)
    RigInfo.zpepComputerIP = '144.82.135.120';
    RigInfo.zpepComputerName = 'ZINTRA';
    RigInfo.WaveInfo.DAQAdaptor = 'nidaq';
    RigInfo.WaveInfo.DAQString = 'Dev1';
    
    positionflag=[];
    while isempty(positionflag)
      positionflag=input('are you TS?  (y or n) >>','s');
      switch positionflag
        case 'y'
          RigInfo.SyncSquare.Position = 'SouthEast';
          RigInfo.DefaultMonitorDistance =24;
        case 'n'
          RigInfo.SyncSquare.Position = 'SouthWest';
          RigInfo.DefaultMonitorDistance = 24; % cm
        otherwise
          positionflag=[];
      end
    end
    
    ScaleFactorflag=input('use lower resolution?  (y or n) >>','s');
    switch ScaleFactorflag
      case 'y'
        RigInfo.ScaleOldStimuliFactor = 6;
      case 'n'
      otherwise
    end
    
  case 'ZEXTRA2'
    % physiology rig 2
    RigInfo.VsDisplayScreen = 2;
    RigInfo.MonitorType = 'Iiyama ProLite E2273HDS'; % 2013-03 CB changed
    RigInfo.MonitorSize = 2*48.0; % for 2 screens via MATROX
    %         RigInfo.MonitorType = 'Iiyama ProLite E2607WS';
    %         RigInfo.MonitorSize = 55.0; % cm - long side (measured 100204)
    RigInfo.zpepComputerIP = '144.82.135.245'; %zintra2 bh 23may2014
    RigInfo.zpepComputerName = 'ZINTRA2';
    RigInfo.WaveInfo.DAQAdaptor = 'ni';
    RigInfo.WaveInfo.DAQString = 'Dev1';
    
  case 'ZILLION'
    % ball rig number 2
    RigInfo.VsDisplayScreen = 2;
    RigInfo.VsDisplayAdaptor = 'Matrox TripleHead2Go Digital Edition';
    RigInfo.MonitorType = 'HANNS-G HA-191';
    RigInfo.MonitorSize = 38*3;
    RigInfo.MonitorNumber = 3;

%     added by MK on 2014-09-25, uncomment if you want to use these definitions
%     RigInfo.DefaultMonitorDistance = 20;
%     RigInfo.Geometry = 'Circular'; % 'Flat' or 'Circular'
%     RigInfo.HorizontalSpan = 270; % degrees of the overall (two-sided) span
   
    RigInfo.zpepComputerIP = '144.82.135.118';
    RigInfo.zpepComputerName = 'ZURPLUS';
    
    RigInfo.SyncSquare.Type = 'Steady'; %'Flicker';
    
    % type of sync square % added by NS on 2014/05/26
    flickerflag=[];
    while isempty(flickerflag)
        flickerflag=input('Type of sync square?  ({s}teady or {f}licker) >>','s');
        switch flickerflag
            case 's'
                RigInfo.SyncSquare.Type = 'Steady';
            case 'f'
                RigInfo.SyncSquare.Type = 'flickergrey';
                
            otherwise
                flickerflag=[];
        end
    end
    
    RigInfo.SyncSquare.Size = 100;
    
    RigInfo.WaveInfo.DAQAdaptor = 'ni';
    RigInfo.WaveInfo.DAQString = 'Dev1';
    RigInfo.WaveInfo.ExtTriggerChannel = 'PFI0'; % this is also the default if not defined here
    RigInfo.WaveInfo.TriggerCondition = 'RisingEdge'; % 'RisingEdge' (default) or 'FallingEdge'
    
    RigInfo.ScaleOldStimuliFactor = 6; % changed from 3 (mush,10-Sept-2013)

    case 'ZGOOD'
     % Nick's rig in 3/2   
    RigInfo.VsDisplayScreen = 1;
    RigInfo.VsDisplayAdaptor = 'Matrox TripleHead2Go Digital Edition';
    RigInfo.MonitorType = 'Iiyama ProLite E1980SD';
    RigInfo.MonitorSize = 38*3; %cm
    RigInfo.MonitorNumber = 3;
    RigInfo.MonitorHeight = 30;
%     added by MK on 2014-09-25, uncomment if you want to use these definitions
    RigInfo.DefaultMonitorDistance = 19;
    RigInfo.Geometry = 'Circular'; % 'Flat' or 'Circular'
    RigInfo.HorizontalSpan = 270; % degrees of the overall (two-sided) span
   
%     RigInfo.BackgroundColor = 20;
    
    RigInfo.zpepComputerIP = '144.82.135.23';
    RigInfo.zpepComputerName = 'ZBAD';
    
%     RigInfo.SyncSquare.Type = 'flickergrey'; %'Flicker';
    
    % type of sync square % added by NS on 2014/05/26
    flickerflag=[];
    while isempty(flickerflag)
        flickerflag=input('Type of sync square?  ({s}teady or {f}licker) >>','s');
        switch flickerflag
            case 's'
                RigInfo.SyncSquare.Type = 'Steady';
            case 'f'
                RigInfo.SyncSquare.Type = 'flickergrey';
                
            otherwise
                flickerflag=[];
        end
    end
    
    RigInfo.SyncSquare.Size = 100;
    RigInfo.SyncSquare.Position = 'SouthEast';
    
    RigInfo.WaveInfo.DAQAdaptor = 'ni';
    RigInfo.WaveInfo.DAQString = 'Dev2';
    RigInfo.WaveInfo.FrameSyncChannel = 'port1/line0';
    RigInfo.ScaleOldStimuliFactor = 6; % changed from 3 (mush,10-Sept-2013)    
    
  case 'ZMAZE'
    % VS/tlVS/VR computer @ B-Scope
    RigInfo.VsDisplayScreen = 1;
    RigInfo.VsDisplayAdaptor = 'Matrox TripleHead2Go Digital Edition';
    RigInfo.MonitorType = 'Iiyama ProLite E1980SD';
    RigInfo.MonitorSize = 38*3;
    RigInfo.MonitorHeight = 30;
    RigInfo.MonitorNumber = 3;
    RigInfo.zpepComputerIP = '144.82.135.65';
    RigInfo.zpepComputerName = 'ZQUAD';
    RigInfo.DefaultMonitorDistance = 19;
    RigInfo.Geometry = 'Circular'; % 'Flat' or 'Circular'
    RigInfo.HorizontalSpan = 270; % degrees of the overall (two-sided) span
    RigInfo.ColorChannels2Use = [0 1 1]; % e.g use [0 1 1] to kill the red gun
    
    RigInfo.SyncSquare.Type = 'Flicker'; %{'Steady'; 'Flicker'}
    RigInfo.SyncSquare.Size = 100;
    RigInfo.SyncSquare.Position = 'SouthEast';
    
    RigInfo.WaveInfo.DAQAdaptor = 'ni';
    RigInfo.WaveInfo.DAQString = 'Dev1';
    %         RigInfo.WaveInfo.FrameSyncChannel = 'port0/line2'; % 2013-03 CB added
    
  case 'ZSCOPE'
    % 2p imaging computer on B-scope (2/18)
    RigInfo.zpepComputerIP = '144.82.135.65';
    RigInfo.zpepComputerName = 'ZQUAD';
    
  case 'ZCAMP3'
    % Timeline computer @ B-Scope
    RigInfo.zpepComputerIP = '144.82.135.65';
    RigInfo.zpepComputerName = 'ZQUAD';
    
    RigInfo.WaveInfo.DAQAdaptor = 'ni';
    RigInfo.WaveInfo.DAQString = 'Dev1';
    
  case 'ZIZZANIA'
    % imaging rig
    RigInfo.VsDisplayScreen = 2;
    RigInfo.zpepComputerIP = '144.82.135.63';   % '144.82.135.33';
    RigInfo.zpepComputerName = 'ZUENDER';          % 'ZODIAC4';
    RigInfo.MonitorType = 'Hyundai L90D+';
    RigInfo.MonitorSize = 38; % check this!!!
    RigInfo.WaveInfo.DAQAdaptor = 'nidaq';
    RigInfo.WaveInfo.DAQString = 'Dev1';
    
    RigInfo.SyncSquare.Type = 'Steady';
    RigInfo.SyncSquare.Size = 1;
    
  case 'ZAMAN-YOK'
    RigInfo.zpepComputerIP = '144.82.135.79';
    RigInfo.zpepComputerName = 'ZAMAN-YOK';
    RigInfo.VsDisplayScreen = 2;
    
  case 'ZUNDER' % Sylvia's desktop PC
    RigInfo.zpepComputerIP = '144.82.135.85';
    RigInfo.zpepComputerName = 'ZUNDER';
    RigInfo.VsDisplayScreen = 2;
    RigInfo.MonitorSize = 52;
    RigInfo.ColorChannels2Use = [0 1 1]; % e.g use [0 1 1] to kill the red gun
    
  case 'ZURPLUS'
    % this may be obsolete
    RigInfo.VsDisplayScreen = 2;
    RigInfo.zpepComputerIP = '144.82.135.51';
    RigInfo.zpepComputerName = 'ZAZZERA';
    
  case {'ZI', 'ZANTANA'} %19/5/14 DS
    RigInfo.EyeTrack_Camera_Name = 'DMx 21BU04';
    
  case 'ZEYE'
    RigInfo.EyeTrack_Camera_Name = 'DMx 21BU04';
    
  case 'ZLICKBLINK'
    RigInfo.EyeTrack_Camera_Name = 'DMx 21BU04'; %AP Feb 14
    
  case 'ZEYE2'
    RigInfo.EyeTrack_Camera_Name = 'DMx 21BU04';
    RigInfo.EyeTrackCameraAdaptor = 'tisimaq';
    
  case 'ZUGLY'
    RigInfo.EyeTrack_Camera_Name = 'DMK 23U618';
    RigInfo.EyeTrackCameraAdaptor = 'tisimaq';    
    
  case 'ZQUAD'
    RigInfo.EyeTrack_Camera_Name = 'DFK 21F04';
    
  case 'ZLICK'
    RigInfo.VsDisplayScreen = 1;
    RigInfo.MonitorType = 'Matrox on two Iiyama ProLite E2273HDS';
    RigInfo.MonitorSize = 60; % HACK!! DID NOT MEASURE THIS YET!!
    RigInfo.MonitorNumber = 2;
    RigInfo.VsDisplayRect = [ 0 0 2732 768 ];
    
    RigInfo.WaveInfo.DAQAdaptor = 'nidaq';
    RigInfo.WaveInfo.DAQString = 'Dev1';
    
  case 'ZURGERY2'
    RigInfo.VsDisplayScreen = 1;
    RigInfo.zpepComputerName = 'ZTEREOTAX';
    RigInfo.zpepComputerIP = '144.82.135.26';
    
    % RigInfo.MonitorNumber = 1;
    % RigInfo.MonitorType = 'HANNS-G HA-191'; % HACK!! DID NOT MEASURE THIS YET!!
    % RigInfo.MonitorSize = 38;
    
    RigInfo.MonitorNumber = 1;
    RigInfo.MonitorType = 'ViewSonic VA2746';
    RigInfo.MonitorSize = 69; % HACK!! DID NOT MEASURE THIS YET!!
 
    RigInfo.WaveInfo.DAQAdaptor = 'ni';
    RigInfo.WaveInfo.DAQString = 'Dev1';   % That's the USB one, NI-USB-6211
    RigInfo.WaveInfo.FrameSyncChannel = 'port1/line0';
 
  case 'ZIT'
    RigInfo.VsDisplayScreen = 1;
    RigInfo.MonitorType = 'ASUS';
    RigInfo.MonitorNumber = 2;
    RigInfo.MonitorSize = 48; % cm - long side
    RigInfo.zpepComputerIP   = '127.0.0.1';
    RigInfo.zpepComputerName = 'localhost';
    RigInfo.WaveInfo.DAQAdaptor = 'ni';
    RigInfo.WaveInfo.DAQString = 'Dev1';
    RigInfo.DefaultMonitorDistance = 12.5; % cm
    % CB added sync square
    RigInfo.SyncSquare.Position = 'SouthWest';
    RigInfo.SyncSquare.Type = 'Flicker'; % or steady?
    
  case 'ZURPRISE' % tlvs computer on Bergamo2 (room 3/3)
    RigInfo.VsDisplayScreen = 2;
    RigInfo.MonitorType = 'Iiyama ProLite E1980SD';
    RigInfo.MonitorNumber = 2;
    RigInfo.MonitorSize = 38*3; % cm - long side
    RigInfo.MonitorHeight = 30;
    RigInfo.zpepComputerIP   = '144.82.135.100';
    RigInfo.zpepComputerName = 'ZIMAGE';
    RigInfo.WaveInfo.DAQAdaptor = 'ni';
    RigInfo.WaveInfo.DAQString = 'Dev1';
    RigInfo.DefaultMonitorDistance = 19; % cm
    RigInfo.Geometry = 'Circular'; % 'Flat' or 'Circular'
    RigInfo.HorizontalSpan = 270; % degrees of the overall (two-sided) span
    RigInfo.ColorChannels2Use = [0 1 1]; % e.g use [0 1 1] to kill the red gun
    % CB added sync square
    RigInfo.SyncSquare.Position = 'SouthWest';
    RigInfo.SyncSquare.Type = 'Flicker'; % or steady?
    RigInfo.SyncSquare.Size = 65;
    
    RigInfo.WaveInfo.FrameSyncChannel = 'port0/line3';
    
  case 'ZYLVIA' % 2p imaging computer on Bergamo2 (room 3/3)
    RigInfo.zpepComputerIP = '144.82.135.100';
    RigInfo.zpepComputerName = 'ZIMAGE';
    
  otherwise
    error('I do not know this host -- amend RigInfoGet');
end

