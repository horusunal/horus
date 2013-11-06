function [varargout] = insert_pickedgcp(conn, idcalibration, idgcp, station, u, v)

%INSERT_PICKEDgcp   Insert a new tuple in the table pickedgcp
%   INSERT_PICKEDgcp(conn, idcalibration, idgcp, station, u, v)
%   inserts the tuple identified by the calibration id, gcp id and station
%   name.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   idcalibration: id of the calibration.
%   idgcp: numeric id of a gcp within a station.
%   station: is the name of the station.
%   'u', 'v': are the pixel coordinates of the gcp transformed by the
%   calibration parameters.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the insertion was
%   successful, 1 otherwise.
%
%   Example:
%       insert_pickedgcp(conn, 'CRTG00012', 32, 'CARTAGENA', 123, 345)
%

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/27 16:18 $

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
        % Data for insertion in pickedgcp
        colnames = {'calibration', 'gcp', 'station', 'u', 'v'};
        extdata = {idcalibration, idgcp, station, u, v};
        
        fastinsert(conn, ['pickedgcp_' lower(station)], colnames, extdata);
        if nargout==1
            varargout(1)={0};
        end
    catch e
        disp([dberror('insert') e.message]);
    end
    
catch e
    disp(e.message)
end