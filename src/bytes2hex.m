function hash = bytes2hex(dig)
% BYTES2HEX converts an array of bytes to hexadecimal.
%
%   Input:
%   dig: Array of numbers (uint8 or int8)
%
%   Output:
%   hash: String with the representation of the array in hexadecimal. If
%         there are negative numbers (2-complement), these are converted to
%         positive numbers
%
%   Example:
%   array = [13, 25, 92, -26];
%   hash = bytes2hex(array);

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/12/22 15:47 $

try
    hash = [];
    for i = 1:numel(dig)
        n = double(dig(i));
        if  n < 0
            % Convert to positive
            n = 256 + n;
        end
        hash = [hash dec2hex(n, 2)];
    end
    
catch e
    disp(e.message)
end