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
    
    data =cell(0);
    EPS = 1 / (24 * 60 * 60);
    try
        for i=1:length(type)
            % Load all times for the images in sorted order
            query_times = ['SELECT timestamp '...
                    'FROM image_' lower(station) ' i NATURAL JOIN rectifiedimage_' lower(station) ' ri '...
                    'WHERE ismini = 0 AND type IN ( '...
                    'SELECT idtype '...
                    'FROM imagetype_' lower(station) ' '...
                    'WHERE name LIKE ("' char(type(i)) '") )'...
                    ' AND ri.calibration IN ('...
                    'SELECT idcalibration '...
                    'FROM calibration_' lower(station) ' '...
                    'WHERE camera LIKE "' camera ...
                    '" AND station LIKE "' station '"' ...
                    ') '...
                    'ORDER BY timestamp'];
            cursor_times = exec(conn, query_times);
            cursor_times = fetch(cursor_times);
            if strcmpi(cursor_times.Data{1,1}, 'No Data') || isfloat(cursor_times.Data)
                continue;
            end
            image_times = get(cursor_times, 'Data');
            image_times = cell2mat(image_times);
            
            len_img_times = length(image_times);
            
            selected_image_positions = false(len_img_times, 1);
            
            % For every search time, look up the found image time that is
            % between [Ti-e, Ti+e] and is closest to Ti.
            for j = 1:length(time)
                Ti = time(j);
                T1 = Ti - error;
                T2 = Ti + error;
                
                % Find the position of the first image time greater or equal than T1 as t1
                t1 = -1;
                lo = 1;
                hi = len_img_times;

                if (image_times(hi) >= T1)
                    while (lo < hi)
                        mid = floor((lo + hi) / 2);
                        if (image_times(mid) >= T1)
                            hi = mid;
                        else
                            lo = mid + 1;
                        end
                    end
                    t1 = lo;
                end
                % Find the position of the last image time less or equal than T2 as t2
                t2 = -1;
                lo = 1;
                hi = len_img_times + 1;

                if (image_times(1) <= T2)
                    while (lo < hi)
                        mid = floor((lo + hi) / 2);
                        if (image_times(mid) > T2)
                            hi = mid;
                        else
                            lo = mid + 1;
                        end
                    end
                    t2 = lo - 1;
                end
                if (t1 ~= -1 && t2 ~= -1)
                    % Find the image time between t1 and t2 closest to Ti and
                    % mark that position as selected in
                    % selected_image_positions
                    min_at = -1;
                    min_val = Inf;
                    for k = t1:t2
                        if abs(Ti - image_times(k)) < min_val
                            min_val = abs(Ti - image_times(k));
                            min_at = k;
                        end
                    end
                    if (min_at >= 1)
                        selected_image_positions(min_at) = true;
                    end
                end
            end
            
            selected_times = image_times(selected_image_positions);

            % Find all the information of the images at the times found in
            % last step
            for t = 1:length(selected_times)
            
                query = ['SELECT filename, path, timestamp, type, ri.calibration '...
                    'FROM image_' lower(station) ' i NATURAL JOIN rectifiedimage_' lower(station) ' ri '...
                    'WHERE ismini = 0 AND type IN ( '...
                    'SELECT idtype '...
                    'FROM imagetype_' lower(station) ' '...
                    'WHERE name LIKE ("' char(type(i)) '") )'...
                    ' AND timestamp BETWEEN ' num2str(selected_times(t) - EPS,17) ...
                    ' AND ' num2str(selected_times(t) + EPS,17) ...
                    ' AND ri.calibration IN ('...
                    'SELECT idcalibration '...
                    'FROM calibration_' lower(station) ' '...
                    'WHERE camera LIKE "' camera ...
                    '" AND station LIKE "' station '"' ...
                    ') '...
                    'LIMIT 1'];
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