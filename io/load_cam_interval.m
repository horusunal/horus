function  data  = load_cam_interval(conn,station,date_ini,date_fin)

%LOAD_CAM_INTERVAL this function is used for querying all the cameras in a
%time interval.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: station name
%   date_ini: initial time for the search.
%   date_fin: final time for the search.
%
%   Output:
%   data: cell array with the camera ids.
%
%   Example:
%   data  = load_cam_interval(conn, 'CARTAGENA',734248,734249);
%
%   See also LOAD_NEARESTIMAGE, LOAD_IMAGECAM, LOAD_FUSION,
%   LOAD_CALIBRATION, LOAD_roi

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/28 15:00 $

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
        query = ['SELECT DISTINCT camera FROM image_' station ' NATURAL JOIN obliqueimage_' station ' '...
            'WHERE ismini = 0 AND station LIKE "' station '" ' ...
            'AND timestamp BETWEEN ' num2str(date_ini - EPS,17) ' AND ' ...
            num2str(date_fin + EPS,17) ' ORDER BY camera'];
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