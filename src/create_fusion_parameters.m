function [parameters mergedimg message] = create_fusion_parameters(imgs, options, cameras, uvaffine, dorectify)

%CREATE_FUSION_PARAMETERS   Generate the model parameters for the
%fusion calibration.
%
% Input:
%   imgs:    images to be calibrated
%   options: cell with the methods of fusion. 1: Affine, 2: Projective, 3:
%       Optmized affine, 4: Optimized projective.
%   cameras: cameras involved in the fusion calibration
%   uvaffine: Common GCP coordinates in the format:
%            {[u1left, v1left], [u1right, v1right], [u2left, v2left], [u2right, v2right], ...}
%             ------------------------------------  ------------------------------------
%                     First pair                               Second pair
%   dorectify: true if fusion is for rectified images, false otherwise.
%
% Output:
%   parameters: list of the affine matrices between pair of images. The
%               (e.g. {'H12', value, 'H23', value, ...})
%   mergedimg:  sample merged image for validation
%   message:    error message if any error, if not, empty

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/10/28 17:31 $


try
    % Set paths
    if ~isdeployed
        root = fileparts(mfilename('fullpath'));
        root = fileparts(root);
        addpath(genpath(root));
    end
    
    
    parameters = cell(0);
    message = [];
    mergedimg = [];
    % Find affine GCPs between 2 images----------------------------------------
    m = numel(cameras);
    
    if dorectify
        mergedimg = imgs{m};
        in = 1;
        jn = 1;
    end
    
    for k = m:-1:2
        option = options{k - 1};
        I1 = imgs{k - 1};
        I2 = imgs{k};
        
        uvleft = uvaffine{(k - 2) * 2 + 1};
        n_left = size(uvleft, 1);
        uvright = uvaffine{(k - 2) * 2 + 2};
        n_right = size(uvright, 1);
        
        if dorectify
            H = homography(uvleft, uvright + [jn * ones(n_right, 1) in * ones(n_left, 1)]);
        else
            if option == 1 || option == 3 % Affine transformation
                H = im2im(uvleft(:, 1), uvleft(:, 2), uvright(:, 1), uvright(:, 2), 1);
            elseif option == 2 || option == 4 % Projective transformation
                H = im2im(uvleft(:, 1), uvleft(:, 2), uvright(:, 1), uvright(:, 2), 2);
            end
            if isempty(H)
                return
            end
            if option == 3 || option == 4 % Optimized
                [H B F hist] = levmarProjective(I1, I2, [], [], H, 20, 10, 1e-5, 120);
            end
            Hall{k - 1} = H;
        end
        
        eval(['H' num2str(k - 1) num2str(k) ' = H;']);
        parameters{end + 1} = ['H' num2str(k - 1) num2str(k)];
        parameters{end + 1} = H;
        
        if dorectify
            [mergedimg in jn] = merge_images(I1, mergedimg, H);
        end
    end
    
    if ~dorectify
        mergedimg = mergeIms(imgs, Hall);
    end
    

catch e
    disp(e.message)
end