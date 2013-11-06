function  data  = load_idcalibration(conn, station, camera, timestamp)

%LOAD_IDCALIBRATION this function is used for querying the nearest
%calibration id for a station and a camera, before a timestamp.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: station associated to the calibration.
%   camera: camera associated to the calibration.
%   timestamp: Value of the timestamp for the search.
%
%   Output:
%   data: calibration id.
%
%   Example:
%   data  = load_idcalibration(conn, 'CARTAGENA', 'C1', 734229.4583333334);
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
    EPS = 1 / (24 * 60 * 60);
    
    % query in the database
    
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    try
        query = ['SELECT idcalibration '...
            'FROM calibration_' lower(station) ' WHERE '...
            'station LIKE "' station '" '...
            'AND camera LIKE "' camera '" '...
            'AND timestamp <= ' num2str(timestamp + EPS,17) ...
            ' ORDER BY timestamp DESC LIMIT 0,1 '];
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