function JF=JF_Pinhole_ND(u,v,xi,yi,zi,B)
%
% JF=JF_Pinhole_ND(u,v,xi,yi,zi,est,var)
% This function calculates Jacobian matrix of the residual vector F of the
% projection using the Pinhole model without distortion from Pérez (2009)
% and Pérez et al (2011). 
% Inputs:
%   u: coordinates u of the GCPs on the image (nx1 matrix).
%   v: coordinates v of the GCPs on the image (nx1 matrix).
%   xi: coordinates x of the GCPs in the space (nx1 matrix).
%   yi: coordinates y of the GCPs in the space (nx1 matrix).
%   zi: coordinates z of the GCPs in the space (nx1 matrix).
%   est: 1x10 vector with the values of the Pinhole model parameters 
%    B=[fDu fDv u0 v0 a b c tx ty tz]. [a b c] is the vector obtained
%    after aplying the Rodrigues formula to the rotation matrix.
%   var: 1x10 vector of 1s and 0s that is used to indicate with 0 which
%   parameters are assumed constant and with 1 which parameters are going
%   to be updated.
% Outputs:
%   JF: Jacobian of the residual vector of the Pinhole model.
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
