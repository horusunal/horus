function [varargout] = delete_measurementtype(conn, paramname,sensor,station)

%DELETE_MEASUREMENTTYPE this function is used for removing the measurement
%                       type associated to a sensor.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   paramname: Name of the measurement type.
%   sensor: ID of the sensor which is associated with the
%             measurement type.
%	station: station where is the measurement type.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the deletion was
%   successful, 1 otherwise.
%
%   Example:
%   status  = delete_measurementtype(conn,'tide','sensor_tide','CARTAGENA')
%
%   See also DELETE_ALL_gcp, DELETE_ALL_IMAGE_STATION, DELETE_CAMERA,
%       DELETE_gcp, DELETE_IMAGE, DELETE_roi, DELETE_SENSOR, DELETE_STATION

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/22 11:00 $

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
        query = ['DELETE FROM measurementtype_' station ' '...
            'WHERE sensor LIKE "' sensor '" AND paramname LIKE "' paramname ...
            '" AND station LIKE "' station '"'];
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