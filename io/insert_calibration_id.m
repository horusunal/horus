function [varargout] = insert_calibration_id(conn, idcalibration, camera, station, timestamp,...
    resolution, parameters, varargin)

%INSERT_CALIBRATION   Insert a new tuple in the table calibration
%   INSERT_CALIBRATION(camera, station, timestamp, parameter, varargin)
%   inserts the tuple identified by an autonumeric id, which is
%   automatically generated by MySQL.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   idcalibration: is the id of the calibration.
%   camera: is the name of the camera.
%   station: is the name of the station.
%   timestamp: is the time where the calibration was generated.
%   resolution: is the rectification resolution measured in m/pix.
%   parameters: is a cell array, and contains all the matrices that
%   represent the optimization model. These are given as pairs of {name,
%   value}, i.e., odd positions contain names, even positions contain the
%   values (scalars, matrices or vectors).
%
%   The optional attributes are given as pairs
%   {'AttributeName', 'AttributeValue'}.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the insertion was
%   successful, 1 otherwise.
%
%   Example:
%       insert_calibration(conn,'C2', 'CARTAGENA', datenum(2011, 07, 22, 00, 00,
%       00), 0.5, {'H', [1 2 3; 4 5 6], 'sigma', 0.8974854}, 'NCE', 0.2893784)
%

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/22 10:52 $

try
    station = upper(station);
    if nargout >= 1
        varargout(1)={1};
    end
    
    % Insert in the database
    
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    try

        % Data for insertion in calibration
        colnames = {'idcalibration', 'camera', 'station', 'timestamp', 'resolution'};
        extdata = {idcalibration, camera, station, timestamp, resolution};
        
        varargin = varargin{:};
        noptargs = numel(varargin);
        
        % Optional arguments go in pairs
        if mod(noptargs, 2) == 1
            disp(dberror('args'));
            return;
        end
        
        for i = 1:2:noptargs
            arg = varargin{i};
            value = varargin{i+1};
            
            if ~strcmp(arg, 'EMCuv') && ~strcmp(arg, 'EMCxy') && ...
                    ~strcmp(arg, 'NCE')
                disp(dberror('args'));
                return;
            end
            
            colnames{end+1} = arg;
            extdata{end+1} = value;
        end
        
        fastinsert(conn, ['calibration_' lower(station)], colnames, extdata);
        if nargout >= 1
            varargout(1)={0};
        end
        
    catch e
        disp([dberror('insert') e.message]);
    end
    
    % Saving calibration parameters
    n = numel(parameters);
    for i = 1:2:n
        name = parameters{i};
        value = parameters{i+1};
        
        insert_calibrationparameter(conn, station, idcalibration, name, value);
    end
        
catch e
    disp(e.message)
end