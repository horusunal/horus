function time = getTimeUTC()

%GETTIMEUTC()   Get system time in Coordinated Universal Time (UTC)
%
% Output:
%   time: UTC system time in DATENUM format.

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/12/22 16:06 $

try
    % Java stuff
    tObj = java.util.GregorianCalendar();
    
    % get reference time
    refTime = datenum('1-jan-1970 00:00:00');
    % how much later than reference time is input?
    offset = tObj.getTimeInMillis() / (1000 * 24 * 60 * 60);
    
    % add and return
    time = refTime + offset;
    
catch e
    disp(e.message)
end