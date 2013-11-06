function [varargout] = update_gcp(conn, idgcp, station, varargin)

%UPDATE_gcp   Update a tuple in the table gcp
%   UPDATE_gcp(conn, idgcp, station, varargin) updates the tuple identified by
%   'idgcp' and 'station'. Any attribute can be updated and they are given
%   by varargin.
%   The attributes are given as pairs {'AttributeName', 'AttributeValue'}.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   idgcp: ID of the gcp.
%   station: This is the station where is the gcp.
%   varargin: The attributes are given as pairs {'AttributeName', 'AttributeValue'}.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the update was
%   successful, 1 otherwise.
%
%   Example:
%      status = update_gcp(conn, 13, 'CARTAGENA', 'name', 'gcp020', 'z', 1.0);
%

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/22 10:38 $

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
        % Data for updating a gcp in the database
        colnames = cell(0);
        extdata = cell(0);
        whereclause = ['WHERE idgcp = ' num2str(idgcp) ' AND station LIKE "' station '"'];
        
        if ~isvalidoption('gcp', varargin{:})
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
        
        update(conn, ['gcp_' lower(station)], colnames, extdata, whereclause);
        if nargout==1
            varargout(1)={0};
        end
        
    catch e
        disp([dberror('update') e.message]);
    end
    
catch e
    disp(e.message)
end