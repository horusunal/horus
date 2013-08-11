function delete_paths(filename,station)

% DELETE_PATHS this function is used for deleting a site in path_info.xml
%
%   Input:
%   filename: Name of the file path_info.xml.
%   station: Name of the station to add.
%
%   Example:
%   delete_paths('path_info.xml','PAJARITO')

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/08/18 9:30 $


try
    % Load XML
    xml = loadXML(filename, 'config');
    xmlPath = strcat('config/paths/site[name=', station, ']');
    
    % delete the site of the file path_info.xml
    removeNode(xml, xmlPath);
    
    % save the file
    xmlsave(filename, xml);
    
catch e
    disp(e.message)
end