function HORUSstacks(site,CamName,roipos,Frames,path)
%
% HORUSstacks(site,CamName,roipos,Frames,path,GMT)
% Function to capture stacks and generate the data base used for the data
% transmission of the video files. To use this function it is necessary to
% have installed the AVTMatlabAdaptor 2.0 or higher.
% Inputs:
%   site: Site name, for example 'TEST'
%   CamName: Camera name (Configuration file CamName.mat)
%   roipos: Region of interest (set of vertices of a polygon as a matrix of nx2)
%   Frames: Total number of frames required, the time of the capture
%   process is defined by Frames/FR, where FR is the frame rate defined
%   in the camera configuration.
%   Path: Path of the image folder in the PC
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
    
    if isdeployed
        pathinfo = what('tmp');
        tmppath = pathinfo.path;
    else
        tmppath = fullfile(root, 'tmp');
    end
    
    clearvars -global
    if ischar(roipos)
        roipos=str2double(roipos);
    end
    if ischar(Frames)
        Frames=str2double(Frames);
    end
    
    xmlfile = 'capture_info.xml';
    
    if ~exist(xmlfile, 'file')
        message = ['Error: The file ' xmlfile ' does not exist!'];
        disp(message);
        return
    end
    
    xml = loadXML(xmlfile, 'Configuration', 'station', site);
    
    xmlPath = strcat('Configuration[station=', site,...
        ']/CameraConfig/Camera[id=', CamName, ']');
    
    cameraNode = getNodes(xml, xmlPath);
    
    if isempty(cameraNode)
        message = ['Error: The camera ' CamName ' was not found!'];
        disp(message);
        return
    end
    
    cameraNode = cameraNode{1};
    
    fr = getNodeVal(cameraNode, 'FrameRate');
    
    parts = regexp(fr, '/', 'split');
    if numel(parts) == 1
        nfr = str2double(fr);
    else
        nfr = str2double(parts{1}) / str2double(parts{2});
    end
    
    minu = min(roipos(:, 1));
    maxu = max(roipos(:, 1));
    minv = min(roipos(:, 2));
    maxv = max(roipos(:, 2));
    width = maxu - minu + 1;
    height = maxv - minv + 1;
    roirect = [minu minv width height];
    
    [stack TimeIni message]=getstack(site, CamName,roirect,Frames);
    if ~isempty(message)
        
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
        return
    end
    
    % Change stack in order to adapt it to the specified ROI
    xv = roipos(:, 1);
    yv = roipos(:, 2);
    xv = [xv; xv(1)];
    yv = [yv; yv(1)];
    [x y] = meshgrid(min(xv):max(xv), min(yv):max(yv));
    mask = uint8(inpolygon(x, y, xv, yv));
    
    % Make a copy of video
    stacktmp = ['#' stack];
    copyfile(stack, stacktmp);
    
    aviobj = avifile(stack,'compression','none','fps', nfr);
    
    obj = mmreader(stacktmp);
    for i = 1:Frames
        im = read(obj, i);
        im(:, :, 1) = im(:, :, 1) .* mask; % R
        im(:, :, 2) = im(:, :, 2) .* mask; % G
        im(:, :, 3) = im(:, :, 3) .* mask; % B
        aviobj = addframe(aviobj, im);
    end
    aviobj = close(aviobj);
    
    delete(stacktmp);
    
    NameIni=strrep(stack,'SITE',upper(site));
    NameIni=strrep(NameIni,'TIME',datestr(TimeIni,'yy.mm.dd.HH.MM.SS'));
    disp('Obtained TimeStack: ')
    disp(NameIni)
    if ~exist(path, 'dir')
        mkdir(path)
    end
    pathI=fullfile(path, site, datestr(TimeIni,'yyyy'), ...
        datestr(TimeIni,'mm'), datestr(TimeIni,'dd'), CamName);
    if ~exist(pathI, 'dir')
        mkdir(pathI)
    end
    [status,message,messageid]=movefile(stack,fullfile(pathI,NameIni),'f');
    
    pathList=fullfile(tmppath, ['ListStack' CamName '.mat']);
    
    if exist(pathList, 'file')
        load(pathList);
    else
        ListStack = cell(0);
    end
    
    ListStack(end+1,1:5)={pathI NameIni nfr Frames 0};
    
    
    save(pathList, 'ListStack');
    
catch e
    disp(e.message)
end
