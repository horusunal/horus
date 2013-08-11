function varargout = gui_genfusion(varargin)
% GUI_GENFUSION M-file for gui_genfusion.fig
%      GUI_GENFUSION, by itself, creates a new GUI_GENFUSION or raises the existing
%      singleton*.
%
%      H = GUI_GENFUSION returns the handle to a new GUI_GENFUSION or the handle to
%      the existing singleton*.
%
%      GUI_GENFUSION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_GENFUSION.M with the given input arguments.
%
%      GUI_GENFUSION('Property','Value',...) creates a new GUI_GENFUSION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_genfusion_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_genfusion_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_genfusion

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
% Last Modified by GUIDE v2.5 03-Sep-2012 18:23:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @gui_genfusion_OpeningFcn, ...
    'gui_OutputFcn',  @gui_genfusion_OutputFcn, ...
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


% --- Executes just before gui_genfusion is made visible.
function gui_genfusion_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_genfusion (see VARARGIN)

try
    
    % Choose default command line output for gui_genfusion
    handles.output = hObject;
    
    % Set HORUS paths
    if ~isdeployed
        root = fileparts(mfilename('fullpath'));
        root = fileparts(root);
        addpath(genpath(root));
    end
    
    handles.images_info = []; % Info of images for every camera: {filename, path, timestamp, camera}
    
    handles.root = ''; % Image root directory
    
    handles.imgleft_index = 0; % Current left image
    
    handles.images = []; % cdata of all images
    
    handles.common_points = struct('cam', cell(0), 'name', cell(0), 'u', cell(0), 'v', cell(0));
    % Common points for this fusion. Cell
    % array where each element is a matrix
    % of mx3 {name, u, v}
    
    handles.commongcps = []; % Common points between cur left and right: {name, uleft, vleft, uright, vright}
    
    handles.uvaffine = []; % Affine points between every pair of cameras
    % uvaffine = {[u1left, v1left], [u1right, v1right], [u2left, v2left], [u2right, v2right], ...}
    %             ------------------------------------  ------------------------------------
    %                     First pair                               Second pair
    
    handles.pickedGCPs = []; % Boolean vector of n elements,
    % n the number of common gcps. 1 if the GCP is picked
    
    handles.motionId = 0;    % 0: No motion, 1: Left motion, 2: Right motion
    
    handles.parameters = []; % Calibration parameters
    
    handles.mergedimg = [];  % Merged image as a result
    
    handles.hDatebox = []; % Matlab object for DateSpinnerComboBox
    handles.datebox = []; % Java object for DateSpinnerComboBox
    
    handles.time_min = []; % Minimum time of oblique images
    handles.time_max = []; % Maximum time of oblique images
    
    % In case the images need to be rectified
    handles.roi = []; % Rectification area
    handles.H = []; % Affine matrix for rectification
    
    handles.saved = false; % True if the current calibration is saved, false otherwise
    
    handles.max_commonpoint = 0; % Keeps the maximum common point id so far
    
    % Initialize JIDE's usage within Matlab
    com.mathworks.mwswing.MJUtilities.initJIDE;
    
    % Display a DateSpinnerComboBox
    handles.datebox = com.jidesoft.combobox.DateSpinnerComboBox; % Constructor
    
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
    
    % Set error between images from different cameras to [0; 10]
    strError = {0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120};
    set(handles.popupTimeError, 'String', strError);
    
    % Put logo
    logo = imread('LogoHorusMin.png');
    imshow(logo, 'Parent', handles.axesLogo);
    
    set(handles.radioOblique, 'Value', true);
    
    % Update handles structure
    guidata(hObject, handles);
    
catch e
    disp(e.message)
end

% UIWAIT makes gui_genfusion wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_genfusion_OutputFcn(hObject, eventdata, handles)
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
        
        handles.time_min = cell2mat(load_datemin(handles.conn, 'oblique', station, false));
        handles.time_max = cell2mat(load_datemax(handles.conn, 'oblique', station, false));
        
        if isempty(handles.time_min)
            errordlg('There are no images in the database!', 'Error');
            return
        end
        
        % Load default path for images
        if ~exist('path_info.xml', 'file')
            errordlg('The file path_info.xml does not exist!', 'Error');
        else
            [pathOblique] = load_paths('path_info.xml', station);
            handles.root = pathOblique;
        end
        
        handles = reload_time(handles);
        handles = reload_camera(handles);
        
        set(handles.buttonContinue, 'String', 'Continue');
    else
        set(handles.listboxCameras, 'Value', 1, 'String', '');
        handles = reset_camera(handles);
        handles.uvaffine = cell(0);
    end
    
    % Update handles structure
    guidata(hObject, handles);
    
catch e
    disp(e.message)
end

% --- Executes on selection change in popupGCP.
function popupGCP_Callback(hObject, eventdata, handles)
% hObject    handle to popupGCP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupGCP contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupGCP

try
    
    if isempty(handles.commongcps)
        % Disable components which depend upon the GCP
        set(handles.editGCPul, 'String', '');
        set(handles.editGCPur, 'String', '');
        set(handles.editGCPvl, 'String', '');
        set(handles.editGCPvr, 'String', '');
    else
        % Update (u, v) coordinates of the GCP for both images
        value = get(hObject, 'Value');
        curgcp = handles.commongcps(value, :);
        set(handles.editGCPul, 'String', num2str(curgcp{2}, '%.2f'));
        set(handles.editGCPvl, 'String', num2str(curgcp{3}, '%.2f'));
        set(handles.editGCPur, 'String', num2str(curgcp{4}, '%.2f'));
        set(handles.editGCPvr, 'String', num2str(curgcp{5}, '%.2f'));
        set(handles.checkboxPickGCP, 'Value', handles.pickedGCPs(value));
    end
    
catch e
    disp(e.message)
end


% --- Executes on button press in buttonAddCommon.
function buttonAddCommon_Callback(hObject, eventdata, handles)
% hObject    handle to buttonAddCommon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    handles.motionId = 1; % Motion on left image
    
    % Add a new common point
    n = size(handles.commongcps, 1);
    handles.pickedGCPs(n + 1) = false;
    
    station = get_station(handles);
    cameras = get_camera_list(handles);
    time = get_time(handles);
    dorectify = get(handles.radioRectified, 'Value');
    if dorectify
        fusiontype = 'rectified';
    else
        fusiontype = 'oblique';
    end
    
    %reboot connection to the database if necessary
    [handles.conn status] = renew_connection_db(handles.conn);
    
    if status == 1
        return
    end
    
    data = load_common_points(handles.conn, station, ...
            cameras{handles.imgleft_index}, fusiontype, time); % {name, u, v}
        
    % The new point id will be the maximum id plus 1
    maxId = handles.max_commonpoint;
    
    if ~isempty(data)
        cpnames = data(:, 1);
        for i = 1:numel(cpnames)
            if strcmp(cpnames{i}(1:3), 'NEW')
                oldId = str2double(cpnames{i}(4:end));
                maxId = max(maxId, oldId);
            end
        end
    end
    
    newid = maxId + 1;
    handles.max_commonpoint = newid;
    
    handles.commongcps{n + 1, 1} = ['NEW' num2str(newid, '%03d')]; % name
    handles.commongcps{n + 1, 2} = -1; % uleft
    handles.commongcps{n + 1, 3} = -1; % vleft
    handles.commongcps{n + 1, 4} = -1; % uright
    handles.commongcps{n + 1, 5} = -1; % vright
    
    handles = reload_gcp(handles);
    
    set(handles.popupGCP, 'Value', n + 1);
    set(handles.editGCPul, 'String', '');
    set(handles.editGCPur, 'String', '');
    set(handles.editGCPvl, 'String', '');
    set(handles.editGCPvr, 'String', '');
    
    % Update handles structure
    guidata(hObject, handles);
    
catch e
    disp(e.message)
end

% --- Executes on button press in buttonAdd.
function buttonAdd_Callback(hObject, eventdata, handles)
% hObject    handle to buttonAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    if check_camera(handles)
        camera = get_camera(handles);
        % List of selected cameras
        contents = get(handles.listboxCameras, 'String');
        
        found = false;
        for i = 1:numel(contents)
            if strcmp(camera, contents{i})
                found = true;
                break;
            end
        end
        
        % If chosen camera is not in the list of selected cameras, append it
        if ~found
            contents{end+1} = camera;
            set(handles.listboxCameras, 'String', contents);
        end
        
        % There should be at least two cameras for calibrating a fusion
        % (pretty obvious)
        if numel(contents) <= 1
            set(handles.buttonLoadImages, 'Enable', 'off');
        else
            set(handles.buttonLoadImages, 'Enable', 'on');
        end
    end
    
catch e
    disp(e.message)
end


% --- Executes on button press in buttonRemove.
function buttonRemove_Callback(hObject, eventdata, handles)
% hObject    handle to buttonRemove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    % List of selected cameras
    contents = get(handles.listboxCameras, 'String');
    
    if ~isempty(contents)
        % Unselect a camera from the list
        index = get(handles.listboxCameras, 'Value');
        new = cell(0);
        
        % Copy all the cameras but the one to be unselected
        for i = 1:numel(contents)
            if i ~= index
                new{end+1} = contents{i};
            end
        end
        % Reload list
        set(handles.listboxCameras, 'Value', 1, 'String', new);
        
        % There should be at least two cameras for calibrating a fusion
        if numel(new) <= 1
            set(handles.buttonLoadImages, 'Enable', 'off');
        else
            set(handles.buttonLoadImages, 'Enable', 'on');
        end
    end
    
catch e
    disp(e.message)
end

% --- Executes on button press in buttonLoadImages.
function buttonLoadImages_Callback(hObject, eventdata, handles)
% hObject    handle to buttonLoadImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    % Load all images
    if ~check_station(handles) || ~check_time(handles) || ~check_camera_list(handles)
        %%%%% ERROR
        warndlg({'No station, camera or time was loaded',...
            'Please select a station, a camera and a time'},'Warning');
        return
    end
    
    station = get_station(handles);
    cameras = get_camera_list(handles);
    error = get_error(handles);
    time = get_time(handles);
    dorectify = get(handles.radioRectified, 'Value');
    
    error = error / (60 * 60 * 24); % Error as a fraction of the day
    
    m = size(cameras, 1);
    if m == 2
        set(handles.buttonContinue, 'String', 'Calculate');
    else
        set(handles.buttonContinue, 'String', 'Continue');
    end
    
    %reboot connection to the database if necessary
    [handles.conn status] = renew_connection_db(handles.conn);
    
    if status == 1
        return
    end
    
    % Load images: {filename, path, timestamp, camera}
    h = gui_message('Loading from database, this might take a while!','Loading...');
    data = load_allimages_per_cam(handles.conn, {'snap'}, station, cameras, time, error);
    if ishandle(h)
        delete(h);
    end
    
    % If the images were not found in the database for all cameras
    if isempty(data)
        %%%%ERROR
        errordlg('There are no images for all cameras in the database!', 'Error');
        return
    end
    
    [m n] = size(data);
    handles.images = cell(m, 1);
    
    if dorectify
        handles.roi = cell(m, 1);
        handles.H = cell(m, 1);
    end
    
    ok = true;
    
    % If not found the image in physical disk
    if filesep == '/' | strfind(handles.root,'http://')
        changeFrom = '\';
        changeTo = '/';
    else
        changeFrom = '/';
        changeTo = '\';
    end
    
    if strfind(handles.root, 'http://')
        warndlg(['The image is loading from an external server, '...
            'it may take some minutes.'],'Message');
    end
    for i = 1:m
        imgname = strtrim(data{i, 1});
        imglocation = data{i, 2};
        
        fullpath = strrep(fullfile(handles.root, imglocation, imgname), changeFrom, changeTo);
        
        if isempty(strfind(handles.root, 'http://'))
            if ~exist(fullpath, 'file')
                %%%%ERROR
                errordlg('There are no images for all cameras in the file disk!', 'Error');
                ok = false;
                break;
            end
        end
        
        % Load image
        handles.images{i} = imread(fullpath);
        
        % If the fusion is for rectified images, rectify images
        if dorectify
            % Load the nearest calibration before t
            calibration = load_calibration(handles.conn, station, cameras{i}, time);
            if isempty(calibration)
                errordlg('No calibration was found in the database!','Error');
                return;
            end
            
            % Extract the parameters H, K and D
            len = size(calibration, 2);
            H = [];
            K = [];
            D = [];
            for j = 1:len
                if strcmp(calibration{j}, 'H')
                    H = calibration{j + 1};
                end
                if strcmp(calibration{j}, 'K')
                    K = calibration{j + 1};
                end
                if strcmp(calibration{j}, 'D')
                    D = calibration{j + 1};
                end
            end
            
            % Load the nearest rectification ROI before t
            roi = load_roi(handles.conn, 'rect', cameras{i}, station, time, time);
            if isempty(roi)
                errordlg('No ROI was found in the database!','Error');
                return;
            end
            
            handles.roi{i} = roi;
            handles.H{i} = H;
            
            uroi = cell2mat(roi(:, 4)); % U coordinates
            vroi = cell2mat(roi(:, 5)); % V coordinates
            zroi = 0;           % level value, fixed
            
            resolution = calibration{3};
            
            % Rectify image
            [u v handles.images{i}] = rectify(handles.images{i}, H, K, D, ...
                [uroi vroi], zroi, resolution, false);
        end
    end
    
    if ok
        
        if ~handles.saved && ~isempty(handles.parameters)
            % Ask the user if he is sure about saving the calibration
            choice = questdlg('Do you want to save the calculated calibration?', ...
                'Save calibration', 'Yes', 'No','No');
            
            if strcmp(choice, 'Yes')
                handles = save_parameters(handles);
            end
        end
        
        handles.images_info = data;
        handles.imgleft_index = 1;
        
        handles.uvaffine = cell(0);
        handles.parameters = [];
        handles.mergedimg = [];
        handles.saved = false;
        set(handles.buttonExport, 'Enable', 'off');
        set(handles.buttonImport, 'Enable', 'on');
        
        handles = reload_images(handles);
    end
    handles.common_points = struct('cam', cell(0), 'name', cell(0), 'u', cell(0), 'v', cell(0));
    % Update handles structure
    guidata(hObject, handles);
    
catch e
    disp(e.message)
end

% --- Executes on button press in buttonContinue.
function buttonContinue_Callback(hObject, eventdata, handles)
% hObject    handle to buttonContinue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    % Load a new pair of consecutive images
    if check_station(handles) && ~isempty(handles.images) && ~isempty(handles.commongcps)
        
        dorectify = get(handles.radioRectified, 'Value');
        m = size(handles.images, 1);
        
        % Indices of all picked GCPs
        ind = find(handles.pickedGCPs);
        
        cameras = get_camera_list(handles);
        if numel(handles.uvaffine) == ((m*2)-2)
            handles.uvaffine{end -1} = cell2mat(handles.commongcps(ind, 2:3)); % [uleft, vleft]
            handles.uvaffine{end} = cell2mat(handles.commongcps(ind, 4:5)); % [uright, vright]
        else
            handles.uvaffine{end + 1} = cell2mat(handles.commongcps(ind, 2:3)); % [uleft, vleft]
            handles.uvaffine{end + 1} = cell2mat(handles.commongcps(ind, 4:5)); % [uright, vright]
            
        end
        for i = 1:length(ind)
            name = handles.commongcps{ind(i), 1};
            l = handles.imgleft_index;
            r = l + 1;
            
            cam = cameras{l};
            u = handles.commongcps{ind(i), 2};
            v = handles.commongcps{ind(i), 3};
            
            found = false;
            for j = 1:numel(handles.common_points)
                cp = handles.common_points{j};
                if strcmp(cam, cp.cam) && strcmp(name, cp.name) && u == cp.u && v == cp.v
                    found = true;
                    break;
                end
            end
            
            if ~found
                handles.common_points{end + 1}.cam = cam;
                handles.common_points{end}.name = name;
                handles.common_points{end}.u = u;
                handles.common_points{end}.v = v;
            end
            
            cam = cameras{r};
            u = handles.commongcps{ind(i), 4};
            v = handles.commongcps{ind(i), 5};
            
            found = false;
            for j = 1:numel(handles.common_points)
                cp = handles.common_points{j};
                if  strcmp(cam, cp.cam) && strcmp(name, cp.name) && u == cp.u && v == cp.v
                    found = true;
                    break;
                end
            end
            
            if ~found
                handles.common_points{end + 1}.cam = cam;
                handles.common_points{end}.name = name;
                handles.common_points{end}.u = u;
                handles.common_points{end}.v = v;
            end
        end
        
        option = 1;
        val = get(handles.radioProjective, 'Value');
        if val == 1
            option = 2;
        end
        val = get(handles.radioOptimizedAffine, 'Value');
        if val == 1
            option = 3;
        end
        val = get(handles.radioOptimizedProjective, 'Value');
        if val == 1
            option = 4;
        end
        
        handles.options{handles.imgleft_index} = option;
        
        % Calculate affine matrices
        if handles.imgleft_index < m
            
            if handles.imgleft_index == m - 2 || m == 2
                set(handles.buttonContinue, 'String', 'Calculate');
            end
            
            % Load next pair of images
            if handles.imgleft_index < m - 1
                
                handles.imgleft_index = handles.imgleft_index + 1;
                handles = reload_images(handles);
                
            else
                cameras = get_camera_list(handles);
                uvaffine = handles.uvaffine;
                
                h = gui_message('Generating fusion parameters, this might take a while!','Please wait...');
                [handles.parameters handles.mergedimg message] = ...
                    create_fusion_parameters(handles.images, handles.options, cameras, uvaffine, dorectify);
                if ishandle(h)
                    delete(h);
                end
                
                if ~isempty(message)
                    errordlg(message, 'Error');
                    return;
                end
                
                show_merged_image(handles);
                set(handles.buttonExport, 'Enable', 'on');
            end
        else
            %%%% WARNING
            warndlg({'Not enough cameras!',...
                'Invalid option!'},'Warning');
        end
        
        % Update handles structure
        guidata(hObject, handles);
    else
        %%%% WARNING
        warndlg({'You must select a station, image and GCPs!',...
            'Invalid option!'},'Warning');
    end
    
catch e
    disp(e.message)
end

% --- Executes on button press in buttonMarkGCP.
function buttonMarkGCP_Callback(hObject, eventdata, handles)
% hObject    handle to buttonMarkGCP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    plot_picked_gcps(handles)
    handles.motionId = 1;
    
    % Update handles structure
    guidata(hObject, handles);
catch e
    disp(e.message)
end

% --- Executes on button press in buttonClearGCP.
function buttonClearGCP_Callback(hObject, eventdata, handles)
% hObject    handle to buttonClearGCP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    if ~handles.motionId
        value = get(handles.popupGCP, 'Value');
        handles.commongcps{value, 2} = -1;
        handles.commongcps{value, 3} = -1;
        handles.commongcps{value, 4} = -1;
        handles.commongcps{value, 5} = -1;
        
        handles.pickedGCPs(value) = false;
        set(handles.checkboxPickGCP, 'Value', false);
        handles = reload_gcp(handles);
        
        set(handles.editGCPul, 'String', '');
        set(handles.editGCPvl, 'String', '');
        set(handles.editGCPur, 'String', '');
        set(handles.editGCPvr, 'String', '');
        
        % Update handles structure
        guidata(hObject, handles);
    end
catch e
    disp(e.message)
end

% --- Executes on button press in buttonPreview.
function buttonPreview_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPreview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    option = 1;
    val = get(handles.radioProjective, 'Value');
    if val == 1
        option = 2;
    end
    val = get(handles.radioOptimizedAffine, 'Value');
    if val == 1
        option = 3;
    end
    val = get(handles.radioOptimizedProjective, 'Value');
    if val == 1
        option = 4;
    end
    
    % Load a new pair of consecutive images
    if check_station(handles) && ~isempty(handles.images) && ~isempty(handles.commongcps)
        
        dorectify = get(handles.radioRectified, 'Value');
        m = size(handles.images, 1);
        
        % Indices of all picked GCPs
        ind = find(handles.pickedGCPs);
        uvleft = cell2mat(handles.commongcps(ind, 2:3)); % [uleft, vleft]
        n_left = size(uvleft, 1);
        uvright = cell2mat(handles.commongcps(ind, 4:5)); % [uright, vright]
        n_right = size(uvright, 1);
        
        % Calculate affine matrices
        if handles.imgleft_index < m
            I1 = handles.images{handles.imgleft_index};
            I2 = handles.images{handles.imgleft_index + 1};
        else
            %%%% WARNING
            warndlg({'Not enough cameras!',...
                'Invalid option!'},'Warning');
            return
        end
        
        if dorectify
            in = 1;
            jn = 1;
            H = homography(uvleft, uvright + [jn * ones(n_right, 1) in * ones(n_left, 1)]);
        else
            if option == 1 || option == 3 % Affine transformation
                H = im2im(uvleft(:, 1), uvleft(:, 2), uvright(:, 1), uvright(:, 2), 1);
            elseif option == 2 || option == 4 % Projective transformation
                H = im2im(uvleft(:, 1), uvleft(:, 2), uvright(:, 1), uvright(:, 2), 2);
            end
            
            if option == 3 || option == 4 % Optimized
                [H B F hist] = levmarProjective(I1, I2, [], [], H, 20, 10, 1e-5, 120);
            end
        end
        
        if dorectify
            [prev in jn] = merge_images(I1, I2, H);
        else
            prev = mergeIms({I1, I2}, {H});
        end
        
        figure
        imshow(prev)
    end
    
catch e
    disp(e.message)
end

% --- Executes on button press in buttonImport.
function buttonImport_Callback(hObject, eventdata, handles)
% hObject    handle to buttonImport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%% TEMPORAL!!!!!!!!!!!!!!!!!!!!!!
% {name, uleft, vleft, uright, vright}
% handles.commongcps{value, 4} = U;
% handles.commongcps{value, 5} = V;
%
% set(handles.editGCPur, 'String', num2str(U, '%.2f'));
% set(handles.editGCPvr, 'String', num2str(V, '%.2f'));
%
% handles.pickedGCPs(value) = true;
% set(handles.checkboxPickGCP, 'Value', true);
% handles = reload_gcp(handles);
%
% % Update handles structure
% guidata(hObject, handles);
%%%%%%%%% TEMPORAL!!!!!!!!!!!!!!!!!!!!!!


try
    
    % Select path of the file to import
    [filename, pathname] = ...
        uigetfile({'*.xls';'*.mat'},'File Selector');
    
    if filename
        cameralist = get_camera_list(handles);
        l = handles.imgleft_index;
        r = l + 1;
        ind = strfind(filename,'.xls');
        if ~isempty(ind)
            [num txt data] = xlsread(fullfile(pathname, filename));
        else
            mat = fullfile(pathname, filename);
            vars = whos('-file', mat);
            load(mat, vars(1).name);
            data = eval(vars(1).name);
        end
        
        % Data should be a matrix of three columns {Camera, GCP name, U, V}
        cams = data(:, 1);
        names = data(:, 2);
        ucoord = cell2mat(data(:, 3));
        vcoord = cell2mat(data(:, 4));
        
        newdata = cell(0);
        
        m = size(data, 1);
        k = 1;
        for i = 1:m
            for j = 1:m
                if i ~= j && strcmp(cams{i}, cameralist{l}) && ...
                        strcmp(cams{j}, cameralist{r}) &&...
                        strcmp(names{i}, names{j})
                    
                    newdata{k, 1} = names{i};
                    newdata{k, 2} = ucoord(i);
                    newdata{k, 3} = vcoord(i);
                    newdata{k, 4} = ucoord(j);
                    newdata{k, 5} = vcoord(j);
                    k = k + 1;
                end
            end
        end
        
        len = k - 1;
        if len > 0
            % Ask if the user is sure about importing, as it would erase current points
            
            handles.commongcps = newdata;
            handles.pickedGCPs = ones(len, 1);
            set(handles.editGCPul, 'String', num2str(newdata{1, 2}, '%.2f'));
            set(handles.editGCPvl, 'String', num2str(newdata{1, 3}, '%.2f'));
            set(handles.editGCPur, 'String', num2str(newdata{1, 4}, '%.2f'));
            set(handles.editGCPvr, 'String', num2str(newdata{1, 5}, '%.2f'));
            
            set(handles.checkboxPickGCP, 'Value', true);
            handles = reload_gcp(handles);
        end
    end
    guidata(hObject, handles);
    
catch e
    disp(e.message)
end

% --- Executes on button press in buttonExport.
function buttonExport_Callback(hObject, eventdata, handles)
% hObject    handle to buttonExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    if isempty(handles.common_points)
        errordlg('There are no common points to be saved!', 'Error');
        return;
    end
    
    % Data should be a matrix of four columns {Camera, GCP name, U, V}
    [filename, pathname] = uiputfile({'*.xls';'*.mat';'*.txt'},'Save common points as...');
    
    if ~filename
        return;
    end
    
    m = numel(handles.common_points);
    data = cell(m, 4);
    for i = 1:m
        cp = handles.common_points{i};
        data{i, 1} = cp.cam;
        data{i, 2} = cp.name;
        data{i, 3} = cp.u;
        data{i, 4} = cp.v;
    end
    
    [tok, rem] = strtok(filename, '.');
    
    try
        if strcmpi(rem, '.xls')
            xlswrite(fullfile(pathname, filename), data(:, 1), ['A1:A' num2str(m)]);
            xlswrite(fullfile(pathname, filename), data(:, 2), ['B1:B' num2str(m)]);
            xlswrite(fullfile(pathname, filename), data(:, 3:4), ['C1:D' num2str(m)]);
        elseif strcmpi(rem, '.mat')
            save(fullfile(pathname, filename), 'data');
        elseif strcmpi(rem, '.txt')
            fid = fopen(fullfile(pathname, filename), 'w');
            for i = 1:m
                fprintf(fid, '%s\t%s\t%e\t%e\n', data{i, 1}, data{i, 2}, data{i, 3}, data{i, 4});
            end
            fclose(fid);
        end
    catch e
        errordlg('Data could not be saved!', 'Error')
        return
    end
    warndlg('Data saved successfully!', 'Success')
    
catch e
    disp(e.message)
end

% --- Executes on button press in radioRectified.
function radioRectified_Callback(hObject, eventdata, handles)
% hObject    handle to radioRectified (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioRectified

try
    on = get(hObject, 'Value');
    if on
        set(handles.radioOblique, 'Value', false)
    end
catch e
    disp(e.message)
end

% --- Executes on button press in radioOblique.
function radioOblique_Callback(hObject, eventdata, handles)
% hObject    handle to radioOblique (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioOblique

try
    on = get(hObject, 'Value');
    if on
        set(handles.radioRectified, 'Value', false)
    end
catch e
    disp(e.message)
end

% --- Executes on button press in radioAffine.
function radioAffine_Callback(hObject, eventdata, handles)
% hObject    handle to radioAffine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioAffine

try
    on = get(hObject, 'Value');
    if on
        set(handles.radioProjective, 'Value', false)
        set(handles.radioOptimizedAffine, 'Value', false)
        set(handles.radioOptimizedProjective, 'Value', false)
    else
        set(hObject, 'Value', true)
    end
catch e
    disp(e.message)
end

% --- Executes on button press in radioProjective.
function radioProjective_Callback(hObject, eventdata, handles)
% hObject    handle to radioProjective (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioProjective

try
    on = get(hObject, 'Value');
    if on
        set(handles.radioAffine, 'Value', false)
        set(handles.radioOptimizedAffine, 'Value', false)
        set(handles.radioOptimizedProjective, 'Value', false)
    else
        set(hObject, 'Value', true)
    end
catch e
    disp(e.message)
end

% --- Executes on button press in radioOptimizedAffine.
function radioOptimizedAffine_Callback(hObject, eventdata, handles)
% hObject    handle to radioOptimizedAffine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioOptimizedAffine

try
    on = get(hObject, 'Value');
    if on
        set(handles.radioAffine, 'Value', false)
        set(handles.radioProjective, 'Value', false)
        set(handles.radioOptimizedProjective, 'Value', false)
    else
        set(hObject, 'Value', true)
    end
catch e
    disp(e.message)
end

% --- Executes on button press in radioOptimizedProjective.
function radioOptimizedProjective_Callback(hObject, eventdata, handles)
% hObject    handle to radioOptimizedProjective (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioOptimizedProjective

try
    on = get(hObject, 'Value');
    if on
        set(handles.radioAffine, 'Value', false)
        set(handles.radioOptimizedAffine, 'Value', false)
        set(handles.radioProjective, 'Value', false)
    else
        set(hObject, 'Value', true)
    end
catch e
    disp(e.message)
end

% --- Executes on button press in checkboxPickGCP.
function checkboxPickGCP_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxPickGCP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxPickGCP

try
    if ~isempty(handles.commongcps) && ~isempty(handles.images{handles.imgleft_index}) &&...
            ~isempty(handles.images{handles.imgleft_index + 1})
        valueGCP = get(handles.popupGCP, 'Value');
        
        valuePickGCP = get(handles.checkboxPickGCP, 'Value');
        handles.pickedGCPs(valueGCP) = valuePickGCP;
        handles = reload_gcp(handles);
        
        % Update handles structure
        guidata(hObject, handles);
    end
catch e
    disp(e.message)
end

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    if handles.motionId == 1 % If motion on left image
        
        handles.motionId = 2; % Switch motion to right image
        
        set(handles.figure1, 'Pointer', 'arrow');
        
        value = get(handles.popupGCP, 'Value');
        
        % Get cursor position over the image
        UV = get(handles.axesImage1, 'CurrentPoint');
        
        U = UV(1, 1);
        V = UV(1, 2);
        handles.commongcps{value, 2} = U;
        handles.commongcps{value, 3} = V;
        
        set(handles.editGCPul, 'String', num2str(U, '%.2f'));
        set(handles.editGCPvl, 'String', num2str(V, '%.2f'));
        
        handles.pickedGCPs(value) = true;
        set(handles.checkboxPickGCP, 'Value', true);
        handles = reload_gcp(handles);
        
        % Update handles structure
        guidata(hObject, handles);
    elseif handles.motionId == 2 % If motion is on the right image
        handles.motionId = 0; % Switch off motion
        
        set(handles.figure1, 'Pointer', 'arrow');
        
        value = get(handles.popupGCP, 'Value');
        UV = get(handles.axesImage2, 'CurrentPoint');
        
        U = UV(1, 1);
        V = UV(1, 2);
        handles.commongcps{value, 4} = U;
        handles.commongcps{value, 5} = V;
        
        set(handles.editGCPur, 'String', num2str(U, '%.2f'));
        set(handles.editGCPvr, 'String', num2str(V, '%.2f'));
        
        handles.pickedGCPs(value) = true;
        set(handles.checkboxPickGCP, 'Value', true);
        handles = reload_gcp(handles);
        
        % Update handles structure
        guidata(hObject, handles);
    end
catch e
    disp(e.message)
end

% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    if handles.motionId == 1 && ~isempty(handles.images{handles.imgleft_index})
        [m n o] = size(handles.images{handles.imgleft_index});
        
        % Get cursor position over the image
        UV = get(handles.axesImage1, 'CurrentPoint');
        U = UV(1, 1);
        V = UV(1, 2);
        
        % The cursor must be within image bounds
        if U > 0 && U <= n && V > 0 && V <= m;
            set(handles.figure1, 'Pointer', 'crosshair');
            set(handles.editGCPul, 'String', num2str(U, '%.2f'));
            set(handles.editGCPvl, 'String', num2str(V, '%.2f'));
        else
            set(handles.figure1, 'Pointer', 'arrow');
            set(handles.editGCPul, 'String', '');
            set(handles.editGCPvl, 'String', '');
        end
        
        % Update handles structure
        guidata(hObject, handles);
        
    elseif handles.motionId == 2 && ~isempty(handles.images{handles.imgleft_index + 1})
        [m n o] = size(handles.images{handles.imgleft_index + 1});
        
        UV = get(handles.axesImage2, 'CurrentPoint');
        U = UV(1, 1);
        V = UV(1, 2);
        if U > 0 && U <= n && V > 0 && V <= m;
            set(handles.figure1, 'Pointer', 'crosshair');
            set(handles.editGCPur, 'String', num2str(U, '%.2f'));
            set(handles.editGCPvr, 'String', num2str(V, '%.2f'));
        else
            set(handles.figure1, 'Pointer', 'arrow');
            set(handles.editGCPur, 'String', '');
            set(handles.editGCPvr, 'String', '');
        end
        % Update handles structure
        guidata(hObject, handles);
    end
catch e
    disp(e.message)
end

% --------------------------------------------------------------------
function menuItemSaveCal_Callback(hObject, eventdata, handles)
% hObject    handle to menuItemSaveCal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    if isempty(handles.parameters)
        warndlg({'You have not generated a calibration!',...
            'Please generate calibration'},'Warning');
        return
    end
    
    handles = save_parameters(handles);
    
    % Update handles structure
    guidata(hObject, handles);
catch e
    disp(e.message)
end

% --------------------------------------------------------------------
function menuItemShow_Callback(hObject, eventdata, handles)
% hObject    handle to menuItemShow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

show_merged_image(handles);


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
% Check if there is a valid camera selected
function ok = check_camera(handles)
try
    value = get(handles.popupCamera, 'Value');
    ok = value ~= 1;
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Check if there is a valid time selected
function ok = check_time(handles)
try
    ok = ~isempty(handles.datebox);
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Check if there is a valid camera list selected
function ok = check_camera_list(handles)
try
    list = get(handles.listboxCameras, 'String');
    ok = numel(list) > 1;
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
% Check if affine option is selected
function value = check_affine(handles)
try
    value = get(handles.radioAffine, 'Value');
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Check if affine option is selected
function value = check_projective(handles)
try
    value = get(handles.radioProjective, 'Value');
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Check if affine option is selected
function value = check_opt_affine(handles)
try
    value = get(handles.radioOptimizedAffine, 'Value');
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Check if affine option is selected
function value = check_opt_projective(handles)
try
    value = get(handles.radioOptimizedProjective, 'Value');
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
% Returns the selected time
function time = get_time(handles)

try
    % Java stuff
    calObj = handles.datebox.getCalendar();
    
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
% Returns the selected camera list
function list = get_camera_list(handles)
try
    list = cellstr(get(handles.listboxCameras, 'String'));
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
% Reload the time sliders, updating the initial and final times for each
function handles = reload_time(handles)

try
    % Set time sliders
    
    if check_station(handles)
        
        % JAVA stuff: load calendar for choosing date & time
        
        handles.datebox.setLocale(java.util.Locale.ENGLISH); % Set English language
        handles.datebox.setTimeDisplayed(true); % Show time
        handles.datebox.setFormat(java.text.SimpleDateFormat('dd/MM/yyyy HH:mm:ss')); % Set date & time format
        handles.datebox.setTimeFormat('HH:mm:ss'); % Set time format (in the grid)
        handles.datebox.setFont(java.awt.Font('SansSerif', java.awt.Font.PLAIN, 10)); % Set fonts
        
        handles.datebox.setShowWeekNumbers(false); % Do not show week number
        handles.datebox.setShowNoneButton(false); % Do not show the 'None' button
        handles.datebox.setShowOKButton(true); % Show the 'OK' button
        handles.datebox.setShowTodayButton(true) % Show the 'Today' button
        
        station = get_station(handles);
        
        timevec = datevec(handles.time_min);
        handles.datebox.setCalendar(java.util.GregorianCalendar(timevec(1), timevec(2) - 1, ...
            timevec(3), timevec(4), timevec(5), timevec(6)));
        
        % Put the DateSpinnerComboBox object in a GUI panel
        [handles.hDatebox,hContainer] = javacomponent(handles.datebox,[2,3,160,19],handles.panelTime);
        
        set(handles.hDatebox, 'ActionPerformedCallback', {@timeCallbackFunction, handles});
    end
catch e
    disp(e.message)
end

% Callback for DateSpinnerComboBox object
function timeCallbackFunction(hObject, eventdata, handles)

try
    if check_station(handles)
        
        % JAVA stuff: load calendar for choosing date & time
        
        time = get_time(handles);
        if time < handles.time_min
            timevec = datevec(handles.time_min);
            handles.datebox.setCalendar(java.util.GregorianCalendar(timevec(1), timevec(2) - 1, ...
                timevec(3), timevec(4), timevec(5), timevec(6)));
        end
        if time > handles.time_max
            timevec = datevec(handles.time_max);
            handles.datebox.setCalendar(java.util.GregorianCalendar(timevec(1), timevec(2) - 1, ...
                timevec(3), timevec(4), timevec(5), timevec(6)));
        end
    end
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
            errordlg('No cameras were found in the database!', 'Error');
            return;
        end
        
        strCamera = {'Select a camera'};
        
        for k = 1:numel(cameras)
            strCamera{k + 1} = char(cameras(k));
        end
        
        set(handles.popupCamera, 'String', strCamera);
    end
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Unload cameras
function handles = reset_camera(handles)
try
    set(handles.popupCamera, 'Value', 1);
    set(handles.popupCamera, 'String', 'Select a camera');
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Reload all GCPs from the database
function handles = reload_gcp(handles)

try
    if ~isempty(handles.commongcps)
        m = size(handles.commongcps, 1);
        
        strGCP = cell(0);
        
        % Write picked GCPs with a '*'
        valueGCP = get(handles.popupGCP, 'Value');
        for i = 1:m
            if handles.pickedGCPs(i)
                strGCP{i} = [handles.commongcps{i, 1} '*'];
            else
                strGCP{i} = handles.commongcps{i, 1};
            end
        end
        
        set(handles.popupGCP, 'String', strGCP);
        
        if ~isempty(strGCP)
            curgcp = handles.commongcps(valueGCP, :);
            set(handles.popupGCP, 'Value', valueGCP);
            set(handles.checkboxPickGCP, 'Value', handles.pickedGCPs(valueGCP));
            set(handles.editGCPul, 'String', num2str(curgcp{2}, '%.2f'));
            set(handles.editGCPvl, 'String', num2str(curgcp{3}, '%.2f'));
            set(handles.editGCPur, 'String', num2str(curgcp{4}, '%.2f'));
            set(handles.editGCPvr, 'String', num2str(curgcp{5}, '%.2f'));
        else
            warndlg('There are no picked GCPs for this pair of cameras!', 'Warning')
        end
        
        plot_picked_gcps(handles);
    else
        warndlg('There are no picked GCPs for this pair of cameras!', 'Warning')
    end
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Reload the images and the GCPs
function handles = reload_images(handles)

try
    if check_station(handles) && check_time(handles) && check_camera_list(handles)
        
        set(handles.popupGCP, 'Value', 1, 'String', ' ');
        set(handles.editGCPul, 'String', '');
        set(handles.editGCPvl, 'String', '');
        set(handles.editGCPur, 'String', '');
        set(handles.editGCPvr, 'String', '');
        set(handles.checkboxPickGCP, 'Value', false);
        
        station = get_station(handles);
        cameras = get_camera_list(handles);
        time = get_time(handles);
        
        imgleft = handles.images{handles.imgleft_index};
        imgleftname = handles.images_info{handles.imgleft_index, 1};
        
        imgright = handles.images{handles.imgleft_index + 1};
        imgrightname = handles.images_info{handles.imgleft_index + 1, 1};
        
        cla(handles.axesImage1)
        cla(handles.axesImage2)
        % Show image in normal size, without zoom
        [m n o] = size(imgleft);
        set(handles.axesImage1, 'Xlim', [0 n])
        set(handles.axesImage1, 'Ylim', [0 m])
        
        imshow(imgleft, 'Parent', handles.axesImage1);
        set(handles.panelImage1, 'Title', imgleftname);
        
        % Show image in normal size, without zoom
        [m n o] = size(imgright);
        set(handles.axesImage2, 'Xlim', [0 n])
        set(handles.axesImage2, 'Ylim', [0 m])
        
        imshow(imgright, 'Parent', handles.axesImage2);
        set(handles.panelImage2, 'Title', imgrightname);
        
        dorectify = get(handles.radioRectified, 'Value');
        if dorectify
            fusiontype = 'rectified';
        else
            fusiontype = 'oblique';
        end
        
        %reboot connection to the database if necessary
        [handles.conn status] = renew_connection_db(handles.conn);

        if status == 1
            return
        end
        
        % Load common points
        common_left = load_common_points(handles.conn, station, ...
            cameras{handles.imgleft_index}, fusiontype, time); % {name, u, v}
        common_right = load_common_points(handles.conn, station, ...
            cameras{handles.imgleft_index + 1}, fusiontype, time); % {name, u, v}
        
        loadpicked = false;
        
        if isempty(common_left) || isempty(common_right) % No previous common points found
            loadpicked = true;
            % Load picked GCPs of current left and right images
            pickedgcps_left = load_pickedgcps(handles.conn, station, ...
                cameras{handles.imgleft_index}, time); % {name, idgcp, u, v, x, y, z}
            
            if isempty(pickedgcps_left)
                errordlg('No picked GCPs were found in the database!', 'Error');
                return;
            end
            
            pickedgcps_right = load_pickedgcps(handles.conn, station, ...
                cameras{handles.imgleft_index + 1}, time);
            
            if isempty(pickedgcps_right)
                errordlg('No picked GCPs were found in the database!', 'Error');
                return;
            end
            
            % Find common GCPs: {name, uleft, vleft, uright, vright}
            handles.commongcps = cell(0, 5);
            [m1 n1] = size(pickedgcps_left);
            [m2 n2] = size(pickedgcps_right);
            
            k = 1;
            for i = 1:m1
                picked_left = pickedgcps_left(i, :);
                for j = 1:m2
                    picked_right = pickedgcps_right(j, :);
                    if picked_left{2} == picked_right{2} % Common
                        handles.commongcps{k, 1} = picked_left{1}; % name
                        handles.commongcps{k, 2} = picked_left{3}; % uleft
                        handles.commongcps{k, 3} = picked_left{4}; % vleft
                        handles.commongcps{k, 4} = picked_right{3};% uright
                        handles.commongcps{k, 5} = picked_right{4};% vright
                        k = k + 1;
                    end
                end
            end
            len = k - 1;
        else
            % Find common GCPs: {name, uleft, vleft, uright, vright}
            handles.commongcps = cell(0, 5);
            [m1 n1] = size(common_left);
            [m2 n2] = size(common_right);
            
            k = 1;
            for i = 1:m1
                picked_left = common_left(i, :);
                for j = 1:m2
                    picked_right = common_right(j, :);
                    if strcmp(picked_left{1}, picked_right{1}) % Common
                        handles.commongcps{k, 1} = picked_left{1}; % name
                        handles.commongcps{k, 2} = picked_left{2}; % uleft
                        handles.commongcps{k, 3} = picked_left{3}; % vleft
                        handles.commongcps{k, 4} = picked_right{2};% uright
                        handles.commongcps{k, 5} = picked_right{3};% vright
                        k = k + 1;
                    end
                end
            end
            len = k - 1;
            
        end
        
        if loadpicked
            
            % If the fusion is for rectified images, rectify GCPs
            if dorectify
                % Load affine matrices and ROIs for left and right images
                Hleft = handles.H{handles.imgleft_index};
                Hright = handles.H{handles.imgleft_index + 1};
                roi_left = handles.roi{handles.imgleft_index};
                roi_right = handles.roi{handles.imgleft_index + 1};
                
                uleft = cell2mat(handles.commongcps(:, 2));
                vleft = cell2mat(handles.commongcps(:, 3));
                uright = cell2mat(handles.commongcps(:, 4));
                vright = cell2mat(handles.commongcps(:, 5));
                
                % Rectify common points' (u, v) coordinates (to (x, y, z))
                [xleft yleft z] = UV2XYZ(Hleft, uleft, vleft, 0);
                [xright yright z] = UV2XYZ(Hright, uright, vright, 0);
                
                uroi_left = cell2mat(roi_left(:, 4)); % U coordinates
                vroi_left = cell2mat(roi_left(:, 5)); % V coordinates
                zroi_left = 0;           % level value, fixed
                uroi_right = cell2mat(roi_right(:, 4)); % U coordinates
                vroi_right = cell2mat(roi_right(:, 5)); % V coordinates
                zroi_right = 0;           % level value, fixed
                
                [mleft nleft o] = size(handles.images{handles.imgleft_index});
                [mright nright o] = size(handles.images{handles.imgleft_index + 1});
                
                % Calculate new position (u, v) in left rectified image
                
                % Rectify ROI
                [X Y Z] = UV2XYZ(Hleft, uroi_left, vroi_left, zroi_left);
                minX = min(X);
                maxX = max(X);
                minY = min(Y);
                maxY = max(Y);
                
                minU = 1;
                maxU = nleft;
                minV = 1;
                maxV = mleft;
                
                % Linear equations for mapping from (x, y, z) to (u, v)
                mU = (maxU - minU) / (maxX - minX);
                bU = maxU - mU * maxX;
                mV = (minV - maxV) / (maxY - minY);
                bV = maxV - mV * minY;
                
                newU = mU * xleft + bU;
                newV = mV * yleft + bV;
                
                for i = 1:len
                    handles.commongcps{i, 2} = newU(i);
                    handles.commongcps{i, 3} = newV(i);
                end
                
                % Calculate new position (u, v) in right rectified image
                
                % Rectify ROI
                [X Y Z] = UV2XYZ(Hright, uroi_right, vroi_right, zroi_right);
                minX = min(X);
                maxX = max(X);
                minY = min(Y);
                maxY = max(Y);
                
                minU = 1;
                maxU = nright;
                minV = 1;
                maxV = mright;
                
                % Linear equations for mapping from (x, y, z) to (u, v)
                mU = (maxU - minU) / (maxX - minX);
                bU = maxU - mU * maxX;
                mV = (minV - maxV) / (maxY - minY);
                bV = maxV - mV * minY;
                
                newU = mU * xright + bU;
                newV = mV * yright + bV;
                
                for i = 1:len
                    handles.commongcps{i, 4} = newU(i);
                    handles.commongcps{i, 5} = newV(i);
                end
                
            end
        end
        
        handles.pickedGCPs = ones(k - 1, 1);
        handles.parameters = [];
        handles.mergedimg = [];
        
        if ~isempty(handles.commongcps)
            % Reload GCPs
            handles = reload_gcp(handles);
        else
            warndlg('There are no picked GCPs for this pair of cameras!', 'Warning')
        end
    end
    
catch e
    disp(e.message)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
% Paint the picked GCPs over the images
function plot_picked_gcps(handles)

try
    
    [m n] = size(handles.commongcps);
    
    % Plot left
    [mi ni oi] = size(handles.images{handles.imgleft_index});
    imshow(handles.images{handles.imgleft_index}, 'Parent', handles.axesImage1)
    
    for i = 1:m
        if handles.pickedGCPs(i)
            name = handles.commongcps{i, 1};
            U = handles.commongcps{i, 2};
            V = handles.commongcps{i, 3};
            
            if U > 0 && V > 0 && U <= ni && V <= mi
                hold(handles.axesImage1, 'on')
                plot(handles.axesImage1, U, V, '*r');
                text(U, V, name, 'Parent', handles.axesImage1, 'Color', 'yellow',...
                    'FontSize', 8, 'VerticalAlignment', 'bottom');
            end
        end
    end
    % Plot right
    [mi ni oi] = size(handles.images{handles.imgleft_index + 1});
    imshow(handles.images{handles.imgleft_index + 1}, 'Parent', handles.axesImage2)
    
    for i = 1:m
        if handles.pickedGCPs(i)
            name = handles.commongcps{i, 1};
            U = handles.commongcps{i, 4};
            V = handles.commongcps{i, 5};
            
            if U > 0 && V > 0 && U <= ni && V <= mi
                hold(handles.axesImage2, 'on')
                plot(handles.axesImage2, U, V, '*r');
                text(U, V, name, 'Parent', handles.axesImage2, 'Color', 'yellow',...
                    'FontSize', 8, 'VerticalAlignment', 'bottom');
            end
        end
    end
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Display the merged image
function show_merged_image(handles)
try
    if ~isempty(handles.mergedimg)
        figure
        imshow(handles.mergedimg);
    else
        %%% WARNING
        warndlg({'You have not calculated a fusion calibration!',...
            'Please calibrate the fusion'},'Warning');
    end
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Save calibration
function handles = save_parameters(handles)

try
    % Ask the user if he is sure about saving the calibration
    choice = questdlg('Are you sure you want to save the calibration in the database?', ...
        'Save calibration', 'Yes', 'No','No');
    
    if strcmp(choice, 'No')
        return
    end
    
    station = get_station(handles);
    % time = get_time(handles);
    time = handles.images_info{1, 3};
    isrectified = get(handles.radioRectified, 'Value');
    cameras = get_camera_list(handles);
    
    if isrectified
        type = 'rectified';
    else
        type = 'oblique';
    end
    
    %reboot connection to the database if necessary
    [handles.conn status] = renew_connection_db(handles.conn);
    
    if status == 1
        return
    end
    
    h = gui_message('Inserting into database, this might take a while!','Saving...');
    [status, idfusion] = insert_fusion(handles.conn, station, time, type, cameras, handles.parameters);
    if status == 1
        errordlg('The fusion could not be inserted in the database!');
        if ishandle(h)
            delete(h);
        end
        return;
    end
    
    for i = 1:numel(handles.common_points)
        cp = handles.common_points{i};
        status = insert_common_point(handles.conn, station, cp.cam, idfusion, cp.name, cp.u, cp.v);
        if status == 1
            errordlg('The common points could not be inserted in the database!');
            if ishandle(h)
                delete(h);
            end
            return;
        end
    end
    
    if ishandle(h)
        delete(h);
    end
    
    warndlg('The calibration was successfully saved!', 'Success');
    handles.saved = true;
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
    if ~handles.saved && ~isempty(handles.parameters)
        % Ask the user if he is sure about saving the calibration
        choice = questdlg('Do you want to save the calculated calibration?', ...
            'Save calibration', 'Yes', 'No','No');
        
        if strcmp(choice, 'Yes')
            handles = save_parameters(handles);
        end
    end
    
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
