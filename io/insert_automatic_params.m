function [varargout] = insert_automatic_params(conn, idauto, station, ...
    type, start_hour, start_minute, end_hour, end_minute, step, varargin)

%INSERT_AUTOMATIC_PARAMS   Insert a new set of capture parameters
%   INSERT_AUTOMATIC_PARAMS(station, start_hour, start_minute, ...
%   end_hour, end_minute, step)
%   inserts the tuple identified by a station.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   idauto: is the capture id.
%   station: is the name of the station.
%   type: is the capture type, and can be 'image', 'stack','transfer' or
%   'process'.
%   start_hour: is the hour when the capture begins.
%   start_minute: is the minute when the capture begins.
%   end_hour: is the hour when the capture ends.
%   end_minute: is the minute when the capture ends.
%   step: if how many minutes are waited between consecutive captures.
%   varargin: This can contain the following information.
%       duration: Duration of the capture.
%       num_images: is the number of images captured.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the insertion was
%   successful, 1 otherwise.
%
%   Example:
%       insert_automatic_params(conn, 1, 'CARTAGENA', ...
%       'image', 6, 0, 18, 0, 30, 'duration', 120, 9)

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/12/06 14:13 $

try
    station = upper(station);
    if nargout >= 1
        varargout(1)={1};
    end
    
    % Insert in the database
    
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    try
        % Data for insertion in automaticparams
        colnames = {'idauto', 'station', 'type', 'start_hour', 'start_minute', ...
            'end_hour', 'end_minute', 'step'};
        extdata = {idauto, station, type, start_hour, start_minute, ...
            end_hour, end_minute, step};
        
        noptargs = numel(varargin);
        if mod(noptargs, 2) == 1
            disp(dberror('args'));
            return;
        end
        
        for i = 1:2:noptargs
            arg = varargin{i};
            value = varargin{i+1};
            
            colnames{end+1} = arg;
            extdata{end+1} = value;
        end
        
        fastinsert(conn, ['automaticparams_' station], colnames, extdata);
        if nargout >= 1
            varargout(1)={0};
        end
        
    catch e
        disp([dberror('insert') e.message]);
    end
    
catch e
    disp(e.message)
end