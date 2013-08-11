function isLeave = parseXML(str, depth, fid)

%PARSEXML   Recursive function that properly indents and saves in a file 
% an XML code.
%
% Input:
%   str:    String with the XML code
%   depth:  depth of indentation
%   fid:    handle of the file where the indented code will be saved
%
% Output:
%   isLeave: Boolean value, true if str is a value text, false, if str is a
%   subtree

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/10/28 17:45 $

try
    
    isLeave = false;
    
    % Base case
    if isempty(str)
        isLeave = true;
        return
    end
    
    % Remove trailing spaces
    str = strtrim(str);
    
    % Find indices of '<' characters
    indopen = strfind(str, '<');
    % Find indices of '>' characters
    indclose = strfind(str, '>');
    
    % If one or both lists are empty, print in file and return
    if isempty(indopen) || isempty(indclose)
        fprintf(fid, '%s',str);
        isLeave = true;
        return
    end
    
    n = length(str);
    
    % Print header line
    if numel(indopen) >= 1 && numel(indclose) >= 1 &&...
            n >= 5 && strcmp(str(1:5), '<?xml')
        strheader = str(indopen(1):indclose(1));
        fprintf(fid, '%s', strheader);
        
        if n > indclose(1)
            parseXML(str(indclose(1) + 1:end), depth, fid);
            return
        end
    end
    
    % Handle single tags e.g. <tag/>
    if numel(indopen) == 1 && numel(indclose) == 1 && ...
            str(1) == '<' && str(n - 1) == '/' && str(n) == '>'
        indent2 = repmat(' ', 1, 4 * depth);
        fprintf(fid, '\n%s',[indent2 str]);
        return
    end
    
    % Text between the first '<' and the first '>'
    strOpen = str(indopen(1):indclose(1));
    
    % If there are attributes inside the mark (e.g. <site name="CARTAGENA">)
    parts = regexp(strOpen, '[ <>]+', 'split');
    strClose = ['</' parts{2} '>'];
    
    % Initial position of the text between the opening mark and the
    % corresponding closing mark
    indini = indclose(1) + 1;
    
    cnt = 1;
    k = indclose(1) + 1;
    
    foundClose = true;
    
    % Search the final position of the text between the opening mark and the
    % corresponding closing mark
    
    % The idea is to search the corresponding closing mark, considering that
    % there could be many possible closing marks, but only one matches.
    % Whenever find an opening mark, increment the counter, and decrement it if
    % find a closing mark. When the count drops to zero, the corresponding
    % closing mark is found.
    while cnt > 0 && k <= n && foundClose
        ind1 = strfind(str(k:end), strOpen);
        ind2 = strfind(str(k:end), strClose);
        
        if isempty(ind2)
            foundClose = false;
            continue
        end
        
        if ~isempty(ind1)
            if ind1(1) < ind2(1)
                cnt = cnt + 1;
                k = k - 1 + ind1(1) + length(strOpen);
            else
                cnt = cnt - 1;
                k = k - 1 + ind2(1) + length(strClose);
            end
        elseif ~isempty(ind2)
            cnt = cnt - 1;
            k = k - 1 + ind2(1) + length(strClose);
        end
    end
    
    % Final position of the text between the opening mark and the
    % corresponding closing mark
    indend = k - length(strClose) - 1;
    
    % Indent according to the depth
    indent = repmat(' ', 1, 4 * depth);
    % Print to the file
    fprintf(fid, '\n%s',[indent strOpen]);
    
    if foundClose
        % Recursively process the text between the opening and closing marks.
        strmid = str(indini:indend);
        isLeave = parseXML(strmid, depth + 1, fid);
        
        if isLeave
            fprintf(fid, '%s', strClose);
            isLeave = false;
        else
            fprintf(fid, '\n%s', [indent strClose]);
        end
    end
    
    % If there is more text to be process, recursively process that text
    if k < n
        parseXML(str(k:end), depth, fid);
    end
    
catch e
    disp(e.message)
end