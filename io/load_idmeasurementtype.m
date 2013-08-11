function  data  = load_idmeasurementtype(conn, station, paramname, sensor)

%LOAD_IDMEASUREMENTTYPE this function is used for querying the id of an
%measurement type.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: station where is the sensor associated to the
%   measurement type.
%   paramname: Name of the parameter to search.
%   sensor: Name of the sensor.
% 
%   Output:
%   data: Id of the measurement type.
%
%   Example:
%   data  = load_idmeasurementtype(conn, 'CARTAGENA', 'tide', 'WTR_SEAGUARD');
%
%   See also LOAD_ALLIMAGE, LOAD_NEARESTIMAGE, LOAD_IMAGECAM, LOAD_FUSION,
%   LOAD_CALIBRATION

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/22 11:00 $

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
        query = ['SELECT id '...
            'FROM measurementtype_' station ' AS ot WHERE '...
            'sensor LIKE "' sensor '" AND ' ...
            'ot.station LIKE "' station '" '...
            'AND paramname LIKE "' paramname '"'];
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