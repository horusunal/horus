function create_session(username, password, ipaddress, dbname, dbport)
%CREATE_SESSION    Creates a new user session, by generating the file with
%the user connection to the database.
%
% Input:
%   username: Database user name.
%   password: Plain text password for database connection.
%   ipaddress: IP address or hostname of the database server.
%   dbname: Database name.
%   dbport: Database port.
%
% Example:
%   create_session('horus', 'abc123', 'localhost', 'horus', '3306')
%

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2012 HORUS
%   $Date: 2012/09/03 13:49 $

try
    if isnumeric(dbport)
        dbport = str2double(dbport);
    end
    % Set HORUS paths
    if ~isdeployed
        root = fileparts(mfilename('fullpath'));
        root = fileparts(root);
        addpath(genpath(root));
    end

    % Path of temporary file where session information will be saved
    if isdeployed
        pathinfo = what('tmp');
        tmppath = pathinfo.path;
    else
        tmppath = fullfile(root, 'tmp');
    end

    userfile = 'userinfo.dat';

    % Encrypt password with symmetric cryptographic algoritm AES, in order to
    % not save the password in plain text, and afterwards being able to decrypt
    % it. The secret key used to encrypt and decrypt is saved as a Java object
    % in 'tmp'.
    password = encrypt_aes(password, tmppath);

    fid = fopen(fullfile(tmppath, userfile), 'w');
    fprintf(fid, 'name=%s\n', username);
    fprintf(fid, 'password=%s\n', password);
    fprintf(fid, 'host=%s\n', ipaddress);
    fprintf(fid, 'port=%s\n', dbport);
    fprintf(fid, 'dbname=%s\n', dbname);
    fclose(fid);
    
    disp('Session created!')
catch e
    disp(e.message);
end
