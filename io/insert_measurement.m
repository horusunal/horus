function [varargout] = insert_measurement(conn, type, ...
    matrix, datatype, station, varargin)

%INSERT_MEASUREMENT this function is used for inserting a new measurement
%in the database.
%
%   Input:
%   conn: is the object that contains the database connection.
%   type: Is the id which represents the type of measurement.
%   matrix: This is a matrix or vector with the data, depending
%           on the type of data. If datatype is "series" this should be a
%           matrix nx2, the first column contains the timestamp of
%           measurement and the second contains the value; if datatype is
%           "matrix"
%           should be a matrix nx3, where first col contains the X
%           values, second col contains the Y values and third col contains
%           the Z values.
%   datatype: This is the type of data: "series" or "matrix".
%   station: station where is the sensor.
%   varargin: This can contain the following information.
%       timestamp: This must be entered if the datatype is "matrix".
%                  This is the timestamp of the measurement.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the insertion was
%   successful, 1 otherwise.
%
%   Example:
%   insert_measurement(conn, 1, [734232 2.3;734233 4;734232 5.8] , 'series');
%   Or
%   insert_measurement(conn, 1, matrix,...
%   'matrix','timestamp',734232);
%   Where matrix is equal:
%   matrix(:,:,1)=[0.00311931944468887,1.10717967010006;0.00311931944468887,1.10717967010006];
%   matrix(:,:,2)=[0,0;23.9999997650059,23.9999997650059];
%   matrix(:,:,3)=[0.00173010380622837,0.0108888408304498;0.00181660899653979,0.00768814878892734];
%
%   See also INSERT_IMAGETYPE, INSERT_MERGED,
%   INSERT_RECTIFIED, INSERT_roi, INSERT_STATION, INSERT_TIMESTACK

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/11/3 15:50 $

% connection to the database

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
    
    if strcmp(datatype,'series')
        
        %   name of the parameter of te table
        colnamesmeasurement = {'type','timestamp','station'};
        colnamesmeasurementvalue = {'idmeasurement','station','idcol','idrow','iddepth','value'};
        
        %   data to insert
        for i=1:size(matrix,1)
            exdatameasurement ={type,matrix(i,1),station};
            try
                fastinsert(conn, ['measurement_' lower(station)],colnamesmeasurement,exdatameasurement);
                if nargout==1
                    varargout(1)={0};
                end
            catch e
                disp([dberror('insert') e.message]);
                if nargout==1
                    varargout(1)={1};
                    return;
                end
            end
            idmeasurement = lastid(conn);
            if idmeasurement==-1
                return
            end
            exdatameasurementvalue ={idmeasurement,station,1,1,1,matrix(i,2)};
            
            try
                fastinsert(conn, ['measurementvalue_' lower(station)],colnamesmeasurementvalue,exdatameasurementvalue);
                if nargout==1
                    varargout(1)={0};
                end
            catch e
                disp([dberror('insert') e.message]);
                if nargout==1
                    varargout(1)={1};
                end
            end
        end
    elseif strcmp(datatype,'matrix')
        
        colnamesmeasurement = {'type','timestamp','station'};
        colnamesmeasurementvalue = {'idmeasurement','station','idcol','idrow','iddepth','value'};
        noptargs = numel(varargin);
        if mod(noptargs, 2) == 1
            disp(dberror('args'));
            return;
        end
        
        for i = 1:2:noptargs
            arg = varargin{i};
            value = varargin{i+1};
            timestamp = value;
        end
        
        exdatameasurement ={type,timestamp,station};
        try
            fastinsert(conn, ['measurement_' lower(station)],colnamesmeasurement,exdatameasurement);
            if nargout==1
                varargout(1)={0};
            end
        catch e
            disp([dberror('insert') e.message]);
            if nargout==1
                varargout(1)={1};
            end
        end
        idmeasurement = lastid(conn);
        if idmeasurement==-1
            return
        end
        for i=1:size(matrix,1)
            
            for j=1:size(matrix,2)
                % Insert data
                exdatameasurementvalue ={idmeasurement,station,j,i,1,matrix(i,j)};
                
                try
                    fastinsert(conn, ['measurementvalue_' lower(station)],colnamesmeasurementvalue,exdatameasurementvalue);
                    if nargout==1
                        varargout(1)={0};
                    end
                catch e
                    disp([dberror('insert') e.message]);
                    if nargout==1
                        varargout(1)={1};
                    end
                end
            end
        end
    end
    
catch e
    disp(e.message)
end
