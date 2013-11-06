function [varargout] = insert_stack_by_file(conn, station_db, root, filename, path)

%INSERT_STACK_BY_FILE   Inserts a stack into the database given the
%filename. This filename is split up into pieces that correspond to the
%stack information.
%
% Requirements: - The stack format must conform to HORUS stack format:
%      YY.MM.DD.HH.mm.SS.GMT.station.camera.STACK.X.Y.widthXheight.HORUS.avi
%
% Input:
%   'conn' is the object that contains the database connection.
%	'station_db' is the name of the station.
%   'root' is the directory where the stack directorie structure is located.
%   'filename' is the name of the image file
%       (e.g. 11.09.23.12.00.00.GMT.CARTAGENA.C1.STACK.500.0.20X768.HORUS.avi)
%   'path' is the stack's directory
%
%
% Output:
%   'varargout': The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the insertion was
%   successful, 1 otherwise.

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/10/28 09:54 $

try
    station_db = upper(station_db);
    if nargout==1
        varargout(1)={1}; % Initially, failure
    end

    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    % Split the filename
    parts = regexp(filename, '\.', 'split');
    
    % image time
    inittime = datenum(filename(1:17), 'yy.mm.dd.HH.MM.ss');
    camera = parts{9};
    station = upper(parts{8}); % station names should be uppercase
    
    video = mmreader(fullfile(root, path, filename));
    fps = video.frameRate;
    numFrames = video.NumberofFrames;
    
    %   name of the parameter table parameters
    colnames = {'filename', 'camera','station', 'inittime', 'path', 'fps', 'numFrames'};
    %   data to insert
    data = {filename,camera,station,inittime,path, fps, numFrames};
    try
        fastinsert(conn, ['timestack_' lower(station_db)],colnames,data);
        if nargout==1
            varargout(1)={0}; % Success
        end
        
    catch e
        disp([dberror('insert') e.message]);
    end
    
catch e
    disp(e.message)
end