function [u v]=undistort(K,D,uv)
%
% [u v]=undistort(K,D,uv)
% This function corrects the radial distortion of ONE point in the image
% using the Pinhole model. The method is the one presented in Pérez (2009).
% Inputs:
%  K: Intrinsec parameters matrix
%  D: Radial distortion parameters: [k1 k2]
%  uv: 1x2 matrix with the distorted coordinates of the point [u v].
% Outputs:
%  u: distortion free u coordinate
%  v: distortion free v coordinate
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
