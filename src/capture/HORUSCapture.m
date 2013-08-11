function HORUSCapture(types,TTime,site,Cams,path)

% HORUSCapture(TTime,site,Cams,path)
% This function allows to capture a set of snap, timex and variance images
% for one or more cameras during a given time using the largest capture
% frequency possible. To use this function it is necessary to have
% installed the AVTMatlabAdaptor 2.0 or higher.
%
% Inputs:
%   types: image types to be captured, the three possible types are 'snap',
%   'timex' and 'var'. Use a cell array to introduce the types needed or
%   just use 'all' to use the 3 types.
%   TTime: total time of the capture in seconds. Depending on the number
%   and type of cameras used, the resulting capturing time will be slightly
%   higher.
%   site: Site name, for example 'TEST'
%   Cams: cell array with the camera names in the order they will be used.
%   For example: {'C1','C2'}
%   path: Path of the image storing folder, for example: 'D:\DBImage'
%
%   Developed by Juan camilo P�rez Mu�oz (2011) for the HORUS project.

try
    
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
    
    xml = loadXML(xmlfile, 'Configuration', 'station', site);
    
    
    clearvars -global
    imaqreset
    
    if ischar(types)
        types = eval(types);
    end
    if ischar(Cams)
        Cams = eval(Cams);
    end
    imaqreset
    if ischar(TTime)
        TTime=str2double(TTime);
    end
    
    %% Select the image types to use
    TypeSnap=0;
    TypeTimex=0;
    TypeVar=0;
    if ~iscell(types)
        switch lower(types)
            case 'snap'
                TypeSnap=1;
            case 'timex'
                TypeTimex=1;
            case 'var'
                TypeVar=1;
            case 'all'
                TypeSnap=1;
                TypeTimex=1;
                TypeVar=1;
        end
    else
        for ik=1:length(types)
            if strcmpi(types{ik},'snap')
                TypeSnap=1;
            elseif strcmpi(types{ik},'timex')
                TypeTimex=1;
            elseif strcmpi(types{ik},'var')
                TypeVar=1;
            elseif strcmpi(types{ik},'all')
                TypeSnap=1;
                TypeTimex=1;
                TypeVar=1;
            end
        end
    end
    imaqreset
    
    %% Set the WhiteBalance, Gain and Shutter of each camera %%%
    for i=1:length(Cams)
        xmlPath = strcat('Configuration[station=', site,...
            ']/CameraConfig/Camera[id=', Cams{i}, ']');
        
        cameraNode = getNodes(xml, xmlPath);
        
        if isempty(cameraNode)
            message = ['Error: The camera ' Cams{i} ' was not found!'];
            disp(message);
            continue
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
        
        parts = regexp(fr, '/', 'split');
        if numel(parts) == 1
            nfr = str2double(fr);
        else
            nfr = str2double(parts{1}) / str2double(parts{2});
        end
        
        disp([AdaptorName ' Device ' mat2str(DeviceID) ' ' DeviceFormat])
        try
            cam=videoinput(AdaptorName,DeviceID,DeviceFormat);
        catch ME
            message=[ME.message ' ' Cams{i}];
            imageerror(message)
            continue
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
        elseif  isfield(sourcet,'WhiteBalanceMode')
            set(source,'WhiteBalanceMode',wb)
        end
        if exist('AOI','var') && isfield(sourcet, 'AutoFunctionAOIMode')
            if ~strcmpi(AOI.mode, 'none')
                set(source,'AutoFunctionAOIMode',AOI.mode)
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
        set(cam,'FramesPerTrigger',25)
        start(cam)
        wait(cam,max(20,50/nfr+2))
        I=getdata(cam,1,'uint8');
        flushdata(cam)
        delete(cam)
        
        %%%% Prepare the videos %%%%
        writerObj{i} = VideoWriter(['CAM' mat2str(i) '.avi'],'Uncompressed AVI');
        writerObj{i}.FrameRate=1;
        open(writerObj{i});
        writeVideo(writerObj{i},I);
        %%%%%%%%%%%
        
        % Save the Devices and Formats
        DeviceFormats{i}=DeviceFormat;
        DeviceIDs{i}=DeviceID;
        AdaptorNames{i}=AdaptorName;
        if ~isempty(strfind(DeviceFormats{i},'RGB'))
            Formats{i}='RGB';
        elseif ~isempty(strfind(DeviceFormats{i},'YUV'))
            Formats{i}='YUV';
        elseif ~isempty(strfind(DeviceFormats{i},'I420'))
            Formats{i}='YUV';
        elseif ~isempty(strfind(DeviceFormats{i},'Y422'))
            Formats{i}='YUV';
        elseif ~isempty(strfind(DeviceFormats{i},'YUY'))
            Formats{i}='YUV';
        else
            Formats{i}='none';
        end
    end
    
    
    %% Capture the videos
    %Maximum Frame Number depends on the camera number and the capture time
    NFrames=TTime/(length(Cams)*0.05); %
    D=struct('time',[]);
    disp('Capture started')
    TimeIni=getTimeUTC();
    tic
    for j=1:NFrames
        for i=1:length(Cams)
            try
                cam=videoinput(AdaptorNames{i},DeviceIDs{i},DeviceFormats{i});
            catch ME
                message=[ME.message ' ' Cams{i}];
                imageerror(message)
                continue
            end
            
            set(cam,'FramesPerTrigger',1)
            try
                start(cam)
                wait(cam,5)
                I=getdata(cam,1,'uint8');
            catch ME
                message=[ME.message ' ' Cams{i}];
                imageerror(message)
                return
            end
            writeVideo(writerObj{i},I);
            D(i,j).time=toc;
            delete(cam)
        end
        if toc>=TTime
            NFrames=j;
            break
        end
    end
    
    for i=1:length(Cams)
        close(writerObj{i});
    end
    % The capture was done, now we need to process the videos
    disp('Capture Finished, processing started')
    
    for i=1:length(Cams)
        
        % Analize the capture frequency
        DT=diff([D(i,:).time]);
        Fr=round(100/mean(DT))/100;
        
        % Create the video object
        VidObj = VideoReader(['CAM' mat2str(i) '.avi']);
        vidHeight = VidObj.Height;
        vidWidth = VidObj.Width;
        nFrames = VidObj.NumberOfFrames;
        
        % initialize the timex, var and snap images
        switch VidObj.VideoFormat
            case {'RGB24','RGB24 Signed','RGB48','RGB48 Signed'}
                timex=zeros(vidHeight,vidWidth,3);
            case {'Mono8','Mono8 Signed','Mono16','Mono16 Signed'}
                timex=zeros(vidHeight,vidWidth,1);
        end
        var=zeros(size(timex));
        snap=zeros(size(timex));
        Q=zeros(size(timex));
        
        
        % Read one frame at a time.
        FramesAdq=0;
        for k = 2 : nFrames
            switch Formats{i}
                case 'RGB'
                    FrameN=double(read(VidObj, k));
                case 'YUV'
                    FrameN=double(ycbcr2rgb(read(VidObj, k)));
                otherwise
                    FrameN=double(read(VidObj, k));
            end
            FramesAdq=FramesAdq+1;
            
            Q=Q+((FramesAdq-1)/FramesAdq).*(FrameN-timex).^2; %Running std deviation
            
            timex=timex+(FrameN-timex)/FramesAdq; %Running mean
        end
        
        %%% Obtain the images
        switch Formats{i}
            case 'RGB'
                snap=read(VidObj, 2);
            case 'YUV'
                snap=ycbcr2rgb(read(VidObj, 2));
            otherwise
                snap=read(VidObj, 2);
        end
        timex=uint8(timex);
        var=uint8((Q/FramesAdq).^0.5);
        
        
        %%% Save the files %%
        
        NameIni=[datestr(TimeIni,'yy.mm.dd.HH.MM.SS') '.GMT.' upper(site) '.' ...
            Cams{i} '.TYPE.' mat2str(size(snap,2)) 'X' mat2str(size(snap,1)) ...
            '.HORUS.jpg'];
        disp('Image created:')
        disp(NameIni)
        disp(['Frames captured: ' mat2str(nFrames-1)])
        disp(['Capturing frequency: ' mat2str(Fr) ' Hz'])
        if ~exist(path, 'dir')
            mkdir(path)
        end
        pathI=fullfile(path, site, datestr(TimeIni,'yyyy'), ...
            datestr(TimeIni,'mm'), datestr(TimeIni,'dd'), Cams{i});
        if ~exist(pathI, 'dir')
            mkdir(pathI)
        end
        if TypeSnap==1
            imwrite(snap,fullfile(pathI,strrep(NameIni,'TYPE','Snap')),'JPG',...
                'Quality',100,'Mode','lossy','Comment',...
                char('Capture frequency (Hz)', mat2str(Fr),...
                'Number of Frames used',mat2str(nFrames-1)))
        end
        if TypeTimex==1
            imwrite(timex,fullfile(pathI,strrep(NameIni,'TYPE','Timex')),'JPG',...
                'Quality',100,'Mode','lossy','Comment',...
                char('Capture frequency (Hz)', mat2str(Fr),...
                'Number of Frames used',mat2str(nFrames-1)))
        end
        if TypeVar==1
            imwrite(var,fullfile(pathI,strrep(NameIni,'TYPE','Var')),'JPG',...
                'Quality',100,'Mode','lossy','Comment',...
                char('Capture frequency (Hz)', mat2str(Fr),...
                'Number of Frames used',mat2str(nFrames-1)))
        end
        
        if isdeployed
            pathinfo = what('tmp');
            tmppath = pathinfo.path;
        else
            tmppath = fullfile(root, 'tmp');
        end
        
        pathList=fullfile(tmppath, ['ListImage' Cams{i} '.mat']);
        
        if exist(pathList, 'file')
            load(pathList);
        else
            ListImage = cell(0);
        end
        
        if TypeSnap==1
            ListImage(end+1,1:3)={pathI strrep(NameIni,'TYPE','Snap') 0};
        end
        if TypeTimex==1
            ListImage(end+1,1:3)={pathI strrep(NameIni,'TYPE','Timex') 0};
        end
        if TypeVar==1
            ListImage(end+1,1:3)={pathI strrep(NameIni,'TYPE','Var') 0};
        end
        
        save(pathList, 'ListImage');
    end
    
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Saves error in MAT file.
% Input:
%   message: Message string
function imageerror(message)
try
    
    root = fileparts(mfilename('fullpath'));
    root = fileparts(root);
    root = fileparts(root);
    
    if isdeployed
        pathinfo = what('tmp');
        tmppath = pathinfo.path;
    else
        tmppath = fullfile(root, 'tmp');
    end
    
    pathError=fullfile(tmppath, 'IMAGEERRORS.mat');
    disp(message)
    error(1,1:2)={datestr(now), message};
    
    if ~exist(pathError, 'file')
        Errors = cell(0);
    else
        load(pathError);
    end
    
    Errors(end+1, :) = error;
    
    save(pathError, 'Errors');
    
catch e
    disp(e.message)
end