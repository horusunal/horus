function [H]=homography(uv_base,uv_affine)

try
    uv1=uv_affine;
    uv2=uv_base;
    A=[];
    b=[];
    for i=1:size(uv1,1)
        A=[A;uv1(i,1) uv1(i,2) 0 0 1 0;0 0 uv1(i,1) uv1(i,2) 0 1];
        b=[b;uv2(i,1);uv2(i,2)];
    end
    V=A\b;
    H=[V(1:2)' V(5); V(3:4)' V(6);0 0 1];
    
catch e
    disp(e.message)
end