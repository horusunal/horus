function [u v]=distort(K,D,uv)
%
% [u v]=distort(K,D,uv)
% This funtion distorts the coordinates of a group of points on the image,
% using the radial distortion parameters and the intrinsec parameters of
% the camera as presented in Pérez (2009).
% Inputs:
%   K: Intrinsec parameter matrix as presented in Pérez et al (2011).
%   D: Radial distortion parameters D=[k1 k2] as presented in Pérez et al
%   (2011).
%   uv: nx2 matrix with the distortion-free coordinates of the points in
%   the image [u(1) v(1);u(2) v(2);...;u(n) v(n)]
% Outputs:
%   u: distorted u coordinates of the points.
%   v: distorted v coordiantes of the points.
%
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

Y=eye(3);
KK=inv(K);

xn(:,1)=KK(1,1).*uv(:,1)+KK(1,3);
xn(:,2)=KK(2,2).*uv(:,2)+KK(2,3);
r=sqrt(xn(:,1).^2+xn(:,2).^2);

Pr=[D(2) 0 D(1) 0 1];

xd(:,1)=xn(:,1).*(polyval(Pr,r));
xd(:,2)=xn(:,2).*(polyval(Pr,r));

uv1(:,1)=K(1,1).*xd(:,1)+K(1,3);
uv1(:,2)=K(2,2).*xd(:,2)+K(2,3);

u=uv1(:,1);
v=uv1(:,2);