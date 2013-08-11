function message = fusion(station, imgtype, isrectified, dorectify, ti, tf, step, error, ...
    show_waitbar, resultslocation, saveDB, custime)

%FUSION   Do the process of fusion for a set of images returned by the
%search process.
%
% Input:
%   station: name of the station (e.g. 'CARTAGENA')
%   imgtype: type of the images to be rectified (e.g. 'snap', 'timex' or 'var')
%   isrectified: True if merge rectified images, false otherwise
%   dorectify: True if rectify before merge, false otherwise
%   ti:      initial image search time in the format of DATENUM
%   tf:      final image search time in the format of DATENUM
%   step:    step size of the image search (given in minutes)
%   error:   margin of error for image search (given in minutes)
%   show_waitbar: Boolean value, true if a wait bar showing the process is
%                 to be displayed, false otherwise
%   resultslocation: Path where the images should be saved
%   saveDB:  Boolean value, true if the images will be saved in the
%            database, false otherwise
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
    [pathOblique, pathRectified] = load_paths('path_info.xml', station);
    root = pathOblique; %% ROOT
    
    try
        conn = connection_db();
    catch e
        disp(e.message)
        return
    end
    
    % Be sure to not rectify already rectified images
    if isrectified
        dorectify = false;
        root = pathRectified;
    end
    
    % Load the cameras that participate in the fusion sorted
    if isrectified
        imgtype2 = 'rectified';
    else
        imgtype2 = 'oblique';
    end
    
    cameras = load_camerasbyfusion(conn, station, imgtype2, tf);
    
    if isempty(cameras)
        message = 'No cameras are associated to this fusion in the database!';
        close(conn)
        return;
    end
    
    ncams = numel(cameras);
    
    % Load all images of the specific type and interval for the first camera
    time = ti:step/(60*24):tf;
    
    if isrectified
        images = load_image_rectified_step(conn, {imgtype}, cameras{1}, station, time, error/(60*24));
    else
        images = load_image_step(conn, {imgtype}, cameras{1}, station, time, error/(60*24));
    end
    
    if isempty(images)
        message = 'No images were found in the database!';
        close(conn)
        return;
    end
    
    % Build time array
    [m n] = size(images);
    
    times = zeros(m, 1);
    for i = 1:m
        current = images(i, :);
        times(i) = current{3};
    end
    
    % Load for every time, the images that are present at that time for all the
    % cameras that participate in fusion
    selected = load_imagecam(conn, {imgtype}, station, imgtype2, times, error);
    
    if isempty(selected)
        message = 'No images were found for all cameras in the database!';
        close(conn)
        return;
    end
    
    % The selected images are presented in groups of 'ncams' images, one per row
    % Merge each group of images
    [m n] = size(selected);
    
    % If a wait bar is to be displayed
    if show_waitbar
        h = waitbar(0, {'Merging images from ' datestr(ti) ' to ' datestr(tf)}, ...
            'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
        setappdata(h,'canceling',0)
    end
    
    first = true;
    
    % Process each group of images
    for i = 1:ncams:m
        
        imgset = cell(0);
        time = Inf; % Minimum time among the to-be-merged-image times
        
        ok = true;
        for j = 1:ncams
            current = selected(i + j - 1, :);
            
            filename = strtrim(current{1});
            location = current{2};
            t = current{3};
            camera   = current{4};
            
            time = min(time, t);
            
            % If anything wrong, go with the next image set
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
                    ok = false;
                    disp(['ERROR: Image file not found: ' imglocation]);
                    break;
                end
            end
            
            if camera ~= cameras{j}
                ok = false;
                disp(['ERROR: Camera ' camera ' does not match with order!']);
                break;
            end
            
            % If we are here, everything went OK
            % Load image
            imgset{j} = imread(imglocation);
            
            % If it is necessary to rectify
            if dorectify
                if isempty(custime)
                    % Load the nearest calibration before t
                    calibration = load_calibration(conn, station, camera, t);
                else
                    calibration = load_calibration(conn, station, camera, custime);
                end
                if isempty(calibration)
                    ok = false;
                    disp('ERROR: No calibration was found in the database!');
                    break;
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
                
                if isempty(custime)
                    % Load the nearest rectification ROI before t
                    roi = load_roi(conn, 'rect', camera, station, t, t);
                else
                    roi = load_roi(conn, 'rect', camera, station, custime, custime);
                end
                
                if isempty(roi)
                    ok = false;
                    disp('ERROR: No ROI was found in the database!');
                    break;
                end
                
                uroi = cell2mat(roi(:, 4)); % U coordinates
                vroi = cell2mat(roi(:, 5)); % V coordinates
                zroi = 0;   % level value, fixed
                
                % rectify image
                [u v imgset{j}] = rectify(imgset{j}, H, K, D,...
                    [uroi vroi], zroi, resolution, false);
                
                if first
                    [X Y Z] = UV2XYZ(H, u, v, zroi);
                    first = false;
                end
            end
            
            if isrectified
                if isempty(custime)
                    % Load the nearest calibration before t
                    calibration = load_calibration(conn, station, camera, t);
                else
                    calibration = load_calibration(conn, station, camera, custime);
                end
                if isempty(calibration)
                    ok = false;
                    disp('ERROR: No calibration was found in the database!');
                    break;
                end
                
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
                
                if isempty(custime)
                    % Load the nearest rectification ROI before t
                    roi = load_roi(conn, 'rect', camera, station, t, t);
                else
                    roi = load_roi(conn, 'rect', camera, station, custime, custime);
                end
                
                if isempty(roi)
                    ok = false;
                    disp('ERROR: No ROI was found in the database!');
                    break;
                end
                
                roi = [cell2mat(roi(:, 4)) cell2mat(roi(:, 5))];
                z = 0;   % level value, fixed
                
                if first
                    if ~isempty(K) && ~isempty(D)
                        for k = 1:size(roi, 1)
                            [u(k, 1) v(k, 1)] = undistort(K, D, roi(k, :));
                        end
                    else
                        u = roi(:, 1);
                        v = roi(:, 2);
                    end
                    [X Y Z] = UV2XYZ(H, u, v, z);
                    
                    
                    newX2 = zeros(4, 3);
                    newX2(:, 3) = z;
                    
                    newX2(1, 1) = min(X);
                    newX2(1, 2) = min(Y);
                    newX2(2, 1) = min(X);
                    newX2(2, 2) = max(Y);
                    newX2(3, 1) = max(X);
                    newX2(3, 2) = max(Y);
                    newX2(4, 1) = max(X);
                    newX2(4, 2) = min(Y);
                    
                    [u v] = XYZ2UV(H, newX2);
                    if ~isempty(K) && ~isempty(D)
                        [u v] = distort(K, D, [u v]);
                    end
                    [X Y Z] = UV2XYZ(H, u, v, z);
                end
            end
        end
        % If image is not loaded or camera does not match the order
        if ~ok
            continue;
        end
        
        % Load the nearest fusion geometry before time
        if dorectify || isrectified
            fusiontype = 'rectified';
        else
            fusiontype = 'oblique';
        end
        
        if isempty(custime)
            fusionpar = load_fusion(conn, fusiontype, station, time);
        else
            fusionpar = load_fusion(conn, fusiontype, station, custime);
        end
        if isempty(fusionpar)
            disp('ERROR: No fusion parameters were found in the database!');
            continue;
        end
        
        % Merge the images in set
        %     mergedimg = imgset{end};
        
        if dorectify || isrectified
            mergedimg = imgset{end};
        end
        
        for k = (ncams - 1):-1:1
            % The affine transformation matrix has the format: Hxy, x: number
            % of first camera, y: number of second camera, e.g. H12
            Hname = ['H' num2str(k) num2str(k + 1)];
            
            % Extract the affine transformation from fusion parameters
            len = size(fusionpar, 2);
            H = [];
            for l = 1:len
                if strcmp(fusionpar{l}, Hname)
                    H = fusionpar{l + 1};
                    break;
                end
            end
            
            if dorectify || isrectified
                [mergedimg in jn] = merge_images(imgset{k}, mergedimg, H);
            else
                Hall{k} = H;
            end
        end
        
        if ~dorectify && ~isrectified
            mergedimg = mergeIms(imgset, Hall);
        end
        
        if show_waitbar
            if getappdata(h,'canceling')
                break
            end
            waitbar((i + ncams - 1) / m, h, {'Merging images from ' datestr(ti) ' to '...
                [datestr(tf) ' (' num2str(100 * (i + ncams - 1) / m, '%.1f') '%)']});
        end
        
        % Save merged image in file disk
        
        if ~isrectified && ~dorectify % If oblique merged image
            save_merged_oblique(mergedimg, t, station, imgtype, resultslocation);
        else % If rectified merged image
            [W H o] = size(imgset{1});
            save_merged_rectified(mergedimg, t, station, imgtype, resultslocation, W, H, in, jn, X, Y);
        end
        
        if saveDB
            path = fullfile(station, num2str(year(t)), num2str(month(t), '%02d'), num2str(day(t), '%02d'));
            if ~isrectified && ~dorectify % If oblique merged image
                filename = [datestr(t, 'YY.mm.DD.HH.MM.SS') '.GMT.' ...
                    upper(station(1)) lower(station(2:end)) '.' ...
                    upper(imgtype(1)) lower(imgtype(2:end)) ...
                    '.PAN.HORUS.jpg'];
            else % If rectified merged image
                % resultslocation = fullfile(root, station, YYYY, mm, DD);
                filename = [datestr(t, 'YY.mm.DD.HH.MM.SS') '.GMT.'...
                    upper(station(1)) lower(station(2:end)) '.' ...
                    upper(imgtype(1)) lower(imgtype(2:end)) ...
                    '.RECT.HORUS.jpg'];
            end
            
            check = check_image(conn, filename, station);
            if ~check
            
                % Actually insert the merged image in the database
                typeids = load_imagetype_ids(conn, station, imgtype);

                if isempty(typeids)
                    failed = insert_imagetype(conn, imgtype, station);
                    if failed
                        continue
                    end
                end

                typeids = load_imagetype_ids(conn, station, imgtype);
                typenum = typeids{1};


                status = insert_merged(conn, station, typenum, t, false, filename, path, fusionpar{1});
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
% Save a merged oblique image in file disk
function save_merged_oblique(mergedimg, t, station, imgtype, resultslocation)
% Input:
%   mergedimg: Merged image
%   t:         Image time
%   station:   Station name
%   imgtype:   Image type
%   resultslocation: Path where the image will be saved

try
    
    Ir = sum(mergedimg, 3);
    [ni nj] = find(Ir > 0);
    
    % Do not leave black spaces in the image boundaries
    imgtmp = mergedimg(min(ni):max(ni), min(nj):max(nj), :);
    if ~isempty(imgtmp)
        mergedimg = imgtmp;
    end
    
    load('horusvideo.mat');
    mm = size(mergedimg, 2);
    
    scale = mm / (3 * size(I, 2));
    I = imresize(I, scale);
    
    mergedimg(end - size(I, 1) + 1:end, ...
        round((mm - size(I, 2)) / 2) + 1:round((mm + size(I, 2)) / 2), :) = I;
    YYYY = num2str(year(t));
    mm = num2str(month(t), '%02d');
    DD = num2str(day(t), '%02d');
    
    resultslocation = fullfile(resultslocation, station, YYYY, mm, DD);
    filename = [datestr(t, 'YY.mm.DD.HH.MM.SS') '.GMT.'...
        upper(station(1)) lower(station(2:end)) '.' ...
        upper(imgtype(1)) lower(imgtype(2:end)) ...
        '.PAN.HORUS.jpg'];
    
    if ~exist(resultslocation, 'dir')
        mkdir(resultslocation);
    end
    
    
    imwrite(mergedimg, fullfile(resultslocation, filename), 'JPEG', 'Quality', 100)
    
    disp(['Saved image ' filename]);
    
catch e
    disp(e.message)
end
%--------------------------------------------------------------------------
% Save a merged rectified image in file disk
function save_merged_rectified(mergedimg, t, station, imgtype, resultslocation, W, H, in, jn, X, Y)

% Input:
%   mergedimg: Merged image
%   t:         Image time
%   station:   Station name
%   imgtype:   Image type
%   resultslocation: Path where the image will be saved
%   W:         Image width
%   H:         Image height
%   in:
%   jn:
%   X:
%   Y:

try
    
    h = figure;
    imshow(mergedimg);
    set(h, 'Visible', 'off', 'Position', [1 1 1280 768])
    
    ca = get(h, 'CurrentAxes');
    %
    % [W H o] = size(firstimg);
    
    du = (max(X) - min(X)) / W;
    dv = (max(Y) - min(Y)) / H;
    
    [m n o] = size(mergedimg);
    ul = linspace(1, m, 10);
    yl = round(-dv .* (ul - in + 1) + max(Y));
    set(ca, 'Visible', 'on')
    set(ca, 'YTick', ul)
    for j = 1:length(yl)
        syl{j} = mat2str(yl(j));
    end
    set(ca, 'Yticklabel', syl)
    ylabel('y (m)')
    set(ca, 'Ygrid', 'on')
    
    vl = linspace(1, n, 10);
    xl = round(du .* (vl - jn + 1) + min(X));
    set(ca, 'XTick', vl)
    for j = 1:length(xl)
        sxl{j} = mat2str(xl(j));
    end
    set(ca, 'Xticklabel', sxl)
    xlabel('x (m)')
    set(ca, 'Xgrid', 'on')
    
    
    text(n / 2, m - 25, 'http://www.horusvideo.com',...
        'Fontsize', 10, 'Color', 'y', 'BackgroundColor', [0 0 0],...
        'FontName', 'Arial', 'HorizontalAlignment', 'Center');
    
    YYYY = num2str(year(t));
    mm = num2str(month(t), '%02d');
    DD = num2str(day(t), '%02d');
    
    resultslocation = fullfile(resultslocation, station, YYYY, mm, DD);
    filename = [datestr(t, 'YY.mm.DD.HH.MM.SS') '.GMT.'  ...
        upper(station(1)) lower(station(2:end)) '.' ...
        upper(imgtype(1)) lower(imgtype(2:end)) ...
        '.RECT.HORUS.jpg'];
    
    if ~exist(resultslocation, 'dir')
        mkdir(resultslocation);
    end
    print(h, '-djpeg', fullfile(resultslocation, filename))
    
    disp(['Saved image ' filename]);
    close(h);
    
catch e
    disp(e.message)
end