function [varargout] = update_roicoordinate(conn, station, idroi, idcoord, varargin)

%UPDATE_roiCOORDINATE   Update a tuple in the table roicoordinate
%   UPDATE_roiCOORDINATE(conn, station, idroi, idcoord, varargin) updates the tuple identified by
%   'idroi' and 'idcoord'. Any attribute can be updated and they are given by varargin.
%   The attributes are given as pairs {'AttributeName', 'AttributeValue'}.
%
%   Input:
%   conn: Database connection which must have been previously created.
%	station: is the name of the station.
%   idroi: ID of the roi.
%   idcoord: ID of the coordenate of the roi.
%   varargin: The attributes are given as pairs {'AttributeName', 'AttributeValue'}.
%
%   Output:
%   varargout: The output argument might or might not be present, if it
%   is, means the status of the transaction. 0 if the update was
%   successful, 1 otherwise.
%
%   Example:
%       status = update_roicoordinate(conn, 'CARTAGENA', 30,[2],'u',[500]);
%

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/22 10:00 $

try
    station = upper(station);
    if nargout==1
        varargout(1)={1};
    end
    
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    try
        
        % Data for updating a calibration in the database
        colnames = cell(0);
        extdata = cell(0);
        
        if ~isvalidoption('roicoordinate', varargin{:})
            disp(dberror('args'));
            return;
        end
        
        noptargs = numel(varargin);
        
        for i = 1:2:noptargs
            arg = varargin{i};
            value = varargin{i+1};
            
            colnames{end+1} = arg;
            extdata{end+1} = value;
        end
        size_new_u= size(cell2mat(extdata(1)),1);
        if size(extdata,2)>1
            if size(cell2mat(extdata(1)),1)==size(cell2mat(extdata(2)),1)
                query = ['SELECT u, v '...
                    'FROM roicoordinate_' station ' '...
                    'WHERE idroi LIKE "' idroi '"'];
                cursor = exec(conn, query);
                cursor = fetch(cursor);
                if strcmpi(cursor.Data{1,1}, 'No Data') || isfloat(cursor.Data)
                    data = [];
                else
                    data = get(cursor, 'Data');
                end
                
                
                size_old_u=size(data,1);
                if size_new_u < size_old_u
                    for i = 1:size_new_u
                        extdata2 = cell(0);
                        whereclause = ['WHERE idroi LIKE "' idroi '" AND idcoord = ' num2str(idcoord(i))];
                        extdata2{1}=extdata{1}(i);
                        extdata2{2}=extdata{2}(i);
                        update(conn, ['roicoordinate_' station], colnames, extdata2, whereclause);
                        if nargout==1
                            varargout(1)={0};
                        end
                    end
                    for i=size_new_u+1:size_old_u
                        
                        query = ['DELETE FROM roicoordinate_' station ' WHERE idroi LIKE "' idroi '" AND idcoord = ' num2str(i)];
                        exec(conn, query);
                    end
                elseif size_new_u > size_old_u
                    for i = 1:size_old_u
                        extdata2 = cell(0);
                        whereclause = ['WHERE idroi LIKE "' idroi '" AND idcoord = ' num2str(idcoord(i))];
                        extdata2{1}=extdata{1}(i);
                        extdata2{2}=extdata{2}(i);
                        update(conn, ['roicoordinate_' station], colnames, extdata2, whereclause);
                        if nargout==1
                            varargout(1)={0};
                        end
                    end
                    colnames_roicoor = {'idroi','idcoord',char(colnames(1)),char(colnames(2))};
                    for i=size_old_u+1:size_new_u
                        
                        data_roicoor = {idroi, i, extdata{1}(i),extdata{2}(i)};
                        fastinsert(conn, ['roicoordinate_' station],colnames_roicoor,data_roicoor);
                    end
                else
                    for i = 1:size_new_u
                        extdata2 = cell(0);
                        whereclause = ['WHERE idroi LIKE "' idroi '" AND idcoord = ' num2str(idcoord(i))];
                        extdata2{1}=extdata{1}(i);
                        extdata2{2}=extdata{2}(i);
                        update(conn, ['roicoordinate_' station], colnames, extdata2, whereclause);
                        if nargout==1
                            varargout(1)={0};
                        end
                    end
                    
                end
            end
        else
            for i = 1:size_new_u
                extdata2 = cell(0);
                whereclause = ['WHERE idroi LIKE "' idroi '" AND idcoord = ' num2str(idcoord(i))];
                extdata2{1}=extdata{1}(i);
                extdata2{2}=extdata{2}(i);
                update(conn, ['roicoordinate_' station], colnames, extdata2, whereclause);
                if nargout==1
                    varargout(1)={0};
                end
            end
        end
        
    catch e
        disp([dberror('update') e.message]);
    end
    
catch e
    disp(e.message)
end