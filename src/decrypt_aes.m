function originalString = decrypt_aes(encrypted, path)

%DECRYPT_AES   Decrypt an hexadecimal string with the AES algorithm.
%The secret key is loaded from file disk.
%
% Input:
%   encrypted: string of hexadecimal bytes
%   path: Directory where key file is saved
%
% Output:
%   originalString: Decrypted message

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/12/22 15:55 $

try
    
    % Java stuff
    import java.security.*;
    import javax.crypto.*;
    import javax.crypto.spec.*;
    
    % Load secret key from disk
    if ~exist(fullfile(path, 'skeySpec.mat'), 'file')
        disp('ERROR: The file skeySpec.mat does not exist! Could not decrypt this password!')
        originalString = [];
        return
    end
    load(fullfile(path, 'skeySpec'));
    
    % Create cipher object
    cipher = Cipher.getInstance('AES');
    cipher.init(Cipher.DECRYPT_MODE, skeySpec);
    
    bytes = zeros(16, 1);
    
    for i = 1:16
        d = hex2dec(encrypted((2 * i - 1):(2 * i)));
        % if d > 2^7-1, it is in 2-complement
        if d >= 128
            d = d - 256;
        end
        bytes(i) = d;
    end
    
    original = cipher.doFinal(bytes);
    originalString = char(original');
    
catch e
    disp(e.message)
end