function [K,R,t,P]=extractDLT(H,u,v,x,y,z)
%
% [K,R,t,P]=extractDLT(H)
% This function estimates the distortion-free Pinhole parameters using the
% DLT of the camera H. The algorthim to estimates the parameters is the one
% presented in P�rez (2009).
% Inputs:
%   H: DLT obtained with the GPPs given by u,v,x,y,z (3x4 matrix).
%   u: coordinates u of the GCPs on the image (nx1 matrix).
%   v: coordinates v of the GCPs on the image (nx1 matrix).
%   x: coordinates x of the GCPs in the space (nx1 matrix).
%   y: coordinates y of the GCPs in the space (nx1 matrix).
%   z: coordinates z of the GCPs in the space (nx1 matrix).
% Outputs:
%   K: Intrinsic parameter matrix (3x3 matrix).
%   R: Rotation matrix of the camera model.
%   t: Translation vector of the optical center t=-RC, where C is the
%   position vector of the optical center in the reference frame. Using K,
%   R and t is posible to approximate H as H=K[R t].
%   P: Structure with all the parameters obtained as presented in P�rez
%   (2009) fDu, fDv, u0, v0, tao, sigma, phi, tx, ty, tz.
%
%   Developed by Juan camilo P�rez Mu�oz (2011) for the HORUS project.
%
% References:
%   P�REZ, J.  M.Sc. Thesis, Optimizaci�n No Lineal y Calibraci�n de
%   C�maras Fotogr�ficas. Facultad de Ciencias, Universidad Nacional de
%   Colombia, Sede Medell�n. (2009). Available online in
%   http://www.bdigital.unal.edu.co/3516/
%   P�REZ, J., ORTIZ, C., OSORIO, A., MEJ�A, C., MEDINA, R. "CAMERA
%   CALIBRATION USING THE LEVENBERG-MARQUADT METHOD AND ITS ENVIROMENTAL
%   MONITORING APLICATIONS". (2011) To be published.

E = -1;
r3 = E * H(3, 1:3);
u0 = H(1, 1:3) * H(3, 1:3)';
v0 = H(2, 1:3) * H(3, 1:3)';
tz = E * H(3, 4);
theta = acosd(-cross(H(1, 1:3)', H(3, 1:3)')' * ...
               cross(H(2, 1:3)', H(3, 1:3)') / ...
               (norm(cross(H(1, 1:3)', H(3, 1:3)')) * ...
                     norm(cross(H(2, 1:3)', H(3, 1:3)'))));
Eu = 1;
fDu = Eu * sqrt(H(1, 1:3) * H(1, 1:3)' -u0 ^ 2) * sind(theta);
Ev = 1;
fDv = Ev * sqrt(H(2, 1:3) * H(2, 1:3)' -v0 ^ 2) * sind(theta);
r1 = (E * (H(1, 1:3) + (H(2, 1:3) -v0 * H(3, 1:3)) * ...
          fDu * cos(theta) / fDv -u0 * H(3, 1:3))) / fDu;
r2 = -(E * (H(2, 1:3) -v0 * H(3, 1:3))) * sind(theta) / fDv;
tx = (E * (H(1, 4) + (H(2, 4) -v0 * H(3, 4)) * ...
          fDu * cos(theta) / fDv -u0 * H(3, 4))) / fDu;
ty = -(E * (H(2, 4) - v0 * H(3, 4))) * sind(theta) / fDv;

R1=[r1; r2; r3];
H1=[fDu 0 u0; 0 -fDv v0; 0 0 1] * [R1 [tx; ty; tz]];

UV = H * [x(1) y(1) z(1) 1]';
UV1 = H1 * [x(1) y(1) z(1) 1]';

U1 = UV1(1) / UV1(3);
V1 = UV1(2) / UV1(3);

U = UV(1) / UV(3);
V = UV(2) / UV(3);

if U1 * U < 0
    E = -E;
end

r3 = E * H(3, 1:3);
u0 = H(1, 1:3) * H(3, 1:3)';
v0 = H(2, 1:3) * H(3, 1:3)';
tz = E * H(3, 4);
theta = acosd(-cross(H(1, 1:3)', H(3, 1:3)')' * ...
               cross(H(2, 1:3)', H(3, 1:3)') / ...
               (norm(cross(H(1, 1:3)', H(3, 1:3)')) * ...
                     norm(cross(H(2, 1:3)', H(3, 1:3)'))));
Eu = 1;
fDu = Eu * sqrt(H(1, 1:3) * H(1, 1:3)' -u0 ^ 2) * sind(theta);
Ev = 1;
fDv = Ev * sqrt(H(2, 1:3) * H(2, 1:3)' -v0 ^ 2) * sind(theta);
r1 = (E * (H(1, 1:3) + (H(2, 1:3) -v0 * H(3, 1:3)) * ...
          fDu * cos(theta) / fDv -u0 * H(3, 1:3))) / fDu;
r2 = -(E * (H(2, 1:3) -v0 * H(3, 1:3))) * sind(theta) / fDv;
tx = (E * (H(1, 4) + (H(2, 4) -v0 * H(3, 4)) * ...
          fDu * cos(theta) / fDv -u0 * H(3, 4))) / fDu;
ty = -(E * (H(2, 4) -v0 * H(3, 4))) * sind(theta) / fDv;

R1=[r1; r2; r3];

[U, S, V] = svd(R1);
R = U * V';
if round(det(R)) == -1
    Eu = -1;
end

fDu = Eu * sqrt(H(1, 1:3) * H(1, 1:3)' -u0 ^ 2) * sind(theta);
Ev = 1;
fDv = Ev * sqrt(H(2, 1:3) * H(2, 1:3)' -v0 ^ 2) * sind(theta);
r1 = (E * (H(1, 1:3) + (H(2, 1:3) -v0 * H(3, 1:3)) * ...
          fDu * cos(theta) / fDv -u0 * H(3, 1:3))) / fDu;
r2 = -(E * (H(2, 1:3) -v0 * H(3, 1:3))) * sind(theta) / fDv;
tx = (E * (H(1, 4) + (H(2, 4) -v0 *H(3, 4)) * ...
          fDu * cos(theta) / fDv -u0 * H(3, 4))) / fDu;
ty = -(E * (H(2, 4) -v0 * H(3, 4))) * sind(theta) / fDv;

R1=[r1; r2; r3];
[U, S, V] = svd(R1);
R = U * V';
K = [fDu 0 u0; 0 -fDv v0; 0 0 1];
r = rodrigues(R);
t=[tx; ty; tz];

P.fDu = fDu;
P.fDv = fDv;
P.u0 = u0;
P.v0 = v0;
P.tao = acosd(R(3,3));
P.sigma = acosd(-R(2,3)/sind(P.tao));
P.phi = acosd(-R(3,2)/sind(P.tao));
P.tx = t(1);
P.ty = t(2);
P.tz = t(3);
