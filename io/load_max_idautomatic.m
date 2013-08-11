function  data  = load_max_idautomatic(conn, station)

%LOAD_MAX_IDAUTOMATIC   Returns the largest idauto in table
%automaticparams.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: station name
%
%   Output:
%   data: A cell with one element containing the id, or NaN if no idauto
%   value was found.
%
%   Example:
%   data  = load_max_idautomatic(conn, 'CARTAGENA')
%
%   LOAD_IDCALIBRATION

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2012 HORUS
%   $Date: 2012/01/20 11:18 $

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
        query = ['SELECT MAX(idauto) '...
            'FROM automaticparams_' station ' WHERE '...
            'station LIKE "' station '"'];
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