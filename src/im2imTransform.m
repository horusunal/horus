function [un vn]=im2imTransform(u,v,H)

% [un vn]=im2imTransform(u,v,H)
% This function transform the image coordinates (u,v) using the
% transformation H, which can be an affine or a projective transformation.
% It follows the ideas in Perez (2009) and Montoliu & Pla (2009) to obtain
% the new coordinates (un,vn) such that [wun;wvn;w]=H*[u;v;1].
% u and v are vectors of the same length.
% Inputs:
%   u: coordinates in direction u
%   v: coordinates in direction v
%   H: transformation matrix H
% Outputs:
%   un: transformed coordinates in direction u
%   vn: transformed coordinates in direction v
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
    % using vector forms, it is easier and faster to obtain the new coordinates
    uv=H*[reshape(u,1,numel(u));reshape(v,1,numel(u));ones(1,numel(u))];
    
    un=reshape(uv(1,:)./uv(3,:),size(u));
    
    vn=reshape(uv(2,:)./uv(3,:),size(v));
    
catch e
    disp(e.message)
end