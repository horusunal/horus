function [varargout] = import_db(filename,path)

% IMPORT_DB this function is used for importing all the database
% information.
%
%   Input:
%   filename: Filename from which to import the database information, it
%   must have extension. sql.
%   path: Path of the file from which to import.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the data import was
%   successful, 1 otherwise.
%
%   Example:
%   status = import_db('export.sql','D:\HORUS')

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/11/4 11:00 $

try
    
    if nargout==1
        varargout(1)={1}; % Initially, failure
    end
    command = ['mysql -h localhost -u horus -psol123 < ' fullfile(path,filename)];
    status = dos(command);
    if ~status
        if nargout==1
            varargout(1)={0}; % Success
        end
    end
    
catch e
    disp(e.message)
end