function  data  = load_days(conn,station,years,months)

%LOAD_DAYS this function is used for querying all the days in a station
% given a year and a month
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: station name.
%   years: Year for the search.
%   months: Month for the search.
%
%   Output:
%   data: cell array with the days in numeric format.
%
%   Example:
%   data  = load_days(conn, 'CARTAGENA',2010,4);
%
%   See also LOAD_NEARESTIMAGE, LOAD_IMAGECAM, LOAD_FUSION,
%   LOAD_CALIBRATION, LOAD_roi

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/28 16:00 $

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
    
    year_ini = datenum(years,months,01);
    year_fin = datenum(years,months+1,01);
    
    try
        query = ['SELECT DISTINCT FLOOR(timestamp) FROM image_' lower(station) ' NATURAL JOIN '...
            'obliqueimage_' lower(station) ' WHERE ismini = 0 AND station LIKE "' station '"' ...
            ' AND timestamp BETWEEN ' num2str(year_ini - EPS,17) ' AND ' ...
            num2str(year_fin + EPS,17) ' ORDER BY timestamp'];
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
            days = day(timestamp(i));
            ind = find(timestamp >= datenum(years,months,days+1));
            data{end+1,1} = days;
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