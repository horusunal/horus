function  data  = load_idfusion(conn, datat, station, data_init)

%LOAD_IDFUSION this function is used for querying all fusion ids after a
%timestamp.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   datat: Is the type of the fusion, can be 'merge_oblique'
%          or 'merge_rectified'.
%   station: station name.
%   data_init: Initial time for the search.
%
%   Output:
%   data: fusion ids.
%
%   Example:
%   data  = load_idfusion(conn, 'merge_oblique', 'CARTAGENA', 734229.4583333334)
%
%   See also LOAD_NEARESTIMAGE, LOAD_IMAGECAM, LOAD_FUSION,
%   LOAD_CALIBRATION, LOAD_roi

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/09/2 10:00 $

try
    station = upper(station);
    data = [];
    EPS = 1 / (24 * 60 * 60);
    
    % query in the database
    
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    data =cell(0);
    try
        switch datat
            case 'merge_oblique'
                query = ['SELECT DISTINCT f.id FROM image_' station ' AS i NATURAL JOIN '...
                    'mergedimage_' station ' AS mi JOIN fusion_' station ' AS f JOIN camerabyfusion_' station ' AS cf WHERE '...
                    'mi.idfusion=f.id AND '...
                    'f.id=cf.idfusion AND ismini = 0 AND '...
                    'cf.station LIKE "' station '" AND '...
                    'f.type LIKE "oblique" AND i.timestamp >= ' num2str(data_init - EPS,17) ];
                cursor = exec(conn, query);
                cursor = fetch(cursor);
                if strcmpi(cursor.Data{1,1}, 'No Data') || isfloat(cursor.Data)
                    data = [];
                    return;
                end
                data = get(cursor, 'Data');
            case 'merge_rectified'
                query = ['SELECT DISTINCT f.id FROM image_' station ' AS i NATURAL JOIN '...
                    'mergedimage_' station ' AS mi JOIN fusion_' station ' AS f JOIN camerabyfusion_' station ' AS cf WHERE '...
                    'mi.idfusion=f.id AND '...
                    'f.id=cf.idfusion AND ismini = 0 AND '...
                    'cf.station LIKE "' station '" AND '...
                    'f.type LIKE "rectified" AND i.timestamp >=' num2str(data_init - EPS,17)];
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