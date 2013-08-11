function [y]=rodrigues(x)
%
% y=rodrigues(x) 
% This function uses the Rodrigues formula (Pérez (2009), chapter 2.1.5) to
% find the rotation matriz asociated to the vector x or the vector y
% asociated with the rotation matrix x. The vector asociated with the
% rotation matrix is parallel to the rotation axis and its norm is equal to
% the rotation angle in mod(2pi).
% Inputs:
%   x: 3x3 Matrix or 3x1 vector
% Outputs:
%   y: Vector parallel to the rotation axis (3x1) or rotation matrix (3x3)
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

if size(x,2)==1
    % We have the vector, and norm(x)=theta (mod 2pi)
    theta=mod(norm(x),2*pi);
    P=theta/norm(x)*[0 -x(3) x(2);x(3) 0 -x(1);-x(2) x(1) 0];
    y=eye(3)+sin(theta)/theta*P+(1-cos(theta))/(theta^2)*P^2;
else
    % We have the rotation matrix. Its determinant has to be close to 1 or
    % -1, the rotation angle is obtained using the Fillmore formula.
    if round(det(x))==-1
        x1=-x;
    else
        x1=x;
    end
    theta=acos((trace(x1)-1)/2);
    A=(x1+x1')-(trace(x1)-1)*eye(3);
    r=A(1,:);
    y=theta*r'/norm(r);
    theta1=mod(norm(y),2*pi);
    P=theta1/norm(y)*[0 -y(3) y(2);y(3) 0 -y(1);-y(2) y(1) 0];
    x2=eye(3)+sin(theta)/theta*P+(1-cos(theta))/(theta^2)*P^2;
    if norm(x2-x)<1e-10
        theta=theta;
    else
        theta=-theta;
    end
    y=theta*r'/norm(r);
end