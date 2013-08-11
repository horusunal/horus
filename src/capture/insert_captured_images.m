function insert_captured_images(station, cameras)
%INSERT_CAPTURED_IMAGES   Inserts captured images into the database.
%
% Input:
%   station: name of the station (e.g. 'CARTAGENA')
%   cameras: List of the cameras as a cell array.
%
% Example:
%   insert_captured_images('CARTAGENA', {'C1', 'C2', 'C3'})

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2012 HORUS
%   $Date: 2012/08/04 12:27 $

try
    
    % Set HORUS paths
    if ~isdeployed
        root = fileparts(mfilename('fullpath'));
        root = fileparts(root);
        root = fileparts(root);
        addpath(genpath(root));
    end
    
    if isdeployed
        pathinfo = what('tmp');
        tmppath = pathinfo.path;
    else
        tmppath = fullfile(root, 'tmp');
    end
    
    % Create a database connection
    try
        conn = connection_db(false);
    catch e
        disp(e.message)
        return
    end
    
    types = load_imagetype_name(conn, station);
    
    pathSendError = fullfile(tmppath, 'DATASENDERRORS.mat');
    
    numImages = 0;
    for i = 1:numel(cameras)
        cam = cameras{i};
        pathList = fullfile(tmppath, ['ListImage' cam '.mat']);
        if exist(pathList, 'file')
            load(pathList)
            ind1 = find(cell2mat(ListImage(:, 3)) == 1); %Number of images to insert for cam1
            numImages = max(numImages, length(ind1));
        end
    end
    
    for j = 1:numImages %Repeat the transfer for all images
        for i = 1:numel(cameras)
            cam = cameras{i};
            pathList = fullfile(tmppath, ['ListImage' cam '.mat']);
            if exist(pathList, 'file')
                load(pathList)
            else
                continue
            end
            
            ind = find(cell2mat(ListImage(:, 3)) == 1);
            if isempty(ind)
                continue
            end
            posI = min(ind);
            disp(['Saving image ' ListImage{posI, 2} ' in the database'])
            image = ListImage{posI, 2};
            textDate = image(1:8);
            textDate = datestr(datenum(textDate, 'yy.mm.dd'), 'yyyy.mm.dd');
            textDate = strrep(textDate, '.', filesep);
            pathImage = [station filesep textDate filesep cam];
            
            parts = regexp(image, '\.', 'split');
            imgtype = parts{10};
            
            % If the image type does not exist, create it
            if ~strcmpi(imgtype, types)
                failed = insert_imagetype(conn, imgtype, station);
                if failed
                    continue
                end
                types{end + 1} = imgtype;
            end
            
            typeids = load_imagetype_ids(conn, station, imgtype);
            
            if isempty(typeids)
                disp([dberror('insert') 'The image type does not exist yet!'])
                continue
            end
            
            type = typeids{1};
            
            timestamp = datenum(image(1:17), 'yy.mm.dd.HH.MM.ss');
            
            status = insert_oblique(conn, type, timestamp, false, image, pathImage, cam, station );
            
            if status == 0
                disp([ListImage{posI,2} ' image saved'])
                try
                    % Put a 2 on the List of Images
                    ListImage{posI, 3} = 2;
                    
                    ind = find(cell2mat(ListImage(:, 3)) ~= 2); %Number of images to insert for cam
                    delete(pathList)
                    if ~isempty(ind)
                        ListImage = ListImage(ind, :);
                        save(pathList, 'ListImage');
                    end
                catch ME
                    message=ME.message;
                    
                    error(1,1:2)={datestr(now), message};
                    
                    if ~exist(pathSendError, 'file')
                        Errors = cell(0);
                    else
                        load(pathSendError);
                    end
                    
                    Errors(end+1, :) = error;
                    
                    save(pathSendError, 'Errors');
                end
            else
                disp([ListImage{posI,2} ' could not be saved'])
            end
        end
    end
    
catch e
    disp(e.message)
end