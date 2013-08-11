function node = createNode(xml, xmlPath)

%CREATENODE   Create a node according to the path.
%
% Input:
%   xml:     XML document object
%   xmlPath: Path from a root node to the node where this node is to be
%       created. The path has the form
%       Node1[attr=val,...]/Node2[attr=val,...]/Node3[attr=val,...].../.../Noden[attr=val,...]
% Output:
%   node:    Node object just created

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2012 HORUS
%   $Date: 2012/03/14 16:08 $

try
    
    node = [];
    
    % Positions of '/' in xmlPath
    ind = strfind(xmlPath, '/');
    parentPath = [];
    nodeStr = xmlPath;
    
    % Parent node is initially empty
    parentNode = cell(0);
    if ~isempty(ind) % If there is more than one node in the path
        if ind(end) > 0
            parentPath = xmlPath(1:ind(end) - 1);
            % Get parent node
            parentNode = getNodes(xml, parentPath);
            if ~isempty(parentNode)
                parentNode = parentNode{1};
            end
        end
        
        if ind(end) < length(xmlPath)
            % Get child node part of the path
            nodeStr = xmlPath(ind(end) + 1:end);
        end
    end
    
    % If the parent was not found, then it must be created recursively
    if isempty(parentNode)
        parentNode = createNode(xml, parentPath);
    end
    
    attribBegin = strfind(nodeStr, '[');
    attribEnd = strfind(nodeStr, ']');
    
    strAttrib = [];
    curNodeName = nodeStr;
    % Separe node name and set of attributes
    if ~isempty(attribBegin) && ~isempty(attribEnd)
        curNodeName = nodeStr(1:attribBegin(1) - 1);
        strAttrib = nodeStr(attribBegin(1) + 1:attribEnd(1) - 1);
    end
    
    % Parse attributes names and values
    attribNames = cell(0);
    attribValues = cell(0);
    if ~isempty(strAttrib)
        partsAttrib = regexp(strAttrib, ',', 'split');
        len = numel(partsAttrib);
        attribNames = cell(len, 1);
        attribValues = cell(len, 1);
        
        for i = 1:len
            partsTmp = regexp(partsAttrib{i}, '=', 'split');
            attribNames{i} = partsTmp{1};
            attribValues{i} = partsTmp{2};
        end
    end
    
    % Create node in XML document
    newElement = xml.createElement(curNodeName);
    % Append the created node to the parent node
    parentNode.appendChild(newElement);
    
    % Create attributes
    for i = 1:numel(attribNames)
        attrib = xml.createAttribute(attribNames{i});
        attrib.setValue(attribValues{i});
        newElement.setAttributeNode(attrib);
    end
    
    node = newElement;
    
catch e
    disp(e.message)
end