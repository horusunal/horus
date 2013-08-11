function [u,v] = XYZ2UV(H,X)
%
% [u,v] = XYZ2UV(H,X)
% This function uses the distortion-free Pinhole model to project the
% points in the space in the image. It uses the Pinhole model matrix or the
% DLT. See P�rez (2009) or P�rez et al (2011) to see the relationship
% between the spatial coordiantes and the image coordinates.
% Inputs:
%   H: Pinhole model matrix or DLT.
%   X: nx3 matrix where each row corresponds to the coordinates [x y z] of
%   one point in the space to be projected in the image.
% Outputs:
%   u: 1xn matrix with the u coordinates of the points in the image.
%   v: 1xn matrix with the v coordinates of the points in the image.
%
%   Developed by Juan camilo P�rez Mu�oz (2011) for the HORUS project.
%
% References:
%   P�REZ, J.  M.Sc. Thesis, Optimizaci�n No Lineal y Calibraci�n de
%   C�maras Fotogr�ficas. Facultad de Ciencias, Universidad Nacional de
%   Colombia, Sede Medell�n. (2009). Available online in
%   http://www.bdigital.unal.edu.co/3516/
%   P�REZ, J., ORTIZ, C., OSORIO, A., MEJ�A, C., MEDINA, R. "CAMERA
%   CALIBRATION USING THE LEVENBERG-MARQUADT METHOD AND ITS ENVIROMENTAL
%   MONITORING APLICATIONS". (2011) To be published.
%

n = size(X, 1);

x = X(:, 1);
y = X(:, 2);
z = X(:, 3);

% u and v calculation
UV = H * [x'; y'; z'; ones(1, n)];
u = (UV(1, :) ./ UV(3, :))';
v = (UV(2, :) ./ UV(3, :))';
