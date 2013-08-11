function [varargout] = create_thumbnail(typet,datat,dateend,site,datemax,width,upload,insert,progressbar,varargin)

% CREATE_THUMBNAIL this function is used for creating thumbnails for
%                  the selected image type.
%
%   Input:
%   typet: Type of the image as a cell (snap,timex,var).
%   datat: Type of the thumbnail, can be 'oblique', 'rectified'
%          'merge_oblique' or 'merge_rectified'.
%   dateend: Initial date for the generation of thumbnails, DATENUM format.
%   site: Station for which thumbnails are to be generated.
%   datemax: Final date for the generation of thumbnails, DATENUM format.
%   width: Desired width of the thumbnail.
%   upload: This indicates whether to upload to hosting. It is 1 if you want
%           to upload the thumbnail to hosting, otherwise it is 0.
%   insert: This indicates whether to insert the information of the
%           thumbnail to data base. It is 1 if you want
%           to insert the thumbnail, otherwise it is 0.
%   progressbar: This indicates whether to display progress bar. It is 1 if
%                you want to display, otherwise it is 0.
%   varargin: Optional argument, if not empty, contains the path where to 
%             save the image. Otherwise, load the file path from path_info.xml
%
%   Output:
%   varargout: This is the status of the operation. 0 If it is successful
%   or 1 if it fails.
%
%   Example:
%   create_thumbnail({'snap'},'oblique',734233.416666667, 'CARTAGENA',...
%       734240.416666667, 20,0,0,1)

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/08/20 15:30 $

try
    
    if nargout==1
            varargout(1)={1};
    end
        
    % Set HORUS paths
    if ~isdeployed
        root = fileparts(mfilename('fullpath'));
        root = fileparts(root);
        addpath(genpath(root));
    end
    
    if ~exist('path_info.xml', 'file')
        message = 'Error: The file path_info.xml does not exist!';
        disp(message);
        return
    end
    
    if isdeployed
        pathinfo = what('tmp');
        tmppath = pathinfo.path;
    else
        tmppath = fullfile(root, 'tmp');
    end
    
    try
        conn = connection_db();
    catch e
        disp(e.message)
        return
    end
    
    try
        if isempty(datemax)
            datemax=now;
        end
        finalnames=cell(0);
        %Load the paths
        [pathOblique pathRectified pathMergeOblique pathMergeRectified ...
            pathObliqueMin pathRectifiedMin pathMergeObliqueMin pathMergeRectifiedMin] ...
            = load_paths('path_info.xml',site);
        
        pathOblique = strtrim(pathOblique);
        pathRectified = strtrim(pathRectified);
        pathMergeOblique = strtrim(pathMergeOblique);
        pathMergeRectified = strtrim(pathMergeRectified);
        pathObliqueMin = strtrim(pathObliqueMin);
        pathRectifiedMin = strtrim(pathRectifiedMin);
        pathMergeObliqueMin = strtrim(pathMergeObliqueMin);
        pathMergeRectifiedMin = strtrim(pathMergeRectifiedMin);
        
        switch datat
            case 'oblique'
                % load the cams
                cam  = load_cam_interval(conn, site,dateend,datemax);
                for i=1:length(cam);
                    % load the images
                    image  = load_allimage(conn, typet, char(cam(i)),site , dateend,datemax );
                    [row col]=size(image);
                    row2=size(finalnames,1);
                    finalnames(row2+1:row2+row,1:col)=image;
                end
            case 'rectified'
                % load the cams
                cam  = load_cam_interval(conn,site,dateend,datemax);
                for i=1:length(cam);
                    % load the images
                    image  = load_allimage_rectified(conn, typet, char(cam(i)), site, dateend, datemax);
                    [row col]=size(image);
                    row2=size(finalnames,1);
                    finalnames(row2+1:row2+row,1:col)=image;
                end
            case 'merge_oblique'
                % load the images
                finalnames  = load_allimage_merged(conn, typet, site, 'oblique', dateend,datemax );
            case 'merge_rectified'
                % load the images
                finalnames  = load_allimage_merged(conn, typet, site, 'rectified', dateend,datemax );
        end
        
        if upload==1
            % load or create the file where it is the image information for
            % upload to the hosting
            if exist(fullfile(tmppath, 'ListImageMin.mat'),'file')==0
                ListImageMin = struct('pathMin',{},'filenameMin',{},'type',{});
            else
                load(fullfile(tmppath, 'ListImageMin.mat'))
            end
        end
        if progressbar==1
            % display progress bar
            h = waitbar(0, {'Generate Thumbnail from ' datestr(dateend) ...
                ' to ' datestr(datemax)}, ...
                'CreateCancelBtn',...
                'setappdata(gcbf,''canceling'',1)');
            setappdata(h,'canceling',0)
        end
        for ij=1:size(finalnames,1)
            
            data = split_filename(char(finalnames(ij,1)));
            
            switch datat
                case 'oblique'
                    path_im=strtrim(char(finalnames(ij,2)));
                    if ~isempty(varargin)
                        path=fullfile(strtrim(char(varargin(1))),path_im);
                    else
                        path=fullfile(pathObliqueMin,path_im);
                    end
                    
                    if filesep == '/'
                        changeFrom = '\';
                        changeTo = '/';
                    else
                        changeFrom = '/';
                        changeTo = '\';
                    end
                    % build the path to the image
                    path = strrep(path, changeFrom, changeTo);
                    
                    if exist(path,'dir')==0
                        mkdir(path)
                    end
                    scale = width / data.width;
                    width2 = ceil(data.width * scale);
                    height = ceil(data.height * scale);
                    namemin=strtrim(strrep(char(finalnames(ij,1)),[num2str(data.width) 'X' num2str(data.height)], [num2str(width2) 'X' num2str(height) '.MIN']));
                    if exist(fullfile(path,namemin),'file')==0
                        
                        % If not found the image in physical disk
                        if filesep == '/' | strfind(pathOblique,'http://')
                            changeFrom = '\';
                            changeTo = '/';
                        else
                            changeFrom = '/';
                            changeTo = '\';
                        end
                        % build the path to the image
                        file = strrep(fullfile(pathOblique, path_im, strtrim(char(finalnames(ij,1)))), changeFrom, changeTo);
                        I=imread(file);
                        % create thumbnail
                        In=imresize(I,[height width2],'nearest');
                        imwrite(In,fullfile(path,namemin),'JPEG','Quality',80);
                        clear I In
                        if upload==1
                            % save the images information in a file
                            % to then upload to the hosting
                            ListImageMin(end+1).pathMin=path;
                            ListImageMin(end).filenameMin=namemin;
                            ListImageMin(end).type='oblique';
                        end
                        if insert==1
                            check = check_image(conn, namemin, site);
                            if ~check
                                type = cell2mat(finalnames(ij,4));
                                timestamp = cell2mat(finalnames(ij,3));
                                path = char(finalnames(ij,2));
                                camera = char(finalnames(ij,5)); 
                                % Insert information of image in the data base
                                insert_oblique(conn, type, timestamp, true,namemin, path, camera, site);
                            end
                        end
                    end
                case 'rectified'
                    
                    path_im=strtrim(char(finalnames(ij,2)));
                    path_im=strrep(path_im,'\',filesep);
                    if ~isempty(varargin)
                        path=fullfile(strtrim(char(varargin(1))),path_im);
                    else
                        path=fullfile(pathRectifiedMin,path_im);
                    end
                    
                    
                    if filesep == '/'
                        changeFrom = '\';
                        changeTo = '/';
                    else
                        changeFrom = '/';
                        changeTo = '\';
                    end
                    % build the path to the image
                    path = strrep(path, changeFrom, changeTo);
                    
                    if exist(path,'dir')==0
                        mkdir(path)
                    end
                    
                    namemin=strtrim(strrep(char(finalnames(ij,1)),'RECT','RECTMIN'));
                    if exist(fullfile(path,namemin),'file')==0
                        % If not found the image in physical disk
                        if filesep == '/' | strfind(pathRectified,'http://')
                            changeFrom = '\';
                            changeTo = '/';
                        else
                            changeFrom = '/';
                            changeTo = '\';
                        end
                        % build the path to the image
                        file = strrep(fullfile(pathRectified, path_im, strtrim(char(finalnames(ij,1)))), changeFrom, changeTo);
                        I=imread(file);
                        
                        scale = width / size(I, 2);
                        width2 = ceil(size(I,2) * scale);
                        height = ceil(size(I,1) * scale);
                        % create thumbnail
                        In=imresize(I,[height width2],'nearest');
                        imwrite(In,fullfile(path,namemin),'JPEG','Quality',80);
                        clear I In
                        if upload==1
                            % save the images information in a file
                            % to then upload to the hosting
                            ListImageMin(end+1).pathMin=path;
                            ListImageMin(end).filenameMin=namemin;
                            ListImageMin(end).type='rectified';
                        end
                        if insert==1
                            check = check_image(conn, namemin, site);
                            if ~check
                                type = cell2mat(finalnames(ij,4));
                                timestamp = cell2mat(finalnames(ij,3));
                                path = char(finalnames(ij,2));
                                idcalibration = cell2mat(finalnames(ij,5));
                                % Insert information of image in the data base
                                insert_rectified(conn, site, type, timestamp, true, namemin, path, idcalibration)
                            end
                        end
                    end
                case 'merge_oblique'
                    
                    path_im=strtrim(char(finalnames(ij,2)));
                    path_im=strrep(path_im,'\',filesep);
                    if ~isempty(varargin)
                        path=fullfile(strtrim(char(varargin(1))),path_im);
                    else
                        path=fullfile(pathMergeObliqueMin,path_im);
                    end
                    
                    if filesep == '/'
                        changeFrom = '\';
                        changeTo = '/';
                    else
                        changeFrom = '/';
                        changeTo = '\';
                    end
                    % build the path to the image
                    path = strrep(path, changeFrom, changeTo);
                    
                    if exist(path,'dir')==0
                        mkdir(path)
                    end
                    namemin=strtrim(strrep(char(finalnames(ij,1)),'PAN','PAM'));
                    if exist(fullfile(path,namemin),'file')==0
                        % If not found the image in physical disk
                        if filesep == '/' | strfind(pathMergeOblique,'http://')
                            changeFrom = '\';
                            changeTo = '/';
                        else
                            changeFrom = '/';
                            changeTo = '\';
                        end
                        % build the path to the image
                        file = strrep(fullfile(pathMergeOblique, path_im, strtrim(char(finalnames(ij,1)))), changeFrom, changeTo);
                        I=imread(file);
                        
                        scale = width / size(I, 2);
                        width2 = ceil(size(I,2) * scale);
                        height = ceil(size(I,1) * scale);
                        % create thumbnail
                        In=imresize(I,[height width2],'nearest');
                        imwrite(In,fullfile(path,namemin),'JPEG','Quality',80);
                        clear I In
                        if upload==1
                            % save the images information in a file
                            % to then upload to the hosting
                            ListImageMin(end+1).pathMin=path;
                            ListImageMin(end).filenameMin=namemin;
                            ListImageMin(end).type='merge_oblique';
                        end
                        if insert==1
                            check = check_image(conn, namemin, site);
                            if ~check
                                type = cell2mat(finalnames(ij,4));
                                timestamp = cell2mat(finalnames(ij,3));
                                path = char(finalnames(ij,2));
                                idfusion = cell2mat(finalnames(ij,5));
                                % Insert information of image in the data base
                                insert_merged(conn, site, type, timestamp, true, namemin, path, idfusion)
                            end
                        end
                    end
                case 'merge_rectified'
                    
                    path_im=strtrim(char(finalnames(ij,2)));
                    path_im=strrep(path_im,'\',filesep);
                    if ~isempty(varargin)
                        path=fullfile(strtrim(char(varargin(1))),path_im);
                    else
                        path=fullfile(pathMergeRectifiedMin,path_im);
                    end
                    
                    if filesep == '/'
                        changeFrom = '\';
                        changeTo = '/';
                    else
                        changeFrom = '/';
                        changeTo = '\';
                    end
                    % build the path to the image
                    path = strrep(path, changeFrom, changeTo);
                    
                    if exist(path,'dir')==0
                        mkdir(path)
                    end
                    namemin=strtrim(strrep(char(finalnames(ij,1)),'RECT','RECM'));
                    if exist(fullfile(path,namemin),'file')==0
                        % If not found the image in physical disk
                        if filesep == '/' | strfind(pathMergeRectified,'http://')
                            changeFrom = '\';
                            changeTo = '/';
                        else
                            changeFrom = '/';
                            changeTo = '\';
                        end
                        % build the path to the image
                        file = strrep(fullfile(pathMergeRectified, path_im, strtrim(char(finalnames(ij,1)))), changeFrom, changeTo);
                        I=imread(file);
                        
                        scale = width / size(I, 2);
                        width2 = ceil(size(I,2) * scale);
                        height = ceil(size(I,1) * scale);
                        % create thumbnail
                        In=imresize(I,[height width2],'nearest');
                        imwrite(In,fullfile(path,namemin),'JPEG','Quality',80);
                        clear I In
                        if upload==1
                            % save the images information in a file
                            % to then upload to the hosting
                            ListImageMin(end+1).pathMin=path;
                            ListImageMin(end).filenameMin=namemin;
                            ListImageMin(end).type='merge_rectified';
                        end
                        if insert==1
                            check = check_image(conn, namemin, site);
                            if ~check
                                type = cell2mat(finalnames(ij,4));
                                timestamp = cell2mat(finalnames(ij,3));
                                path = char(finalnames(ij,2));
                                idfusion = cell2mat(finalnames(ij,5));
                                % Insert information of image in the data base
                                insert_merged(conn, site, type, timestamp, true, namemin, path, idfusion)
                            end
                        end
                    end
            end
            if progressbar==1
                if getappdata(h,'canceling')
                    break
                end
                % display progress bar
                progress=ij/length(finalnames);
                
                waitbar(progress, h, {'Generate Thumbnail from ' datestr(dateend) ...
                    ' to ' [datestr(datemax) ' (' num2str(progress*100,'%.1f') '%)']})
            end
        end
        if progressbar==1
            % close progress bar
            delete(h)
        end
        if upload==1
            % save file where it is the image information for
            % upload to the hosting
            save(fullfile(tmppath, 'ListImageMin.mat'),'ListImageMin');
        end
        if nargout==1
            varargout(1)={0};
        end
    catch e
        if progressbar==1
            % close progress bar
            if exist('h','var')
                delete(h)
            end
        end
        if upload==1
            % save file where it is the image information for
            % upload to the hosting
            save(fullfile(tmppath, 'ListImageMin.mat'),'ListImageMin');
        end
        disp(e.message);
    end
    
    close(conn)
    
catch e
    disp(e.message)
end