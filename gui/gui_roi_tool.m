function varargout = gui_roi_tool(varargin)
% GUI_ROI_TOOL M-file for gui_roi_tool.fig
%      GUI_ROI_TOOL, by itself, creates a new GUI_ROI_TOOL or raises the existing
%      singleton*.
%
%      H = GUI_ROI_TOOL returns the handle to a new GUI_ROI_TOOL or the handle to
%      the existing singleton*.
%
%      GUI_ROI_TOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_ROI_TOOL.M with the given input arguments.
%
%      GUI_ROI_TOOL('Property','Value',...) creates a new GUI_ROI_TOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_roi_tool_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_roi_tool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_roi_tool

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
% Last Modified by GUIDE v2.5 12-Oct-2012 17:21:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @gui_roi_tool_OpeningFcn, ...
    'gui_OutputFcn',  @gui_roi_tool_OutputFcn, ...
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


% --- Executes just before gui_roi_tool is made visible.
function gui_roi_tool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_roi_tool (see VARARGIN)

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
    
    % Show the axesLogo
    logo=imread('LogoHorusMin.png');
    imshow(logo, 'Parent', handles.axesLogo);
    
    % Initialize the variables
    handles.root = [];
    handles.motionActivated = false;
    handles.Uinsert=[];
    handles.Vinsert=[];
    handles.Uupdate=[];
    handles.Vupdate=[];
    handles.figure=[];
    handles.id_roi=[];
    % Calendar
    handles.datebox=[];
    handles.saved = true;
    handles.external_call=0;
    noptargs = numel(varargin);
    
    if noptargs == 7
        handles.external_call = 1;
        set(handles.StationSelect,'Enable','inactive');
        set(handles.cameraSelect,'Enable','inactive');
        set(handles.timestampCalSelect,'Enable','inactive');
        set(handles.TypeSelect,'Enable','inactive');
        set(handles.TimestampRoiSelect,'Enable','inactive');
        set(handles.loadImageButton,'Enable','inactive');
        set(handles.LoadImageSelect,'Enable','inactive');
        
        set(handles.StationSelect,'String',{varargin{1}});
        set(handles.cameraSelect,'String',{varargin{2}});
        timestampCal = datestr(varargin{3});
        set(handles.timestampCalSelect,'String',timestampCal);
        set(handles.TypeSelect,'String',{varargin{4}});
        timestampRoi = datestr(varargin{5});
        set(handles.TimestampRoiSelect,'String',timestampRoi);
        set(handles.updateRoiButton,'Visible','off')
        set(handles.deleteRoiButton,'Visible','off')
        set(handles.insertRoiButton,'Visible','off')
        set(handles.loadImageButton,'Visible','off')
        imgname=varargin{6};
        imglocation = varargin{7};
        % Load path
        if ~exist('path_info.xml', 'file')
            errordlg('The file path_info.xml does not exist!', 'Error');
            root=[];
        else
            [pathOblique] = load_paths('path_info.xml', varargin{1});
            root = strtrim(pathOblique);
        end
        % If not found the image in physical disk
        if filesep == '/' | strfind(root,'http://')
            changeFrom = '\';
            changeTo = '/';
        else
            changeFrom = '/';
            changeTo = '\';
        end
        
        fullpath = strrep(fullfile(root, imglocation, imgname), changeFrom, changeTo);
        
        if strfind(root, 'http://')
            
            h=gui_message(['The image is loading from an external server, '...
                'it may take some minutes.'],'Message');
            try
                handles.figure = imread(fullpath);
                if ishandle(h)
                    delete(h);
                end
            catch e
                if ishandle(h)
                    delete(h);
                end
                warndlg('Can''t read URL','Warning');
                % Update handles structure
                guidata(hObject, handles);
                varargout = gui_roi_tool_OutputFcn(hObject, eventdata, handles);
                return;
            end
        else
            if ~exist(fullpath, 'file')
                warndlg('This image does not exist in the file disk','Warning');
                % Update handles structure
                guidata(hObject, handles);
                varargout = gui_roi_tool_OutputFcn(hObject, eventdata, handles);
                return;
            end
        end
        
        handles.figure = imread(fullpath);
        % Show the image
        imshow(handles.figure, 'Parent', handles.image);
        set(handles.imagePanel, 'Title', imgname);
        hold(handles.image, 'on')
        
        set(handles.zoomIn,'Enable','on')
        set(handles.zoomOut,'Enable','on')
        set(handles.pan,'Enable','on')
        set(handles.deletePoint,'Enable','on')
        set(handles.buttonPick,'Enable','on')
        % Type of action "Update" or "Insert"
        handles.action = 'Insert';
    else
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
            set(handles.StationSelect,'String',stations);
        end
        % Type of action "Update" or "Insert"
        handles.action = 'Update';
        
        set(handles.saveButton,'Visible','off')
        
    end
    % Choose default command line output for gui_roi_tool
    handles.output = hObject;
    
    % Update handles structure
    guidata(hObject, handles);
    
    % UIWAIT makes gui_roi_tool wait for user response (see UIRESUME)
    uiwait(handles.figure1);
catch e
    disp(e.message)
end

% --- Outputs from this function are returned to the command line.
function varargout = gui_roi_tool_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    % Get default command line output from handles structure
    if ~isempty(handles)
        if handles.external_call
            %%%OutputFCN
            
            if ~isempty(handles.Uinsert) && ~isempty(handles.Vinsert) && ...
                    size(handles.Uinsert,1) >= 3 && size(handles.Vinsert,1) >= 3
                UV(:,1)=handles.Uinsert;
                UV(:,2)=handles.Vinsert;
                varargout{1} = UV;
            else
                varargout{1} = [];
            end
        else
            varargout{1} = handles.output;
        end
        % The figure can be deleted now
        delete(handles.figure1);
    else
        varargout{1} = [];
    end
catch e
    disp(e.message)
end

% --- Executes on selection change in StationSelect.
function StationSelect_Callback(hObject, eventdata, handles)
% hObject    handle to StationSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns StationSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from StationSelect

try
    % Reset some part of the GUI
    if ~isempty(handles.datebox)
        handles.datebox.setVisible(false)
        set(handles.NewTimestampRoi,'visible','off')
        set(handles.TimestampNewRoi,'visible','off')
    end
    set(handles.cameraSelect,'Value',1)
    set(handles.cameraSelect,'String',{''})
    set(handles.timestampCalSelect,'Value',1)
    set(handles.timestampCalSelect,'String',{''})
    set(handles.TypeSelect,'Value',1)
    set(handles.TypeSelect,'String',{''})
    set(handles.pointsUText,'String','')
    set(handles.pointsVText,'String','')
    set(handles.LoadImageSelect,'Value',1)
    set(handles.LoadImageSelect,'String',{''})
    axes(handles.image);
    cla;
    handles.figure=[];
    set(handles.imagePanel, 'Title', '');
    set(handles.TimestampRoiSelect,'Value',1)
    set(handles.TimestampRoiSelect,'String',{''})
    set(handles.Roi, 'Title', 'ROI Update');
    handles.Uinsert=[];
    handles.Vinsert=[];
    handles.Uupdate=[];
    handles.Vupdate=[];
    set(handles.displayU,'String','');
    set(handles.displayV,'String','');
    handles.motionActivated = false;
    if get(handles.StationSelect,'value')>1
        
        station = get_station(handles);
        % Load path
        if ~exist('path_info.xml', 'file')
            errordlg('The file path_info.xml does not exist!', 'Error');
        else
            [pathOblique] = load_paths('path_info.xml', station);
            handles.root = strtrim(pathOblique);
        end
        
        %reboot connection to the database if necessary
        [handles.conn status] = renew_connection_db(handles.conn);

        if status == 1
            return
        end
        
        h=gui_message('Loading from database, this might take a while!',...
            'Loading');
        % Initialize cameras in popup menu
        cam=load_cam_calibration(handles.conn, station);
        if ishandle(h)
            delete(h);
        end
        
        cams = cell(0);
        cams{1, 1}= 'Select the camera';
        j=2;
        for k = 1:length(cam)
            cams{j, 1}=char(cam(k));
            j=j+1;
        end
        if (j == 2)
            warndlg({'No camera in the database','Be sure to enter the site before proceeding.'},'Warning');
        else
            set(handles.cameraSelect,'String',cams);
        end
    end
    
    
    check_data_roi(handles)
    % Update handles structure
    guidata(hObject, handles);
    
catch e
    disp(e.message)
end

% --- Executes on selection change in cameraSelect.
function cameraSelect_Callback(hObject, eventdata, handles)
% hObject    handle to cameraSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns cameraSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cameraSelect

try
    % Reset some part of the GUI
    if ~isempty(handles.datebox)
        handles.datebox.setVisible(false)
        set(handles.NewTimestampRoi,'visible','off')
        set(handles.TimestampNewRoi,'visible','off')
    end
    set(handles.timestampCalSelect,'Value',1)
    set(handles.timestampCalSelect,'String',{''})
    set(handles.TypeSelect,'Value',1)
    set(handles.TypeSelect,'String',{''})
    set(handles.pointsUText,'String','')
    set(handles.pointsVText,'String','')
    set(handles.LoadImageSelect,'Value',1)
    set(handles.LoadImageSelect,'String',{''})
    set(handles.Roi, 'Title', 'ROI Update');
    axes(handles.image);
    cla;
    handles.figure=[];
    set(handles.imagePanel, 'Title', '');
    set(handles.TimestampRoiSelect,'Value',1)
    set(handles.TimestampRoiSelect,'String',{''})
    handles.Uinsert=[];
    handles.Vinsert=[];
    handles.Uupdate=[];
    handles.Vupdate=[];
    set(handles.displayU,'String','');
    set(handles.displayV,'String','');
    handles.motionActivated = false;
    
    if get(handles.cameraSelect,'value')>1
        station = get_station(handles);
        cam = get_camera(handles);
        
        %reboot connection to the database if necessary
        [handles.conn status] = renew_connection_db(handles.conn);

        if status == 1
            return
        end
        
        h=gui_message('Loading from database, this might take a while!',...
            'Loading');
        % Initialize timestampnewroi calibration in popup menu
        timestamp_cal  = load_timestamp_calibration(handles.conn, station, cam);
        if ishandle(h)
            delete(h);
        end
        timestampsstr_cal = cell(0);
        timestampsstr_cal{1, 1}= 'Select the timestamp the calibration';
        j=2;
        for k = 1:length(timestamp_cal)
            timestampsstr_cal{j, 1}=datestr(cell2mat(timestamp_cal(k)));
            j=j+1;
        end
        if (j == 2)
            warndlg({'No camera in the database','Be sure to enter the site before proceeding.'},'Warning');
        else
            set(handles.timestampCalSelect,'String',timestampsstr_cal);
        end
    end
    
    check_data_roi(handles)
    % Update handles structure
    guidata(hObject, handles);
catch e
    disp(e.message)
end

% --- Executes on selection change in timestampCalSelect.
function timestampCalSelect_Callback(hObject, eventdata, handles)
% hObject    handle to timestampCalSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns timestampCalSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        timestampCalSelect

try
    % Reset some part of the GUI
    if ~isempty(handles.datebox)
        handles.datebox.setVisible(false)
        set(handles.NewTimestampRoi,'visible','off')
        set(handles.TimestampNewRoi,'visible','off')
    end
    set(handles.TypeSelect,'Value',1)
    set(handles.TypeSelect,'String',{''})
    set(handles.pointsUText,'String','')
    set(handles.pointsVText,'String','')
    set(handles.LoadImageSelect,'Value',1)
    set(handles.LoadImageSelect,'String',{''})
    set(handles.Roi, 'Title', 'ROI Update');
    axes(handles.image);
    cla;
    handles.figure=[];
    set(handles.imagePanel, 'Title', '');
    set(handles.TimestampRoiSelect,'Value',1)
    set(handles.TimestampRoiSelect,'String',{''})
    handles.Uinsert=[];
    handles.Vinsert=[];
    handles.Uupdate=[];
    handles.Vupdate=[];
    set(handles.displayU,'String','');
    set(handles.displayV,'String','');
    handles.motionActivated = false;
    
    if get(handles.timestampCalSelect,'value')>1
        % Initialize type of ROI in popup menu
        type = {'Select the type of ROI';'rect';'stack';'user'};
        set(handles.TypeSelect,'String',type);
        
    end
    check_data_roi(handles)
    % Update handles structure
    guidata(hObject, handles);
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
    % Reset some part of the GUI
    if ~isempty(handles.datebox)
        handles.datebox.setVisible(false)
        set(handles.NewTimestampRoi,'visible','off')
        set(handles.TimestampNewRoi,'visible','off')
    end
    set(handles.pointsUText,'String','')
    set(handles.pointsVText,'String','')
    set(handles.LoadImageSelect,'Value',1)
    set(handles.LoadImageSelect,'String',{''})
    set(handles.Roi, 'Title', 'ROI Update');
    axes(handles.image);
    cla;
    handles.figure=[];
    set(handles.imagePanel, 'Title', '');
    set(handles.TimestampRoiSelect,'Value',1)
    set(handles.TimestampRoiSelect,'String',{''})
    handles.Uinsert=[];
    handles.Vinsert=[];
    handles.Uupdate=[];
    handles.Vupdate=[];
    set(handles.displayU,'String','');
    set(handles.displayV,'String','');
    handles.motionActivated = false;
    
    if get(handles.TypeSelect,'value')>1
        station = get_station(handles);
        
        cam = get_camera(handles);
        timestampsnum_cal = get_timestampCal(handles);
        timestampsnum_cal=datenum(timestampsnum_cal);
        type = get_type(handles);
        
        %reboot connection to the database if necessary
        [handles.conn status] = renew_connection_db(handles.conn);

        if status == 1
            return
        end
        
        h=gui_message('Loading from database, this might take a while!',...
            'Loading');
        % Initialize timestampnewroi ROI in popup menu
        timestamp_roi  = load_timestamp_roi(handles.conn, station, cam, timestampsnum_cal, type);
        if ishandle(h)
            delete(h);
        end
        timestampsstr_roi = cell(0);
        timestampsstr_roi{1, 1}= 'Select the timestamp the ROI';
        timestampsstr_roi{2, 1} = 'New ROI';
        j=3;
        for k = 1:length(timestamp_roi)
            timestampsstr_roi{j, 1}=datestr(cell2mat(timestamp_roi(k)));
            j=j+1;
        end
        set(handles.TimestampRoiSelect,'String',timestampsstr_roi);
        
    end
    check_data_roi(handles)
    % Update handles structure
    guidata(hObject, handles);
catch e
    disp(e.message)
end

% --- Executes on selection change in TimestampRoiSelect.
function TimestampRoiSelect_Callback(hObject, eventdata, handles)
% hObject    handle to TimestampRoiSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TimestampRoiSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TimestampRoiSelect

try
    % Reset some part of the GUI
    if ~isempty(handles.datebox)
        handles.datebox.setVisible(false)
        set(handles.NewTimestampRoi,'visible','off')
        set(handles.TimestampNewRoi,'visible','off')
    end
    set(handles.pointsUText,'String','')
    set(handles.pointsVText,'String','')
    set(handles.LoadImageSelect,'Value',1)
    set(handles.LoadImageSelect,'String',{''})
    set(handles.insertRoiButton,'Visible','off')
    set(handles.Roi, 'Title', 'ROI Update');
    axes(handles.image);
    cla;
    handles.figure=[];
    set(handles.imagePanel, 'Title', '');
    handles.Uinsert=[];
    handles.Vinsert=[];
    handles.Uupdate=[];
    handles.Vupdate=[];
    set(handles.displayU,'String','');
    set(handles.displayV,'String','');
    handles.motionActivated = false;
    
    timestampsnum_roi = get_timestampRoi(handles);
    station = get_station(handles);
    if strcmp(timestampsnum_roi,'New ROI')
        % Enable the slider and load value
        set(handles.TimestampNewRoi,'visible','on')
        handles = reload_time(handles);
        set(handles.updateRoiButton,'Visible','off')
        set(handles.deleteRoiButton,'Visible','off')
        set(handles.insertRoiButton,'Visible','on')
        set(handles.insertRoiButton,'Enable','off')
        handles.action = 'Insert';
        dnum = get_timestamp_calendar(handles);
        set(handles.Roi, 'Title', 'ROI Insert');
        % Update handles structure
        guidata(hObject, handles);
        
    elseif get(handles.TimestampRoiSelect,'value')>1
        if ~isempty(handles.datebox)
            handles.datebox.setVisible(false)
            set(handles.NewTimestampRoi,'visible','off')
            set(handles.TimestampNewRoi,'visible','off')
        end
        type = get_type(handles);
        set(handles.insertRoiButton,'Visible','off')
        set(handles.updateRoiButton,'Visible','on')
        set(handles.updateRoiButton,'Enable','off')
        set(handles.deleteRoiButton,'Visible','on')
        set(handles.Roi, 'Title', 'ROI Update');
        handles.action = 'Update';
        
        cam = get_camera(handles);
        
        timestampsnum_cal = get_timestampCal(handles);
        timestampsnum_cal=datenum(timestampsnum_cal);
        
        %reboot connection to the database if necessary
        [handles.conn status] = renew_connection_db(handles.conn);

        if status == 1
            return
        end
        
        h=gui_message('Loading from database, this might take a while!',...
            'Loading');
        % Load ROI, value U and V
                
        data_roi  = load_roi(handles.conn, type, cam, station, timestampsnum_cal, datenum(timestampsnum_roi));
        if ishandle(h)
            delete(h);
        end
        
        if isempty(data_roi)
            warndlg('No ROI was found in the database!', 'Warning');
        else
            handles.id_roi=cell2mat(data_roi(1,1));
            for i=1:size(data_roi,1)
                u(cell2mat(data_roi(i,2)),1)=cell2mat(data_roi(i,4));
                v(cell2mat(data_roi(i,2)),1)=cell2mat(data_roi(i,5));
            end
            handles.Uinsert=u;
            handles.Vinsert=v;
            u=u';
            v=v';
            % Display U and V
            set(handles.pointsUText,'String',num2str(u,'%.2f '));
            set(handles.pointsVText,'String',num2str(v,'%.2f '));
            set(handles.deleteRoiButton,'Enable','on')
        end
    end
    % Update handles structure
    guidata(hObject, handles);
catch e
    disp(e.message)
end

% --- Executes on button press in insertRoiButton.
function insertRoiButton_Callback(hObject, eventdata, handles)
% hObject    handle to insertRoiButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    action=questdlg('Will insert information into the database is sure?','Insert','No');
    if strcmp(action,'Yes')
        save_roi(hObject,handles);
    end
catch e
    disp(e.message)
end

% --- Executes on button press in updateRoiButton.
function updateRoiButton_Callback(hObject, eventdata, handles)
% hObject    handle to updateRoiButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    action=questdlg('Will update the data is sure?','Update','No');
    if strcmp(action,'Yes')
        update_roi(hObject,handles);        
    end
catch e
    disp(e.message)
end

% --- Executes on button press in deleteRoiButton.
function deleteRoiButton_Callback(hObject, eventdata, handles)
% hObject    handle to deleteRoiButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    action=questdlg('Will delete the data is sure?','Delete','No');
    if strcmp(action,'Yes')
        % Delete ROI into the database
        
        %reboot connection to the database if necessary
        [handles.conn status] = renew_connection_db(handles.conn);

        if status == 1
            return
        end
        
        h=gui_message('Deleting in database, this might take a while!',...
            'Deleting');
        station = get_station(handles);
        status = delete_roi(handles.conn, station, handles.id_roi);
        if ishandle(h)
            delete(h);
        end
        if status ==0
            warndlg('Delete successful','Successful');
            if ~isempty(handles.figure)
                % Show image
                imshow(handles.figure, 'Parent', handles.image);
                % Update variables
                hold(handles.image, 'on')
                
            end
            
            handles.Uinsert=[];
            handles.Vinsert=[];
            handles.Uupdate=[];
            handles.Vupdate=[];
            set(handles.displayU,'String','');
            set(handles.displayV,'String','');
            handles.motionActivated = false;
            
            set(handles.buttonPick,'Enable','off')
            set(handles.TimestampRoiSelect,'Value',1)
            set(handles.TimestampRoiSelect,'String',{''})
            
            cam = get_camera(handles);
            timestampsnum_cal = get_timestampCal(handles);
            timestampsnum_cal=datenum(timestampsnum_cal);
            type = get_type(handles);
            h=gui_message('Loading from database, this might take a while!',...
                'Loading');
            % Initialize timestampnewroi ROI in popup menu
            timestamp_roi  = load_timestamp_roi(handles.conn, station, cam, timestampsnum_cal, type);
            if ishandle(h)
                delete(h);
            end
            timestampsstr_roi = cell(0);
            timestampsstr_roi{1, 1}= 'Select the timestamp the ROI';
            timestampsstr_roi{2, 1} = 'New ROI';
            j=3;
            for k = 1:length(timestamp_roi)
                timestampsstr_roi{j, 1}=datestr(cell2mat(timestamp_roi(k)));
                j=j+1;
            end
            set(handles.TimestampRoiSelect,'String',timestampsstr_roi);
            
        else
            warndlg('Delete unsuccessful','Unsuccessful');
        end
        
        % Update handles structure
        guidata(hObject, handles);
    end
catch e
    disp(e.message)
end

function pointsUText_Callback(hObject, eventdata, handles)
% hObject    handle to pointsUText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pointsUText as text
%        str2double(get(hObject,'String')) returns contents of pointsUText as a double

try
    handles.saved = false;
    if handles.external_call
        check_UV(handles)
    else
        check_data_roi(handles)
    end
    if strcmp(handles.action, 'Insert')
        U=str2num(get(handles.pointsUText,'String'));
        U=U';
        if ~isempty(U)
            % Assign points in U
            handles.Uinsert=U;
            if ~isempty(handles.figure)
                if size(handles.Uinsert,1)==size(handles.Vinsert,1)
                    u=handles.Uinsert;
                    v=handles.Vinsert;
                    if size(U,1)>=3
                        % Close the polynomial
                        u(end+1)=(handles.Uinsert(1,1));
                        v(end+1)=(handles.Vinsert(1,1));
                    end
                    % Show image
                    imshow(handles.figure, 'Parent', handles.image);
                    hold(handles.image, 'on')
                    % Display ROI
                    plot(u,v,'-*r','MarkerSize',10,'MarkerFaceColor','g','MarkerEdgeColor','y', 'Parent', handles.image)
                end
            end
            % Update handles structure
            guidata(hObject, handles);
        end
        if size(U,1)<3
            warndlg('The U and V must have at least 3 points and numeric','Warning');
            return;
        end
    else
        
        U=str2num(get(handles.pointsUText,'String'));
        U=U';
        V=str2num(get(handles.pointsVText,'String'));
        V=V';
        if ~isempty(U)
            % Assign points in U
            handles.Uupdate=U;
            handles.Vupdate=V;
            if ~isempty(handles.figure)
                if size(handles.Uupdate,1)==size(handles.Vupdate,1)
                    % Show image
                    imshow(handles.figure, 'Parent', handles.image);
                    hold(handles.image, 'on')
                    u=handles.Uinsert;
                    v=handles.Vinsert;
                    % Close the polynomial
                    u(end+1)=(handles.Uinsert(1,1));
                    v(end+1)=(handles.Vinsert(1,1));
                    % Display old ROI
                    plot(u,v,'-*y','MarkerSize',10,'MarkerFaceColor','g','MarkerEdgeColor','r', 'Parent', handles.image)
                    
                    u=handles.Uupdate;
                    v=handles.Vupdate;
                    if size(U,1)>=3
                        % Close the polynomial
                        u(end+1)=(handles.Uupdate(1,1));
                        v(end+1)=(handles.Vupdate(1,1));
                    end
                    % Display new ROI
                    plot(u,v,'-*r','MarkerSize',10,'MarkerFaceColor','g','MarkerEdgeColor','y', 'Parent', handles.image)
                end
            end
            % Update handles structure
            guidata(hObject, handles);
        end
        if size(U,1)<3
            warndlg('The U and V must have at least 3 points and numeric','Warning');
            return;
        end
        
    end
catch e
    disp(e.message)
end

function pointsVText_Callback(hObject, eventdata, handles)
% hObject    handle to pointsVText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pointsVText as text
%        str2double(get(hObject,'String')) returns contents of pointsVText as a double

try
    handles.saved = false;
    if handles.external_call
        check_UV(handles)
    else
        check_data_roi(handles)
    end
    if strcmp(handles.action, 'Insert')
        V=str2num(get(handles.pointsVText,'String'));
        V=V';
        if ~isempty(V)
            % Assign points in V
            handles.Vinsert=V;
            if ~isempty(handles.figure)
                if size(handles.Uinsert,1)==size(handles.Vinsert,1)
                    u=handles.Uinsert;
                    v=handles.Vinsert;
                    if size(V,1)>=3
                        % Close the polynomial
                        u(end+1)=(handles.Uinsert(1,1));
                        v(end+1)=(handles.Vinsert(1,1));
                    end
                    % Show image
                    imshow(handles.figure, 'Parent', handles.image);
                    hold(handles.image, 'on')
                    % Display ROI
                    plot(u,v,'-*r','MarkerSize',10,'MarkerFaceColor','g','MarkerEdgeColor','y', 'Parent', handles.image)
                end
            end
            % Update handles structure
            guidata(hObject, handles);
        end
        if size(V,1)<3
            warndlg('The U and V must have at least 3 points and numeric','Warning');
            return;
        end
    else
        V=str2num(get(handles.pointsVText,'String'));
        V=V';
        U=str2num(get(handles.pointsUText,'String'));
        U=U';
        if ~isempty(V)
            % Assign points in V
            handles.Vupdate=V;
            handles.Uupdate=U;
            if ~isempty(handles.figure)
                if size(handles.Uupdate,1)==size(handles.Vupdate,1)
                    % Show image
                    imshow(handles.figure, 'Parent', handles.image);
                    hold(handles.image, 'on')
                    u=handles.Uinsert;
                    v=handles.Vinsert;
                    % Close the polynomial
                    u(end+1)=(handles.Uinsert(1,1));
                    v(end+1)=(handles.Vinsert(1,1));
                    % Display old ROI
                    plot(u,v,'-*y','MarkerSize',10,'MarkerFaceColor','g','MarkerEdgeColor','r', 'Parent', handles.image)
                    
                    u=handles.Uupdate;
                    v=handles.Vupdate;
                    if size(V,1)>=3
                        % Close the polynomial
                        u(end+1)=(handles.Uupdate(1,1));
                        v(end+1)=(handles.Vupdate(1,1));
                    end
                    % Display new ROI
                    plot(u,v,'-*r','MarkerSize',10,'MarkerFaceColor','g','MarkerEdgeColor','y', 'Parent', handles.image)
                end
            end
            % Update handles structure
            guidata(hObject, handles);
        end
        
        if size(V,1)<3
            warndlg('The U and V must have at least 3 points and numeric','Warning');
            return;
        end
    end
catch e
    disp(e.message)
end

% --------------------------------------------------------------------
function deletePoint_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to deletePoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    if strcmp(handles.action, 'Insert')
        % Delete the last point mark
        if size(handles.Uinsert,1)>1
            handles.Uinsert=handles.Uinsert(1:end-1,1);
            handles.Vinsert=handles.Vinsert(1:end-1,1);
        else
            handles.Uinsert=[];
            handles.Vinsert=[];
        end
        % Show image
        imshow(handles.figure, 'Parent', handles.image);
        hold(handles.image, 'on')
        % Display ROI
        plot(handles.Uinsert,handles.Vinsert,'-*r','MarkerSize',10,'MarkerFaceColor','g','MarkerEdgeColor','y', 'Parent', handles.image)
        u=handles.Uinsert';
        v=handles.Vinsert';
        % Display U and V
        set(handles.pointsUText,'String',num2str(u,'%.2f '));
        set(handles.pointsVText,'String',num2str(v,'%.2f '));
        
    else
        % Delete the last point mark
        if size(handles.Uupdate,1)>1
            handles.Uupdate=handles.Uupdate(1:end-1,1);
            handles.Vupdate=handles.Vupdate(1:end-1,1);
        else
            handles.Uupdate=[];
            handles.Vupdate=[];
        end
        % Show image
        imshow(handles.figure, 'Parent', handles.image);
        hold(handles.image, 'on')
        
        u=handles.Uinsert;
        v=handles.Vinsert;
        % Close the polynomial
        u(end+1)=(handles.Uinsert(1,1));
        v(end+1)=(handles.Vinsert(1,1));
        % Display old ROI
        plot(u,v,'-*y','MarkerSize',10,'MarkerFaceColor','g','MarkerEdgeColor','r', 'Parent', handles.image)
        
        % Display new ROI
        plot(handles.Uupdate,handles.Vupdate,'-*r','MarkerSize',10,'MarkerFaceColor','g','MarkerEdgeColor','y', 'Parent', handles.image)
        
        u=handles.Uupdate';
        v=handles.Vupdate';
        % Display U and V
        set(handles.pointsUText,'String',num2str(u,'%.2f '));
        set(handles.pointsVText,'String',num2str(v,'%.2f '));
    end
    check_data_roi(handles)
    % Update handles structure
    guidata(hObject, handles);
catch e
    disp(e.message)
end

% --- Executes on button press in loadImageButton.
function loadImageButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadImageButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    if ~isempty(handles.datebox)
        date=get_timestamp_calendar(handles);
    else
        timestampRoi = get_timestampRoi(handles);
        date = datenum(timestampRoi,'dd-mmm-yyyy HH:MM:SS');
    end
    
    station = get_station(handles);
    cam = get_camera(handles);
    % Load image
    
    %reboot connection to the database if necessary
    [handles.conn status] = renew_connection_db(handles.conn);
    
    if status == 1
        return
    end
    
    h=gui_message('Loading from database, this might take a while!',...
        'Loading');
    
    value = get(handles.timestampCalSelect, 'Value');
    contents = cellstr(get(handles.timestampCalSelect, 'String'));
    if size(contents,1) > value
        time_max = datenum(contents{value + 1}) - (1/(24*3600));
    else
        time_max = inf;
    end
    
    date_max = min(date+(12/24),time_max);
    image_info = load_allimage(handles.conn, {'snap'}, cam, station, date, date_max);
    if ishandle(h)
        delete(h);
    end
    if ~isempty(image_info)
        % Initialize images in popup menu
        imgname = image_info(:,1);
        handles.imglocation = strrep(image_info(:,2),'\',filesep);
        
        j=2;
        images = cell(0);
        images{1, 1}= 'Select the image to show';
        for i=1: min(length(imgname),20)
            if strfind(handles.root,'http://')
                images{j, 1}=strtrim(imgname{i});
                j=j+1;
            else
                if exist(fullfile(handles.root, strtrim(handles.imglocation{i}), strtrim(imgname{i})), 'file')
                    images{j, 1}=strtrim(imgname{i});
                    j=j+1;
                end
            end
        end
        set(handles.LoadImageSelect,'String',images);
        
    else
        warndlg({['No images in the database between ' datestr(date) ...
            ' and ' datestr(date+(12/24)) ], ...
            'Be sure to enter the site before proceeding.'},'Warning');
    end
    
    % Update handles structure
    guidata(hObject, handles);
catch e
    disp(e.message)
end

% --- Executes on selection change in LoadImageSelect.
function LoadImageSelect_Callback(hObject, eventdata, handles)
% hObject    handle to LoadImageSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns LoadImageSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LoadImageSelect

try
    if get(handles.LoadImageSelect,'Value') > 1
        
        imgname=cellstr(get(handles.LoadImageSelect,'String'));
        imgname=char(imgname{get(handles.LoadImageSelect,'Value')});
        imglocation = handles.imglocation;
        imglocation=char(imglocation{get(handles.LoadImageSelect,'Value')-1});
        
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
            
            h=gui_message(['The image is loading from an external server, '...
                'it may take some minutes.'],'Message');
            try
                handles.figure = imread(fullpath);
                if ishandle(h)
                    delete(h);
                end
            catch e
                if ishandle(h)
                    delete(h);
                end
                warndlg('Can''t read URL','Warning');
                % Update handles structure
                guidata(hObject, handles);
                varargout = gui_roi_tool_OutputFcn(hObject, eventdata, handles);
                return;
            end
        else
            if ~exist(fullpath, 'file')
                warndlg('This image does not exist in the file disk','Warning');
                % Update handles structure
                guidata(hObject, handles);
                varargout = gui_roi_tool_OutputFcn(hObject, eventdata, handles);
                return;
            end
        end
        
        handles.figure = imread(fullpath);
        % Show the image
        imshow(handles.figure, 'Parent', handles.image);
        set(handles.imagePanel, 'Title', imgname);
        hold(handles.image, 'on')
        
        if strcmp(handles.action, 'Update');
            u=handles.Uinsert;
            v=handles.Vinsert;
            % Close the polynomial
            u(end+1)=(handles.Uinsert(1,1));
            v(end+1)=(handles.Vinsert(1,1));
            % Display ROI
            plot(u,v,'-*y','MarkerSize',10,'MarkerFaceColor','g','MarkerEdgeColor','r','Parent', handles.image)
        end
        
        set(handles.zoomIn,'Enable','on')
        set(handles.zoomOut,'Enable','on')
        set(handles.pan,'Enable','on')
        set(handles.deletePoint,'Enable','on')
        set(handles.buttonPick,'Enable','on')
        % Update handles structure
        guidata(hObject, handles);
    else
        set(handles.imagePanel, 'Title', '');
        axes(handles.image);
        cla;
        set(handles.zoomIn,'Enable','off')
        set(handles.zoomOut,'Enable','off')
        set(handles.pan,'Enable','off')
        set(handles.deletePoint,'Enable','on')
        set(handles.buttonPick,'Enable','off')
    end
catch e
    disp(e.message)
end

% --- Executes on button press in buttonPick.
function buttonPick_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    handles.saved = false;
    handles.motionActivated = true;
    % Show image
    imshow(handles.figure, 'Parent', handles.image);
    hold(handles.image, 'on')
    if strcmp(handles.action, 'Insert')
        if size(handles.Uinsert,1)> size(handles.Vinsert,1)
            handles.Uinsert=handles.Uinsert(1:end-1,1);
        elseif size(handles.Uinsert,1) < size(handles.Vinsert,1)
            handles.Vinsert=handles.Vinsert(1:end-1,1);
        end
        % Display ROI
        plot(handles.Uinsert,handles.Vinsert,'-*r','MarkerSize',10,'MarkerFaceColor','g','MarkerEdgeColor','y', 'Parent', handles.image)
        u=handles.Uinsert';
        v=handles.Vinsert';
        % Display U and V
        set(handles.pointsUText,'String',num2str(u,'%.2f '));
        set(handles.pointsVText,'String',num2str(v,'%.2f '));
    else
        u=handles.Uinsert;
        v=handles.Vinsert;
        % Close the polynomial
        u(end+1)=(handles.Uinsert(1,1));
        v(end+1)=(handles.Vinsert(1,1));
        % Display ROI
        plot(u,v,'-*y','MarkerSize',10,'MarkerFaceColor','g','MarkerEdgeColor','r', 'Parent', handles.image)
        if size(handles.Uupdate,1)> size(handles.Vupdate,1)
            handles.Uupdate=handles.Uupdate(1:end-1,1);
        elseif size(handles.Uupdate,1) < size(handles.Vupdate,1)
            handles.Vupdate=handles.Vupdate(1:end-1,1);
        end
        % Display ROI
        plot(handles.Uupdate,handles.Vupdate,'-*r','MarkerSize',10,'MarkerFaceColor','g','MarkerEdgeColor','y', 'Parent', handles.image)
        u=handles.Uupdate';
        v=handles.Vupdate';
        % Display U and V
        set(handles.pointsUText,'String',num2str(u,'%.2f '));
        set(handles.pointsVText,'String',num2str(v,'%.2f '));
    end
    check_data_roi(handles)
    % Update handles structure
    guidata(hObject, handles);
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
    if handles.motionActivated
        
        [m n o] = size(handles.figure);
        UV = get(handles.image, 'CurrentPoint');
        U = UV(1, 1);
        V = UV(1, 2);
        
        if U > 0 && U <= n && V > 0 && V <= m;
            
            if strcmp(handles.action, 'Insert')
                
                if strcmp(get(handles.figure1,'SelectionType'),'normal')
                    % Mark the point left click
                    handles.motionActivated = true;
                    
                    % Update variables
                    handles.Uinsert(end+1,1)=U;
                    handles.Vinsert(end+1,1)=V;
                    % Show image
                    imshow(handles.figure, 'Parent', handles.image);
                    hold(handles.image, 'on')
                    % Display ROI
                    plot(handles.Uinsert,handles.Vinsert,'-*r','MarkerSize',10,'MarkerFaceColor','g','MarkerEdgeColor','y', 'Parent', handles.image)
                    
                    u=handles.Uinsert';
                    v=handles.Vinsert';
                    % Display U and V
                    set(handles.pointsUText,'String',num2str(u,'%.2f '));
                    set(handles.pointsVText,'String',num2str(v,'%.2f '));
                elseif strcmp(get(handles.figure1,'SelectionType'),'alt')
                    % Close the polynomial mark with right click
                    handles.motionActivated = false;
                    set(handles.figure1, 'Pointer', 'arrow');
                    
                    handles.Uinsert(end+1,1)=U;
                    handles.Vinsert(end+1,1)=V;
                    u=handles.Uinsert;
                    v=handles.Vinsert;
                    if size(u,1)<3 || size(v,1)<3
                        handles.motionActivated = true;
                        warning = warndlg('The U and V must have at least 3 points','Warning');
                    else
                        % Close the polynomial
                        u(end+1)=(handles.Uinsert(1,1));
                        v(end+1)=(handles.Vinsert(1,1));
                        set(handles.saveButton,'Enable','on');
                    end
                    figure(handles.figure1);
                    % Show image
                    imshow(handles.figure, 'Parent', handles.image);
                    hold(handles.image, 'on')
                    % Display ROI
                    plot(u,v,'-*r','MarkerSize',10,'MarkerFaceColor','g','MarkerEdgeColor','y', 'Parent', handles.image)
                    u=handles.Uinsert';
                    v=handles.Vinsert';
                    % Display U and V
                    set(handles.pointsUText,'String',num2str(u,'%.2f '));
                    set(handles.pointsVText,'String',num2str(v,'%.2f '));
                    if exist('warning','var')
                        figure(warning);
                    end
                    set(handles.displayU,'String','');
                    set(handles.displayV,'String','');
                    if handles.external_call
                        check_UV(handles)
                    else
                        check_data_roi(handles)
                    end
                end
                
            else
                
                if strcmp(get(handles.figure1,'SelectionType'),'normal')
                    % Mark the point left click
                    handles.motionActivated = true;
                    
                    handles.Uupdate(end+1,1)=U;
                    handles.Vupdate(end+1,1)=V;
                    % Show image
                    imshow(handles.figure, 'Parent', handles.image);
                    hold(handles.image, 'on')
                    u=handles.Uinsert;
                    v=handles.Vinsert;
                    % Close the polynomial
                    u(end+1)=(handles.Uinsert(1,1));
                    v(end+1)=(handles.Vinsert(1,1));
                    % Display old ROI
                    plot(u,v,'-*y','MarkerSize',10,'MarkerFaceColor','g','MarkerEdgeColor','r', 'Parent', handles.image)
                    % Display new ROI
                    plot(handles.Uupdate,handles.Vupdate,'-*r','MarkerSize',10,'MarkerFaceColor','g','MarkerEdgeColor','y', 'Parent', handles.image)
                    u=handles.Uupdate';
                    v=handles.Vupdate';
                    % Display U and V
                    set(handles.pointsUText,'String',num2str(u,'%.2f '));
                    set(handles.pointsVText,'String',num2str(v,'%.2f '));
                elseif strcmp(get(handles.figure1,'SelectionType'),'alt')
                    % Close the polynomial mark with right click
                    handles.motionActivated = false;
                    set(handles.figure1, 'Pointer', 'arrow');
                    
                    % Update variables
                    handles.Uupdate(end+1,1)=U;
                    handles.Vupdate(end+1,1)=V;
                    u=handles.Uupdate;
                    v=handles.Vupdate;
                    if size(u,1)<3 || size(v,1)<3
                        handles.motionActivated = true;
                        warning = warndlg('The U and V must have at least 3 points','Warning');
                    else
                        % Close the polynomial
                        u(end+1)=(handles.Uupdate(1,1));
                        v(end+1)=(handles.Vupdate(1,1));
                    end
                    figure(handles.figure1);
                    % Show image
                    imshow(handles.figure, 'Parent', handles.image);
                    hold(handles.image, 'on')
                    
                    u2=handles.Uinsert;
                    v2=handles.Vinsert;
                    u2(end+1)=(handles.Uinsert(1,1));
                    v2(end+1)=(handles.Vinsert(1,1));
                    % Display old ROI
                    plot(u2,v2,'-*y','MarkerSize',10,'MarkerFaceColor','g','MarkerEdgeColor','r', 'Parent', handles.image)
                    
                    % Display new ROI
                    plot(u,v,'-*r','MarkerSize',10,'MarkerFaceColor','g','MarkerEdgeColor','y', 'Parent', handles.image)
                    
                    
                    u=handles.Uupdate';
                    v=handles.Vupdate';
                    % Display U and V
                    set(handles.pointsUText,'String',num2str(u,'%.2f '));
                    set(handles.pointsVText,'String',num2str(v,'%.2f '));
                    if exist('warning','var')
                        figure(warning);
                    end
                    set(handles.displayU,'String','');
                    set(handles.displayV,'String','');
                    check_data_roi(handles)
                end
                
            end
        end
        
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
    if handles.motionActivated
        [m n o] = size(handles.figure);
        
        UV = get(handles.image, 'CurrentPoint');
        U = UV(1, 1);
        V = UV(1, 2);
        
        if U > 0 && U <= n && V > 0 && V <= m;
            % Display point U and V
            set(handles.figure1, 'Pointer', 'crosshair');
            set(handles.displayU,'String',num2str(U,'%.2f '));
            set(handles.displayV,'String',num2str(V,'%.2f '));
            
        else
            % Not display point U and V
            set(handles.figure1, 'Pointer', 'arrow');
            set(handles.displayU,'String','');
            set(handles.displayV,'String','');
            
        end
        % Update handles structure
        guidata(hObject, handles);
    end
catch e
    disp(e.message)
end

function check_data_roi(handles)

try
    % Check data of the GUI
    flag=1;
    % Check station
    if get(handles.StationSelect,'Value')==1
        set(handles.insertRoiButton,'Enable','off')
        set(handles.updateRoiButton,'Enable','off')
        set(handles.deleteRoiButton,'Enable','off')
        flag=0;
    end
    % Check camera
    if get(handles.cameraSelect,'Value')==1
        set(handles.insertRoiButton,'Enable','off')
        set(handles.updateRoiButton,'Enable','off')
        set(handles.deleteRoiButton,'Enable','off')
        flag=0;
    end
    % Check timestampnewroi of the Calibration
    if get(handles.timestampCalSelect,'Value')==1
        set(handles.insertRoiButton,'Enable','off')
        set(handles.updateRoiButton,'Enable','off')
        set(handles.deleteRoiButton,'Enable','off')
        flag=0;
    end
    % Check type the ROI
    if get(handles.TypeSelect,'Value')==1
        set(handles.insertRoiButton,'Enable','off')
        set(handles.updateRoiButton,'Enable','off')
        set(handles.deleteRoiButton,'Enable','off')
        flag=0;
    end
    % Check timestampnewroi of the ROI
    if get(handles.TimestampRoiSelect,'Value')==1
        set(handles.insertRoiButton,'Enable','off')
        set(handles.updateRoiButton,'Enable','off')
        set(handles.deleteRoiButton,'Enable','off')
        flag=0;
    end
    % Check U
    U=str2num(get(handles.pointsUText,'String'));
    if isempty(U)
        set(handles.insertRoiButton,'Enable','off')
        set(handles.updateRoiButton,'Enable','off')
        flag=0;
    end
    % Check V
    V=str2num(get(handles.pointsVText,'String'));
    if isempty(V)
        set(handles.insertRoiButton,'Enable','off')
        set(handles.updateRoiButton,'Enable','off')
        flag=0;
    end
    % Check U and V
    if size(U,2)~=size(V,2)
        set(handles.insertRoiButton,'Enable','off')
        set(handles.updateRoiButton,'Enable','off')
        flag=0;
    end
    
    if size(U,2)<3 || size(V,2)<3
        set(handles.insertRoiButton,'Enable','off')
        set(handles.updateRoiButton,'Enable','off')
        flag=0;
    end
    if flag==1
        set(handles.insertRoiButton,'Enable','on')
        set(handles.updateRoiButton,'Enable','on')
        set(handles.deleteRoiButton,'Enable','on')
    end
    
catch e
    disp(e.message)
end

function check_UV(handles)

try
    % Check data of the GUI
    flag=1;
    U=str2num(get(handles.pointsUText,'String'));
    if isempty(U)
        set(handles.insertRoiButton,'Enable','off')
        set(handles.updateRoiButton,'Enable','off')
        flag=0;
    end
    % Check V
    V=str2num(get(handles.pointsVText,'String'));
    if isempty(V)
        set(handles.insertRoiButton,'Enable','off')
        set(handles.updateRoiButton,'Enable','off')
        flag=0;
    end
    % Check U and V
    if size(U,2)~=size(V,2)
        set(handles.insertRoiButton,'Enable','off')
        set(handles.updateRoiButton,'Enable','off')
        flag=0;
    end
    
    if size(U,2)<3 || size(V,2)<3
        set(handles.insertRoiButton,'Enable','off')
        set(handles.updateRoiButton,'Enable','off')
        flag=0;
    end
    if flag==1
        set(handles.insertRoiButton,'Enable','on')
    end
catch e
    disp(e.message)
end

% Get station
function station = get_station(handles)
try
    value = get(handles.StationSelect, 'Value');
    contents = cellstr(get(handles.StationSelect, 'String'));
    station = contents{value};
catch e
    disp(e.message)
end

% Get camera
function camera = get_camera(handles)
try
    value = get(handles.cameraSelect, 'Value');
    contents = cellstr(get(handles.cameraSelect, 'String'));
    camera = contents{value};
catch e
    disp(e.message)
end

% Get timestampnewroi of the Calibration
function timestampCal = get_timestampCal(handles)
try
    value = get(handles.timestampCalSelect, 'Value');
    contents = cellstr(get(handles.timestampCalSelect, 'String'));
    timestampCal = contents{value};
catch e
    disp(e.message)
end

% Get type of the ROI
function type = get_type(handles)
try
    value = get(handles.TypeSelect, 'Value');
    contents = cellstr(get(handles.TypeSelect, 'String'));
    type = contents{value};
catch e
    disp(e.message)
end

% Get timestamproi of the ROI
function timestampRoi = get_timestampRoi(handles)
try
    value = get(handles.TimestampRoiSelect, 'Value');
    contents = cellstr(get(handles.TimestampRoiSelect, 'String'));
    timestampRoi = contents{value};
catch e
    disp(e.message)
end

% Save de ROI in the database
function save_roi(hObject,handles)

try
    pointsU = handles.Uinsert;
    pointsV = handles.Vinsert;
    
    % Get information
    station = get_station(handles);
    cam = get_camera(handles);
    type = get_type(handles);
    timestampsnum_cal = get_timestampCal(handles);
    timestampsnum_cal=datenum(timestampsnum_cal);
    if handles.external_call
        timestampsnum_roi = datenum(get(handles.TimestampRoiSelect,'String'));
    else
        timestampsnum_roi = get_timestamp_calendar(handles);
    end
    
    %reboot connection to the database if necessary
    [handles.conn status] = renew_connection_db(handles.conn);
    
    if status == 1
        return
    end
    
    h=gui_message('Loading from database, this might take a while!',...
        'Loading');
    idcalibration = load_idcalibration(handles.conn, station, cam, timestampsnum_cal);
    if ishandle(h)
        delete(h);
    end
    h=gui_message('Inserting in database, this might take a while!',...
        'Inserting');
    % Insert ROI into the database
    status = insert_roi(handles.conn, station, type,cell2mat(idcalibration),timestampsnum_roi,pointsU,pointsV);
    if ishandle(h)
        delete(h);
    end
    if status ==0
        warndlg('Insert successful','Successful');
        set(handles.displayU,'String','');
        set(handles.displayV,'String','');
        handles.motionActivated = false;
        if handles.external_call
            close(handles.figure1)
        end
        set(handles.TimestampRoiSelect,'Value',1)
        set(handles.TimestampRoiSelect,'String',{''})
        station = get_station(handles);
        
        cam = get_camera(handles);
        timestampsnum_cal = get_timestampCal(handles);
        timestampsnum_cal=datenum(timestampsnum_cal);
        type = get_type(handles);
        h=gui_message('Loading from database, this might take a while!',...
            'Loading');
        % Initialize timestampnewroi ROI in popup menu
        timestamp_roi  = load_timestamp_roi(handles.conn, station, cam, timestampsnum_cal, type);
        if ishandle(h)
            delete(h);
        end
        timestampsstr_roi = cell(0);
        timestampsstr_roi{1, 1}= 'Select the timestamp the ROI';
        timestampsstr_roi{2, 1} = 'New ROI';
        j=3;
        for k = 1:length(timestamp_roi)
            timestampsstr_roi{j, 1}=datestr(cell2mat(timestamp_roi(k)));
            j=j+1;
        end
        set(handles.TimestampRoiSelect,'String',timestampsstr_roi);
        handles.saved = true;
    else
        warndlg('Insert unsuccessful','Unsuccessful');
    end
    % Update handles structure
    guidata(hObject, handles);
catch e
    disp(e.message)
end

function update_roi(hObject,handles)

try
    % Get information
    pointsU = handles.Uupdate;
    pointsV = handles.Vupdate;
    idcorrd = 1:size(pointsU,1);
    
    %reboot connection to the database if necessary
    [handles.conn status] = renew_connection_db(handles.conn);
    
    if status == 1
        return
    end
    
    h=gui_message('Updating in database, this might take a while!',...
        'Updating');
    % Update ROI into the database
    station = get_station(handles);
    status = update_roicoordinate(handles.conn, station, handles.id_roi, idcorrd, 'u', ...
        pointsU, 'v', pointsV);
    if ishandle(h)
        delete(h);
    end
    if status ==0
        warndlg('Update successful','Successful');
        % Update variables
        handles.Uinsert=pointsU;
        handles.Vinsert=pointsV;
        u=handles.Uinsert;
        v=handles.Vinsert;
        % Close the polynomial
        u(end+1)=(handles.Uinsert(1,1));
        v(end+1)=(handles.Vinsert(1,1));
        if ~isempty(handles.figure)
            % Show image
            imshow(handles.figure, 'Parent', handles.image);
            hold(handles.image, 'on')
            % Display ROI
            plot(u,v,'-*y','MarkerSize',10,'MarkerFaceColor','g','MarkerEdgeColor','r', 'Parent', handles.image)
        end
        handles.Uupdate=[];
        handles.Vupdate=[];
        set(handles.displayU,'String','');
        set(handles.displayV,'String','');
        handles.motionActivated = false;
        handles.saved = true;
        % Update handles structure
        guidata(hObject, handles);
    else
        warndlg('Update unsuccessful','Unsuccessful');
    end
    % Update handles structure
    guidata(hObject, handles);
catch e
    disp(e.message)
end


function handles = reload_time(handles)

try
    % Set time sliders
    
    % JAVA stuff: load calendar for choosing date & time
    import java.util.*;
    import java.text.*;
    import java.awt.*;
    
    % Initialize JIDE's usage within Matlab
    com.mathworks.mwswing.MJUtilities.initJIDE;
    
    % Display a DateSpinnerComboBox
    handles.datebox = com.jidesoft.combobox.DateSpinnerComboBox; % Constructor
    
    handles.datebox.setLocale(Locale.ENGLISH); % Set English language
    handles.datebox.setTimeDisplayed(true); % Show time
    handles.datebox.setFormat(SimpleDateFormat('dd/MM/yyyy HH:mm:ss')); % Set date & time format
    handles.datebox.setTimeFormat('HH:mm:ss'); % Set time format (in the grid)
    handles.datebox.setFont(Font('SansSerif', Font.PLAIN, 10)); % Set fonts
    
    handles.datebox.setShowWeekNumbers(false); % Do not show week number
    handles.datebox.setShowNoneButton(false); % Do not show the 'None' button
    handles.datebox.setShowOKButton(true); % Show the 'OK' button
    handles.datebox.setShowTodayButton(true) % Show the 'Today' button
    
    time_min = get_timestampCal(handles);
    time_min = datenum(time_min);
    timevec = datevec(time_min);
    handles.datebox.setCalendar(GregorianCalendar(timevec(1), timevec(2) - 1, ...
        timevec(3), timevec(4), timevec(5), timevec(6)));
    
    % Put the DateSpinnerComboBox object in a GUI panel
    [handles.hDatebox,hContainer] = javacomponent(handles.datebox,[0,0,191,22],handles.NewTimestampRoi);
    
    set(handles.hDatebox, 'ActionPerformedCallback', {@timeCallbackFunction, handles});
catch e
    disp(e.message)
end


% Callback for DateSpinnerComboBox object
function timeCallbackFunction(hObject, eventdata, handles)

try
    % JAVA stuff: load calendar for choosing date & time
    import java.util.*;
    import java.text.*;
    import java.awt.*;
    
    station = get_station(handles);
    
    
    time_min = get_timestampCal(handles);
    time_min = datenum(time_min);
    
    value = get(handles.timestampCalSelect, 'Value');
    contents = cellstr(get(handles.timestampCalSelect, 'String'));
    if size(contents,1) > value
        time_max = datenum(contents{value + 1}) - (1/(24*3600));
    else
        %reboot connection to the database if necessary
        [handles.conn status] = renew_connection_db(handles.conn);
        
        if status == 1
            return
        end
        
        time_max = load_datemax(handles.conn, 'oblique', station, false);
        time_max = cell2mat(time_max);
        % Update handles structure
        guidata(hObject, handles);
    end
    
    time = get_timestamp_calendar(handles);
    if time < time_min
        timevec = datevec(time_min);
        handles.datebox.setCalendar(GregorianCalendar(timevec(1), timevec(2) - 1, ...
            timevec(3), timevec(4), timevec(5), timevec(6)));
    end
    if time > time_max
        timevec = datevec(time_max);
        handles.datebox.setCalendar(GregorianCalendar(timevec(1), timevec(2) - 1, ...
            timevec(3), timevec(4), timevec(5), timevec(6)));
    end
catch e
    disp(e.message)
end

function dnum = get_timestamp_calendar(handles)

try
    % Get time-----------------------------------------------------------------
    calObj = handles.datebox.getCalendar();
    
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

% --------------------------------------------------------------------
function zoomIn_OnCallback(hObject, eventdata, handles)
% hObject    handle to zoomIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    h = zoom;
    set(h,'Direction','in','Enable','on');
    get(handles.zoomIn,'State')
catch e
    disp(e.message)
end

% --------------------------------------------------------------------
function zoomIn_OffCallback(hObject, eventdata, handles)
% hObject    handle to zoomIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom off

% --------------------------------------------------------------------
function zoomOut_OnCallback(hObject, eventdata, handles)
% hObject    handle to zoomOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    h = zoom;
    set(h,'Direction','out','Enable','on');
catch e
    disp(e.message)
end

% --------------------------------------------------------------------
function zoomOut_OffCallback(hObject, eventdata, handles)
% hObject    handle to zoomOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

zoom off


% --------------------------------------------------------------------
function pan_OnCallback(hObject, eventdata, handles)
% hObject    handle to pan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pan on

% --------------------------------------------------------------------
function pan_OffCallback(hObject, eventdata, handles)
% hObject    handle to pan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pan off

% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    close(gcbf)
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
    %%%CloseReqFCN
    session = true;
    if handles.external_call
        choice = questdlg('Are you satisfied with this ROI?', ...
            'Select ROI', 'Yes', 'No','No');
        session = false;
        if strcmp(choice, 'No')
            return
        end
    elseif ~handles.saved
        if strcmp(handles.action, 'Insert')
            choice = questdlg('Do you want to save the selected ROI?', ...
                'Save ROI', 'Yes', 'No','No');

            if strcmp(choice, 'Yes')
                save_roi(hObject,handles);
            end
        else
            choice = questdlg('Do you want to update the selected ROI?', ...
                'Update ROI', 'Yes', 'No','No');

            if strcmp(choice, 'Yes')
                update_roi(hObject,handles);
            end
        end        
    end
    
    if session
        close_session = questdlg('Do you want to close this session?', ...
            'Close session', 'Yes', 'No', 'Cancel', 'Cancel');
        
        if strcmp(close_session, 'Yes')
            destroy_session
        elseif strcmp(close_session, 'Cancel')
            return
        end
    end
        

    if isconnection(handles.conn)
        close(handles.conn)
    end
    
    if isequal(get(hObject, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, us UIRESUME
        uiresume(hObject);
        
    else
        % The GUI is no longer waiting, just close it
        delete(hObject);
    end
catch e
    disp(e.message)
end
