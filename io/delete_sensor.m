function [varargout] = delete_sensor(conn,name,station)

%DELETE_SENSOR this function is used for removing a sensor from a station.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   name: Name of the sensor.
%   station: station where is the sensor.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the deletion was
%   successful, 1 otherwise.
%
%   Example:
%   status  = delete_sensor(conn, 'sensor_tide','CARTAGENA');
%
%   See also LOAD_ALLIMAGE, LOAD_NEARESTIMAGE, LOAD_IMAGECAM, LOAD_FUSION,
%   LOAD_CALIBRATION

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
        query = ['DELETE FROM sensor_' station ' '...
            'WHERE station LIKE "' station '" AND name LIKE "' name '"' ];
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