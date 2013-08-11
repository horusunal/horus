function insert_captured_stacks(station, cameras)
%INSERT_CAPTURED_STACKS   Inserts captured stacks into the database.
%
% Input:
%   station: name of the station (e.g. 'CARTAGENA')
%   cameras: List of the cameras as a cell array.
%
% Example:
%   insert_captured_stacks('CARTAGENA', {'C1'})

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2012 HORUS
%   $Date: 2012/08/04 12:27 $

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
    
    % Create a database connection
    try
        conn = connection_db(false);
    catch e
        disp(e.message)
        return
    end
    
    pathSendError = fullfile(tmppath, 'DATASENDERRORS.mat');
    
    numStacks = 0;
    for i = 1:numel(cameras)
        cam = cameras{i};
        pathList = fullfile(tmppath, ['ListStack' cam '.mat']);
        if exist(pathList, 'file')
            load(pathList);
            ind1 = find(cell2mat(ListStack(:, 5)) == 1); %Number of stacks to insert for cam1
            numStacks = max(numStacks, length(ind1));
        end
    end
    
    for j = 1:numStacks %Repeat the transfer for all stacks
        for i = 1:numel(cameras)
            cam = cameras{i};
            pathList = fullfile(tmppath, ['ListStack' cam '.mat']);
            if exist(pathList, 'file')
                load(pathList);
            else
                continue
            end
            
            ind = find(cell2mat(ListStack(:, 5)) == 1);
            if isempty(ind)
                continue
            end
            posI = min(ind);
            if isempty(posI)
                continue
            end
            
            disp(['Saving stack ' ListStack{posI, 2} ' in the database'])
            stack = ListStack{posI, 2};
            textDate = stack(1:8);
            textDate = datestr(datenum(textDate, 'yy.mm.dd'), 'yyyy.mm.dd');
            textDate = strrep(textDate, '.', filesep);
            pathstack = [station filesep textDate filesep cam];
            
            timestamp = datenum(stack(1:17), 'yy.mm.dd.HH.MM.ss');
            
            fps = ListStack{posI, 3};
            numFrames = ListStack{posI, 4};
            
            status = insert_timestack(conn, stack, cam, station, timestamp, pathstack, fps, numFrames );
            
            if status == 0
                disp([ListStack{posI,2} ' stack saved'])
                try
                    % Put a 2 on the List of stacks
                    ListStack{posI, 5} = 2;
                    
                    ind = find(cell2mat(ListStack(:, 5)) ~= 2); %Number of stacks to insert for cam
                    delete(pathList)
                    if ~isempty(ind)
                        ListStack = ListStack(ind, :);
                        save(pathList, 'ListStack');
                    end
                catch ME
                    message=ME.message;
                    error(1,1:2)={datestr(now), message};
                    
                    if ~exist(pathSendError, 'file')
                        Errors = cell(0);
                    else
                        load(pathSendError);
                    end
                    
                    Errors(end+1, :) = error;
                    
                    save(pathSendError, 'Errors');
                end
            else
                disp([ListStack{posI,2} ' could not be saved'])
            end
        end
    end
    
catch e
    disp(e.message)
end