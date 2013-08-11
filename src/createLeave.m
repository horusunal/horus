function createLeave(xml, parentElement, childName, textNode)

%CREATELEAVE   Create a leave node in the XML tree.
%
% Input:
%   xml:     XML document object
%   parentElement: Node which acts as parent of the leave node.
%   childName: Leave node name
%   textNode:  Value of the node (as it is a leave, it cannot have subtrees)

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2012 HORUS
%   $Date: 2012/03/14 16:04 $

try
    
    % Create leave node
    childElement = xml.createElement(childName);
    
    % Assign value to the leave node
    childElement.appendChild(xml.createTextNode(textNode));
    
    % Append leave node to parent node
    parentElement.appendChild(childElement);
    
catch e
    disp(e.message)
end