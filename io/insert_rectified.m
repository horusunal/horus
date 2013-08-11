function [varargout] = insert_rectified(conn, station, type, timestamp, ismini, filename, path, idcalibration )

%INSERT_RECTIFIED this function is used for inserting a new rectified image
%in the database.
%
%   Input:
%   conn: Database connection which must have been previously created.
%	station: is the name of the station.
%   type: Is the id which represents the image type.
%   timestamp: The date of the image represents the number of days from
%              January 1 of year 0 plus 1. This is the same format used by the MATLAB function
%              DATENUM. The hours, minutes, seconds are decimal in
%              this case.
%   ismini: Boolean attribute indicating whether or not the image is a
%           miniature.
%   filename: image filename.
%   path: Location of image file.
%   idcalibration: Represents the parameters used to rectify the image.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the insertion was
%   successful, 1 otherwise.
%
%   Example:
%   insert_rectified(conn, 'CARTAGENA', 2, 734688.549, 0, '09.12.04.19.00.00.GMT.Cartagena.C1.Snap.1024X768.HORUS.jpg', '/home/horus/images/', 3);
%
%   See also INSERT_IMAGETYPE, INSERT_MERGED, INSERT_OBLIQUE,
%   INSERT_roi, INSERT_STATION, INSERT_TIMESTACK

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/21 10:20 $

% connection to the database

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
    
    %   name of the parameter of te table
    colnames_ima={'type','timestamp','ismini','filename','path'};
    colnames_rect = {'filename', 'calibration'};
    %   data to insert
    data_ima = {type,timestamp,ismini,filename,path};
    try
        fastinsert(conn, ['image_' station],colnames_ima,data_ima);
        
        %       data to insert
        data_rect = {filename, idcalibration};
        try
            fastinsert(conn, ['rectifiedimage_' station],colnames_rect,data_rect);
            if nargout==1
                varargout(1)={0};
            end
            
        catch e
            disp([dberror('insert') e.message]);
        end
        
    catch e
        disp([dberror('insert') e.message]);
    end
    
catch e
    disp(e.message)
end

end