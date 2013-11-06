function  data  = load_sensor_info(conn, station, sensor)

%LOAD_SENSOR_INFO this function is used for querying the sensor information.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: station associated to the sensor.
%   sensor: Name of the sensor.
%
%   Output:
%   data: cell array with these elements:
%         {name, station, x, y, z, isvirtual, description}
%
%   Example:
%   data  = load_sensor_info(conn, 'CARTAGENA','sensor_tide');
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
    data=[];
    
    % query in the database
    
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    try
        query = ['SELECT name, station, x, y , z, isvirtual, description ' ...
            'FROM sensor_' lower(station) ' WHERE station LIKE "' station '" AND name LIKE "' sensor '"'];
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