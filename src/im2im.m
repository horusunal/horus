function H=im2im(u1,v1,u2,v2,type)

% H=im2im(u1,v1,u2,v2,type)
% This function estimates the transformation H from image coordinates in
% the image 2 to the image coordinates in image 1 using affine or
% projective transformations. It follows the ideas in Perez (2009) and
% Montoliu & Pla (2009) to estimate the transformation H.
% Inputs:
%   u1: coordinates in direction u on the image 1
%   v1: coordinates in direction v on the image 1
%   u2: coordinates in direction u on the image 2
%   v2: coordinates in direction v on the image 2
%   type: transformation type (1) Affine or (2) projective.
% Outputs:
%   H: transformation matrix H, such that [wu1;wv1;w]=H*[u2;v2;1]
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
    %Initialize H
    H=[];
    % Check if there are enough points
    if length(u1)<3
        f = errordlg('You need at least 3 points', 'Error', 'modal');
        return
    elseif type==2 && length(u1)<4 % The projective transformation needs at least 4 ponts
        f = errordlg({'You need at least 4 points for',...
            'the projective transformation'}, 'Error', 'modal');
        return
    end
    
    %Initialize the matrices used
    A=[];
    B=[];
    switch type
        case 1 %Affine transformation
            for i=1:length(u1)
                A=[A;u2(i) v2(i) 1 0 0 0;0 0 0 u2(i) v2(i) 1];
                B=[B;u1(i);v1(i)];
            end
            h=A\B;
            H=[h(1:3)';h(4:6)';0 0 1];
        case 2 %Projective transformation
            for i=1:length(u1)
                A=[A;u2(i) v2(i) 1 0 0 0 -u1(i)*u2(i) -v2(i)*u1(i);...
                    0 0 0 u2(i) v2(i) 1 -v1(i)*u2(i) -v2(i)*v1(i)];
                B=[B;u1(i);v1(i)];
            end
            h=A\B;
            H=[h(1:3)';h(4:6)';h(7:8)' 1];
    end
    
catch e
    disp(e.message)
end