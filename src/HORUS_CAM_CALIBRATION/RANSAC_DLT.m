function [H UV XYZ pos]=RANSAC_DLT(u,v,x,y,z)
%
% [H UVend XYZend pos]=RANSAC_DLT(u,v,x,y,z)
% This function calculates the DLT as presented in P�rez (2009) and P�rez
% et al (2011), selecting the GCP to use based on the RANSAC method. It
% needs at least 6 GCPs to calculate the homogeneous solution of the DLT
% using an approach based on Singular Value Decomposition as presented in
% P�rez (2009). The DLT, H satisfies the condition h31^2+h32^2+h33^2=1.
% Inputs:
%   u: coordinates u of the GCPs on the image (nx1 matrix).
%   v: coordinates v of the GCPs on the image (nx1 matrix).
%   x: coordinates x of the GCPs in the space (nx1 matrix).
%   y: coordinates y of the GCPs in the space (nx1 matrix).
%   z: coordinates z of the GCPs in the space (nx1 matrix).
% Outputs:
%   H: DLT of the camera, satisfying the condition h31^2+h32^2+h33^2=1.
%   UVend: Image coordinates of the GCP used to calculate the DLT after
%   using the RANSAC method.
%   XYZend: Space coordinates of the GCP used to calculate the DLT after
%   using the RANSAC method.
%   pos: Index with respect o the original GCPs of the final GCPs obtained
%   with the RANSAC method.
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

u1 = u;
v1 = v;
x1 = x;
y1 = y;
z1 = z;

[H] = DLT(u1, v1, x1, y1, z1);

UV1 = H * [x1'; y1'; z1'; ones(size(x1'))];
uf1 = (UV1(1, :) ./ UV1(3, :))';
vf1 = (UV1(2, :) ./ UV1(3, :))';

EMC1 = sqrt((uf1 - u1) .^ 2 + (vf1 - v1) .^ 2);
[mm ind] = max(abs(EMC1 - mean(EMC1)));
pos = [1:(ind - 1) (ind + 1):length(x1)];

u2 = u(pos);
v2 = v(pos);
x2 = x(pos);
y2 = y(pos);
z2 = z(pos);

[H] = DLT(u2, v2, x2, y2, z2);

UV2 = H * [x2'; y2'; z2'; ones(size(x2'))];
uf2 = (UV2(1, :) ./ UV2(3, :))';
vf2 = (UV2(2, :) ./ UV2(3, :))';

EMC2 = sqrt((uf2 - u2) .^ 2 + (vf2 - v2) .^ 2);

while length(pos) > 6 && abs(mean(EMC1) - mean(EMC2)) / mean(EMC1) > 0.05
    u1 = u(pos);
    v1 = v(pos);
    x1 = x(pos);
    y1 = y(pos);
    z1 = z(pos);
    
    [H] = DLT(u1, v1, x1, y1, z1);

    UV1 = H * [x1'; y1'; z1'; ones(size(x1'))];
    uf1 = (UV1(1, :) ./ UV1(3, :))';
    vf1 = (UV1(2, :) ./ UV1(3, :))';
    
    EMC1 = sqrt((uf1 - u1) .^ 2 + (vf1 - v1) .^ 2);
    
    [mm ind] = max(abs(EMC1 - mean(EMC1)));
    pos = pos([1:(ind - 1) (ind + 1):length(x1)]);
    
    u2 = u(pos);
    v2 = v(pos);
    x2 = x(pos);
    y2 = y(pos);
    z2 = z(pos);
    
    [H] = DLT(u2, v2, x2, y2, z2);
    
    UV2 = H * [x2'; y2'; z2'; ones(size(x2'))];
    uf2 = (UV2(1, :) ./ UV2(3, :))';
    vf2 = (UV2(2, :) ./ UV2(3, :))';
    
    EMC2 = sqrt((uf2 - u2) .^ 2 + (vf2 - v2) .^ 2);
end
UV = [u2 v2];
XYZ = [x2 y2 z2];
[H] = DLT(u2, v2, x2, y2, z2);
