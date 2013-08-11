function plot_resolution(H,K,D,u,v,I_rect,zvalue)
%
% plot_resolution(H,K,D,u,v,I_rect,zvalue)
% This function creates a resolution map on the portion of the rectified
% image obtained using the function rectify.
% Inputs:
%  H: Pinhole model matrix or DLT.
%  K: 3x3 upper triangular matrix with the intrinsec parameters of the
%  camera model used to correct the lens distortion effect, if no
%  distortion is going to be corrected, the K may be an empty array.
%  D: 1x2 matrix with the radial distortion parameters of the camera model,
%  [k1 k2]. This parameters are used to correct the distortion effects in
%  the image and, therefore, if there is no distortion to correct then D
%  might be an empty array.
%  u: u coordinates of the rectified region on teh original image, these
%  are returned by the function rectify.
%  v: v coordinates of the rectified region on teh original image, these
%  are returned by the function rectify.
%  I_rect: Rectified image obtained with the function rectify.
%  zvalue: Z value used to create the rectified image.
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
