function node = removeNode(xml, xmlPath)

%REMOVENODE   Removes a node from the XML document.
%
% Input:
%   xml:      XML document object
%   xmlPath:  Path from a root node to the node where this node is to be
%       created. The path has the form
%       Node1[attr=val,...]/Node2[attr=val,...]/Node3[attr=val,...].../.../Noden[attr=val,...]
%
% Output:
%   node:     Object of the just-removed node.

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2012 HORUS
%   $Date: 2012/03/14 16:33 $

try
    
    node = [];
    
    % Split the path parts
    ind = strfind(xmlPath, '/');
    parentNode = cell(0);
    if ~isempty(ind)
        if ind(end) > 0
            % Get the parent part of the path
            parentPath = xmlPath(1:ind(end) - 1);
            % Get the node parent
            parentNode = getNodes(xml, parentPath);
            if ~isempty(parentNode)
                parentNode = parentNode{1};
            end
        end
    end
    
    if isempty(parentNode)
        return
    end
    
    % Now find the node to be removed
    childNode = getNodes(xml, xmlPath);
    if ~isempty(childNode)
        childNode = childNode{1};
    else
        return
    end
    
    node = childNode;
    % Actually remove the node
    parentNode.removeChild(childNode);
    
catch e
    disp(e.message)
end