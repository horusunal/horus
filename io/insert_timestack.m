function [varargout] = insert_timestack(conn, filename, camera, station, inittime, path, fps, numFrames )

%INSERT_TIMESTACK this function is used for inserting a new timestack in
%the database.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   filename: timestack filename.
%   camera: camera that generated the timestack.
%   station: station where the timestack was captured.
%   inittime: Start time of capture in the format of the MATLAB
%             function DATENUM.
%   path: Location of timestack file.
%   fps: Frequency or frame rate in Hz. It is the number of images captured
%        per second.
%   numFrames: Number of frames captured at the given frequency.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the insertion was
%   successful, 1 otherwise.
%
%   Example:
%   insert_timestack(conn, '11.03.24.12.00.00.GMT.CARTAGENA.C2.STACK.615.0.20X760.HORUS.jpg', 'C2', 'CARTAGENA', 734688.549, '/home/horus/stacks/', 2, 1200)
%
%   See also INSERT_IMAGETYPE, INSERT_MERGED, INSERT_OBLIQUE,
%   INSERT_RECTIFIED, INSERT_roi, INSERT_STATION

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/21 11:20 $

try
    station = upper(station);
    if nargout==1
        varargout(1)={1};
    end
    
    % Insert in the database
    
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    %   name of the parameter of te table
    colnames_timestack={'filename', 'camera', 'station', 'inittime', 'path', 'fps', 'numFrames'};
    %   data to insert
    data_timestack = {filename, camera, station, inittime, path, fps, numFrames};
    try
        fastinsert(conn, ['timestack_' lower(station)],colnames_timestack,data_timestack);
        if nargout==1
            varargout(1)={0};
        end
    catch e
        disp([dberror('insert') e.message]);
    end
    
catch e
    disp(e.message)
end

end