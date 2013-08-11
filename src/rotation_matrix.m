function R = rotation_matrix(phi, sigma, tao)
% ROTATION_MATRIX    Creates a rotation matrix based on angles phi, sigma
% and tao.

try
    
    p = deg2rad(phi);
    s = deg2rad(sigma);
    t = deg2rad(tao);
    
    r11 = cos(p) * cos(s) + sin(p) * cos(t) * sin(s);
    r12 = -sin(p) * cos(s) + cos(p) * cos(t) * sin(s);
    r13 = sin(t) * sin(s);
    r21 = -cos(p) * sin(s) + sin(p) * cos(t) * cos(s);
    r22 = sin(p) * sin(s) + cos(p) * cos(t) * cos(s);
    r23 = sin(t) * cos(s);
    r31 = sin(p) * sin(t);
    r32 = cos(p) * sin(t);
    r33 = -cos(t);
    
    R=-[r11 r12 r13;
        r21 r22 r23;
        r31 r32 r33];
    
catch e
    disp(e.message)
end