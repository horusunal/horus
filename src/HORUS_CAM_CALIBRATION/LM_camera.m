function [B R F hist]=LM_camera(ui,vi,xi,yi,zi,est,var,A,v,tao,eps,kmax)
% 
% [B R F hist]=LM_camera(ui,vi,xi,yi,zi,est,var,A,v,tao,eps,kmax)
% Levenberg-Marquardt algorithm implemented to work with the residual
% vectorial function of the Pinhole model with distortion as given in P�rez
% (2009) and P�rez et al (2011). Is uses the update mechanisms of the
% parameter lambda presented in P�rez (2009).
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
%   A: Initial value of the parameter lambda as presented in P�rez (2009)
%   and P�rez et al (2011), it controls the Levenberg-Marquardt method as
%   if A=0 the method is equal to the Gauss-Newton method and if A->inf
%   then the method tends to the Gradient method.
%   v: Parameter to control the update rate of the parameter lambda as
%   presented in P�rez (2009).
%   tao: Control parameter to avoid zero divisions when the update ratio of
%   the estimates is calculated. See P�rez (2009) chapter 3.3.
%   eps: Control parameter to stop the algorithm when the Value of F'F or
%   the estimate update is smaller than eps. See P�rez (2009) chapter 3.3.
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

% Initialization step
k = 1;
B(:, 1) = est;
n = length(est);
ind = find(var);
ni = length(ind);
d = zeros(n, 1);
d1 = d;
d2 = d;
hw = waitbar(0, 'Solving Levenberg-Marquardt iterations...');

while k <= kmax
    % Residual vector
    R = F_Pinhole_dist(ui, vi, xi, yi, zi, B(:, k));
    % Sum of the squares of the residuals
    F = R' * R;
    % Jacobian matrix of R
    Rp = JF_camera(ui, vi, xi, yi, zi, B(:, k), var);
    % History update
    hist(k, :) = [A F norm(Rp) norm(2 * Rp' * R) d'];

    % Using lambda (A), F(A_k) and F(A_k/v) are calculated
    d1(ind) = sparse((Rp' * Rp + A * eye(ni))) \ -Rp' * R;
    d2(ind) = sparse((Rp' * Rp + A / v * eye(ni))) \ -Rp' * R;
    
    R1 = F_Pinhole_dist(ui, vi, xi, yi, zi, B(:, k) + d1);
    R2 = F_Pinhole_dist(ui, vi, xi, yi, zi, B(:, k) + d2);
    F1 = R1' * R1;
    F2 = R2' * R2;

    % Marquardt update mechanism
    dg = -Rp' * R;
    Kr = 2;
    id = 0;
    if F2 <= F
        A = A / v;
    elseif F2 > F && F1 <= F
        A = A;
    else
        while F1 > F
            A = A * v;
            dl = sparse((Rp' * Rp + A * eye(ni))) \ -Rp' * R;
            if acos(dl' * dg / (norm(dl) * norm(dg))) > pi/2 || acos(dl' * dg / (norm(dl) * norm(dg))) < pi/4
                while F1 > F
                    d1(ind) = sparse((Rp' * Rp + A * eye(ni))) \ -Rp' * R;
                    Kr = Kr / v;
                    B1 = B(:,k) + Kr * d1;
                    R1 = F_Pinhole_dist(ui, vi, xi, yi, zi, B1);
                    F1 = R1' * R1;
                end
                id = 1;
                break
            else
                d1(ind) = sparse((Rp' * Rp + A * eye(ni))) \ -Rp' * R;
                B1 = B(:, k) + d1;
                R1 = F_Pinhole_dist(ui, vi, xi, yi, zi, B1);
                F1 = R1' * R1;
            end
            R1 = F_Pinhole_dist(ui, vi, xi, yi, zi, B1);
            F1 = R1' * R1;
        end
    end

    % Using the new lambda (A), we calculate the update vector d and B+d
    % the new estimates values.
    d(ind) = sparse((Rp' * Rp + A * eye(ni))) \ -Rp' * R;
    k = k + 1;
    if id == 0
        B(:, k) = B(:, k - 1) + d;
    else
        B(:, k) = B(:, k - 1) + Kr * d;
    end

    % Ratio between the updates and the actual estimates values
    er = max(abs(d) ./ (tao + abs(B(:, k))));

    waitbar(k / kmax, hw)
    
    R1 = F_Pinhole_dist(ui, vi, xi, yi, zi, B(:,end));
    F = R1' * R1;
    
    % Stop mechanism
    if er < eps || F < 1e-25
        break
    end
end
close(hw)
R = F_Pinhole_dist(ui, vi, xi, yi, zi, B(:,end));
F = R' * R;
% Final Jacobian
Rp = JF_camera(ui, vi, xi, yi, zi, B(:, end), var);
% History update
hist(k, :) = [A F norm(Rp) norm(2 * Rp' * R) d'];
