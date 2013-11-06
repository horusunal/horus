function  data  = load_all_automatic_params(conn, station)

%LOAD_ALL_AUTOMATIC_PARAMS Returns all the parameters regarding times of capture
%for a specified station
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: Name of the station.
%
%   Output:
%   data: Cell array containing {station, type, start_hour, start_minute, end_hour,
%   end_minute, step, duration, num_images}.
%
%   Example:
%   data  = load_all_automatic_params(conn,'CARTAGENA');
%

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/12/06 14:02 $

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
        query = ['SELECT station, type, start_hour, start_minute, '...
            'end_hour, end_minute, step, duration, num_images, idauto '...
            'FROM automaticparams_' lower(station) ];
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