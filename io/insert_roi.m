function [varargout] = insert_roi(conn, station, type,idcalibration,timestamp,u,v )

%INSERT_roi this function is used for inserting a new roi in the database.
%
%   Input:
%   conn: Database connection which must have been previously created.
%	station: is the name of the station.
%   type: It's the type of roi or type of application of a particular roi.
%         The values you can take are: fusion, rect, stack, user.
%   idcalibration: It is the ID of the calibration associated to the roi.
%   timestamp: Date on which the roi was created. This date is in the format of
%              the MATLAB function DATENUM.
%   u and v: The coordinate value in pixels of polygon.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the insertion was
%   successful, 1 otherwise.
%
%   Example:
%   insert_roi(conn,'CARTAGENA','rect','CRTG00010',733904.437500000,[-46.7740998388039;430.328583695565;1578.37546159132;559.875083399941],[169.798335263915;-11.7669467845833;276.700189311303;918.169409047055])
%
%   See also INSERT_IMAGETYPE, INSERT_MERGED, INSERT_OBLIQUE,
%   INSERT_RECTIFIED, INSERT_STATION, INSERT_TIMESTACK

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $ Date: 2011/07/21 10:40$

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
    
    newid  = generate_autoinc(conn, ['roi_' lower(station)], 'idroi', station);
    %   name of the parameter of te table
    colnames_roi = {'idroi', 'type','idcalibration','timestamp'};
    colnames_roicoor = {'idroi','idcoord','u','v'};
    %   data to insert
    data_roi = {newid, type,idcalibration,timestamp};
    
    if numel(u) ~= numel(v)
        
        disp([dberror('insert') 'u, v should be the same size']);
        return;
    end
    
    if ~strcmp(type,'fusion') && ~strcmp(type,'rect') && ~strcmp(type,'stack') && ~strcmp(type,'user')
        
        disp([dberror('insert') 'the type is invalid [fusion, rect, stack, user]']);
        return;
    end
    
    try
        fastinsert(conn, ['roi_' lower(station)],colnames_roi,data_roi);
        %     id=lastid(conn);
        %     if id ==-1
        %         return
        %     end
        
        for i=1:length(u)
            %           data to insert
            data_roicoor = {newid, i, u(i),v(i)};
            
            try
                fastinsert(conn, ['roicoordinate_' lower(station)],colnames_roicoor,data_roicoor);
                if nargout==1
                    varargout(1)={0};
                end
            catch e
                disp([dberror('insert') e.message]);
            end
        end
        
    catch e
        disp([dberror('insert') e.message]);
    end
    
catch e
    disp(e.message)
end

end