function  data  = load_station_info(conn, name)

%LOAD_STATION_INFO this function is used for querying the information of the stations.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   name: station name.
%
%   Output:
%   data: cell array with these elements:
%         {name, elevation, lat, lon, country, state, city, responsible, description}
%
%   Example:
%   data  = load_station_info(conn, 'CARTAGENA');
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
    name = upper(name);
    data = [];
    
    % query in the database
    
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    try
        query = ['SELECT name, alias, elevation, lat, lon, country, state, city,' ...
            'responsible, description FROM station WHERE name LIKE "' name '"'];
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