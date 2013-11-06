function  data  = load_timestamp_calibration(conn, station, camera)

%LOAD_TIMESTAMP_CALIBRATION this function is used for querying the
%timestamps for the calibrations given a station and a camera.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: station name.
%   camera: camera id.
%
%   Output:
%   data: Cell array with the timestamps.
%
%   Example:
%   data  = load_timestamp_calibration(conn, 'CARTAGENA','C1');
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
        query = ['SELECT DISTINCT(timestamp) FROM calibration_' lower(station) ' WHERE station LIKE "' station '" AND camera LIKE "' camera '" ORDER BY timestamp'];
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