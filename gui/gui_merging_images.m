function varargout = gui_merging_images(varargin)
% GUI_MERGING_IMAGES M-file for gui_merging_images.fig
%      GUI_MERGING_IMAGES, by itself, creates a new GUI_MERGING_IMAGES or raises the existing
%      singleton*.
%
%      H = GUI_MERGING_IMAGES returns the handle to a new GUI_MERGING_IMAGES or the handle to
%      the existing singleton*.
%
%      GUI_MERGING_IMAGES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_MERGING_IMAGES.M with the given input arguments.
%
%      GUI_MERGING_IMAGES('Property','Value',...) creates a new GUI_MERGING_IMAGES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_merging_images_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_merging_images_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_merging_images

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
% Last Modified by GUIDE v2.5 03-Sep-2012 13:45:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @gui_merging_images_OpeningFcn, ...
    'gui_OutputFcn',  @gui_merging_images_OutputFcn, ...
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


% --- Executes just before gui_merging_images is made visible.
function gui_merging_images_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_merging_images (see VARARGIN)

try
    
    % Choose default command line output for gui_merging_images
    handles.output = hObject;
    
    % Set HORUS paths
    if ~isdeployed
        root = fileparts(mfilename('fullpath'));
        root = fileparts(root);
        addpath(genpath(root));
    end
    
    handles.savePath = [];
    
    handles.hDateboxInit = []; % Matlab object for DateSpinnerComboBox
    handles.dateboxInit = []; % Java object for DateSpinnerComboBox
    handles.hDateboxFinal = []; % Matlab object for DateSpinnerComboBox
    handles.dateboxFinal = []; % Java object for DateSpinnerComboBox
    
    handles.time_min_rect = []; % Minimum time of rectified images
    handles.time_max_rect = []; % Maximum time of rectified images
    handles.time_min_obl = []; % Minimum time of oblique images
    handles.time_max_obl = []; % Maximum time of oblique images
    
    % Initialize JIDE's usage within Matlab
    com.mathworks.mwswing.MJUtilities.initJIDE;
    
    % Display a DateSpinnerComboBox
    handles.dateboxInit = com.jidesoft.combobox.DateSpinnerComboBox; % Constructor
    handles.dateboxFinal = com.jidesoft.combobox.DateSpinnerComboBox; % Constructor
    
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
    
    % Set empty set of image type
    set(handles.popupImageType, 'String', {'Select image type'});
    
    set(handles.popupFusion, 'String', {'Default (nearest before time)'});
    
    % Set error between images from different cameras to [0; 10]
    strError = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    set(handles.popupTimeError, 'String', strError);
    
    % Set Save images in disk only as default
    set(handles.radioSaveDisk, 'Value', 1)
    set(handles.buttonPath, 'Enable', 'on')
    
    % Put logo
    logo = imread('LogoHorusMin.png');
    imshow(logo, 'Parent', handles.axesLogo);
    
    % Update handles structure
    guidata(hObject, handles);
    
catch e
    disp(e.message)
end
% UIWAIT makes gui_merging_images wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_merging_images_OutputFcn(hObject, eventdata, handles)
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
        station = get_station(handles);
               
        %reboot connection to the database if necessary
        [handles.conn status] = renew_connection_db(handles.conn);

        if status == 1
            return
        end
        
        handles.time_min_rect = cell2mat(load_datemin(handles.conn, 'rectified', station, false));
        handles.time_max_rect = cell2mat(load_datemax(handles.conn, 'rectified', station, false));
        handles.time_min_obl = cell2mat(load_datemin(handles.conn, 'oblique', station, false));
        handles.time_max_obl = cell2mat(load_datemax(handles.conn, 'oblique', station, false));
        
        % Initialize stations in popup menu
        h = gui_message('Loading from database, this might take a while!','Loading...');
         % Initialize image types: rectified, oblique
        strType = {'Select image type'};
        types = load_imagetype_name(handles.conn, station);
        if ishandle(h)
            delete(h);
        end

        for i = 1:numel(types)
            strType{i + 1} = types{i};
        end

        set(handles.popupImageType, 'String', strType);
        
    else
        set(handles.popupImageType, 'String', {'Select image type'}, 'Value', 1);
        set(handles.popupFusion, 'String', {'Default (nearest before time)'}, 'Value', 1);
        set(handles.radioRectify, 'Value', 0)
        set(handles.radioAlreadyRectified, 'Value', 0)
        set(handles.popupTimeError, 'Value', 1)
        set(handles.editTimeStep, 'String', '')
        set(handles.radioSaveDB, 'Value', 0)
        set(handles.radioSaveDisk, 'Value', 1)
    end
    
    if check_station(handles) && check_imgtype(handles)
        set(handles.buttonStartFusion, 'Enable', 'on')
        set(handles.radioSaveDB, 'Enable', 'on')
        % Set time sliders
        handles = reload_time(handles);
        handles = reload_fusion_time(handles);
        station = get_station(handles);
        
        handles.time_min_rect = cell2mat(load_datemin(handles.conn, 'rectified', station, false));
        handles.time_max_rect = cell2mat(load_datemax(handles.conn, 'rectified', station, false));
        handles.time_min_obl = cell2mat(load_datemin(handles.conn, 'oblique', station, false));
        handles.time_max_obl = cell2mat(load_datemax(handles.conn, 'oblique', station, false));
    else
        set(handles.buttonStartFusion, 'Enable', 'off')
        set(handles.radioSaveDB, 'Enable', 'off')
        set(handles.buttonSeemore, 'Enable', 'off')
    end
    
    % Update handles structure
    guidata(hObject, handles);
catch e
    disp(e.message)
end

% --- Executes on selection change in popupImageType.
function popupImageType_Callback(hObject, eventdata, handles)
% hObject    handle to popupImageType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupImageType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupImageType

try
    
    if check_station(handles) && check_imgtype(handles)
        set(handles.buttonStartFusion, 'Enable', 'on')
        set(handles.radioSaveDB, 'Enable', 'on')
        % Set time sliders
        handles = reload_time(handles);
        handles = reload_fusion_time(handles);
        
        % Update handles structure
        guidata(hObject, handles);
    else
        set(handles.buttonStartFusion, 'Enable', 'off')
        set(handles.radioSaveDB, 'Enable', 'off')
        set(handles.buttonSeemore, 'Enable', 'off')
    end
catch e
    disp(e.message)
end

% --- Executes on button press in buttonStartFusion.
function buttonStartFusion_Callback(hObject, eventdata, handles)
% hObject    handle to buttonStartFusion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    isrectified = get(handles.radioAlreadyRectified, 'Value');
    rectify = get(handles.radioRectify, 'Value');
    
    ok = true;
    
    if ~check_station(handles)
        warndlg({'You must select a station!', 'Please select a station'},'Warning');
        ok = false;
    end
    if ~check_imgtype(handles)
        warndlg({'You must select an image type!', 'Please select an image type'},'Warning');
        ok = false;
    end
    
    if ok
        % Gather fusion parameters
        station = get_station(handles);
        imgtype = get_imgtype(handles);
        error = get_error(handles);
        ti = get_initial_time(handles);
        tf = get_final_time(handles);
        step = get_time_step(handles);
        saveDB = get(handles.radioSaveDB, 'Value');
        saveDisk = get(handles.radioSaveDisk, 'Value');
        
        custime = [];
        custimeval = get(handles.popupFusion, 'Value');
        if custimeval > 1
            timestr = get(handles.popupFusion, 'String');
            custime = datenum(timestr(custimeval));
        end
        
        if isnan(step)
            errordlg('The time step must be numeric!');
            return;
        end
        
        % Generate path where the images will be saved
        ok = true;
        
        % Load default path for merged images
        if ~exist('path_info.xml', 'file')
            errordlg('The file path_info.xml does not exist!', 'Error');
            return;
        end
        
        [pathOblique pathRectified pathMergeOblique pathMergeRectified] = ...
            load_paths('path_info.xml', station);
        if isrectified || rectify
            root = pathMergeRectified; %% ROOT
        else
            root = pathMergeOblique; %% ROOT
        end
        if saveDisk
            if ~isempty(handles.savePath)
                root = handles.savePath;
            else
                ok = false;
                %%% WARNING
                warndlg({'You must select a destination path for the images!',...
                    'Please select a path'},'Warning');
            end
        end
        
        if ok
            % Ask the user if he is sure about continuing
            choice = questdlg('The fusion process is about to start. Do you want to continue?', ...
                'Start fusion', 'Yes', 'No','No');
            
            if strcmp(choice, 'No')
                return
            end
            % Do the fusion
            message = fusion(station, imgtype, isrectified, rectify, ti, tf, step, error, true, ...
                root, saveDB, custime);
            if ~isempty(message)
                errordlg(message, 'Error');
                return;
            end
        end
    end
    
catch e
    disp(e.message)
end

% --- Executes on button press in buttonPath.
function buttonPath_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    handles.savePath = uigetdir('.');
    
    if handles.savePath == 0
        handles.savePath = [];
    end
    set(handles.editPath, 'String', handles.savePath)
    
    % Update handles structure
    guidata(hObject, handles);
    
catch e
    disp(e.message)
end


% --- Executes on button press in radioAlreadyRectified.
function radioAlreadyRectified_Callback(hObject, eventdata, handles)
% hObject    handle to radioAlreadyRectified (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioAlreadyRectified

try
    on = get(hObject, 'Value');
    if on
        set(handles.radioRectify, 'Value', false)
        set(handles.radioRectify, 'Enable', 'off')
    else
        set(handles.radioRectify, 'Enable', 'on')
    end
    
    if check_station(handles) && check_imgtype(handles)
        handles = reload_fusion_time(handles);
    end
    % Update handles structure
    guidata(hObject, handles);
    
catch e
    disp(e.message)
end

% --- Executes on button press in radioRectify.
function radioRectify_Callback(hObject, eventdata, handles)
% hObject    handle to radioRectify (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioRectify
try
    if check_station(handles) && check_imgtype(handles)
        handles = reload_fusion_time(handles);
    end
    % Update handles structure
    guidata(hObject, handles);
    
catch e
    disp(e.message)
end


% --- Executes on button press in radioSaveDB.
function radioSaveDB_Callback(hObject, eventdata, handles)
% hObject    handle to radioSaveDB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioSaveDB

try
    on = get(hObject, 'Value');
    if on
        set(handles.radioSaveDisk, 'Value', false)
        set(handles.editPath, 'Enable', 'off')
        set(handles.buttonPath, 'Enable', 'off')
    else
        set(handles.radioSaveDB, 'Value', true);
    end
    
    if check_station(handles) && check_imgtype(handles)
        handles = reload_fusion_time(handles);
    end
    % Update handles structure
    guidata(hObject, handles);
catch e
    disp(e.message)
end

% --- Executes on button press in radioSaveDisk.
function radioSaveDisk_Callback(hObject, eventdata, handles)
% hObject    handle to radioSaveDisk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioSaveDisk

try
    on = get(hObject, 'Value');
    if on
        set(handles.radioSaveDB, 'Value', false)
        set(handles.editPath, 'Enable', 'on')
        set(handles.buttonPath, 'Enable', 'on')
    else
        set(handles.radioSaveDisk, 'Value', true);
    end
catch e
    disp(e.message)
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

%--------------------------------------------------------------------------
% Check if there is a valid time error selected
function ok = check_error(handles)
try
    value = get(handles.popupTimeError, 'Value');
    ok = value ~= 1;
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Check if there is a valid image type selected
function ok = check_imgtype(handles)
try
    value = get(handles.popupImageType, 'Value');
    ok = value ~= 1;
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Check if there is a valid initial time selected
function ok = check_initial_time(handles)
try
    ok = ~isempty(handles.dateboxInit);
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Check if there is a valid final time selected
function ok = check_final_time(handles)
try
    ok = ~isempty(handles.dateboxFinal);
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
% Returns the selected time error
function error = get_error(handles)
try
    value = get(handles.popupTimeError, 'Value');
    contents = cellstr(get(handles.popupTimeError, 'String'));
    error = str2double(contents{value});
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected image type
function camera = get_imgtype(handles)
try
    value = get(handles.popupImageType, 'Value');
    contents = cellstr(get(handles.popupImageType, 'String'));
    camera = contents{value};
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected initial time
function time = get_initial_time(handles)

try
    % Java stuff
    calObj = handles.dateboxInit.getCalendar();
    
    % Time zone offset in millis, with Daylight Saving Time
    tzOffset = calObj.get(calObj.ZONE_OFFSET) + calObj.get(calObj.DST_OFFSET);
    
    epoch = (calObj.getTimeInMillis() + tzOffset) / 1000;
    
    % get reference time
    refTime = datenum('1-jan-1970 00:00:00');
    
    % how much later than reference time is input?
    offset = epoch / (24*3600);
    
    % add and return
    time = refTime + offset;
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected final time
function time = get_final_time(handles)

try
    % Java stuff
    calObj = handles.dateboxFinal.getCalendar();
    
    % Time zone offset in millis, with Daylight Saving Time
    tzOffset = calObj.get(calObj.ZONE_OFFSET) + calObj.get(calObj.DST_OFFSET);
    
    epoch = (calObj.getTimeInMillis() + tzOffset) / 1000;
    
    % get reference time
    refTime = datenum('1-jan-1970 00:00:00');
    
    % how much later than reference time is input?
    offset = epoch / (24*3600);
    
    % add and return
    time = refTime + offset;
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected image search time step
function step = get_time_step(handles)
try
    step = str2double(get(handles.editTimeStep, 'String'));
catch e
    disp(e.message)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
% Reload the time sliders, updating the initial and final times for each
function handles = reload_time(handles)

try
    % Set time sliders
    
    if check_station(handles) && check_imgtype(handles)
        
        % JAVA stuff: load calendar for choosing date & time
        
        handles.dateboxInit.setLocale(java.util.Locale.ENGLISH); % Set English language
        handles.dateboxInit.setTimeDisplayed(true); % Show time
        handles.dateboxInit.setFormat(java.text.SimpleDateFormat('dd/MM/yyyy HH:mm:ss')); % Set date & time format
        handles.dateboxInit.setTimeFormat('HH:mm:ss'); % Set time format (in the grid)
        handles.dateboxInit.setFont(java.awt.Font('SansSerif', java.awt.Font.PLAIN, 10)); % Set fonts
        
        handles.dateboxInit.setShowWeekNumbers(false); % Do not show week number
        handles.dateboxInit.setShowNoneButton(false); % Do not show the 'None' button
        handles.dateboxInit.setShowOKButton(true); % Show the 'OK' button
        handles.dateboxInit.setShowTodayButton(true) % Show the 'Today' button
        
        handles.dateboxFinal.setLocale(java.util.Locale.ENGLISH); % Set English language
        handles.dateboxFinal.setTimeDisplayed(true); % Show time
        handles.dateboxFinal.setFormat(java.text.SimpleDateFormat('dd/MM/yyyy HH:mm:ss')); % Set date & time format
        handles.dateboxFinal.setTimeFormat('HH:mm:ss'); % Set time format (in the grid)
        handles.dateboxFinal.setFont(java.awt.Font('SansSerif', java.awt.Font.PLAIN, 10)); % Set fonts
        
        handles.dateboxFinal.setShowWeekNumbers(false); % Do not show week number
        handles.dateboxFinal.setShowNoneButton(false); % Do not show the 'None' button
        handles.dateboxFinal.setShowOKButton(true); % Show the 'OK' button
        handles.dateboxFinal.setShowTodayButton(true) % Show the 'Today' button
        
        isrectified = get(handles.radioAlreadyRectified, 'Value');
        
        if isrectified
            time_min = handles.time_min_rect;
            time_max = handles.time_max_rect;
        else
            time_min = handles.time_min_obl;
            time_max = handles.time_max_obl;
        end
        
        timevec1 = datevec(time_min);
        handles.dateboxInit.setCalendar(java.util.GregorianCalendar(timevec1(1), timevec1(2) - 1, ...
            timevec1(3), timevec1(4), timevec1(5), timevec1(6)));
        
        timevec2 = datevec(time_max);
        handles.dateboxFinal.setCalendar(java.util.GregorianCalendar(timevec2(1), timevec2(2) - 1, ...
            timevec2(3), timevec2(4), timevec2(5), timevec2(6)));
        
        % Put the DateSpinnerComboBox object in a GUI panel
        [handles.hDateboxInit,hContainer] = javacomponent(handles.dateboxInit,[2,3,200,20],handles.panelInitTime);
        [handles.hDateboxFinal,hContainer] = javacomponent(handles.dateboxFinal,[2,3,200,20],handles.panelFinalTime);
        
        set(handles.hDateboxInit, 'ActionPerformedCallback', {@timeInitCallbackFunction, handles});
        set(handles.hDateboxFinal, 'ActionPerformedCallback', {@timeFinalCallbackFunction, handles});
    end
    
catch e
    disp(e.message)
end

% Callback for DateSpinnerComboBox object
function timeInitCallbackFunction(hObject, eventdata, handles)

try
    
    if check_station(handles)
        
        % JAVA stuff: load calendar for choosing date & time
        
        isrectified = get(handles.radioAlreadyRectified, 'Value');
        
        if isrectified
            time_min = handles.time_min_rect;
            time_max = handles.time_max_rect;
        else
            time_min = handles.time_min_obl;
            time_max = handles.time_max_obl;
        end
        
        inittime = get_initial_time(handles);
        finaltime = get_final_time(handles);
        
        if inittime < time_min
            timevec = datevec(time_min);
            handles.dateboxInit.setCalendar(java.util.GregorianCalendar(timevec(1), timevec(2) - 1, ...
                timevec(3), timevec(4), timevec(5), timevec(6)));
        elseif inittime > finaltime
            timevec = datevec(min(time_max, finaltime));
            handles.dateboxInit.setCalendar(java.util.GregorianCalendar(timevec(1), timevec(2) - 1, ...
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
        
        isrectified = get(handles.radioAlreadyRectified, 'Value');
        
        if isrectified
            time_min = handles.time_min_rect;
            time_max = handles.time_max_rect;
        else
            time_min = handles.time_min_obl;
            time_max = handles.time_max_obl;
        end
        
        inittime = get_initial_time(handles);
        finaltime = get_final_time(handles);
        
        if finaltime < inittime
            timevec = datevec(max(time_min, inittime));
            handles.dateboxFinal.setCalendar(java.util.GregorianCalendar(timevec(1), timevec(2) - 1, ...
                timevec(3), timevec(4), timevec(5), timevec(6)));
        elseif finaltime > time_max
            timevec = datevec(time_max);
            handles.dateboxFinal.setCalendar(java.util.GregorianCalendar(timevec(1), timevec(2) - 1, ...
                timevec(3), timevec(4), timevec(5), timevec(6)));
        end
    end
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Reload fusion times
function handles = reload_fusion_time(handles)

try
    if check_station(handles) && check_imgtype(handles)
        station = get_station(handles);
        
        %reboot connection to the database if necessary
        [handles.conn status] = renew_connection_db(handles.conn);

        if status == 1
            return
        end
        
        isrectified = get(handles.radioAlreadyRectified, 'Value');
        rectify = get(handles.radioRectify, 'Value');
        
        type = 'oblique';
        if isrectified || rectify
            type = 'rectified';
        end
        timestamps = load_fusion_times(handles.conn, station, type);

        cellstr = {'Default (nearest before time)'};

        for i = 1:numel(timestamps)
            cellstr{i + 1} = datestr(timestamps{i});
        end

        set(handles.popupFusion, 'String', cellstr);
    end
catch e
    disp(e.message)
end


% --- Executes on selection change in popupFusion.
function popupFusion_Callback(hObject, eventdata, handles)
% hObject    handle to popupFusion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupFusion contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupFusion

try
    if get(handles.popupFusion,'value')>1
        set(handles.buttonSeemore, 'Enable', 'on')
    else
        set(handles.buttonSeemore, 'Enable', 'off')
    end
catch e
    disp(e.message)
end

% --- Executes on button press in buttonSeemore.
function buttonSeemore_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSeemore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    [handles.conn status] = renew_connection_db(handles.conn);

    if status == 1
        return
    end
    
    station = get_station(handles);
    tf = get_final_time(handles);
    isrectified = get(handles.radioAlreadyRectified, 'Value');
    
    if isrectified
        imgtype2 = 'rectified';
    else
        imgtype2 = 'oblique';
    end
    
    cameras = load_camerasbyfusion(handles.conn, station, imgtype2, tf);
    
    msg1 = '                 Fusion information:                      ';
    msg2 = 'The sequence of cameras is: ';
    msg3 = [];
    for i=1:numel(cameras)
        msg3 = [msg3 cameras{i} ];
        if i ~= numel(cameras)
            msg3 = [msg3 ' - '];
        end
    end
        msgbox({msg1,msg2,msg3},'Fusion information')
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
