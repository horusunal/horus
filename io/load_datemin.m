function  data  = load_datemin(conn, datat, station, isthumb)

%LOAD_DATEMIN this function is used for querying the time of the first image.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   datat: Is the type of the miniature, can be 'oblique', 'rectified', 'merge_oblique'
%          or 'merge_rectified'.
%   station: station for the search.
%   isthumb: True if the image is thumbnail, false otherwise
%
%   Output:
%   data: Is the date of the first image.
%
%   Example:
%   data  = load_datemin(conn, 'oblique', 'CARTAGENA', false)
%
%   See also LOAD_NEARESTIMAGE, LOAD_IMAGECAM, LOAD_FUSION,
%   LOAD_CALIBRATION, LOAD_roi

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/09/2 9:00 $

try
    station = upper(station);
    data = [];
    
    % query in the database
    
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    data =cell(0);
    try
        switch datat
            case 'oblique'
                query = ['SELECT timestamp FROM image_' lower(station) ' NATURAL JOIN '...
                    'obliqueimage_' lower(station) ' WHERE ismini = ' num2str(isthumb) ' AND '...
                    'station LIKE "' station '" '...
                    'ORDER BY timestamp LIMIT 1'];
                cursor = exec(conn, query);
                cursor = fetch(cursor);
                if strcmpi(cursor.Data{1,1}, 'No Data') || isfloat(cursor.Data)
                    data = [];
                    return;
                end
                data = get(cursor, 'Data');
            case 'rectified'
                query = ['SELECT i.timestamp FROM image_' lower(station) ' AS i NATURAL JOIN '...
                    'rectifiedimage_' lower(station) ' AS ri JOIN calibration_' lower(station) ' AS c WHERE ismini = ' num2str(isthumb) ' AND '...
                    'ri.calibration = c.idcalibration '...
                    'AND c.station LIKE "' station '" '...
                    'ORDER BY i.timestamp LIMIT 1'];
                cursor = exec(conn, query);
                cursor = fetch(cursor);
                if strcmpi(cursor.Data{1,1}, 'No Data') || isfloat(cursor.Data)
                    data = [];
                    return;
                end
                data = get(cursor, 'Data');
            case 'merge_oblique'
                query = ['SELECT i.timestamp FROM image_' lower(station) ' AS i NATURAL JOIN '...
                    'mergedimage_' lower(station) ' AS mi JOIN fusion_' lower(station) ' AS f JOIN camerabyfusion_' lower(station) ' AS cf WHERE '...
                    'mi.idfusion=f.id AND '...
                    'f.id=cf.idfusion AND ismini = ' num2str(isthumb) ' AND '...
                    'cf.station LIKE "' station '" AND f.type LIKE "oblique" '...
                    'ORDER BY i.timestamp LIMIT 1'];
                cursor = exec(conn, query);
                cursor = fetch(cursor);
                if strcmpi(cursor.Data{1,1}, 'No Data') || isfloat(cursor.Data)
                    data = [];
                    return;
                end
                data = get(cursor, 'Data');
            case 'merge_rectified'
                query = ['SELECT i.timestamp FROM image_' lower(station) ' AS i NATURAL JOIN '...
                    'mergedimage_' lower(station) ' AS mi JOIN fusion_' lower(station) ' AS f JOIN camerabyfusion_' lower(station) ' AS cf WHERE '...
                    'mi.idfusion=f.id AND '...
                    'f.id=cf.idfusion AND ismini = ' num2str(isthumb) ' AND '...
                    'cf.station LIKE "' station '" AND f.type LIKE "rectified" '...
                    'ORDER BY i.timestamp LIMIT 1'];
                cursor = exec(conn, query);
                cursor = fetch(cursor);
                if strcmpi(cursor.Data{1,1}, 'No Data') || isfloat(cursor.Data)
                    data = [];
                    return;
                end
                data = get(cursor, 'Data');
        end
        
    catch e
        disp([dberror('select') e.message]);
    end
    
catch e
    disp(e.message)
end

end