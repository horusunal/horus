function [varargout] = insert_fusion(conn, station, timestamp, type, cameraSequence, ...
    parameters)

%INSERT_FUSION   Insert a new tuple in the table fusion
%   INSERT_FUSION(conn, station, timestamp, type, cameraSequence,
%   parameters)
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: is the name of the station.
%   timestamp: time when the fusion was generated in datenum format.
%   type: can be 'rectified' or 'oblique', and represent the kind of
%   images that are to be merged.
%   cameraSequence: is a cell array that contains the ids of the cameras
%   that participate in the fusion, sorted by the sequence order.
%   parameters: is a cell array of the form {'param1', value1, param2,
%   value2, ...} where the odd positions (1-based index) are the parameters
%   names and the even positions contain the parameter values as scalar
%   values, vectors or matrices.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the insertion was
%   successful, 1 otherwise.
%
%   Example:
%       insert_fusion(conn, 'CARTAGENA', 734710.786, 'oblique', {'C1', 'C2',
%       'C3'}, {'H', [1 2 3; 4 5 6], 'sigma', 0.9887768})
%

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/27 16:00 $

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
    
    try
        newid  = generate_autoinc(conn, ['fusion_' station], 'id', station);
        % Data for insertion in fusion
        colnames = {'id', 'timestamp', 'type'};
        extdata = {newid, timestamp, type};
        
        fastinsert(conn, ['fusion_' station], colnames, extdata);
        
    catch e
        disp([dberror('insert') e.message]);
    end
        
    % Saving fusion parameters
    n = numel(parameters);
    for i = 1:2:n
        name = parameters{i};
        value = parameters{i+1};
        
        insert_fusionparameter(conn, station, newid, name, value);
    end
    
    % Saving cameras that participate in this fusion, sorted by the sequence
    % number
    
    m = numel(cameraSequence);
    for i = 1:m
        insert_camerabyfusion(conn, newid, cameraSequence{i}, station, i);
    end
    
    if nargout>=1
        varargout(1)={0};
    end
    if nargout == 2
        varargout(2) = {newid};
    end
    
catch e
    disp(e.message)
end