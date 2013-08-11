function varargout = gui_paths_editor(varargin)
% GUI_PATHS_EDITOR M-file for gui_paths_editor.fig
%      GUI_PATHS_EDITOR, by itself, creates a new GUI_PATHS_EDITOR or raises the existing
%      singleton*.
%
%      H = GUI_PATHS_EDITOR returns the handle to a new GUI_PATHS_EDITOR or the handle to
%      the existing singleton*.
%
%      GUI_PATHS_EDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_PATHS_EDITOR.M with the given input arguments.
%
%      GUI_PATHS_EDITOR('Property','Value',...) creates a new GUI_PATHS_EDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_paths_editor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_paths_editor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_paths_editor

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
% Last Modified by GUIDE v2.5 16-Feb-2012 10:34:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @gui_paths_editor_OpeningFcn, ...
    'gui_OutputFcn',  @gui_paths_editor_OutputFcn, ...
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


% --- Executes just before gui_paths_editor is made visible.
function gui_paths_editor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_paths_editor (see VARARGIN)

try
    % Set paths
    if ~isdeployed
        root = fileparts(mfilename('fullpath'));
        root = fileparts(root);
        addpath(genpath(root));
    end
    
    try
        handles.conn = connection_db();
    catch e
        disp(e.message)
        return
    end
    
    % Show the logo
    logo=imread('LogoHorusMin.png');
    imshow(logo, 'Parent', handles.logo);
    
    handles.xmlfile = 'path_info.xml';
    
    % Initialize stations in popup menu
    site=load_station(handles.conn);
    handles.sites = cell(0);
    handles.sites{1, 1}= 'Select the station';
    j=2;
    for k = 1:length(site)
        handles.sites{j, 1}=char(site(k));
        j=j+1;
    end
    if (j == 2)
        warndlg({'No sites in the database','Be sure to enter the site before proceeding.'},'Warning');
    else
        set(handles.stationSelect,'String',handles.sites);
    end
    
    % Choose default command line output for gui_paths_editor
    handles.output = hObject;
    
    % Update handles structure
    guidata(hObject, handles);
catch e
    disp(e.message)
end
% UIWAIT makes gui_paths_editor wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_paths_editor_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on selection change in stationSelect.
function stationSelect_Callback(hObject, eventdata, handles)
% hObject    handle to stationSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns stationSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from stationSelect

try
    
    if get(handles.stationSelect,'Value')==1
        % Reset some part of the GUI
        set(handles.savepath,'Enable','off');
        set(handles.pathObliqueText,'String','');
        set(handles.pathRectifiedText,'String','')
        set(handles.pathMergeObliqueText,'String','');
        set(handles.pathMergeRectifiedText,'String','');
        set(handles.pathObliqueMinText,'String','');
        set(handles.pathRectifiedMinText,'String','')
        set(handles.pathMergeObliqueMinText,'String','');
        set(handles.pathMergeRectifiedMinText,'String','');
        
    else
        set(handles.savepath,'Enable','on');
        station = get_station(handles);
        xml = loadXML(handles.xmlfile, 'config');
        xmlPath = strcat('config/paths/site[name=', station, ']');
        pathsNodes = getNodes(xml, xmlPath);
        
        if ~isempty(pathsNodes)
            paths = pathsNodes{1};
            % Load path
            % Checks to be a folder or a URL to display the path
            
            val = getNodeVal(paths, 'pathOblique');
            find = strfind(strtrim(val),'http://');
            if ~isdir(strtrim(val)) && isempty(find)
                set(handles.pathObliqueText,'String','');
            else
                set(handles.pathObliqueText,'String',strtrim(val));
            end
            
            val = getNodeVal(paths, 'pathRectified');
            find = strfind(strtrim(val),'http://');
            if ~isdir(strtrim(val)) && isempty(find)
                set(handles.pathRectifiedText,'String','')
            else
                set(handles.pathRectifiedText,'String',strtrim(val));
            end
            
            val = getNodeVal(paths, 'pathMergeOblique');
            find = strfind(strtrim(val),'http://');
            if ~isdir(strtrim(val)) && isempty(find)
                set(handles.pathMergeObliqueText,'String','')
            else
                set(handles.pathMergeObliqueText,'String',strtrim(val));
            end
            
            val = getNodeVal(paths, 'pathMergeRectified');
            find = strfind(strtrim(val),'http://');
            if ~isdir(strtrim(val)) && isempty(find)
                set(handles.pathMergeRectifiedText,'String','')
            else
                set(handles.pathMergeRectifiedText,'String',strtrim(val));
            end
            
            val = getNodeVal(paths, 'pathObliqueMin');
            find = strfind(strtrim(val),'http://');
            if ~isdir(strtrim(val)) && isempty(find)
                set(handles.pathObliqueMinText,'String','')
            else
                set(handles.pathObliqueMinText,'String',strtrim(val));
            end
            
            val = getNodeVal(paths, 'pathRectifiedMin');
            find = strfind(strtrim(val),'http://');
            if ~isdir(strtrim(val)) && isempty(find)
                set(handles.pathRectifiedMinText,'String','')
            else
                set(handles.pathRectifiedMinText,'String',strtrim(val))
            end
            
            val = getNodeVal(paths, 'pathMergeObliqueMin');
            find = strfind(strtrim(val),'http://');
            if ~isdir(strtrim(val)) && isempty(find)
                set(handles.pathMergeObliqueMinText,'String','')
            else
                set(handles.pathMergeObliqueMinText,'String',strtrim(val));
            end
            
            val = getNodeVal(paths, 'pathMergeRectifiedMin');
            find = strfind(strtrim(val),'http://');
            if ~isdir(strtrim(val)) && isempty(find)
                set(handles.pathMergeRectifiedMinText,'String','')
            else
                set(handles.pathMergeRectifiedMinText,'String',strtrim(val));
            end
            
        else
            set(handles.pathObliqueText,'String','');
            set(handles.pathRectifiedText,'String','')
            set(handles.pathMergeObliqueText,'String','');
            set(handles.pathMergeRectifiedText,'String','');
            set(handles.pathObliqueMinText,'String','');
            set(handles.pathRectifiedMinText,'String','')
            set(handles.pathMergeObliqueMinText,'String','');
            set(handles.pathMergeRectifiedMinText,'String','');
            
        end
    end
catch e
    disp(e.message)
end

% --- Executes on button press in pathObliqueButton.
function pathObliqueButton_Callback(hObject, eventdata, handles)
% hObject    handle to pathObliqueButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    % Select path
    path = uigetdir;
    if path ~= 0
        set(handles.pathObliqueText,'String',path);
    end
catch e
    disp(e.message)
end

% --- Executes on button press in pathMergeObliqueButton.
function pathMergeObliqueButton_Callback(hObject, eventdata, handles)
% hObject    handle to pathMergeObliqueButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    % Select path
    path = uigetdir;
    if path ~= 0
        set(handles.pathMergeObliqueText,'String',path);
    end
catch e
    disp(e.message)
end

% --- Executes on button press in pathMergeRectifiedButton.
function pathMergeRectifiedButton_Callback(hObject, eventdata, handles)
% hObject    handle to pathMergeRectifiedButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    % Select path
    path = uigetdir;
    if path ~= 0
        set(handles.pathMergeRectifiedText,'String',path);
    end
catch e
    disp(e.message)
end

% --- Executes on button press in pathObliqueMinButton.
function pathObliqueMinButton_Callback(hObject, eventdata, handles)
% hObject    handle to pathObliqueMinButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    % Select path
    path = uigetdir;
    if path ~= 0
        set(handles.pathObliqueMinText,'String',path);
    end
catch e
    disp(e.message)
end

% --- Executes on button press in pathMergeObliqueMinButton.
function pathMergeObliqueMinButton_Callback(hObject, eventdata, handles)
% hObject    handle to pathMergeObliqueMinButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    % Select path
    path = uigetdir;
    if path ~= 0
        set(handles.pathMergeObliqueMinText,'String',path);
    end
catch e
    disp(e.message)
end

% --- Executes on button press in pathMergeRectifiedMinButton.
function pathMergeRectifiedMinButton_Callback(hObject, eventdata, handles)
% hObject    handle to pathMergeRectifiedMinButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    % Select path
    path = uigetdir;
    if path ~= 0
        set(handles.pathMergeRectifiedMinText,'String',path);
    end
catch e
    disp(e.message)
end

% --- Executes on button press in pathRectifiedButton.
function pathRectifiedButton_Callback(hObject, eventdata, handles)
% hObject    handle to pathRectifiedButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    % Select path
    path = uigetdir;
    if path ~= 0
        set(handles.pathRectifiedText,'String',path);
    end
catch e
    disp(e.message)
end

% --- Executes on button press in pathRectifiedMinButton.
function pathRectifiedMinButton_Callback(hObject, eventdata, handles)
% hObject    handle to pathRectifiedMinButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    % Select path
    path = uigetdir;
    if path ~= 0
        set(handles.pathRectifiedMinText,'String',path);
    end
catch e
    disp(e.message)
end


% --- Executes on button press in savepath.
function savepath_Callback(hObject, eventdata, handles)
% hObject    handle to savepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    flag = check_paths(handles);
    
    if flag
        
        station = get_station(handles);
        xml = loadXML(handles.xmlfile, 'config');
        xmlPath = strcat('config/paths/site[name=', station, ']');
        
        removeNode(xml, xmlPath);
        
        pathsElement = createNode(xml, xmlPath);
        
        createLeave(xml, pathsElement, 'pathOblique', sprintf('%s', get(handles.pathObliqueText,'String')))
        createLeave(xml, pathsElement, 'pathRectified', sprintf('%s', get(handles.pathRectifiedText,'String')))
        createLeave(xml, pathsElement, 'pathMergeOblique', sprintf('%s', get(handles.pathMergeObliqueText,'String')))
        createLeave(xml, pathsElement, 'pathMergeRectified', sprintf('%s', get(handles.pathMergeRectifiedText,'String')))
        createLeave(xml, pathsElement, 'pathObliqueMin', sprintf('%s', get(handles.pathObliqueMinText,'String')))
        createLeave(xml, pathsElement, 'pathRectifiedMin', sprintf('%s', get(handles.pathRectifiedMinText,'String')))
        createLeave(xml, pathsElement, 'pathMergeObliqueMin', sprintf('%s', get(handles.pathMergeObliqueMinText,'String')))
        createLeave(xml, pathsElement, 'pathMergeRectifiedMin',sprintf('%s', get(handles.pathMergeRectifiedMinText,'String')))
        
        try
            xmlsave(handles.xmlfile, xml);
            warndlg('Update successful','Successful');
        catch e
            warndlg('Update unsuccessful','Unsuccessful');
        end
        
    else
        warndlg('There was an error, check the fields in red. Remember that paths must be a folder or a URL','Warning');
    end
catch e
    disp(e.message)
end

function flag = check_paths(handles)

try
    % Checks paths to be a folder or a URL
    flag=1;
    find = strfind(get(handles.pathObliqueText,'String'),'http://');
    if ~isdir(get(handles.pathObliqueText,'String')) && isempty(find)
        set(handles.pathObliqueText,'BackgroundColor',[1 0 0])
        flag=0;
    else
        set(handles.pathObliqueText,'BackgroundColor',[1 1 1])
    end
    find = strfind(get(handles.pathRectifiedText,'String'),'http://');
    if ~isdir(get(handles.pathRectifiedText,'String')) && isempty(find)
        set(handles.pathRectifiedText,'BackgroundColor',[1 0 0])
        flag=0;
    else
        set(handles.pathRectifiedText,'BackgroundColor',[1 1 1])
    end
    find = strfind(get(handles.pathMergeObliqueText,'String'),'http://');
    if ~isdir(get(handles.pathMergeObliqueText,'String')) && isempty(find)
        set(handles.pathMergeObliqueText,'BackgroundColor',[1 0 0])
        flag=0;
    else
        set(handles.pathMergeObliqueText,'BackgroundColor',[1 1 1])
    end
    find = strfind(get(handles.pathMergeRectifiedText,'String'),'http://');
    if ~isdir(get(handles.pathMergeRectifiedText,'String')) && isempty(find)
        set(handles.pathMergeRectifiedText,'BackgroundColor',[1 0 0])
        flag=0;
    else
        set(handles.pathMergeRectifiedText,'BackgroundColor',[1 1 1])
    end
    find = strfind(get(handles.pathObliqueMinText,'String'),'http://');
    if ~isdir(get(handles.pathObliqueMinText,'String')) && isempty(find)
        set(handles.pathObliqueMinText,'BackgroundColor',[1 0 0])
        flag=0;
    else
        set(handles.pathObliqueMinText,'BackgroundColor',[1 1 1])
    end
    find = strfind(get(handles.pathMergeObliqueMinText,'String'),'http://');
    if ~isdir(get(handles.pathMergeObliqueMinText,'String')) && isempty(find)
        set(handles.pathMergeObliqueMinText,'BackgroundColor',[1 0 0])
        flag=0;
    else
        set(handles.pathMergeObliqueMinText,'BackgroundColor',[1 1 1])
    end
    find = strfind(get(handles.pathRectifiedMinText,'String'),'http://');
    if ~isdir(get(handles.pathRectifiedMinText,'String')) && isempty(find)
        set(handles.pathRectifiedMinText,'BackgroundColor',[1 0 0])
        flag=0;
    else
        set(handles.pathRectifiedMinText,'BackgroundColor',[1 1 1])
    end
    find = strfind(get(handles.pathMergeRectifiedMinText,'String'),'http://');
    if ~isdir(get(handles.pathMergeRectifiedMinText,'String')) && isempty(find)
        set(handles.pathMergeRectifiedMinText,'BackgroundColor',[1 0 0])
        flag=0;
    else
        set(handles.pathMergeRectifiedMinText,'BackgroundColor',[1 1 1])
    end
catch e
    disp(e.message)
end

% Get station
function station = get_station(handles)
try
    value = get(handles.stationSelect, 'Value');
    contents = cellstr(get(handles.stationSelect, 'String'));
    station = contents{value};
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
