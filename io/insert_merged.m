function [varargout] = insert_merged(conn, station, type, timestamp, ismini, filename, path, idfusion )

%INSERT_MERGED this function is used for inserting a merged image's
%information in the database.
%
%   Input:
%   conn: is the object that contains the database connection.
%	station: is the name of the station.
%   type: Is the id which represents the image type.
%   timestamp: The date of the image represents the number of days from
%              January 1 of year 0 plus 1. This is the same format used by the MATLAB function
%              DATENUM. The hours, minutes, seconds are decimal in
%              this case.
%   ismini: Boolean attribute indicating whether or not the image is a
%           thumbnail.
%   filename: image filename.
%   path: Location of image file.
%   idfusion: Represents the parameters used to merge multiple images.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the insertion was
%   successful, 1 otherwise.
%
%   Example:
%   insert_merged( conn, 'CARTAGENA', 2, 734688.549, 0, '09.12.04.19.00.00.GMT.Cartagena.Snap.PAN.HORUS.jpg', '/home/horus/images/', 3);
%
%   See also INSERT_IMAGETYPE, INSERT_OBLIQUE,
%   INSERT_RECTIFIED, INSERT_roi, INSERT_STATION, INSERT_TIMESTACK

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/21 9:30 $

try
    station = upper(station);
    % connection to the database
    
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
    colnames_merged = {'filename', 'idfusion'};
    %   data to insert
    data_ima = {type,timestamp,ismini,filename,path};
    try
        fastinsert(conn, ['image_' lower(station)],colnames_ima,data_ima);
        %       data to insert
        data_merged = {filename, idfusion};
        try
            fastinsert(conn, ['mergedimage_' lower(station)],colnames_merged,data_merged);
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

