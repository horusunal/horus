function xmlsave(fileName, docNode)

% XMLSAVE this function is use for save the file xml
%
%   Input:
%   fileName: Name of the file path_info.xml.
%   docNode: Document Object Model node, as defined by the
%            World Wide Web consortium
%
%   Example:
%   xmlsave('path_info.xml', xml)

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/08/18 8:30 $

try
    
    % get document elements
    docNodeRoot=docNode.getDocumentElement;
    % change header of the XML
    str=strrep(char(docNode.saveXML(docNodeRoot)), 'encoding="UTF-16"','encoding="iso-8859-1"');
    
    pathinfo = what('data');
    datapath = pathinfo.path;
    
    % path to the file
    path=fullfile(datapath,fileName);
    % open the file
    fid=fopen(path, 'w');
    % properly indents and saves in a file an XML code
    parseXML(str, 0, fid);
    % close  the file
    fclose(fid);
    
catch e
    disp(e.message)
end