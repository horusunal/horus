function  data  = load_fusion_times(conn, station, type)

%LOAD_FUSION_TIMES  Loads timestamps for all fusions associated
%to a station.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: station name.
%   type: Type of fusion. Can take values: 'oblique' or 'rectified'.
%
%   Output:
%   data: cell array with the timestamps
%
%   Example:
%   data  = load_fusion_times(conn, 'CARTAGENA');
%

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2012 HORUS
%   $Date: 2012/07/04 18:11 $

try
    station = upper(station);
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    try
        alias = load_station_alias(conn, station);
        query = ['SELECT DISTINCT(timestamp) '...
            'FROM fusion_' lower(station) ' '...
            'WHERE id LIKE ''' alias '%'' '...
            'AND type LIKE ''' type ''''];
        
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