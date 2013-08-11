function [B  F hist]=LM_Pinhole(ui,vi,xi,yi,zi,B0,A,v,tao,eps,kmax)
%
% [B F hist]=LM_Pinhole(ui,vi,xi,yi,zi,B0,A,v,tao,eps,kmax)
% Levenberg-Marquardt algorithm implemented to work with the residual
% vectorial function of the Pinhole model without distortion as given in
% Pérez (2009) and Pérez et al (2011). Is uses the update mechanisms of the
% parameter lambda presented in Pérez (2009). In the case of distortion
% present or when just a few parameters need to be updated, is better to
% use the function LM_camera.
% Inputs:
%   ui: coordinates u of the GCPs on the image (nx1 matrix).
%   vi: coordinates v of the GCPs on the image (nx1 matrix).
%   xi: coordinates x of the GCPs in the space (nx1 matrix).
%   yi: coordinates y of the GCPs in the space (nx1 matrix).
%   zi: coordinates z of the GCPs in the space (nx1 matrix).
%   B0: 1x10 vector with the initial estimates of the parameters
%   est=[fDu fDv u0 v0 a b c tx ty tz], [a b c] is obtained by aplying the
%   Rodrigues formula to the rotation matrix R and the vector
%   [tx ty tz]'=-R*C.
%   A: Initial value of the parameter lambda as presented in Pérez (2009)
%   and Pérez et al (2011), it controls the Levenberg-Marquardt method as
%   if A=0 the method is equal to the Gauss-Newton method and if A->inf
%   then the method tends to the Gradient method.
%   v: Parameter to control the update rate of the parameter lambda as
%   presented in Pérez (2009).
%   tao: Control parameter to avoid zero divisions when the update ratio of
%   the estimates is calculated. See Pérez (2009) chapter 3.3.
%   eps: Control parameter to stop the algorithm when the Value of F'F or
%   the estimate update is smaller than eps. See Pérez (2009) chapter 3.3.
%   kmax: Maximum iteration number allowed.
% Outputs:
%   B: nxk matrix where n is the number of estimated parameters and k is
%   the number of iterations performed. The first column of B corresponds
%   to the initial estimates.
%   F: Sum of the squares of the residuals F(B(:,k))=R'R. F/sqrt(2*N) where
%   N is the number of GCPs used gives the RMS error of the projection of
%   the GCP in the image.
%   hist: kx(3+n) matrix. The firs column is the history of the lambda
%   update, the second column is the history of F, the third column the
%   history of the norm of the Jacobian of R (The residuals vector), the
%   forth column is the history of the norm of the gradient of F=R'R and
%   the next columns are the history of each estimated parameter.
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
