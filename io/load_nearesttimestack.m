function data = load_nearesttimestack(conn, station, camera, timestamp, error)

%LOAD_NEARESTTIMESTACK   Timestack whose inittime is the nearest to a time.
%   data = LOAD_NEARESTTIMESTACK(conn, station, camera, timestamp, error) returns
%   timestack whose inittime is the nearest under or above a given
%   timestamp and within a time error margin.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: is the name of the station.
%   camera: the name of the camera.
%   timestamp: is the time for which we want to find the nearest
%   timestack, given in datenum format.
%   error: is the time error.
%
%   Output:
%   data: is a cell matrix, where every row contains the following fields:
%
%   - path: The absolute path of the directory that contains the
%   timestack in the hard disk or a network.
%   - filename: The name of the file.
%   - fps: Frames per second of the video.
%   - numFrames: The total amount of frames the video contains.
%
%   The video duration is given by the formula: numFrames / fps (seconds)
%
%   Example:
%   data = load_nearesttimestack(conn, 'CARTAGENA', 'C2', 734598.708333333, 3/24*3600)

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/22 09:21 $

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
        % Query for retrieving the timestack nearest to a specified time within
        % an error margin for a camera in a station
        
        tstr = num2str(timestamp);
        tistr = num2str(timestamp - error - EPS);
        tfstr = num2str(timestamp + error + EPS);
        
        query = ['SELECT filename, path, fps, numFrames '...
            'FROM timestack_' station ' '...
            'WHERE camera LIKE "' camera '" AND station LIKE "' station '" '...
            'AND inittime BETWEEN ' tistr ' AND ' tfstr ' '...
            'ORDER BY (ABS(inittime - ' tstr ')) LIMIT 1'];
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