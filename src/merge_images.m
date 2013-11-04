function [mergedimg in jn] = merge_images(img1, img2, H)

%MERGE_IMAGES   Merge two images with the affine matrix H.
%
% Input:
%   img1: First image
%   img2: Second image
%   H:    Affine matrix
%
% Output:
%   mergedimg:  Merged image
%   in:
%   jn:

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/10/28 17:31 $

try
    mergedimg = [];
    in = [];
    jn = [];
    [h1 w1 o] = size(img1);
    [h2 w2 o] = size(img2);
    
    N = 1;
    uv = H * [1 w2 w2 1;
        1 1 h2 h2;
        1 1 1 1];
    
    U = uv(1, :) ./ uv(3, :);
    V = uv(2, :) ./ uv(3, :);
    
    minU = floor(min(U));
    maxU = ceil(max(U));
    minV = floor(min(V));
    maxV = ceil(max(V));
    
    [Ug Vg] = meshgrid(minU:N:maxU, minV:N:maxV);
    
    [m n o] = size(Ug);
    
    Ui = zeros(m, n, o);
    Vi = zeros(m, n, o);
    for j = 1:N:n
        uv = H \ [Ug(:, j)';
            Vg(:, j)';
            ones(1, m)];
        
        Ui(:, j) = uv(1, :) ./ uv(3, :);
        Vi(:, j) = uv(2, :) ./ uv(3, :);
    end
    
    img = zeros(m, n, 3);
    
    for i = 1:3
        tmp = double(img2(:, :, i));
        img(:, :, i) = interp2(tmp, Ui, Vi, 'nearest');
    end
    
    img = uint8(img);
    uv = H * [1 w2 w2 1;
        1 1 h2 h2;
        1 1 1 1];
    
    U = uv(1, :) ./ uv(3, :);
    V = uv(2, :) ./ uv(3, :);
    
    minU = min(1, floor(min(U)));
    maxU = max(w1, ceil(max(U)));
    minV = min(1, floor(min(V)));
    maxV = max(h1, ceil(max(V)));
    
    [Un Vn] = meshgrid(minU:N:maxU, minV:N:maxV);
    
    [m n o] = size(Un);
    
    mergedimg = uint8(zeros(m, n, 3));
    
    [minimum in] = min(abs(Vn(:, 1) - Vg(1, 1)));
    [minimum jn] = min(abs(Un(1, :) - Ug(1, 1)));
    
    [m n o] = size(img);
    
    minU = jn;
    maxU = jn + n - 1;
    minV = in;
    maxV = in + m - 1;
    
    mergedimg(minV:maxV, minU:maxU, :) = img(:, :, :);
    
    [minimum in] = min(abs(Vn(:, 1) - 1));
    [minimum jn] = min(abs(Un(1, :) - 1));
    
    mask = ~logical(img1(1:N:end, 1:N:end, :));
    
    minU = jn;
    maxU = jn + w1 / N - 1;
    minV = in;
    maxV = in + h1 / N - 1;
    
    mergedimg(minV:maxV, minU:maxU, :) = img1(1:N:end, 1:N:end, :) + ...
        uint8(mask) .* mergedimg(minV:maxV, minU:maxU, :);
    
catch e
    disp(e.message)
end