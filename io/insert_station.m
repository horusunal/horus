function [varargout] = insert_station(conn, name, alias, elevation, lat, lon, country, state, city, varargin)

%INSERT_STATION this function is used for inserting a new station in the
%database.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   name: station Name.
%   alias: station alias.
%   elevation: Elevation above sea level in meters.
%   lat: Latitude of the site in Degrees.
%   lon: Longitude of the site in Degrees.
%   country: Country where the station is located.
%   state: State or department where the station is located.
%   city: City where the station is located.
%   varargin: This can contain the following information.
%       responsible: Name of the entity or person responsible for the
%                    station.
%       description: Description in words of the site where the station is
%                    located.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the insertion was
%   successful, 1 otherwise.
%
%   Example:
%   insert_station(conn,'CARTAGENA','CRTG',85,10.397283333333,-75.5619194444444,'Colombia','Bolivar','Cartagena');
%   Or
%   insert_station(conn,'CARTAGENA','CRTG',85,10.397283333333,-75.5619194444444,'Colombia','Bolivar','Cartagena','responsible','HORUS','description','Edificio Bavaria, Bocagrande');
%   Or
%   insert_station(conn,'CARTAGENA','CRTG',85,10.397283333333,-75.5619194444444,'Colombia','Bolivar','Cartagena','description','Edificio Bavaria, Bocagrande');
%
%   See also INSERT_IMAGETYPE, INSERT_MERGED, INSERT_OBLIQUE,
%   INSERT_RECTIFIED, INSERT_roi, INSERT_TIMESTACK

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/21 11:00 $

% connection to the database

try

    if nargout==1
        varargout(1)={1};
    end
    % Insert in the database
    
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    %   name of the parameter of te table
    colnames_station = {'name', 'alias', 'elevation', 'lat', 'lon', 'country', 'state', 'city'};
    %   data to insert
    data_station = {upper(name), upper(alias), elevation, lat, lon, country, state, city};
    
    noptargs = numel(varargin);
    if mod(noptargs, 2) == 1
        disp(dberror('args'));
        return;
    end
    
    for i = 1:2:noptargs
        arg = varargin{i};
        value = varargin{i+1};
        
        colnames_station{end+1} = arg;
        data_station{end+1} = value;
    end
    
    try
        fastinsert(conn, 'station',colnames_station,data_station);
        if nargout==1
            varargout(1)={0};
        end
    catch e
        
        disp([dberror('insert') e.message]);
    end
    
catch e
    disp(e.message)
end

end