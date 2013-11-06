function  data  = load_roi(conn, type, camera, station, timestampcal,timestamproi)

%LOAD_roi this function is used for querying the roi information.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   type: It's the type of roi or type of application of a particular roi.
%         The values you can take are: fusion, rect, stack, user.
%   camera: Represents the camera associated to the roi.
%   station: station associated to the roi.
%   timestampcal: Value of the timestamp of the calibration for the search.
%   timestamproi: Value of the timestamp of the roi for the search.
%
%   Output:
%   data: cell array with these elements:
%         {roi id, coordinate id, timestamp, u, v}
%
%   Example:
%   data  = load_roi(conn, 'rect', 'C1', 'CARTAGENA', 734229,734250.4583333334);
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
    
    EPS = 1/(24*60*60);
    
    try
        query = ['SELECT idroi, idcoord, timestamp, u, v '...
            'FROM roi_' lower(station) ' NATURAL JOIN roicoordinate_' lower(station) ' '...
            'WHERE idroi = '...
            '(SELECT idroi '...
            'FROM roi_' lower(station) ' '...
            'WHERE type LIKE "' type '" '...
            'AND idcalibration = '...
            '(SELECT idcalibration '...
            'FROM calibration_' lower(station) ' '...
            'WHERE camera LIKE "' camera '" '...
            'AND station LIKE "' station '" ' ...
            ' AND timestamp <= ' num2str(timestampcal + EPS, 17)  ...
            'ORDER BY timestamp DESC LIMIT 0,1)' ...
            'AND timestamp <= ' num2str(timestamproi + EPS, 17) ...
            ' ORDER BY timestamp DESC LIMIT 0,1'...
            ')'];
        
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