function create_auto_exec(param, station, varargin)

%CREATE_AUTO_EXEC  Compile automatic execs and create scripts for executing
%them.
%
%   Input:
%   param: Can be 'capture', 'transfer', 'sync' or 'process'.
%   station: Station name.
%   varargin: Optional arguments. For 'transfer': host name or IP address.
%                                 For 'process': Search step and search
%                                 error.
%             If the compilation is to be done on a UNIX system, the last
%             optional parameter should be the MCR root directory. It is
%             usually the MATLAB root (e.g. /usr/local/matlab/R2011b)
%
%   Examples:
%   create_auto_exec('capture', 'CARTAGENA')
%   create_auto_exec('transfer', 'CARTAGENA', '168.176.124.165')
%   create_auto_exec('process', 'CARTAGENA', 30, 5)
%   create_auto_exec('sync', 'CARTAGENA')

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2012 HORUS
%   $Date: 2012/07/16 10:20 $

try
    nargopt = numel(varargin);
    
    % Check arguments
    ok = true;
    if strcmpi(param, 'capture') && ispc && nargopt ~= 0
        ok = false;
    end
    if strcmpi(param, 'capture') && ~ispc && nargopt ~= 1
        ok = false;
    end
    if strcmpi(param, 'transfer') && ispc && nargopt ~= 1
        ok = false;
    end
    if strcmpi(param, 'transfer') && ~ispc && nargopt ~= 2
        ok = false;
    end
    if strcmpi(param, 'process') && ispc && nargopt ~= 2
        ok = false;
    end
    if strcmpi(param, 'process') && ~ispc && nargopt ~= 3
        ok = false;
    end
    if strcmpi(param, 'sync') && ispc && nargopt ~= 0
        ok = false;
    end
    if strcmpi(param, 'sync') && ~ispc && nargopt ~= 1
        ok = false;
    end
    
    if ~ok
        error('Invalid arguments!');
    end
    
    % Set HORUS paths
    if ~isdeployed
        root = fileparts(mfilename('fullpath'));
        root = fileparts(root);
        addpath(genpath(root));
        curpath = pwd;
        cd(root); % Compile from root path
    end
    
    
    try
        if strcmpi(param, 'capture')
            % Compile with MCC
            fprintf('Starting compilation...\n');
            mcc -m auto_capture_images -a ./data -I ./tmp;
            fprintf('Compilation finished!\n');
            
            % Create script
            fprintf('Creating script...\n');
            fid = fopen('run_auto_capture_images.bat', 'w');
            if ispc
                fprintf(fid, 'auto_capture_images %s\n', station);
            else
                mcrroot = varargin{1};
                fprintf(fid, './run_auto_capture_images.sh %s %s\n', mcrroot, station);
            end
            fclose(fid);
            fprintf('Script created!\n');
            if ~ispc
                dos('chmod +x run_auto_capture_images.bat');
            end
        end
        
        if strcmpi(param, 'transfer')
            % Compile with MCC
            fprintf('Starting compilation...\n');
            mcc -m auto_transfer -a ./data -I ./tmp;
            fprintf('Compilation finished!\n');
            
            % Create script
            host = varargin{1};
            fprintf('Creating script...\n');
            fid = fopen('run_auto_transfer.bat', 'w');
            if ispc
                fprintf(fid, 'auto_transfer %s %s\n', station, host);
            else
                mcrroot = varargin{2};
                fprintf(fid, './run_auto_transfer.sh %s %s %s\n', mcrroot, station, host);
            end
            fclose(fid);
            fprintf('Script created!\n');
            if ~ispc
                dos('chmod +x run_auto_transfer.bat');
            end
        end
        
        if strcmpi(param, 'process')
            % Compile with MCC
            fprintf('Starting compilation...\n');
            mcc -m auto_process_images -a ./data -I ./tmp;
            fprintf('Compilation finished!\n');
            
            % Create script
            istep = varargin{1};
            ierror = varargin{2};
            fprintf('Creating script...\n');
            fid = fopen('run_auto_process_images.bat', 'w');
            if ispc
                fprintf(fid, 'auto_process_images %s %d %d\n', station, istep, ierror);
            else
                mcrroot = varargin{3};
                fprintf(fid, './run_auto_process_images.sh %s %s %d %d\n', mcrroot, station, istep, ierror);
            end
            fclose(fid);
            fprintf('Script created!\n');
            if ~ispc
                dos('chmod +x run_auto_process_images.bat');
            end
        end
        
        if strcmpi(param, 'sync')
            % Compile with MCC
            fprintf('Starting compilation...\n');
            mcc -m auto_synchronization -a ./data -a ./src -I ./tmp;
            fprintf('Compilation finished!\n');
            
            % Create script
            fprintf('Creating script...\n');
            fid = fopen('run_auto_synchronization.bat', 'w');
            if ispc
                fprintf(fid, 'auto_synchronization %s\n', station);
            else
                mcrroot = varargin{1};
                fprintf(fid, './run_auto_synchronization.sh %s %s\n', mcrroot, station);
            end
            fclose(fid);
            fprintf('Script created!\n');
            if ~ispc
                dos('chmod +x run_auto_synchronization.bat');
            end
        end
    catch e
        disp(['There was a problem while compiling: ' e.message])
        cd(curpath);
    end
    cd(curpath);
    
catch e
    disp(e.message)
end