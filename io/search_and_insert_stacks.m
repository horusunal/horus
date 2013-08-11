function search_and_insert_stacks(root, station, path)

%SEARCH_AND_INSERT_STACKS   Recursively searches stacks within a directory
%tree and inserts it in the database.
%
% Requirements: - The database must be correctly set up, and the station and
% cameras corresponding to all stacks must be present in the database.
%               - The stack format must conform to HORUS image format:
%      YY.MM.DD.HH.mm.SS.GMT.station.camera.STACK.X.Y.widthXheight.HORUS.avi
%
% Input:
%   root: is the root directory (parent of the station directories, e.g.
%   C:\dbimage).
%   station: Name of the station.
%   path: is where the search should start. If the search is for ALL the
%   stations, path = ''. If the search is for a specific station, path =
%   'station name' (e.g. path = 'CARTAGENA')
%
% Assuming that all requirements are fulfilled, every stack will be
% inserted into the database.

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2012 HORUS
%   $Date: 2012/05/23 15:54 $

try
    station = upper(station);
    % Attempts to create a connection
    
    S = dir(fullfile(root, path));
    
    conn  = connection_db();
    if ~isconnection(conn)
        
        disp([dberror('conn') conn.Message]);
        return;
    end
    
    for i = 3:numel(S)
        if S(i).isdir
            search_and_insert_stacks(root, station, fullfile(path, S(i).name));
        else
            parts = regexp(S(i).name, '\.', 'split');
            ext = parts(end);
            if ~strcmpi(ext, 'avi')
                continue;
            end
            
            failed = insert_stack_by_file(conn, station, root, S(i).name, path);
            
            if failed
                disp([dberror('insert') S(i).name]);
            else
                disp(['Stack ' S(i).name ' successfully inserted!']);
            end
            
        end
    end
    close(conn)
    
catch e
    disp(e.message)
end