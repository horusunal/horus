function plot_resolution(H,K,D,u,v,I_rect,zvalue)
%
% plot_resolution(H,K,D,u,v,I_rect,zvalue)
% This function creates a resolution map on the portion of the rectified
% image obtained using the function rectify.
% Inputs:
%  H: Pinhole model matrix or DLT.
%  K: 3x3 upper triangular matrix with the intrinsec parameters of the
%  camera model used to correct the lens distortion effect, if no
%  distortion is going to be corrected, the K may be an empty array.
%  D: 1x2 matrix with the radial distortion parameters of the camera model,
%  [k1 k2]. This parameters are used to correct the distortion effects in
%  the image and, therefore, if there is no distortion to correct then D
%  might be an empty array.
%  u: u coordinates of the rectified region on teh original image, these
%  are returned by the function rectify.
%  v: v coordinates of the rectified region on teh original image, these
%  are returned by the function rectify.
%  I_rect: Rectified image obtained with the function rectify.
%  zvalue: Z value used to create the rectified image.
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

if isempty(K)||isempty(D)
    IDDist=0;
else
    IDDist=1;
end

if IDDist==1
    for i=1:size(u,1)
        [u(i,1) v(i,1)]=undistort(K,D,[u(i) v(i)]);
    end
end

[newX(:,1) newX(:,2) newX(:,3)] = UV2XYZ(H,u,v,zvalue);

newX2=zeros(4,3);
newX2(:,3)=zvalue;
newX2(1,1)=min(newX(:,1));
newX2(1,2)=min(newX(:,2));
newX2(2,1)=min(newX(:,1));
newX2(2,2)=max(newX(:,2));
newX2(3,1)=max(newX(:,1));
newX2(3,2)=max(newX(:,2));
newX2(4,1)=max(newX(:,1));
newX2(4,2)=min(newX(:,2));
minX=floor(min(newX2(:,1)));
maxX=floor(max(newX2(:,1)));
minY=floor(min(newX2(:,2)));
maxY=floor(max(newX2(:,2)));

figure(20);close(gcf);figure(20)
imagesc(I_rect);
axis equal tight
grid on

[m n]=size(I_rect(:,:,1));

deltaX=maxX-minX;
deltaY=maxY-minY;

mindelta=min(deltaX,deltaY);

if mindelta<=10
    delta=1;
elseif mindelta<=100
    delta=round(mindelta/10);
elseif mindelta<=1000
    delta=round(mindelta/100)*10;
else mindelta<=10000
    delta=round(mindelta/1000)*100;
end

if minX*maxX<0
    coordx(1,:)=0:delta:maxX;
    coordx=[fliplr([-delta:-delta:minX]) coordx];
elseif maxX<=0
    coordx(1,:)=fliplr([0:-delta:minX]);
    tc=find(coordx<=maxX);
    coordx=coordx(tc);
else
    coordx(1,:)=[0:delta:maxX];
    tc=find(coordx>=minX);
    coordx=coordx(tc);
end

if minY*maxY<0
    coordy(1,:)=0:delta:maxY;
    coordy=[fliplr([-delta:-delta:minY]) coordy];
elseif maxY<=0
    coordy(1,:)=fliplr([0:-delta:minY]);
    tc=find(coordy<=maxY);
    coordy=coordy(tc);
else
    coordy(1,:)=[0:delta:maxY];
    tc=find(coordy>=minY);
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

[U V]=meshgrid(linspace(min(u),max(u),40),linspace(min(v),max(v),40));
[resX resY]=resolution(H,K,D,U,V);
resX=resX(:);
resY=resY(:);
U=U(:);
V=V(:);
if IDDist==1
    for i=length(U)
        [U(i,1) V(i,1)]=undistort(K,D,[U(i) V(i)]);
    end
end
[x y z]=UV2XYZ(H,U,V,0);
pixX=(x-minX)./(deltaX/n);
pixY=m-(y-minY)./(deltaY/m);

[pixU pixV]=meshgrid(1:5:n,1:5:m);
resx=griddata(pixX,pixY,resX,pixU,pixV,'linear');
resy=griddata(pixX,pixY,resY,pixU,pixV,'linear');
title('Resolution (m/pix), x_{res} in blue, y_{res} in red')
ho=gca;
hx=axes('position',get(gca,'Position'));
[CC hh]=contour(pixU,pixV,resx,'LineColor','b');
levels=get(hh,'LevelList');
clabel(CC,hh,levels(1:2:end),'Color','y','Fontsize',10);
set(hx,'xlim',get(ho,'xlim'),'ylim',get(ho,'ylim'),'Visible','off',...
    'Ydir','reverse','PlotBoxAspectRatio',get(ho,'PlotBoxAspectRatio'));

hy=axes('position',get(gca,'Position'));
[CC hh]=contour(pixU,pixV,resy,'LineColor','r');
levels=get(hh,'LevelList');
clabel(CC,hh,levels(1:2:end),'Color','y','Fontsize',10);
set(hy,'xlim',get(ho,'xlim'),'ylim',get(ho,'ylim'),'Visible','off',...
    'Ydir','reverse','PlotBoxAspectRatio',get(ho,'PlotBoxAspectRatio'));


function [resx resy]=resolution(H,K,D,u,v)
u1=u(:);
v1=v(:);
if isempty(K)||isempty(D)
    IDDist=0;
else
    IDDist=1;
end
if IDDist==1
    for i=length(u1)
        [u1(i,1) v1(i,1)]=undistort(K,D,[u1(i) v1(i)]);
    end
end
[x y z]=UV2XYZ(H,[u1-1;u1+0;u1+1],[v1-1;v1+0;v1+1],0);
x=reshape(x,size(u1,1),3);
y=reshape(y,size(u1,1),3);
resx=(abs(x(:,1)-x(:,2))+abs(x(:,3)-x(:,2)))/2;
resy=(abs(y(:,1)-y(:,2))+abs(y(:,3)-y(:,2)))/2;
resx=reshape(resx,size(u));
resy=reshape(resy,size(v));
