function insert_images_recursively(root, station, type)

%INSERT_IMAGES_RECURSIVELY   This is the caller function for
%SEARCH_AND_INSERT_IMAGES. Creates a database connection, calls
%SEARCH_AND_INSERT_IMAGES and close the database connection.
%
% Input:
%   root: Directory where the image directory tree is contained. MUST
%   be an absolute path (e.g. C:\DBIMAGE).
%   station: station name, in uppercase. If this variable is empty, you
%   want to insert all the stations. (e.g. CARTAGENA)
%   type: type of image to be inserted into the database must be:
%           'oblique', 'rectified', 'merge_oblique' or 'merge_rectified'

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/10/28 09:54 $

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
    search_and_insert_images(root, parts{1}, station, type);
    
catch e
    disp(e.message)
end