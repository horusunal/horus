function [x y z] = UV2XYZ2(H,u,v,KnownP,coord)
%
% [x y z] = UV2XYZ2(H,u,v,KnownP,coord)
% This function calculates the spatial coordinates of several points in the
% image using the given value KnownP of the coordinate expressed using
% coord  and using the distortion-free Pinhole model matrix or the DLT. See
% Pérez (2009) or Pérez et al (2011) to see the relationship between the
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
%   Developed by Juan camilo Pérez Muñoz (2011) for the HORUS project.
%
% References:
%   PÉREZ, J.  M.Sc. Thesis, Optimización No Lineal y Calibración de
%   Cámaras Fotográficas. Facultad de Ciencias, Universidad Nacional de
%   Colombia, Sede Medellín. (2009). Available online in
%   http://www.bdigital.unal.edu.co/3516/
%   PÉREZ, J., ORTIZ, C., OSORIO, A., MEJÍA, C., MEDINA, R. "CAMERA
%   CALIBRATION USING THE LEVENBERG-MARQUADT METHOD AND ITS ENVIROMENTAL
%   MONITORING APLICATIONS". (2011) To be published.
%
