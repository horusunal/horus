function hash = encrypt_password(pass)

%ENCRYPT_PASSWORD   Encrypt a string with the SHA-1 algorithm.
%
% Input:
%   pass: a string to be encrypted.
%
% Output:
%   hash: encrypted string in hexadecimal

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/12/22 16:02 $

try
    % Java stuff
    import java.security.*;
    
    d = MessageDigest.getInstance('SHA-1');
    d.reset();
    d.update(double(pass))
    dig = d.digest();
    
    hash = bytes2hex(dig);
    
catch e
    disp(e.message)
end