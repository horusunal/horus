function check = check_image(conn, image_name, station)

%CHECK_IMAGE this function is used for checking if the image exist.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   image_name: This is the image name.
%
%   Output:
%   check: means the status of the transaction. 1 if the image exist 
%          in the database, 0 otherwise.
%
%   Example:
%   check = check_image(conn, '10.05.01.16.15.00.GMT.Cartagena.C2.Snap.1024X768.HORUS.jpg', 'CARTAGENA');
%
%   See also LOAD_ALLIMAGE_MERGED, LOAD_ALLIMAGE_RECTIFIED, LOAD_NEARESTIMAGE,
%   LOAD_IMAGECAM, LOAD_FUSION, LOAD_CALIBRATION, LOAD_roi

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/22 9:00 $

try
    
    % query in the database
    
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    station = upper(station);
    if status == 1
        return
    end
    check = 0;
    try
            query = ['SELECT filename '...
                'FROM image_' station ' '...
                'WHERE filename LIKE "' image_name '"'];
            cursor = exec(conn, query);
            cursor = fetch(cursor);
            if ~strcmpi(cursor.Data{1,1}, 'No Data') && ~isfloat(cursor.Data)
                check = 1;
            end
    catch e
        disp([dberror('select') e.message]);
    end
    
catch e
    disp(e.message)
end