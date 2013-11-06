function  data  = load_nearestimage_merged(conn, station, type, idfusion, time, error)

%LOAD_NEARESTIMAGE_MERGED this function is used for querying the merged
%image closer to a time.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: Name of the station.
%   type: cell with the image type names.
%   idfusion: Represents the parameters used to merge multiple images.
%   time: Vector column with the values of the timestamp for the search.
%   error: This is the error in the timestamp permitted in the search.
%
%   Output:
%   data: cell array with these elements:
%         {image name, image path, timestamp}
%
%   Example:
%   data  = load_nearestimage_merged(conn, 'CARTAGENA', {'snap', 'timex'}, 'CRTG00002',[734229.4583333334;734229.8541666666;734231.4791666666], 0.02);
%
%   See also LOAD_ALLIMAGE, LOAD_IMAGECAM, LOAD_FUSION,
%   LOAD_CALIBRATION, LOAD_roi

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/22 9:20 $

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
    for i=1:size(time,1)
        
        try
            for j=1:length(type)
                query = ['SELECT filename, path, timestamp '...
                    'FROM image_' lower(station) ' i NATURAL JOIN mergedimage_' lower(station) ' mi '...
                    'WHERE ismini = 0 AND type IN ( ' ...
                    'SELECT idtype '...
                    'FROM imagetype_' lower(station) ' '...
                    'WHERE name LIKE ("' char(type(j)) '") ) '...
                    'AND mi.idfusion LIKE "' num2str(idfusion) '" '...
                    'AND timestamp BETWEEN ' num2str(time(i,1)-error-EPS,17) ' AND ' ...
                    num2str(time(i,1)+error+EPS,17) ' '...
                    'ORDER BY (ABS(timestamp - ' num2str(time(i,1),17) ')) LIMIT 0, 1'];
                cursor = exec(conn, query);
                cursor = fetch(cursor);
                if strcmpi(cursor.Data{1,1}, 'No Data') || isfloat(cursor.Data)
                    image = [];
                    continue;
                end
                image = get(cursor, 'Data');
                tam=size(image,2);
                data(end+1,1:tam) = image;
            end
        catch e
            disp([dberror('select') e.message]);
        end
        
    end
    
catch e
    disp(e.message)
end

end