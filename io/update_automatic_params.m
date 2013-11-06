function [varargout] = update_automatic_params(conn, station, idauto, varargin)

%UPDATE_AUTOMATIC_PARAMS   Updates a set of capture parameters
%   UPDATE_AUTOMATIC_PARAMS(conn, station, idauto, varargin)
%   updates the tuple identified by a station and an ID. Any attribute can be
%   updated and they are given by varargin.
%   The attributes are given as pairs {'AttributeName', 'AttributeValue'}.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: Name of the station.
%   idauto: ID of the capture.
%   varargin: The attributes are given as pairs {'AttributeName', 'AttributeValue'}.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the update was
%   successful, 1 otherwise.
%
%   Example:
%   status = update_automatic_params(conn, 2, 'step', 15);

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/12/06 14:17 $

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
        colnames = cell(0);
        extdata = cell(0);
        whereclause = ['WHERE idauto = ' num2str(idauto)];
        
        if ~isvalidoption('automaticparams', varargin{:})
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
        
        update(conn, ['automaticparams_' lower(station)], colnames, extdata, whereclause);
        if nargout==1
            varargout(1)={0};
        end
        
    catch e
        disp([dberror('update') e.message]);
    end
    
catch e
    disp(e.message)
end