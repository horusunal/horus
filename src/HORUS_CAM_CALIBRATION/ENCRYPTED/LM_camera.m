function [B R F hist]=LM_camera(ui,vi,xi,yi,zi,est,var,A,v,tao,eps,kmax)
% 
% [B R F hist]=LM_camera(ui,vi,xi,yi,zi,est,var,A,v,tao,eps,kmax)
% Levenberg-Marquardt algorithm implemented to work with the residual
% vectorial function of the Pinhole model with distortion as given in Pérez
% (2009) and Pérez et al (2011). Is uses the update mechanisms of the
% parameter lambda presented in Pérez (2009).
% Inputs:
%   ui: coordinates u of the GCPs on the image (nx1 matrix).
%   vi: coordinates v of the GCPs on the image (nx1 matrix).
%   xi: coordinates x of the GCPs in the space (nx1 matrix).
%   yi: coordinates y of the GCPs in the space (nx1 matrix).
%   zi: coordinates z of the GCPs in the space (nx1 matrix).
%   est: 1x12 vector with the initial estimates of the parameters 
%   est=[fDu fDv u0 v0 k1 k2 a b c tx ty tz], [a b c] is obtained by
%   aplying the Rodrigues formula to the rotation matrix R and the vector
%   [tx ty tz]'=-R*C.
%   var:  1x12 vector of 1s and 0s that is used to indicate with 0 which
%   parameters are assumed constant and with 1 which parameters are going
%   to be updated.
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
%   R: Final residual vector, obtained with the last estimated parameter
%   values.
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
