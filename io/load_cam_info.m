function  data  = load_cam_info(conn, station, cam)

%LOAD_CAM_INFO this function is used for querying information for a camera
%in a station.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: station associated to the camera.
%   cam: camera id.
%
%   Output:
%   data: cell array with these elements: 
%         {camera id, station, reference, size X, size Y}
%
%   Example:
%   data  = load_cam_info(conn, 'CARTAGENA','C1');
%
%   See also LOAD_NEARESTIMAGE, LOAD_IMAGECAM, LOAD_FUSION,
%   LOAD_CALIBRATION, LOAD_roi

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/28 15:00 $

try
    station = upper(station);
    data=[];
    
    % query in the database
    
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    try
        query = ['SELECT id, station, reference, sizeX, sizeY ' ...
            'FROM camera_' lower(station) ' WHERE station LIKE "' station '" AND id LIKE "' cam '"'];
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