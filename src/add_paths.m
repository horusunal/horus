function add_paths(filename,station)

% ADD_PATHS this function is used for adding a station in path_info.xml
%           with the existing station information.
%
%   Input:
%   filename: Name of the file path_info.xml.
%   station: Name of the station to add.
%
%   Example:
%   add_paths('path_info.xml','PAJARITO')

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/08/18 9:00 $

try
    
    xml = loadXML(filename, 'config');
    xmlPath = strcat('config/paths/site');
    pathsNodes = getNodes(xml, xmlPath);
    
    if ~isempty(pathsNodes)
        paths = pathsNodes{1};
        % Load path
        
        pathOblique = getNodeVal(paths, 'pathOblique');
        pathRectified = getNodeVal(paths, 'pathRectified');
        pathMergeOblique = getNodeVal(paths, 'pathMergeOblique');
        pathMergeRectified = getNodeVal(paths, 'pathMergeRectified');
        pathObliqueMin = getNodeVal(paths, 'pathObliqueMin');
        pathRectifiedMin = getNodeVal(paths, 'pathRectifiedMin');
        pathMergeObliqueMin = getNodeVal(paths, 'pathMergeObliqueMin');
        pathMergeRectifiedMin = getNodeVal(paths, 'pathMergeRectifiedMin');
        
        
        xml = loadXML(filename, 'config');
        xmlPath = strcat('config/paths/site[name=', station, ']');
        
        removeNode(xml, xmlPath);
        
        pathsElement = createNode(xml, xmlPath);
        
        createLeave(xml, pathsElement, 'pathOblique', sprintf('%s', pathOblique))
        createLeave(xml, pathsElement, 'pathRectified', sprintf('%s', pathRectified))
        createLeave(xml, pathsElement, 'pathMergeOblique', sprintf('%s', pathMergeOblique))
        createLeave(xml, pathsElement, 'pathMergeRectified', sprintf('%s', pathMergeRectified))
        createLeave(xml, pathsElement, 'pathObliqueMin', sprintf('%s', pathObliqueMin))
        createLeave(xml, pathsElement, 'pathRectifiedMin', sprintf('%s', pathRectifiedMin))
        createLeave(xml, pathsElement, 'pathMergeObliqueMin', sprintf('%s', pathMergeObliqueMin))
        createLeave(xml, pathsElement, 'pathMergeRectifiedMin',sprintf('%s', pathMergeRectifiedMin))
        
        % save the file
        xmlsave(filename, xml);
    end
    
catch e
    disp(e.message)
end