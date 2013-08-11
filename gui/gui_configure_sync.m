function varargout = gui_configure_sync(varargin)
% GUI_CONFIGURE_SYNC M-file for gui_configure_sync.fig
%      GUI_CONFIGURE_SYNC, by itself, creates a new GUI_CONFIGURE_SYNC or raises the existing
%      singleton*.
%
%      H = GUI_CONFIGURE_SYNC returns the handle to a new GUI_CONFIGURE_SYNC or the handle to
%      the existing singleton*.
%
%      GUI_CONFIGURE_SYNC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_CONFIGURE_SYNC.M with the given input arguments.
%
%      GUI_CONFIGURE_SYNC('Property','Value',...) creates a new GUI_CONFIGURE_SYNC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_configure_sync_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_configure_sync_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_configure_sync

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
% Last Modified by GUIDE v2.5 03-Sep-2012 15:36:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_configure_sync_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_configure_sync_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gui_configure_sync is made visible.
function gui_configure_sync_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_configure_sync (see VARARGIN)

try
    % Choose default command line output for gui_configure_sync
    handles.output = hObject;

    handles.xmlfile = 'sync_info.xml';

    if ~isdeployed
        root = fileparts(mfilename('fullpath'));
        handles.root = fileparts(root);
        addpath(genpath(handles.root));
        handles.datapath = fullfile(handles.root, 'data');
    else
        pathinfo = what('data');
        handles.datapath = pathinfo.path;
    end
    try
        handles.conn = connection_db();
    catch e
        disp(e.message)
        return
    end

    % Initialize stations in popup menu
    h = gui_message('Loading from database, this might take a while!','Loading...');
    stations = load_station(handles.conn);
    if ishandle(h)
        delete(h);
    end

    if isempty(stations)
        warndlg('No stations were found in the database!', 'Warning');
    end

    strStation = {'Select a station'};

    for k = 1:numel(stations)
        strStation{k + 1, 1} = char(stations(k));
    end

    set(handles.popupStation, 'String', strStation);

    % Set hour and minutes defaults
    strStartHour = cell(0);
    strStartMinute = cell(0);
    strEndHour = cell(0);
    strEndMinute = cell(0);

    for i = 0:23
        strStartHour{i + 1} = num2str(i, '%02d');
        strEndHour{i + 1} = num2str(i, '%02d');
    end
    set(handles.popupStartHour, 'String', strStartHour);

    set(handles.popupEndHour, 'String', strEndHour);

    for i = 0:59
        strStartMinute{i + 1} = num2str(i, '%02d');
        strEndMinute{i + 1} = num2str(i, '%02d');
    end
    set(handles.popupStartMinute, 'String', strStartMinute);

    set(handles.popupEndMinute, 'String', strEndMinute);

    % Put logo
    logo = imread('LogoHorusMin.png');
    imshow(logo, 'Parent', handles.axesLogo)

    % Update handles structure
    guidata(hObject, handles);
catch e
    disp(e.message)
end

% UIWAIT makes gui_configure_sync wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_configure_sync_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupStation.
function popupStation_Callback(hObject, eventdata, handles)
% hObject    handle to popupStation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupStation contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupStation

try
    if check_station(handles)

        %reboot connection to the database if necessary
        [handles.conn status] = renew_connection_db(handles.conn);

        if status == 1
            return
        end
        set(handles.buttonShow_time, 'Enable', 'on')
        set(handles.buttonSave, 'Enable', 'on')
        set(handles.editLocalHost, 'Enable', 'on')
        set(handles.editLocalUser, 'Enable', 'on')
        set(handles.editLocalPass, 'Enable', 'on')
        set(handles.editLocalDB, 'Enable', 'on')
        set(handles.editLocalPort, 'Enable', 'on')
        set(handles.editRemoteHost, 'Enable', 'on')
        set(handles.editRemoteUser, 'Enable', 'on')
        set(handles.editRemotePass, 'Enable', 'on')
        set(handles.editRemoteDB, 'Enable', 'on')
        set(handles.editRemotePort, 'Enable', 'on')
       
        station = get_station(handles);

        xml = loadXML(handles.xmlfile, 'Configuration', 'station', station);

        xmlPath = strcat('Configuration[station=', station, ']/SyncConfig');
        syncNodes = getNodes(xml, xmlPath);

        if ~isempty(syncNodes)
            syncNode = syncNodes{1};

            val = getNodeVal(syncNode, 'StartHour');
            set(handles.popupStartHour, 'Value', str2double(val) + 1)

            val = getNodeVal(syncNode, 'StartMinute');
            set(handles.popupStartMinute, 'Value', str2double(val) + 1)

            val = getNodeVal(syncNode, 'EndHour');
            set(handles.popupEndHour, 'Value', str2double(val) + 1)

            val = getNodeVal(syncNode, 'EndMinute');
            set(handles.popupEndMinute, 'Value', str2double(val) + 1)

            val = getNodeVal(syncNode, 'TimeStep');
            set(handles.editTimeStep, 'String', val)

            val = getNodeVal(syncNode, 'HostLocal');
            set(handles.editLocalHost, 'String', val)

            val = getNodeVal(syncNode, 'UserLocal');
            set(handles.editLocalUser, 'String', val)

            val = getNodeVal(syncNode, 'PassLocal');
            val = decrypt_aes(val, handles.datapath);
            set(handles.editLocalPass, 'String', val)

            val = getNodeVal(syncNode, 'DBNameLocal');
            set(handles.editLocalDB, 'String', val)

            val = getNodeVal(syncNode, 'PortLocal');
            set(handles.editLocalPort, 'String', val)

            val = getNodeVal(syncNode, 'HostRemote');
            set(handles.editRemoteHost, 'String', val)

            val = getNodeVal(syncNode, 'UserRemote');
            set(handles.editRemoteUser, 'String', val)

            val = getNodeVal(syncNode, 'PassRemote');
            val = decrypt_aes(val, handles.datapath);
            set(handles.editRemotePass, 'String', val)

            val = getNodeVal(syncNode, 'DBNameRemote');
            set(handles.editRemoteDB, 'String', val)
            
            val = getNodeVal(syncNode, 'PortRemote');
            set(handles.editRemotePort, 'String', val)
        end
        % Update handles structure
        guidata(hObject, handles);
    else
        set(handles.popupStartHour, 'Value', 1)
        set(handles.popupStartMinute, 'Value', 1)
        set(handles.popupEndHour, 'Value', 1)
        set(handles.popupEndMinute, 'Value', 1)
        set(handles.editTimeStep, 'String', '')
        set(handles.editLocalHost, 'String', '', 'Enable', 'off')
        set(handles.editLocalUser, 'String', '', 'Enable', 'off')
        set(handles.editLocalPass, 'String', '', 'Enable', 'off')
        set(handles.editLocalDB, 'String', '', 'Enable', 'off')
        set(handles.editLocalPort, 'String', '', 'Enable', 'off')
        set(handles.editRemoteHost, 'String', '', 'Enable', 'off')
        set(handles.editRemoteUser, 'String', '', 'Enable', 'off')
        set(handles.editRemotePass, 'String', '', 'Enable', 'off')
        set(handles.editRemoteDB, 'String', '', 'Enable', 'off')
        set(handles.editRemotePort, 'String', '', 'Enable', 'off')
        set(handles.buttonSave, 'Enable', 'off')
        set(handles.buttonShow_time, 'Enable', 'off')
        set(handles.buttonBuild, 'Enable', 'off')
    end
catch e
    disp(e.message)
end


% --- Executes on button press in buttonSave.
function buttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    %reboot connection to the database if necessary
    [handles.conn status] = renew_connection_db(handles.conn);

    if status == 1
        return
    end

    if check_station(handles)
        station = get_station(handles);
        start_hour = get_start_hour(handles);
        start_minute = get_start_minute(handles);
        end_hour = get_end_hour(handles);
        end_minute = get_end_minute(handles);
        step = get_time_step(handles);
        localhost = get_local_host(handles);
        localuser = get_local_user(handles);
        localpass = get_local_pass(handles);
        localdb = get_local_db(handles);
        localport = get_local_port(handles);
        remotehost = get_remote_host(handles);
        remoteuser = get_remote_user(handles);
        remotepass = get_remote_pass(handles);
        remotedb = get_remote_db(handles);
        remoteport = get_remote_port(handles);

        ok = true;
        if ok && start_hour * 60 + start_minute > end_hour * 60 + end_minute
            warndlg('The initial time is greater than final time!', 'Warning')
            ok = false;
        end
        if ok && isnan(step)
            warndlg('The time step is invalid!', 'Warning')
            ok = false;
        end
        if ok && isempty(localhost)
            warndlg('The local host is invalid!', 'Warning')
            ok = false;
        end
        if ok && isempty(localuser)
            warndlg('The local username is invalid!', 'Warning')
            ok = false;
        end
        if ok && isempty(localpass)
            warndlg('The local password is invalid!', 'Warning')
            ok = false;
        end
        if ok && isempty(localdb)
            warndlg('The local database name is invalid!', 'Warning')
            ok = false;
        end
        if ok && (isempty(localport) || isnan(str2double(localport)))
            warndlg('The local port is invalid!', 'Warning')
            ok = false;
        end
        if ok && isempty(remotehost)
            warndlg('The remote host is invalid!', 'Warning')
            ok = false;
        end
        if ok && isempty(remoteuser)
            warndlg('The remote username is invalid!', 'Warning')
            ok = false;
        end
        if ok && isempty(remotepass)
            warndlg('The remote password is invalid!', 'Warning')
            ok = false;
        end
        if ok && isempty(remotedb)
            warndlg('The remote database name is invalid!', 'Warning')
            ok = false;
        end
        if ok && (isempty(remoteport) || isnan(str2double(remoteport)))
            warndlg('The remote port is invalid!', 'Warning')
            ok = false;
        end

        if ok
            type = 'sync';
            xml = loadXML(handles.xmlfile, 'Configuration', 'station', station);
            % Encrypt passwords
            localpass = encrypt_aes(localpass, handles.datapath);
            remotepass = encrypt_aes(remotepass, handles.datapath);
            
            xmlPath = strcat('Configuration[station=', station, ']/SyncConfig');

            removeNode(xml, xmlPath);

            syncElement = createNode(xml, xmlPath);

            createLeave(xml, syncElement, 'StartHour', sprintf('%d', start_hour))
            createLeave(xml, syncElement, 'StartMinute', sprintf('%d', start_minute))
            createLeave(xml, syncElement, 'EndHour', sprintf('%d', end_hour))
            createLeave(xml, syncElement, 'EndMinute', sprintf('%d', end_minute))
            createLeave(xml, syncElement, 'TimeStep', sprintf('%d', step))
            createLeave(xml, syncElement, 'HostLocal', sprintf('%s', localhost))
            createLeave(xml, syncElement, 'UserLocal', sprintf('%s', localuser))
            createLeave(xml, syncElement, 'PassLocal',sprintf('%s', localpass))
            createLeave(xml, syncElement, 'DBNameLocal', sprintf('%s', localdb))
            createLeave(xml, syncElement, 'PortLocal', sprintf('%s', localport))
            createLeave(xml, syncElement, 'HostRemote',sprintf('%s', remotehost))
            createLeave(xml, syncElement, 'UserRemote',sprintf('%s', remoteuser))
            createLeave(xml, syncElement, 'PassRemote', sprintf('%s', remotepass))
            createLeave(xml, syncElement, 'DBNameRemote', sprintf('%s', remotedb))
            createLeave(xml, syncElement, 'PortRemote',sprintf('%s', remoteport))

            idproc = load_idautomatic(handles.conn, station, type);
            idproc =  cell2mat(idproc);
            if ~isempty(idproc)
                status = update_automatic_params(handles.conn, station, idproc, ...
                    'type', type, 'start_hour', start_hour, ...
                    'start_minute', start_minute, 'end_hour', ...
                    end_hour, 'end_minute', end_minute,...
                    'step', step);
            else
                idval = cell2mat(load_max_idautomatic(handles.conn, station));
                if isnan(idval)
                    idproc = 1;
                else
                    idproc = idval + 1;
                end
                status = insert_automatic_params(handles.conn, idproc, station, ...
                    type, start_hour, start_minute, ...
                    end_hour, end_minute, step);
            end

            if status == 1
                warndlg('The synchronization configuration has not been saved!', 'Failure')
            else
                xmlsave(handles.xmlfile, xml);
                warndlg('The synchronization configuration has been saved!', 'Success')
                set(handles.buttonBuild, 'Enable', 'on')
            end
        end
    end
catch e
    disp(e.message)
end


% --- Executes on button press in buttonBuild.
function buttonBuild_Callback(hObject, eventdata, handles)
% hObject    handle to buttonBuild (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if check_station(handles)
    station = get_station(handles);

    if ispc
        h = gui_message('Generating synchronization automatic might take several minutes...','Loading...');
        create_auto_exec('sync', station)
        if ishandle(h)
            delete(h);
        end
    else
        mcrroot = uigetdir('.');
        if mcrroot
            h = gui_message('Generating synchronization automatic might take several minutes...','Loading...');
            create_auto_exec('sync', station, mcrroot);
            if ishandle(h)
                delete(h);
            end
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
% Check if there is a valid station selected
function ok = check_station(handles)
try
    value = get(handles.popupStation, 'Value');
    ok = value ~= 1;
catch e
    disp(e.message)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
% Returns the selected station
function station = get_station(handles)
try
    value = get(handles.popupStation, 'Value');
    contents = cellstr(get(handles.popupStation, 'String'));
    station = contents{value};
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected start hour
function startHour = get_start_hour(handles)
try
    value = get(handles.popupStartHour, 'Value');
    contents = cellstr(get(handles.popupStartHour, 'String'));
    startHour = str2double(contents{value});
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected end hour
function endHour = get_end_hour(handles)
try
    value = get(handles.popupEndHour, 'Value');
    contents = cellstr(get(handles.popupEndHour, 'String'));
    endHour = str2double(contents{value});
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected start minute
function startMinute = get_start_minute(handles)
try
    value = get(handles.popupStartMinute, 'Value');
    contents = cellstr(get(handles.popupStartMinute, 'String'));
    startMinute = str2double(contents{value});
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected end minute
function endMinute = get_end_minute(handles)
try
    value = get(handles.popupEndMinute, 'Value');
    contents = cellstr(get(handles.popupEndMinute, 'String'));
    endMinute = str2double(contents{value});
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected time step
function step = get_time_step(handles)
try
    step = str2double(get(handles.editTimeStep, 'String'));
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected local host
function value = get_local_host(handles)
try
    value = get(handles.editLocalHost, 'String');
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected local user
function value = get_local_user(handles)
try
    value = get(handles.editLocalUser, 'String');
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected local password
function value = get_local_pass(handles)
try
    value = get(handles.editLocalPass, 'String');
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected local database name
function value = get_local_db(handles)
try
    value = get(handles.editLocalDB, 'String');
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected local port
function value = get_local_port(handles)
try
    value = get(handles.editLocalPort, 'String');
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected remote host
function value = get_remote_host(handles)
try
    value = get(handles.editRemoteHost, 'String');
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected remote user
function value = get_remote_user(handles)
try
    value = get(handles.editRemoteUser, 'String');
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected remote password
function value = get_remote_pass(handles)
try
    value = get(handles.editRemotePass, 'String');
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected remote database name
function value = get_remote_db(handles)
try
    value = get(handles.editRemoteDB, 'String');
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected remote port
function value = get_remote_port(handles)
try
    value = get(handles.editRemotePort, 'String');
catch e
    disp(e.message)
end

% --- Executes on button press in buttonShow_time.
function buttonShow_time_Callback(hObject, eventdata, handles)
% hObject    handle to buttonShow_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    if check_station(handles)
        station = get_station(handles);
        process_times(station)
    end
catch e
    disp(e.message)
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: delete(hObject) closes the figure

try
    
    close_session = questdlg('Do you want to close this session?', ...
            'Close session', 'Yes', 'No', 'Cancel', 'Cancel');
        
    if strcmp(close_session, 'Yes')
        destroy_session
    elseif strcmp(close_session, 'Cancel')
        return
    end
    if isconnection(handles.conn)
        close(handles.conn)
    end
    delete(hObject);
catch e
    disp(e.message)
end
