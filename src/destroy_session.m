function destroy_session()
%DESTROY_SESSION    Destroys a user session, by deleting the file with
%the user connection to the database.
%

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2012 HORUS
%   $Date: 2012/09/03 13:50 $

try
    % Set HORUS paths
    if ~isdeployed
        root = fileparts(mfilename('fullpath'));
        root = fileparts(root);
        addpath(genpath(root));
    end

    if isdeployed
        pathinfo = what('tmp');
        tmppath = pathinfo.path;
    else
        tmppath = fullfile(root, 'tmp');
    end

    datafile = 'userinfo.dat';
    keyfile = 'skeySpec.mat';
    if exist(fullfile(tmppath, datafile), 'file') &&...
       exist(fullfile(tmppath, keyfile), 'file')     
        delete(fullfile(tmppath, datafile));
        delete(fullfile(tmppath, keyfile));
        disp('Session destroyed!');
    end

catch e
    disp(e.message);
end