function  data  = load_measurementtype_station(conn, station)

%LOAD_MEASUREMENTTYPE_STATION this function is used for querying all
%                 the measurements types in the station.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: station associated to the measurements.
%
%   Output:
%   data: name of the measurement type.
%
%   Example:
%   data  = load_measurementtype_station(conn, 'CARTAGENA');
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
    
    % query in the database
    
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    try
        query = ['SELECT paramname, sensor FROM measurementtype_' station ' ot JOIN sensor_' station ' WHERE ' ...
            'name = sensor AND ot.station LIKE "' station '"'];
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