function [varargout] = load_paths(filename,station)

% LOAD_PATHS this function is used for loading the paths of
%           a station from the xml file.
%
%   Input:
%   filename: Name of the file path_info.xml.
%   station: Name of the station to add.
%
%   Output:
%   varargout: paths for the station.
%
%   Example:
%   [pathOblique pathRectified] = load_paths('path_info.xml','PAJARITO');

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/08/18 10:30 $

try
    
    % read the file path_info.xml
    
    xml = loadXML(filename, 'config');
    xmlPath = strcat('config/paths/site[name=', station, ']');
    pathsNodes = getNodes(xml, xmlPath);
    
    nout = max(nargout,1);
    varargout = cell(1, nout);
    if ~isempty(pathsNodes)
        paths = pathsNodes{1};
        % Load path
        
        strPaths{1} = getNodeVal(paths, 'pathOblique');
        strPaths{2} = getNodeVal(paths, 'pathRectified');
        strPaths{3} = getNodeVal(paths, 'pathMergeOblique');
        strPaths{4} = getNodeVal(paths, 'pathMergeRectified');
        strPaths{5} = getNodeVal(paths, 'pathObliqueMin');
        strPaths{6} = getNodeVal(paths, 'pathRectifiedMin');
        strPaths{7} = getNodeVal(paths, 'pathMergeObliqueMin');
        strPaths{8} = getNodeVal(paths, 'pathMergeRectifiedMin');
        
        % assigning the paths
        for i = 1:nout
            varargout{i} = strtrim(strPaths{i});
        end
    else
        for i = 1:nout
            varargout{i} = '';
        end
    end
    
catch e
    disp(e.message)
end