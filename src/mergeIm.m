function [I offun offvn]=mergeIm(I1,I2,H,offu,offv,sf)

% [I offun offvn]=mergeIm(I1,I2,H,offu,offv,sf)
% This function merges two images related with the transformation matrix H,
% independently of the type of transformation. It can use sacale factor. It
% follows the ideas in Perez (2009) and Montoliu & Pla (2009) to merge the
% images.
%
% Inputs:
%   I1: image at the left or reference image
%   I2: Image at the right or image to be transformed.
%   H: Image transformation from I2 to I1 (Original images without scaling)
%   offu: offset of the image I2 in direction U, it is used when trying to
%   merge an image already merged with a new one.
%   offv: offset of the image I2 in direction U, it is used when trying to
%   merge an image already merged with a new one.
%   sf: scaling factor for both images as a vector [sf1 sf2], sf1 and sf2
%   must be values between 0 and 1.
% Outputs:
%   I: merged image
%   offun: offset of the merged image in direction U, it is used when
%   trying to merge an image already merged with a new one. Use it when
%   merging the image with another one.
%   offun: offset of the merged image in direction U, it is used when
%   trying to merge an image already merged with a new one. Use it when
%   merging the image with another one.
%
%   Developed by Juan camilo Perez Munoz (2011) for the HORUS project.
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
    if isempty(sf)
        sf=[1 1];
    end
    I1=imresize(I1,sf(1));
    I2=imresize(I2,sf(2));
    offu=offu*sf(2);
    offv=offv*sf(2);
    T1=[sf(1) 0 0;0 sf(1) 0;0 0 1];
    T2=[sf(1) 0 0;0 sf(1) 0;0 0 1];
    H=T1*H/T2;
    
    % Initialize dimensions of image I1
    Su=size(I1,2); Sv=size(I1,1); channels=size(I1,3);
    % Initialize dimensions of image I2
    su=size(I2,2); sv=size(I2,1);
    
    % Transform those dimension to obtain the area in the image I1 where I2 is.
    [un vn]=im2imTransform([1 su su 1]-offu,[1 1 sv sv]-offv,H);
    
    %Create a grid for the merged image
    [ug vg]=meshgrid(min([un 1]):max([un Su]),min([vn 1]):max([vn Sv]));
    
    % Initialize the image
    I=uint8(zeros(size(ug,1),size(ug,2),channels));
    
    % Obtain the coordinates of the merge image on the image I2
    [ug vg]=im2imTransform(ug(:),vg(:),inv(H));
    offun=round(1-min([un 1]));
    offvn=round(1-min([vn 1]));
    
    mI=size(I,1); nI=size(I,2);
    
    for j=1:channels
        % Obtain the intensity values of each channel for the transformed image
        Ir=interp2(double(I2(:,:,j)),ug+offu,vg+offv,'nearest');
        % Reshape to the size of the image
        I(1:mI,1:nI,j)=reshape(uint8(Ir),mI,nI);
        % Merge both images
        I(1+offvn:Sv+offvn,1+offun:Su+offun,j)=I1(:,:,j);
    end
    
catch e
    disp(e.message)
end

