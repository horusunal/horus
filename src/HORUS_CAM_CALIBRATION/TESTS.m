%% Test calibration
clear all, close all, clc
load GCP.mat
[H K D R t P MSEuv MSExy NCError]=camera_cal(u,v,x,y,z,[],[1 1 1 1 0 0 1 1 1 1 1 1]);
est=[K(1,1) -K(2,2) K(1,3) K(2,3) 0 0 rodrigues(R)' t'];
[H K D R t P MSEuv MSExy NCError]=camera_cal(u,v,x,y,z,est,ones(1,12))

%% Correct distortion on the image
In=undistort_Image(K,D,'TestImage.jpg',1,1);

%% Rectify
I=imread('TestImage.jpg');
figure(1), imshow(I)
% select 4 points in the image
[u1 v1]=ginput(4);
[u2 v2 rectimg]=rectify(I,H,K,D,[u1 v1],0,1/10,1); %The selected resolution is 0.1 m/pixel

%% Resolution plot 
plot_resolution(H,K,D,u2,v2,rectimg,0)