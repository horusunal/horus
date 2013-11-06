function  data  = load_imagetype_name(conn, station)

%LOAD_IMAGETYPE_NAME this function is used for querying all image type
%names in a station.
%
%   Input:
%   conn: Database connection which must have been previously created.
%
%   Output:
%   data: cell array with the image type names.
%
%   Example:
%   data  = load_imagetype_name(conn);
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
        alias = load_station_alias(conn, station);
        query = ['SELECT DISTINCT(name) FROM imagetype_' lower(station) ' ' ...
            'WHERE idtype LIKE "' alias '%"'];
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