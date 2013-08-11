function [varargout] = update_fusion(conn, station, id, varargin)

%UPDATE_FUSION   Update a tuple in the table fusion
%   UPDATE_FUSION(conn, station, id, varargin) updates the tuple identified by
%   'id'. Any attribute can be updated and they are given by varargin.
%   The attributes are given as pairs {'AttributeName', 'AttributeValue'}.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: Name of the station.
%   id: ID of the fusion.
%   varargin: The attributes are given as pairs {'AttributeName', 'AttributeValue'}.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the insertion was
%   successful, 1 otherwise.
%
%   Example:
%       status = update_fusion(conn, 'CARTAGENA', 9, 'timestamp', 734706.4362, 'type',
%       'rectified');
%

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/22 10:28 $

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
        % Data for updating a fusion in the database
        colnames = cell(0);
        extdata = cell(0);
        whereclause = ['WHERE id LIKE "' id '"'];
        
        if ~isvalidoption('fusion', varargin{:})
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
        
        update(conn, ['fusion_' station], colnames, extdata, whereclause);
        if nargout==1
            varargout(1)={0};
        end
    catch e
        disp([dberror('update') e.message]);
    end
    
catch e
    disp(e.message)
end