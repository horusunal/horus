function In=mergeIms(Imset,Hset)

% In=mergeIms(Imset,Hset)
% This function merges a set of images using a set of matrix
% transformations between pairs of images.  It follows the ideas in Perez
%  (2009) and Montoliu & Pla (2009) to merge the images.
%
% Inputs:
%   Imset: cell with the images to be merged in order from left to right.
%   For example, {image1, image2, image3, image4}.
%   Hset: cell with the transformation matrix between image pairs in order
%   from left to right. For example, {H12, H23, H34}.
% Outputs:
%   In: merged image
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
    In=[];
    % Check the number of images to merge
    nIm=length(Imset);
    
    % The number of transformations must be nIm-1
    if length(Hset)~=nIm-1
        f = errordlg({'The number of transformations does',...
            'not match with the number of images minus 1'}, 'Error', 'modal');
    else
        nH=nIm-1;
    end
    
    % Initialize the offset and the output image
    offu=0;
    offv=0;
    In=Imset{nIm};
    
    % The scale factor should be 1 at the beginning
    sf=[1 1];
    
    %identifier when scaling has been done
    ids=0;
    
    % The merging is done from right to left
    for k=nIm:-1:2
        if ids==1
            sf=[sf(1) 1];
        end
        try
            %try to merge the image k-1 with the merge of the images k:nIm
            [In offu offv]=mergeIm(Imset{k-1},In,Hset{k-1},offu,offv,sf);
        catch
            % If there is a memory error, change the scale factor to 0.75
            ids=1;
            sf=sf-0.50;
            try
                [In offu offv]=mergeIm(Imset{k-1},In,Hset{k-1},offu,offv,sf);
            catch
                % If there is a memory error again, change the scale factor to 0.5
                ids=1;
                sf=sf-0.25;
                try
                    [In offu offv]=mergeIm(Imset{k-1},In,Hset{k-1},offu,offv,sf);
                catch
                    % If there is a memory error again, tell the user.
                    f = errordlg({'The images are too large for',...
                        'this computer memory.'},...
                        'Memory error', 'modal');
                end
            end
        end
    end
    %Crop the black areas around the largest image
    [indi indj]=find(In(:,:,1));
    In=In(min(indi):max(indi),min(indj):max(indj),:);
    
catch e
    disp(e.message)
end