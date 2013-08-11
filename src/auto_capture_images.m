function auto_capture_images(station)
%AUTO_CAPTURE_IMAGES    Executes continously and at certain times, captures
%images and stacks.
%
% Input:
%   station: Name of the station.
%

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2012 HORUS
%   $Date: 2012/08/03 17:27 $

try
    
    % Set HORUS paths
    if ~isdeployed
        root = fileparts(mfilename('fullpath'));
        root = fileparts(root);
        addpath(genpath(root));
    end
    
    % Load default path for rectified images
    if ~exist('path_info.xml', 'file')
        disp('ERROR: The file path_info.xml does not exist!');
        return;
    end
    
    [pathOblique] = load_paths('path_info.xml', station);
    
    % Load capture times from the configuration file
    % This file contains the same configuration from the database, in case that
    % there is no connection with the database and the capture can be carried
    % out.
    xmlfile = 'capture_info.xml';
    
    if ~exist(xmlfile, 'file')
        message = ['Error: The file ' xmlfile ' does not exist!'];
        disp(message);
        return
    end
    
    xml = loadXML(xmlfile, 'Configuration', 'station', station);
    
    xmlPath = strcat('Configuration[station=', station, ']/CaptureConfig/Capture');
    
    captureNodes = getNodes(xml, xmlPath);
    
    captureInfo = struct('id',         [], 'type',       [], 'StartHour',     [], ...
        'StartMinute',[], 'EndHour',    [], 'EndMinute',     [], ...
        'TimeStep',   [], 'CaptureTime',[], 'NumberOfFrames',[], ...
        'Snap',       [], 'Timex',      [], 'Variance',      [], ...
        'ROI',        [], 'Cameras',    []);
    
    xmlPath = strcat('Configuration[station=', station, ']/CameraPerCaptureConfig/CameraPerCapture');
    camPerCaptureNodes = getNodes(xml, xmlPath);
    
    % Load all captures' configuration
    for i = 1:numel(captureNodes)
        captureNode = captureNodes{i};
        
        captureInfo(i).id =           str2double(getAttributeValue(captureNode, 'id'));
        captureInfo(i).type =           getAttributeValue(captureNode, 'type');
        
        captureInfo(i).StartHour =      str2double(getNodeVal(captureNode, 'StartHour'));
        captureInfo(i).StartMinute =    str2double(getNodeVal(captureNode, 'StartMinute'));
        captureInfo(i).EndHour =        str2double(getNodeVal(captureNode, 'EndHour'));
        captureInfo(i).EndMinute =      str2double(getNodeVal(captureNode, 'EndMinute'));
        captureInfo(i).TimeStep =       str2double(getNodeVal(captureNode, 'TimeStep'));
        
        if strcmpi(captureInfo(i).type, 'image')
            snapNode = getNodeVal(captureNode, 'Snap');
            if ~isempty(snapNode)
                captureInfo(i).Snap =     eval(snapNode);
            end
            timexNode = getNodeVal(captureNode, 'Timex');
            if ~isempty(timexNode)
                captureInfo(i).Timex =    eval(timexNode);
            end
            varNode = getNodeVal(captureNode, 'Var');
            if ~isempty(varNode)
                captureInfo(i).Variance = eval(varNode);
            end
            captureInfo(i).CaptureTime =      str2double(getNodeVal(captureNode, 'CaptureTime'));
        else
            XCoords = getNodeVal(captureNode, 'ROI/XCoords');
            YCoords = getNodeVal(captureNode, 'ROI/YCoords');
            
            roi = [];
            partsX = regexp(XCoords, '[ \t]+', 'split');
            partsY = regexp(YCoords, '[ \t]+', 'split');
            
            for k = 1:numel(partsX)
                roi = [roi; str2double(partsX(k)) str2double(partsY(k))];
            end
            
            captureInfo(i).ROI = roi;
            captureInfo(i).NumberOfFrames = str2double(getNodeVal(captureNode, 'NumberOfFrames'));
        end
        
        captureInfo(i).Cameras = cell(0);
        
        % Associate cameras for each capture
        for j = 1:numel(camPerCaptureNodes)
            node = camPerCaptureNodes{j};
            id = str2double(getAttributeValue(node, 'capture'));
            
            if id == captureInfo(i).id
                captureInfo(i).Cameras{end + 1} = getAttributeValue(node, 'camera');
            end
        end
    end
    
    while true
        cur_time = now;
        
        % If current minute is for capturing images
        cur_minute = mod(floor(cur_time * 24 * 60), 24 * 60); % Current minute
        cur_sec = floor(second(cur_time)); % Current second
        
        for i = 1:numel(captureInfo)
            info = captureInfo(i);
            
            % Minute of the day [0..1439] of start and final capture time
            ti_process = info.StartHour * 60 + info.StartMinute; % Init process time (min)
            tf_process = info.EndHour * 60 + info.EndMinute; % End process time (min)
            delta_t = info.TimeStep;
            
            if cur_minute >= ti_process && cur_minute <= tf_process && ...
                    mod(cur_minute - ti_process, delta_t) == 0 && cur_sec == 0
                
                if strcmpi(info.type, 'image')
                    types = cell(0);
                    if info.Snap
                        types{end + 1} = 'snap';
                    end
                    if info.Timex
                        types{end + 1} = 'timex';
                    end
                    if info.Variance
                        types{end + 1} = 'var';
                    end
                    
                    disp([datestr(now) 'Starting image capture...'])
                    HORUSCapture(types, info.CaptureTime, station, info.Cameras, pathOblique)
                    disp([datestr(now) 'Image capture finished.'])
                else
                    disp([datestr(now) 'Starting stack capture...'])
                    HORUSstacks(station, info.Cameras{1}, info.ROI, info.NumberOfFrames, pathOblique);
                    disp([datestr(now) 'Stack capture finished.'])
                end
            end
        end
        
        % Be suspended for 1 second until next iteration
        pause(1)
    end
    
catch e
    disp(e.message)
end