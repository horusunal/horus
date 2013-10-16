function [H K D R t P ECN MSExy MSEuv un vn pos rectimg] =...
    create_calibration_parameters(img, roi, resolution, method, data, est, var)

%CREATE_CALIBRATION_PARAMETERS   Generate the model parameters for the
%rectification calibration, according to the specific method.
%
% Input:
%   img:    Image to be rectified
%   roi:    ROI for the image rectification
%   resolution: Resolution of the rectification
%   method: method of choice (e.g. 'Pinhole', 'DLT', 'RANSAC-DLT')
%   data:   GCPs information {name, id, U, V, X, Y, Z}
%   est:    Initial estimates in case the method is Pinhole (12 positions)
%   var:    Boolean vector for selected initial estimated (12 positions)
%
% Output:
%   H:      Transformation matrix
%   K:      Distorsion matrix
%   D:
%   R:      Rotation matrix
%   t:
%   P:      Model parameters
%   ECN:    Normalized Calibration Error
%   MSExy:  Mean Squared Error for space
%   MSEuv:  Mean Squared Error for pixels
%   un:     Horizontal image coords of the ROI
%   vn:     Vertical image coords of the ROI
%   pos:
%   rectimg: Rectified image

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/10/28 17:24 $

try
    
    % Set HORUS paths
    if ~isdeployed
        root = fileparts(mfilename('fullpath'));
        root = fileparts(root);
        addpath(genpath(root));
    end
    
    numgcps = size(data, 1);
    
    % Load GCPs information
    gcp_names = data(:, 1);
    gcp_ids = data(:, 2);
    U = cell2mat(data(:, 3));
    V = cell2mat(data(:, 4));
    X = cell2mat(data(:, 5));
    Y = cell2mat(data(:, 6));
    Z = cell2mat(data(:, 7));
    
    % Empty initial parameters
    H = DLT(U, V, X, Y, Z);
    K = [];
    D = [];
    R = [];
    t = [];
    P = [];
    ECN = [];
    MSExy = [];
    MSEuv = [];
    un = [];
    vn = [];
    
    % Optimize by the chosen method
    if strcmpi(method, 'dlt')
        % Solve model with DLT method
        H = DLT(U, V, X, Y, Z);
        xn = zeros(numgcps, 1);
        yn = zeros(numgcps, 1);
        
        for i = 1:numgcps
            XY = ([H(:, [1 2]) -[U(i); V(i); 1]]) \ (-H(:, [3 4]) * [Z(i); 1]);
            xn(i) = XY(1);
            yn(i) = XY(2);
        end
        
        pos = 1:numgcps;
        
        if ~isempty(H)
            MSExy = sqrt(sum((xn - X) .^ 2 + (yn - Y) .^ 2) / numgcps);
            [un, vn] = XYZ2UV(H, [X Y Z]);
            MSEuv = sqrt(sum((un - U) .^ 2 + (vn - V) .^ 2) / (2 * length(un)));
            
            disp('The camera transformation matrix is:')
            disp(H)
            disp(['The image projection error is ' num2str(MSEuv, '%e') ' pixels'])
            disp(['The space back projection error is ' num2str(MSExy, '%e') ' meters'])
        end
        
    elseif strcmpi(method, 'ransac-dlt')
        % Solve model with RANSAC-DLT method
        [H UVend XYZend pos] = RANSAC_DLT(U, V, X, Y, Z);
        xn = zeros(length(pos), 1);
        yn = zeros(length(pos), 1);
        
        k = 1;
        for i = pos
            XY = ([H(:, [1 2]) -[U(i); V(i); 1]]) \ (-H(:, [3 4]) * [Z(i); 1]);
            xn(k) = XY(1);
            yn(k) = XY(2);
            k = k + 1;
        end
        
        if ~isempty(H)
            MSExy = sqrt(sum((xn - X(pos)) .^ 2 + (yn - Y(pos)) .^ 2) / length(pos));
            [un, vn] = XYZ2UV(H, [X(pos) Y(pos) Z(pos)]);
            MSEuv = sqrt(sum((un - U(pos)) .^ 2 + (vn - V(pos)) .^ 2) / (2 * length(un)));
            
            disp('The camera transformation matrix is:')
            disp(H)
            disp(['The image projection error is ' num2str(MSEuv, '%e') ' pixels'])
            disp(['The space back projection error is ' num2str(MSExy, '%e') ' meters'])
        end
        
    elseif strcmpi(method, 'pinhole')
        
        % Solve model with Pinhole method
        [H K D R t P MSEuv MSExy ECN] = camera_cal(U, V, X, Y, Z, est, var);
        pos = 1:numgcps;
        
        if ~isempty(H)
            [un, vn] = XYZ2UV(H, [X(pos) Y(pos) Z(pos)]);
            
            if ~isempty(K) && ~isempty(D)
                [un, vn] = distort(K, D, [un vn]);
            end
            
            k1 = 0;
            k2 = 0;
            
            if length(D) == 2
                k1 = D(1);
                k2 = D(2);
            end
            
            disp('The camera transformation matrix is:')
            disp(H)
            disp(['The distortion parameters are: k1 = ' num2str(k1, '%e')...
                ', k2 = ' num2str(k2, '%e')])
            disp(['The image projection error is ' num2str(MSEuv, '%e') ' pixels'])
            disp(['The space back projection error is ' num2str(MSExy, '%e') ' meters'])
            disp(['The normalized calibration error is ' num2str(ECN, '%e')])
        end
    end
    
    uroi = roi(:, 1); % U coordinates
    vroi = roi(:, 2); % V coordinates
    zroi = 0;         % level value, fixed
    [u v rectimg] = rectify(img, H, K, D, [uroi vroi], zroi, resolution, true);
    
catch e
    disp(e.message)
end