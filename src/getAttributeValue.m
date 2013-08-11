function val = getAttributeValue(rootNode, attribName)

%GETATTRIBUTEVALUE   Return the value of the attribute associated to a
%node.
%
% Input:
%   rootNode:     Node for which we want to know the attribute value.
%   attribName:   Name of the attribute.
%
% Output:
%   val:          Attribute value (as a string)

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2012 HORUS
%   $Date: 2012/03/14 16:17 $

try
    
    val = [];
    
    if rootNode.hasAttributes()
        attributes = rootNode.getAttributes();
        numAttributes = attributes.getLength();
        
        % Loop through all the attributes
        for j = 1:numAttributes
            attrib = attributes.item(j - 1);
            name = char(attrib.getName());
            value = char(attrib.getValue());
            
            % If the attribute is found, assign value
            if strcmpi(name, attribName)
                val = value;
                break
            end
        end
    end
    
catch e
    disp(e.message)
end
