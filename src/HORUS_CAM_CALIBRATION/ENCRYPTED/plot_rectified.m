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
