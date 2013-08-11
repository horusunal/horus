function [Hnew B F hist]=levmarProjective(I1,I2,u2,v2,H,A,v,eps,kmax)

% [B  F hist]=levmarProjective(I1,I2,u2,v2,H,A,v,tao,eps,kmax)
% This function optimizes the projective transformation H between images I1
% and I2 using the ideas in Montoliu and Pla (2009), but using the
% Levenberg-Marquardt method as optimization technique using the
% implemntation presented in Perez (2009).
%
% Inputs:
%   I1: image at the left or reference image
%   I2: Image at the right or image to be transformed.
%   u2: Coordinates of the points used to optimize in the direction U for
%   image I2, can be an empty array and then the algorithm uses borders in
%   the image as point to optimize.
%   v2: Coordinates of the points used to optimize in the direction V for
%   image I2, can be an empty array and then the algorithm uses borders in
%   the image as point to optimize.
%   H: Image transformation from I2 to I1 (Original images without scaling)
%   A: Value of lambda in the levenberg-Marquardt algoritmh as presented in
%   Perez (2009), a good starting value is 20.
%   v: Update value for lambda as presented in Perez (2009), a good
%   starting point is 10.
%   eps: Stoping parameter for the Levenberg-Marquartd algorithm, if the
%   parameters changes are lower than this value, then the algorithm stops.
%   kmax: Maximum number of iterations for the Levenmberg-Marquardt method.
% Outputs:
%   Hnew: Optimized matrix transformation.
%   B: History of the transformation parameters during the optimization
%   process.
%   F: Value of the minimized functional
%   hist: Matrix of dimension k x (3+n), where the first column is the
%   history of lambda (A), the second column is the history of F, the third
%   column is the history of the Jacobian norm of the functional, the
%   fourth column is the history of the gradient norm of F and the next
%   columns are the history of the updates for each parameter.
%
% References:
%   PEREZ, J.  M.Sc. Thesis, Optimizacion No Lineal y Calibracion de
%   Camaras Fotograficas. Facultad de Ciencias, Universidad Nacional de
%   Colombia, Sede Medellin. (2009). Available online in
%   http://www.bdigital.unal.edu.co/3516/
%   MONTOLIU, R., PLA, F. "Generalized least squares-based parametric
%   motion estimation". Computer Vision and Image Understanding 113 (2009)
%   pp 790-801.

try
    % Check if the images are gray scale
    if size(I1,3)>1
        I1=rgb2gray(I1);
    end
    if size(I2,3)>1
        I2=rgb2gray(I2);
    end
    
    % The first parameter estimate is given by H
    B0(:,1)=[H(1,:) H(2,:) H(3,1:2)]';
    
    % Transform the images to double
    I1=double(I1); I2=double(I2);
    
    if isempty(u2)
        % Since no all the image merge completelly, we need to find the pixels
        % coordintes on I2 that are likely to be in I1.
        %Fin the edges in the images I2
        BW=edge(imadjust(uint8(I2)),'canny',0.25);
        [vi ui]=find(BW);
        % Select just a number of points in the edges
        ind=round(linspace(1,length(vi),min(3000,length(vi))));
        ui=ui(ind); vi=vi(ind);
        ui=ui(ui<size(I2,2)&ui>0); vi=vi(vi<size(I2,1)&vi>0);
    else
        ui=round(u2);vi=round(v2);
    end
    % transform the coordinates from image I2 to I1 using the actual parameters
    [un vn]=im2imTransform(ui(:),vi(:),H);
    % reshape the new coordinates
    ui=reshape(ui,size(un));
    vi=reshape(vi,size(vn));
    % Find the coordinates values that are inside I1
    ind=find(un<10|un>size(I1,2)-10|vn<10|vn>size(I1,1)-10);
    ui(ind)=[];
    vi(ind)=[];
    vn(ind)=[];
    un(ind)=[];
    
    % gradient of the image
    [I1u,I1v] = gradient(I1);
    
    %% Levenberg-Marquardt method %%%%%%%%%%%%%%%
    
    %Initialize
    k=1;
    B(:,1)=B0;
    n=length(B0);
    d=zeros(n,1);
    
    while k<=kmax
        % Transformation matrix
        H=[B(1:3,k)';B(4:6,k)';B(7:8,k)' 1];
        
        % Least-squares function calculation
        F=affineF(I1,I2,H,ui,vi)'*affineF(I1,I2,H,ui,vi);
        %Jacobian calculation
        Rp=ProjectivedF(I1u,I1v,H,ui,vi);
        %History update
        hist(k,:)=[A F norm(Rp) norm(2*Rp'*affineF(I1,I2,H,ui,vi)) d'];
        
        %Obtain  F(A_k) and F(A_k/v)
        d1=inv(sparse((Rp'*Rp+A*eye(n))))*-Rp'*affineF(I1,I2,H,ui,vi);
        d2=inv(sparse((Rp'*Rp+A/v*eye(n))))*-Rp'*affineF(I1,I2,H,ui,vi);
        H1=H+[d1(1:3)';d1(4:6)';d1(7:8)' 0];
        H2=H+[d2(1:3)';d2(4:6)';d2(7:8)' 0];
        F1=affineF(I1,I2,H1,ui,vi)'*affineF(I1,I2,H1,ui,vi);
        F2=affineF(I1,I2,H2,ui,vi)'*affineF(I1,I2,H2,ui,vi);
        
        %Marquardt decision method
        dg=-Rp'*affineF(I1,I2,H,ui,vi);
        Kr=2;
        id=0;
        if F2<=F
            A=A/v;
        elseif F2>F&&F1<=F
            A=A;
        else
            while F1>F
                A=A*v;
                d1=inv(sparse((Rp'*Rp+A*eye(n))))*-Rp'*affineF(I1,I2,H,ui,vi);
                if acos(d1'*dg/(norm(d1)*norm(dg)))>pi/2 || acos(d1'*dg/(norm(d1)*norm(dg)))<pi/4
                    while F1>F
                        d1=inv(sparse((Rp'*Rp+A*eye(n))))*-Rp'*affineF(I1,I2,H,ui,vi);
                        Kr=Kr/v;
                        B1=B(:,k)+Kr*d1;
                        H1=[B1(1:3,1)';B1(4:6,1)';B1(7:8,1)' 1];
                        F1=affineF(I1,I2,H1,ui,vi)'*affineF(I1,I2,H1,ui,vi);
                    end
                    id=1;
                    break
                else
                    B1=B(:,k)+d1;
                    H1=[B1(1:3,1)';B1(4:6,1)';B1(7:8,1)' 1];
                    F1=affineF(I1,I2,H1,ui,vi)'*affineF(I1,I2,H1,ui,vi);
                end
                H1=H+[d1(1:3)';d1(4:6)';d1(7:8)' 0];
                F1=affineF(I1,I2,H1,ui,vi)'*affineF(I1,I2,H1,ui,vi);
            end
        end
        
        %With the new A, obtain the parameter update vector d and the new
        %parameters estimates B+d
        d=inv(sparse((Rp'*Rp+A*eye(n))))*-Rp'*affineF(I1,I2,H,ui,vi);
        k=k+1;
        if id==0
            B(:,k)=B(:,k-1)+d;
        else
            B(:,k)=B(:,k-1)+Kr*d;
        end
        
        %Finish condition
        er=max(abs(d)./(1e-7+abs(B(:,k))));
        if er<eps
            break
        end
        
    end
    
    % Calculate optimized transformation
    Hnew=[B(1:3,k)';B(4:6,k)';B(7:8,k)' 1];
    
    % Obtain functional value
    F=affineF(I1,I2,Hnew,ui,vi)'*affineF(I1,I2,Hnew,ui,vi);
    
    %Jacobian
    Rp=ProjectivedF(I1u,I1v,Hnew,ui,vi);
    
    %History update
    hist(k,:)=[A F norm(Rp) norm(2*Rp'*affineF(I1,I2,Hnew,ui,vi)) d'];
    
catch e
    disp(e.message)
end

end

%%%%
function F=affineF(I1,I2,H,u2,v2)
try
    [u1 v1]=im2imTransform(u2,v2,H);
    u1=round(u1); v1=round(v1);
    
    for i=1:length(u2)
        try
            F(i,1)=(I2(v2(i),u2(i))-I1(v1(i),u1(i)));
        catch
            F(i,1)=255;
        end
    end
catch e
    disp(e.message)
end
end


%%%%%

function dF=ProjectivedF(I1u,I1v,H,u2,v2)

try
    [u1 v1]=im2imTransform(u2,v2,H);
    u1=round(u1); v1=round(v1);
    a1=H(1,1); b1=H(1,2); c1=H(1,3);
    a2=H(2,1); b2=H(2,2); c2=H(2,3);
    d=H(3,1); e=H(3,2);
    for i=1:length(u2)
        try
            N=d*u2(i)+e*v2(i)+1;
            dF(i,:)=-1/N*[I1u(v1(i),u1(i))*u2(i), I1u(v1(i),u1(i))*v2(i),...
                I1u(v1(i),u1(i)), I1v(v1(i),u1(i))*u2(i),...
                I1v(v1(i),u1(i))*v2(i), I1u(v1(i),u1(i)),...
                I1u(v1(i),u1(i))*u1(i)*u2(i)+I1v(v1(i),u1(i))*v1(i)*u2(i),...
                I1u(v1(i),u1(i))*u1(i)*v2(i)+I1v(v1(i),u1(i))*v1(i)*v2(i)];
        catch
            dF(i,:)=0;
        end
    end
catch e
    disp(e.message)
end
end
