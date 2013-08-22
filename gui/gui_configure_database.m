function varargout = gui_configure_database(varargin)
%GUI_CONFIGURE_DATABASE M-file for gui_configure_database.fig
%      GUI_CONFIGURE_DATABASE, by itself, creates a new GUI_CONFIGURE_DATABASE or raises the existing
%      singleton*.
%
%      H = GUI_CONFIGURE_DATABASE returns the handle to a new GUI_CONFIGURE_DATABASE or the handle to
%      the existing singleton*.
%
%      GUI_CONFIGURE_DATABASE('Property','Value',...) creates a new GUI_CONFIGURE_DATABASE using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to gui_configure_database_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      GUI_CONFIGURE_DATABASE('CALLBACK') and GUI_CONFIGURE_DATABASE('CALLBACK',hObject,...) call the
%      local function named CALLBACK in GUI_CONFIGURE_DATABASE.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_configure_database

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2013 HORUS

% Last Modified by GUIDE v2.5 16-Apr-2013 19:04:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_configure_database_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_configure_database_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before gui_configure_database is made visible.
function gui_configure_database_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

try
    
    handles.output = hObject;
    
    % Set HORUS paths
    if ~isdeployed
        root = fileparts(mfilename('fullpath'));
        handles.root = fileparts(root);
        addpath(genpath(handles.root));
        handles.datapath = fullfile(handles.root, 'data');
        handles.tmppath = fullfile(handles.root, 'tmp');
    else
        pathinfo = what('data');
        handles.datapath = pathinfo.path;
        pathinfo = what('tmp');
        handles.tmppath = pathinfo.path;
    end
    
    set(handles.editPort, 'String', '3306')
    handles.sqlPath = [];
    
    % Update handles structure
    guidata(hObject, handles);
    
    % Put logo
    logo = imread('LogoHorusMin.png');
    imshow(logo, 'Parent', handles.axesLogo)
catch e
    disp(e.message)
end

% UIWAIT makes gui_configure_database wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_configure_database_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in buttonApply.
function buttonApply_Callback(hObject, eventdata, handles)
% hObject    handle to buttonApply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    if ~check_host(handles)
        warndlg('Invalid host!', 'Warning')
        return
    end
    if ~check_dbname(handles)
        warndlg('Invalid database name!', 'Warning')
        return
    end
    if ~check_port(handles)
        warndlg('Invalid port!', 'Warning')
        return
    end
    if ~check_username(handles)
        warndlg('Invalid admin username!', 'Warning')
        return
    end
    if ~check_password(handles)
        warndlg('Invalid admin password!', 'Warning')
        return
    end
    if ~check_sqlpath(handles, hObject)
        warndlg('You have not selected the SQL file!', 'Warning')
        return
    end
    
    % Gather user info from GUI
    host = get(handles.editHost, 'String');
    dbname = get(handles.editDBName, 'String');
    port = get(handles.editPort, 'String');
    username = get(handles.editUsername, 'String');
    userpass = get(handles.editPassword, 'String');
    
    % Ask for MySQL root password
    prompt = {'Please enter the MySQL root password:'};
    dlg_title = 'MySQL root password';
    num_lines = 1;
    answer = inputdlg(prompt, dlg_title, num_lines);
    
    if isempty(answer) % cancel
        return
    end
    if isempty(answer{1})
        warndlg('The password of the MySQL root user is required!', 'Warning')
        return
    end
    password = answer{1};
    
    [status, message] = set_database(password, host, dbname, port,...
        username, userpass, handles.sqlPath);
    
    if status == 0 % success
        warndlg(message, 'Success')
    else
        if isempty(message)
            message = ['There was an error when configuring the database: ' 
                message];
        end
         warndlg(message, 'Failure')
    end
    
catch e
    disp(e.message)
end


% --- Executes on button press in buttonSQL.
function buttonSQL_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSQL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    [filename, path] = uigetfile('*.sql');
    handles.sqlPath = fullfile(path, filename);
    
    if handles.sqlPath == 0
        handles.sqlPath = [];
    end
    set(handles.editSQL, 'String', handles.sqlPath)
    
    % Update handles structure
    guidata(hObject, handles);
    
catch e
    disp(e.message)
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
% Check if there is a valid host
function ok = check_host(handles)
try
    value = get(handles.editHost, 'String');
    ok = true;
    
    if isempty(value)
        ok = false;
        return
    end
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Check if there is a valid database name
function ok = check_dbname(handles)
try
    value = get(handles.editDBName, 'String');
    ok = true;
    
    if isempty(value)
        ok = false;
        return
    end
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Check if there is a valid database port
function ok = check_port(handles)
try
    value = get(handles.editPort, 'String');
    ok = true;
    
    if isempty(value)
        ok = false;
        return
    end
    if isnan(str2double(value))
        ok = false;
        return
    end
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Check if there is a valid username
function ok = check_username(handles)
try
     value = get(handles.editUsername, 'String');
    if isempty(value)
        ok = false;
        return
    end
    
    % Username should begin with a letter
    if (value(1) >= 'A' && value(1) <= 'Z') || ...
            (value(1) >= 'a' && value(1) <= 'z')
        ok = true;
    else
        ok = false;
    end
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Check if there is a valid password
function ok = check_password(handles)
try
    value = get(handles.editPassword, 'String');
    ok = true;
    
    if isempty(value)
        ok = false;
        return
    end
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Check if there SQL path has been selected
function ok = check_sqlpath(handles,hObject)
try
    pathsql = get(handles.editSQL, 'String');
    if ~isempty(pathsql)
        handles.sqlPath = pathsql;
    end
    
    [pathstr, name, ext] = fileparts(handles.sqlPath);
    
    if strcmpi(ext,'.sql')
        ok = 1;
    else
        ok = 0;
    end
    
    % Update handles structure
    guidata(hObject, handles);
catch e
    disp(e.message)
end
