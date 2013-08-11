function varargout = gui_gencalibration(varargin)
% GUI_GENCALIBRATION M-file for gui_gencalibration.fig
%      GUI_GENCALIBRATION, by itself, creates a new GUI_GENCALIBRATION or raises the existing
%      singleton*.
%
%      H = GUI_GENCALIBRATION returns the handle to a new GUI_GENCALIBRATION or the handle to
%      the existing singleton*.
%
%      GUI_GENCALIBRATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_GENCALIBRATION.M with the given input arguments.
%
%      GUI_GENCALIBRATION('Property','Value',...) creates a new GUI_GENCALIBRATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_gencalibration_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_gencalibration_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_gencalibration

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
% Last Modified by GUIDE v2.5 10-Nov-2012 11:37:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @gui_gencalibration_OpeningFcn, ...
    'gui_OutputFcn',  @gui_gencalibration_OutputFcn, ...
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


% --- Executes just before gui_gencalibration is made visible.
function gui_gencalibration_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_gencalibration (see VARARGIN)

try
    
    % Choose default command line output for gui_gencalibration
    handles.output = hObject;
    
    % Set HORUS paths
    if ~isdeployed
        root = fileparts(mfilename('fullpath'));
        root = fileparts(root);
        addpath(genpath(root));
    end
    
    
    
    handles.img = [];        % Image cdata
    
    handles.rectimg = [];    % Rectified image created with calculated calibration
    
    handles.image_info = []; % Info returned from database
    % {filename, path, timestamp}
    
    handles.gcps = [];       % Info returned from database
    % {idgcp, name, x, y, z}
    
    handles.marked = [];     % Matrix of nx2, n the numbers of gcps.
    % Contains (u, v) for every GCP or -1 if not marked
    
    handles.pickedGCPs = []; % Boolean vector of n elements,
    % n the number of gcps. 1 if the GCP is picked
    
    handles.root = '';       % Images root directory
    
    handles.motionActivated = false; % Boolean value: 1 if the show (u, v)
    % feature is activated, 0 otherwise
    
    handles.initialEstimates = []; % Initial estimates for Pinhole
    
    handles.calibration = []; % Calibration parameters
    % {H K D R t P ECN MSExy MSEuv un vn pos}
    
    handles.hDatebox = []; % Matlab object for DateSpinnerComboBox
    handles.datebox = []; % Java object for DateSpinnerComboBox
    
    handles.roi = []; % ROI if selected by the user
    
    handles.time_min = []; % Minimum time of oblique images
    handles.time_max = []; % Maximum time of oblique images
    
    handles.saved = false; % True if the current calibration is saved, false otherwise
    
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
    
    % Initialize cameras in popup menu
    reset_camera(handles);
    
    % Initialize calibration methods in popup menu
    strMethods = {'Select a method', 'DLT', 'RANSAC-DLT', 'Pinhole'};
    set(handles.popupMethod, 'String', strMethods);
    
    % Initialize axes handle as not visible
    set(handles.axesImage, 'Visible', 'off')
    
    set(handles.popupGCP, 'String', ' ');
    
    % Update handles structure
    guidata(hObject, handles);
    
    % Put logo
    logo = imread('LogoHorusMin.png');
    imshow(logo, 'Parent', handles.axesLogo);
    
catch e
    disp(e.message)
end
% UIWAIT makes gui_gencalibration wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_gencalibration_OutputFcn(hObject, eventdata, handles)
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
        handles = reset_camera(handles);
        handles = reset_gcp(handles);
    else
        station = get_station(handles);
        
        %reboot connection to the database if necessary
        [handles.conn status] = renew_connection_db(handles.conn);
        
        if status == 1
            return
        end
        
        handles.time_min = cell2mat(load_datemin(handles.conn, 'oblique', station, false));
        handles.time_max = cell2mat(load_datemax(handles.conn, 'oblique', station, false));
        
        % Load default path for images
        if ~exist('path_info.xml', 'file')
            errordlg('The file path_info.xml does not exist!', 'Error');
        else
            [pathOblique] = load_paths('path_info.xml', station);
            handles.root = pathOblique;
        end
        
        % Initialize cameras in popup menu
        handles = reload_camera(handles);
        
        % Initialize GCP's in popup menu
        h = gui_message('Loading from database, this might take a while!','Loading...');
        gcps = load_allgcps(handles.conn, station); % Columns: {idgcp, name, x, y, z}
        if ishandle(h)
            delete(h);
        end
        
        if isempty(gcps)
            errordlg('No GCPs were found in the database!', 'Error');
            return;
        end
        
        handles.gcps = gcps;
        
        m = size(gcps, 1);
        handles.marked = -1 * ones(m, 2); % Sentinel value for non-marked GCPs
        handles.pickedGCPs = zeros(m, 1); % No GCP is picked (zero means false)
        handles = reload_gcp(handles);
        
        handles.roi = [];
    end
    cla(handles.axesImage);
    % Update handles structure
    guidata(hObject, handles);
    
catch e
    disp(e.message)
end

% --- Executes on selection change in popupCamera.
function popupCamera_Callback(hObject, eventdata, handles)
% hObject    handle to popupCamera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupCamera contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        popupCamera

try
    if ~check_camera(handles)
        % Disable buttons which depend upon the camera
        set(handles.buttonLoadImage, 'Enable', 'off');
        set(handles.buttonMarkGCP, 'Enable', 'off');
        set(handles.buttonImport, 'Enable', 'off');
        set(handles.buttonExportGCP, 'Enable', 'off');
        set(handles.buttonClearGCP, 'Enable', 'off');
        
        handles.img = [];
        handles.image_info = [];
        handles.roi = [];
    else
        % Enable buttons which depend upon the camera
        set(handles.buttonLoadImage, 'Enable', 'on');
        if check_gcp(handles) && check_image(handles)
            set(handles.buttonMarkGCP, 'Enable', 'on');
            set(handles.buttonImport, 'Enable', 'on');
            set(handles.buttonExportGCP, 'Enable', 'on');
            set(handles.buttonClearGCP, 'Enable', 'on');
        end
        
        handles = reload_time(handles);
        
        %     handles.initialEstimates = [];
        %     handles.calibration = [];
        %     handles.roi = [];
        %     handles.rectimg = [];
        %     handles.saved = false;
        
        m = size(handles.gcps, 1);
        handles.marked = -1 * ones(m, 2); % Sentinel value for non-marked GCPs
        handles.pickedGCPs = zeros(m, 1); % No GCP is picked (zero means false)
        handles = reload_gcp(handles);
    end
    cla(handles.axesImage);
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
    
    if ~check_gcp(handles)
        % Disable components which depend upon the GCP
        set(handles.editGCPx, 'String', '');
        set(handles.editGCPy, 'String', '');
        set(handles.editGCPz, 'String', '');
        set(handles.editGCPu, 'String', '');
        set(handles.editGCPv, 'String', '');
        
        set(handles.buttonMarkGCP, 'Enable', 'off');
        set(handles.buttonImport, 'Enable', 'off');
        set(handles.buttonExportGCP, 'Enable', 'off');
        set(handles.buttonClearGCP, 'Enable', 'off');
        set(handles.checkboxPickGCP, 'Enable', 'off');
    else
        % Update (x, y, z) coordinates of the GCP
        value = get(hObject, 'Value');
        curgcp = handles.gcps(value, :);
        set(handles.editGCPx, 'String', num2str(curgcp{3}, '%.2f'));
        set(handles.editGCPy, 'String', num2str(curgcp{4}, '%.2f'));
        set(handles.editGCPz, 'String', num2str(curgcp{5}, '%.2f'));
        set(handles.checkboxPickGCP, 'Value', handles.pickedGCPs(value));
        
        if check_image(handles)
            set(handles.buttonMarkGCP, 'Enable', 'on');
            set(handles.buttonImport, 'Enable', 'on');
            set(handles.buttonExportGCP, 'Enable', 'on');
            set(handles.buttonClearGCP, 'Enable', 'on');
        end
        
        % Does the current GCP have a (u, v) coordinate associated?
        isMarked = handles.marked(value, 1) ~= -1 && ...
            handles.marked(value, 2) ~= -1;
        
        if isMarked
            set(handles.editGCPu, 'String',...
                num2str(handles.marked(value, 1), '%.2f'));
            set(handles.editGCPv, 'String',...
                num2str(handles.marked(value, 2), '%.2f'));
        else
            
            set(handles.editGCPu, 'String', '');
            set(handles.editGCPv, 'String', '');
        end
    end
    
catch e
    disp(e.message)
end

% --- Executes on selection change in popupMethod.
function popupMethod_Callback(hObject, eventdata, handles)
% hObject    handle to popupMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupMethod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupMethod

try
    
    % Initial parameters for Pinhole
    params = {'fDu', 'fDv', 'u0', 'v0', 'k1', 'k2', ...
        'a', 'b', 'c', 'tx', 'ty', 'tz'};
    
    if check_method(handles) && check_time(handles) && ...
            check_station(handles) && check_camera(handles) && check_gcp(handles)
        method = get_method(handles);
        
        set(handles.buttonCalculate, 'Enable', 'on');
        
        if strcmpi(method, 'pinhole')
            
            for i = 1:numel(params)
                % Initially all estimates are picked
                eval(['set(handles.checkbox' params{i} ...
                    ', ''Enable'', ''on'');']);
                eval(['set(handles.checkbox' params{i} ...
                    ', ''Value'', true);']);
            end
            
            % Load initial estimates
            
            load_estimates(handles);
        else
            % If method is not Pinhole, no initial estimates can be provided
            for i = 1:numel(params)
                eval(['set(handles.checkbox' params{i} ...
                    ', ''Enable'', ''off'');']);
                eval(['set(handles.checkbox' params{i} ...
                    ', ''Value'', false);']);
            end
            
            for i = 1:numel(params)
                eval(['set(handles.edit' params{i} ...
                    ', ''String'', '''');']);
            end
        end
    else
        set(handles.buttonCalculate, 'Enable', 'off');
        
        for i = 1:numel(params)
            eval(['set(handles.checkbox' params{i} ...
                ', ''Enable'', ''off'');']);
            eval(['set(handles.checkbox' params{i} ...
                ', ''Value'', false);']);
        end
        
        for i = 1:numel(params)
            eval(['set(handles.edit' params{i} ...
                ', ''String'', '''');']);
        end
    end
    % Update handles structure
    guidata(hObject, handles);
    
catch e
    disp(e.message)
end

% --- Executes on button press in buttonLoadImage.
function buttonLoadImage_Callback(hObject, eventdata, handles)
% hObject    handle to buttonLoadImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    if ~check_station(handles) || ~check_camera(handles) || ~check_time(handles)
        %%%%% ERROR
        warndlg({'No station, camera or time was loaded',...
            'Please select a station, a camera and a time'},'Warning');
        return
    end
    
    %reboot connection to the database if necessary
    [handles.conn status] = renew_connection_db(handles.conn);
    
    if status == 1
        return
    end
    
    if ~handles.saved && ~isempty(handles.calibration)
        handles = save_calibration(handles);
    end
    
    cla(handles.axesImage)
    
    station = get_station(handles);
    camera = get_camera(handles);
    imgtime = get_time(handles);
    
    % Load nearest image to the selected time +/- one day.
    % Columns: {filename, path, timestamp}
    h = gui_message('Loading from database, this might take a while!','Loading...');
    handles.image_info = load_nearestimage(handles.conn, {'snap'}, camera, station, imgtime, 1440/(60*24));
    if ishandle(h)
        delete(h);
    end
    
    % If the image was not found in the database...
    if isempty(handles.image_info)
        %%%%% ERROR
        errordlg('This image does not exist in the database','Error');
        return
    end
    
    % Reset initial parameters for Pinhole
    params = {'fDu', 'fDv', 'u0', 'v0', 'k1', 'k2', ...
        'a', 'b', 'c', 'tx', 'ty', 'tz'};
    set(handles.buttonCalculate, 'Enable', 'off');
    set(handles.popupMethod, 'Value', 1)
    
    for i = 1:numel(params)
        eval(['set(handles.checkbox' params{i} ...
            ', ''Enable'', ''off'');']);
        eval(['set(handles.checkbox' params{i} ...
            ', ''Value'', false);']);
    end
    
    for i = 1:numel(params)
        eval(['set(handles.edit' params{i} ...
            ', ''String'', '''');']);
    end
    
    imgname = strtrim(handles.image_info{1});
    imglocation = handles.image_info{2};
    
    % If not found the image in physical disk
    if filesep == '/' | strfind(handles.root,'http://')
        changeFrom = '\';
        changeTo = '/';
    else
        changeFrom = '/';
        changeTo = '\';
    end
    
    fullpath = strrep(fullfile(handles.root, imglocation, imgname), changeFrom, changeTo);
    
    if strfind(handles.root, 'http://')
        warndlg(['The image is loading from an external server, '...
            'it may take some minutes.'],'Message');
    else
        if ~exist(fullpath, 'file')
            %%%%% ERROR
            warndlg('This image does not exist in the file disk','Warning');
            return
        end
    end
    
    handles.img = imread(fullpath);
    handles.initialEstimates = [];
    handles.calibration = [];
    handles.roi = [];
    handles.rectimg = [];
    handles.saved = false;
    
    % Show image
    imshow(handles.img, 'Parent', handles.axesImage);
    set(handles.panelImageAxis, 'Title', imgname);
    
    % Enable ROI button
    set(handles.buttonROI, 'Enable', 'on');
    
    t = handles.image_info{3};
    roi = load_roi(handles.conn, 'rect', camera, station, t, t);
    if isempty(roi)
        warndlg('No ROI was found in the database!', 'Warning');
    else
        uroi = cell2mat(roi(:, 4)); % U coordinates
        vroi = cell2mat(roi(:, 5)); % V coordinates
        handles.roi = [uroi vroi];
    end
    
    
    
    % If there are GCPs
    if check_gcp(handles)
        
        [m n] = size(handles.gcps);
        
        % Initialize marked GCPs
        handles.marked = -1 * ones(m, 2);
        handles.pickedGCPs = zeros(m, 1);
        
        set(handles.editGCPu, 'String', '');
        set(handles.editGCPv, 'String', '');
        
        set(handles.buttonMarkGCP, 'Enable', 'on');
        set(handles.buttonImport, 'Enable', 'on');
        set(handles.buttonExportGCP, 'Enable', 'on');
        set(handles.buttonClearGCP, 'Enable', 'on');
        
        % Update picked GCPs
        h = gui_message('Loading from database, this might take a while!','Loading...');
        pickedgcps = load_pickedgcps(handles.conn, station, camera, imgtime); % {name, idgcp, u, v, x, y, z}
        if ishandle(h)
            delete(h);
        end
        
        if isempty(pickedgcps)
            errordlg('No picked GCPs were found in the database!', 'Error');
            % Update handles structure
            guidata(hObject, handles);
            return;
        end
        
        n = size(pickedgcps, 1);
        m = size(handles.gcps, 1);
        
        for i = 1:m % For each GCP
            for j = 1:n % For each picked GCP found
                if handles.gcps{i, 1} == pickedgcps{j, 2} % Ids
                    handles.marked(i, 1) = pickedgcps{j, 3}; % U
                    handles.marked(i, 2) = pickedgcps{j, 4}; % V
                    handles.pickedGCPs(i) = true; % Set this GCP as picked
                end
            end
        end
        
        % Reload GCPs
        handles = reload_gcp(handles);
        
        % Show current (u, v) if available
        value = get(handles.popupGCP, 'Value');
        
        % Does the current GCP have a (u, v) coordinate associated?
        isMarked = handles.marked(value, 1) ~= -1 && ...
            handles.marked(value, 2) ~= -1;
        
        if isMarked
            set(handles.editGCPu, 'String', num2str(handles.marked(value, 1), '%.2f'));
            set(handles.editGCPv, 'String', num2str(handles.marked(value, 2), '%.2f'));
            set(handles.checkboxPickGCP, 'Value', true);
        end
    end
    
    % Update handles structure
    guidata(hObject, handles);
    
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
    plot_roi(handles)
    handles.motionActivated = true;
    
    % Update handles structure
    guidata(hObject, handles);
    
catch e
    disp(e.message)
end

function buttonClearGCP_Callback(hObject, eventdata, handles)
% hObject    handle to buttonClearGCP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    if ~handles.motionActivated
        value = get(handles.popupGCP, 'Value');
        handles.marked(value, 1) = -1;
        handles.marked(value, 2) = -1;
        handles.pickedGCPs(value) = false;
        
        set(handles.editGCPu, 'String', '');
        set(handles.editGCPv, 'String', '');
        
        reload_gcp(handles);
        
        % Update handles structure
        guidata(hObject, handles);
    end
    
catch e
    disp(e.message)
end

% --- Executes on button press in buttonCalculate.
function buttonCalculate_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCalculate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    if ~check_method(handles) || ~check_time(handles) || ...
            ~check_station(handles) || ~check_camera(handles) || ~check_gcp(handles)
        %%%%% ERROR
        warndlg({'No station, camera, time or method was loaded',...
            'Please select a station, a camera, a time and a method'},'Warning');
        return
    end
    
    method = get_method(handles);
    numgcps = sum(handles.pickedGCPs); % Number of picked GCPs
    
    m = size(handles.pickedGCPs, 1);
    
    if numgcps < 2 % If no GCP selected
        %%%%% ERROR
        warndlg('Please select at least two GCPs','Warning');
        return
    end
    
    data = cell(numgcps, 7);
    k = 1;
    for i = 1:m
        if handles.pickedGCPs(i)
            data{k, 1} = handles.gcps{i, 2}; % Name
            data{k, 2} = handles.gcps{i, 1}; % Id
            data{k, 3} = handles.marked(i, 1); % U
            data{k, 4} = handles.marked(i, 2); % V
            data{k, 5} = handles.gcps{i, 3}; % X
            data{k, 6} = handles.gcps{i, 4}; % Y
            data{k, 7} = handles.gcps{i, 5}; % Z
            k = k + 1;
        end
    end
    
    % Check ROI
    if isempty(handles.roi)
        warndlg('You have not selected a ROI!', 'Warning')
        return
    end
    
    % Check image
    if isempty(handles.img)
        warndlg('There is no image selected!', 'Warning')
        return
    end
    
    % Check resolution
    if ~check_resolution(handles)
        warndlg('There is no resolution selected!', 'Warning')
        return
    end
    
    resolution = get_resolution(handles);
    
    % Load initial estimates from GUI
    est = zeros(1, 12);
    
    % Boolean vector: 1 for selected estimates, 0 for not selected ones
    var = zeros(1, 12);
    
    % Estimates names
    params = {'fDu', 'fDv', 'u0', 'v0', 'k1', 'k2',...
        'a', 'b', 'c', 'tx', 'ty', 'tz'};
    
    % Fill var and est
    allEmpty = true;
    for i = 1:numel(params)
        eval(['var(' num2str(i) ') = get(handles.checkbox' params{i} ...
            ', ''Value'');']);
        
        str = eval(['get(handles.edit' params{i} ', ''String'');']);
        if ~isempty(str)
            allEmpty = false;
        end
        
        est(i) = str2double(str);
    end
    
    if strcmpi(method, 'pinhole')
        if allEmpty
            est = [];
        else
            for i = 1:numel(params)
                if isnan(est(i))
                    errordlg('Invalid initial estimates!', 'Error')
                    return
                end
            end
        end
    end
    
    % Actually calculate model parameters with method and estimates
    h = gui_message('Generating calibration parameters, this might take a while!','Please wait...');
    [H K D R t P ECN MSExy MSEuv un vn pos handles.rectimg] = ...
        create_calibration_parameters(handles.img, handles.roi, resolution,...
        method, data, est, var);
    if ishandle(h)
        delete(h);
    end
    
    handles.calibration.H = H;
    handles.calibration.K = K;
    handles.calibration.D = D;
    handles.calibration.R = R;
    handles.calibration.t = t;
    handles.calibration.P = P;
    handles.calibration.ECN = ECN;
    handles.calibration.MSExy = MSExy;
    handles.calibration.MSEuv = MSEuv;
    handles.calibration.un = un;
    handles.calibration.vn = vn;
    handles.calibration.pos = pos;
    
    if strcmpi(method, 'pinhole')
        load_estimates(handles);
    end
    
    if ~isempty(un)
        plot_method_result(handles);
    end
    
    % Update handles structure
    guidata(hObject, handles);
    
catch e
    disp(e.message)
end

% --- Executes on button press in buttonROI.
function buttonROI_Callback(hObject, eventdata, handles)
% hObject    handle to buttonROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    if check_station(handles) && check_camera(handles) && check_time(handles) &&...
            check_image(handles)
        
        station  = get_station(handles);
        camera   = get_camera(handles);
        
        filename = strtrim(handles.image_info{1});
        location =         handles.image_info{2};
        t        =         handles.image_info{3};
        
        roi = gui_roi_tool(station, camera, t, 'rect', t, filename, location);
        
        if ~isempty(roi)
            handles.roi = roi;
            
            plot_picked_gcps(handles);
            plot_roi(handles);
            
            % Update handles structure
            guidata(hObject, handles);
        end
    else
        errordlg('Please select a station, camera, time and image!', 'Error');
    end
    
catch e
    disp(e.message)
end

% --- Executes on button press in buttonClearEstimates.
function buttonClearEstimates_Callback(hObject, eventdata, handles)
% hObject    handle to buttonClearEstimates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    % Reset initial parameters for Pinhole
    params = {'fDu', 'fDv', 'u0', 'v0', 'k1', 'k2', ...
        'a', 'b', 'c', 'tx', 'ty', 'tz'};
    
    for i = 1:numel(params)
        eval(['set(handles.edit' params{i} ', ''String'', '''');']);
    end
catch e
    disp(e.message)
end

% --- Executes on button press in buttonImport.
function buttonImport_Callback(hObject, eventdata, handles)
% hObject    handle to buttonImport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    % Select path of the file to import
    if ispc
        [filename, pathname] = ...
            uigetfile({'*.xls';'*.xlsx';'*.mat'},'File Selector');
    else
        [filename, pathname] = ...
            uigetfile({'*.xls';'*.mat'},'File Selector');
    end
    if filename
        
        ind = strfind(filename,'.xlsx');
        ind2 = strfind(filename,'.xls');
        if ~isempty(ind) || ~isempty(ind2)
            [num txt data] = xlsread(fullfile(pathname, filename));
        else
            mat = fullfile(pathname, filename);
            vars = whos('-file', mat);
            load(mat, vars(1).name);
            data = eval(vars(1).name);
        end
        
        % Data should be a matrix of three columns {GCP name, U, V}
        names = data(:, 1);
        ucoord = cell2mat(data(:, 2));
        vcoord = cell2mat(data(:, 3));
        
        % Reset marked and picked GCPs
        m = size(handles.gcps, 1);
        n = size(data, 1);
        handles.marked = -1 * ones(m, 2); % Sentinel value for non-marked GCPs
        handles.pickedGCPs = zeros(m, 1); % No GCP is picked (zero means false)
        
        for i = 1:m
            for j = 1:n
                if strcmpi(handles.gcps(i, 2), names(j))
                    handles.pickedGCPs(i) = true;
                    handles.marked(i, :) = [ucoord(j) vcoord(j)];
                end
            end
        end
        
        value = get(handles.popupGCP, 'Value');
        
        if handles.pickedGCPs(value)
            U = handles.marked(value, 1);
            V = handles.marked(value, 2);
            
            set(handles.editGCPu, 'String', num2str(U, '%.2f'));
            set(handles.editGCPv, 'String', num2str(V, '%.2f'));
        else
            set(handles.editGCPu, 'String', '');
            set(handles.editGCPv, 'String', '');
        end
        
        handles = reload_gcp(handles);
        plot_picked_gcps(handles)
        plot_roi(handles)
    end
    guidata(hObject, handles);
    
catch e
    disp(e.message)
end

% --- Executes on button press in buttonExportGCP.
function buttonExportGCP_Callback(hObject, eventdata, handles)
% hObject    handle to buttonExportGCP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    % Data should be a matrix of three columns {GCP name, U, V}
    [filename, pathname] = uiputfile({'*.xls';'*.mat';'*.txt'},'Save picked GCPs as...');
    
    if ~filename
        return;
    end
    ind = find(handles.pickedGCPs);
    data = cell(length(ind), 3);
    for i = 1:length(ind)
        data{i, 1} = handles.gcps{ind(i), 2};
        data{i, 2} = handles.marked(ind(i), 1);
        data{i, 3} = handles.marked(ind(i), 2);
    end
    
    [tok, rem] = strtok(filename, '.');
    
    try
        if strcmpi(rem, '.xls')
            xlswrite(fullfile(pathname, filename), data(:, 1), ['A1:A' num2str(length(ind))]);
            xlswrite(fullfile(pathname, filename), data(:, 2:3), ['B1:C' num2str(length(ind))]);
        elseif strcmpi(rem, '.mat')
            save(fullfile(pathname, filename), 'data');
        elseif strcmpi(rem, '.txt')
            fid = fopen(fullfile(pathname, filename), 'w');
            m = size(data, 1);
            for i = 1:m
                fprintf(fid, '%s\t%e\t%e\n', data{i, 1}, data{i, 2}, data{i, 3});
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

% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    % If there is an image over which to select a point
    if handles.motionActivated && check_image(handles)
        value = get(handles.popupGCP, 'Value');
        
        % Does the current GCP have a (u, v) coordinate associated?
        isMarked = handles.marked(value, 1) ~= -1 && ...
            handles.marked(value, 2) ~= -1;
        
        [m n o] = size(handles.img);
        
        % Location of the cursor with respect to the image
        UV = get(handles.axesImage, 'CurrentPoint');
        U = UV(1, 1);
        V = UV(1, 2);
        
        % If cursor within image bounds
        if U > 0 && U <= n && V > 0 && V <= m;
            set(handles.figure1, 'Pointer', 'crosshair');
            set(handles.editGCPu, 'String', num2str(U, '%.2f'));
            set(handles.editGCPv, 'String', num2str(V, '%.2f'));
        else
            set(handles.figure1, 'Pointer', 'arrow');
            if isMarked
                set(handles.editGCPu, 'String', ...
                    num2str(handles.marked(value, 1), '%.2f'));
                set(handles.editGCPv, 'String', ...
                    num2str(handles.marked(value, 2), '%.2f'));
            else
                set(handles.editGCPu, 'String', '');
                set(handles.editGCPv, 'String', '');
            end
        end
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
    
    % Switch off motion for selecting points over the image
    if handles.motionActivated
        
        handles.motionActivated = false;
        
        set(handles.figure1, 'Pointer', 'arrow');
        
        value = get(handles.popupGCP, 'Value');
        UV = get(handles.axesImage, 'CurrentPoint');
        
        U = UV(1, 1);
        V = UV(1, 2);
        
        % Mark selected point over the image
        handles.marked(value, 1) = U;
        handles.marked(value, 2) = V;
        
        set(handles.editGCPu, 'String', num2str(U, '%.2f'));
        set(handles.editGCPv, 'String', num2str(V, '%.2f'));
        
        handles.pickedGCPs(value) = true;
        set(handles.checkboxPickGCP, 'Value', true);
        handles = reload_gcp(handles);
        
        % Repaint all GCPs
        plot_picked_gcps(handles);
        plot_roi(handles)
        
        % Update handles structure
        guidata(hObject, handles);
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
    
    if check_gcp(handles) && check_image(handles)
        valueGCP = get(handles.popupGCP, 'Value');
        
        % Does the current GCP have a (u, v) coordinate associated?
        isMarked = handles.marked(valueGCP, 1) ~= -1 && ...
            handles.marked(valueGCP, 2) ~= -1;
        
        if isMarked
            valuePickGCP = get(handles.checkboxPickGCP, 'Value');
            handles.pickedGCPs(valueGCP) = valuePickGCP;
            handles = reload_gcp(handles);
        else
            set(handles.checkboxPickGCP, 'Value', false);
        end
        
        % Update handles structure
        guidata(hObject, handles);
    end
    
catch e
    disp(e.message)
end

% --------------------------------------------------------------------
function menuItemShowCal_Callback(hObject, eventdata, handles)
% hObject    handle to menuItemShowCal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

plot_method_result(handles);

% --------------------------------------------------------------------
function menuItemShow_Callback(hObject, eventdata, handles)
% hObject    handle to menuItemShow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

show_rectified_image(handles, true);

% --------------------------------------------------------------------
function menuItemShowNoGrid_Callback(hObject, eventdata, handles)
% hObject    handle to menuItemShowNoGrid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

show_rectified_image(handles, false);

% --------------------------------------------------------------------
function menuItemSaveCal_Callback(hObject, eventdata, handles)
% hObject    handle to menuItemSaveCal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    if isempty(handles.calibration)
        warndlg({'You have not generated a calibration!',...
            'Please generate calibration'},'Warning');
        return
    end
    
    handles = save_calibration(handles);
    
    % Update handles structure
    guidata(hObject, handles);
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
% Check if there is a valid camera selected
function ok = check_camera(handles)
try
    value = get(handles.popupCamera, 'Value');
    ok = value ~= 1;
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Check if there is a valid method selected
function ok = check_method(handles)
try
    value = get(handles.popupMethod, 'Value');
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
% Check if there is a valid GCP selected
function ok = check_gcp(handles)
try
    ok = ~isempty(handles.gcps);
catch e
    disp(e.message)
end
%--------------------------------------------------------------------------
% Check if there is a valid image loaded
function ok = check_image(handles)
try
    ok = ~isempty(handles.img);
catch e
    disp(e.message)
end
%--------------------------------------------------------------------------
% Check if there is a valid resolution
function ok = check_resolution(handles)
try
    value = get(handles.editResolution, 'String');
    num = str2double(value);
    ok = ~isnan(num);
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
% Returns the selected method
function method = get_method(handles)
try
    value = get(handles.popupMethod, 'Value');
    contents = cellstr(get(handles.popupMethod, 'String'));
    method = contents{value};
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected resolution
function resolution = get_resolution(handles)
try
    value = get(handles.editResolution, 'String');
    resolution = str2double(value);
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected local time
function time = get_time(handles)
try
    
    %%% Java stuff
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
    set(handles.buttonLoadImage, 'Enable', 'off');
    set(handles.buttonMarkGCP, 'Enable', 'off');
    set(handles.buttonImport, 'Enable', 'off');
    set(handles.buttonExportGCP, 'Enable', 'off');
    set(handles.buttonClearGCP, 'Enable', 'off');
    
    handles.img = [];
    handles.image_info = [];
    handles.marked = [];
    handles.pickedGCPs = [];
    handles.initialEstimates = [];
    handles.calibration = [];
    handles.roi = [];
    handles.rectimg = [];
    handles.saved = false;
    
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Reload all GCPs from the database
function handles = reload_gcp(handles)

try
    if check_station(handles)
        m = size(handles.gcps, 1);
        
        strGCP = cell(0);
        
        % Write picked GCPs with a '*'
        valueGCP = get(handles.popupGCP, 'Value');
        for i = 1:m
            if handles.pickedGCPs(i)
                strGCP{i} = [handles.gcps{i, 2} '*'];
            else
                strGCP{i} = handles.gcps{i, 2};
            end
        end
        
        set(handles.popupGCP, 'String', strGCP);
        
        if ~isempty(strGCP)
            curgcp = handles.gcps(valueGCP, :);
            set(handles.popupGCP, 'Value', valueGCP);
            set(handles.checkboxPickGCP, 'Value', handles.pickedGCPs(valueGCP));
            set(handles.editGCPx, 'String', num2str(curgcp{3}, '%.2f'));
            set(handles.editGCPy, 'String', num2str(curgcp{4}, '%.2f'));
            set(handles.editGCPz, 'String', num2str(curgcp{5}, '%.2f'));
        end
        
        plot_picked_gcps(handles);
        plot_roi(handles);
    end
    
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Unload all GCPs
function handles = reset_gcp(handles)

try
    
    set(handles.popupGCP, 'Value', 1);
    set(handles.popupGCP, 'String', ' ');
    
    set(handles.editGCPx, 'String', '');
    set(handles.editGCPy, 'String', '');
    set(handles.editGCPz, 'String', '');
    set(handles.editGCPu, 'String', '');
    set(handles.editGCPv, 'String', '');
    
    set(handles.buttonMarkGCP, 'Enable', 'off');
    set(handles.buttonImport, 'Enable', 'off');
    set(handles.buttonExportGCP, 'Enable', 'off');
    set(handles.buttonClearGCP, 'Enable', 'off');
    
    handles.gcps = [];
    handles.marked = [];
    handles.roi = [];
    
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Reload the time sliders, updating the initial and final times for each
function handles = reload_time(handles)
% Set time sliders

try
    
    if check_station(handles) && check_camera(handles)
        
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
        
        timevec = datevec(handles.time_min);
        handles.datebox.setCalendar(java.util.GregorianCalendar(timevec(1), timevec(2) - 1, ...
            timevec(3), timevec(4), timevec(5), timevec(6)));
        
        % Put the DateSpinnerComboBox object in a GUI panel
        [handles.hDatebox,hContainer] = javacomponent(handles.datebox,[2,3,193,22],handles.panelTime);
        
        set(handles.hDatebox, 'ActionPerformedCallback', {@timeCallbackFunction, handles});
    end
    
catch e
    disp(e.message)
end

% Callback for DateSpinnerComboBox object
function timeCallbackFunction(hObject, eventdata, handles)

try
    
    if check_station(handles) && check_camera(handles)
        
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
% Paint all picked GCPs over the image
function plot_picked_gcps(handles)

try
    
    [m n] = size(handles.marked);
    
    imshow(handles.img, 'Parent', handles.axesImage)
    
    for i = 1:m
        isMarked = handles.marked(i, 1) ~= -1 && handles.marked(i, 2) ~= -1;
        if handles.pickedGCPs(i) && isMarked
            U = handles.marked(i, 1);
            V = handles.marked(i, 2);
            name = handles.gcps{i, 2};
            
            hold(handles.axesImage, 'on')
            plot(handles.axesImage, U, V, '*r');
            text(U, V, name, 'Parent', handles.axesImage, 'Color', 'yellow',...
                'FontSize', 8, 'VerticalAlignment', 'bottom');
        end
    end
    
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Paint the calibrated GCP values over the image
function plot_method_result(handles)

try
    
    if isempty(handles.calibration)
        %%%%% ERROR
        warndlg('No calibration has been generated!','Warning');
        return
    end
    if isempty(handles.img)
        %%%%% ERROR
        warndlg('No image is loaded!','Warning');
        return
    end
    imshow(handles.img, 'Parent', handles.axesImage)
    m = length(handles.pickedGCPs);
    
    k = sum(handles.pickedGCPs); % Number of picked GCPs
    
    % Coordinates of calibrated GCPs
    U = zeros(k, 1);
    V = zeros(k, 1);
    
    k = 1;
    for i = 1:m
        if handles.pickedGCPs(i)
            U(k) = handles.marked(i, 1);
            V(k) = handles.marked(i, 2);
            k = k + 1;
        end
    end
    
    % Actual GCP coordinates
    un = handles.calibration.un;
    vn = handles.calibration.vn;
    pos = handles.calibration.pos;
    
    hold on
    plot(handles.axesImage, un, vn, 'gs', 'MarkerSize', 7)
    
    for i = 1:length(un)
        hold on
        plot(handles.axesImage, U(pos(i)), V(pos(i)), '*r');
        hold on
        plot(handles.axesImage, [un(i) U(pos(i))], [vn(i) V(pos(i))], 'y')
    end
    plot_roi(handles);
    
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Paint the selected ROI over the image
function plot_roi(handles)

try
    
    if isempty(handles.roi)
        return
    end
    
    [m n o] = size(handles.roi);
    hold(handles.axesImage, 'on');
    for i = 1:m
        j = mod(i, m) + 1;
        
        p1 = handles.roi(i, :);
        p2 = handles.roi(j, :);
        plot(handles.axesImage, p1(1), p1(2), '*y')
        plot(handles.axesImage, [p1(1) p2(1)], [p1(2) p2(2)], 'r');
    end
    
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Load initial estimates

function est = load_estimates(handles)

try
    
    time = get_time(handles);
    station = get_station(handles);
    camera = get_camera(handles);
    method = get_method(handles);
    params = {'fDu', 'fDv', 'u0', 'v0', 'k1', 'k2', ...
        'a', 'b', 'c', 'tx', 'ty', 'tz'};
    
    [est, message] = initial_estimates_pinhole(station, camera, time);
    
    if isstruct(handles.calibration) && ~isempty(handles.calibration.K)...
            && ~isempty(handles.calibration.D) && ~isempty(handles.calibration.R)...
            && ~isempty(handles.calibration.t)
        
        C = handles.calibration;
        est = [C.K(1,1) -C.K(2,2) C.K(1,3) C.K(2,3) C.D(1) C.D(2) rodrigues(C.R)' C.t'];
    end
    
    if isempty(est)
        warndlg('No initial estimates for Pinhole model were found!', 'Warning');
    end
    
    if ~isempty(est)
        for i = 1:numel(params)
            % Show estimates values
            eval(['set(handles.edit' params{i} ...
                ', ''String'', num2str(est(' num2str(i) '), ''%e''));']);
        end
    end
    
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Display the merged image
function show_rectified_image(handles, with_grid)

try
    if ~isempty(handles.rectimg)
        if with_grid
            uroi = handles.roi(:, 1); % U coordinates
            vroi = handles.roi(:, 2); % V coordinates
            zroi = 0;         % level value, fixed
            plot_rectified(handles.rectimg, handles.calibration.H, ...
                handles.calibration.K, handles.calibration.D, [uroi vroi], zroi)
        else
            figure
            imshow(handles.rectimg);
        end
    else
        %%% WARNING
        warndlg('You have not calculated a calibration!', 'Warning');
    end
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Save calibration
function handles = save_calibration(handles)

try
    
    % Ask the user if he is sure about saving the calibration
    choice = questdlg('Are you sure you want to save the calibration in the database?', ...
        'Save calibration', 'Yes', 'No','No');
    
    if strcmp(choice, 'No')
        return
    end
    
    if ~check_resolution(handles)
        warndlg('Please select a valid resolution!', 'Warning');
        return
    end
    
    camera = get_camera(handles);
    station = get_station(handles);
    resolution = get_resolution(handles);
    % t = now; % Time of creation of the calibration
    t = handles.image_info{3};
    
    % The parameters are inserted into the database as a cell array where odd
    % positions (1-indexed) are the parameter names, and even positions are the
    % corresponding values (scalars, vectors or matrices)
    parameters = cell(0);
    if ~isempty(handles.calibration.H)
        parameters{end+1} = 'H';
        parameters{end+1} = handles.calibration.H;
    end
    if ~isempty(handles.calibration.K)
        parameters{end+1} = 'K';
        parameters{end+1} = handles.calibration.K;
    end
    if ~isempty(handles.calibration.R)
        parameters{end+1} = 'R';
        parameters{end+1} = handles.calibration.R;
    end
    if ~isempty(handles.calibration.D)
        parameters{end+1} = 'D';
        parameters{end+1} = handles.calibration.D;
    end
    if ~isempty(handles.calibration.t)
        parameters{end+1} = 't';
        parameters{end+1} = handles.calibration.t;
    end
    if ~isempty(handles.calibration.P)
        if ~isempty(handles.calibration.P.fDu)
            parameters{end+1} = 'fDu';
            parameters{end+1} = handles.calibration.P.fDu;
        end
        if ~isempty(handles.calibration.P.fDv)
            parameters{end+1} = 'fDv';
            parameters{end+1} = handles.calibration.P.fDv;
        end
        if ~isempty(handles.calibration.P.u0)
            parameters{end+1} = 'u0';
            parameters{end+1} = handles.calibration.P.u0;
        end
        if ~isempty(handles.calibration.P.v0)
            parameters{end+1} = 'v0';
            parameters{end+1} = handles.calibration.P.v0;
        end
        if ~isempty(handles.calibration.P.k1)
            parameters{end+1} = 'k1';
            parameters{end+1} = handles.calibration.P.k1;
        end
        if ~isempty(handles.calibration.P.k2)
            parameters{end+1} = 'k2';
            parameters{end+1} = handles.calibration.P.k2;
        end
        if ~isempty(handles.calibration.P.tao)
            parameters{end+1} = 'tao';
            parameters{end+1} = handles.calibration.P.tao;
        end
        if ~isempty(handles.calibration.P.sigma)
            parameters{end+1} = 'sigma';
            parameters{end+1} = handles.calibration.P.sigma;
        end
        if ~isempty(handles.calibration.P.phi)
            parameters{end+1} = 'phi';
            parameters{end+1} = handles.calibration.P.phi;
        end
        if ~isempty(handles.calibration.P.xc)
            parameters{end+1} = 'xc';
            parameters{end+1} = handles.calibration.P.xc;
        end
        if ~isempty(handles.calibration.P.yc)
            parameters{end+1} = 'yc';
            parameters{end+1} = handles.calibration.P.yc;
        end
        if ~isempty(handles.calibration.P.zc)
            parameters{end+1} = 'zc';
            parameters{end+1} = handles.calibration.P.zc;
        end
    end
    
    % The error measures are optional
    optional = cell(0);
    if ~isempty(handles.calibration.MSExy)
        optional{end+1} = 'EMCxy';
        optional{end+1} = handles.calibration.MSExy;
    end
    if ~isempty(handles.calibration.MSEuv)
        optional{end+1} = 'EMCuv';
        optional{end+1} = handles.calibration.MSEuv;
    end
    if ~isempty(handles.calibration.ECN)
        optional{end+1} = 'NCE';
        optional{end+1} = handles.calibration.ECN;
    end
    
    %reboot connection to the database if necessary
    [handles.conn status] = renew_connection_db(handles.conn);
    
    if status == 1
        return
    end
    
    % Do the insertion
    h = gui_message('Inserting into database, this might take a while!','Saving...');
    
    if isempty(handles.roi)
        errordlg('No ROI has been selected!', 'Error');
        return;
    end
    
    uroi = handles.roi(:, 1); % U coordinates
    vroi = handles.roi(:, 2); % V coordinates
        
    
    data_calibration  = load_calibration(handles.conn, station, camera, t);
    calibration_time = -1;
    if ~isempty(data_calibration)
        calibration_time = data_calibration{4};
    end
    
    if isempty(data_calibration) || t ~= calibration_time
        [status idcal] = insert_calibration(handles.conn, camera, station, t, resolution, parameters, optional);
    else
        idcal = char(data_calibration(1));
        status_delete = delete_calibration_id(handles.conn, station, idcal);
        if status_delete == 0
            status = insert_calibration_id(handles.conn, idcal, camera, station, t, resolution, parameters, optional);
        else
            status = 1;
        end
    end
    if status == 1
        errordlg('The calibration could not be inserted in the database!');
        return;
    end
    
    status = insert_roi(handles.conn, station, 'rect', idcal, t, uroi, vroi);
    if status == 1
        errordlg('The ROI could not be inserted in the database!');
        return;
    end
    
    % Insert new picked GCPs
    [m n] = size(handles.marked);
    
    for i = 1:m
        isMarked = handles.marked(i, 1) ~= -1 && handles.marked(i, 2) ~= -1;
        if handles.pickedGCPs(i) && isMarked
            U = handles.marked(i, 1);
            V = handles.marked(i, 2);
            idgcp = handles.gcps{i, 1};
            
            status = insert_pickedgcp(handles.conn, idcal, idgcp, station, U, V);
            if status == 1
                errordlg('The picked GCP could not be inserted in the database!');
                return;
            end
        end
    end
    
    warndlg('The calibration was successfully saved!', 'Success');
    handles.saved = true;
    
    if ishandle(h)
        delete(h);
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
    
    if ~handles.saved && ~isempty(handles.calibration)
        handles = save_calibration(handles);
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
