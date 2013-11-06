function [varargout] = update_measurementtype(conn, paramname, sensor, station, varargin)

%UPDATE_MEASUREMENTTYPE   Update a tuple in the table measurementtype
%   UPDATE_MEASUREMENTTYPE(conn, paramname, sensor, station, varargin) updates the tuple identified by
%   'paramname' and 'sensor'. Any attribute can be updated and they are given by varargin.
%   The attributes are given as pairs {'AttributeName', 'AttributeValue'}.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   paramname: This is the name of the parameter.
%   sensor: This is the ID of the sensor.
%   station: This is the station where is the sensor.
%   varargin: The attributes are given as pairs {'AttributeName', 'AttributeValue'}.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the update was
%   successful, 1 otherwise.
%
%   Example:
%       status = update_measurementtype(conn, 'tide', 'sensor_tide','CARTAGENA', 'unity', 'm');
%

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/22 09:42 $

try
    station = upper(station);
    if nargout==1
        varargout(1)={1};
    end
    
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    try
        % Data for updating a calibration in the database
        colnames = cell(0);
        extdata = cell(0);
        whereclause = ['WHERE paramname LIKE "' paramname '" AND sensor LIKE "' sensor ...
            '" AND station LIKE "' station '"'];
        
        if ~isvalidoption('measurementtype', varargin{:})
            disp(dberror('args'));
            return;
        end
        
        noptargs = numel(varargin);
        
        for i = 1:2:noptargs
            arg = varargin{i};
            value = varargin{i+1};
            
            colnames{end+1} = arg;
            extdata{end+1} = value;
        end
        
        update(conn, ['measurementtype_' lower(station)], colnames, extdata, whereclause);
        if nargout==1
            varargout(1)={0};
        end
        
    catch e
        disp([dberror('update') e.message]);
    end
    
catch e
    disp(e.message)
end