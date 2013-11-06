function [varargout] = insert_image_by_file_merged_obli(conn, station, filename, path)

%INSERT_IMAGE_BY_FILE_MERGED_OBLI   Inserts a merged oblique image in the database given the
%filename. This filename is split up into pieces that correspond to the
%image information.
%
% Requirements: - The image format must conform to HORUS image format:
%      YY.MM.DD.HH.mm.SS.GMT.station.imgtype.PAN.HORUS.ext
%
% Input:
%   conn: Database connection which must have been previously created.
%	station: is the name of the station.
%   filename: is the name of the image file
%       (e.g. 11.09.23.12.00.00.GMT.CARTAGENA.C1.snap.1024X768.HORUS.jpg)
%   path: is the path relative to current directory of the image.
%
% Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the insertion was
%   successful, 1 otherwise.
%
%   Example:
%       insert_image_by_file_merged_obli(conn, 'CARTAGENA', '10.05.02.13.00.00.GMT.Cartagena.Snap.PAN.HORUS.jpg', 'CARTAGENA\2010\05\02')

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
    
    %   name of the parameter table parameters
    colnames_ima={'type','timestamp','ismini','filename','path'};
    colnames_pan = {'filename','idfusion'};
    
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end    
    
    query=['SELECT id, timestamp FROM fusion_' lower(station) ' WHERE type LIKE "oblique" '...
        'AND timestamp <= ' mat2str(timestamp)];
    try
        result = get(fetch(exec(conn, query)), 'Data');
        result2 = cell2mat(result(:,2));
        [m2 pos]=min(abs(result2-timestamp));
        idfusion=cell2mat(result(pos,1));
    catch e
        disp([dberror('select') e.message]);
    end
    %   data to insert
    data_ima = {type,timestamp,ismini,filename,path};
    try
        fastinsert(conn, ['image_' lower(station)],colnames_ima,data_ima);
        
        data_pan = {filename, idfusion};
        try
            fastinsert(conn, ['mergedimage_' lower(station)],colnames_pan,data_pan);
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