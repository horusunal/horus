function val = getNodeVal(rootNode, xmlPath)

%GETNODEVAL   Return the value of a node.
%
% Input:
%   rootNode:     Node from which the XML path begins.
%   xmlPath:      Path from the root node. The path has the form
%       Node1[attr=val,...]/Node2[attr=val,...]/Node3[attr=val,...].../.../Noden[attr=val,...]
%
% Output:
%   val:          Value of the node (as a string)

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2012 HORUS
%   $Date: 2012/03/14 16:28 $

try
    
    val = [];
    
    % First search the node(s)
    node = getNodes(rootNode, xmlPath);
    if isempty(node)
        return
    end
    % Then extract the value
    val = strtrim(char(node{1}.getTextContent()));
    
catch e
    disp(e.message)
end