function  data  = load_measurementtype_info(conn, station, paramname, sensor)

%LOAD_MEASUREMENTTYPE_INFO this function is used for querying the
%information of a measurement type.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: station associated to the sensor.
%   paramname: parameter name.
%   sensor: Name of the sensor.
%
%   Output:
%   data: cell array with these elements:
%         {paramname, datatype, name, unitx, unity, unitz, axisnamex, axisnamey, axisnamez, description}
%   Example:
%   data  = load_measurementtype_info(conn, 'CARTAGENA', 'tide', 'WTR_SEAGUARD');
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
        query = ['SELECT paramname, datatype, sensor, unitx, unity, ' ...
            'unitz, axisnamex, axisnamey, axisnamez, ot.description  ' ...
            'FROM measurementtype_' station ' ot' ...
            ' WHERE sensor LIKE "' sensor '" AND ' ...
            'ot.station LIKE "' station '" AND paramname LIKE "' paramname '"'];
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