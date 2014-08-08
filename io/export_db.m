function [varargout] = export_db(filename,path)

% EXPORT_DB this function is used for exporting all the database
% information.
%
%   Input:
%   filename: Filename where database information will be exported to,
%   written without the filename extension.
%   path: Directory where filename will be saved.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the data export was
%   successful, 1 otherwise.
%
%   Example:
%   status = export_db('export','D:\HORUS')

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/11/4 10:00 $

try
    
    if nargout==1
        varargout(1)={1}; % Initially, failure
    end
    filename=[filename '.sql'];
    if ismac
        command = ['/usr/local/mysql/bin/mysqldump --opt -h localhost -u horus -psol123 -B horus > ' fullfile(path,filename)];
        [status, message] = unix(command);
    else    
        command = ['mysqldump --opt -h localhost -u horus -psol123 -B horus > ' fullfile(path,filename)];
        [status, message] = dos(command);
    end

    if ~status
        if nargout==1
            varargout(1)={0}; % Success
        end
    end
    
catch e
    disp(e.message)
end