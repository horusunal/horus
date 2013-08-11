function xml = loadXML(xmlfile, rootName, varargin)

%LOADXML   Load or creates an XML object.
%
% Input:
%   xmlfile:     Name of the XML file.
%   rootName:    Name of the XML root node.
%   varargin:    A list of pairs of {attributeName, attributeValue} for the
%                root node
%
% Output:
%   xml:         XML document object.
%
% Example:
%   xml = loadXML('info.xml', 'Configuration', {'station', 'CARTAGENA'});

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2012 HORUS
%   $Date: 2012/03/14 16:30 $

try
    
    if ~exist(xmlfile, 'file')
        % Create XML document
        xml = com.mathworks.xml.XMLUtils.createDocument(rootName);
        rootNode = xml.getDocumentElement();
        
        optargs = numel(varargin);
        
        % Assign attributes to root node
        for i = 1:2:optargs
            attrib = xml.createAttribute(varargin{i});
            attrib.setValue(varargin{i + 1});
            rootNode.setAttributeNode(attrib);
        end
    else
        % Read XML document
        try
            xml = xmlread(xmlfile);
        catch e
            errordlg(['Failed to read XML file ' xmlfile '.'], 'Error');
            return
        end
    end
    
catch e
    disp(e.message)
end