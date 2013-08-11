function  [varargout] = delete_station(conn,name)

%DELETE_STATION this function is used for revoming a station.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   name: Name of the station in the database.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the deletion was
%   successful, 1 otherwise.
%
%   Example:
%   status  = delete_station(conn, 'CARTAGENA');
%
%   See also DELETE_ALL_gcp, DELETE_ALL_IMAGE_STATION, DELETE_CAMERA, DELETE_gcp,
%       DELETE_IMAGE, DELETE_MEASUREMENTTYPE, DELETE_roi, DELETE_SENSOR

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/22 11:00 $

try
    name = upper(name);
    if nargout==1
        varargout(1)={1};
    end
    % query in the database
    
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    try
        query = ['DELETE FROM station '...
            'WHERE name LIKE "' name '"'];
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

end