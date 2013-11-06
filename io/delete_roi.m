function  [varargout] = delete_roi(conn, station, idroi)

%DELETE_roi this function is used for removing a roi.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: Name of the station.
%   idroi: ID of the roi in the database.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the deletion was
%   successful, 1 otherwise.
%
%   Example:
%   status  = delete_roi(conn, , 'CARTAGENA', 'CRTG0006');
%
%   See also DELETE_ALL_gcp, DELETE_ALL_IMAGE_STATION, DELETE_CAMERA, DELETE_gcp,
%       DELETE_IMAGE, DELETE_MEASUREMENTTYPE, DELETE_SENSOR, DELETE_STATION

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/22 11:00 $

try
    station = lower(station);
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
        query = ['DELETE FROM roi_' station ' '...
            'WHERE idroi LIKE "' mat2str(idroi) '"'];
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