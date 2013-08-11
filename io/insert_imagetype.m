function [varargout] = insert_imagetype(conn, name, station, varargin)

%INSERT_IMAGETYPE this function is used for inserting a tuple in the table
%imagetype
%
%   Input:
%   conn: Database connection which must have been previously created.
%   name: Type name. Only these values are allowed: snap, timex, var.
%   station: station name.
%   varargin: Description in words of the image type.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the insertion was
%   successful, 1 otherwise.
%
%   Example:
%   insert_imagetype(conn, 'snap', 'CARTAGENA');
%   Or
%   insert_imagetype(conn, 'timex', 'CARTAGENA', 'These are timex images.');
%
%   See also INSERT_MERGED, INSERT_OBLIQUE,
%   INSERT_RECTIFIED, INSERT_roi, INSERT_STATION, INSERT_TIMESTACK

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/21 9:00 $

try
    station = upper(station);
    % connection to the database,
    
    if nargout==1
        varargout(1)={1};
    end
    
    % Insert in the database
    
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    if nargin == 3
        %     name of the parameter of te table
        newid  = generate_autoinc(conn, ['imagetype_' station], 'idtype', station);
        colnames_imagetype = {'idtype', 'name'};
        %       data to insert
        data_imagetype = {newid, name};
        
    else
        
        newid  = generate_autoinc(conn, ['imagetype_' station], 'idtype', station);
        colnames_imagetype = {'idtype', 'name', 'description'};
        data_imagetype = {newid, name, char(varargin{1})};
        
    end
    try
        %       insert data to the table
        fastinsert(conn, ['imagetype_' station],colnames_imagetype,data_imagetype);
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

