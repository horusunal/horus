function [varargout] = insert_common_point(conn, station, camera, idfusion, name, u, v)

%INSERT_COMMON_POINT   Insert a new tuple in the table commonpoint
%   Input:
%   conn: Database connection which must have been previously created.
%   station: is the name of the station.
%   camera: camera id.
%   idfusion: ID of the corresponding fusion.
%   name: name of the common point (e.g. NEW0001)
%   u: U coordinate.
%   v: V coordinate.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the insertion was
%   successful, 1 otherwise.
%
%   Example:
%       insert_common_point(conn, 'CARTAGENA', 'C1', 'CRTG00002', 'NEW0001',
%                           120, 700)
%

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2012 HORUS
%   $Date: 2012/07/03 16:56 $

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
        % Data for insertion in fusion
        colnames = {'idfusion', 'camera', 'station', 'name', 'u', 'v'};
        extdata = {idfusion, camera, station, name, u, v};
        
        fastinsert(conn, ['commonpoint_' station], colnames, extdata);
        
    catch e
        disp([dberror('insert') e.message]);
        return;
    end
    
    if nargout==1
        varargout(1)={0};
    end
    
catch e
    disp(e.message)
end