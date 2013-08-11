function insert_stacks_recursively(root, station)

%INSERT_STACKS_RECURSIVELY   This is the caller function for
%SEARCH_AND_INSERT_STACKS. Creates a database connection, calls
%SEARCH_AND_INSERT_STACKS and close the database connection.
%
% Input:
%   root: Directory where the stacks directory tree is contained. MUST
%   be an absolute path (e.g. C:\DBIMAGE).
%   station: station name, in uppercase. If this variable is empty, you
%   want to insert all the stations. (e.g. CARTAGENA)

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2012 HORUS
%   $Date: 2012/05/23 15:52 $

try
    station = upper(station);
    % Add the necessary HORUS paths
    if ~isdeployed
        root2 = fileparts(mfilename('fullpath'));
        root2 = fileparts(root2);
        addpath(genpath(root2));
    end
    
    % Call the recursive function for searching image in the whole directory
    parts = regexp(station, '[\\/]+', 'split');
    search_and_insert_stacks(root, parts{1}, station);
    
catch e
    disp(e.message)
end