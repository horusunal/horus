function alias = load_station_alias(conn, station)

%LOAD_STATION_ALIAS Loads the alias for specified station.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: station name
%
%   Output:
%   alias: station alias
%
%   Example:
%   alias  = load_station_alias(conn, 'CARTAGENA');

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2012 HORUS
%   $Date: 2012/05/22 18:34 $

try
    station = upper(station);
    alias = [];
    
    % query in the database
    
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    try
        query = ['SELECT alias FROM station WHERE name LIKE ''' station ''''];
        cursor = exec(conn, query);
        cursor = fetch(cursor);
        if strcmpi(cursor.Data{1,1}, 'No Data') || isfloat(cursor.Data)
            return;
        end
        data = get(cursor, 'Data');
        alias = char(data);
    catch e
        disp([dberror('select') e.message]);
    end
    
catch e
    disp(e.message)
end

end