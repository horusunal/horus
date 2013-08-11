function  newid  = generate_autoinc(conn, tablename, pkname, station)

%GENERATE_AUTOINC     Generate the autoincrement id for a table
%
%   Input:
%   conn: Database connection which must have been previously created.
%   tablename: Table name.
%   pkname: Name of the primary key attribute.
%   station: station name.
%
%   Output:
%   id: Autoincremented id.
%
%   Example:
%   id  = generate_autoinc(conn, 'camera', 'CARTAGENA')

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2012 HORUS
%   $Date: 2012/05/22 16:34 $

try
    station = upper(station);
    newid = [];
    
    % query in the database
    
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    try
        query = ['SELECT MAX(' pkname ') FROM ' tablename];
        cursor = exec(conn, query);
        cursor = fetch(cursor);
        if strcmpi(cursor.Data{1,1}, 'No Data') || isfloat(cursor.Data)
            return;
        end
        id = cell2mat(get(cursor, 'Data'));
        
        alias = load_station_alias(conn, station);
        
        if strcmpi(id, 'null')
            newid = sprintf('%s00000', alias);
            return;
        end
        
        n = length(id);
        num = str2double(id(n - 4:n));
        
        newid = sprintf('%s%05d', alias, num + 1);
        
    catch e
        disp([dberror('select') e.message]);
    end
    
catch e
    disp(e.message)
end