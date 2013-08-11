function [varargout] = update_timestack(conn, station, filename, varargin)

%UPDATE_TIMESTACK   Update a tuple in the table timestack
%   UPDATE_TIMESTACK(conn, station, filename, varargin) updates the tuple identified by
%   'filename'. Any attribute can be updated and they are given by varargin.
%   The attributes are given as pairs {'AttributeName', 'AttributeValue'}.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: station name.
%   filename: This is the filename of the timestack.
%   varargin: The attributes are given as pairs {'AttributeName', 'AttributeValue'}.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the update was
%   successful, 1 otherwise.
%
%   Example:
%      status =  update_timestack(conn, 'CARTAGENA','10.02.24.12.30.00.GMT.Cartagena.C2.Stack.800X600.avi',
%      'path', '/home/horus/timestack', 'fps', 2);
%

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/22 10:00 $

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
        % Data for updating a Timestack in the database
        colnames = cell(0);
        extdata = cell(0);
        whereclause = ['WHERE filename LIKE "' filename '"'];
        
        if ~isvalidoption('timestack', varargin{:})
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
        
        update(conn, ['timestack_' station], colnames, extdata, whereclause);
        if nargout==1
            varargout(1)={0};
        end
    catch e
        disp([dberror('update') e.message]);
    end
    
catch e
    disp(e.message)
end