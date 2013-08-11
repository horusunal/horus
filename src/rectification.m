function message = rectification(station, imgtype, camera, ti, tf, step, error,...
    show_waitbar, resultslocation, saveDB, roi, custime)

%RECTIFICATION   Do the process of rectification for a set of images
%returned by the search process.
%
% Input:
%   station: name of the station (e.g. 'CARTAGENA')
%   imgtype: type of the images to be rectified (e.g. 'snap', 'timex' or 'var')
%   camera:  id of the camera (e.g. 'C1')
%   ti:      initial image search time in the format of DATENUM
%   tf:      final image search time in the format of DATENUM
%   step:    step size of the image search (given in minutes)
%   error:   margin of error for image search (given in minutes)
%   show_waitbar: Boolean value, true if a wait bar showing the process is
%                 to be displayed, false otherwise
%   resultslocation: Path where the images should be saved
%   saveDB:  Boolean value, true if the images will be saved in the
%            database, false otherwise
%   roi:     A ROI, this is optional, in case it is empty, the ROI will be
%            loaded from database.
%   custime: Optional parameter. Time for choosing a calibration, if empty
%            select the nearest before image time.
%
% Output:
%   message: Error message, if no error this is empty

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/10/28 17:04 $

% function rectification

try
    
    % Set HORUS paths
    if ~isdeployed
        root = fileparts(mfilename('fullpath'));
        root = fileparts(root);
        addpath(genpath(root));
    end
    
    message = [];
    
    % Default path where oblique images are located
    if ~exist('path_info.xml', 'file')
        message = 'The file path_info.xml does not exist!';
        return;
    end
    [pathOblique] = load_paths('path_info.xml', station);
    root = pathOblique; %% ROOT
    
    try
        conn = connection_db();
    catch e
        disp(e.message)
        return
    end
    
    % Build the times when the images will be searched
    time = ti:step/(60*24):tf;
    error = error/(60*24);
    
    % Search and load all images
    images = load_image_step(conn, {imgtype}, camera, station, time, error);
    
    if isempty(images)
        message = 'No images were found in the database!';
        close(conn)
        return;
    end
    
    [m n] = size(images);
    
    % If a wait bar is to be displayed
    if show_waitbar
        h = waitbar(0, {'Rectifying images from ' datestr(ti) ' to ' datestr(tf)}, ...
            'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
        setappdata(h,'canceling',0)
    end
    
    loadroi = isempty(roi);
    
    % Process each image
    for i = 1:m
        current = images(i, :);
        
        filename = strtrim(current{1});
        location =         current{2};
        t        =         current{3};
        
        % If anything wrong, go with the next image
        if filesep == '/' | strfind(root,'http://')
            changeFrom = '\';
            changeTo = '/';
        else
            changeFrom = '/';
            changeTo = '\';
        end
        
        imglocation = strrep(fullfile(root, location, filename), changeFrom, changeTo);
        if isempty(strfind(root, 'http://'))
            if ~exist(imglocation, 'file')
                disp(['ERROR: Image file not found: ' imglocation]);
                continue;
            end
        end
        
        % If we are here, everything went OK
        % Load image
        img = imread(imglocation);
        
        if isempty(custime)
            % Load the nearest calibration before t
            calibration = load_calibration(conn, station, camera, t);
        else
            calibration = load_calibration(conn, station, camera, custime);
        end
        
        if isempty(calibration)
            disp('ERROR: No calibration was found in the database!');
            continue;
        end
        
        resolution = calibration{3};
        
        % Extract the parameters H, K and D
        len = size(calibration, 2);
        H = [];
        K = [];
        D = [];
        for k = 1:len
            if strcmp(calibration{k}, 'H')
                H = calibration{k + 1};
            end
            if strcmp(calibration{k}, 'K')
                K = calibration{k + 1};
            end
            if strcmp(calibration{k}, 'D')
                D = calibration{k + 1};
            end
        end
        
        if loadroi
            if isempty(custime)
                % Load the nearest rectification ROI before t
                roi = load_roi(conn, 'rect', camera, station, t, t);
            else
                roi = load_roi(conn, 'rect', camera, station, custime, custime);
            end
            
            if isempty(roi)
                disp('ERROR: No ROI was found!');
                continue;
            end
            
            uroi = cell2mat(roi(:, 4)); % U coordinates
            vroi = cell2mat(roi(:, 5)); % V coordinates
            zroi = 0;           % level value, fixed
        else
            uroi = roi(:, 1); % U coordinates
            vroi = roi(:, 2); % V coordinates
            zroi = 0;           % level value, fixed
        end
        
        
        
        % Rectify image
        [u v rectimg] = rectify(img, H, K, D, [uroi vroi], zroi, resolution, false);
        
        if show_waitbar
            if getappdata(h,'canceling')
                break
            end
            waitbar(i / m, h, {'Rectifying images from ' datestr(ti) ' to '...
                [datestr(tf) ' (' num2str(100 * i / m, '%.1f') '%)']});
        end
        
        % Save rectified image in file disk
        save_rectified(rectimg, t, station, camera, imgtype, resultslocation);
        
        if saveDB
            % resultslocation = fullfile(root, station, YYYY, mm, DD);
            filename = [datestr(t, 'YY.mm.DD.HH.MM.SS') '.GMT.' ...
                upper(station(1)) lower(station(2:end)) '.' camera '.' ...
                upper(imgtype(1)) lower(imgtype(2:end)) ...
                '.RECT.HORUS.jpg'];            
            check = check_image(conn, filename, station);
            if ~check
                
                path = fullfile(station, num2str(year(t)), num2str(month(t), '%02d'), num2str(day(t), '%02d'), camera);
                % Actually insert the image in the database
                typeids = load_imagetype_ids(conn, station, imgtype);

                if isempty(typeids)
                    failed = insert_imagetype(conn, imgtype, station);
                    if failed
                        continue
                    end
                end

                typeids = load_imagetype_ids(conn, station, imgtype);
                typenum = typeids{1};

                status = insert_rectified(conn, station, typenum, t, false, filename, path, calibration{1});
                if status == 1
                    disp(['ERROR: ' filename ' could not be inserted in the database!']);
                    continue;
                end
            end
        end
    end
    
    if show_waitbar
        delete(h)
    end
    
    close(conn)
    
catch e
    disp(e.message)
end


%--------------------------------------------------------------------------
% Save a rectified image in file disk
function save_rectified(rectimg, t, station, camera, imgtype, resultslocation)
% Input:
%   rectimg: Rectified image
%   t: Image time
%   station: Station name
%   camera: Camera ID
%   imgtype: Image type
%   resultslocation: Directory where the image is to be saved


try
    
    load('horusvideo.mat');
    mm = size(rectimg, 2);
    
    scale = mm / (3 * size(I, 2));
    I = imresize(I, scale);
    
    rectimg(end - size(I, 1) + 1:end, ...
        round((mm - size(I, 2)) / 2) + 1:round((mm + size(I, 2)) / 2), :) = I;
    
    YYYY = num2str(year(t));
    mm = num2str(month(t), '%02d');
    DD = num2str(day(t), '%02d');
    
    resultslocation = fullfile(resultslocation, station, YYYY, mm, DD, camera);
    filename = [datestr(t, 'YY.mm.DD.HH.MM.SS') '.GMT.' ...
        upper(station(1)) lower(station(2:end)) '.' camera '.' ...
        upper(imgtype(1)) lower(imgtype(2:end)) ...
        '.RECT.HORUS.jpg'];
    
    if ~exist(resultslocation, 'dir')
        mkdir(resultslocation);
    end
    
    imwrite(rectimg, fullfile(resultslocation, filename), 'JPEG', 'Quality', 100)
    
    disp(['Saved image ' filename]);
    
catch e
    disp(e.message)
end