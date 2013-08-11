function  dbConn  = connection_db(reset)

% CONNECTION_DB this function is used to create a connection to HORUS
% database.
%
%   Input:
%       reset: boolean value which, if true (and if present) determines if
%       the file with the login information should be deleted, after a
%       connection issue. If this argument is not present, then it is
%       assumed that the file must be reseted.
%   Output:
%   dbConn: Connection object.
%
%   Example:
%   dbConn = connection_db();

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/18 8:00 $

try
    
    % Set HORUS paths
    if ~isdeployed
        root = fileparts(mfilename('fullpath'));
        root = fileparts(root);
        addpath(genpath(root));
    end
    jconnection = which('mysql-connector-java-5.1.25-bin.jar');
    javaaddpath(jconnection)
    if nargin == 0
        reset = true;
    end
    
    ok = false;
    dbConn = database();
    
    if isdeployed
        pathinfo = what('tmp');
        tmppath = pathinfo.path;
    else
        tmppath = fullfile(root, 'tmp');
    end
    
    while ~ok
        ok = true;
        if ~exist(fullfile(tmppath, 'userinfo.dat'), 'file')
            go = gui_login();
            if ~go
                break
            end
        end
        
        try
            % The login information is saved in 'userinfo.dat'
            fid = fopen(fullfile(tmppath, 'userinfo.dat'), 'r');
            
            user = nextValue(fid);
            password = nextValue(fid);
            host = nextValue(fid);
            port = nextValue(fid);
            dbase = nextValue(fid);
            
            fclose(fid);
        catch e
            disp(e.message)
        end
        password = decrypt_aes(password, tmppath);
        
        % Data of the connection
        jdbcString = sprintf('jdbc:mysql://%s:%s/%s', host, port, dbase);
        jdbcDriver = 'com.mysql.jdbc.Driver';
        
        % Create the connection
        dbConn = database(dbase, user, password, jdbcDriver, jdbcString);
        
        if ~isconnection(dbConn)
            if reset
                delete(fullfile(tmppath, 'userinfo.dat'));
                delete(fullfile(tmppath, 'skeySpec.mat'));
            end
            ok = false;
        end
    end
    
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Reads next line in database connection file, and returns the value if the
% line is of the form: attr=val
function value = nextValue(fid)
% Input:
%   fid: File handle.
try
    
    line = fgetl(fid);
    parts = regexp(line, '\=', 'split');
    value = parts{2};
    
catch e
    disp(e.message)
end