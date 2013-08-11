function [flag children] = load_node_xml(theNode,pattern,varargin)

% LOAD_NODE_XML this function is used for finding the children nodes of TheNode
% labeled with pattern
%
%   Input:
%   theNode: Node of the xml.
%   pattern: Pattern of search.
%   varargin: Station name when pattern is 'site'.
%
%   Output:
%   flag: This indicates the success with 1 or failure with 0 of the load
%         node
%   children: Children node object.
%
%   Example:
%   load_node_xml(theNode,'site', 'CARTAGENA')

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/08/18 8:00 $

try
    flag=0;
    children=NaN;
    % if he has children nodes
    if theNode.hasChildNodes
        % get children node
        childNodes = theNode.getChildNodes;
        % number of children nodes
        numChildNodes = childNodes.getLength;
        for count = 1:numChildNodes
            % get the children node.
            theNode2 = childNodes.item(count-1);
            % compare the obtained node with the pattern
            if strcmp(char(theNode2.getNodeName),pattern)
                if strcmp('site',pattern)
                    if theNode2.hasAttributes
                        theAttributes = theNode2.getAttributes;
                        attrib = theAttributes.item(0);
                        % compare the attribute name with the varargin (site)
                        if(strcmp(char(attrib.getValue),varargin))
                            flag=1;
                            children = theNode2;
                            break;
                        end
                    end
                else
                    flag=1;
                    children = theNode2;
                    break;
                end
                
            else
                flag=0;
                children=NaN;
            end
        end
    end
catch e
    disp(e.message)
end