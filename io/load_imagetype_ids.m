function  data = load_imagetype_ids(conn, station, type)

%LOAD_IMAGETYPE_IDS   Loads all the ids associated with a image type name.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: station name.
%   type: Type name (e.g. snap)
%
%   Output:
%       data: Array with the ids returned by the query
%
%   Example:
%   data  = load_imagetype_ids(conn, 'snap');
%
%   See also LOAD_NEARESTIMAGE, LOAD_IMAGECAM, LOAD_FUSION,
%   LOAD_CALIBRATION, LOAD_roi

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2012 HORUS
%   $Date: 2012/02/14 15:05 $

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
        query = ['SELECT idtype FROM imagetype_' lower(station) ' WHERE name LIKE ''' type ''''];
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