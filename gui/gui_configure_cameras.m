function varargout = gui_configure_cameras(varargin)
% GUI_CONFIGURE_CAMERAS MATLAB code for gui_configure_cameras.fig
%      GUI_CONFIGURE_CAMERAS, by itself, creates a new GUI_CONFIGURE_CAMERAS or raises the existing
%      singleton*.
%
%      H = GUI_CONFIGURE_CAMERAS returns the handle to a new GUI_CONFIGURE_CAMERAS or the handle to
%      the existing singleton*.
%
%      GUI_CONFIGURE_CAMERAS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_CONFIGURE_CAMERAS.M with the given input arguments.
%
%      GUI_CONFIGURE_CAMERAS('Property','Value',...) creates a new GUI_CONFIGURE_CAMERAS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_configure_cameras_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_configure_cameras_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_configure_cameras

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
% Last Modified by GUIDE v2.5 12-Oct-2012 18:04:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @gui_configure_cameras_OpeningFcn, ...
    'gui_OutputFcn',  @gui_configure_cameras_OutputFcn, ...
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


% --- Executes just before gui_configure_cameras is made visible.
function gui_configure_cameras_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_configure_cameras (see VARARGIN)

try
    % Set HORUS paths
    if ~isdeployed
        root = fileparts(mfilename('fullpath'));
        handles.root = fileparts(root);
        addpath(genpath(handles.root));
    end
    
    handles.info = []; % Information of the selected adaptor
    handles.adaptor = []; % Adaptor name
    handles.device = []; % Information of the selected camera device
    handles.cam = []; % Video input object for the selected camera
    handles.source = []; % Information of the source device
    handles.hText = []; % Handle of the annotation
    
    try
        handles.conn = connection_db();
    catch e
        disp(e.message)
        return
    end
    
    % Choose the installed adaptors
    adaptorinfo = imaqhwinfo;
    adaptors = adaptorinfo.InstalledAdaptors';
    
    set(handles.popupAdaptor, 'String', adaptors)
    
    handles = update_adaptor(handles);
    
    % Choose default command line output for gui_configure_cameras
    handles.output = hObject;
    
    % Update handles structure
    guidata(hObject, handles);
    
    % Put logo
    logo = imread('LogoHorusMin.png');
    imshow(logo, 'Parent', handles.axesLogo)
    
catch e
    disp(e.message)
end
% UIWAIT makes gui_configure_cameras wait for user response (see UIRESUME)
% uiwait(handles.config_cameras);


% --- Outputs from this function are returned to the command line.
function varargout = gui_configure_cameras_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupAdaptor.
function popupAdaptor_Callback(hObject, eventdata, handles)
% hObject    handle to popupAdaptor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupAdaptor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupAdaptor

handles = update_adaptor(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on selection change in popupStation.
function popupStation_Callback(hObject, eventdata, handles)
% hObject    handle to popupStation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupStation contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupStation

handles = reload_camera(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on selection change in popupCamera.
function popupCamera_Callback(hObject, eventdata, handles)
% hObject    handle to popupCamera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupCamera contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupCamera

handles = update_camera_device(handles);

% Update handles structure
guidata(hObject, handles);

% --- Executes on selection change in popupFormat.
function popupFormat_Callback(hObject, eventdata, handles)
% hObject    handle to popupFormat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupFormat contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupFormat

handles = update_camera_params(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in buttonSave.
function buttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    % Information to be saved
    fr = [];
    gm = [];
    sm = [];
    wb = [];
    AOI = struct('mode', [], 'Height', [], 'Width', [], 'Left', [], 'Top', []);
    
    if ~check_assoc_camera(handles)
        errordlg('You need to associate a camera to this configuration', 'Error')
        return
    end
    camname = get_assoc_camera(handles);
    station = get_station(handles);
    
    if check_framerate(handles)
        fr = get_framerate(handles);
        set(handles.source, 'FrameRate', fr)
    end
    if check_gain(handles)
        gm = get_gain(handles);
        set(handles.source, 'GainMode', gm)
    end
    if check_shutter(handles)
        sm = get_shutter(handles);
        set(handles.source, 'ShutterMode', sm)
    end
    if check_white_balance(handles)
        hsource = set(handles.source);
        wb = get_white_balance(handles);
        if isfield(hsource, 'WhiteBalanceMode')
            set(handles.source, 'WhiteBalanceMode', wb)
        else
            set(handles.source, 'WhitebalanceMode', wb)
        end
    end
    
    hsource = set(handles.source);
    if isfield(hsource, 'AutoFunctionAOIMode')
        AOI.mode = get(handles.source, 'AutoFunctionAOIMode');
        if strcmpi(AOI.mode, 'showimage')
            set(handles.source, 'AutoFunctionAOIMode', 'on');
            AOI.mode = get(handles.source, 'AutoFunctionAOIMode');
        end
        AOI.Height = get(handles.source, 'AutoFunctionAOIHeight');
        AOI.Width = get(handles.source, 'AutoFunctionAOIWidth');
        AOI.Left = get(handles.source, 'AutoFunctionAOILeft');
        AOI.Top = get(handles.source, 'AutoFunctionAOITop');
    end
    
    adaptor = get_adaptor(handles);
    deviceID = get_camera(handles);
    deviceFormat = get_format(handles);
    
    %%% Save {FrameRate, GainMode, ShutterMode, WhiteBalance, AdaptorName,
    %%% DeviceID, DeviceFormat, AOI} in capture_info.xml
    
    xmlfile = 'capture_info.xml';
    
    xml = loadXML(xmlfile, 'Configuration', 'station', station);
    xmlPath = strcat('Configuration/CameraConfig/Camera[id=', camname, ']');
    removeNode(xml, xmlPath);
    
    % Add the new camera configuration
    camNode = createNode(xml, xmlPath);
    
    % Create element FrameRate
    if isempty(fr)
        textNode = sprintf('none');
    else
        textNode = sprintf('%s', fr);
    end
    createLeave(xml, camNode, 'FrameRate', textNode)
    
    % Create element GainMode
    if isempty(gm)
        textNode = sprintf('none');
    else
        textNode = sprintf('%s', gm);
    end
    createLeave(xml, camNode, 'GainMode', textNode)
    
    % Create element ShutterMode
    if isempty(sm)
        textNode = sprintf('none');
    else
        textNode = sprintf('%s', sm);
    end
    createLeave(xml, camNode, 'ShutterMode', textNode)
    
    % Create element WhiteBalanceMode
    if isempty(wb)
        textNode = sprintf('none');
    else
        textNode = sprintf('%s', wb);
    end
    createLeave(xml, camNode, 'WhiteBalanceMode', textNode)
    
    % Create element AdaptorName
    textNode = sprintf('%s', adaptor);
    createLeave(xml, camNode, 'AdaptorName', textNode)
    
    % Create element DeviceID
    textNode = sprintf('%s', deviceID);
    createLeave(xml, camNode, 'DeviceID', textNode)
    
    % Create element DeviceFormat
    textNode = sprintf('%s', deviceFormat);
    createLeave(xml, camNode, 'DeviceFormat', textNode)
    
    % Create element AOI
    xmlPath = strcat(xmlPath, '/AOI');
    AOINode = createNode(xml, xmlPath);
    
    if isempty(AOI.mode)
        textNode = 'none';
    else
        textNode = sprintf('%s', AOI.mode);
    end
    createLeave(xml, AOINode, 'mode', textNode)
    
    if isempty(AOI.Height)
        textNode = 'none';
    else
        textNode = sprintf('%d', AOI.Height);
    end
    createLeave(xml, AOINode, 'Height', textNode)
    
    if isempty(AOI.Width)
        textNode = 'none';
    else
        textNode = sprintf('%d', AOI.Width);
    end
    createLeave(xml, AOINode, 'Width', textNode)
    
    if isempty(AOI.Left)
        textNode = 'none';
    else
        textNode = sprintf('%d', AOI.Left);
    end
    createLeave(xml, AOINode, 'Left', textNode)
    
    if isempty(AOI.Top)
        textNode = 'none';
    else
        textNode = sprintf('%d', AOI.Top);
    end
    createLeave(xml, AOINode, 'Top', textNode)
    
    % Save the modified XML file
    xmlsave(xmlfile, xml);
    warndlg(['The configuration for ' camname ' has been saved! Please select another camera or close the window.'], 'Success')
    
catch e
    disp(e.message)
end

% --- Executes on button press in buttonAOI.
function buttonAOI_Callback(hObject, eventdata, handles)
% hObject    handle to buttonAOI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    % Check if there is a rectangle drawn yet
    if strcmpi(who('hRect','global'),'hRect')
        mode='saveRect';
    else
        mode='DrawRect';
        global hRect
    end
    source = handles.cam.source;
    
    % Check if there is a rectangle drawn yet
    switch mode
        case 'DrawRect'
            sourcet = get(source);
            if isfield(sourcet, 'AutoFunctionAOIMode')
                f = warndlg({'Please select the AOI area,',...
                    'then press the " AOI area" button again'}, 'Instruction', 'modal');
                waitfor(f)
                hRect = imrect(handles.axesCam);
            else
                mode='DrawRect';
                f = errordlg('The camera does not have an AOI mode', 'Error', 'modal');
            end
        case 'saveRect'
            global hRect
            sourcet = get(source);
            if isfield(sourcet, 'AutoFunctionAOIMode')
                pos = round(getPosition(hRect));
                set(source, 'AutoFunctionAOIMode', 'showimage')
                set(source, 'AutoFunctionAOIHeight', pos(4))
                set(source, 'AutoFunctionAOIWidth', pos(3))
                set(source, 'AutoFunctionAOILeft', pos(1))
                set(source, 'AutoFunctionAOITop', pos(2))
            else
                f = errordlg('The camera does not have an AOI mode', 'Error', 'modal');
            end
            delete(hRect)
            clearvars -global hRect
    end
    
catch e
    disp(e.message)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
% Check if there is a valid adaptor selected
function ok = check_adaptor(handles)
try
    str = get(handles.popupAdaptor, 'String');
    ok = ~(isempty(str) || (numel(str) == 1 && strcmp(str, ' ')));
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Check if there is a valid station selected
function ok = check_station(handles)
try
    str = get(handles.popupStation, 'String');
    ok = ~(isempty(str) || (numel(str) == 1 && strcmp(str, ' ')));
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Check if there is a valid camera selected
function ok = check_camera(handles)
try
    str = get(handles.popupCamera, 'String');
    ok = ~(isempty(str) || (numel(str) == 1 && strcmp(str, ' ')));
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Check if there is a valid associated camera selected
function ok = check_assoc_camera(handles)
try
    str = get(handles.popupAssociateCam, 'String');
    ok = ~(isempty(str) || (numel(str) == 1 && strcmp(str, ' ')));
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Check if there is a valid format selected
function ok = check_format(handles)
try
    str = get(handles.popupFormat, 'String');
    ok = ~(isempty(str) || (numel(str) == 1 && strcmp(str, ' ')));
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Check if there is a valid framerate selected
function ok = check_framerate(handles)
try
    str = get(handles.listboxFramerate, 'String');
    ok = ~(isempty(str) || (numel(str) == 1 && strcmp(str, ' ')));
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Check if there is a valid gain mode selected
function ok = check_gain(handles)
try
    str = get(handles.listboxGain, 'String');
    ok = ~(isempty(str) || (numel(str) == 1 && strcmp(str, ' ')));
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Check if there is a valid shutter mode selected
function ok = check_shutter(handles)
try
    str = get(handles.listboxShutter, 'String');
    ok = ~(isempty(str) || (numel(str) == 1 && strcmp(str, ' ')));
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Check if there is a valid white balance mode selected
function ok = check_white_balance(handles)
try
    str = get(handles.listboxWhiteBalance, 'String');
    ok = ~(isempty(str) || (numel(str) == 1 && strcmp(str, ' ')));
catch e
    disp(e.message)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
% Returns the selected adaptor
function adaptor = get_adaptor(handles)
try
    value = get(handles.popupAdaptor, 'Value');
    contents = cellstr(get(handles.popupAdaptor, 'String'));
    adaptor = contents{value};
catch e
    disp(e.message)
end

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
% Returns the selected camera
function camera = get_camera(handles)
try
    value = get(handles.popupCamera, 'Value');
    contents = cellstr(get(handles.popupCamera, 'String'));
    camera = contents{value};
catch e
    disp(e.message)
end

% Returns the selected camera
function camera = get_assoc_camera(handles)
try
    value = get(handles.popupAssociateCam, 'Value');
    contents = cellstr(get(handles.popupAssociateCam, 'String'));
    camera = contents{value};
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected format
function format = get_format(handles)
try
    value = get(handles.popupFormat, 'Value');
    contents = cellstr(get(handles.popupFormat, 'String'));
    format = contents{value};
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected framerate
function fr = get_framerate(handles)
try
    value = get(handles.listboxFramerate, 'Value');
    contents = cellstr(get(handles.listboxFramerate, 'String'));
    fr = contents{value};
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected gain
function gain = get_gain(handles)
try
    value = get(handles.listboxGain, 'Value');
    contents = cellstr(get(handles.listboxGain, 'String'));
    gain = contents{value};
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected shutter mode
function shutter = get_shutter(handles)
try
    value = get(handles.listboxShutter, 'Value');
    contents = cellstr(get(handles.listboxShutter, 'String'));
    shutter = contents{value};
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected white balance mode
function wb = get_white_balance(handles)
try
    value = get(handles.listboxWhiteBalance, 'Value');
    contents = cellstr(get(handles.listboxWhiteBalance, 'String'));
    wb = contents{value};
catch e
    disp(e.message)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
% Updates the adaptor
function handles = update_adaptor(handles)

try
    
    % If there is any adaptor
    if check_adaptor(handles)
        
        %reboot connection to the database if necessary
        [handles.conn status] = renew_connection_db(handles.conn);

        if status == 1
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
            return
        end
        
        set(handles.popupStation, 'Enable', 'on', 'String', stations)
        
        handles = reload_camera(handles);
        
        % Show by default the first adaptor
        handles.adaptor = get_adaptor(handles);
        handles.info = imaqhwinfo(handles.adaptor);
        
        % Devices connected to selected adaptor
        devices = handles.info.DeviceIDs;
        ok = true;
        if isempty(devices)
            %         warndlg(['There are no ' adaptor ' cameras connected'],'Warning')
            ok = false;
        end
        
        if ok
            n = numel(devices);
            strDev = cell(n, 1);
            for i = 1:n
                strDev{i} = num2str(devices{i});
            end
            
            set(handles.popupCamera, 'String', strDev, 'Value', 1, 'Enable', 'on')
            
            handles = update_camera_device(handles);
        end
        
    else
        set(handles.popupCamera, 'Enable','off', 'String', ' ')
        set(handles.popupFormat, 'Enable','off', 'String', ' ')
        set(handles.popupStation, 'Enable', 'off', 'String', ' ')
        set(handles.popupAssociateCam, 'Enable','off', 'String', ' ')
        set(handles.listboxFramerate, 'Enable','off', 'String', ' ')
        set(handles.listboxGain, 'Enable','off', 'String', ' ')
        set(handles.listboxShutter, 'Enable','off', 'String', ' ')
        set(handles.listboxWhiteBalance, 'Enable','off', 'String', ' ')
        set(handles.buttonAOI, 'Enable','off')
        set(handles.buttonSave, 'Enable','off')
    end
    
catch e
    disp(e.message)
end


%--------------------------------------------------------------------------
% Updates the camera device
function handles = update_camera_device(handles)

try
    
    if check_camera(handles)
        % For the camera selected, choose a format
        curcam = str2double(get_camera(handles));
        handles.device = handles.info.DeviceInfo(curcam);
        formats = handles.device.SupportedFormats;
        
        set(handles.popupFormat, 'String', formats, 'Value', 1, 'Enable', 'on')
        
        handles = update_camera_params(handles);
    else
        set(handles.popupFormat, 'Enable','off', 'String', ' ')
        set(handles.popupStation, 'Enable', 'off', 'String', ' ')
        set(handles.popupAssociateCam, 'Enable','off', 'String', ' ')
        set(handles.listboxFramerate, 'Enable','off', 'String', ' ')
        set(handles.listboxGain, 'Enable','off', 'String', ' ')
        set(handles.listboxShutter, 'Enable','off', 'String', ' ')
        set(handles.listboxWhiteBalance, 'Enable','off', 'String', ' ')
        set(handles.buttonAOI, 'Enable','off')
        set(handles.buttonSave, 'Enable','off')
    end
    
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Updates the camera format
function handles = update_camera_params(handles)

try
    
    if check_format(handles)
        deviceFormat = get_format(handles);
        
        if ~isempty(handles.cam)
            delete(handles.cam);
        end
        
        % Create video input object according to all the information selected
        handles.cam = videoinput(handles.adaptor, handles.device.DeviceID, deviceFormat);
        handles.source = getselectedsource(handles.cam);
        
        hsource = set(handles.source);
        
        if isfield(hsource, 'AutoFunctionAOIMode')
            res = get(handles.cam, 'Videoresolution');
            set(handles.source, 'AutoFunctionAOIMode', 'on')
            set(handles.source, 'AutoFunctionAOILeft', 0)
            set(handles.source, 'AutoFunctionAOITop', 0)
            set(handles.source, 'AutoFunctionAOIHeight', res(2))
            set(handles.source, 'AutoFunctionAOIWidth', res(1))
            set(handles.source, 'AutoFunctionAOIMode', 'off')
            set(handles.buttonAOI, 'Enable','on')
        end
        fr = get(handles.source, 'FrameRate');
        framerates = hsource.FrameRate;
        for i = 1:length(framerates)
            if strcmpi(framerates{i}, fr)
                FRi = i;
                break
            end
        end
        
        set(handles.popupAssociateCam,   'Enable', 'on')
        set(handles.buttonSave,          'Enable', 'on')
        
        set(handles.listboxFramerate, 'String', framerates, ...
            'Value', FRi, 'Enable', 'on')
        
        % If the camera supports Gain Mode, create listbox object with gain modes
        if isfield(hsource, 'GainMode')
            gainModes = hsource.GainMode;
            GM = get(handles.source, 'GainMode');
            for i = 1:length(gainModes)
                if strcmpi(gainModes{i}, GM)
                    GMi =i ;
                    break
                end
            end
            set(handles.listboxGain, 'String', gainModes, 'Value', GMi, 'Enable', 'on')
        else
            set(handles.listboxGain, 'String', ' ', 'Enable', 'off')
        end
        
        % If the camera supports Shutter Mode, create listbox object with shutter modes
        if isfield(hsource, 'ShutterMode')
            shutterModes = hsource.ShutterMode;
            SM = get(handles.source, 'ShutterMode');
            for i = 1:length(shutterModes)
                if strcmpi(shutterModes{i}, SM)
                    SMi = i;
                    break
                end
            end
            set(handles.listboxShutter, 'String', shutterModes, 'Value', SMi, 'Enable', 'on')
        else
            set(handles.listboxShutter, 'String', ' ', 'Enable', 'off')
        end
        
        % If the camera supports White Balance Mode, create listbox object with white balance modes
        if isfield(hsource, 'WhitebalanceMode') || ...
                isfield(hsource,'WhiteBalanceMode')
            field = 'WhitebalanceMode';
            if isfield(hsource, 'WhiteBalanceMode')
                field = 'WhiteBalanceMode';
            end
            
            wbModes = eval(['hsource.' field]);
            
            WB = eval(['get(handles.source,' '''' field ''')']);
            for i=1:length(wbModes)
                if strcmpi(wbModes{i}, WB)
                    WBi=i;
                    break
                end
            end
            set(handles.listboxWhiteBalance, 'String', wbModes, 'Value', WBi, 'Enable', 'on')
        else
            set(handles.listboxWhiteBalance, 'String', ' ', 'Enable', 'off')
        end
        
        handles = update_video_capture(handles);
    else
        set(handles.popupStation, 'Enable', 'off', 'String', ' ')
        set(handles.popupAssociateCam, 'Enable','off', 'String', ' ')
        set(handles.listboxFramerate, 'Enable','off', 'String', ' ')
        set(handles.listboxGain, 'Enable','off', 'String', ' ')
        set(handles.listboxShutter, 'Enable','off', 'String', ' ')
        set(handles.listboxWhiteBalance, 'Enable','off', 'String', ' ')
        set(handles.buttonAOI, 'Enable','off')
        set(handles.buttonSave, 'Enable','off')
    end
    
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Updates the video capture
function handles = update_video_capture(handles)

try
    
    % Get video resolution and number of bands
    vidRes = get(handles.cam, 'VideoResolution');
    nBands = get(handles.cam, 'NumberOfBands');
    
    % Create image object with resolution and bands
    hImage = image(zeros(vidRes(2), vidRes(1), nBands) , 'Parent', handles.axesCam);
    
    % Set axes
    set(handles.axesCam, 'Units', 'Normalized')
    position = [.05, (1-vidRes(2)/vidRes(1)*0.5)/2, 0.5, vidRes(2)/vidRes(1)*0.5];
    set(handles.axesCam, 'Xtick', [], 'YTick', [], 'Position', position)
    set(handles.axesCam, 'Units', 'Pixels')
    
    position = get(handles.axesCam, 'Position');
    position(4) = vidRes(2) * position(3) / vidRes(1);
    set(handles.axesCam, 'Position', position)
    set(handles.axesCam, 'Units', 'normalized')
    position = get(handles.axesCam, 'Position');
    position(2) = (1 - position(4)) / 2;
    set(handles.axesCam, 'Position', position)
    
    delete(handles.hText)
    deviceFormat = get_format(handles);
    titleText = ['Adaptor: ' handles.adaptor ', Format: ' deviceFormat ...
        ', Device Name: ' handles.device.DeviceName];
    handles.hText = annotation('Textbox', [position(1), position(2)-0.06, position(3), 0.05]);
    set(handles.hText, 'Interpreter', 'none', 'String', titleText, 'EdgeColor', 'none', ...
        'LineStyle', 'none', 'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle')
    preview(handles.cam, hImage);
    
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Reload all cameras from the database
function handles = reload_camera(handles)

try
    
    if check_station(handles)
        station = get_station(handles);
        
        %reboot connection to the database if necessary
        [handles.conn status] = renew_connection_db(handles.conn);
        
        if status == 1
            return
        end
        
        h = gui_message('Loading from database, this might take a while!','Loading...');
        cameras = load_cam_station(handles.conn, station);
        if ishandle(h)
            delete(h);
        end
        
        if isempty(cameras)
            warndlg('No cameras were found in the database!', 'Warning');
            return
        end
        
        set(handles.popupAssociateCam, 'String', cameras);
    end

catch e
    disp(e.message)
end

% --- Executes when user attempts to close config_cameras.
function config_cameras_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to config_cameras (see GCBO)
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
