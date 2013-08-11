function  data  = load_last_thumb_time(conn, imgtype, station )

%LOAD_LAST_THUMB_TIME this function is used for querying the timestamp of
%the last thumbnail.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   imgtype: Is the type of the thumbnail, can be 'oblique', 'merge_oblique'
%          or 'merge_rectified'.
%   station: station for the search.
%
%   Output:
%   data: Timestamp of the last thumbnail.
%
%   Example:
%   data  = load_last_thumb_time(conn, 'oblique', 'CARTAGENA' )
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
        switch imgtype
            case 'oblique'
                query = ['SELECT MAX(timestamp) FROM image_' station ' NATURAL JOIN '...
                    'obliqueimage_' station ' WHERE ismini = 1 AND '...
                    'station LIKE "' station '" '];
                cursor = exec(conn, query);
                cursor = fetch(cursor);
                if strcmpi(cursor.Data{1,1}, 'No Data') || isfloat(cursor.Data)
                    data = [];
                    return;
                end
                data = get(cursor, 'Data');
            case 'merge_oblique'
                query = ['SELECT MAX(i.timestamp) FROM image_' station ' AS i NATURAL JOIN '...
                    'mergedimage_' station ' AS mi JOIN fusion_' station ' AS f JOIN camerabyfusion_' station ' AS cf WHERE '...
                    'mi.idfusion=f.id AND '...
                    'f.id=cf.idfusion AND ismini = 1 AND '...
                    'cf.station LIKE "' station '" AND f.type LIKE "oblique"'];
                cursor = exec(conn, query);
                cursor = fetch(cursor);
                if strcmpi(cursor.Data{1,1}, 'No Data') || isfloat(cursor.Data)
                    data = [];
                    return;
                end
                data = get(cursor, 'Data');
            case 'merge_rectified'
                query = ['SELECT MAX(i.timestamp) FROM image_' station ' AS i NATURAL JOIN '...
                    'mergedimage_' station ' AS mi JOIN fusion_' station ' AS f JOIN camerabyfusion_' station ' AS cf WHERE '...
                    'mi.idfusion=f.id AND '...
                    'f.id=cf.idfusion AND ismini = 1 AND '...
                    'cf.station LIKE "' station '" AND f.type LIKE "rectified"'];
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