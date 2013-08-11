function  data  = load_calibration_times(conn, station, camera)

%LOAD_CALIBRATION_TIMES  Loads timestamps for all calibrations associated
%to a camera in a station.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: station name.
%   camera: camera id.
%
%   Output:
%   data: cell array with the timestamps
%
%   Example:
%   data  = load_calibration_times(conn, 'CARTAGENA', 'C1');
%

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2012 HORUS
%   $Date: 2012/07/04 18:08 $

try
    station = upper(station);
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    try
        query = ['SELECT DISTINCT(timestamp) '...
            'FROM calibration_' station ' '...
            'WHERE camera LIKE "' camera '" AND station LIKE "' station '"'];
        
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