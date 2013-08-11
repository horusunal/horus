function [varargout] = delete_automatic_params(conn, idauto, station)

%DELETE_AUTOMATIC_PARAMS  Removes a set of automatic params in a station.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   idauto: Numeric ID of the params.
%   station: station name.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the deletion was
%   successful, 1 otherwise.
%
%   Example:
%   status  = delete_automatic_params(conn, 1, 'CARTAGENA');
%

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2012 HORUS
%   $Date: 2012/07/27 11:44 $

try
    station = upper(station);
    if nargout==1
        varargout(1)={1};
    end
    
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    try
        query = ['DELETE FROM automaticparams_' station ' '...
            'WHERE station LIKE "' station '" AND idauto = ' num2str(idauto)];
        cursor = exec(conn, query);
        if nargout==1
            if isfloat(cursor.Message)
                varargout(1)={0};
            end
        end
    catch e
        disp([dberror('delete') e.message]);
    end
catch e
    disp(e.message)
end
