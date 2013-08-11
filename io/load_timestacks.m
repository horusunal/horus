function data = load_timestacks(conn, station, camera, initialtime, finaltime)

%LOAD_TIMESTACKS   Timestacks in a time interval.
%   data = LOAD_TIMESTACKS(conn, station, camera, initialtime, finaltime) returns
%   all the timestacks whose initial times are found within a given
%   interval, for a camera and a station.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: is the name of the station.
%   camera: the name of the camera.
%   initialtime: is the lower bound of the time interval.
%   finaltime: is the upper bound of the time interval.
%
%   Output:
%   data: is a cell matrix, where every row contains the following fields:
%   - filename: The name of the file.
%   - path: The absolute path of the directory that contains the
%   timestack in the hard disk or a network.
%   - fps: Frames per second of the video.
%   - numFrames: The total amount of frames the video contains.
%
%   The video duration is given by the formula: numFrames / fps (seconds)
%
%   Example:
%   data = load_timestacks(conn, 'CARTAGENA', 'C2', 734598.708333333, 734658.708333333);

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/22 09:33 $

try
    station = upper(station);
    data = [];
    EPS = 1 / (24 * 60 * 60);
    
    % query in the database
    
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    try
        % Query for retrieving all the timestacks between initialtime and
        % finaltime for a camera in a station
        
        tistr = num2str(initialtime - EPS);
        tfstr = num2str(finaltime + EPS);
        
        query = ['SELECT filename, path, fps, numFrames '...
            'FROM timestack_' station ' ' ...
            'WHERE camera LIKE "' camera '" AND station LIKE "' station '" AND inittime '...
            'BETWEEN ' tistr ' AND ' tfstr];
        cursor = exec(conn, query);
        cursor = fetch(cursor);
        
        if strcmpi(cursor.Data{1,1}, 'No Data') || isfloat(cursor.Data)
            data = [];
            return;
        end
        
        data = get(cursor, 'Data');
        
    catch e
        disp([dberror('select') e.message]);
    end
    
catch e
    disp(e.message)
end