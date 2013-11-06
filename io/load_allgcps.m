function data = load_allgcps(conn, station)

%LOAD_ALLgcpS   Returns all the information of the Ground Control Points in
%   a station.
%   data = LOAD_ALLgcpS(station) returns the information of the Ground
%   Control Points: id, name and position (x, y, z).
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: is the name of the station whose gcps we want to return.
%
%   Output:
%   data: is a nx5 cell matrix, where n is the number of gcps and a row
%   contains the following information (in the order specified):
%
%   'idgcp': The gcp number in the station
%   'name': The gcp name
%   'x': Georeferenced x position
%   'y': Georeferenced y position
%   'z': Georeferenced z position
%
%   Example:
%   data = load_allgcps(conn, 'CARTAGENA')
%
%   See also LOAD_NEARESTIMAGE, LOAD_IMAGECAM, LOAD_FUSION,
%   LOAD_CALIBRATION, LOAD_roi

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/21 17:10 $

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
        % Query for retrieving all the gcps in a station
        query = ['SELECT idgcp, name, x, y, z FROM gcp_' lower(station) ' WHERE station LIKE "' station '"'];
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