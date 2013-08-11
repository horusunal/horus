function [u,v] = XYZ2UV(H,X)
%
% [u,v] = XYZ2UV(H,X)
% This function uses the distortion-free Pinhole model to project the
% points in the space in the image. It uses the Pinhole model matrix or the
% DLT. See Pérez (2009) or Pérez et al (2011) to see the relationship
% between the spatial coordiantes and the image coordinates.
% Inputs:
%   H: Pinhole model matrix or DLT.
%   X: nx3 matrix where each row corresponds to the coordinates [x y z] of
%   one point in the space to be projected in the image.
% Outputs:
%   u: 1xn matrix with the u coordinates of the points in the image.
%   v: 1xn matrix with the v coordinates of the points in the image.
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
