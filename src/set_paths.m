function [status, message] = set_paths(paths_root, station)

%SET_PATHS  Create standard directories for storing oblique, merged,
%rectified images and thumbnails.
%
% The generated directories are:
%   paths_root/rectified
%   paths_root/merged/oblique
%   paths_root/merged/rectified
%   paths_root/thumbnail/oblique
%   paths_root/thumbnail/rectified
%   paths_root/thumbnail/merged/oblique
%   paths_root/thumbnail/merged/rectified
%
% After the paths are successfully created, the information is saved in the
% configuration file path_info.xml.
%
% By default, all subdirectories are created under the root path
% 'paths_root'. If the user needs a different location for the resulting
% images, he can change manually the XML file, or use the GUI
% 'gui_paths_editor', which is located in 'gui' under the HORUS' main
% directory.
%
%   Input:
%       paths_root: directory where all paths are to be created.
%       station: station name.
%
%   Output:
%       status: 0 if paths were created successfully, 1 otherwise.
%       message: error or success message.
%
%   Example:
%       set_paths('C:\horus\images');

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2013 HORUS
%   $Date: 2013/04/16 16:33 $

status = 1; % failure
message = [];
try
    % Set HORUS paths
    if ~isdeployed
        root = fileparts(mfilename('fullpath'));
        root = fileparts(root);
        addpath(genpath(root));
    end
    
    xmlfile = 'path_info.xml';
    
    path_rectified = fullfile(paths_root, station, 'rectified');
    path_merged_oblique = fullfile(paths_root, station, 'merged', 'oblique');
    path_merged_rect = fullfile(paths_root, station, 'merged', 'rectified');
    path_oblique_min = fullfile(paths_root, station, 'thumbnail', 'oblique');
    path_rectified_min = fullfile(paths_root, station, 'thumbnail', 'rectified');
    path_merged_oblique_min = fullfile(paths_root, station, 'thumbnail', 'merged', 'oblique');
    path_merged_rect_min = fullfile(paths_root, station, 'thumbnail', 'merged', 'rectified');
    
    if ~exist(path_rectified, 'dir')
        disp(['Creating directory: ' path_rectified])
        mkdir(path_rectified);
    end
    if ~exist(path_merged_oblique, 'dir')
        disp(['Creating directory: ' path_merged_oblique])
        mkdir(path_merged_oblique);
    end
    if ~exist(path_merged_rect, 'dir')
        disp(['Creating directory: ' path_merged_rect])
        mkdir(path_merged_rect);
    end
    if ~exist(path_oblique_min, 'dir')
        disp(['Creating directory: ' path_oblique_min])
        mkdir(path_oblique_min);
    end
    if ~exist(path_rectified_min, 'dir')
        disp(['Creating directory: ' path_rectified_min])
        mkdir(path_rectified_min);
    end
    if ~exist(path_merged_oblique_min, 'dir')
        disp(['Creating directory: ' path_merged_oblique_min])
        mkdir(path_merged_oblique_min);
    end
    if ~exist(path_merged_rect_min, 'dir')
        disp(['Creating directory: ' path_merged_rect_min])
        mkdir(path_merged_rect_min);
    end
    
    xml = loadXML(xmlfile, 'config');
    xmlPath = strcat('config/paths/site[name=', station, ']');
    pathsNodes = getNodes(xml, xmlPath);   
    if ~isempty(pathsNodes)
        paths = pathsNodes{1};
        % Load path
        % Checks to be a folder or a URL to display the path

        val = getNodeVal(paths, 'pathOblique');
        if ~isempty(val)
            pathOblique = strtrim(val);
        end
    end
    removeNode(xml, xmlPath);
        
    pathsElement = createNode(xml, xmlPath);
    
    createLeave(xml, pathsElement, 'pathOblique', pathOblique)
    createLeave(xml, pathsElement, 'pathRectified', path_rectified)
    createLeave(xml, pathsElement, 'pathMergeOblique', path_merged_oblique)
    createLeave(xml, pathsElement, 'pathMergeRectified', path_merged_rect)
    createLeave(xml, pathsElement, 'pathObliqueMin', path_oblique_min)
    createLeave(xml, pathsElement, 'pathRectifiedMin', path_rectified_min)
    createLeave(xml, pathsElement, 'pathMergeObliqueMin', path_merged_oblique_min)
    createLeave(xml, pathsElement, 'pathMergeRectifiedMin', path_merged_rect_min)

    disp(['Saving paths configuration in ' xmlfile])
    xmlsave(xmlfile, xml);
    
    status = 0; % success
    message = 'Paths were generated successfully!';
catch e
    disp(e.message)
    message = e.message;
end