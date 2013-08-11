function [varargout] = insert_sensor(conn, name,station, x, y, z, isvirtual, varargin)

%INSERT_SENSOR this function is used for inserting a new sensor in the
%database.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   name: sensor name.
%   station: It is the station where is the sensor.
%   x, y, z: Georeferenced sensor coordinate.
%   isvirtual: Says if this sensor is virtual or not.
%   varargin: This can contain the following information.
%       description: Description in words of the sensor.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the insertion was
%   successful, 1 otherwise.
%
%   Example:
%   insert_sensor(conn,'sensor_tide','CARTAGENA',200,300,2, false);
%   Or
%   insert_sensor(conn,'sensor_tide','CARTAGENA','description','The measured tide');
%
%   See also INSERT_IMAGETYPE, INSERT_MERGED, INSERT_OBLIQUE,
%   INSERT_RECTIFIED, INSERT_roi, INSERT_TIMESTACK

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/11/2 11:55 $


try
    station = upper(station);
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
    colnames_sensor = {'name','station','x','y','z', 'isvirtual'};
    %   data to insert
    data_sensor = {name,station,x,y,z, isvirtual};
    
    query = ['SELECT name FROM sensor_' station ' WHERE station LIKE "' station '"'];
    cursor = exec(conn, query);
    cursor = fetch(cursor);
    if ~strcmpi(cursor.Data{1,1}, 'No Data') && ~isfloat(cursor.Data)
        
        sensor_name = get(cursor, 'Data');
        
        sensor_name2 = find(strcmpi(sensor_name,name));
        
        if ~isempty(sensor_name2)
            disp([dberror('insert') 'Duplicated sensor']);
            return;
        end
        
    end
    
    noptargs = numel(varargin);
    if mod(noptargs, 2) == 1
        disp(dberror('args'));
        return;
    end
    
    for i = 1:2:noptargs
        arg = varargin{i};
        value = varargin{i+1};
        
        colnames_sensor{end+1} = arg;
        data_sensor{end+1} = value;
    end
    
    try
        fastinsert(conn, ['sensor_' station],colnames_sensor,data_sensor);
        if nargout==1
            varargout(1)={0};
        end
    catch e
        disp([dberror('insert') e.message]);
    end
    
catch e
    disp(e.message)
end