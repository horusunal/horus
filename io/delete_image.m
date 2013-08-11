function  [varargout] = delete_image(conn, station,camera,type,ismin,inittime,finaltime)

%DELETE_IMAGE this function is used for deleting all images in a given
%time interval, type, camera and station.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: station where the images are to be removed.
%   camera: Cell array with the name of the cameras.
%   type: Cell array with the image type names.
%   ismin: true if the image is a thumbnail, false otherwise.
%   inittime: Initial time for the deletion.
%   finaltime: Final time for the deletion.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the deletion was
%   successful, 1 otherwise.
%
%   Example:
%   status = delete_image(conn,'CARTAGENA',{'C1','C2'},{'snap', 'timex'},0,734229, 734230)
%
%   See also DELETE_ALL_gcp, DELETE_ALL_IMAGE_STATION, DELETE_CAMERA, DELETE_gcp,
%       DELETE_MEASUREMENTTYPE, DELETE_roi, DELETE_SENSOR, DELETE_STATION

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/11/1 7:45 $

try
    station = upper(station);
    if nargout==1
        varargout(1)={1};
    end
    % query in the database
    
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    try
        for i=1:length(camera)
            for j=1:length(type)
                query = ['DELETE image_' station ', obliqueimage_' station ' FROM image_' station ' NATURAL JOIN obliqueimage_' station ' '...
                    'WHERE station LIKE "' station '" AND type IN ( '...
                    'SELECT idtype FROM imagetype_' station ' WHERE name LIKE ("' char(type(j)) '") )' ...
                    ' AND camera LIKE "' char(camera(i)) '" AND ismini =' num2str(ismin) ' AND timestamp BETWEEN ' ...
                    num2str(inittime+ 1/(24*60*60),17) ' AND ' num2str(finaltime+ 1/(24*60*60),17)];
                cursor = exec(conn, query);
                if nargout==1
                    if isfloat(cursor.Message)
                        varargout(1)={0};
                    end
                end
            end
        end
    catch e
        varargout(1)={1};
        disp([dberror('delete') e.message]);
    end
    
catch e
    disp(e.message)
end

end