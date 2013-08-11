function varargout = gui_thumbnails_tool(varargin)
% GUI_THUMBNAILS_TOOL M-file for gui_thumbnails_tool.fig
%      GUI_THUMBNAILS_TOOL, by itself, creates a new GUI_THUMBNAILS_TOOL or raises the existing
%      singleton*.
%
%      H = GUI_THUMBNAILS_TOOL returns the handle to a new GUI_THUMBNAILS_TOOL or the handle to
%      the existing singleton*.
%
%      GUI_THUMBNAILS_TOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_THUMBNAILS_TOOL.M with the given input arguments.
%
%      GUI_THUMBNAILS_TOOL('Property','Value',...) creates a new GUI_THUMBNAILS_TOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_thumbnails_tool_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_thumbnails_tool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_thumbnails_tool

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
% Last Modified by GUIDE v2.5 03-Sep-2012 18:36:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @gui_thumbnails_tool_OpeningFcn, ...
    'gui_OutputFcn',  @gui_thumbnails_tool_OutputFcn, ...
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


% --- Executes just before gui_thumbnails_tool is made visible.
function gui_thumbnails_tool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_thumbnails_tool (see VARARGIN)

try
    % Set paths
    if ~isdeployed
        root = fileparts(mfilename('fullpath'));
        root = fileparts(root);
        addpath(genpath(root));
    end
    
    % Show the logo
    logo=imread('LogoHorusMin.png');
    imshow(logo, 'Parent', handles.logo);
    
    try
        handles.conn = connection_db();
    catch e
        disp(e.message)
        return
    end
    
    
    handles.dateboxInit =[];
    handles.dateboxFinal = [];
    % Initialize stations in popup menu
    
    h=gui_message('Loading from database, this might take a while!',...
        'Loading');
    station=load_station(handles.conn);
    if ishandle(h)
        delete(h);
    end
    stations = cell(0);
    stations{1, 1}= 'Select the station';
    j=2;
    for k = 1:length(station)
        stations{j, 1}=char(station(k));
        j=j+1;
    end
    if (j == 2)
        warndlg({'No station in the database','Be sure to enter the site before proceeding.'},'Warning');
    else
        set(handles.stationSelect,'String',stations);
    end
    
    
    
    % Choose default command line output for gui_thumbnails_tool
    handles.output = hObject;
    
    % Update handles structure
    guidata(hObject, handles);
catch e
    disp(e.message)
end
% UIWAIT makes gui_thumbnails_tool wait for user response (see UIRESUME)
% uiwait(handles.thumbnail);


% --- Outputs from this function are returned to the command line.
function varargout = gui_thumbnails_tool_OutputFcn(hObject, eventdata, handles)
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
        set(handles.TypeSelect,'Value',1,'String',{''})
        set(handles.popupImageType, 'Value', 1, 'String', {''});
        set(handles.listboxImageType, 'Value', 1, 'String', cell(0));
        resert_objects(handles)
        
    else
        % Initialize type in popup menu
        type = {'Select the type of miniature';'oblique';'rectified';'merge_oblique';'merge_rectified'};
        set(handles.TypeSelect,'String',type);
        handles = reload_types(handles);
        
        % Update handles structure
        guidata(hObject, handles);
    end
catch e
    disp(e.message)
end

% --- Executes on selection change in TypeSelect.
function TypeSelect_Callback(hObject, eventdata, handles)
% hObject    handle to TypeSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TypeSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TypeSelect

try
    if get(handles.TypeSelect,'Value')>1
        
        set(handles.Insert_DB,'Enable','on');
        if get(handles.Insert_DB,'Value')==1
            load_path(handles);
        end
        % Display calendar
        handles = reload_time(handles);
    else
        % Reset some part of the GUI
        resert_objects(handles)
    end
    
    % Update handles structure
    guidata(hObject, handles);
catch e
    disp(e.message)
end

function widthText_Callback(hObject, eventdata, handles)
% hObject    handle to widthText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of widthText as text
%        str2double(get(hObject,'String')) returns contents of widthText as a double

try
    % Check width
    check_gen_min(handles)
    width=str2double(get(handles.widthText,'String'));
    if isnan(width)
        warndlg('The desired width must be numeric','Warning');
    end
catch e
    disp(e.message)
end

% --- Executes on button press in Upload.
function Upload_Callback(hObject, eventdata, handles)
% hObject    handle to Upload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Upload

try
    % Check Upload
    if get(handles.Upload,'Value')==1
        set(handles.Insert_disk,'Value',0)
    end
    check_gen_min(handles)
catch e
    disp(e.message)
end

% --- Executes on button press in Insert_DB.
function Insert_DB_Callback(hObject, eventdata, handles)
% hObject    handle to Insert_DB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Insert_DB

try
    if get(handles.Insert_DB,'Value')==1
        set(handles.Insert_disk,'Value',0)
        
        load_path(handles);
        
        if isempty(get(handles.pathText,'String'))
            set(handles.pathText,'Enable','on');
            set(handles.pathButton,'Enable','on');
            warndlg({'The path no is valid','Select another.'},'Warning');
        else
            set(handles.pathText,'Enable','inactive');
            set(handles.pathButton,'Enable','off');
        end
        
    end
    check_gen_min(handles)
catch e
    disp(e.message)
end

% --- Executes on button press in Insert_disk.
function Insert_disk_Callback(hObject, eventdata, handles)
% hObject    handle to Insert_disk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Insert_disk

try
    if get(handles.Insert_disk,'Value')==1
        % Deselect others option
        set(handles.Insert_DB,'Value',0)
        set(handles.Upload,'Value',0)
        set(handles.pathText,'String','');
        set(handles.pathText,'Enable','on');
        set(handles.pathButton,'Enable','on');
    else
        set(handles.pathText,'Enable','inactive');
        set(handles.pathButton,'Enable','off');
    end
    check_gen_min(handles)
catch e
    disp(e.message)
end

% --- Executes on button press in Start.
function Start_Callback(hObject, eventdata, handles)
% hObject    handle to Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    imagetype=cell(0);
    contents = get(handles.listboxImageType, 'String');
    for i=1:numel(contents)
        
        % Image type selected
        imagetype(1,end+1)={char(contents(i))};
    end
    % Date init
    dateinit = get_initial_time(handles);
    % Date final
    datefin = get_final_time(handles);
    width = str2double(get(handles.widthText,'String'));
    set(handles.Start,'Enable','off')
    typemin = get_type(handles);
    station = get_station(handles);
    % Create thumbnail
    status = create_thumbnail(imagetype,typemin, dateinit,station,datefin, ...
        width,get(handles.Upload,'value'),get(handles.Insert_DB,'value'), 1, ...
        get(handles.pathText,'String'));
    if status ==0
        warndlg('Create thumbnail successful','Successful');
    else
        warndlg('Create thumbnail unsuccessful','Unsuccessful');
    end
    set(handles.Start,'Enable','on')
catch e
    disp(e.message)
end

function pathText_Callback(hObject, eventdata, handles)
% hObject    handle to pathText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pathText as text
%        str2double(get(hObject,'String')) returns contents of pathText as a double

try
    % Check path
    check_gen_min(handles)
    if ~isdir(get(handles.pathText,'String'))
        warndlg('The save Thumbnail path must be a folder','Warning');
    end
catch e
    disp(e.message)
end

% --- Executes on button press in pathButton.
function pathButton_Callback(hObject, eventdata, handles)
% hObject    handle to pathButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    % Select path
    path = uigetdir;
    if path ~= 0
        set(handles.pathText,'String',path);
        check_gen_min(handles)
    end
catch e
    disp(e.message)
end

function check_gen_min(handles)

try
    flag=1;
    
    % Check station
    if get(handles.stationSelect,'Value')==1
        set(handles.Start,'Enable','off')
        flag=0;
    end
    % Check type thumbnail
    if get(handles.TypeSelect,'Value')==1
        set(handles.Start,'Enable','off')
        flag=0;
    end
    % Check path
    if ~isdir(get(handles.pathText,'String'))
        set(handles.Start,'Enable','off')
        flag=0;
    end
    % Check image type
    contents = get(handles.listboxImageType, 'String');
    if numel(contents)==0
        set(handles.Start,'Enable','off')
        flag=0;
    end
    
    % Check width
    width=str2double(get(handles.widthText,'String'));
    if isnan(width)
        set(handles.Start,'Enable','off')
        flag=0;
    end
    
    % Check some checkbox
    if get(handles.Insert_disk,'Value')==0 && get(handles.Insert_DB,'Value')==0
        set(handles.Start,'Enable','off')
        flag=0;
    end
    
    if flag==1
        set(handles.Start,'Enable','on')
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

% Get type thumbnail
function type = get_type(handles)
try
    value = get(handles.TypeSelect, 'Value');
    contents = cellstr(get(handles.TypeSelect, 'String'));
    type = contents{value};
catch e
    disp(e.message)
end

% Reset objects in the GUI
function resert_objects(handles)
try
    set(handles.Start,'Enable','off')
    if ~isempty(handles.dateboxInit)
        handles.dateboxInit.setVisible(false)
    end
    if ~isempty(handles.dateboxFinal)
        handles.dateboxFinal.setVisible(false)
    end
    set(handles.pathText,'String','');
    set(handles.Upload,'Value',0);
    set(handles.Insert_DB,'Value',0,'Enable','off');
catch e
    disp(e.message)
end

% Check if there is a valid station selected
function ok = check_station(handles)
try
    value = get(handles.stationSelect, 'Value');
    ok = value ~= 1;
catch e
    disp(e.message)
end

function ok = check_imgtype(handles)
try
    value = get(handles.TypeSelect, 'Value');
    ok = value ~= 1;
catch e
    disp(e.message)
end

function load_path(handles)

try
    station = get_station(handles);
    
    % Load paths
    if ~exist('path_info.xml', 'file')
        errordlg('The file path_info.xml does not exist!', 'Error');
        pathObliqueMin = '';
        pathRectifiedMin = '';
        pathMergeObliqueMin = '';
        pathMergeRectifiedMin = '';
    else
        [pathOblique pathRectified pathMergeOblique pathMergeRectified pathObliqueMin ...
            pathRectifiedMin pathMergeObliqueMin pathMergeRectifiedMin] = ...
            load_paths('path_info.xml',station);
    end
    
    
    % Check paths
    type = get_type(handles);
    if strcmp(type,'oblique')
        find = strfind(strtrim(pathObliqueMin),'http://');
        if ~isdir(strtrim(pathObliqueMin)) && ~isempty(find)
            set(handles.pathText,'String','');
        else
            set(handles.pathText,'String',strtrim(pathObliqueMin));
        end
    elseif strcmp(type,'rectified')
        find = strfind(strtrim(pathRectifiedMin),'http://');
        if ~isdir(strtrim(pathRectifiedMin)) && ~isempty(find)
            set(handles.pathText,'String','');
        else
            set(handles.pathText,'String',strtrim(pathRectifiedMin));
        end
    elseif strcmp(type,'merge_oblique')
        find = strfind(strtrim(pathMergeObliqueMin),'http://');
        if ~isdir(strtrim(pathMergeObliqueMin)) && ~isempty(find)
            set(handles.pathText,'String','');
        else
            set(handles.pathText,'String',strtrim(pathMergeObliqueMin));
        end
    else
        find = strfind(strtrim(pathMergeRectifiedMin),'http://');
        if ~isdir(strtrim(pathMergeRectifiedMin)) && ~isempty(find)
            set(handles.pathText,'String','');
        else
            set(handles.pathText,'String',strtrim(pathMergeRectifiedMin));
        end
    end
catch e
    disp(e.message)
end

function handles = reload_time(handles)

try
    % Set time sliders
    
    if check_station(handles) && check_imgtype(handles)
        
        %reboot connection to the database if necessary
        [handles.conn status] = renew_connection_db(handles.conn);

        if status == 1
            return
        end
        
        station = get_station(handles);
        type = get_type(handles);
        h=gui_message('Loading from database, this might take a while!',...
            'Loading');
        time_min = load_datemin(handles.conn, type, station, false);
        time_min = cell2mat(time_min);
        time_max = load_datemax(handles.conn, type, station, false);
        time_max = cell2mat(time_max);
        if ishandle(h)
            delete(h);
        end
        
        if isempty(time_min)
            time_min = NaN;
            time_max = NaN;
        end
        
        if ~isnan(time_min) && ~isnan(time_max)
            % JAVA stuff: load calendar for choosing date & time
            import java.util.*;
            import java.text.*;
            import java.awt.*;
            
            % Initialize JIDE's usage within Matlab
            com.mathworks.mwswing.MJUtilities.initJIDE;
            
            % Display a DateSpinnerComboBox
            handles.dateboxInit = com.jidesoft.combobox.DateSpinnerComboBox; % Constructor
            handles.dateboxFinal = com.jidesoft.combobox.DateSpinnerComboBox; % Constructor
            
            handles.dateboxInit.setLocale(Locale.ENGLISH); % Set English language
            handles.dateboxInit.setTimeDisplayed(true); % Show time
            handles.dateboxInit.setFormat(SimpleDateFormat('dd/MM/yyyy HH:mm:ss')); % Set date & time format
            handles.dateboxInit.setTimeFormat('HH:mm:ss'); % Set time format (in the grid)
            handles.dateboxInit.setFont(Font('SansSerif', Font.PLAIN, 10)); % Set fonts
            
            handles.dateboxInit.setShowWeekNumbers(false); % Do not show week number
            handles.dateboxInit.setShowNoneButton(false); % Do not show the 'None' button
            handles.dateboxInit.setShowOKButton(true); % Show the 'OK' button
            handles.dateboxInit.setShowTodayButton(true) % Show the 'Today' button
            
            handles.dateboxFinal.setLocale(Locale.ENGLISH); % Set English language
            handles.dateboxFinal.setTimeDisplayed(true); % Show time
            handles.dateboxFinal.setFormat(SimpleDateFormat('dd/MM/yyyy HH:mm:ss')); % Set date & time format
            handles.dateboxFinal.setTimeFormat('HH:mm:ss'); % Set time format (in the grid)
            handles.dateboxFinal.setFont(Font('SansSerif', Font.PLAIN, 10)); % Set fonts
            
            handles.dateboxFinal.setShowWeekNumbers(false); % Do not show week number
            handles.dateboxFinal.setShowNoneButton(false); % Do not show the 'None' button
            handles.dateboxFinal.setShowOKButton(true); % Show the 'OK' button
            handles.dateboxFinal.setShowTodayButton(true) % Show the 'Today' button
            
            timevec1 = datevec(time_min);
            handles.dateboxInit.setCalendar(GregorianCalendar(timevec1(1), timevec1(2) - 1, ...
                timevec1(3), timevec1(4), timevec1(5), timevec1(6)));
            
            timevec2 = datevec(time_max);
            handles.dateboxFinal.setCalendar(GregorianCalendar(timevec2(1), timevec2(2) - 1, ...
                timevec2(3), timevec2(4), timevec2(5), timevec2(6)));
            
            % Put the DateSpinnerComboBox object in a GUI panel
            [handles.hDateboxInit,hContainer] = javacomponent(handles.dateboxInit,[0,0,160,22],handles.dateInitCalendar);
            [handles.hDateboxFinal,hContainer] = javacomponent(handles.dateboxFinal,[0,0,160,22],handles.dateFinCalendar);
            
            set(handles.hDateboxInit, 'ActionPerformedCallback', {@timeInitCallbackFunction, handles});
            set(handles.hDateboxFinal, 'ActionPerformedCallback', {@timeFinalCallbackFunction, handles});
        else
            % Reset some part of the GUI
            resert_objects(handles)
            warndlg({'No images of this type was found.','Select another.'},'Warning');
        end
    end    
catch e
    disp(e.message)
end

% Callback for DateSpinnerComboBox object
function timeInitCallbackFunction(hObject, eventdata, handles)

try
    if check_station(handles)
        
        % JAVA stuff: load calendar for choosing date & time
        import java.util.*;
        import java.text.*;
        import java.awt.*;
        
        station = get_station(handles);
        type = get_type(handles);
        
        %reboot connection to the database if necessary
        [handles.conn status] = renew_connection_db(handles.conn);

        if status == 1
            return
        end
        
        time_min = load_datemin(handles.conn, type, station, false);
        time_min = cell2mat(time_min);
        
        inittime = get_initial_time(handles);
        finaltime = get_final_time(handles);
        if inittime < time_min
            timevec = datevec(time_min);
            handles.dateboxInit.setCalendar(GregorianCalendar(timevec(1), timevec(2) - 1, ...
                timevec(3), timevec(4), timevec(5), timevec(6)));
        elseif inittime > finaltime
            timevec = datevec(finaltime);
            handles.dateboxInit.setCalendar(GregorianCalendar(timevec(1), timevec(2) - 1, ...
                timevec(3), timevec(4), timevec(5), timevec(6)));
        end
    end
catch e
    disp(e.message)
end

% Callback for DateSpinnerComboBox object
function timeFinalCallbackFunction(hObject, eventdata, handles)

try
    if check_station(handles)
        
        % JAVA stuff: load calendar for choosing date & time
        import java.util.*;
        import java.text.*;
        import java.awt.*;
        
        station = get_station(handles);
        type = get_type(handles);
        
        %reboot connection to the database if necessary
        [handles.conn status] = renew_connection_db(handles.conn);

        if status == 1
            return
        end
        
        time_max = load_datemax(handles.conn, type, station, false);
        time_max = cell2mat(time_max);
        
        inittime = get_initial_time(handles);
        finaltime = get_final_time(handles);
        
        if finaltime < inittime
            timevec = datevec(inittime);
            handles.dateboxFinal.setCalendar(GregorianCalendar(timevec(1), timevec(2) - 1, ...
                timevec(3), timevec(4), timevec(5), timevec(6)));
        elseif finaltime > time_max
            timevec = datevec(time_max);
            handles.dateboxFinal.setCalendar(GregorianCalendar(timevec(1), timevec(2) - 1, ...
                timevec(3), timevec(4), timevec(5), timevec(6)));
        end   
    end
catch e
    disp(e.message)
end

function dnum = get_initial_time(handles)

try
    % Get time-----------------------------------------------------------------
    calObj = handles.dateboxInit.getCalendar();
    
    % Time zone offset in millis, with Daylight Saving Time
    tzOffset = calObj.get(calObj.ZONE_OFFSET) + calObj.get(calObj.DST_OFFSET);
    
    epoch = (calObj.getTimeInMillis() + tzOffset) / 1000;
    
    % get reference time
    refTime = datenum('1-jan-1970 00:00:00');
    
    % how much later than reference time is input?
    offset = epoch / (24*3600);
    
    % add and return
    dnum = refTime + offset;
catch e
    disp(e.message)
end

function dnum = get_final_time(handles)

try
    % Get time-----------------------------------------------------------------
    calObj = handles.dateboxFinal.getCalendar();
    
    % Time zone offset in millis, with Daylight Saving Time
    tzOffset = calObj.get(calObj.ZONE_OFFSET) + calObj.get(calObj.DST_OFFSET);
    
    epoch = (calObj.getTimeInMillis() + tzOffset) / 1000;
    
    % get reference time
    refTime = datenum('1-jan-1970 00:00:00');
    
    % how much later than reference time is input?
    offset = epoch / (24*3600);
    
    % add and return
    dnum = refTime + offset;
catch e
    disp(e.message)
end

% --- Executes on button press in buttonAddImageType.
function buttonAddImageType_Callback(hObject, eventdata, handles)
% hObject    handle to buttonAddImageType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    if check_ImageType(handles)
        ImageType = get_ImageType(handles);
        % List of selected thumbs type
        contents = get(handles.listboxImageType, 'String');
        
        found = false;
        for i = 1:numel(contents)
            if strcmp(ImageType, contents{i})
                found = true;
                break;
            end
        end
        
        % If chosen thumbs type is not in the list of selected thumbs type, append it
        if ~found
            contents{end+1} = ImageType;
            set(handles.listboxImageType, 'String', contents);
            
            check_gen_min(handles);
        end
        
    end
catch e
    disp(e.message)
end

% --- Executes on button press in buttonRemoveImageType.
function buttonRemoveImageType_Callback(hObject, eventdata, handles)
% hObject    handle to buttonRemoveImageType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    % List of selected image type
    contents = get(handles.listboxImageType, 'String');
    
    if ~isempty(contents)
        % Unselect a image type from the list
        index = get(handles.listboxImageType, 'Value');
        new = cell(0);
        
        % Copy all the image type but the one to be unselected
        for i = 1:numel(contents)
            if i ~= index
                new{end+1} = contents{i};
            end
        end
        % Reload list
        set(handles.listboxImageType, 'Value', 1, 'String', new);
        
        check_gen_min(handles);
    end
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Check if there is a valid thumbs type selected
function ok = check_ImageType(handles)
try
    value = get(handles.popupImageType, 'Value');
    ok = value ~= 1;
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected thumbs type
function ImageType = get_ImageType(handles)
try
    value = get(handles.popupImageType, 'Value');
    contents = cellstr(get(handles.popupImageType, 'String'));
    ImageType = contents{value};
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Reload all cameras from the database
function handles = reload_types(handles)

try
    if check_station(handles)
        station = get_station(handles);
        
        %reboot connection to the database if necessary
        [handles.conn status] = renew_connection_db(handles.conn);

        if status == 1
            return
        end
        
        h = gui_message('Loading from database, this might take a while!','Loading...');
        types = load_imagetype_name(handles.conn, station);
        if ishandle(h)
            delete(h);
        end
        
        if isempty(types)
            errordlg('No image types were found in the database!', 'Error');
            return;
        end
        
        strtype = {'Select a type'};
        
        for k = 1:numel(types)
            strtype{k + 1} = char(types(k));
        end
        
        set(handles.popupImageType, 'String', strtype);
    end
catch e
    disp(e.message)
end

% --- Executes when user attempts to close thumbnail.
function thumbnail_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to thumbnail (see GCBO)
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
