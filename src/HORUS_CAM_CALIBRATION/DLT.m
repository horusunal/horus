function [H]=DLT(u,v,x,y,z)
%
% [H]=DLT(u,v,x,y,z)
% This function calculates de DLT as presented in Pérez (2009) and Pérez et
% al (2011). It needs at least 6 GCPs to calculate the homogeneous solution
% of the DLT using an approach based on Singular Value Decomposition as
% presented in Pérez (2009). The DLT, H satisfies the condition
% h31^2+h32^2+h33^2=1.
% Inputs:
%   u: coordinates u of the GCPs on the image (nx1 matrix).
%   v: coordinates v of the GCPs on the image (nx1 matrix).
%   x: coordinates x of the GCPs in the space (nx1 matrix).
%   y: coordinates y of the GCPs in the space (nx1 matrix).
%   z: coordinates z of the GCPs in the space (nx1 matrix).
% Outputs:
%   H: DLT of the camera, satisfying the condition h31^2+h32^2+h33^2=1.
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

A=[];
n=length(u);
for i=1:n
    A=[A; 0 0 0 0 -x(i) -y(i) -z(i) -1 v(i)*[x(i) y(i) z(i) 1];...
        x(i) y(i) z(i) 1 0 0 0 0 -u(i)*[x(i) y(i) z(i) 1]];
end

[U,S,V] = svd(A);
h=V(:,12);
H1=[h(1:4)';h(5:8)';h(9:12)'];
alpha=H1(3,1)^2+H1(3,2)^2+H1(3,3)^2;
beta=sqrt(1/alpha);
H=beta*H1;

