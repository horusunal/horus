function  data  = load_gcp_info(conn, station, gcp)

%LOAD_gcp_INFO this function is used for querying the information of a
%gcp.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: station name.
%   gcp: Name of the gcp.
%
%   Output:
%   data: cell array with these elements:
%         {gcp id, station, name, x, y, z}

%
%   Example:
%   data  = load_gcp_info(conn, 'CARTAGENA','gcp006');
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
    data = [];
    
    % query in the database
    
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    try
        query = ['SELECT idgcp, station, name, x, y, z FROM gcp_' station ' WHERE station LIKE "'...
            station '" AND name LIKE "' gcp '"'];
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