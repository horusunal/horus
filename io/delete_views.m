function [varargout] = delete_views(conn, station)  

%DELETE_VIEWS this function is used for deleting the views.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: station that makes up the name of the view.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the deletion was
%   successful, 1 otherwise.
%
%   Example:
%   status = delete_views(conn, station) 
%
%   See also DELETE_ALL_gcp, DELETE_ALL_IMAGE_STATION, DELETE_CAMERA, DELETE_gcp,
%       DELETE_MEASUREMENTTYPE, DELETE_roi, DELETE_SENSOR, DELETE_STATION

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2012/09/3 7:45 $

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

        query = ['DROP VIEW imagetype_' station ...
            ', timestack_' station ...
            ', sensor_' station ...
            ', camera_' station ...
            ', rectifiedimage_' station ...
            ', mergedimage_' station ...
            ', obliqueimage_' station ...
            ', image_' station ...
            ', fusion_' station ...
            ', fusionparameter_' station ...
            ', commonpoint_' station ...
            ', fusionvalue_' station ...
            ', camerabyfusion_' station ...
            ', calibration_' station ...
            ', calibrationparameter_' station ...
            ', calibrationvalue_' station ...
            ', roi_' station ...
            ', roicoordinate_' station ...
            ', gcp_' station ...
            ', pickedgcp_' station ... 
            ', automaticparams_' station ...
            ', measurement_' station ...
            ', measurementtype_' station ...
            ', measurementvalue_' station ];
        cursor = exec(conn, query);
        if nargout==1
            if size(cursor.Message,2) == 0
                varargout(1)={0};
            end
        end

    catch e
        varargout(1)={1};
        disp([dberror('delete') e.message]);
    end
    
catch e
    disp(e.message)
end

end