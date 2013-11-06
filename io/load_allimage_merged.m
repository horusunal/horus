function  data  = load_allimage_merged(conn, type, station, merged_type, inittime, finaltime)

%LOAD_ALLIMAGE_MERGED this function is used for querying all merged images
%in a given time interval, type, a camera and a station.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   type: Cell array with the image type names.
%   camera: camera id
%   station: station name
%   inittime: Initial time for the search.
%   finaltime: Final time for the search.
%
%   Output:
%   data: Cell matrix with these columns:
%         {image name, image path, timestamp, image type, fusion id}
%
%   Example:
%   data  = load_allimage_merged(conn, {'snap', 'timex'}, 'CARTAGENA', 'oblique', 734229, 734230 );
%
%   See also LOAD_ALLIMAGE, LOAD_ALLIMAGE_RECTIFIED, LOAD_NEARESTIMAGE,
%   LOAD_IMAGECAM, LOAD_FUSION, LOAD_CALIBRATION, LOAD_roi

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/22 9:00 $

try
    station = upper(station);
    % query in the database
    
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    data = cell(0);
    EPS = 1 / (24 * 60 * 60);
    try
        for i=1:length(type)
            query = ['SELECT filename, path, timestamp, type, mi.idfusion '...
                'FROM image_' lower(station) ' i NATURAL JOIN mergedimage_' lower(station) ' mi '...
                'WHERE ismini = 0 AND type IN ( '...
                'SELECT idtype '...
                'FROM imagetype_' lower(station) ' '...
                'WHERE name LIKE ("' char(type(i)) '") ) '...
                ' AND timestamp BETWEEN ' num2str(inittime - EPS,17)...
                ' AND ' num2str(finaltime + EPS,17)...
                ' AND mi.idfusion IN ('...
                'SELECT DISTINCT f.id FROM fusion_' lower(station) ' AS f INNER JOIN'...
                ' camerabyfusion_' lower(station) ' AS cf ON f.id = cf.idfusion'...
                ' WHERE cf.station LIKE "'...
                station '" AND type LIKE "' merged_type ...
                '")'];
            cursor = exec(conn, query);
            cursor = fetch(cursor);
            if strcmpi(cursor.Data{1,1}, 'No Data') || isfloat(cursor.Data)
                continue;
            end
            image = get(cursor, 'Data');
            [row col]=size(image);
            data(end+1:end+row,1:col) = image;
        end
    catch e
        disp([dberror('select') e.message]);
    end
    
catch e
    disp(e.message)
end

end