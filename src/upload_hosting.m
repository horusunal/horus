function [varargout] = upload_hosting(station,progressbar)

% UPLOAD_HOSTING this function is used for uploading thumbnails to the
%                hosting
%   Input:
%   station: Station where to upload the thumbnail.
%   progressbar: This indicates whether to display progress bar. It is 1 if
%                you want to display, otherwise it is 0.
%
%   Output:
%   varargout: This is the status of the operation. 0 If it is successful
%   or 1 if fails.
%
%   Example:
%   upload_hosting('CARTAGENA', true)

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/12/19 15:50 $

try
    
    % This is used for can connect to the FTP with java
    import org.apache.commons.net.ftp.FTPClient;
    import java.io.FileInputStream;
    
    if nargout==1
        varargout(1)={1};
    end
    
    if ~isdeployed
        root = fileparts(mfilename('fullpath'));
        root = fileparts(root);
        addpath(genpath(root));
        datapath = fullfile(root, 'data');
        tmppath = fullfile(root, 'tmp');
    else
        pathinfo = what('data');
        datapath = pathinfo.path;
        pathinfo = what('tmp');
        tmppath = pathinfo.path;
    end
    
    if ~exist('path_info.xml', 'file')
        message = 'Error: The file path_info.xml does not exist!';
        disp(message);
        return
    end
    
    file_images = fullfile(tmppath, 'ListImageMin.mat');
    if ~exist(file_images,'file')
        if nargout==1
            varargout(1)={1};
        else
            disp('The ListImageMin.mat file does not exist');
        end
        return;
    end
    
    % Load the images to upload to the FTP
    load(file_images);
    
    file_xml = 'processing_info.xml';
    if ~exist(file_xml,'file')
        if nargout==1
            varargout(1)={1};
        else
            disp('The processing_info.xml file does not exist');
        end
        return;
    end
    
    xml = loadXML(file_xml, 'Configuration', 'station', station);
    xmlPath = strcat('Configuration[station=', station, ']/ThumbnailsConfig');
    thumbnailsNodes = getNodes(xml, xmlPath);
    
    if ~isempty(thumbnailsNodes)
        thumbnails = thumbnailsNodes{1};
        host = getNodeVal(thumbnails, 'UploadFTPHost');
        user = getNodeVal(thumbnails, 'UploadFTPUser');
        pass = getNodeVal(thumbnails, 'UploadFTPPass');
        % Decrypt password
        pass = decrypt_aes(pass, datapath);
    else
        if nargout==1
            varargout(1)={1};
        else
            disp('The FTP configuration does not exist');
        end
        return;
    end
    
    % Connecting to FTP
    try
        FTP = FTPClient();
        FTP.connect(host);
        FTP.login(user, pass);
        
    catch e
        disp(['Failure to connect to the FTP ' e.message]);
        return;
    end
    
    if progressbar==1
        % display progress bar
        h = waitbar(0, 'Uploading Thumbnail ', ...
            'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
        setappdata(h,'canceling',0)
    end
    
    % Number of failures
    failures = 0;
    i=1;
    try
        while i <= size(ListImageMin,2) %Repeat the transfer for all images
            
            % Filename of the image
            filename=ListImageMin(i).filenameMin;
            data=split_filename(filename);
            % Date of the image
            textDate = [num2str(data.year) '/' num2str(data.month,'%02d') '/' num2str(data.day,'%02d')];
            switch ListImageMin(i).type
                case 'oblique'
                    % Path remote in the FTP
                    pathImageRemote=['/DBImageMIN/' upper(data.station) '/' textDate '/' data.cam];
                    
                case 'rectified'
                    % Path remote in the FTP
                    pathImageRemote=['/DBImageRECMIN/' upper(data.station) '/' textDate '/' data.cam];
                case 'merge_oblique'
                    % Path remote in the FTP
                    pathImageRemote=['/DBImagePAM/' upper(data.station) '/' textDate];
                case 'merge_rectified'
                    % Path remote in the FTP
                    pathImageRemote=['/DBImageRECM/' upper(data.station) '/' textDate];
            end
            % Change to the directory in the FTP where saved image
            path = FTP.changeWorkingDirectory(pathImageRemote);
            if ~path
                % if the directory change failed, create directories
                FTP = change_create_directory (FTP,pathImageRemote,cell(0));
                path = FTP.changeWorkingDirectory(pathImageRemote);
            end
            
            if path
                % File to upload to the FTP
                local = FileInputStream(fullfile(ListImageMin(i).pathMin, filename));
                % It set to send binary files of any type
                FTP.setFileType(FTP.BINARY_FILE_TYPE);
                % Set the current data connection mode to PASSIVE_LOCAL_DATA_CONNECTION_MODE
                FTP.enterLocalPassiveMode;
                
                % Upload the file
                status=FTP.storeFile(filename, local);
                local.close();
                if status
                    disp([filename ' image transferred'])
                    % Delete the uploaded image
                    i = i + 1;
                    failures = 0;
                else
                    % Accumulated errors
                    failures = failures + 1;
                end
            end
            
            if failures == 10
                break;
            end
            if progressbar==1
                if getappdata(h,'canceling')
                    break
                end
                % display progress bar
                progress=i/size(ListImageMin,2);
                
                waitbar(progress, h,['Uploading Thumbnail (' num2str(progress*100,'%.1f') '%)'])
            end
            
        end
        if progressbar==1
            % close progress bar
            delete(h)
        end
        if i > size(ListImageMin,2)
            ListImageMin = [];
            if nargout==1
                varargout(1)={0};
            end
        else
            ListImageMin=ListImageMin(i:end);
        end
        % Disconnect of the FTP
        FTP.logout();
        FTP.disconnect();
        % Save o delete file of the images
        if isempty(ListImageMin)
            delete(fullfile(tmppath, 'ListImageMin.mat'))
        else
            save(fullfile(tmppath, 'ListImageMin.mat'),'ListImageMin');
        end
        
    catch e
        if progressbar==1
            % close progress bar
            if exist('h','var')
                delete(h)
            end
        end
        if i > size(ListImageMin,2)
            ListImageMin = [];
        else
            ListImageMin=ListImageMin(i:end);
        end
        % Save o delete file of the images
        if isempty(ListImageMin)
            delete(fullfile(tmppath, 'ListImageMin.mat'))
        else
            save(fullfile(tmppath, 'ListImageMin.mat'),'ListImageMin');
        end
        
        disp(e.message);
    end
    
catch e
    disp(e.message)
end

function FTP = change_create_directory (FTP,pathImageRemote,dirs)

% CHANGE_CREATE_DIRECTORY This function create the directories
%			  in the FTP server
%
%   Input:
%   FTP: Object with the connection to the FTP.
%   pathImageRemote: Path of the directory where saved the image.
%   dirs: Cell with the directories to create.
%
%   Output:
%   FTP: Object with the connection to the FTP, with the directory change.
%
%   Example:
%   FTP = change_create_directory (FTP,pathImageRemote,cell(0))

%   Copyright 2011 HORUS
%   $Date: 2011/12/19 15:30 $

try
    
    % Path is separated by /
    parts = regexp(pathImageRemote, '\/', 'start');
    % Change to the directory in the FTP where saved image
    path = FTP.changeWorkingDirectory(pathImageRemote);
    if ~path
        % Save the directory to create
        dirs(end+1) = {pathImageRemote(parts(end)+1:end)};
        pathImageRemote=pathImageRemote(1:parts(end)-1);
        if isempty(pathImageRemote)
            pathImageRemote = '/';
        end
        
        FTP = change_create_directory (FTP,pathImageRemote,dirs);
    elseif path && ~isempty(dirs)
        % Create Directory
        FTP.mkd(dirs(end));
        pathImageRemote = [pathImageRemote '/' char(dirs(end))];
        dirs(end) = [];
        FTP = change_create_directory (FTP,pathImageRemote,dirs);
    end
    
catch e
    disp(e.message)
end
