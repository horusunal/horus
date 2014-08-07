function [status, message] = set_database(passwd, host, dbname, port, username, userpass, sql)

% SET_DATABASE this function is used to configure a new HORUS database.
%
%   Input:
%       passwd: Password of the root user (must have been created)
%       host: IP address or host name of database server
%       dbname: Database name
%       port: Port of database server
%       username: Nickname of the HORUS administrator
%       userpass: Password of the HORUS administrator
%       sql: Path where the SQL HORUS file is located
%
%   Output:
%       status: 0 if paths were created successfully, 1 otherwise.
%       message: error or success message.
%
%   Example:
%       set_database('abc123', '192.168.1.177', 'horusdb', 3306, 
%                     'horususer', 'xyz123', 'C:\horus\examples\horus.sql')
%

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2013/04/04 15:19 $

status = 1; % failure
message = [];
try
    % Set HORUS paths
    if ~isdeployed
        root = fileparts(mfilename('fullpath'));
        root = fileparts(root);
        addpath(genpath(root));
    end
    
    if ~ischar(port)
        port = num2str(port);
    end
        
    if ~exist('com.mysql.jdbc.Driver', 'class')
        jconnection = which('mysql-connector-java-5.1.25-bin.jar');
        javaaddpath(jconnection)
    end
    
    % Data of the connection
    jdbcString = sprintf('jdbc:mysql://%s:%s', host, port);
    jdbcDriver = 'com.mysql.jdbc.Driver';

    % Create a connection with the root account
    conn = database('', 'root', passwd, jdbcDriver, jdbcString);
    if isempty(conn.Driver)
        message = 'Error detected! Check the fields!';
        return;
    end
    % Create database schema and main user
    exec(conn, ['CREATE DATABASE ' dbname]);
    exec(conn, ['CREATE USER ''' username '''@''' host ''' IDENTIFIED BY ''' userpass '''']);
    exec(conn, ['GRANT ALL PRIVILEGES ON ' dbname '.* TO ''' username ...
        '''@''localhost'' IDENTIFIED BY ''' userpass ''' WITH GRANT OPTION']);
    exec(conn, ['GRANT CREATE USER, RELOAD ON *.* TO ''' username ...
        '''@''localhost'' IDENTIFIED BY ''' userpass ''' WITH GRANT OPTION']);
    exec(conn, ['GRANT ALL PRIVILEGES ON ' dbname '.* TO ''' username ...
        '''@''%'' IDENTIFIED BY ''' userpass ''' WITH GRANT OPTION']);
    exec(conn, ['GRANT CREATE USER, RELOAD ON *.* TO ''' username ...
        '''@''%'' IDENTIFIED BY ''' userpass ''' WITH GRANT OPTION']);
    
    exec(conn, ['GRANT SELECT, INSERT, UPDATE, DELETE ON mysql.* TO ''' username ...
        '''@''%'' IDENTIFIED BY ''' userpass '''']);
    exec(conn, ['GRANT SELECT, INSERT, UPDATE, DELETE ON mysql.* TO ''' username ...
        '''@''localhost'' IDENTIFIED BY ''' userpass '''']);
    
    exec(conn, 'FLUSH PRIVILEGES');
    
    close(conn);
    
    % Create the HORUS database structure, if available
    if exist(sql, 'file')
        if ismac
            command = ['/usr/local/mysql/bin/mysql -h ' host ' -u ' username ' -p' userpass ' ' dbname ' < ' sql];
        else    
            command = ['mysql -h ' host ' -u ' username ' -p' userpass ' ' dbname ' < ' sql];
        end
        [status, message] = dos(command);
    end
    if status == 0
        message = 'Successful database configuration!';
    end
    
catch e
    disp(e.message)
end