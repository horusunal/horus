function [varargout] = update_pickedgcp(conn, idcal, gcp, station, varargin)

%UPDATE_PICKEDgcp   Update a tuple in the table pickedgcp
%   UPDATE_PICKEDgcp(conn, idcal, gcp, station, varargin) updates the tuple
%   identified by 'idcal', 'gcp' and 'station'. Any attribute can be
%   updated and they are given by varargin.
%   The attributes are given as pairs {'AttributeName', 'AttributeValue'}.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   idcal: ID of the calibration.
%   gcp: ID of the gcp.
%   station: This is the station where is the gcp and the calibration.
%   varargin: The attributes are given as pairs {'AttributeName', 'AttributeValue'}.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the update was
%   successful, 1 otherwise.
%
%   Example:
%       status = update_pickedgcp(conn, 3, 10, 'CARTAGENA', 'u', 111, 'v', 435);
%

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/22 10:45 $

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
        % Data for updating a pickedgcp in the database
        colnames = cell(0);
        extdata = cell(0);
        whereclause = ['WHERE calibration LIKE "' idcal ...
            '" AND gcp = ' num2str(gcp) ' AND  station LIKE "' station '"'];
        
        if ~isvalidoption('pickedgcp', varargin{:})
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
        
        update(conn, ['pickedgcp_' lower(station)], colnames, extdata, whereclause);
        if nargout==1
            varargout(1)={0};
        end
    catch e
        disp([dberror('update') e.message]);
    end
    
catch e
    disp(e.message)
end