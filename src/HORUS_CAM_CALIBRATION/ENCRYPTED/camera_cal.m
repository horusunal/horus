function [H K D R t P MSEuv MSExy NCError]=camera_cal(ui,vi,xi,yi,zi,est,var)
%
%   [H K D R t P MSEuv MSExy NCError]=camera_cal(ui,vi,xi,yi,zi,est,var)
%
%   This function finds estimates for all the Pinhole model parameters
%   using the Levenberg-Marquardt method proposed in Pérez (2009) and Pérez
%   et al (2011) with at least 6 GCP. In the case that initial estimates of
%   the parameters exit, it is possible to just updated some of the
%   parameter using less GCPs.
%
%   Inputs:
%       ui: coordinates u of the GCPs on the image (nx1 matrix).
%       vi: coordinates v of the GCPs on the image (nx1 matrix).
%       xi: coordinates x of the GCPs in the space (nx1 matrix).
%       yi: coordinates y of the GCPs in the space (nx1 matrix).
%       zi: coordinates z of the GCPs in the space (nx1 matrix).
%       est=[fDu fDv u0 v0 k1 k2 a b c tx ty tz], [a b c] is obtained by
%       aplying the Rodrigues formula to the rotation matrix R and the
%       vector [tx ty tz]'=-R*C. It may be a empty array, in the case that
%       6 or more GCP are used.
%       var:  1x12 vector of 1s and 0s that is used to indicate with 0
%       which parameters are assumed constant and with 1 which parameters
%       are going to be updated.
%   Outputs:
%       H: Distortion free Pinhole model matrix obtained after the
%       Levenberg-Marquardt optimization, H=K*[R t].
%       K: Intrinsec parameters matrix, necesary to work around the
%       distortion.
%       D: Radial distortion parameters [k1 k2]
%       R: Rotation matrix of the model.
%       t: translation vector of the model, corresponds to the optical
%       center in the rotated frame t=-RC;
%       P: Structure with all the Pinhole model parameters, it gives the
%       rotation angles tao, sigma and phi and the optical center
%       coordiantes xc, yc, zc.
%       MSEuv: Mean square error of the projection of the points in the
%       space to the image [pixels]
%       MSExy: Mean square error of the back-projection of the points in
%       the image to the space [meters or the lenght unit used]
%       NCEerror: Normalized Calibration error as presented in Pérez (2009).
%
% It is possible to estimate as well just the extrinsec parameter, the
% intrinsec parameter, the distortion parameters or all the parameters of
% the Pinhole model withou distortion. In such cases it is possible also to
% use less than 6 GCPs but then initial estimates need to be defined.
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
