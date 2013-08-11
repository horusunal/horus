function flag = isvalidoption(tablename, varargin)

%ISVALIDOPTION   Determines whether a set of attributes are contained
%within table 'tablename'.
%   flag = ISVALIDOPTION(tablename) returns a boolean value. If all the
%   attributes included in 'varargin' correspond to the table 'tablename',
%   returns 1, otherwise returns 0. Every attributes is represented
%   as a pair {'AttributeName', 'AttributeValue'}, where 'AttributeName' is
%   the name of the attribute and 'AttributeValue' is the value in the
%   corresponding format or data type. The available tablenames are the
%   following:
%
%      'image', 'imagetype', 'rectifiedimage', 'mergedimage',
%      'obliqueimage', 'fusion', 'camerabyfusion', 'fusionparameter',
%      'fusionvalue', 'camera', 'station', 'calibration', 'timestack',
%      'roi', 'roicoordinate', 'calibrationparameter', 'calibrationvalue',
%      'gcp', 'pickedgcp', 'sensor', 'measurement', 'measurementtype',
%      'measurementvalue', 'commonpoint' and 'automaticparams'.
%
%   Output:
%   flag: is the boolean value as explained before.
%
%   Example:
%   flag = isvalidoption('image', 'type',2)
%
%   See also VALIDOPTIONS.

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/21 16:01 $

try
    
    % Valid options for entity tablename
    valid = validoptions(tablename);
    noptargs = numel(varargin);
    flag = 1;
    
    % Optional arguments go in pairs
    if noptargs == 0 || mod(noptargs, 2) == 1
        flag = 0;
        return;
    end
    
    for i = 1:2:noptargs
        arg = varargin{i};
        
        if ~strcmp(arg, valid)
            flag = 0;
            return;
        end
    end
    
catch e
    disp(e.message)
end