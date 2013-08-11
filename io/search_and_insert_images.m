function search_and_insert_images(root, station, path, type)

%SEARCH_AND_INSERT_IMAGES   Recursively searches images within a directory
%tree and inserts it in the database.
%
% Requirements: - The database must be correctly set up, and the station and
% cameras corresponding to all images must be present in the database.
%               - The image format must conform to HORUS image format:
%      YY.MM.DD.HH.mm.SS.GMT.station.camera.imgtype.widthXheight.HORUS.ext
%
% Input:
%   root: is the root directory (parent of the station directories, e.g.
%   C:\dbimage).
%   station: Name of the station.
%   path: is where the search should start. If the search is for ALL the
%   stations, path = ''. If the search is for a specific station, path =
%   'station name' (e.g. path = 'CARTAGENA')
%   type: type of image to be inserted into the database must be:
%           'oblique', 'rectified', 'merge_oblique' or 'merge_rectified'
%
% Assuming that all requirements are fulfilled, every image will be
% inserted into the database.

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/10/28 09:54 $

try
    station = upper(station);
    % Attempts to create a connection
    
    S = dir(fullfile(root, path));
    
    conn  = connection_db();
    if ~isconnection(conn)
        
        disp([dberror('conn') conn.Message]);
        return;
    end
    
    types = load_imagetype_name(conn, station);
    
    for i = 3:numel(S)
        if S(i).isdir
            search_and_insert_images(root, station, fullfile(path, S(i).name), type);
        else
            parts = regexp(S(i).name, '\.', 'split');
            ext = parts(end);
            if ~strcmpi(ext, 'jpg') && ~strcmpi(ext, 'jpeg') && ...
                    ~strcmpi(ext, 'png')
                continue;
            end
            data = split_filename(S(i).name);
            imgtype = data.imgtype;
            
            if ~strcmpi(imgtype, types)
                failed = insert_imagetype(conn, imgtype, station);
                if failed
                    continue
                end
                types{end + 1} = imgtype;
            end
            
            failed = true;
            if strcmp(type,'oblique')
                failed = insert_image_by_file_obli(conn, station, S(i).name, path);
            elseif strcmp(type,'rectified')
                failed = insert_image_by_file_rect(conn, station, S(i).name, path);
            elseif strcmp(type,'merge_oblique')
                failed = insert_image_by_file_merged_obli(conn, station, S(i).name, path);
            elseif strcmp(type,'merge_rectified')
                failed = insert_image_by_file_merged_rect(conn, station, S(i).name, path);
            end
            
            if failed
                disp([dberror('insert') S(i).name]);
            else
                disp(['image ' S(i).name ' successfully inserted!']);
            end
            
        end
    end
    close(conn)
    
catch e
    disp(e.message)
end