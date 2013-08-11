function [H K D R t P MSEuv MSExy NCError]=camera_cal(ui,vi,xi,yi,zi,est,var)
%
%   [H K D R t P MSEuv MSExy NCError]=camera_cal(ui,vi,xi,yi,zi,est,var)
%
%   This function finds estimates for all the Pinhole model parameters
%   using the Levenberg-Marquardt method proposed in P�rez (2009) and P�rez
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
%       NCEerror: Normalized Calibration error as presented in P�rez (2009).
%
% It is possible to estimate as well just the extrinsec parameter, the
% intrinsec parameter, the distortion parameters or all the parameters of
% the Pinhole model withou distortion. In such cases it is possible also to
% use less than 6 GCPs but then initial estimates need to be defined.
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
%


%% Initialize output variables as empty
H=[];
K=[];
D=[];
R=[];
t=[];
P=[];
MSEuv=[];
MSExy=[];
NCError=[];

%% Check how many parameters are going to be estimated
var=logical(var);
if sum(var)==12 || (sum(var)==10&&sum(var(3:4)==0)) || (sum(var)==8&&sum(var(1:4)==0))
    mode='AllDist';
elseif sum(var)==10&&sum(var(5:6))==0 || (sum(var)==8&&sum(var(3:6)==0))
    mode='AllNoDist';
elseif sum(var)==6&&sum(var(1:6))==0
    mode='Extrinsec';
elseif sum(var)==4&&sum(var(1:4))==4
    mode='Intrinsec';
elseif sum(var)==2&&sum(var(5:6))==2
    mode='Dist';
else
    f = errordlg({'It is not recommended to estimate just a part of the',...
        'intrinsec or extrinsec parameters.',...
        'Try to use a different parameter set if the result is not good'},'Error', 'modal');
    waitfor(f)
    mode='AllDist';
    %return
end

% Initial estimates calculation when enough GCP are used.
if isempty(est)&&length(ui)>=6
    [H]=DLT(ui,vi,xi,yi,zi); %DLT calculation
    [K,R,t,P1]=extractDLT(H,ui,vi,xi,yi,zi); %Extracting the parameters
    % The distortion parameters are set to 0 initially
    est=[K(1,1) -K(2,2) K(1,3) K(2,3) 0 0 rodrigues(R)' t'];
elseif isempty(est)
    % With less than 6 GCPs, it is necessary to define initial estimates
    f = errordlg({'It is not possible to calculate initial estimate with',...
        'the number of GCPs used.',...
        'Try to give initial estimates or increase the',...
        'number of GCPs used'},'Error', 'modal');
    return
end

%Estimating the parameters
switch mode
    case {'AllNoDist','Extrinsec','Intrinsec'}
        est=est([1:4 7:12]);
        [B F hist]=LM_Pinhole(ui,vi,xi,yi,zi,est,5,10,1e-10,1e-10,2000);
        estn=B(:,end)';
        Re=F_Pinhole_ND(ui,vi,xi,yi,zi,estn);
        estn=[estn(1:4) 0 0 estn(5:10)];
    case {'AllDist','Dist'}
        [B Re F hist]=LM_camera(ui,vi,xi,yi,zi,est,var,5,20,1e-4,1e-6,2500);
        estn=B(:,end)';
end

% Construction K, R, D and t
K=[estn(1) 0 estn(3);0 -estn(2) estn(4);0 0 1];
D=[estn(5) estn(6)];
R=rodrigues([estn(7) estn(8) estn(9)]');
t=[estn(10) estn(11) estn(12)]';

P.fDu=estn(1);
P.fDv=estn(2);
P.u0=estn(3);
P.v0=estn(4);
P.k1=estn(5);
P.k2=estn(6);
P.tao=-acosd(R(3,3));
P.sigma=atand(-R(1,3)/-R(2,3));
P.phi=atand(-R(3,1)/-R(3,2));

C=-inv(R)*t;
P.xc=C(1);
P.yc=C(2);
P.zc=C(3);

H=K*[R t];

n = length(ui);

uu = zeros(n, 1);
vv = zeros(n, 1);
for i=1:n
    [uu(i) vv(i)]=undistort(K,D,[ui(i) vi(i)]);
end

xn = zeros(n, 1);
yn = zeros(n, 1);
for i=1:n
    XY=([H(:,[1 2]) -[uu(i);vv(i);1]])\(-H(:,[3 4])*[zi(i);1]);
    xn(i)=XY(1);
    yn(i)=XY(2);
end

% Error of the estimated model
MSExy=sqrt(sum((xn-xi).^2+(yn-yi).^2)/length(xi));

MSEuv=sqrt(F/length(Re));

NCError=NCE(ui,vi,xi,yi,zi,estn);