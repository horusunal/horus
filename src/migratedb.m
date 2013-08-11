function migratedb(location)
%MIGRATEDB   Migrates old MAT files continaing HORUS information, to the
%new MySQL database
%
% Input:
%   location: Path where the MAT files are located.

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2012 HORUS
%   $Date: 2012/08/04 12:10 $
% 
try
    
    try
        conn = connection_db();
    catch e
        disp(e.message)
    end
    
    mapcalibration = cell(0);
    
    S = dir(fullfile(location, '*.mat'));
    
    for i = 1:numel(S)
        load(fullfile(location, S(i).name));
        
        if regexp(S(i).name, 'HORUS_DB.mat')
            disp(S(i).name)
            for k = 1:numel(Sitios)
                name = Sitios(k).sitio;
                elevation = str2double(Sitios(k).elev);
                if isnan(elevation)
                    elevation = 0;
                end
                lat = str2double(Sitios(k).lat);
                if isnan(lat)
                    lat = 0;
                end
                lon = str2double(Sitios(k).lon);
                if isnan(lon)
                    lon = 0;
                end
                country = Sitios(k).pais;
                state = Sitios(k).depto;
                city = Sitios(k).ciudad;
                responsible = Sitios(k).propietario;
                alias = name(1:5);
                insert_station(conn, name,alias, elevation, lat, lon, country, ...
                    state, city, 'responsible', responsible);
                createViews(conn, name);
            end
        end
    end
    
    for i = 1:numel(S)
        load(fullfile(location, S(i).name));
        
        if regexp(S(i).name, 'HorusDB.Camara.*.mat')
            disp(S(i).name)
            parts = regexp(S(i).name, '\.', 'split');
            station = upper(parts{3});
            
            for k = 1:numel(Camara)
                insert_camera(conn, Camara(k).identificar, station, ...
                    Camara(k).modelo, Camara(k).tamanoX, Camara(k).tamanoY);
            end
        end
    end
    
    for i = 1:numel(S)
        load(fullfile(location, S(i).name));
        if regexp(S(i).name, 'HorusDB.GCP.*.mat')
            disp(S(i).name)
            parts = regexp(S(i).name, '\.', 'split');
            station = upper(parts{3});
            
            for k = 1:numel(Gcp)
                insert_gcp(conn, Gcp(k).numero, station, Gcp(k).nombre,...
                    Gcp(k).x, Gcp(k).y, Gcp(k).z);
            end
        end
    end
    
    for i = 1:numel(S)
        load(fullfile(location, S(i).name));
        if regexp(S(i).name, 'HorusDB.Geometria.*.mat')
            disp(S(i).name)
            parts = regexp(S(i).name, '\.', 'split');
            station = upper(parts{3});
            
            paramnames = {'H', 'K', 'R', 'D', 't', 'fDu', 'fDv', 'u0', 'v0',...
                'k1', 'k2', 'tao', 'sigma', 'phi', 'xc', 'yc', 'zc'};
            for k = 1:numel(geometria)
                
                parameters = cell(0);
                for j = 1:numel(paramnames)
                    name = paramnames{j};
                    if j <= 5
                        value = eval(['geometria(k).' name]);
                    else
                        value = eval(['geometria(k).P.' name]);
                    end
                    parameters{end + 1} = name;
                    parameters{end + 1} = value;
                end
                
                [status idcal] = insert_calibration(conn, geometria(k).cameraidentificar, ...
                    station, datenum(geometria(k).fechavalid), 0.5, ...
                    parameters, {'EMCuv', geometria(k).EMCuv, 'EMCxy', geometria(k).EMCxy, ...
                    'NCE', geometria(k).NCE});
                mapcalibration{k} = idcal;
            end
        end
    end
    
    for i = 1:numel(S)
        load(fullfile(location, S(i).name));
        if regexp(S(i).name, 'HorusDB.PanFusion.*.mat')
            disp(S(i).name)
            parts = regexp(S(i).name, '\.', 'split');
            station = upper(parts{3});
            
            for k = 1:numel(PanFusion)
                sequence = PanFusion(k).Camorder;
                
                parameters = cell(0);
                cameraSequence = cell(0);
                for j = 2:numel(sequence)
                    name = ['H' num2str(sequence(j - 1)) num2str(sequence(j))];
                    value = eval(['PanFusion(k).H.' name]);
                    parameters{end + 1} = name;
                    parameters{end + 1} = value;
                end
                
                for j = 1:numel(sequence)
                    cameraSequence{j} = ['C' num2str(sequence(j))];
                end
                
                insert_fusion(conn, station, PanFusion(k).date, 'oblique', ...
                    cameraSequence, parameters);
            end
        end
    end
    
    for i = 1:numel(S)
        load(fullfile(location, S(i).name));
        if regexp(S(i).name, 'HorusDB.RectFusion.*.mat')
            disp(S(i).name)
            parts = regexp(S(i).name, '\.', 'split');
            station = upper(parts{3});
            
            for k = 1:numel(RectFusion)
                sequence = RectFusion(k).Camorder;
                
                parameters = cell(0);
                cameraSequence = cell(0);
                for j = 2:numel(sequence)
                    name = ['H' num2str(sequence(j - 1)) num2str(sequence(j))];
                    value = eval(['RectFusion(k).H.' name]);
                    parameters{end + 1} = name;
                    parameters{end + 1} = value;
                end
                
                for j = 1:numel(sequence)
                    cameraSequence{j} = ['C' num2str(sequence(j))];
                end
                
                insert_fusion(conn, station, RectFusion(k).date, 'rectified', ...
                    cameraSequence, parameters);
            end
        end
    end
    
    for i = 1:numel(S)
        load(fullfile(location, S(i).name));
        if regexp(S(i).name, 'HorusDB.PickedGCP.*.mat')
            disp(S(i).name)
            parts = regexp(S(i).name, '\.', 'split');
            station = upper(parts{3});
            
            for k = 1:numel(PickedGCP)
                idcal = mapcalibration{PickedGCP(k).Geometria};
                
                for j = 1:size(PickedGCP(k).GCP, 2)
                    u = PickedGCP(k).GCP(j, 1);
                    v = PickedGCP(k).GCP(j, 2);
                    idgcp = PickedGCP(k).GCP(j, 3);
                    insert_pickedgcp(conn, idcal, idgcp, station, u, v);
                end
            end
        end
        
    end
    
    for i = 1:numel(S)
        load(fullfile(location, S(i).name));
        if regexp(S(i).name, 'HorusDB.RectFusion.*.mat')
            disp(S(i).name)
            parts = regexp(S(i).name, '\.', 'split');
            station = upper(parts{3});
            
            for k = 1:numel(RectFusion)
                sequence = RectFusion(k).Camorder;
                timestamp = RectFusion(k).date;
                
                for j = 1:numel(sequence)
                    camera = ['C' num2str(sequence(j))];
                    u = eval(['RectFusion(k).UV.u' num2str(sequence(j))]);
                    v = eval(['RectFusion(k).UV.v' num2str(sequence(j))]);
                    data  = load_idcalibration(conn, station, camera, timestamp);
                    
                    if ~isempty(data)
                        idcal = data{1};
                        
                        insert_roi(conn, station, 'rect', idcal, timestamp, u, v);
                    end
                end
            end
        end
    end
    
catch e
    disp(e.message)
end