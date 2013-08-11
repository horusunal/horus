function auto_process_images(station, search_step, search_error, ti)
%AUTO_PROCESS_IMAGES    Executes continously and at certain times,
%processes images (fusion, rectification, miniaturization and uploading)
%
% Input:
%   station: Name of the station.
%   search_step: Step size in minutes of the image search process.
%   search_error: Error for image search process.
%   ti: (Optional) initial time for image search.
%

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2012 HORUS
%   $Date: 2012/08/03 17:27 $

try
    
    % Set HORUS paths
    if ~isdeployed
        root = fileparts(mfilename('fullpath'));
        root = fileparts(root);
        addpath(genpath(root));
    else
        search_step = str2double(search_step);
        search_error = str2double(search_error);
    end
    
    % Load default path for rectified images
    if ~exist('path_info.xml', 'file')
        disp('ERROR: The file path_info.xml does not exist!');
        return;
    end
    
    [pathOblique pathRectified pathMerged pathMergedRect] =...
        load_paths('path_info.xml', station);
    
    xmlfile = 'processing_info.xml';
    
    if ~exist(xmlfile, 'file')
        message = ['Error: The file ' xmlfile ' does not exist!'];
        disp(message);
        return
    end
    
    xml = loadXML(xmlfile, 'Configuration', 'station', station);
    xmlPath = strcat('Configuration[station=', station, ']/ImageProcessingConfig');
    
    processNode = getNodes(xml, xmlPath);
    
    xmlPath = strcat('Configuration[station=', station, ']/ThumbnailsConfig');
    
    thumbsNode = getNodes(xml, xmlPath);
    
    % PROCESSING IS MANDATORY, THUMBS GENERATION IS OPTIONAL!!!!!
    % Something is wrong with the XML file
    if isempty(processNode)
        disp('Error: Invalid configuration!')
        return
    end
    
    genthumbs = ~isempty(thumbsNode);
    
    processNode = processNode{1};
    
    % Image processing parameters
    startHour = str2double(getNodeVal(processNode, 'StartHour'));
    startMinute = str2double(getNodeVal(processNode, 'StartMinute'));
    endHour = str2double(getNodeVal(processNode, 'EndHour'));
    endMinute = str2double(getNodeVal(processNode, 'EndMinute'));
    timeStep = str2double(getNodeVal(processNode, 'TimeStep'));
    mergeOnly = eval(getNodeVal(processNode, 'MergeOnly'));
    rectifyOnly = eval(getNodeVal(processNode, 'RectifyOnly'));
    rectifyAndMerge = eval(getNodeVal(processNode, 'RectifyAndMerge'));
    
    % Create a database connection
    try
        conn = connection_db();
    catch e
        disp(e.message)
        return
    end
    
    % Image types
    types = load_imagetype_name(conn, station);
    
    imgtypes = cell(0);
    for k = 1:numel(types)
        val = getNodeVal(processNode, char(types(k)));
        if ~isempty(val)
            if eval(val)
                imgtypes{end + 1} = char(types(k));
            end
        end
    end
    
    % Load all cameras from the database
    cameras = load_cam_station(conn, station);
    show_waitbar = true; % True if waitbars are to be shown, false otherwise
    saveDB = true; % Save in database, it should always be true
    EPS = 1 / (24 * 60); % 1 minute
    
    close(conn)
    
    ti_process = startHour * 60 + startMinute; % Init process time (min)
    tf_process = endHour * 60 + endMinute; % End process time (min)
    delta_t = timeStep;
    
    if genthumbs
        thumbsNode = thumbsNode{1};

        % Thumbs generation parameters
        rectified = eval(getNodeVal(thumbsNode, 'Rectified'));
        oblique = eval(getNodeVal(thumbsNode, 'Oblique'));
        mergedRectified = eval(getNodeVal(thumbsNode, 'MergedRectified'));
        mergedOblique = eval(getNodeVal(thumbsNode, 'MergedOblique'));
        thumbWidth = str2double(getNodeVal(thumbsNode, 'ThumbWidth'));

        % Thumbnail types
        thumbtypes = cell(0);
        for k = 1:numel(types)
            val = getNodeVal(thumbsNode, char(types(k)));
            if ~isempty(val)
                if eval(val)
                    thumbtypes{end + 1} = char(types(k));
                end
            end
        end

        % Thumbnail types of processed image
        thumbtypes2 = cell(0);
        if rectified
            thumbtypes2{end + 1} = 'rectified';
        end
        if oblique
            thumbtypes2{end + 1} = 'oblique';
        end
        if mergedRectified
            thumbtypes2{end + 1} = 'merge_rectified';
        end
        if mergedOblique
            thumbtypes2{end + 1} = 'merge_oblique';
        end
    end
    
    
    % Infinite loop for running as a daemon
    while true
        cur_time = now;
        
        % If current minute is for processing images
        cur_minute = mod(floor(cur_time * 24 * 60), 24 * 60); % Current minute
        cur_sec = floor(second(cur_time)); % Current second
        
        if cur_minute >= ti_process && cur_minute <= tf_process && ...
                mod(cur_minute - ti_process, delta_t) == 0 && cur_sec == 0
            
            try
                conn = connection_db();
            catch e
                disp(e.message)
                continue
            end
            % IMAGE PROCESSING
            
            if nargin < 4
                % If no processed images are found, then begin at the time of the
                % first oblique image
                ti_oblique = cell2mat(load_datemin(conn, 'oblique', station, false));
                if isempty(ti_oblique)
                    ti_oblique = NaN;
                end
                ti_oblique = ti_oblique + EPS;

                % Time of the last rectified image + EPS (in order to not
                % reprocessing the last image)
                ti_rectified = cell2mat(load_datemax(conn, 'rectified', station, false));
                if isempty(ti_rectified)
                    ti_rectified = NaN;
                end
                ti_rectified = ti_rectified + search_step / (60*24) + EPS;
                % Time of the last panoramic image + EPS
                ti_merge_oblique = cell2mat(load_datemax(conn, 'merge_oblique', station, false));
                if isempty(ti_merge_oblique)
                    ti_merge_oblique = NaN;
                end
                ti_merge_oblique = ti_merge_oblique + search_step / (60*24) + EPS;
                % Time of the last merged-rectified image + EPS
                ti_merge_rectified = cell2mat(load_datemax(conn, 'merge_rectified', station, false));
                if isempty(ti_merge_rectified)
                    ti_merge_rectified = NaN;
                end
                ti_merge_rectified = ti_merge_rectified + search_step / (60*24) + EPS;
            else
                if ischar(ti)
                    ti = str2double(ti);
                end
            end
            
            % Attempt to process images until the time of the last oblique
            % image in the database
            tf = cell2mat(load_datemax(conn, 'oblique', station, false));
            if isempty(tf)
                tf = NaN;
            end
            
            for i = 1:numel(imgtypes)
                % First rectify only
                if rectifyOnly
                    for j = 1:numel(cameras)
                        if nargin < 4
                            if ~isnan(ti_rectified)
                                ti = ti_rectified;
                            else
                                ti = ti_oblique;
                            end
                        end
                        if ~isnan(ti)
                            disp(['Starting rectification for ' imgtypes{i} ' images, camera '...
                                cameras{j} ' from ' datestr(ti) ' to ' datestr(tf) '...'])
                            message = rectification(station, imgtypes{i}, cameras{j},...
                                ti, tf, search_step, search_error, show_waitbar, ...
                                pathRectified, saveDB, [], []);
                            if ~isempty(message)
                                disp(['ERROR: ' message]);
                            else
                                disp('Rectification finished!')
                            end
                            
                        end
                        
                    end
                end
                
                % Then, merge only
                if mergeOnly
                    if nargin < 4
                        if ~isnan(ti_merge_oblique)
                            ti = ti_merge_oblique;
                        else
                            ti = ti_oblique;
                        end
                    end
                    if ~isnan(ti)
                        disp(['Starting fusion (only merge) for ' imgtypes{i} ...
                            ' images from ' datestr(ti) ' to ' datestr(tf) '...'])
                        message = fusion(station, imgtypes{i}, false, false,...
                            ti, tf, search_step, search_error, show_waitbar, pathMerged, saveDB, []);
                        if ~isempty(message)
                            disp(['ERROR: ' message]);
                        else
                            disp('Fusion finished!')
                        end
                    end
                end
                
                
                
                % Lastly, rectify and merge
                if rectifyAndMerge
                    if nargin < 4
                        if ~isnan(ti_merge_rectified)
                            ti = ti_merge_rectified;
                        else
                            ti = ti_oblique;
                        end
                    end
                    if ~isnan(ti)
                        disp(['Starting fusion (and rectification) for ' imgtypes{i} ...
                            ' images from ' datestr(ti) ' to ' datestr(tf) '...'])
                        message = fusion(station, imgtypes{i}, false, true,...
                            ti, tf, search_step, search_error, show_waitbar, pathMergedRect, saveDB, []);
                        if ~isempty(message)
                            disp(['ERROR: ' message]);
                        else
                            disp('Fusion finished!')
                        end
                    end
                end
                close(conn)
            end
            
            if genthumbs
                % THUMBS GENERATION
                % Create a database connection
                try
                    conn = connection_db();
                catch e
                    disp(e.message)
                    return
                end
                % first oblique image
                ti_oblique = cell2mat(load_datemin(conn, 'oblique', station, false)) + EPS;
                for j = 1:numel(thumbtypes2)

                    % Time of the last thumbnail image + EPS
                    if nargin < 4
                        ti_thumb = cell2mat(load_datemax(conn, thumbtypes2{j}, station, true)) + EPS;
                        if ~isnan(ti_thumb)
                            ti = ti_thumb;
                        else
                            ti = ti_oblique;
                        end
                    end
                    if ~isnan(ti)
                        disp(['Starting thumbnails generation for ' thumbtypes2{j} ...
                            ' images from ' datestr(ti) ' to ' datestr(tf) '...'])
                        status = create_thumbnail(thumbtypes, thumbtypes2{j}, ...
                            ti, station, tf, thumbWidth, true, ...
                            saveDB, show_waitbar);
                        if status == 0
                            disp('Thumbnails generation finished!')
                        else
                            disp('Error with thumbnails generation!')
                        end
                    end
                end
                disp('Uploading thumbnails to the web...')
                status = upload_hosting(station, show_waitbar);
                if status == 0
                    disp('Thumbnails upload finished!')
                else
                    disp('Error with thumbnails upload!')
                end
                close(conn)
            end
        end
        
        % Be suspended for 1 second until next iteration
        pause(1)
    end
    
catch e
    disp(e.message)
end