function createViews(conn, station)
%CREATEVIEWS   Creates views for every table in the database for a specific
%station.
%
% Input:
%   conn: Database connection object.
%   station: station name.
%
% Example:
%   createViews(conn, 'CARTAGENA')

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2012 HORUS
%   $Date: 2012/08/04 12:41 $

try
    station = lower(station);
    alias = load_station_alias(conn, station);
    
    viewimagetype = strcat('CREATE VIEW imagetype_', station, ' AS SELECT * FROM imagetype WHERE idtype LIKE "', alias, '%" WITH CHECK OPTION');
    viewtimestack = strcat('CREATE VIEW timestack_', station, ' AS SELECT * FROM timestack WHERE station = "', station, '" WITH CHECK OPTION');
    viewsensor = strcat('CREATE VIEW sensor_', station, ' AS SELECT * FROM sensor WHERE station = "', station, '" WITH CHECK OPTION');
    viewcamera = strcat('CREATE VIEW camera_', station, ' AS SELECT * FROM camera WHERE station = "', station, '" WITH CHECK OPTION');
    % viewRectimage = strcat('CREATE VIEW rectifiedimage_', station, ' AS SELECT * FROM rectifiedimage WHERE calibration IN (SELECT idcalibration FROM calibration WHERE station = "', station, '") WITH CHECK OPTION');
    viewRectimage = strcat('CREATE VIEW rectifiedimage_', station, ' AS SELECT * FROM rectifiedimage WHERE filename LIKE "%.', station, '.%" WITH CHECK OPTION');
    % viewmergedimage = strcat('CREATE VIEW mergedimage_', station, ' AS SELECT * FROM mergedimage WHERE idfusion IN (SELECT id FROM fusion WHERE id IN (SELECT idfusion FROM camerabyfusion WHERE station = "', station, '")) WITH CHECK OPTION');
    viewmergedimage = strcat('CREATE VIEW mergedimage_', station, ' AS SELECT * FROM mergedimage WHERE filename LIKE "%.', station, '.%" WITH CHECK OPTION');
    viewobliqueimage = strcat('CREATE VIEW obliqueimage_', station, ' AS SELECT * FROM obliqueimage WHERE station = "', station, '" WITH CHECK OPTION');
    % viewimage = strcat('CREATE VIEW image_', station, ' AS (SELECT filename, type, timestamp, ismini, path FROM image NATURAL JOIN rectifiedimage_', station, ') UNION (SELECT filename, type, timestamp, ismini, path FROM image NATURAL JOIN mergedimage_', station, ') UNION (SELECT filename, type, timestamp, ismini, path FROM image NATURAL JOIN obliqueimage_', station, ')');
    viewimage = strcat('CREATE VIEW image_', station, ' AS SELECT * FROM image WHERE filename LIKE "%.', station, '.%" WITH CHECK OPTION');
    % viewfusion = strcat('CREATE VIEW fusion_', station, ' AS SELECT * FROM fusion WHERE id IN (SELECT idfusion FROM camerabyfusion WHERE station = "', station, '") WITH CHECK OPTION');
    viewfusion = strcat('CREATE VIEW fusion_', station, ' AS SELECT * FROM fusion WHERE id LIKE "', alias, '%" WITH CHECK OPTION');
    % viewfusionParam = strcat('CREATE VIEW fusionparameter_', station, ' AS SELECT * FROM fusionparameter WHERE idfusion IN (SELECT id FROM fusion WHERE id IN (SELECT idfusion FROM camerabyfusion WHERE station = "', station, '")) WITH CHECK OPTION');
    viewfusionParam = strcat('CREATE VIEW fusionparameter_', station, ' AS SELECT * FROM fusionparameter WHERE idfusion LIKE "', alias, '%" WITH CHECK OPTION');
    viewcommonpoint = strcat('CREATE VIEW commonpoint_', station, ' AS SELECT * FROM commonpoint WHERE idfusion LIKE "', alias, '%" WITH CHECK OPTION');
    % viewfusionvalue = strcat('CREATE VIEW fusionvalue_', station, ' AS SELECT * FROM fusionvalue WHERE idmatrix IN (SELECT id FROM fusionparameter WHERE idfusion IN (SELECT id FROM fusion WHERE id IN (SELECT idfusion FROM camerabyfusion WHERE station = "', station, '"))) WITH CHECK OPTION');
    viewfusionvalue = strcat('CREATE VIEW fusionvalue_', station, ' AS SELECT * FROM fusionvalue WHERE idmatrix LIKE "', alias, '%" WITH CHECK OPTION');
    viewCamByfusion = strcat('CREATE VIEW camerabyfusion_', station, ' AS SELECT * FROM camerabyfusion WHERE station = "', station, '" WITH CHECK OPTION');
    viewcalibration = strcat('CREATE VIEW calibration_', station, ' AS SELECT * FROM calibration WHERE station = "', station, '" WITH CHECK OPTION');
    % viewcalibrationParam = strcat('CREATE VIEW calibrationparameter_', station, ' AS SELECT * FROM calibrationparameter WHERE calibration IN (SELECT idcalibration FROM calibration WHERE station = "', station, '") WITH CHECK OPTION');
    viewcalibrationParam = strcat('CREATE VIEW calibrationparameter_', station, ' AS SELECT * FROM calibrationparameter WHERE id LIKE "', alias, '%" WITH CHECK OPTION');
    % viewcalibrationvalue = strcat('CREATE VIEW calibrationvalue_', station, ' AS SELECT * FROM calibrationvalue WHERE idparam IN (SELECT id FROM calibrationparameter WHERE calibration IN (SELECT idcalibration FROM calibration WHERE station = "', station, '")) WITH CHECK OPTION');
    viewcalibrationvalue = strcat('CREATE VIEW calibrationvalue_', station, ' AS SELECT * FROM calibrationvalue WHERE idparam LIKE "', alias, '%" WITH CHECK OPTION');
    % viewroi = strcat('CREATE VIEW roi_', station, ' AS SELECT * FROM roi WHERE idcalibration IN (SELECT idcalibration FROM calibration WHERE station = "', station, '") WITH CHECK OPTION');
    viewroi = strcat('CREATE VIEW roi_', station, ' AS SELECT * FROM roi WHERE idroi LIKE "', alias, '%" WITH CHECK OPTION');
    % viewroicoordinate = strcat('CREATE VIEW roicoordinate_', station, ' AS SELECT * FROM roicoordinate WHERE idroi IN (SELECT idroi FROM roi WHERE idcalibration IN (SELECT idcalibration FROM calibration WHERE station = "', station, '")) WITH CHECK OPTION');
    viewroicoordinate = strcat('CREATE VIEW roicoordinate_', station, ' AS SELECT * FROM roicoordinate WHERE idroi LIKE "', alias, '%" WITH CHECK OPTION');
    viewgcp = strcat('CREATE VIEW gcp_', station, ' AS SELECT * FROM gcp WHERE station = "', station, '" WITH CHECK OPTION');
    viewpickedgcp = strcat('CREATE VIEW pickedgcp_', station, ' AS SELECT * FROM pickedgcp WHERE station = "', station, '" WITH CHECK OPTION');
    % viewstation = strcat('CREATE VIEW station_', station, ' AS SELECT * FROM station WHERE name = "', station, '" WITH CHECK OPTION');
    viewCapture = strcat('CREATE VIEW automaticparams_', station, ' AS SELECT * FROM automaticparams WHERE station = "', station, '" WITH CHECK OPTION');
    viewmeasurement = strcat('CREATE VIEW measurement_', station, ' AS SELECT * FROM measurement WHERE station = "', station, '" WITH CHECK OPTION');
    viewmeasurementtype = strcat('CREATE VIEW measurementtype_', station, ' AS SELECT * FROM measurementtype WHERE station = "', station, '" WITH CHECK OPTION');
    viewmeasurementvalue = strcat('CREATE VIEW measurementvalue_', station, ' AS SELECT * FROM measurementvalue WHERE station = "', station, '" WITH CHECK OPTION');
    
    
    %reboot connection to the database if necessary
    [conn status] = renew_connection_db(conn);
    
    if status == 1
        return
    end
    
    try
        exec(conn, viewimagetype);
        exec(conn, viewtimestack);
        exec(conn, viewsensor);
        exec(conn, viewcamera);
        exec(conn, viewRectimage);
        exec(conn, viewmergedimage);
        exec(conn, viewobliqueimage);
        exec(conn, viewimage);
        exec(conn, viewfusion);
        exec(conn, viewfusionParam);
        exec(conn, viewcommonpoint);
        exec(conn, viewfusionvalue);
        exec(conn, viewCamByfusion);
        exec(conn, viewcalibration);
        exec(conn, viewcalibrationParam);
        exec(conn, viewcalibrationvalue);
        exec(conn, viewroi);
        exec(conn, viewroicoordinate);
        exec(conn, viewgcp);
        exec(conn, viewpickedgcp);
        %     exec(conn, viewstation);
        exec(conn, viewCapture);
        exec(conn, viewmeasurement);
        exec(conn, viewmeasurementtype);
        exec(conn, viewmeasurementvalue);
    catch e
        disp(e.message)
    end
    
catch e
    disp(e.message)
end