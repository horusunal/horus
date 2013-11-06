function data = load_pickedgcps(conn, station, camera, timestamp)

%LOAD_PICKEDgcpS   gcps for a camera.
%   data = LOAD_PICKEDgcpS(conn, station, camera, timestamp) returns the
%   information of the gcps assigned to a given camera, as well as the
%   pixel coordinates.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: is the name of the station.
%   camera: the name of the camera.
%   timestamp: is the upper bound for the timestamp. We want to find the
%   picked gcps assigned in the greatest time less than or equal to
%   'timestamp'.
%
%   Output:
%   data: is a cell matrix, where every row contains the following fields:
%   - name: name of the gcp
%   - gcp: Id of the gcp.
%   - u: Horizontal pixel coordinate.
%   - v: Vertical pixel coordinate.
%   - x: X georeferenced coordinate of the gcp
%   - y: Y georeferenced coordinate of the gcp
%   - z: Z georeferenced coordinate of the gcp
%
%   Example:
%       load_pickedgcps(conn, 'CARTAGENA', 'C1', 734260.437500000)
%
%   The pixel coordinates are located in a coordinate system whose origin
%   is in the upper left corner of the camera capture area.

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/22 09:27 $

try
    station = upper(station);
    data = [];
    EPS = 1 / (24 * 60 * 60);
    % query in the database
    
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    try
        % Query for retrieving all the picked gcps for a camera
        
        timestr = num2str(timestamp + EPS,17);
        
        query = ['SELECT DISTINCT g.name, pg.gcp, pg.u, pg.v, g.x, g.y, g.z '...
            'FROM pickedgcp_' lower(station) ' pg, gcp_' lower(station) ' g '...
            'WHERE g.idgcp = pg.gcp AND '...
            'calibration = ' ...
            '(SELECT idcalibration '...
            'FROM calibration_' lower(station) ' '...
            'WHERE station LIKE "' ...
            station '" '...
            'AND camera LIKE "' camera '" '...
            'AND timestamp <= ' timestr ' '...
            'ORDER BY ABS(timestamp - ' timestr ') LIMIT 1)'];
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