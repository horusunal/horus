function  data  = load_fusion(conn, type, station, timestamp)

%LOAD_FUSION this function is used for querying a fusion.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   type: It's the type of images to be merged. The values you can
%         take: rectified and oblique.
%   station: station name.
%   timestamp: Value of the timestamp for the search.
%
%   Output:
%   data: cell array with these elements:
%         {fusion id, timestamp, ...}
%         From the third element, each four parameters are repeated the name of
%         the matrix, the ids of the matrix and the values.
%
%   Example:
%   data  = load_fusion(conn, 'oblique', 'CARTAGENA', 734229.4583333334);
%
%   See also LOAD_ALLIMAGE, LOAD_NEARESTIMAGE, LOAD_IMAGECAM,
%   LOAD_CALIBRATION, LOAD_roi

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/22 10:20 $

try
    station = upper(station);
    data = [];
    EPS = 1 / (24 * 60 * 60);
    
    % query in the database
    
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    try
        query = ['SELECT DISTINCT f.id as idfusion, '...
            'fm.id as idfusionparameter, timestamp, name, '...
            'idrow, idcol, value '...
            'FROM fusion_' lower(station) ' f '...
            'JOIN fusionparameter_' lower(station) ' fm '...
            'JOIN fusionvalue_' lower(station) ' fv '...
            'JOIN camerabyfusion_' lower(station) ' cxf '...
            'WHERE f.id = fm.idfusion '...
            'AND fm.id = fv.idmatrix '...
            'AND f.id = cxf.idfusion '...
            'AND cxf.station LIKE "' station '" '...
            'AND f.id = '...
            '(SELECT id '...
            'FROM fusion_' lower(station) ' '...
            'WHERE type LIKE "' type '" '...
            'AND timestamp <= ' num2str(timestamp + EPS,17)...
            ' ORDER BY timestamp DESC LIMIT 0,1)'];
        
        cursor = exec(conn, query);
        cursor = fetch(cursor);
        if strcmpi(cursor.Data{1,1}, 'No Data') || isfloat(cursor.Data)
            data = [];
            return;
        end
        fusion = get(cursor, 'Data'); % Organizar los datos
        data = cell(0);
        [ids pos1 pos2 ] = unique(cell2mat(fusion(:, 2)), 'rows','first');
        valuematrix=cell2mat(fusion(:,5:7));
        data{1} = cell2mat(fusion(1,1));
        data{2} = cell2mat(fusion(1,3));
        for i=1:size(ids, 1)
            
            posi = pos1(i);
            posf = size(fusion, 1);
            if i < size(ids, 1)
                posf = pos1(i + 1) - 1;
            end
            row = cell2mat(fusion(posi:posf, 5));
            col = cell2mat(fusion(posi:posf, 6));
            matrix = zeros(max(row),max(col) );
            
            for j = posi:posf
                matrix (valuematrix(j,1),valuematrix(j,2))= valuematrix(j,3);
            end
            data{end+1}=fusion(j,4);
            data{end+1}=matrix;
        end
        
    catch e
        disp([dberror('select') e.message]);
    end
    
catch e
    disp(e.message)
end

end