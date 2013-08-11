function [y]=rodrigues(x)
%
% y=rodrigues(x) 
% This function uses the Rodrigues formula (Pérez (2009), chapter 2.1.5) to
% find the rotation matriz asociated to the vector x or the vector y
% asociated with the rotation matrix x. The vector asociated with the
% rotation matrix is parallel to the rotation axis and its norm is equal to
% the rotation angle in mod(2pi).
% Inputs:
%   x: 3x3 Matrix or 3x1 vector
% Outputs:
%   y: Vector parallel to the rotation axis (3x1) or rotation matrix (3x3)
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
