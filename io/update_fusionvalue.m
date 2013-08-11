function [varargout] = update_fusionvalue(conn, station, idmatrix, idcol, idrow, varargin)

%UPDATE_FUSIONVALUE   Update a tuple in the table fusionvalue
%   UPDATE_FUSIONVALUE(conn, station, idmatrix, idcol, idrow, varargin) updates the tuple
%   identified by 'idmatrix', 'idcol' and 'idrow'. Any attribute can be
%   updated and they are given by varargin.
%   The attributes are given as pairs {'AttributeName', 'AttributeValue'}.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: Name of the station.
%   idmatrix: ID of the parameter.
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
%      status = update_fusionvalue(conn, 'CARTAGENA', 3, 2, 2, 'value', 0.04987432);
%

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/22 10:36 $

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
        % Data for updating a fusionvalue in the database
        colnames = cell(0);
        extdata = cell(0);
        whereclause = ['WHERE idmatrix LIKE "' idmatrix '" AND idcol = ' ...
            num2str(idcol) ' AND idrow = ' num2str(idrow)];
        
        if ~isvalidoption('fusionvalue', varargin{:})
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
        
        update(conn, ['fusionvalue_' station], colnames, extdata, whereclause);
        if nargout==1
            varargout(1)={0};
        end
    catch e
        disp([dberror('update') e.message]);
    end
    
catch e
    disp(e.message)
end