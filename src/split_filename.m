function data = split_filename(filename)

%SPLIT_FILENAME   Split the image filename
%   SPLIT_FILENAME(filename) splits the 'filename' string using regular
%   expressions by '.'. The result is saved in the structure 'data' with
%   all the information.
%
%   Example:
%       filename =
%             '06.08.31.14.18.03.GMT.Magdale.C1.snap.1280X1022.HORUS.JPG';
%       data = split_filename(filename);
%
%   The 'data' structure has the following fields:
%       - year: Format YYYY
%       - month
%       - day
%       - hour
%       - min
%       - sec
%       - GMT: Format GMT[+/-N]
%       - station: Name of the station
%       - cam: Id of a camera
%       - imgtype: Image type (snap, timex, var)
%       - width: Image width
%       - height: Image height
%       - ext: File extension (e.g. jpg, png)

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/09/05 11:27 $

try
    
    % Split filename by '.'
    parts = regexp(filename, '\.', 'split');
    
    % Create structure
    data = struct('year',[], 'month',[], 'day',[], 'hour',[], 'min',[], ...
        'sec',[], 'GMT',[], 'station',[], 'cam',[], 'imgtype',[], ...
        'width',[], 'height',[], 'ext',[], 'ismini',[]);
    
    data.year = 2000 + str2double(parts{1});
    if data.year > year(now)
        data.year = data.year - 100;
    end
    data.month = str2double(parts{2});
    data.day = str2double(parts{3});
    data.hour = str2double(parts{4});
    data.min = str2double(parts{5});
    data.sec = str2double(parts{6});
    data.GMT = strtrim(parts{7});
    data.station = strtrim(parts{8});
    
    if  ~isempty(strfind(strtrim(parts{9}),'C'))
        data.cam = strtrim(parts{9});
        data.imgtype = strtrim(parts{10});
        data.ext = strtrim(parts{end});
        data.program = strtrim(parts{end-1});
        if isempty(strfind(filename,'MIN.'))
            data.ismini=0;
        else
            data.ismini=1;
        end
        if isempty(strfind(filename,'.RECT'))
            % Split image size by 'X'
            size = strtrim(parts{11});
            parts = regexp(size, '[Xx]', 'split');
            data.width = str2double(parts{1});
            data.height = str2double(parts{2});
        end
    elseif ~isempty(strfind(filename,'.PAN.')) || ~isempty(strfind(filename,'.RECT.'))
        data.imgtype = strtrim(parts{9});
        data.program = strtrim(parts{11});
        data.ext = strtrim(parts{end});
        data.ismini=0;
    elseif ~isempty(strfind(filename,'.PAM.')) || ~isempty(strfind(filename,'.RECM.'))
        data.imgtype = strtrim(parts{9});
        data.program = strtrim(parts{11});
        data.ext = strtrim(parts{end});
        data.ismini=1;
        
    end
    
catch e
    disp(e.message)
end

