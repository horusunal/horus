function [u v rectimg]=rectify(img,H,K,D,roi,z,resolution,paint)
%
% [u v rectimg]=rectify(img,H,K,D,roi,z,resolution,paint)
% This function rectifies a given image using the Pinhole model matrix or
% the DLT of the camera. It does not take into account the distortion
% effects of the lenses. After defining the value of Z, the user needs to
% choose 4 points on the image that define the rectification area. The
% rectification process is carried out as presented in Pérez (2009) and
% Pérez et al (2011).
% Inputs:
%     img: Image to be rectified in a multidimensional array of Matlab as
%     obtained using the function imread of Matlab. The image can be
%     grayscale or RGB.
%     H: Pinhole matrix H=K[R t]  or DLT as presented in Pérez (2009) and
%     Pérez et al (2010).
%     K: 3x3 upper triangular matrix with the intrinsec parameters of the
%     camera model used to correct the lens distortion effect, if no
%     distortion is going to be corrected, matrix  K may be an empty array.
%     D: 1x2 matrix with the radial distortion parameters of the camera
%     model, [k1 k2]. This parameters are used to correct the distortion
%     effects in the image and, therefore, if there is no distortion to
%     correct then D might be an empty array.
%     roi: matrix nx2 (n>=3) with the coordinates (u,v) of the point that
%     define the polygon of the interest area.
%     z: value of the Z coordinate where the interest area is assumed to be
%     located. Depending of the units used for the GCPs its value may be
%     [mm], [cm] or [m].
%     resolution: Desired resolution of the resulting rectified image,
%     depending of the units used for the GCPs its value may be [mm/pix],
%     [cm/pix] or [m/pix].
%     paint: control parameter to plot the results. 1 to plot the
%     rectified image, 0 to rectify without plotting.
%  Outputs:
%     u: coordenadas U of the rectified area, used as input in the function
%     plot_resolution
%     v: coordenadas V of the rectified area, used as input in the function
%     plot_resolution
%     rectimg: Rectified image, can be displayed directly using imshow or
%     imagesc, but there are no grid lines to localize points in XY. If you
%     want to plot the rectified image with gridlines and coordinates
%     values, use the function plot_rectified.
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
