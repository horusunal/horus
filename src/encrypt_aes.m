function encrypted = encrypt_aes(message, path)

%ENCRYPT_AES   Encrypt a string with the AES algorithm.
%The secret key is randomly generated and saved in the file disk.
%
% Input:
%   message: a string to be encrypted.
%   path: Directory where key file will be saved
%
% Output:
%   encrypted: encrypted message

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
    
    if ~exist(fullfile(path, 'skeySpec.mat'), 'file')
        % Generate secret key of 128 bytes
        kgen = KeyGenerator.getInstance('AES');
        kgen.init(128);

        skey = kgen.generateKey();
        raw = skey.getEncoded();
        skeySpec = SecretKeySpec(raw, 'AES');

        % Save secret key to disk
        save(fullfile(path, 'skeySpec'), 'skeySpec');
    end
    
    load(fullfile(path, 'skeySpec.mat'));
    % Create cipher object
    cipher = Cipher.getInstance('AES');
    cipher.init(Cipher.ENCRYPT_MODE, skeySpec);
    encrypted = cipher.doFinal(double(message));
    
    encrypted = bytes2hex(encrypted);
    
catch e
    disp(e.message)
end