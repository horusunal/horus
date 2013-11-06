function  data  = load_allimages_per_cam(conn, type, station, cameras, timestamp, error)

%LOAD_ALLIMAGES_PER_CAM this function is used for querying all images per camera.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   type: Cell array with all the image type names.
%   station: station of the corresponding image.
%   cameras: Cell with the camera ids for the search.
%   timestamp: Value of the timestamp for the search.
%   error: This is the error in the timestamp permitted in the search.
%
%   Output:
%   data: Cell matrix with these columns:
%         {image name, image path, timestamp, camera}
%
%
%   Example:
%   data  = load_allimages_per_cam(conn, {'snap', 'timex'}, 'CARTAGENA',
%         {'C1', 'C2', 'C3'}, datenum(2010, 4, 10, 12, 0, 0), 3/(60*24));
%
%   See also LOAD_ALLIMAGE, LOAD_NEARESTIMAGE, LOAD_FUSION,
%   LOAD_CALIBRATION, LOAD_roi

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/10/10 15:42 $

% query in the database

try
    station = upper(station);
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    data = cell(0);
    EPS = 1 / (24 * 60 * 60);
    for i = 1:numel(cameras)
        try
            for j = 1:numel(type)
                query = ['SELECT filename, path, timestamp, camera '...
                    'FROM image_' lower(station) ' NATURAL JOIN obliqueimage_' lower(station) ' '...
                    'WHERE timestamp BETWEEN ' num2str(timestamp - error - EPS, 17) ' AND ' num2str(timestamp + error + EPS, 17) ' '...
                    'AND ismini = 0 '...
                    'AND station LIKE ''' station ''' '...
                    'AND camera LIKE ''' cameras{i} ''' ' ...
                    'AND type IN '...
                    '(SELECT idtype '...
                    'FROM imagetype_' lower(station) ' '...
                    'WHERE name LIKE ''' type{j} ''') '...
                    'ORDER BY ABS(timestamp - ' num2str(timestamp, 17) ') '...
                    'LIMIT 1'];
                cursor = exec(conn, query);
                cursor = fetch(cursor);
                
                if strcmpi(cursor.Data{1,1}, 'No Data') || isfloat(cursor.Data)
                    data = [];
                    return;
                end
                
                image = get(cursor, 'Data');
                
                data(end+1, :) = image;
            end
        catch e
            disp([dberror('select') e.message]);
        end
        
    end
    
catch e
    disp(e.message)
end

end