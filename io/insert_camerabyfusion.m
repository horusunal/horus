function [varargout] = insert_camerabyfusion(conn, idfusion, camera, station, sequence)

%INSERT_CAMERABYFUSION   Insert a new tuple in the table camerabyfusion
%   INSERT_CAMERABYFUSION(conn, idfusion, camera, station, sequence)
%   inserts the tuple identified by the fusion id, camera id and station
%   name.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   idfusion: numeric id of the fusion.
%   camera: id of the camera.
%   station: is the name of the station.
%   sequence: the order in the sequence for merging the images of the
%   different cameras.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the insertion was
%   successful, 1 otherwise.
%
%   Example:
%       insert_camerabyfusion(conn, 12, 'C3', 'CARTAGENA', 2)
%

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/27 15:42 $

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
        % Data for insertion in camerabyfusion
        colnames = {'idfusion', 'camera', 'station', 'sequence'};
        extdata = {idfusion, camera, station, sequence};
        
        fastinsert(conn, ['camerabyfusion_' lower(station)], colnames, extdata);
        if nargout==1
            varargout(1)={0};
        end
    catch e
        disp([dberror('insert') e.message]);
    end
    
catch e
    disp(e.message)
end