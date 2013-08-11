function id = lastid(conn)

%LASTID   Id of the row last inserted in the database with the connection
% 'conn'.
%   id = LASTID(conn) returns the id of the last row inserted in any table
%   in the database. This is specific for MySQL.
%
%   Input:
%   conn: is an instance of connection to the database.
%
%   Output:
%   id: contains the numeric value of the last inserted row's id.
% 
%   Example:
%   id = lastid(conn)

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/21 16:06 $

try
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    % Retrieve id of the last row inserted in database
    query = 'SELECT last_insert_id()';
    cursor = exec(conn, query);
    cursor = fetch(cursor);
    id = get(cursor, 'Data');
    id = cell2mat(id);
catch e
    id = -1;
    disp([dberror('select') e.message]);
end