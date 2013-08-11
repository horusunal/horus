function [R t]=Rt_estimate_linear(H,K)
%
% [R t]=Rt_estimate_linear(H,K)
% This function estimates the rotation matrix and the translation vector
% t=-RC using the Pinhole model matrix or the DLT given by H and an
% estimate of the matrix of intrinsec parameters K. The procedure is the
% one presented in Pérez (2009), using SVD to obtain an orthonormal matrix
% R with determinant 1.
% Inputs:
%  H: Model matrix or DLT of the camera.
%  K: Intrinsec parameters matrix
% Outputs:
%  R: Rotation matrix
%  t: Translation matrix
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
