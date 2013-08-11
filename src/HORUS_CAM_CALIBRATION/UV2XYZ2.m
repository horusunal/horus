function [x y z] = UV2XYZ2(H,u,v,KnownP,coord)
%
% [x y z] = UV2XYZ2(H,u,v,KnownP,coord)
% This function calculates the spatial coordinates of several points in the
% image using the given value KnownP of the coordinate expressed using
% coord  and using the distortion-free Pinhole model matrix or the DLT. See
% P�rez (2009) or P�rez et al (2011) to see the relationship between the
% spatial coordiantes and the image coordinates.
% Inputs:
%   H: Pinhole model matrix or DLT.
%   u: 1xn matrix with the u coordinates of the points on the image.
%   v: 1xn matrix with the v coordinates of the points on the image.
%   KnownP: scalar value of the known coordinate.
%   coord: identifier for the known coordinate "1" for x, "2" for y and "3"
%   for z.
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
z = zeros(n, 1);

for i = 1:n
    B = -H(:, [coord 4]) * [KnownP 1]';
    XY = [H(:, [1:coord - 1, (coord + 1):3]) [-u(i); -v(i); -1]] \ B;
    if coord == 1
        x(i) = KnownP;
        y(i) = XY(1);
        z(i) = XY(2);
    elseif coord == 2
        x(i) = XY(1);
        y(i) = KnownP;
        z(i) = XY(2);
    else
        x(i) = XY(1);
        y(i) = XY(2);
        z(i) = KnownP;
    end
end