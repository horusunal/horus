function  data  = load_common_points(conn, station, camera, fusiontype, timestamp)

%LOAD_COMMON_POINTS  Loads common points used for generating a fusion.
%These points are loaded with the nearest fusion before timestamp.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: station name.
%   camera: camera id.
%   fusiontype: May be 'oblique' or 'rectified'.
%   timestamp: Value of the timestamp for the search (DATENUM).
%
%   Output:
%   data: matrix {name, u, v} of size mx3
%
%   Example:
%   data  = load_common_points(conn, 'CARTAGENA', 'C1', 734229.4583333334);
%

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2012 HORUS
%   $Date: 2012/07/03 11:41 $

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
        query = ['SELECT name, u, v '...
            'FROM commonpoint_' lower(station) ' '...
            'WHERE camera LIKE "' camera '" AND station LIKE "' station '" '...
            'AND idfusion = '...
            '(SELECT id '...
            'FROM fusion_' lower(station) ' '...
            'WHERE type LIKE "' fusiontype '" '...
            'AND timestamp <= ' num2str(timestamp + EPS,17)...
            ' ORDER BY timestamp DESC LIMIT 0,1)'];
        
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

end