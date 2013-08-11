function [varargout] = insert_image_by_file_rect(conn, station, filename, path)

%INSERT_IMAGE_BY_FILE_RECT   Inserts a rectified image in the database given the
%filename. This filename is split up into pieces that correspond to the
%image information.
%
% Requirements: - The image format must conform to HORUS image format:
%      YY.MM.DD.HH.mm.SS.GMT.station.camera.imgtype.RECT.HORUS.ext
%
% Input:
%   'conn' is the object that contains the database connection.
%	'station' is the name of the station.
%   'filename' is the name of the image file
%       (e.g. 11.09.23.12.00.00.GMT.Cartagena.C1.Timex.RECT.HORUS.jpg)
%   'path' is the path relative to current directory of the image.
%
% Output:
%   'varargout': The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the insertion was
%   successful, 1 otherwise.
%
%   Example:
%       insert_image_by_file_rect(conn, 'CARTAGENA', '10.05.02.13.00.00.GMT.Cartagena.C1.Timex.RECT.HORUS.jpg', 'CARTAGENA\2010\05\02\C1')

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/10/28 09:54 $

try
    station = upper(station);
    if nargout==1
        varargout(1)={1}; % Initially, failure
    end
    
    % Split the filename
    info = split_filename(filename);
    
    typeids = load_imagetype_ids(conn, station, info.imgtype);
    
    if isempty(typeids)
        disp([dberror('insert') 'The image type does not exist yet!'])
        return
    end
    
    type = typeids{1};
    
    % image time
    timestamp = datenum(info.year, info.month, info.day, ...
        info.hour, info.min, info.sec);
    ismini = info.ismini; % Initially, thumbnails are not inserted into the database
    camera = info.cam;
    
    %   name of the parameter table parameters
    colnames_ima={'type','timestamp','ismini','filename','path'};
    colnames_rect = {'filename', 'calibration'};
    
    query=['SELECT idcalibration, timestamp FROM calibration_' station ' WHERE '...
        'station LIKE "' station '" AND camera LIKE "' camera '" AND timestamp <= '...
        mat2str(timestamp)];
    
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    try
        result = get(fetch(exec(conn, query)), 'Data');
        result2 = cell2mat(result(:,2));
        [m2 pos]=min(abs(result2-timestamp));
        idcalibration=cell2mat(result(pos,1));
    catch e
        disp([dberror('select') e.message]);
    end
    
    %   data to insert
    data_ima = {type,timestamp,ismini,filename,path};
    try
        fastinsert(conn, ['image_' station],colnames_ima,data_ima);
        %       data to insert
        data_rect = {filename, idcalibration};
        try
            fastinsert(conn, ['rectifiedimage_' station],colnames_rect,data_rect);
            if nargout==1
                varargout(1)={0}; % Success
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