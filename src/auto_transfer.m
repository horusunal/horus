function auto_transfer(station, host)
%AUTO_TRANSFER    Executes continously and at certain times,
%transfer captured images via SFTP.
%
% Input:
%   station: Name of the station.
%   host: IP address or host name of the SFTP server.
%

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2012 HORUS
%   $Date: 2012/08/04 12:01 $

try
    % Set HORUS paths
    if ~isdeployed
        root = fileparts(mfilename('fullpath'));
        root = fileparts(root);
        addpath(genpath(root));
    end
    
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
    
    xmlPath = strcat('Configuration[station=', station, ']/CaptureConfig/Transfer[FTPHost=', host, ']');
    
    transferNodes = getNodes(xml, xmlPath);
    
    if isempty(transferNodes)
        disp('No transfer information was found!')
        return
    end
    
    transferNode = transferNodes{1};
    
    startHour = str2double(getNodeVal(transferNode, 'StartHour'));
    startMinute = str2double(getNodeVal(transferNode, 'StartMinute'));
    endHour = str2double(getNodeVal(transferNode, 'EndHour'));
    endMinute = str2double(getNodeVal(transferNode, 'EndMinute'));
    timeStep = str2double(getNodeVal(transferNode, 'TimeStep'));
    
    cameras = cell(0);
    
    xmlPath = strcat('Configuration[station=', station, ']/CameraConfig/Camera');
    
    cameraNodes = getNodes(xml, xmlPath);
    
    if isempty(cameraNodes)
        disp('No cameras were found!')
        return
    end
    
    for i = 1:numel(cameraNodes)
        cameras{i} = getAttributeValue(cameraNodes{i}, 'id');
    end
    
    while true
        cur_time = now;
        
        % If current minute is for capturing images
        cur_minute = mod(floor(cur_time * 24 * 60), 24 * 60); % Current minute
        cur_sec = floor(second(cur_time)); % Current second
        
        % Minute of the day [0..1439] of start and final capture time
        ti_process = startHour * 60 + startMinute; % Init process time (min)
        tf_process = endHour * 60 + endMinute; % End process time (min)
        delta_t = timeStep;
        
        try
            if cur_minute >= ti_process && cur_minute <= tf_process && ...
                    mod(cur_minute - ti_process, delta_t) == 0 && cur_sec == 0
                
                senddata(station, cameras, host, 'image', ti_process, tf_process)
                
                % Insert captured images into the database
                insert_captured_images(station, cameras)
                
            elseif (cur_minute > tf_process || cur_minute < ti_process)
                senddata(station, cameras, host, 'stack', ti_process, tf_process)
                
                % Insert captured stack into the database
                insert_captured_stacks(station, cameras)
            end
        catch e
            disp(e.message);
            continue;
        end
        
        % Be suspended for 1 second until next iteration
        pause(1)
    end
    
catch e
    disp(e.message)
end