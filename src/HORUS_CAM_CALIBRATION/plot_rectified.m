function plot_rectified(rectimg, H, K, D, roi, z)
%
% plot_rectified(rectimg, H, H, D, roi, z)
% This function plots the rectified image rectimg using the roi of original
% coordinates in the image (u v) and the assumed value of z for the
% rectification process in the function rectify.
% Inputs:
%     rectimg: rectified image to be plotted.
%     H: Pinhole matrix H=K[R t]  or DLT as presented in Pérez (2009) and
%     Pérez et al (2010).
%     K: 3x3 upper triangular matrix with the intrinsec parameters of the
%     camera model used to correct the lens distortion effect, if no
%     distortion is going to be corrected, the K may be an empty array.
%     D: 1x2 matrix with the radial distortion parameters of the camera
%     model, [k1 k2]. This parameters are used to correct the distortion
%     effects in the image and, therefore, if there is no distortion to
%     correct then D might be an empty array.
%     roi: matrix nx2 with the coordinates (u,v) of the points that define
%     the area rectified.
%     z: value of the Z coordinate where the interest area is assumed to be
%     located. Depending of the units used for the GCPs its value may be
%     [mm], [cm] or [m].
%
%   Developed by Juan camilo Pérez Muñoz (2011) for the HORUS project
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

if isempty(K)||isempty(D)
    IDDist=0;
else
    IDDist=1;
end

if IDDist==1
    for i=1:size(roi,1)
        [u(i,1) v(i,1)]=undistort(K,D,roi(i,:));
    end
else
    u=roi(:,1);
    v=roi(:,2);
end
[X Y Z] = UV2XYZ(H,u,v,z);

newX2 = zeros(4, 3);
newX2(:, 3) = z;

newX2(1, 1) = min(X);
newX2(1, 2) = min(Y);
newX2(2, 1) = min(X);
newX2(2, 2) = max(Y);
newX2(3, 1) = max(X);
newX2(3, 2) = max(Y);
newX2(4, 1) = max(X);
newX2(4, 2) = min(Y);

minX = floor(min(newX2(:, 1)));
maxX = floor(max(newX2(:, 1)));
minY = floor(min(newX2(:, 2)));
maxY = floor(max(newX2(:, 2)));

figure;
imagesc(rectimg);

axis equal tight
grid on

[m n]=size(rectimg(:,:,1));

deltaX=maxX-minX;
deltaY=maxY-minY;

mindelta=max(deltaX,deltaY);

if mindelta<=10
    delta=1;
elseif mindelta<=100
    delta=round(mindelta/10);
elseif mindelta<=1000
    delta=round(mindelta/100)*10;
else
    delta=round(mindelta/1000)*100;
end

if minX*maxX<0
    coordx(1,:)=0:delta:maxX;
    coordx=[fliplr([-delta:-delta:minX]) coordx];
elseif maxX<=0
    coordx(1,:)=fliplr([0:-delta:minX]);
    tc= coordx<=maxX;
    coordx=coordx(tc);
else
    coordx(1,:)=[0:delta:maxX];
    tc= coordx>=minX;
    coordx=coordx(tc);
end

if minY*maxY<0
    coordy(1,:)=0:delta:maxY;
    coordy=[fliplr([-delta:-delta:minY]) coordy];
elseif maxY<=0
    coordy(1,:)=fliplr([0:-delta:minY]);
    tc= coordy<=maxY;
    coordy=coordy(tc);
else
    coordy(1,:)=[0:delta:maxY];
    tc= coordy>=minY;
    coordy=coordy(tc);
end
coordy=fliplr(coordy);

pixX=(coordx-minX)./(deltaX/n);
pixY=m-(coordy-minY)./(deltaY/m);

set(gca,'XTick',pixX);
set(gca,'YTick',pixY);

a=num2str(coordx(1));
for k=2:length(coordx)
    b=['|' num2str(coordx(k))];
    a=strcat(a,b);
end
a1=num2str(coordy(1));
for k=2:length(coordy)
    b1=['|' num2str(coordy(k))];
    a1=strcat(a1,b1);
end

set(gca,'XTickLabel',a);
set(gca,'YTickLabel',a1);
ylabel('y (m)')
xlabel('x (m)')