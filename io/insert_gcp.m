function [varargout] = insert_gcp(conn, idgcp, station, name, x, y, z)

%INSERT_gcp   Insert a new tuple in the table gcp
%   INSERT_gcp(conn, idgcp, station, name, x, y, z)
%   inserts the tuple identified by idgcp (numeric) and the station name.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   idgcp: number that identifies a gcp in a station.
%   station: is the name of the station.
%   name: is a mnemotechnic name for the gcp.
%   'x', 'y', 'z': is the georeferenced coordinate of the gcp.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the insertion was
%   successful, 1 otherwise.
%
%   Example:
%       insert_gcp(conn, 32, 'CARTAGENA', 'gcp032', 1000, 2000, 1900)
%

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/27 16:11 $

try
    station = upper(station);
    if nargout==1
        varargout(1)={1};
    end
    
    % Insert in the database
    
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    try
        query = ['SELECT name FROM gcp_' station ' WHERE station LIKE "' station '"'];
        cursor = exec(conn, query);
        cursor = fetch(cursor);
        
        if ~strcmpi(cursor.Data{1,1}, 'No Data') && ~isfloat(cursor.Data)
            
            gcp_name = get(cursor, 'Data');
            
            gcp_name2 = find(strcmpi(gcp_name,name));
            
            if ~isempty(gcp_name2)
                disp([dberror('insert') 'Duplicated gcp name']);
                return;
            end
            
        end
        
        % Data for insertion in gcp
        colnames = {'idgcp', 'station', 'name', 'x', 'y', 'z'};
        extdata = {idgcp, station, name, x, y, z};
        
        fastinsert(conn, ['gcp_' station], colnames, extdata);
        if nargout==1
            varargout(1)={0};
        end
    catch e
        disp([dberror('insert') e.message]);
    end
    
catch e
    disp(e.message)
end