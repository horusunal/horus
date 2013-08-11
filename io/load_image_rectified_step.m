function  data  = load_image_rectified_step(conn, type, camera, station, time, error)

%LOAD_IMAGE_RECTIFIED_STEP   Finds a group of rectified images whose timestamp
%coincide with an array of times +/- a given error.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   type: Is a cell with the name of the type of the image.
%   camera: camera id
%   station: station name
%   time: array of times for the search.
%   error: error of the search in days.
%
%   Output:
%   data: Is a matrix containing the information of the images.
%         {filename, path, timestamp, type, idcalibration}
%
%   Example:
%   data  = load_image_rectified_step(conn, {'snap', 'timex'}, 'C1', 'CARTAGENA', 734229:734240, 1/24 );
%
%   See also LOAD_NEARESTIMAGE, LOAD_IMAGECAM, LOAD_FUSION,
%   LOAD_CALIBRATION, LOAD_roi

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2012/01/07 15:00 $

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
        for t = 1:length(time)
            for i=1:length(type)
                query = ['SELECT filename, path, timestamp, type, ri.calibration '...
                    'FROM image_' station ' i NATURAL JOIN rectifiedimage_' station ' ri '...
                    'WHERE ismini = 0 AND type IN ( '...
                    'SELECT idtype '...
                    'FROM imagetype_' station ' '...
                    'WHERE name LIKE ("' char(type(i)) '") )'...
                    ' AND timestamp BETWEEN ' num2str(time(t)-error - EPS,17) ...
                    ' AND ' num2str(time(t)+error + EPS,17) ...
                    ' AND ri.calibration IN ('...
                    'SELECT idcalibration '...
                    'FROM calibration_' station ' '...
                    'WHERE camera LIKE "' camera ...
                    '" AND station LIKE "' station '"' ...
                    ') '...
                    'ORDER BY ABS(timestamp - ' num2str(time(t)) ') LIMIT 1'];
                cursor = exec(conn, query);
                cursor = fetch(cursor);
                if strcmpi(cursor.Data{1,1}, 'No Data') || isfloat(cursor.Data)
                    continue;
                end
                image = get(cursor, 'Data');
                [row col]=size(image);
                data(end+1:end+row,1:col) = image;
            end
        end
    catch e
        disp([dberror('select') e.message]);
    end
    
catch e
    disp(e.message)
end

end