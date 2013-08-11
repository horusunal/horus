function varargout = gui_login(varargin)
% GUI_LOGIN M-file for gui_login.fig
%      GUI_LOGIN, by itself, creates a new GUI_LOGIN or raises the existing
%      singleton*.
%
%      H = GUI_LOGIN returns the handle to a new GUI_LOGIN or the handle to
%      the existing singleton*.
%
%      GUI_LOGIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_LOGIN.M with the given input arguments.
%
%      GUI_LOGIN('Property','Value',...) creates a new GUI_LOGIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_login_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_login_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_login

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
% Last Modified by GUIDE v2.5 10-Feb-2012 17:47:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @gui_login_OpeningFcn, ...
    'gui_OutputFcn',  @gui_login_OutputFcn, ...
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


% --- Executes just before gui_login is made visible.
function gui_login_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_login (see VARARGIN)

try
    
    % Choose default command line output for gui_login
    handles.output = hObject;
    
    % Set HORUS paths
    if ~isdeployed
        handles.root = fileparts(mfilename('fullpath'));
        handles.root = fileparts(handles.root);
        addpath(genpath(handles.root));
    end
    
    % Put logo
    logo = imread('LogoHorusMin.png');
    imshow(logo, 'Parent', handles.axesLogo);
    
    % Update handles structure
    guidata(hObject, handles);
    
    % UIWAIT makes gui_login wait for user response (see UIRESUME)
    uiwait(handles.figure1);
catch e
    disp(e.message)
end

% --- Outputs from this function are returned to the command line.
function varargout = gui_login_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% % Get default command line output from handles structure
% varargout{1} = handles.output;

if ~isempty(handles)
    varargout{1} = true;
    delete(handles.figure1);
else
    varargout{1} = false;
end
%
% delete(handles.figure1); % Close figure on exit

% --- Executes on button press in buttonOK.
function buttonOK_Callback(hObject, eventdata, handles)
% hObject    handle to buttonOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    if ~check_username(handles)
        warndlg('Invalid username!', 'Warning')
        return
    end
    if ~check_password(handles)
        warndlg('Invalid password!', 'Warning')
        return
    end
    if ~check_ipaddress(handles)
        warndlg('Invalid IP address!', 'Warning')
        return
    end
    if ~check_dbname(handles)
        warndlg('Invalid Database name!', 'Warning')
        return
    end
    if ~check_dbport(handles)
        warndlg('Invalid port!', 'Warning')
        return
    end

    % Gather user info from GUI
    username = get(handles.editUsername, 'String');
    password = get(handles.editPassword, 'String');
    ipaddress = get(handles.editIPAddress, 'String');
    dbname = get(handles.editDBName, 'String');
    dbport = get(handles.editDBPort, 'String');

    create_session(username, password, ipaddress, dbname, dbport);

    uiresume(handles.figure1);
    % closereq
catch e
    disp(e.message)
end

% --- Executes on button press in buttonCancel.
function buttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

closereq


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
% Check if there is a valid IP address
function ok = check_ipaddress(handles)
try
    value = get(handles.editIPAddress, 'String');
    ok = true;
    
    if isempty(value)
        ok = false;
        return
    end
catch e
    disp(e.message)
end
%%%%%%%%%% USE REGULAR EXPRESSION

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
% Check if there is a valid port
function ok = check_dbport(handles)
try
    value = get(handles.editDBPort, 'String');
    ok = ~isnan(str2double(value));
catch e
    disp(e.message)
end