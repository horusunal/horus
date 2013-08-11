function  data  = load_years(conn, station)

%LOAD_YEARS this function is used for querying all the years for oblique
%images in a station.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: station name.
%
%   Output:
%   data: cell array with the years.
%
%   Example:
%   data  = load_years(conn, 'CARTAGENA');
%
%   See also LOAD_NEARESTIMAGE, LOAD_IMAGECAM, LOAD_FUSION,
%   LOAD_CALIBRATION, LOAD_roi

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/28 15:20 $

try
    station = upper(station);
    data = [];
        
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    try
        query = ['SELECT DISTINCT FLOOR(timestamp) FROM image_' station ' NATURAL JOIN '...
            'obliqueimage_' station ' WHERE ismini = 0 AND station LIKE "' station ...
            '" ORDER BY timestamp'];
        cursor = exec(conn, query);
        cursor = fetch(cursor);
        if strcmpi(cursor.Data{1,1}, 'No Data') || isfloat(cursor.Data)
            data = [];
            return;
        end
        timestamp = get(cursor, 'Data');
        data = cell(0);
        timestamp = cell2mat(timestamp);
        i=1;
        while i <= numel(timestamp)
            years = year(timestamp(i));
            ind = find(timestamp > datenum(years+1,0,0));
            data{end+1,1} = years;
            if isempty(ind)
                i= numel(timestamp) + 1;
            else
                i= ind(1);
            end
            
        end
        
    catch e
        disp([dberror('select') e.message]);
    end
    
catch e
    disp(e.message)
end

end