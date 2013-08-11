function [x y z] = UV2XYZ(H,u,v,z)
%
% [x y z] = UV2XYZ(H,u,v,z)
% This function calculates the spatial coordinates of several points in the
% image using the given values of Z and using the distortion-free Pinhole
% model matrix or the DLT. See P�rez (2009) or P�rez et al (2011) to see
% the realtionship between the spatial coordiantes and the image
% coordinates.
% Inputs:
%   H: Pinhole model matrix or DLT.
%   u: 1xn matrix with the u coordinates of the points on the image.
%   v: 1xn matrix with the v coordinates of the points on the image.
%   z: 1xn matrix with the z coordinates of teh point of the space. It may
%   be a scalar value as well, in such case all the points have the same
%   Z value.
% Outputs:
%   x: 1xn matrix with the x coordinates of the points in the space.
%   y: 1xn matrix with the y coordinates of the points in the space.
%   z: 1xn matrix with the z coordinates of the points in the space.
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

n = numel(u);

x = zeros(n, 1);
y = zeros(n, 1);

if numel(z) == 1;
    z = z * ones(n, 1);
end

for i = 1:n
    B = -H(:, 3:4) * [z(i); 1];
    XY = ([H(:, 1:2) -[u(i); v(i); 1]]) \ B;
    x(i) = XY(1);
    y(i) = XY(2);
end

