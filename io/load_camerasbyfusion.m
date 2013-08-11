function data = load_camerasbyfusion(conn, station, type, timestamp)

%LOAD_CAMERASBYFUSION   cameras by fusion.
%   data = LOAD_CAMERASBYFUSION(conn, station, type, timestamp) returns the
%   names of the cameras that participate in a fusion.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: is the name of the station.
%   type: is the type of fusion ('rectified' or 'oblique').
%   timestamp: is the upper bound for the search time in the format of
%   datenum. The fusion time will correspond to the greatest time less
%   than or equal to 'timestamp'.
%
%   Output:
%   data: is a cell array that contains the names of the cameras sorted.
%
%   Example:
%   load_camerasbyfusion(conn, 'CARTAGENA', 'oblique', 734248)

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/22 09:13 $

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
        % Query for retrieving the cameras that participate in a fusion, sorted
        % by sequence
        
        query = ['SELECT camera FROM camerabyfusion_' station ' WHERE station LIKE "' station ...
            '" AND idfusion = (SELECT id FROM fusion_' station ' WHERE type LIKE "' ...
            type '" AND timestamp <= ' num2str(timestamp + EPS) ...
            ' ORDER BY ABS(timestamp - ' num2str(timestamp) ') LIMIT 1) ORDER BY sequence'];
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