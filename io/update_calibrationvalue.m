function [varargout] = update_calibrationvalue(conn, station, idparam, idcol, idrow, varargin)

%UPDATE_CALIBRATIONVALUE   Update a tuple in the table calibrationvalue
%   UPDATE_CALIBRATIONVALUE(conn, station, idparam, idcol, idrow, varargin) updates the
%   tuple identified by 'idparam', 'idcol' and 'idrow'. Any attribute can
%   be updated and they are given by varargin.
%   The attributes are given as pairs {'AttributeName', 'AttributeValue'}.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: Name of the station.
%   idparam: ID of the parameter.
%   idcol: ID of the column.
%   idrow: ID of the row.
%   varargin: The attributes are given as pairs {'AttributeName', 'AttributeValue'}.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the update was
%   successful, 1 otherwise.
%
%   Example:
%       status = update_calibrationvalue(conn, 3, 1, 1, 'value', 0.0786465754);
%

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/22 10:43 $

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
        % Data for updating a calibrationvalue in the database
        colnames = cell(0);
        extdata = cell(0);
        whereclause = ['WHERE idparam LIKE "' idparam '" AND idcol = ' ...
            num2str(idcol) ' AND idrow = ' num2str(idrow)];
        
        if ~isvalidoption('calibrationvalue', varargin{:})
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
        
        update(conn, ['calibrationvalue_' lower(station)], colnames, extdata, whereclause);
        if nargout==1
            varargout(1)={0};
        end
    catch e
        disp([dberror('update') e.message]);
    end
    
catch e
    disp(e.message)
end