function varargout = gui_upload_hosting(varargin)
% GUI_UPLOAD_HOSTING MATLAB code for gui_upload_hosting.fig
%      GUI_UPLOAD_HOSTING, by itself, creates a new GUI_UPLOAD_HOSTING or raises the existing
%      singleton*.
%
%      H = GUI_UPLOAD_HOSTING returns the handle to a new GUI_UPLOAD_HOSTING or the handle to
%      the existing singleton*.
%
%      GUI_UPLOAD_HOSTING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_UPLOAD_HOSTING.M with the given input arguments.
%
%      GUI_UPLOAD_HOSTING('Property','Value',...) creates a new GUI_UPLOAD_HOSTING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_upload_hosting_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_upload_hosting_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_upload_hosting

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
% Last Modified by GUIDE v2.5 03-Sep-2012 18:37:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @gui_upload_hosting_OpeningFcn, ...
    'gui_OutputFcn',  @gui_upload_hosting_OutputFcn, ...
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


% --- Executes just before gui_upload_hosting is made visible.
function gui_upload_hosting_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_upload_hosting (see VARARGIN)

try
    % Choose default command line output for gui_upload_hosting
    handles.output = hObject;
    
    % Set HORUS paths
    if ~isdeployed
        root = fileparts(mfilename('fullpath'));
        handles.root = fileparts(root);
        addpath(genpath(handles.root));
        handles.datapath = fullfile(handles.root, 'data');
    else
        pathinfo = what('data');
        handles.datapath = pathinfo.path;
    end
    
    handles.xmlfile = 'processing_info.xml';
    handles.Rectified = 'false';
    handles.Oblique = 'false';
    handles.MergedRectified = 'false';
    handles.MergedOblique = 'false';
    handles.ThumbWidth = '';
    handles.UploadThumbs = 'false';
    handles.Types = cell(0);
    
    try
        handles.conn = connection_db();
    catch e
        disp(e.message)
        return
    end
    
    % Put logo
    logo = imread('LogoHorusMin.png');
    imshow(logo, 'Parent', handles.axesLogo)
    
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
    
    % Update handles structure
    guidata(hObject, handles);
catch e
    disp(e.message)
end
% UIWAIT makes gui_upload_hosting wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_upload_hosting_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function textFTPHost_Callback(hObject, eventdata, handles)
% hObject    handle to textFTPHost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textFTPHost as text
%        str2double(get(hObject,'String')) returns contents of textFTPHost as a double

try
    check_data(handles);
    
    set(handles.Upload,'Enable','off')
    if isempty(get(handles.textFTPHost,'String'))
        warndlg('The FTP host cannot be empty','Warning');
    end
catch e
    disp(e.message)
end

function textFTPUser_Callback(hObject, eventdata, handles)
% hObject    handle to textFTPUser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textFTPUser as text
%        str2double(get(hObject,'String')) returns contents of textFTPUser as a double

try
    check_data(handles);
    set(handles.Upload,'Enable','off')
    if isempty(get(handles.textFTPUser,'String'))
        warndlg('The FTP user cannot be empty','Warning');
    end
catch e
    disp(e.message)
end

function textFTPPass_Callback(hObject, eventdata, handles)
% hObject    handle to textFTPPass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textFTPPass as text
%        str2double(get(hObject,'String')) returns contents of textFTPPass as a double

try
    handles.FTPPassw = get_ftp_pass(handles);
    check_data(handles);
    set(handles.Upload,'Enable','off')
    if isempty(handles.FTPPassw)
        warndlg('The FTP password cannot be empty','Warning');
    end
    % Update handles structure
    guidata(hObject, handles);
catch e
    disp(e.message)
end

% --- Executes on button press in Upload.
function Upload_Callback(hObject, eventdata, handles)
% hObject    handle to Upload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    station = get_station(handles);
    status = upload_hosting(station,1);
    
    if status ==0
        warndlg('Upload all thumbnail successful','Successful');
    else
        warndlg('Upload all thumbnail unsuccessful','Unsuccessful');
    end
catch e
    disp(e.message)
end

% --- Executes on selection change in popupStation.
function popupStation_Callback(hObject, eventdata, handles)
% hObject    handle to popupStation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupStation contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupStation

try
    set(handles.textFTPHost, 'String', '')
    set(handles.textFTPUser, 'String', '')
    set(handles.textFTPPass, 'String', '')
    set(handles.Upload,'Enable','off')
    set(handles.Save,'Enable','off')
    if check_station(handles)
        
        
        station = get_station(handles);
        xml = loadXML(handles.xmlfile, 'Configuration', 'station', station);
        xmlPath = strcat('Configuration[station=', station, ']/ThumbnailsConfig');
        thumbnailsNodes = getNodes(xml, xmlPath);
        
        if ~isempty(thumbnailsNodes)
            thumbnails = thumbnailsNodes{1};
            
            val = getNodeVal(thumbnails, 'UploadFTPHost');
            set(handles.textFTPHost, 'String', val)
            
            val = getNodeVal(thumbnails, 'UploadFTPUser');
            set(handles.textFTPUser, 'String', val)
            
            val = getNodeVal(thumbnails, 'UploadFTPPass');
            val = decrypt_aes(val, handles.datapath);
            set(handles.textFTPPass, 'String', val)
            
            handles.Rectified = getNodeVal(thumbnails, 'Rectified');
            
            handles.Oblique = getNodeVal(thumbnails, 'Oblique');
            
            handles.MergedRectified = getNodeVal(thumbnails, 'MergedRectified');
            
            handles.MergedOblique = getNodeVal(thumbnails, 'MergedOblique');
            
            handles.ThumbWidth = getNodeVal(thumbnails, 'ThumbWidth');
            
            handles.UploadThumbs = getNodeVal(thumbnails, 'UploadThumbs');
            
            %reboot connection to the database if necessary
            [handles.conn status] = renew_connection_db(handles.conn);
            
            if status == 1
                return
            end
            
            types = load_imagetype_name(handles.conn, station);
            for k = 1:numel(types)
                val = getNodeVal(thumbnails, char(types(k)));
                if ~isempty(val)
                    if eval(val)
                        handles.Types{end+1} = char(types(k));
                    end
                end
            end
            
            set(handles.Upload,'Enable','on')
            
        end
        set(handles.textFTPHost,'Enable','on')
        set(handles.textFTPUser,'Enable','on')
        set(handles.textFTPPass,'Enable','on')
        % Update handles structure
        guidata(hObject, handles);
    end
catch e
    disp(e.message)
end


% --- Executes on button press in Save.
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    station = get_station(handles);
    xml = loadXML(handles.xmlfile, 'Configuration', 'station', station);
    xmlPath = strcat('Configuration[station=', station, ']/ThumbnailsConfig');
    
    removeNode(xml, xmlPath);
    
    thumbsElement = createNode(xml, xmlPath);
    
    host = get_ftp_host(handles);
    user = get_ftp_user(handles);
    pass = get_ftp_pass(handles);
    % Encrypt password
    pass = encrypt_aes(pass, handles.datapath);
    
    createLeave(xml, thumbsElement, 'Rectified', sprintf('%s', handles.Rectified))
    createLeave(xml, thumbsElement, 'Oblique', sprintf('%s', handles.Oblique))
    createLeave(xml, thumbsElement, 'MergedRectified', sprintf('%s', handles.MergedRectified))
    createLeave(xml, thumbsElement, 'MergedOblique', sprintf('%s', handles.MergedOblique))
    createLeave(xml, thumbsElement, 'ThumbWidth', sprintf('%s', handles.ThumbWidth))
    createLeave(xml, thumbsElement, 'UploadThumbs', sprintf('%s', handles.UploadThumbs))
    createLeave(xml, thumbsElement, 'UploadFTPHost', sprintf('%s', host))
    createLeave(xml, thumbsElement, 'UploadFTPUser',sprintf('%s', user))
    createLeave(xml, thumbsElement, 'UploadFTPPass',sprintf('%s', pass))
    
    %reboot connection to the database if necessary
    [handles.conn status] = renew_connection_db(handles.conn);
    
    if status == 1
        return
    end
    
    types = load_imagetype_name(handles.conn, station);
    isfalse = true;
    for i = 1:numel(types)
        for j = 1:numel(handles.Types)
            if strcmpi(char(handles.Types(j)),char(types(i)))
                createLeave(xml, thumbsElement, char(types(i)), sprintf('%s', 'true'))
                isfalse = false;
                break;
            end
        end
        
        if isfalse
            createLeave(xml, thumbsElement, char(types(i)), sprintf('%s', 'false'))
        end
        isfalse = true;
    end
    
    xmlsave(handles.xmlfile, xml);
    set(handles.Upload,'Enable','on')
    set(handles.Save,'Enable','off')
    warndlg('Thumbnails transfer configuration was successfully saved!','Successful');
    
    % Update handles structure
    guidata(hObject, handles);
catch e
    disp(e.message)
end

function ok = check_station(handles)
try
    value = get(handles.popupStation, 'Value');
    ok = value ~= 1;
catch e
    disp(e.message)
end

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
% Returns the selected FTP host
function value = get_ftp_host(handles)
try
    value = get(handles.textFTPHost, 'String');
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected FTP user
function value = get_ftp_user(handles)
try
    value = get(handles.textFTPUser, 'String');
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected FTP password
function value = get_ftp_pass(handles)
try
    value = get(handles.textFTPPass, 'String');
catch e
    disp(e.message)
end

function check_data(handles)

try
    flag = 1;
    if isempty(get_ftp_host(handles))
        set(handles.Save,'Enable','off')
        flag=0;
    end
    
    if isempty(get_ftp_user(handles))
        set(handles.Save,'Enable','off')
        flag=0;
    end
    
    if isempty(get_ftp_pass(handles))
        set(handles.Save,'Enable','off')
        flag=0;
    end
    
    if flag==1
        set(handles.Save,'Enable','on')
    end
catch e
    disp(e.message)
end

% --- Executes on key press with focus on textFTPPass and none of its controls.
function textFTPPass_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to textFTPPass (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

try
    if ~isempty(eventdata.Character)
        set(handles.Save,'Enable','on')
        set(handles.Upload,'Enable','off')
    else
        set(handles.Save,'Enable','off')
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
