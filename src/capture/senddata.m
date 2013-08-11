function senddata(station, cameras, host, type, ti_process, tf_process)
%SENDDATA   Sends images and stacks via SFTP.
%
% Input:
%   station: name of the station (e.g. 'CARTAGENA')
%   cameras: List of the cameras as a cell array.
%   host: IP address or host name of the server.
%   type: Type of information to be transferred: 'image' or 'stack'
%   ti_process: Initial time of the images or stacks in DATENUM format.
%   tf_process: Final time of the images or stacks in DATENUM format.

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2012 HORUS
%   $Date: 2012/08/04 12:27 $

try
    
    % Send data captured by HORUSimages and HORUSstacks using the configuration
    % saved on ConfigName
    
    if ~isdeployed
        root = fileparts(mfilename('fullpath'));
        root = fileparts(root);
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

    xmlfile = 'capture_info.xml';
    
    if ~exist(xmlfile, 'file')
        message = ['Error: The file ' xmlfile ' does not exist!'];
        disp(message);
        return
    end
    
    xml = loadXML(xmlfile, 'Configuration', 'station', station);
    
    xmlPath = strcat('Configuration[station=', station, ']/CaptureConfig/Transfer[FTPHost=', host, ']');
    transferNodes = getNodes(xml, xmlPath);
    
    if isempty(transferNodes)
        disp('No transfer information was found!')
        return
    end
    
    transferNode = transferNodes{1};
    
    ftpUser = getNodeVal(transferNode, 'FTPUser');
    ftpPass = getNodeVal(transferNode, 'FTPPass');
    emailUser = getNodeVal(transferNode, 'EmailUser');
    emailPass = getNodeVal(transferNode, 'EmailPass');
    emailRcpt = getNodeVal(transferNode, 'EmailRcpt');
    emailRcpt = regexp(emailRcpt, '[ ,]+', 'split');
    rootPath = getNodeVal(transferNode, 'RootPath');

    % Decrypt passwords
    ftpPass = decrypt_aes(ftpPass, datapath);
    emailPass = decrypt_aes(emailPass, datapath);

    
    pathSendError=fullfile(tmppath, 'DATASENDERRORS.mat');
    pathImageError=fullfile(tmppath, 'IMAGEERRORS.mat');
    
    %% Review ERRORS on Capture archive and send information if needed
    if exist(pathImageError, 'file')
        load(pathImageError);
        
        RowN=size(Errors,1);
        if RowN>1 %More than 1 errors causes a mail to be send
            message=[];
            for j=RowN:-1:1
                message=[message 10 Errors{j,2} ' at ' Errors{j,1}];
            end
            sendmailgmail(emailUser,emailPass,emailRcpt,...
                ['Errors on ' station],message)
        end
        delete(pathImageError)
    end
    
    %% Sending Images
    numItems=0;
    for i=1:length(cameras)
        cam1=cameras{i};
        if strcmpi(type, 'image')
            pathList1=fullfile(tmppath, ['ListImage' cam1 '.mat']);
        else
            pathList1=fullfile(tmppath, ['ListStack' cam1 '.mat']);
        end
        if exist(pathList1, 'file')
            load(pathList1);
            if strcmpi(type, 'image')
                ind1 = find(cell2mat(ListImage(:, 3)) == 0); %Number of images to transfer for cam1
            else
                ind1 = find(cell2mat(ListStack(:, 5)) == 0); %Number of stacks to transfer for cam1
            end
            numItems=max(numItems,length(ind1));
        end
    end
    % Connecting to FTP
    [channel scp1] = connection_ssh(host, ftpUser, ftpPass);
    success = 1;
    
    try
        for j=1:numItems %Repeat the transfer for all images
            for i=1:length(cameras)
                if mod(success, 100) == 0
                    channel.close();
                    [channel scp1] = connection_ssh();
                    disp('Connection restarted!')
                end
                cam = cameras{i};
                if strcmpi(type, 'image')
                    pathList=fullfile(tmppath, ['ListImage' cam '.mat']);
                else
                    pathList=fullfile(tmppath, ['ListStack' cam '.mat']);
                end
                if exist(pathList, 'file')
                    load(pathList);
                else
                    continue
                end
                
                % FTP connected, then try to send images
                if strcmpi(type, 'image')
                    ind=find(cell2mat(ListImage(:, 3))==0);
                else
                    ind=find(cell2mat(ListStack(:, 5))==0);
                end
                if isempty(ind)
                    continue
                end
                posI=min(ind);
                
                if strcmpi(type, 'image')
                    disp(['sending image ' ListImage{posI,2}])
                    image=ListImage{posI,2};
                else
                    disp(['sending stack ' ListStack{posI,2}])
                    image=ListStack{posI,2};
                end
                textDate=image(1:8);
                textDate=datestr(datenum(textDate,'yy.mm.dd'),'yyyy.mm.dd');
                textDate=strrep(textDate,'.',filesep);
                pathImage=[filesep station filesep textDate filesep cam];
                
                pathImageRemote2=strrep(pathImage,'\','/');
                if ~isempty(rootPath) && rootPath(end) == '/'
                    rootPath = rootPath(1:end-1);
                end
                pathImageRemote = [rootPath pathImageRemote2];
                
                try
                    status_dir = isdir_ssh(channel, pathImageRemote);
                    
                    if strcmp('false', status_dir)
                        % if the directory change failed, create directories
                        change_create_directory (channel,pathImageRemote,cell(0));
                        status_dir = isdir_ssh(channel,pathImageRemote);
                    end
                    
                    if strcmp('true', status_dir)
                        
                        if strcmpi(type, 'image')
                            % Upload image
                            scp1.put(fullfile(ListImage{posI,1},ListImage{posI,2}),pathImageRemote);
                            disp([ListImage{posI,2} ' image transferred'])
                            % Put a 1 on the List of Images
                            ListImage{posI, 3} = 1;
                            save(pathList, 'ListImage');
                        else
                            % Upload stack
                            scp1.put(fullfile(ListStack{posI,1},ListStack{posI,2}),pathImageRemote);
                            disp([ListStack{posI,2} ' stack transferred'])
                            % Put a 1 on the List of Stacks
                            ListStack{posI, 5} = 1;
                            save(pathList, 'ListStack');
                        end
                        
                        success = success + 1;
                        
                    end
                catch e
                    channel.close();
                    [channel scp1] = connection_ssh();
                    disp('Connection restarted!')
                end
                
            end
            % If current minute is for capturing images, do not send more stacks
            cur_minute = mod(floor(now * 24 * 60), 24 * 60); % Current minute
            if strcmpi(type, 'stack') && cur_minute >= ti_process && ...
                    cur_minute <= tf_process
                break;
            end
        end
    catch e
        disp(e.message);
    end
    
    
    %% Review ERRORS on data transmision archive and send information if needed
    if exist(pathSendError, 'file')
        load(pathSendError);
        
        RowN=size(Errors,1);
        if RowN>19 %More than 19 errors causes a mail to be send
            message=[];
            for j=RowN:-1:1
                message=[message 10 Errors{j,2} ' at ' Errors{j,1}];
            end
            sendmailgmail(emailUser,emailPass,emailRcpt,...
                ['Errors on ' station],message)
        end
        delete(pathSendError)
    end
    
    disp(['Transfers finished at ' datestr(now)])
    
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Create an SSH connection using external Java libraries.
function [channel scp1] = connection_ssh(hostName, userName, password)
% Input:
%   hostName: IP address or host name of the server.
%   userName: User name of SSH login.
%   password: Password of SSH login.

try
    
    scp1 = [];
    import ch.ethz.ssh2.SCPClient;
    import ch.ethz.ssh2.Connection;
    import ch.ethz.ssh2.Session;
    
    %Set up the connection with the remote server
    
    try
        channel = Connection(hostName, 22);
        channel.connect();
    catch e
        error(['Error: SCPTOMATLAB could not connect to the'...
            ' remote machine %s ...'], hostName);
    end
    
    %
    %  Check the authentication for login...
    %
    
    try
        import java.io.File;
    catch e
        error('Error: SCPTOMATLAB could not find the java.io.File package');
    end
    
    isAuthenticated = channel.authenticateWithPassword(userName, password);
    
    if ~isAuthenticated
        error...
            (['Error: SCPTOMATLAB could not authenticate the',...
            ' SSH connection...']);
    end
    
    %Open session
    scp1 = SCPClient(channel);
    
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
function change_create_directory (channel, pathImageRemote, dirs)

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
    
    status_dir = isdir_ssh(channel, pathImageRemote);
    
    if strcmp('false', status_dir)
        % Save the directory to create
        dirs(end+1) = {pathImageRemote(parts(end)+1:end)};
        pathImageRemote = pathImageRemote(1:parts(end)-1);
        if isempty(pathImageRemote)
            pathImageRemote = '/';
        end
        
        change_create_directory (channel, pathImageRemote, dirs);
    elseif strcmp('true', status_dir) && ~isempty(dirs)
        % Create Directory
        mkdir_ssh(channel, [pathImageRemote '/' char(dirs(end))])
        pathImageRemote = [pathImageRemote '/' char(dirs(end))];
        dirs(end) = [];
        change_create_directory(channel, pathImageRemote, dirs);
    end
    
catch e
    disp(e.message)
end


%--------------------------------------------------------------------------
% Checks if a remote location is indeed a directory.
function status_dir = isdir_ssh(channel,pathImageRemote)
% Input:
%   channel: connection object.
%   patImageRemote: directory to be checked.

try
    status_dir = 'false';
    import java.io.BufferedReader;
    import java.io.IOException;
    import java.io.InputStream;
    import java.io.InputStreamReader;
    import ch.ethz.ssh2.Connection;
    import ch.ethz.ssh2.Session;
    import ch.ethz.ssh2.StreamGobbler;
    
    command = ['if [ -d "' pathImageRemote '" ]; then '...
        'echo true; ' ...
        'else ' ...
        'echo false; ' ...
        'fi'];
    
    
    result = {''};
    channel2 = channel.openSession();
    channel2.execCommand(command);
    
    %
    % Report the result to screen and to the string result...
    %
    stdout = StreamGobbler(channel2.getStdout());
    br = BufferedReader(InputStreamReader(stdout));
    
    while true
        line = br.readLine();
        if isempty(line)
            break
        else
            if isempty(result{1})
                result{1} = char(line);
            else
                result{end+1} = char(line);
            end
        end
    end
    channel2.close();
    status_dir = char(result);
    
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Makes a directory in remote server.
function mkdir_ssh(channel,pathImageRemote)
% Input:
%   channel: connection object.
%   pathImageRemote: directory to be created.

try
    
    command = ['mkdir ' pathImageRemote ];
    
    channel2 = channel.openSession();
    channel2.execCommand(command);
    
catch e
    disp(e.message)
end