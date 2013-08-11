function [est, message] = initial_estimates_pinhole(station, camera, timestamp)

%INITIAL_ESTIMATES_PINHOLE   Calculate initial estimates for Pinhole.
%
% Input:
%   station: name of the station
%   camera:  id of the camera (e.g. 'C1')
%   timestamp: Time in the format of DATENUM
%
% Output:
%   est: Array of estimated (12 positions)
%   message: Error message

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/10/28 17:38 $

try
    
    % Empty initial estimates for Pinhole
    est = [];
    message = [];
    
    try
        conn = connection_db();
    catch e
        disp(e.message)
        return
    end
    
    cal = load_calibration(conn, station, camera, timestamp);
    
    if isempty(cal)
        message = 'No calibration was found in the database!';
        close(conn)
        return;
    end
    
    found = false;
    for i = 1:numel(cal)
        if strcmp(cal{i}, 'K')
            K = cal{i + 1};
            found = true;
        elseif strcmp(cal{i}, 'D')
            D = cal{i + 1};
        elseif strcmp(cal{i}, 'R')
            R = cal{i + 1};
        elseif strcmp(cal{i}, 't')
            t = cal{i + 1};
        end
    end
    
    if found
        est = [K(1,1) -K(2,2) K(1,3) K(2,3) D(1) D(2) rodrigues(R)' t'];
    end
    
    close(conn)
    
catch e
    disp(e.message)
end