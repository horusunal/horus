function In=undistort_Image(K,D,name,idg,ids)
%
% In=undistort_Image(K,D,name,idg,ids)
% This function uses the method presented in Pérez (2009) to correct the
% distortion in an image using the Pinhole model with radial distortion.
% Inputs:
%  K: Intrinsec parameter matrix
%  D: Radial distortion parameters: [k1 k2]
%  name: Complete path of the image as character array. For example
%  'C:\MyDB\images\MyImage.jpg'
%  idg: control parameter used to identify with 1 when the plots should be
%  plotted and 0 when no plots are required.
%  ids: control parameter used to identify with 1 when the result should be
%  saved and 0 when no saving is required.
% Outputs:
%  In: Distortion-free image.
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

I=imread(name);

[X Y]=meshgrid(1:size(I,2),1:size(I,1));

XI=zeros(size(I,1),size(I,2));
YI=XI;

for j=1:size(I,2)
    [u v]=distort(K,D,[X(:,j) Y(:,j)]);
    XI(:,j)=u;
    YI(:,j)=v;
end

try
    if size(I,3)==1
        In = interp2(X,Y,double(I(:,:,1)),XI,YI,'linear');
    else
        In(:,:,1) = interp2(X,Y,double(I(:,:,1)),XI,YI,'linear');
        In(:,:,2) = interp2(X,Y,double(I(:,:,2)),XI,YI,'linear');
        In(:,:,3) = interp2(X,Y,double(I(:,:,3)),XI,YI,'linear');
    end
catch
    In=[];
    hmsg=errordlg('There is an error. The selected area is too big or the used model is not accurate','Error');
    waitfor(hmsg);
    return
end

In=uint8(In);

if idg==1
    figure(1), imshow(I), title('Figura original')
    figure(2), imshow(In), title('Figura con distorsion corregida')
end


if ids==1
    data=imfinfo(name);
    name2=strrep(lower(name),['.' data.Format],['_undistort.' data.Format]);
    imwrite(In,name2,'JPEG','Quality',100)
end

