function  [varargout] = delete_fusion(conn, station)

%DELETE_FUSION this function is used for removing all fusion parameters
% from a station.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: station where the fusion parameters are to be removed.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the deletion was
%   successful, 1 otherwise.
%
%   Example:
%   status = delete_fusion(conn, 'CARTAGENA')
%
%   See also DELETE_ALL_gcp, DELETE_CAMERA, DELETE_gcp, DELETE_IMAGE,
%       DELETE_MEASUREMENTTYPE, DELETE_roi, DELETE_SENSOR, DELETE_STATION

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/10/31 15:45 $

try
    station = upper(station);
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
        alias = load_station_alias(conn, station);
        
        query = ['DELETE FROM fusion_' station ' '...
            'WHERE id LIKE "' alias '%"'];
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