function [stack TimeIni message]=getstack(station, CamName,roirect,Frames)

% [stack TimeIni message]=getstack(CamName,roirect,Frames)
% This function captures stacks using one camera at the frame rate defined
% by the user in the camera configuration file. It captures the information
% as an uncompressed AVI file of the ROI defined.
%
% Inputs:
%   CamName: Video object or name of the configured camera to use (For
%   example: 'C1').
%   roirect: Position and size of the Region of Interest: [U V width height]
%   Frames: Number of frames to be captured, the time of the capture
%   process is the defined by Frames/FR, where FR is the frame rate defined
%   in the camera configuration.
%
% Outputs:
%   stack: Name of the AVI file used to store the stack
%   TimeIni: Time at which the capture was started
%   message: Error message if there is such.
%
%   Developed by Juan camilo P�rez Mu�oz (2011) for the HORUS project.

try
    
    stack=[];
    TimeIni=[];
    message=[];
    
    % Set HORUS paths
    if ~isdeployed
        root = fileparts(mfilename('fullpath'));
        root = fileparts(root);
        root = fileparts(root);
        addpath(genpath(root));
    end
    
    xmlfile = 'capture_info.xml';
    
    if ~exist(xmlfile, 'file')
        message = ['Error: The file ' xmlfile ' does not exist!'];
        disp(message);
        return
    end
    
    xml = loadXML(xmlfile, 'Configuration', 'station', station);
    
    xmlPath = strcat('Configuration[station=', station,...
        ']/CameraConfig/Camera[id=', CamName, ']');
    
    cameraNode = getNodes(xml, xmlPath);
    
    if isempty(cameraNode)
        message = ['Error: The camera ' CamName ' was not found!'];
        disp(message);
        return
    end
    
    cameraNode = cameraNode{1};
    
    fr = getNodeVal(cameraNode, 'FrameRate');
    gm = getNodeVal(cameraNode, 'GainMode');
    sm = getNodeVal(cameraNode, 'ShutterMode');
    wb = getNodeVal(cameraNode, 'WhiteBalanceMode');
    AdaptorName = getNodeVal(cameraNode, 'AdaptorName');
    DeviceID = getNodeVal(cameraNode, 'DeviceID');
    DeviceFormat = getNodeVal(cameraNode, 'DeviceFormat');
    
    xmlPath = strcat(xmlPath, '/AOI');
    AOINode = getNodes(xml, xmlPath);
    
    if ~isempty(AOINode)
        AOINode = AOINode{1};
        AOI.mode = getNodeVal(AOINode, 'mode');
        AOI.Height = str2double(getNodeVal(AOINode, 'Height'));
        AOI.Width = str2double(getNodeVal(AOINode, 'Width'));
        AOI.Left = str2double(getNodeVal(AOINode, 'Left'));
        AOI.Top = str2double(getNodeVal(AOINode, 'Top'));
    end
    
    imaqreset
    h=imaqhwinfo(AdaptorName);
    Devices={h.DeviceInfo.DeviceName};
    
    if isempty(Devices)
        message=['There are no ' AdaptorName ' cameras connected'];
        disp(message)
        return
    end
    
    if isempty(DeviceID)
        message=['There is no device designed'];
        disp(message)
        return
    end
    
    disp([AdaptorName ' ' mat2str(DeviceID) ' ' DeviceFormat])
    try
        cam=videoinput(AdaptorName,DeviceID,DeviceFormat);
    catch ME
        message=[ME.message ' ' CamName];
        disp(message)
        return
    end
    source=cam.Source;
    sourcet=set(source);
    set(source,'FrameRate',fr)
    if  isfield(sourcet,'GainMode')
        set(source,'GainMode',gm)
    end
    if  isfield(sourcet,'ShutterMode')
        set(source,'ShutterMode',sm)
    end
    if  isfield(sourcet,'WhitebalanceMode')
        set(source,'WhitebalanceMode',wb)
    end
    if  isfield(sourcet,'WhiteBalanceMode')
        set(source,'WhiteBalanceMode',wb)
    end
    if exist('AOI','var') && isfield(sourcet, 'AutoFunctionAOIMode')
        
        if ~strcmpi(AOI.mode, 'none')
            set(source,'AutoFunctionAOIMode','off')
        end
        if ~strcmpi(AOI.Height, 'none')
            set(source,'AutoFunctionAOIHeight',AOI.Height)
        end
        if ~strcmpi(AOI.Width, 'none')
            set(source,'AutoFunctionAOIWidth',AOI.Width)
        end
        if ~strcmpi(AOI.Left, 'none')
            set(source,'AutoFunctionAOILeft',AOI.Left)
        end
        if ~strcmpi(AOI.Top, 'none')
            set(source,'AutoFunctionAOITop',AOI.Top)
        end
    end
    
    parts = regexp(fr, '/', 'split');
    if numel(parts) == 1
        nfr = str2double(fr);
    else
        nfr = str2double(parts{1}) / str2double(parts{2});
    end
    
    FrameGrabInterval=1;
    set(cam,'FramesPerTrigger',25)
    start(cam)
    wait(cam,max(20,50/nfr+2))
    set(cam,'FramesPerTrigger',Frames)
    set(cam,'ROIPosition',roirect);
    set(cam,'FrameGrabInterval',1);
    set(cam,'Timeout',Frames*FrameGrabInterval)
    
    
    try
        if 0 %Never log on memory unlees you know is possible
            cam.LoggingMode = 'memory';
            flushdata(cam)
            stop(cam)
            time1=now;
            start(cam)
            [stack ,time] = getdata(cam,Frames,'uint8');
            time=time/(24*60*60)+time1;
        else
            disp('Memory Limit overflow risk, logging data to disk')
            aviname=['TIME.GMT.SITE.' CamName '.STACK.' mat2str(roirect(1)) ...
                '.' mat2str(roirect(2)) '.' mat2str(roirect(3)) 'X' ...
                mat2str(roirect(4)) '.HORUS.avi'];
            disp(['Avi file: ' aviname])
            aviobj = avifile(aviname,'compression','none','fps', nfr);
            cam.LoggingMode = 'disk';
            cam.DiskLogger = aviobj;
            flushdata(cam)
            stop(cam)
            TimeIni=getTimeUTC();
            start(cam)
            count=cam.DiskLoggerFrameCount;
            while count<Frames
                count=cam.DiskLoggerFrameCount;
            end
            aviobj = close(cam.DiskLogger);
            disp('Stack Capture finished')
            stack=aviname;
        end
    catch e
        message=['Problems capturing images: ' e.message];
        disp(message)
        return
    end
    delete(cam)
    
catch e
    disp(e.message)
end