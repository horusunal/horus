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

% Initialization step
k=1;
B(:,1)=B0;
n=length(B0);
d=zeros(n,1);
while k<kmax
    % Least squares function
    F=F_Pinhole_ND(ui,vi,xi,yi,zi,B(:,k))'*F_Pinhole_ND(ui,vi,xi,yi,zi,B(:,k));
    % Jacobian of the residuals vector
    Rp=JF_Pinhole_ND(ui,vi,xi,yi,zi,B(:,k));
    % History update
    hist(k,:)=[A F norm(Rp) norm(2*Rp'*F_Pinhole_ND(ui,vi,xi,yi,zi,B(:,k))) d'];
    
    %F(A_k) and F(A_k/v) calculation
    d1=inv(sparse((Rp'*Rp+A*eye(n))))*-Rp'*F_Pinhole_ND(ui,vi,xi,yi,zi,B(:,k));
    d2=inv(sparse((Rp'*Rp+A/v*eye(n))))*-Rp'*F_Pinhole_ND(ui,vi,xi,yi,zi,B(:,k));
    F1=F_Pinhole_ND(ui,vi,xi,yi,zi,B(:,k)+d1)'*F_Pinhole_ND(ui,vi,xi,yi,zi,B(:,k)+d1);
    F2=F_Pinhole_ND(ui,vi,xi,yi,zi,B(:,k)+d2)'*F_Pinhole_ND(ui,vi,xi,yi,zi,B(:,k)+d2);
    
    % Marquardt decision mechanism
    dg=-Rp'*F_Pinhole_ND(ui,vi,xi,yi,zi,B(:,k));
    Kr=2;
    id=0;
    if F2<=F
        A=A/v;
    elseif F2>F&&F1<=F
        A=A;
    else
        while F1>F
            A=A*v;
            d1=inv(sparse((Rp'*Rp+A*eye(n))))*-Rp'*F_Pinhole_ND(ui,vi,xi,yi,zi,B(:,k));
            if acos(d1'*dg/(norm(d1)*norm(dg)))>pi/2 || acos(d1'*dg/(norm(d1)*norm(dg)))<pi/4
                while F1>F
                    d1=inv(sparse((Rp'*Rp+A*eye(n))))*-Rp'*F_Pinhole_ND(ui,vi,xi,yi,zi,B(:,k));
                    Kr=Kr/v;
                    B1=B(:,k)+Kr*d1;
                    F1=F_Pinhole_ND(ui,vi,xi,yi,zi,B1)'*F_Pinhole_ND(ui,vi,xi,yi,zi,B1);
                end
                id=1;
                break
            else
                B1=B(:,k)+d1;
                F1=F_Pinhole_ND(ui,vi,xi,yi,zi,B1)'*F_Pinhole_ND(ui,vi,xi,yi,zi,B1);
            end
            F1=F_Pinhole_ND(ui,vi,xi,yi,zi,B1)'*F_Pinhole_ND(ui,vi,xi,yi,zi,B1);
        end
    end
    
    %d and B+d calculation
    d=inv(sparse((Rp'*Rp+A*eye(n))))*-Rp'*F_Pinhole_ND(ui,vi,xi,yi,zi,B(:,k));
    k=k+1;
    if id==0
        B(:,k)=B(:,k-1)+d;
    else
        B(:,k)=B(:,k-1)+Kr*d;
    end
    
    %ratio between the updates (d) and the actual estimates values
    er=max(abs(d)./(tao+abs(B(:,k))));
    
    if er<eps
        break
    end
end

F=F_Pinhole_ND(ui,vi,xi,yi,zi,B(:,end))'*F_Pinhole_ND(ui,vi,xi,yi,zi,B(:,end));
% Jacobian
Rp=JF_Pinhole_ND(ui,vi,xi,yi,zi,B(:,end));
% History update
hist(k,:)=[A F norm(Rp) norm(2*Rp'*F_Pinhole_ND(ui,vi,xi,yi,zi,B(:,end))) d'];

