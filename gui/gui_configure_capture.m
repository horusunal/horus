function varargout = gui_configure_capture(varargin)
% GUI_CONFIGURE_CAPTURE M-file for gui_configure_capture.fig
% GUI_CONFIGURE_CAPTURE, by itself, creates a new GUI_CONFIGURE_CAPTURE or raises the existing
% singleton*.
%
% H = GUI_CONFIGURE_CAPTURE returns the handle to a new GUI_CONFIGURE_CAPTURE or the handle to
% the existing singleton*.
%
% GUI_CONFIGURE_CAPTURE('CALLBACK',hObject,eventData,handles,...) calls the local
% function named CALLBACK in GUI_CONFIGURE_CAPTURE.M with the given input arguments.
%
% GUI_CONFIGURE_CAPTURE('Property','Value',...) creates a new GUI_CONFIGURE_CAPTURE or raises the
% existing singleton*. Starting from the left, property value pairs are
% applied to the GUI before gui_configure_capture_OpeningFcn gets called. An
% unrecognized property name or invalid value makes property application
% stop. All inputs are passed to gui_configure_capture_OpeningFcn via varargin.
%
% *See GUI Options on GUIDE's Tools menu. Choose "GUI allows only one
% instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_configure_capture

% Written by
% Sebastian Munera Alvarez and
% Cesar Augusto Cartagena Ocampo
% for the HORUS Project
% Universidad Nacional de Colombia
% Copyright 2011 HORUS
% Last Modified by GUIDE v2.5 09-Nov-2012 22:48:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name', mfilename, ...
    'gui_Singleton', gui_Singleton, ...
    'gui_OpeningFcn', @gui_configure_capture_OpeningFcn, ...
    'gui_OutputFcn', @gui_configure_capture_OutputFcn, ...
    'gui_LayoutFcn', [] , ...
    'gui_Callback', []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gui_configure_capture is made visible.
function gui_configure_capture_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject handle to figure
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)
% varargin command line arguments to gui_configure_capture (see VARARGIN)

% Choose default command line output for gui_configure_capture

try
    
    handles.output = hObject;
    handles.xmlfile = 'capture_info.xml';
    
    handles.curroi = struct('xcoords', [], 'ycoords', []);
    handles.stackQueue = struct('id', {}, 'start_hour', {}, 'start_minute', {}, ...
        'end_hour', {}, 'end_minute', {}, 'time_step', {}, 'num_frames', {}, ...
        'roi_x', {}, 'roi_y', {}, 'cam', {});
    
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
    
    strCapture = {'Select an option', 'New capture'};
    set(handles.popupCaptureID, 'String', strCapture);
    
    % Set hour and minutes defaults
    strStartHour = cell(0);
    strStartMinute = cell(0);
    strEndHour = cell(0);
    strEndMinute = cell(0);
    
    for i = 0:23
        strStartHour{i + 1} = num2str(i, '%02d');
        strEndHour{i + 1} = num2str(i, '%02d');
    end
    set(handles.popupImageStartHour, 'String', strStartHour);
    set(handles.popupStackStartHour, 'String', strStartHour);
    set(handles.popupTransferStartHour, 'String', strStartHour);
    
    set(handles.popupImageEndHour, 'String', strEndHour);
    set(handles.popupStackEndHour, 'String', strEndHour);
    set(handles.popupTransferEndHour, 'String', strEndHour);
    
    for i = 0:59
        strStartMinute{i + 1} = num2str(i, '%02d');
        strEndMinute{i + 1} = num2str(i, '%02d');
    end
    set(handles.popupImageStartMinute, 'String', strStartMinute);
    set(handles.popupStackStartMinute, 'String', strStartMinute);
    set(handles.popupTransferStartMinute, 'String', strStartMinute);
    
    set(handles.popupImageEndMinute, 'String', strEndMinute);
    set(handles.popupStackEndMinute, 'String', strEndMinute);
    set(handles.popupTransferEndMinute, 'String', strEndMinute);
    
    set(handles.editRemotePath, 'String', '.')
   
    % Update handles structure
    guidata(hObject, handles);
    
    % Put logo
    logo = imread('LogoHorusMin.png');
    imshow(logo, 'Parent', handles.axesLogo)
catch e
    disp(e.message)
end
% UIWAIT makes gui_configure_capture wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_configure_capture_OutputFcn(hObject, eventdata, handles)
% varargout cell array for returning output args (see VARARGOUT);
% hObject handle to figure
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupStation.
function popupStation_Callback(hObject, eventdata, handles)
% hObject handle to popupStation (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupStation contents as cell array
% contents{get(hObject,'Value')} returns selected item from popupStation

try
	[handles numcam]= reload_camera(handles);
    if check_station(handles) && numcam > 0
        
        %reboot connection to the database if necessary
        [handles.conn, status] = renew_connection_db(handles.conn);

        if status == 1
            return
        end
        
        station = get_station(handles);
        types = load_imagetype_name(handles.conn, station);
        if isempty(types)
            warndlg('No image types were found in the database!', 'Warning');
            return;
        end
        
        handles = reload_types(handles);
        xml = loadXML(handles.xmlfile, 'Configuration', 'station', station);
        
        xmlPath = strcat('Configuration[station=', station,...
            ']/CaptureConfig/Capture[type=image]');
        captureImageNodes = getNodes(xml, xmlPath);
        
        xmlPath = strcat('Configuration[station=', station,...
            ']/CaptureConfig/Capture[type=stack]');
        captureStackNodes = getNodes(xml, xmlPath);
        
        xmlPath = strcat('Configuration[station=', station,...
            ']/CaptureConfig/Transfer');
        captureTransferNodes = getNodes(xml, xmlPath);
        
        if ~isempty(captureImageNodes)
            captureImage = captureImageNodes{1};
            
            val = getNodeVal(captureImage, 'StartHour');
            set(handles.popupImageStartHour, 'Value', str2double(val) + 1)
            
            val = getNodeVal(captureImage, 'StartMinute');
            set(handles.popupImageStartMinute, 'Value', str2double(val) + 1)
            
            val = getNodeVal(captureImage, 'EndHour');
            set(handles.popupImageEndHour, 'Value', str2double(val) + 1)
            
            val = getNodeVal(captureImage, 'EndMinute');
            set(handles.popupImageEndMinute, 'Value', str2double(val) + 1)
            
            val = getNodeVal(captureImage, 'TimeStep');
            set(handles.editImageTimeStep, 'String', val)
            
            val = getNodeVal(captureImage, 'CaptureTime');
            set(handles.editTime, 'String', val)
            
            typesxml = cell(0);
            for k = 1:numel(types)
                val = getNodeVal(captureImage, char(types(k)));
                if ~isempty(val)
                    if eval(val)
                        typesxml{end+1} = char(types(k));
                    end
                end
            end
            
            set(handles.listboxImageType, 'Value', 1, 'String', typesxml);
            
        end
        
        if ~isempty(captureTransferNodes)
            
            captureTransfer = captureTransferNodes{1};
            attrib = captureTransfer.getAttributes().item(0);
            name = char(attrib.getName());
            value = char(attrib.getValue());
            
            ftphost = '';
            if strcmp(name, 'FTPHost')
                ftphost = value;
            end
            set(handles.editFTPHost, 'String', ftphost)
            
            val = getNodeVal(captureTransfer, 'FTPUser');
            set(handles.editFTPUser, 'String', val)
            
            val = getNodeVal(captureTransfer, 'FTPPass');
            val = decrypt_aes(val, handles.datapath);
            set(handles.editFTPPass, 'String', val)
            
            val = getNodeVal(captureTransfer, 'StartHour');
            set(handles.popupTransferStartHour, 'Value', str2double(val) + 1)
            
            val = getNodeVal(captureTransfer, 'StartMinute');
            set(handles.popupTransferStartMinute, 'Value', str2double(val) + 1)
            
            val = getNodeVal(captureTransfer, 'EndHour');
            set(handles.popupTransferEndHour, 'Value', str2double(val) + 1)
            
            val = getNodeVal(captureTransfer, 'EndMinute');
            set(handles.popupTransferEndMinute, 'Value', str2double(val) + 1)
            
            val = getNodeVal(captureTransfer, 'TimeStep');
            set(handles.editTransferTimeStep, 'String', val)
            
            val = getNodeVal(captureTransfer, 'EmailUser');
            set(handles.editEmailAcc, 'String', val)
            
            val = getNodeVal(captureTransfer, 'EmailPass');
            val = decrypt_aes(val, handles.datapath);
            set(handles.editEmailPass, 'String', val)
            
            val = getNodeVal(captureTransfer, 'EmailRcpt');
            set(handles.editEmailRecpt, 'String', val)
            
            val = getNodeVal(captureTransfer, 'RootPath');
            set(handles.editRemotePath, 'String', val)
            
        end
        
        if ~isempty(captureStackNodes)
            handles = reload_stack_ids(handles);
        end
        set(handles.buttonRemotePath, 'Enable', 'on');
        set(handles.buttonSave, 'Enable', 'on');
        set(handles.show_time, 'Enable', 'on');
        % Update handles structure
        guidata(hObject, handles);
    else
        set(handles.popupImageStartHour, 'Value', 1);
        set(handles.popupImageEndHour, 'Value', 1);
        set(handles.popupImageStartMinute, 'Value', 1);
        set(handles.popupImageEndMinute, 'Value', 1);
        set(handles.editImageTimeStep, 'String', '');
        set(handles.editTime, 'String', '0', 'Enable', 'inactive');
        set(handles.popupImageType, 'String', ' ', 'Value', 1);
        set(handles.listboxImageType, 'String', '', 'Value', 1);
        set(handles.popupCaptureID, 'String', {'Select an option', 'New capture'}, 'Value', 1);
        set(handles.popupStackStartHour, 'Value', 1);
        set(handles.popupStackEndHour, 'Value', 1);
        set(handles.popupStackStartMinute, 'Value', 1);
        set(handles.popupStackEndMinute, 'Value', 1);
        set(handles.editStackTimeStep, 'String', '');
        set(handles.editStackFrames, 'String', '');
        set(handles.popupCamera, 'String', ' ', 'Value', 1);
        set(handles.editFTPHost, 'String', '');
        set(handles.editFTPPass, 'String', '');
        set(handles.editFTPUser, 'String', '');
        set(handles.popupTransferStartHour, 'Value', 1);
        set(handles.popupTransferEndHour, 'Value', 1);
        set(handles.popupTransferStartMinute, 'Value', 1);
        set(handles.popupTransferEndMinute, 'Value', 1);
        set(handles.editTransferTimeStep, 'String', '');
        set(handles.editEmailAcc, 'String', '');
        set(handles.editEmailPass, 'String', '');
        set(handles.editEmailRecpt, 'String', '');
        set(handles.editRemotePath, 'String', '');
        set(handles.buttonDeleteStack, 'Enable', 'off');
        set(handles.buttonRemotePath, 'Enable', 'off');
        set(handles.buttonBuildCaptureAuto, 'Enable', 'off');
        set(handles.buttonBuildTransferAuto, 'Enable', 'off');
        set(handles.buttonSave, 'Enable', 'off');
        set(handles.show_time, 'Enable', 'off');
        set(handles.buttonROI, 'Enable', 'off');
        set(handles.buttonEnqueueStack, 'Enable', 'off');
        handles.curroi = struct('xcoords', [], 'ycoords', []);
        handles.stackQueue = struct('id', {}, 'start_hour', {}, 'start_minute', {}, ...
        'end_hour', {}, 'end_minute', {}, 'time_step', {}, 'num_frames', {}, ...
        'roi_x', {}, 'roi_y', {}, 'cam', {});
        
        % Update handles structure
        guidata(hObject, handles);
    end
catch e
    disp(e.message)
end

% --- Executes on selection change in popupCaptureID.
function popupCaptureID_Callback(hObject, eventdata, handles)
% hObject handle to popupCaptureID (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupCaptureID contents as cell array
% contents{get(hObject,'Value')} returns selected item from popupCaptureID

try
    
    [handles numcam]= reload_camera(handles);
    if check_station(handles) && numcam > 0
    
        value = get(handles.popupCaptureID, 'Value');
        
        if value == 1
            set(handles.buttonROI, 'Enable', 'off');
            set(handles.buttonEnqueueStack, 'Enable', 'off');
        else
            set(handles.buttonROI, 'Enable', 'on');
            set(handles.buttonEnqueueStack, 'Enable', 'on');
        end
        
        if value <= 2
            set(handles.buttonDeleteStack, 'Enable', 'off');
            set(handles.popupStackStartHour, 'Value', 1);
            set(handles.popupStackStartMinute, 'Value', 1);
            set(handles.popupStackEndHour, 'Value', 1);
            set(handles.popupStackEndMinute, 'Value', 1);
            set(handles.editStackTimeStep, 'String', '');
            set(handles.editStackFrames, 'String', '');
            return
        end
        
        id = get_stack_capture(handles);
        
        set(handles.buttonDeleteStack, 'Enable', 'on');
        
        for i = 1:numel(handles.stackQueue)
            if handles.stackQueue(i).id == id
                set(handles.popupStackStartHour, 'Value', handles.stackQueue(i).start_hour + 1)
                set(handles.popupStackStartMinute, 'Value', handles.stackQueue(i).start_minute + 1)
                set(handles.popupStackEndHour, 'Value', handles.stackQueue(i).end_hour + 1)
                set(handles.popupStackEndMinute, 'Value', handles.stackQueue(i).end_minute + 1)
                set(handles.editStackTimeStep, 'String', handles.stackQueue(i).time_step)
                set(handles.editStackFrames, 'String', handles.stackQueue(i).num_frames)
                handles.curroi.xcoords = handles.stackQueue(i).roi_x;
                handles.curroi.ycoords = handles.stackQueue(i).roi_y;
                break;
            end
        end
    end
    % Update handles structure
    guidata(hObject, handles);
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Capture an image using the configured camera
function im = captureImage(handles)

im = [];
try
    station = get_station(handles);
    cam = get_stack_camera(handles);
    xml = loadXML(handles.xmlfile, 'Configuration', 'station', station);
    
    xmlPath = strcat('Configuration[station=', station,...
        ']/CameraConfig/Camera[id=', cam, ']');
    cameraNode = getNodes(xml, xmlPath);
    if isempty(cameraNode)
        return;
    end
    
    cameraNode = cameraNode{1};
    fr = getNodeVal(cameraNode, 'FrameRate');
% fr = eval(fr);
    gm = getNodeVal(cameraNode, 'GainMode');
    sm = getNodeVal(cameraNode, 'ShutterMode');
    wb = getNodeVal(cameraNode, 'WhiteBalanceMode');
    adaptor = getNodeVal(cameraNode, 'AdaptorName');
    device = getNodeVal(cameraNode, 'DeviceID');
    format = getNodeVal(cameraNode, 'DeviceFormat');
    
    % Create video input object according to all the information selected
    camobj = videoinput(adaptor, device, format);
    source = getselectedsource(camobj);

    hsource = set(source);
    
    if isfield(hsource, 'FrameRate') && ~isempty(fr)
        set(source, 'FrameRate', fr)
    end
    if isfield(hsource, 'GainMode') && ~strcmpi(gm, 'none')
        set(source, 'GainMode', gm)
    end
    if isfield(hsource, 'ShutterMode') && ~strcmpi(sm, 'none')
        set(source, 'ShutterMode', sm)
    end
    if ~strcmpi(wb, 'none')
        if isfield(hsource, 'WhiteBalanceMode')
            set(source, 'WhiteBalanceMode', wb)
        else
            set(source, 'WhitebalanceMode', wb)
        end
    end
    
    triggerconfig(camobj, 'manual');
    set(camobj, 'FramesPerTrigger', 1);
    set(camobj, 'TriggerRepeat', Inf);

    start(camobj);
    trigger(camobj);
    im = getdata(camobj, 1);
    stop(camobj), delete(camobj), clear camobj;

catch e
    disp(e.message)
end

% --- Executes on button press in buttonROI.
function buttonROI_Callback(hObject, eventdata, handles)
% hObject handle to buttonROI (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)

try
    im = captureImage(handles);
    if isempty(im)
        errordlg('This camera is not configured yet!', 'Error');
        return;
    end
    
    fig = figure;
    imshow(im);

    xcoords = [];
    ycoords = [];
    done = false;
    while ~done
        [x y button] = ginput(1);
        if button == 3 || button == 1 % Right click: Quit, Left click: Mark point
            xcoords = [xcoords, x];
            ycoords = [ycoords, y];
            
        end
        if button == 'x' || button == 'X' % Erase
            xcoords = xcoords(1:end-1);
            ycoords = ycoords(1:end-1);
        end
        imshow(im);
        n = length(xcoords);
        for i = 1:n
            hold on
            plot(xcoords(i), ycoords(i), 'r*');
            if i > 1
                hold on
                plot([xcoords(i - 1) xcoords(i)], ...
                    [ycoords(i - 1) ycoords(i)], 'y')
            end
        end
        if button == 3
            
            choice = questdlg('Are you satisfied with this ROI?', ...
                'Select ROI', 'Yes', 'No', 'Cancel','No');
            if strcmp(choice, 'No') || strcmp(choice, 'Cancel')
                done = false;
            else
                done = true;
            end
            
        end
    end
    n = length(xcoords);
    if n > 1
        hold on
        plot([xcoords(1) xcoords(end)], ...
            [ycoords(1) ycoords(end)], 'y')
    end

    if length(xcoords) == length(ycoords) && length(xcoords) >= 3
        handles.curroi.xcoords = xcoords;
        handles.curroi.ycoords = ycoords;
        
        choice = questdlg('The ROI was correctly generated! Press Ok to continue', ...
            'ROI generated!', 'Ok','Ok');
        if strcmp(choice, 'Ok')
            close(fig);
        end
        
    else
        errordlg('Invalid ROI!', 'Error');
    end
    
% % Select an image for marking points
% [file path] = uigetfile({'*.jpg'; '*.png'}, 'Select an image');
% if file
% im = imread(fullfile(path, file));
% figure;
% imshow(im);
%
% xcoords = [];
% ycoords = [];
% done = false;
% while ~done
% [x y button] = ginput(1);
% if button == 3 || button == 1 % Right click: Quit, Left click: Mark point
% xcoords = [xcoords, x];
% ycoords = [ycoords, y];
% if button == 3
% done = true;
% end
% end
% if button == 'x' || button == 'X' % Erase
% xcoords = xcoords(1:end-1);
% ycoords = ycoords(1:end-1);
% end
% imshow(im);
% n = length(xcoords);
% for i = 1:n
% hold on
% plot(xcoords(i), ycoords(i), 'r*');
% if i > 1
% hold on
% plot([xcoords(i - 1) xcoords(i)], ...
% [ycoords(i - 1) ycoords(i)], 'y')
% end
% end
% end
% n = length(xcoords);
% if n > 1
% hold on
% plot([xcoords(1) xcoords(end)], ...
% [ycoords(1) ycoords(end)], 'y')
% end
%
% if length(xcoords) == length(ycoords) && length(xcoords) > 3
% handles.curroi.xcoords = xcoords;
% handles.curroi.ycoords = ycoords;
% else
% errordlg('Invalid ROI!', 'Error');
% end
%
% else % If there are no images, input coordinates directly
% prompt = {'X Coordinates:', 'Y Coordinates:'};
% title = 'ROI Parameters';
% num_lines = 1;
%
% if isempty(handles.curroi.xcoords)
% default = {'0', '0'};
% else
% xcoords = '';
% ycoords = '';
% first = true;
%
% for i = 1:numel(handles.curroi.xcoords)
% if first
% first = false;
% else
% xcoords = [xcoords, ' '];
% ycoords = [ycoords, ' '];
% end
% xcoords = [xcoords, num2str(handles.curroi.xcoords(i))];
% ycoords = [ycoords, num2str(handles.curroi.ycoords(i))];
% end
%
% default = {xcoords, ycoords};
% end
%
% answer = inputdlg(prompt, title, num_lines, default);
%
% if isempty(answer)
% return
% end
%
% if isempty(answer{1}) || isempty(answer{2})
% errordlg('The ROI you have selected is not valid!','Error');
% return
% end
%
% parts = regexp(answer{1}, '[ \t]+', 'split');
% xcoords = NaN(numel(parts), 1);
% for i = 1:numel(parts)
% xcoords(i) = str2double(parts{i});
% end
%
% parts = regexp(answer{2}, '[ \t]+', 'split');
% ycoords = NaN(numel(parts), 1);
% for i = 1:numel(parts)
% ycoords(i) = str2double(parts{i});
% end
%
% if length(xcoords) == length(ycoords) && length(xcoords) > 3
% handles.curroi.xcoords = xcoords;
% handles.curroi.ycoords = ycoords;
% else
% errordlg('Invalid ROI!', 'Error');
% end
% end
    
    % Update handles structure
    guidata(hObject, handles);
catch e
    disp(e.message)
end


% --- Executes on button press in buttonSave.
function buttonSave_Callback(hObject, eventdata, handles)
% hObject handle to buttonSave (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)

try
    
    %%%% SAVE TRANSFER CONFIGURATION
    station = get_station(handles);
    host = get_ftp_host(handles);
    user = get_ftp_user(handles);
    pass = get_ftp_pass(handles);
    start_hour = get_transfer_start_hour(handles);
    start_minute = get_transfer_start_minute(handles);
    end_hour = get_transfer_end_hour(handles);
    end_minute = get_transfer_end_minute(handles);
    step = get_transfer_time_step(handles);
    euser = get_email_acc(handles);
    epass = get_email_pass(handles);
    rcpt = get_email_rcpt(handles);
    rpath = get_remote_path(handles);
    type = 'transfer';
    minInit = (start_hour*60) + start_minute;
    minEnd = (end_hour*60) + end_minute;
    xml = loadXML(handles.xmlfile, 'Configuration', 'station', station);
    
    %reboot connection to the database if necessary
    [handles.conn status] = renew_connection_db(handles.conn);
    
    if status == 1
        return
    end
        
    ok = true;
    if ok && isempty(host)
        warndlg('The transfer Data host is invalid!', 'Warning')
        ok = false;
    end
    if ok && isempty(user)
        warndlg('The transfer Username is invalid!', 'Warning')
        ok = false;
    end
    if ok && isempty(pass)
        warndlg('The transfer Password is invalid!', 'Warning')
        ok = false;
    end
    if ok && minInit > minEnd
        warndlg('Transfer initial time is greater than final time!', 'Warning')
        ok = false;
    end
    if ok && isnan(step)
        warndlg('The transfer Time step is invalid!', 'Warning')
        ok = false;
    end
    if ok && isempty(euser)
        warndlg('The transfer Email account is invalid!', 'Warning')
        ok = false;
    end
    if ok && isempty(epass)
        warndlg('The transfer Email password is invalid!', 'Warning')
        ok = false;
    end
    if ok && isempty(rcpt)
        warndlg('The transfer Email recipients list is invalid!', 'Warning')
        ok = false;
    end
    if ok && isempty(rpath)
        warndlg('The transfer Remote path is invalid!', 'Warning')
        ok = false;
    end
    
    if ok
        % Encrypt passwords
        pass = encrypt_aes(pass, handles.datapath);
        epass = encrypt_aes(epass, handles.datapath);
        
        xmlPath = strcat('Configuration[station=', station,...
            ']/CaptureConfig/Transfer');
        
        removeNode(xml, xmlPath);
        
        xmlPath = strcat(xmlPath, '[FTPHost=', host, ']');
        % Add the new transfer configuration
        transferElement = createNode(xml, xmlPath);
        
        createLeave(xml, transferElement, 'FTPUser', sprintf('%s', user))
        createLeave(xml, transferElement, 'FTPPass', sprintf('%s', pass))
        createLeave(xml, transferElement, 'StartHour', sprintf('%d', start_hour))
        createLeave(xml, transferElement, 'StartMinute', sprintf('%d', start_minute))
        createLeave(xml, transferElement, 'EndHour', sprintf('%d', end_hour))
        createLeave(xml, transferElement, 'EndMinute', sprintf('%d', end_minute))
        createLeave(xml, transferElement, 'TimeStep', sprintf('%d', step))
        createLeave(xml, transferElement, 'EmailUser', sprintf('%s', euser))
        createLeave(xml, transferElement, 'EmailPass', sprintf('%s', epass))
        createLeave(xml, transferElement, 'EmailRcpt', sprintf('%s', rcpt))
        createLeave(xml, transferElement, 'RootPath', sprintf('%s', rpath))
        %%% Save in database and then update
                
        idtransfer = load_idautomatic(handles.conn, station, type);
        idtransfer = cell2mat(idtransfer);
        if ~isempty(idtransfer)
            status = update_automatic_params(handles.conn, station, idtransfer, ...
                'type', type, 'start_hour', start_hour, 'start_minute', start_minute, ...
                'end_hour', end_hour, 'end_minute', end_minute, 'step', step);
        else
            idval = cell2mat(load_max_idautomatic(handles.conn, station));
            if isnan(idval)
                idtransfer = 1;
            else
                idtransfer = idval + 1;
            end
            status = insert_automatic_params(handles.conn, idtransfer, station, ...
                type, start_hour, start_minute, end_hour, end_minute, step);
        end
        
        if status == 0
            xmlsave(handles.xmlfile, xml);
            warndlg('The capture transfer configuration has been saved!', 'Success')
            set(handles.buttonBuildTransferAuto, 'Enable', 'on');
        else
            warndlg('The capture transfer configuration has not been saved!', 'Failure')
        end
    end
    
    savedStack = true;
    savedImage = false;
    
    %%%% SAVE STACK CONFIGURATION
    
    type = 'stack';
        
    for i = 1:numel(handles.stackQueue)
        id = handles.stackQueue(i).id;
        start_hour = handles.stackQueue(i).start_hour;
        start_minute = handles.stackQueue(i).start_minute;
        end_hour = handles.stackQueue(i).end_hour;
        end_minute = handles.stackQueue(i).end_minute;
        time_step = handles.stackQueue(i).time_step;
        num_frames = handles.stackQueue(i).num_frames;
        roi_x = handles.stackQueue(i).roi_x;
        roi_y = handles.stackQueue(i).roi_y;
        cam = handles.stackQueue(i).cam;
        
        xml = loadXML(handles.xmlfile, 'Configuration', 'station', station);
        xmlPath = strcat('Configuration[station=', station, ...
        ']/CaptureConfig/Capture[type=', type, ',id=', num2str(abs(id)), ']');
    
        removeNode(xml, xmlPath);
        
        xmlPath = strcat('Configuration[station=', station, ...
        ']/CameraPerCaptureConfig/CameraPerCapture[capture=', num2str(abs(id)), ']');
    
        removeNode(xml, xmlPath);
        
        if id < 0 % Delete this capture
            id = -id;
                    
            %reboot connection to the database if necessary
            [handles.conn status] = renew_connection_db(handles.conn);

            if status == 1
                return
            end

            data = load_automatic_params(handles.conn, station, id);

            if ~isempty(data)
                status = delete_automatic_params(handles.conn, id, station);
                if status == 0
                    warndlg('The stack capture configuration has been deleted!', 'Success')
                else
                    warndlg('The stack capture configuration has not been deleted!', 'Failure')
                end
            end
            xmlsave(handles.xmlfile, xml);
        else
            % Add the new capture configuration
            xmlPath = strcat('Configuration[station=', station, ...
                ']/CaptureConfig/Capture[type=', type, ',id=', num2str(id), ']');
            captureElement = createNode(xml, xmlPath);

            createLeave(xml, captureElement, 'StartHour', sprintf('%d', start_hour))
            createLeave(xml, captureElement, 'StartMinute', sprintf('%d', start_minute))
            createLeave(xml, captureElement, 'EndHour', sprintf('%d', end_hour))
            createLeave(xml, captureElement, 'EndMinute', sprintf('%d', end_minute))
            createLeave(xml, captureElement, 'TimeStep', sprintf('%d', time_step))
            createLeave(xml, captureElement, 'NumberOfFrames', sprintf('%d', num_frames))

            xmlPath = strcat('Configuration[station=', station, ...
                ']/CaptureConfig/Capture[type=', type, ',id=', num2str(id), ']/ROI');
            roiElement = createNode(xml, xmlPath);

            xcoords = '';
            ycoords = '';
            first = true;

            for j = 1:numel(roi_x)
                if first
                    first = false;
                else
                    xcoords = [xcoords, ' '];
                    ycoords = [ycoords, ' '];
                end
                xcoords = [xcoords, num2str(roi_x(j))];
                ycoords = [ycoords, num2str(roi_y(j))];
            end


            createLeave(xml, roiElement, 'XCoords', xcoords)
            createLeave(xml, roiElement, 'YCoords', ycoords)

            xmlPath = strcat('Configuration[station=', station, ']/CameraPerCaptureConfig/CameraPerCapture[camera=', cam, ',capture=', num2str(id), ']');

            tmpNode = getNodes(xml, xmlPath);

            if isempty(tmpNode)
                createNode(xml, xmlPath);
            end


            %%% Save in database and then update timestack

            data = load_automatic_params(handles.conn, station, id);

            xmlPath = strcat('Configuration[station=', station,...
                ']/CameraConfig/Camera[id=', cam, ']');
            CameraNode = getNodes(xml, xmlPath);
            camera = CameraNode{1};
            fr = getNodeVal(camera, 'FrameRate');
            fr = eval(fr);
            
            if ~isempty(data)
                status = update_automatic_params(handles.conn, station, id, ...
                    'type', type, 'start_hour', start_hour, 'start_minute', start_minute, ...
                    'end_hour', end_hour, 'end_minute', end_minute, 'step', time_step, ...
                    'duration', num_frames / fr);
            else
                status = insert_automatic_params(handles.conn, id, station, ...
                    type, start_hour, start_minute, end_hour, end_minute, time_step, ...
                    'duration', num_frames / fr);
            end

            if status == 0
                xmlsave(handles.xmlfile, xml);
            else
                savedStack = false;
            end
        end
    end
    if savedStack
        warndlg('The stack capture configurations have been saved!', 'Success')
    else
        warndlg('The stack capture configurations have not been saved!', 'Failure')
    end
    
    %%%% SAVE IMAGE CONFIGURATION
    
    type = 'image';
    
    idcapture = -1;
    xmlPath1 = strcat('Configuration[station=', station, ']/CaptureConfig/Capture[type=', type, ']');
    existingChild = getNodes(xml, xmlPath1);
    
    if ~isempty(existingChild)
        existingChild = existingChild{1};
        idcapture = str2double(getAttributeValue(existingChild, 'id'));
    end
    
    if idcapture == -1
        idval = cell2mat(load_max_idautomatic(handles.conn, station));
        if isnan(idval)
            idcapture = 1;
        else
            idcapture = idval + 1;
        end
    end
    
    start_hour = get_image_start_hour(handles);
    start_minute = get_image_start_minute(handles);
    end_hour = get_image_end_hour(handles);
    end_minute = get_image_end_minute(handles);
    step = get_image_time_step(handles);
    time = get_image_time(handles);
    
    minInit = (start_hour*60) + start_minute;
    minEnd = (end_hour*60) + end_minute;
    contents = get(handles.listboxImageType, 'String');
    
    ok = true;
    if ok && minInit > minEnd
        warndlg('The image capture initial time is greater than final time!', 'Warning')
        ok = false;
    end
    if ok && isnan(step)
        warndlg('The image capture time step is invalid!', 'Warning')
        ok = false;
    end
    if ok && isnan(time)
        warndlg('The image capture time is invalid!', 'Warning')
        ok = false;
    end
    if ok && isempty(contents)
        warndlg('Please select at least one image capture type!', 'Warning')
        ok = false;
    end
    if ok && ~check_overlapping(handles, idcapture, start_hour, start_minute, ...
                end_hour, end_minute, step, time)
        warndlg('Two or more capture configurations overlap!', 'Warning');
        ok = false;
    end
    
    if ok
        removeNode(xml, xmlPath1);
        % Add the new capture configuration
        xmlPath = strcat('Configuration[station=', station, ...
            ']/CaptureConfig/Capture[type=', type, ',id=', num2str(idcapture), ']');
        captureElement = createNode(xml, xmlPath);

        createLeave(xml, captureElement, 'StartHour', sprintf('%d', start_hour))
        createLeave(xml, captureElement, 'StartMinute', sprintf('%d', start_minute))
        createLeave(xml, captureElement, 'EndHour', sprintf('%d', end_hour))
        createLeave(xml, captureElement, 'EndMinute', sprintf('%d', end_minute))
        createLeave(xml, captureElement, 'TimeStep', sprintf('%d', step))
        createLeave(xml, captureElement, 'CaptureTime', sprintf('%d', time))

        types = load_imagetype_name(handles.conn, station);
        isfalse = true;
        num_types = 0;
        for i = 1:numel(types)
            for j = 1:numel(contents)
                if strcmpi(char(contents(j)),char(types(i)))
                    createLeave(xml, captureElement, char(types(i)), sprintf('%s', 'true'))
                    isfalse = false;
                    num_types = num_types + 1;
                    break;
                end
            end

            if isfalse
                createLeave(xml, captureElement, char(types(i)), sprintf('%s', 'false'))
            end
            isfalse = true;
        end

        xmlPath = strcat('Configuration[station=', station, ']/CameraConfig/Camera');

        camNodes = getNodes(xml, xmlPath);

        for i = 1:numel(camNodes)
            cam = getAttributeValue(camNodes{i}, 'id');
            xmlPath = strcat('Configuration[station=', station, ']/CameraPerCaptureConfig/CameraPerCapture[camera=', cam, ',capture=', num2str(idcapture), ']');

            tmpNode = getNodes(xml, xmlPath);

            if isempty(tmpNode)
                createNode(xml, xmlPath);
            end
        end

        %%% Save in database and then update
        data = load_automatic_params(handles.conn, station, idcapture);
        cameras = numel(camNodes);
        if ~isempty(data)
            status = update_automatic_params(handles.conn, station, idcapture, ...
                'type', type, 'start_hour', start_hour, 'start_minute', start_minute, ...
                'end_hour', end_hour, 'end_minute', end_minute, 'step', step, ...
                'duration', time, 'num_images', num_types*cameras);
        else
            status = insert_automatic_params(handles.conn, idcapture, station, ...
                type, start_hour, start_minute, end_hour, end_minute, step, ...
                'duration', time, 'num_images', num_types*cameras);
        end

        if status == 0
            xmlsave(handles.xmlfile, xml);
            warndlg('The image capture configuration has been saved!', 'Success')
            savedImage = true;
        else
            warndlg('The image capture configuration has not been saved!', 'Failure')
        end
    end
    
    if savedStack || savedImage
        set(handles.buttonBuildCaptureAuto, 'Enable', 'on');
    end
    
    % Update handles structure
    guidata(hObject, handles);
catch e
    disp(e.message)
end


% --- Executes on button press in buttonBuildCaptureAuto.
function buttonBuildCaptureAuto_Callback(hObject, eventdata, handles)
% hObject handle to buttonBuildCaptureAuto (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)

if check_station(handles)
    station = get_station(handles);
    if ispc
        h = gui_message('Generating capture automatic might take several minutes...','Loading...');
        create_auto_exec('capture', station)
        if ishandle(h)
            delete(h);
        end

    else
        mcrroot = uigetdir('.');
        if mcrroot
            h = gui_message('Generating capture automatic might take several minutes...','Loading...');
            create_auto_exec('capture', station, mcrroot);
            if ishandle(h)
                delete(h);
            end
        end
    end
end

% --- Executes on button press in buttonBuildTransferAuto.
function buttonBuildTransferAuto_Callback(hObject, eventdata, handles)
% hObject handle to buttonBuildTransferAuto (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)

if check_station(handles)
    station = get_station(handles);
    host = get_ftp_host(handles);
    if ~isempty(host)
        if ispc
            h = gui_message('Generating transfer automatic might take several minutes...','Loading...');
            create_auto_exec('transfer', station, host);
            if ishandle(h)
                delete(h);
            end
        else
            mcrroot = uigetdir('.');
            if mcrroot
                h = gui_message('Generating transfer automatic might take several minutes...','Loading...');
                create_auto_exec('transfer', station, host, mcrroot);
                if ishandle(h)
                    delete(h);
                end
            end
        end
    end
end

% --- Executes on button press in buttonDeleteStack.
function buttonDeleteStack_Callback(hObject, eventdata, handles)
% hObject handle to buttonDeleteStack (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)

try
    if check_station(handles)
% station = get_station(handles);
% xml = loadXML(handles.xmlfile, 'Configuration', 'station', station);
% type = 'stack';
        
        captureval = get(handles.popupCaptureID, 'Value');
        
        if captureval > 2
            options.Interpreter = 'tex';
            % Include the desired Default answer
            options.Default = 'No';
            % Create a TeX string for the question
            qstring = 'Do you really want to delete this stack configuration?';
            choice = questdlg(qstring,'Delete stack configuration',...
                'Yes','No', 'Cancel',options);
            
            if strcmpi(choice, 'No') || strcmpi(choice, 'Cancel')
                return;
            end
            
            idcapture = get_stack_capture(handles);
% xmlPath = strcat('Configuration[station=', station,...
% ']/CaptureConfig/Capture[type=', type, ',id=', num2str(idcapture), ']');
% existingChild = removeNode(xml, xmlPath);
%
% if ~isempty(existingChild)
% idcapture = str2double(getAttributeValue(existingChild, 'id'));
% end
%
% xmlPath = strcat('Configuration[station=', station,...
% ']/CameraPerCaptureConfig/CameraPerCapture[capture=', num2str(idcapture), ']');
% removeNode(xml, xmlPath);
%
% %reboot connection to the database if necessary
% [handles.conn status] = renew_connection_db(handles.conn);
%
% if status == 1
% return
% end
%
% data = load_automatic_params(handles.conn, station, idcapture);
%
% if ~isempty(data)
% status = delete_automatic_params(handles.conn, idcapture, station);
% if status == 0
%
% xmlPath = strcat('Configuration[station=', station,...
% ']/CaptureConfig/Capture[type=stack]');
% captureStackNodes = getNodes(xml, xmlPath);
% if ~isempty(captureStackNodes)
% set(handles.popupCaptureID, 'Value', 1)
% end
%
% xmlsave(handles.xmlfile, xml);

                    for i = 1:numel(handles.stackQueue)
                        if idcapture == handles.stackQueue(i).id
                            handles.stackQueue(i).id = -idcapture;
                            break;
                        end
                    end

                    handles = reload_stack_ids(handles);
% warndlg('The stack capture configuration has been deleted!', 'Success')
% else
% warndlg('The stack capture configuration has not been deleted!', 'Failure')
% end
% end
        end
        % Update handles structure
        guidata(hObject, handles);
    end
catch e
    disp(e.message)
end


% --- Executes on button press in buttonRemotePath.
function buttonRemotePath_Callback(hObject, eventdata, handles)
% hObject handle to buttonRemotePath (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)

try
    rpath = uigetdir('.');
    
    if rpath
        set(handles.editRemotePath, 'String', rpath)
    end
    
    % Update handles structure
    guidata(hObject, handles);
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
% Returns the selected start hour
function startHour = get_image_start_hour(handles)
try
    value = get(handles.popupImageStartHour, 'Value');
    contents = cellstr(get(handles.popupImageStartHour, 'String'));
    startHour = str2double(contents{value});
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected end hour
function endHour = get_image_end_hour(handles)
try
    value = get(handles.popupImageEndHour, 'Value');
    contents = cellstr(get(handles.popupImageEndHour, 'String'));
    endHour = str2double(contents{value});
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected start minute
function startMinute = get_image_start_minute(handles)
try
    value = get(handles.popupImageStartMinute, 'Value');
    contents = cellstr(get(handles.popupImageStartMinute, 'String'));
    startMinute = str2double(contents{value});
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected end minute
function endMinute = get_image_end_minute(handles)
try
    value = get(handles.popupImageEndMinute, 'Value');
    contents = cellstr(get(handles.popupImageEndMinute, 'String'));
    endMinute = str2double(contents{value});
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected image search time step
function step = get_image_time_step(handles)
try
    step = str2double(get(handles.editImageTimeStep, 'String'));
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected start hour
function startHour = get_stack_start_hour(handles)
try
    value = get(handles.popupStackStartHour, 'Value');
    contents = cellstr(get(handles.popupStackStartHour, 'String'));
    startHour = str2double(contents{value});
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected end hour
function endHour = get_stack_end_hour(handles)
try
    value = get(handles.popupStackEndHour, 'Value');
    contents = cellstr(get(handles.popupStackEndHour, 'String'));
    endHour = str2double(contents{value});
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected start minute
function startMinute = get_stack_start_minute(handles)
try
    value = get(handles.popupStackStartMinute, 'Value');
    contents = cellstr(get(handles.popupStackStartMinute, 'String'));
    startMinute = str2double(contents{value});
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected end minute
function endMinute = get_stack_end_minute(handles)
try
    value = get(handles.popupStackEndMinute, 'Value');
    contents = cellstr(get(handles.popupStackEndMinute, 'String'));
    endMinute = str2double(contents{value});
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected image search time step
function step = get_stack_time_step(handles)
try
    step = str2double(get(handles.editStackTimeStep, 'String'));
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected image search time step
function step = get_image_time(handles)
try
    step = str2double(get(handles.editTime, 'String'));
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected image search time step
function step = get_stack_numframes(handles)
try
    step = str2double(get(handles.editStackFrames, 'String'));
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected end minute
function cam = get_stack_camera(handles)
try
    value = get(handles.popupCamera, 'Value');
    contents = cellstr(get(handles.popupCamera, 'String'));
    cam = contents{value};
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected end minute
function endMinute = get_stack_capture(handles)
try
    value = get(handles.popupCaptureID, 'Value');
    contents = cellstr(get(handles.popupCaptureID, 'String'));
    endMinute = str2double(contents{value});
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected end minute
function value = get_ftp_host(handles)
try
    value = get(handles.editFTPHost, 'String');
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected end minute
function value = get_ftp_user(handles)
try
    value = get(handles.editFTPUser, 'String');
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected end minute
function value = get_ftp_pass(handles)
try
    value = get(handles.editFTPPass, 'String');
catch e
    disp(e.message)
end
%--------------------------------------------------------------------------
% Returns the selected end minute
function startHour = get_transfer_start_hour(handles)
try
    value = get(handles.popupTransferStartHour, 'Value');
    contents = cellstr(get(handles.popupTransferStartHour, 'String'));
    startHour = str2double(contents{value});
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected end minute
function startMinute = get_transfer_start_minute(handles)
try
    value = get(handles.popupTransferStartMinute, 'Value');
    contents = cellstr(get(handles.popupTransferStartMinute, 'String'));
    startMinute = str2double(contents{value});
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected end minute
function endHour = get_transfer_end_hour(handles)
try
    value = get(handles.popupTransferEndHour, 'Value');
    contents = cellstr(get(handles.popupTransferEndHour, 'String'));
    endHour = str2double(contents{value});
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected end minute
function endMinute = get_transfer_end_minute(handles)
try
    value = get(handles.popupTransferEndMinute, 'Value');
    contents = cellstr(get(handles.popupTransferEndMinute, 'String'));
    endMinute = str2double(contents{value});
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected end minute
function value = get_transfer_time_step(handles)
try
    value = str2double(get(handles.editTransferTimeStep, 'String'));
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected end minute
function value = get_email_acc(handles)
try
    value = get(handles.editEmailAcc, 'String');
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected end minute
function value = get_email_pass(handles)
try
    value = get(handles.editEmailPass, 'String');
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected end minute
function value = get_email_rcpt(handles)
try
    value = get(handles.editEmailRecpt, 'String');
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected root path
function value = get_remote_path(handles)
try
    value = get(handles.editRemotePath, 'String');
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
% Reload all cameras from the database
function [handles numcam]= reload_camera(handles)

try
    numcam = 0;
    if check_station(handles)
        station = get_station(handles);
        
        xml = loadXML(handles.xmlfile, 'Configuration', 'station', station);
        xmlPath = strcat('Configuration[station=', station, ']/CameraConfig/Camera');
        
        camNodes = getNodes(xml, xmlPath);
        
        if isempty(camNodes)
            warndlg('No cameras were found!', 'Warning');
            return
        end
        numcam = numel(camNodes);
        cameras = cell(numel(camNodes), 1);
        for i = 1:numcam
            cam = getAttributeValue(camNodes{i}, 'id');
            cameras{i} = cam;
        end
        
        set(handles.popupCamera, 'String', cameras);
    end
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Reload stack ids
function handles = reload_stack_ids(handles)

station = get_station(handles);

if isempty(handles.stackQueue)
    xml = loadXML(handles.xmlfile, 'Configuration', 'station', station);
    xmlPath = strcat('Configuration[station=', station,...
                    ']/CaptureConfig/Capture[type=stack]');

    captureStackNodes = getNodes(xml, xmlPath);
    
    for i = 1:numel(captureStackNodes)
        captureStack = captureStackNodes{i};
        
        id = str2double(getAttributeValue(captureStack, 'id'));
        start_hour = str2double(getNodeVal(captureStack, 'StartHour'));
        start_minute = str2double(getNodeVal(captureStack, 'StartMinute'));
        end_hour = str2double(getNodeVal(captureStack, 'EndHour'));
        end_minute = str2double(getNodeVal(captureStack, 'EndMinute'));
        time_step = str2double(getNodeVal(captureStack, 'TimeStep'));
        num_frames = str2double(getNodeVal(captureStack, 'NumberOfFrames'));
        
        xmlPath = strcat('Configuration[station=', station, ...
            ']/CaptureConfig/Capture[type=stack,id=', num2str(id), ']/ROI');
        roiNode = getNodes(xml, xmlPath);
        
        roi_x = [];
        roi_y = [];
        if ~isempty(roiNode)
            roiNode = roiNode{1};
            xcoords = getNodeVal(roiNode, 'XCoords');
            ycoords = getNodeVal(roiNode, 'YCoords');
            
            xparts = regexp(xcoords, '[ \t]+', 'split');
            yparts = regexp(ycoords, '[ \t]+', 'split');
            
            if numel(xparts) == numel(yparts) && numel(xparts) > 3
                roi_x = [];
                roi_y = [];
                for j = 1:numel(xparts)
                    roi_x(j) = str2double(xparts(j));
                    roi_y(j) = str2double(yparts(j));
                end
            end
        end
        
        xmlPath = strcat('Configuration[station=', station, ...
            ']/CameraPerCaptureConfig/CameraPerCapture[capture=', num2str(id), ']');
        camNodes = getNodes(xml, xmlPath);
        
        cam = [];
        if ~isempty(camNodes)
            camNode = camNodes{1};
            cam = getAttributeValue(camNode, 'camera');
        end
        
        handles.stackQueue(i).id = id;
        handles.stackQueue(i).start_hour = start_hour;
        handles.stackQueue(i).start_minute = start_minute;
        handles.stackQueue(i).end_hour = end_hour;
        handles.stackQueue(i).end_minute = end_minute;
        handles.stackQueue(i).time_step = time_step;
        handles.stackQueue(i).num_frames = num_frames;
        handles.stackQueue(i).roi_x = roi_x;
        handles.stackQueue(i).roi_y = roi_y;
        handles.stackQueue(i).cam = cam;
    end
end

strStackCapture = {'Select an option', 'New capture'};

for i = 1:numel(handles.stackQueue)
    if handles.stackQueue(i).id >= 0
        strStackCapture{end + 1} = num2str(handles.stackQueue(i).id);
    end
end
set(handles.popupCaptureID, 'Value', 1, 'String', strStackCapture);
set(handles.buttonDeleteStack, 'Enable', 'off');
set(handles.buttonEnqueueStack, 'Enable', 'off');
set(handles.buttonROI, 'Enable', 'off');
set(handles.popupStackStartHour, 'Value', 1);
set(handles.popupStackStartMinute, 'Value', 1);
set(handles.popupStackEndHour, 'Value', 1);
set(handles.popupStackEndMinute, 'Value', 1);
set(handles.editStackTimeStep, 'String', '');
set(handles.editStackFrames, 'String', '');


% --- Executes on button press in buttonAddImageType.
function buttonAddImageType_Callback(hObject, eventdata, handles)
% hObject handle to buttonAddImageType (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)

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
        end
        
        found = false;
        if numel(contents) > 1
            set(handles.editTime, 'Enable', 'on')
        else
            for i = 1:numel(contents)
                if strcmp('Snap', contents{i})
                    found = true;
                    break;
                end
            end
            if ~found && numel(contents) == 1
                set(handles.editTime, 'Enable', 'on')
            else
                set(handles.editTime, 'Enable', 'inactive')
                set(handles.editTime, 'String', '0')
            end
        end
        
    end
catch e
    disp(e.message)
end

% --- Executes on button press in buttonRemoveImageType.
function buttonRemoveImageType_Callback(hObject, eventdata, handles)
% hObject handle to buttonRemoveImageType (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)

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
        
        found = false;
        if numel(new) > 1
            set(handles.editTime, 'Enable', 'on')
        else
            for i = 1:numel(new)
                if strcmpi('Snap', new{i})
                    found = true;
                    break;
                end
            end
            if ~found && numel(new) == 1
                set(handles.editTime, 'Enable', 'on')
            else
                set(handles.editTime, 'Enable', 'inactive')
                set(handles.editTime, 'String', '0')
            end
        end
        
    end
catch e
    disp(e.message)
end

% --- Executes on button press in buttonEnqueueStack.
function buttonEnqueueStack_Callback(hObject, eventdata, handles)
% hObject handle to buttonEnqueueStack (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)

try
    station = get_station(handles);
    cam = get_stack_camera(handles);
    
    idcapture = -1;
    
    captureval = get(handles.popupCaptureID, 'Value');
    
    if captureval > 1 % Do nothing if captureval == 1
        if captureval > 2
            idcapture = get_stack_capture(handles);
        end
        
        if idcapture == -1
            idval = cell2mat(load_max_idautomatic(handles.conn, station));
            if isnan(idval)
                idcapture = 1;
            else
                idcapture = idval + 1;
            end
        end
        
        start_hour = get_stack_start_hour(handles);
        start_minute = get_stack_start_minute(handles);
        end_hour = get_stack_end_hour(handles);
        end_minute = get_stack_end_minute(handles);
        step = get_stack_time_step(handles);
        numframes = get_stack_numframes(handles);
        
        minInit = (start_hour*60) + start_minute;
        minEnd = (end_hour*60) + end_minute;
        
        ok = true;
        if ok && minInit > minEnd
            warndlg('The stack initial time is greater than final time!', 'Warning')
            ok = false;
        end
        if ok && isnan(step)
            warndlg('The stack time step is invalid!', 'Warning')
            ok = false;
        end
        if ok && isnan(numframes)
            warndlg('The stack number of frames is invalid!', 'Warning')
            ok = false;
        end
        
        % If there is no selected ROI, choose the entire image by default.
        if isempty(handles.curroi.xcoords)
            im = captureImage(handles);
            if isempty(im)
                errordlg('This camera is not configured yet!', 'Error');
                ok = false;
            end
            
            if ok
                [m, n, o] = size(im);
                handles.curroi.xcoords(1) = 1;
                handles.curroi.ycoords(1) = 1;
                handles.curroi.xcoords(2) = 1;
                handles.curroi.ycoords(2) = m;
                handles.curroi.xcoords(3) = n;
                handles.curroi.ycoords(3) = m;
                handles.curroi.xcoords(4) = n;
                handles.curroi.ycoords(4) = 1;
            end
        else
            if ok && isempty(handles.curroi.xcoords) || isempty(handles.curroi.ycoords) ||...
                    length(handles.curroi.xcoords) ~= length(handles.curroi.ycoords) ||...
                    length(handles.curroi.xcoords) < 3 || length(handles.curroi.ycoords) < 3
                warndlg('The stack ROI is invalid!', 'Warning')
                ok = false;
            end
        end
        
        xml = loadXML(handles.xmlfile, 'Configuration', 'station', station);
        xmlPath = strcat('Configuration[station=', station,...
            ']/CameraConfig/Camera[id=', cam, ']');
        CameraNode = getNodes(xml, xmlPath);
        camera = CameraNode{1};
        fr = getNodeVal(camera, 'FrameRate');
        fr = eval(fr);
        if ok && ~check_overlapping(handles, idcapture, start_hour, start_minute, ...
                end_hour, end_minute, step, numframes / fr)
            warndlg('Two or more capture configurations overlap!', 'Warning');
            ok = false;
        end
        
        if ok
            % Add the new capture configuration
            pos = NaN;
            for i = 1:numel(handles.stackQueue)
                if handles.stackQueue(i).id == idcapture
                    pos = i;
                    break;
                end
            end
            
            if isnan(pos)
                n = numel(handles.stackQueue);
                pos = n + 1;
            end
            
            handles.stackQueue(pos).id = idcapture;
            handles.stackQueue(pos).start_hour = start_hour;
            handles.stackQueue(pos).start_minute = start_minute;
            handles.stackQueue(pos).end_hour = end_hour;
            handles.stackQueue(pos).end_minute = end_minute;
            handles.stackQueue(pos).time_step = step;
            handles.stackQueue(pos).num_frames = numframes;
            handles.stackQueue(pos).roi_x = handles.curroi.xcoords;
            handles.stackQueue(pos).roi_y = handles.curroi.ycoords;
            handles.stackQueue(pos).cam = cam;
            
            handles = reload_stack_ids(handles);
            
            warndlg('The stack capture configuration has been saved in memory!', 'Success')
        end
    end
    % Update handles structure
    guidata(hObject, handles);
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

%--------------------------------------------------------------------------
% Check if a capture configuration overlaps with other capture from XML
% file.
function ok = check_overlapping(handles, id, start_hour, start_minute, ...
    end_hour, end_minute, step, duration)

ok = true;
station = get_station(handles);

start_time = (start_hour * 60 + start_minute) * 60;
end_time = (end_hour * 60 + end_minute) * 60;

start_ind = start_time:step * 60:end_time;
end_ind = start_ind + duration;

xml = loadXML(handles.xmlfile, 'Configuration', 'station', station);

xmlPath = strcat('Configuration[station=', station,...
                ']/CaptureConfig/Capture[type=image]');

imageNodes = getNodes(xml, xmlPath);
for i = 1:numel(imageNodes)
    node = imageNodes{i};
    idnode = str2double(getAttributeValue(node, 'id'));
    if idnode == id
        continue;
    end
    
    sh = str2double(getNodeVal(node, 'StartHour'));
    sm = str2double(getNodeVal(node, 'StartMinute'));
    eh = str2double(getNodeVal(node, 'EndHour'));
    em = str2double(getNodeVal(node, 'EndMinute'));
    s = str2double(getNodeVal(node, 'TimeStep'));
    d = str2double(getNodeVal(node, 'CaptureTime'));
    
    if isnan(idnode) || isnan(sh) || isnan(sm) || isnan(eh) || ...
            isnan(em) || isnan(s) || isnan(d)
        continue;
    end
    
    stime = (sh * 60 + sm) * 60;
    etime = (eh * 60 + em) * 60;

    sind = stime:s * 60:etime;
    eind = sind + d;
    
    for j = 1:length(start_ind)
        for k = 1:length(sind)
            if start_ind(j) < eind(k) && sind(k) < end_ind(j)
                ok = false;
                return;
            end
        end
    end
end

xmlPath = strcat('Configuration[station=', station, ']/CaptureConfig/Capture[type=stack]');
stackNodes = getNodes(xml, xmlPath);
for i = 1:numel(stackNodes)
    node = stackNodes{i};
    idnode = str2double(getAttributeValue(node, 'id'));
    if idnode == id
        continue;
    end
    
    sh = str2double(getNodeVal(node, 'StartHour'));
    sm = str2double(getNodeVal(node, 'StartMinute'));
    eh = str2double(getNodeVal(node, 'EndHour'));
    em = str2double(getNodeVal(node, 'EndMinute'));
    s = str2double(getNodeVal(node, 'TimeStep'));
    
    if isnan(idnode) || isnan(sh) || isnan(sm) || isnan(eh) || ...
            isnan(em) || isnan(s)
        continue;
    end
    
    nframes = str2double(getNodeVal(node, 'NumberOfFrames'));
    
    xmlPath2 = strcat('Configuration[station=', station, ']/CameraPerCaptureConfig/',...
        'CameraPerCapture[capture=', num2str(idnode), ']');
    
    camCaptureNode = getNodes(xml, xmlPath2);
    if isempty(camCaptureNode)
        continue;
    end
    camCaptureNode = camCaptureNode{1};
    cam = getAttributeValue(camCaptureNode, 'camera');
    
    xmlPath2 = strcat('Configuration[station=', station,...
        ']/CameraConfig/Camera[id=', cam, ']');
    camNode = getNodes(xml, xmlPath2);
    if isempty(camNode)
        continue;
    end
    camera = camNode{1};
    fr = getNodeVal(camera, 'FrameRate');
    fr = eval(fr);
    
    d = nframes / fr;
    
    if isnan(d)
        continue;
    end
    
    stime = (sh * 60 + sm) * 60;
    etime = (eh * 60 + em) * 60;

    sind = stime:s * 60:etime;
    eind = sind + d;
    
    for j = 1:length(start_ind)
        for k = 1:length(sind)
            if start_ind(j) < eind(k) && sind(k) < end_ind(j)
                ok = false;
                return;
            end
        end
    end
end

% --- Executes on button press in show_time.
function show_time_Callback(hObject, eventdata, handles)
% hObject handle to show_time (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)
try
    if check_station(handles)
        station = get_station(handles);
        process_times(station)
    end
catch e
    disp(e.message)
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject handle to figure1 (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)
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