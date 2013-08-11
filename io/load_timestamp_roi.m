function  data  = load_timestamp_roi(conn,station,camera,timestampCal, type)

%LOAD_TIMESTAMP_roi this function is used for querying the roi timestamp
%associated with a calibration.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: station name.
%   camera: camera id.
%   timestampCal: calibration timestamp.
%   type: roi type, can be: 'fusion', 'rect', 'stack', 'user'.
%
%   Output:
%   data: cell array with the roi timestamps
%
%   Example:
%   data  = load_timestamp_roi(conn, 'CARTAGENA','C2',734598,'user');
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
        query = ['SELECT DISTINCT(r.timestamp) FROM roi_' station ' r JOIN calibration_' station ' c' ...
            ' WHERE c.idcalibration = r.idcalibration' ...
            ' AND station LIKE "' station '" AND camera LIKE "' camera ...
            '" AND type LIKE "' type '" AND ABS(c.timestamp - ' ...
            mat2str(timestampCal) ') <= ' num2str(EPS) ' ORDER BY r.timestamp'];
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