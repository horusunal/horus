function  [dbConn status] = renew_connection_db(dbConn)

% RENEW_CONNECTION_DB this function is used for rebooting a connection to
% the HORUS database.
%
%   Input:
%       dbConn: Database connection which must have been previously created.
%
%   Output:
%   dbConn: new connection object.
%   status: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the operation was
%   successful, 1 otherwise.
%
%   Example:
%   [dbConn status] = renew_connection_db(dbConn);

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/18 8:00 $

try
    status = 1;
    if ~isconnection(dbConn)
        try
            dbConn = connection_db();
            if isconnection(dbConn)
                status = 0;
            end
        catch e
            disp([dberror('conn') dbConn.Message]);
            return
        end
    else
        status = 0;
    end
catch e
    disp(e.message)
    return
end