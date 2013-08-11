function [varargout] = insert_camera(conn, id, station, reference, sizeX, sizeY)

%INSERT_CAMERA   Insert a new tuple in the table camera
%   INSERT_CAMERA(conn, id, station, reference,sizeX, sizeY)
%   inserts the tuple identified by a character id
%
%   Input:
%   conn: Database connection which must have been previously created.
%   id: name of the camera.
%   station: is the name of the station.
%   reference: name of the camera's model or brand.
%   sizeX: number of pixels that the camera sensor can capture
%   horizontally.
%   sizeY: number of pixels that the camera sensor can capture
%   vertically.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the insertion was
%   successful, 1 otherwise.
%
%   Example:
%       insert_camera(conn, 'C2', 'CARTAGENA', 'Marlin', 1024, 768)
%

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/27 15:28 $

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
        % Data for insertion in camera
        colnames = {'id', 'station', 'reference','sizeX', 'sizeY'};
        extdata = {id, station, reference, sizeX, sizeY};
        
        fastinsert(conn, ['camera_' station], colnames, extdata);
        if nargout==1
            varargout(1)={0};
        end
    catch e
        disp([dberror('insert') e.message]);
    end
    
catch e
    disp(e.message)
end