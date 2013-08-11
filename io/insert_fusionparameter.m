function [varargout] = insert_fusionparameter(conn, station, idfusion, name, value)

%INSERT_FUSIONPARAMETER   Insert a new tuple in the table fusionparameter and
%several tuples in fusionvalue corresponding to a matrix.
%   INSERT_FUSIONPARAMETER(conn, station, idfusion, name, value)
%
%   Input:
%   conn: Database connection which must have been previously created.
%	station: is the name of the station.
%   idfusion: numeric id of the fusion.
%   name: is the name of the parameter.
%   value: matrix that contains the actual value.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the insertion was
%   successful, 1 otherwise.
%
%   Example:
%       insert_fusionparameter(conn, 'CARTAGENA', 20, 'K', [1 2 3; 4 5 6; 7 8 9])
%

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/27 16:06 $

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
        % Data for insertion in fusionparameter
        newid  = generate_autoinc(conn, ['fusionparameter_' station], 'id', station);
        
        colnames = {'id', 'idfusion', 'name'};
        extdata = {newid, idfusion, name};
        
        fastinsert(conn, ['fusionparameter_' station], colnames, extdata);
        
        % Insertion in fusionvalue
        [m, n] = size(value);
        % Every matrix element is inserted as an independent row
        for r = 1:m
            for c = 1:n
                colnames = {'idmatrix', 'idcol', 'idrow', 'value'};
                extdata = {newid, c, r, value(r, c)};
                
                fastinsert(conn, ['fusionvalue_' station], colnames, extdata);
                if nargout==1
                    varargout(1)={0};
                end
            end
        end
        
    catch e
        disp([dberror('insert') e.message]);
    end
    
catch e
    disp(e.message)
end