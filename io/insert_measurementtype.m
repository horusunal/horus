function [varargout] = insert_measurementtype(conn, paramname,datatype,sensor,station, varargin)

%INSERT_MEASUREMENTTYPE this function is used for inserting a new
%measurement type in the database.
%
%   Input:
%   conn: is the object that contains the database connection.
%   paramname: Is the parameter name.
%   datatype: This represents the graphic type in the web page, can be
%   'series' or 'contour'.
%   sensor: Name of the sensor.
%   station: station where is the sensor.
%   varargin: This can contain the following information.
%       unitx: Unit of the axes x.
%       unity: Unit of the axes y.
%       unitz: Unit of the axes z.
%       axisnamex: Label of the axes x.
%       axisnamey: Label of the axes y.
%       axisnamez: Label of the axes z.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the insertion was
%   successful, 1 otherwise.
%
%   Example:
%   insert_measurementtype(conn, 'surf','series','sensor_surf','CARTAGENA');
%   Or
%   insert_measurementtype(conn, 'surf','series','sensor_surf','CARTAGENA','unity','m','axisnamey','Surf');
%   Or
%   insert_measurementtype(conn, 'matrix','contour','sensor_matrix','CARTAGENA','unitx','m/s','unity','�','unitz','%',...
%   'axisnamex','Velocidad del viento','axisnamey','Direcci�n','axisnamez',...
%   'Probabilidad Conjunta vel-dir del Viento','sensor',1);
%
%   See also INSERT_IMAGETYPE, INSERT_MERGED, INSERT_OBLIQUE,
%   INSERT_RECTIFIED, INSERT_roi, INSERT_TIMESTACK

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/11/2 12:15 $

% connection to the database

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
    colnames_measurementtype = {'paramname','datatype','sensor','station'};
    %   data to insert
    data_measurementtype = {paramname,datatype,sensor,station};
    
    noptargs = numel(varargin);
    if mod(noptargs, 2) == 1
        disp(dberror('args'));
        return;
    end
    
    query = ['SELECT paramname, sensor FROM measurementtype_' station ' WHERE station LIKE "' station '"'];
    cursor = exec(conn, query);
    cursor = fetch(cursor);
    flag = true;
    if ~strcmpi(cursor.Data{1,1}, 'No Data') && ~isfloat(cursor.Data)
        
        measurementtype_verification = get(cursor, 'Data');
        
        measurementtype_verification2 = find(strcmpi(measurementtype_verification(:,1),paramname));
        
        for i = 1: size(measurementtype_verification2,1)
            if strcmpi(measurementtype_verification(measurementtype_verification2(i),2),sensor)
                flag = false;
                break;
            end
        end
        
        if ~flag
            disp([dberror('insert') 'Duplicated measurement type']);
            return;
        end
        
    end
    
    for i = 1:2:noptargs
        arg = varargin{i};
        value = varargin{i+1};
        
        colnames_measurementtype{end+1} = arg;
        data_measurementtype{end+1} = value;
    end
    
    try
        fastinsert(conn, ['measurementtype_' station],colnames_measurementtype,data_measurementtype);
        idmeasurementtype = lastid(conn);
        if idmeasurementtype==-1
            return
        end
        if nargout==1
            varargout(1)={0};
        elseif nargout==2
            varargout(1)={0};
            varargout(2)={idmeasurementtype};
        end
    catch e 
        disp([dberror('insert') e.message]);
    end
    
catch e
    disp(e.message)
end
