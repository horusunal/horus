function F=F_Pinhole_ND(u,v,xi,yi,zi,B)
%
% F=F_Pinhole_ND(u,v,xi,yi,zi,B)
% This function calculates the residual vector F of the projection using
% the Pinhole model without distortion from Pérez (2009) and Pérez et al
% (2011). The spatial GCPs coordinates are used to project the GCP on the
% image using the parameters given in B and then the image coordiantes
% obtained are compared with the ones given.
% Inputs:
%   u: coordinates u of the GCPs on the image (nx1 matrix).
%   v: coordinates v of the GCPs on the image (nx1 matrix).
%   xi: coordinates x of the GCPs in the space (nx1 matrix).
%   yi: coordinates y of the GCPs in the space (nx1 matrix).
%   zi: coordinates z of the GCPs in the space (nx1 matrix).
%   B: 1x10 vector with the values of the Pinhole model parameters 
%    B=[fDu fDv u0 v0 a b c tx ty tz]. [a b c] is the vector obtained
%    after aplying the Rodrigues formula to the rotation matrix.
% Outputs:
%   F: vector of order 2nx1 with the residuals of the projection using the
%   parameters given in B.
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

fDu=B(1);
fDv=B(2);
u0=B(3);
v0=B(4);
a=B(5);
b=B(6);
c=B(7);
tx=B(8);
ty=B(9);
tz=B(10);


F=zeros(2*size(u,1),1);
k=0;
for j=1:size(u,1)
    x=xi(j);
    y=yi(j);
    z=zi(j);
    uk=u(j);
    vk=v(j);
    
    k=k+1;
    F(k)=(((-x*u0+z*fDu)*b+y*(-c*fDu+u0*a))*(abs(a)^2+abs(b)^2+abs(c)^2)*sin(sqrt((abs(a)^2+abs(b)^2+abs(c)^2)))+(((z*u0+x*fDu)*b^2-y*(a*fDu+c*u0)*b+(-c*fDu+u0*a)*(z*a-x*c))*cos(sqrt((abs(a)^2+abs(b)^2+abs(c)^2)))+(((x+tx)*fDu+u0*(tz+z))*abs(a)^2)+(((x+tx)*fDu+u0*(tz+z))*abs(b)^2)+(((x+tx)*fDu+u0*(tz+z))*abs(c)^2)+((-z*u0-x*fDu)*b^2)+(y*(a*fDu+c*u0)*b)-((-c*fDu+u0*a)*(z*a-x*c)))*sqrt((abs(a)^2+abs(b)^2+abs(c)^2)))/((abs(a)^2+abs(b)^2+abs(c)^2)*(-b*x+y*a)*sin(sqrt((abs(a)^2+abs(b)^2+abs(c)^2)))+((z*b^2-x*c*a-y*c*b+z*a^2)*cos(sqrt((abs(a)^2+abs(b)^2+abs(c)^2)))+((tz+z)*abs(a)^2)+((tz+z)*abs(b)^2)+((tz+z)*abs(c)^2)-(z*b^2)-(z*a^2)+(x*c*a)+(y*c*b))*sqrt((abs(a)^2+abs(b)^2+abs(c)^2)))-uk;
    k=k+1;
    F(k)=(((y*v0+z*fDv)*a-x*(fDv*c+v0*b))*(abs(a)^2+abs(b)^2+abs(c)^2)*sin(sqrt((abs(a)^2+abs(b)^2+abs(c)^2)))-(((y*fDv-z*v0)*a^2-x*(-c*v0+b*fDv)*a-(fDv*c+v0*b)*(z*b-y*c))*cos(sqrt((abs(a)^2+abs(b)^2+abs(c)^2)))+(((ty+y)*fDv-v0*(tz+z))*abs(a)^2)+(((ty+y)*fDv-v0*(tz+z))*abs(b)^2)+(((ty+y)*fDv-v0*(tz+z))*abs(c)^2)+((-y*fDv+z*v0)*a^2)+(x*(-c*v0+b*fDv)*a)+((fDv*c+v0*b)*(z*b-y*c)))*sqrt((abs(a)^2+abs(b)^2+abs(c)^2)))/((abs(a)^2+abs(b)^2+abs(c)^2)*(-b*x+y*a)*sin(sqrt((abs(a)^2+abs(b)^2+abs(c)^2)))+((z*b^2-x*c*a-y*c*b+z*a^2)*cos(sqrt((abs(a)^2+abs(b)^2+abs(c)^2)))+((tz+z)*abs(a)^2)+((tz+z)*abs(b)^2)+((tz+z)*abs(c)^2)-(z*b^2)-(z*a^2)+(x*c*a)+(y*c*b))*sqrt((abs(a)^2+abs(b)^2+abs(c)^2)))-vk;
end
