function auto_synchronization(station)
%AUTO_SYNCHRONIZATION    Executes continously and at certain times,
%synchronizes local and central databases
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
%   $Date: 2012/08/12 19:04 $

try
    
    % Set HORUS paths
    if ~isdeployed
        root = fileparts(mfilename('fullpath'));
        root = fileparts(root);
        addpath(genpath(root));
        datapath = fullfile(root, 'data');
    else
        pathinfo = what('data');
        datapath = pathinfo.path;
    end

    xmlfile = 'sync_info.xml';
    
    if ~exist(xmlfile, 'file')
        message = ['Error: The file ' xmlfile ' does not exist!'];
        disp(message);
        return
    end
    
    xml = loadXML(xmlfile, 'Configuration', 'station', station);
    xmlPath = strcat('Configuration[station=', station, ']/SyncConfig');
    
    syncNode = getNodes(xml, xmlPath);
    
    % Something is wrong with the XML file
    if isempty(syncNode)
        disp('Error: Invalid configuration!')
        return
    end
    
    syncNode = syncNode{1};
    
    % Synchronization parameters
    startHour = str2double(getNodeVal(syncNode, 'StartHour'));
    startMinute = str2double(getNodeVal(syncNode, 'StartMinute'));
    endHour = str2double(getNodeVal(syncNode, 'EndHour'));
    endMinute = str2double(getNodeVal(syncNode, 'EndMinute'));
    timeStep = str2double(getNodeVal(syncNode, 'TimeStep'));
    hostLocal = getNodeVal(syncNode, 'HostLocal');
    userLocal = getNodeVal(syncNode, 'UserLocal');
    passLocal = getNodeVal(syncNode, 'PassLocal');
    dbNameLocal = getNodeVal(syncNode, 'DBNameLocal');
    portLocal = getNodeVal(syncNode, 'PortLocal');
    hostRemote = getNodeVal(syncNode, 'HostRemote');
    userRemote = getNodeVal(syncNode, 'UserRemote');
    passRemote = getNodeVal(syncNode, 'PassRemote');
    dbNameRemote = getNodeVal(syncNode, 'DBNameRemote');
    portRemote = getNodeVal(syncNode, 'PortRemote');
    
    % Decrypt passwords
    passLocal = decrypt_aes(passLocal, datapath);
    passRemote = decrypt_aes(passRemote, datapath);

    ti_sync = startHour * 60 + startMinute; % Init process time (min)
    tf_sync = endHour * 60 + endMinute; % End process time (min)
    delta_t = timeStep;

    % Infinite loop for running as a daemon
    while true
        cur_time = now;
        
        % If current minute is for processing images
        cur_minute = mod(floor(cur_time * 24 * 60), 24 * 60); % Current minute
        cur_sec = floor(second(cur_time)); % Current second
        
        if cur_minute >= ti_sync && cur_minute <= tf_sync && ...
                mod(cur_minute - ti_sync, delta_t) == 0 && cur_sec == 0
            command = ['python "' fullfile(pwd, 'src', 'sync_databases.py') '" '...
                station ' ' hostLocal ' ' userLocal ' ' passLocal ' ' ...
                dbNameLocal ' ' portLocal ' ' hostRemote ' ' userRemote ' ' ...
                passRemote ' ' dbNameRemote ' ' portRemote];
            
            status = dos(command);
            if status == 1
                disp('There was a problem with synchronization!')
            end
        end
        
        % Be suspended for 1 second until next iteration
        pause(1)
    end
    
catch e
    disp(e.message)
end