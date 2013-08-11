function node = getNodes(rootNode, xmlPath)

%GETNODES   Return the nodes in the end of the XML path (as a cell array).
%The search is made recursively.
%
% Input:
%   rootNode:     Node from which the XML path begins.
%   xmlPath:      Path from the root node. The path has the form
%       Node1[attr=val,...]/Node2[attr=val,...]/Node3[attr=val,...].../.../Noden[attr=val,...]
%
% Output:
%   node:         Cell array with the node objects.

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2012 HORUS
%   $Date: 2012/03/14 16:20 $

try
    
    node = cell(0);
    
    parts = regexp(xmlPath, '/', 'split');
    
    % Get the current node name
    nodeStr = parts{1};
    
    attribBegin = strfind(nodeStr, '[');
    attribEnd = strfind(nodeStr, ']');
    
    % Get the current node's attributes and values
    strAttrib = [];
    curNodeName = nodeStr;
    if ~isempty(attribBegin) && ~isempty(attribEnd)
        curNodeName = nodeStr(1:attribBegin(1) - 1);
        strAttrib = nodeStr(attribBegin(1) + 1:attribEnd(1) - 1);
    end
    
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
    
    childNodes = rootNode.getChildNodes();
    numChildNodes = childNodes.getLength();
    
    curNode = cell(0);
    % Loop through all the parent node's children
    for i = 1:numChildNodes
        childNode = childNodes.item(i - 1);
        nodeName = childNode.getNodeName();
        
        % If this children is the current node...
        if strcmp(nodeName, curNodeName)
            attributes = childNode.getAttributes();
            
            numAttrib = attributes.getLength();
            numStrAttrib = numel(attribNames);
            
            % Verify that all attributes match
            visited = zeros(numStrAttrib, 1);
            for j = 1:numAttrib
                attrib = attributes.item(j - 1);
                name = attrib.getName();
                value = attrib.getValue();
                
                for k = 1:numStrAttrib
                    if strcmp(name, attribNames{k}) &&...
                            strcmp(value, attribValues{k})
                        visited(k) = true;
                    end
                end
            end
            
            % If everything matches, then everything is OK
            ok = true;
            for k = 1:numStrAttrib
                ok = ok & visited(k);
            end
            
            % Maintain list of found nodes
            if ok
                curNode{end + 1} = childNode;
            end
        end
    end
    
    if ~isempty(curNode)
        if numel(parts) == 1
            node = curNode;
        else % If there is more path to walk through...
            xmlPath = parts{2};
            for i = 3:numel(parts)
                xmlPath = strcat(xmlPath, '/', parts{i});
            end
            
            % Branch and recursively search until the nodes are found
            for i = 1:numel(curNode)
                tmpnode = getNodes(curNode{i}, xmlPath);
                for j = 1:numel(tmpnode)
                    node{end + 1} = tmpnode{j};
                end
            end
        end
    end
    
catch e
    disp(e.message)
end