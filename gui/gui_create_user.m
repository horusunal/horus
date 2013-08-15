function varargout = gui_create_user(varargin)
% GUI_CREATE_USER MATLAB code for gui_create_user.fig
%      GUI_CREATE_USER, by itself, creates a new GUI_CREATE_USER or raises the existing
%      singleton*.
%
%      H = GUI_CREATE_USER returns the handle to a new GUI_CREATE_USER or the handle to
%      the existing singleton*.
%
%      GUI_CREATE_USER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_CREATE_USER.M with the given input arguments.
%
%      GUI_CREATE_USER('Property','Value',...) creates a new GUI_CREATE_USER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_create_user_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_create_user_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_create_user

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
% Last Modified by GUIDE v2.5 03-May-2012 05:43:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @gui_create_user_OpeningFcn, ...
    'gui_OutputFcn',  @gui_create_user_OutputFcn, ...
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


% --- Executes just before gui_create_user is made visible.
function gui_create_user_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_create_user (see VARARGIN)

try
    
    % Choose default command line output for gui_create_user
    handles.output = hObject;
    
    % Set HORUS paths
    if ~isdeployed
        handles.root = fileparts(mfilename('fullpath'));
        handles.root = fileparts(handles.root);
        addpath(genpath(handles.root));
    end
    
    try
        handles.conn = connection_db();
    catch e
        disp(e.message)
        return
    end
    
    % Initialize stations in popup menu
    stations = load_station(handles.conn);
    
    if isempty(stations)
        warndlg('No stations were found in the database!', 'Warning');
    end
    
    strStation = {'Select a station'};
    
    for k = 1:numel(stations)
        strStation{k + 1, 1} = char(stations(k));
    end
    
    set(handles.popupStation, 'String', strStation);
    
    % Put logo
    logo = imread('LogoHorusMin.png');
    imshow(logo, 'Parent', handles.axesLogo);
    
    
    % Update handles structure
    guidata(hObject, handles);
    
catch e
    disp(e.message)
end
% UIWAIT makes gui_create_user wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_create_user_OutputFcn(hObject, eventdata, handles)
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
    
    if ~check_station(handles)
        set(handles.editNewUser, 'Enable', 'off')
        set(handles.editNewPass, 'Enable', 'off')
        set(handles.editDatabase, 'Enable', 'off')
        set(handles.checkboxQuery, 'Enable', 'off')
        set(handles.checkboxInsert, 'Enable', 'off')
        set(handles.checkboxDelete, 'Enable', 'off')
        set(handles.checkboxUpdate, 'Enable', 'off')
        set(handles.buttonCreate, 'Enable', 'off')
        set(handles.buttonCancel, 'Enable', 'off')
    else
        set(handles.editNewUser, 'Enable', 'on')
        set(handles.editNewPass, 'Enable', 'on')
        set(handles.editDatabase, 'Enable', 'on')
        set(handles.checkboxQuery, 'Enable', 'on')
        set(handles.checkboxInsert, 'Enable', 'on')
        set(handles.checkboxDelete, 'Enable', 'on')
        set(handles.checkboxUpdate, 'Enable', 'on')
        set(handles.buttonCreate, 'Enable', 'on')
        set(handles.buttonCancel, 'Enable', 'on')
    end
    
catch e
    disp(e.message)
end


% --- Executes on button press in buttonCreate.
function buttonCreate_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCreate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    if ~check_station(handles)
        warndlg('Invalid station!', 'Warning')
        return
    end
    
    if ~check_username(handles)
        warndlg('Invalid username!', 'Warning')
        return
    end
    
    if ~check_password(handles)
        warndlg('Invalid password!', 'Warning')
        return
    end
    
    if ~check_database(handles)
        warndlg('Invalid database name!', 'Warning')
        return
    end
    
    query = get(handles.checkboxQuery, 'Value');
    insert = get(handles.checkboxInsert, 'Value');
    delete = get(handles.checkboxDelete, 'Value');
    update = get(handles.checkboxUpdate, 'Value');
    
    if ~query && ~insert && ~delete && ~update
        warndlg('You should grant at least one permission to the user!', 'Warning')
        return
    end
    
    station = get_station(handles);
    username = get_username(handles);
    password = get_password(handles);
    database = get_database(handles);
    
    privileges = '';
    first = true;
    if query
        if first
            first = false;
        else
            privileges = [privileges ', '];
        end
        privileges = [privileges 'SELECT'];
    end
    
    if insert
        if first
            first = false;
        else
            privileges = [privileges ', '];
        end
        privileges = [privileges 'INSERT'];
    end
    
    if delete
        if first
            first = false;
        else
            privileges = [privileges ', '];
        end
        privileges = [privileges 'DELETE'];
    end
    
    if update
        if first
            first = false;
        else
            privileges = [privileges ', '];
        end
        privileges = [privileges 'UPDATE'];
    end
    
    tables = {'timestack', 'sensor', 'camera', 'rectifiedimage', ...
        'mergedimage', 'obliqueimage', 'image', 'fusion', 'fusionparameter', ...
        'fusionvalue', 'camerabyfusion', 'calibration', 'calibrationparameter', ...
        'calibrationvalue', 'roi', 'roicoordinate', 'gcp', 'pickedgcp', ...
        'automaticparams', 'measurement', 'measurementtype', ...
        'measurementvalue', 'station', 'imagetype', 'commonpoint'};
    
    %reboot connection to the database if necessary
    [handles.conn status] = renew_connection_db(handles.conn);
    
    if status == 1
        return
    end
    
    for i = 1:numel(tables)
        
        % Station have no views
        if  ~strcmpi(tables{i}, 'Station')
            view = [tables{i} '_' lower(station)];
        else
            view = tables{i};
        end
        
        statement = ['GRANT ' privileges ' ON ' database '.' view ' TO ''' username '''@''localhost'' IDENTIFIED BY ''' password ''''];
        statement2 = ['GRANT ' privileges ' ON ' database '.' view ' TO ''' username '''@''%'' IDENTIFIED BY ''' password ''''];
        
        try
            exec(handles.conn, statement);
            exec(handles.conn, statement2);
            exec(handles.conn, 'FLUSH PRIVILEGES');
            %         disp(statement)
        catch e
            disp(e.message)
        end
    end
    % Update handles structure
    guidata(hObject, handles);
    warndlg('User created!', 'Success')
    
catch e
    disp(e.message)
end

% --- Executes on button press in buttonCancel.
function buttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

closereq


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

%--------------------------------------------------------------------------
% Check if there is a valid username
function ok = check_username(handles)
try
    value = get(handles.editNewUser, 'String');
    ok = ~isempty(value);
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Check if there is a valid password
function ok = check_password(handles)
try
    value = get(handles.editNewPass, 'String');
    ok = ~isempty(value);
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Check if there is a valid database
function ok = check_database(handles)
try
    value = get(handles.editDatabase, 'String');
    ok = ~isempty(value);
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
% Returns the selected username
function value = get_username(handles)
try
    value = get(handles.editNewUser, 'String');
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected password
function value = get_password(handles)
try
    value = get(handles.editNewPass, 'String');
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected database
function value = get_database(handles)
try
    value = get(handles.editDatabase, 'String');
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
    
    % Update handles structure
    guidata(hObject, handles);
    
    delete(hObject);
catch e
    disp(e.message)
end
