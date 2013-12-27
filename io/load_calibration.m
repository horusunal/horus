function  data  = load_calibration(conn, station, camera, timestamp)

%LOAD_CALIBRATION this function is used for querying a calibration
%given a station, a camera and a timestamp.
%
%   Input:
%   conn: Database connection which must have been previously created.
%   station: station of the corresponding calibration.
%   camera: ID of the camera.
%   timestamp: Value of the timestamp for the search.
%
%   Output:
%   data: A cell array with these elements:
%         {calibration id, calibration parameters, timestamp, resolution, MSEuv, MSExy, NCE}
%
%   Example:
%   data  = load_calibration(conn, 'CARTAGENA', 'C1', 734229.4583333334);
%
%   See also LOAD_ALLIMAGE, LOAD_NEARESTIMAGE, LOAD_IMAGECAM, LOAD_FUSION,
%   LOAD_roi

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
%   $Date: 2011/07/22 10:40 $

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
        query = ['SELECT idcalibration, gp.id, '...
            'timestamp, resolution, EMCuv, EMCxy, NCE, name, idrow, idcol, value '...
            'FROM calibration_' station ' c '...
            'JOIN calibrationparameter_' station ' gp '...
            'JOIN calibrationvalue_' station ' pv '...
            'WHERE c.idcalibration = gp.calibration '...
            'AND gp.id = pv.idparam '...
            'AND c.idcalibration = '...
            '(SELECT idcalibration '...
            'FROM calibration_' station ' '...
            'WHERE timestamp <= ' num2str(timestamp + EPS,17) ' '...
            'AND station LIKE "' station '" '...
            'AND camera LIKE "' camera '" '...
            ' ORDER BY timestamp, idcalibration DESC LIMIT 0,1)'
            ];
        cursor = exec(conn, query);
        cursor = fetch(cursor);
        if strcmpi(cursor.Data{1,1}, 'No Data') || isfloat(cursor.Data)
            data = [];
            return;
        end
        calibration = get(cursor, 'Data');
        
        data = cell(0);
        [ids pos1 pos2 ] = unique(cell2mat(calibration(:, 2)), 'rows','first');
        valuematrix=cell2mat(calibration(:,9:11));
        data{1} = cell2mat(calibration(1,1));
        data{2} = cell2mat(calibration(1,3));
        data{3} = cell2mat(calibration(1,4));
        data{4} = cell2mat(calibration(1,5));
        data{5} = cell2mat(calibration(1,6));
        data{6} = cell2mat(calibration(1,7));
        for i=1:size(ids, 1)
            
            posi = pos1(i);
            posf = size(calibration, 1);
            if i < size(ids, 1)
                posf = pos1(i + 1) - 1;
            end
            row = cell2mat(calibration(posi:posf, 9));
            col = cell2mat(calibration(posi:posf, 10));
            matrix = zeros(max(row),max(col) );
            
            for j = posi:posf
                matrix (valuematrix(j,1),valuematrix(j,2))= valuematrix(j,3);
            end
            data{end+1}=calibration(posf,8);
            data{end+1}=matrix;
        end
    catch e
        disp([dberror('select') e.message]);
    end
    
catch e
    disp(e.message)
end

end