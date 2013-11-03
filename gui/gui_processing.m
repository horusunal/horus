function varargout = gui_processing(varargin)
% GUI_PROCESSING MATLAB code for gui_processing.fig
%      GUI_PROCESSING, by itself, creates a new GUI_PROCESSING or raises the existing
%      singleton*.
%
%      H = GUI_PROCESSING returns the handle to a new GUI_PROCESSING or the handle to
%      the existing singleton*.
%
%      GUI_PROCESSING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_PROCESSING.M with the given input arguments.
%
%      GUI_PROCESSING('Property','Value',...) creates a new GUI_PROCESSING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_processing_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_processing_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_processing

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
% Last Modified by GUIDE v2.5 09-Nov-2012 18:36:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @gui_processing_OpeningFcn, ...
    'gui_OutputFcn',  @gui_processing_OutputFcn, ...
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


% --- Executes just before gui_processing is made visible.
function gui_processing_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_processing (see VARARGIN)

try
    % Choose default command line output for gui_processing
    handles.output = hObject;
    
    handles.xmlfile = 'processing_info.xml';
    
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
    
    % Set hour and minutes defaults
    strStartHour = cell(0);
    strStartMinute = cell(0);
    strEndHour = cell(0);
    strEndMinute = cell(0);
    
    for i = 0:23
        strStartHour{i + 1} = num2str(i, '%02d');
        strEndHour{i + 1} = num2str(i, '%02d');
    end
    set(handles.popupStartHour, 'String', strStartHour);
    
    set(handles.popupEndHour, 'String', strEndHour);
    
    for i = 0:59
        strStartMinute{i + 1} = num2str(i, '%02d');
        strEndMinute{i + 1} = num2str(i, '%02d');
    end
    set(handles.popupStartMinute, 'String', strStartMinute);
    
    set(handles.popupEndMinute, 'String', strEndMinute);
    
    % Put logo
    logo = imread('LogoHorusMin.png');
    imshow(logo, 'Parent', handles.axesLogo)
    
    % Update handles structure
    guidata(hObject, handles);
catch e
    disp(e.message)
end
% UIWAIT makes gui_processing wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_processing_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in checkboxUpload.
function checkboxUpload_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxUpload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxUpload

try
    on = get(hObject, 'Value');
    if on
        set(handles.editFTPHost, 'Enable', 'on')
        set(handles.editFTPUser, 'Enable', 'on')
        set(handles.editFTPPass, 'Enable', 'on')
        set(handles.checkboxRectified, 'Enable', 'on')
        set(handles.checkboxOblique, 'Enable', 'on')
        set(handles.checkboxMergedRectified, 'Enable', 'on')
        set(handles.checkboxMergedOblique, 'Enable', 'on')
        set(handles.editWidth, 'Enable', 'on')
        set(handles.popupThumbsImageType, 'Enable', 'on')
        set(handles.checkboxMergedOblique, 'Enable', 'on')
        set(handles.buttonAddThumbsType, 'Enable', 'on')
        set(handles.buttonRemoveThumbsType, 'Enable', 'on')
        set(handles.listboxThumbsImageType, 'Enable', 'on')
    else
        set(handles.editFTPHost, 'Enable', 'off')
        set(handles.editFTPUser, 'Enable', 'off')
        set(handles.editFTPPass, 'Enable', 'off')
        set(handles.checkboxRectified, 'Enable', 'off')
        set(handles.checkboxOblique, 'Enable', 'off')
        set(handles.checkboxMergedRectified, 'Enable', 'off')
        set(handles.checkboxMergedOblique, 'Enable', 'off')
        set(handles.editWidth, 'Enable', 'off')
        set(handles.popupThumbsImageType, 'Enable', 'off')
        set(handles.checkboxMergedOblique, 'Enable', 'off')
        set(handles.buttonAddThumbsType, 'Enable', 'off')
        set(handles.buttonRemoveThumbsType, 'Enable', 'off')
        set(handles.listboxThumbsImageType, 'Enable', 'off')
    end
catch e
    disp(e.message)
end

% --- Executes on button press in buttonSave.
function buttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    %reboot connection to the database if necessary
    [handles.conn status] = renew_connection_db(handles.conn);
    
    if status == 1
        return
    end
    
    station = get_station(handles);
    step = get_time_step(handles);
    merge = eval(get_merge_only(handles));
    rectify = eval(get_rectify_only(handles));
    rectMerge = eval(get_rectify_merge(handles));
    selectedTypes = get_list_process_type(handles);
    start_hour = get_start_hour(handles);
    start_minute = get_start_minute(handles);
    end_hour = get_end_hour(handles);
    end_minute = get_end_minute(handles);
    
    type = 'process';
    types = load_imagetype_name(handles.conn, station);
    xml = loadXML(handles.xmlfile, 'Configuration', 'station', station);
    
    ok = true;
    if start_hour * 60 + start_minute > end_hour * 60 + end_minute
        warndlg('Initial time is greater than final time!', 'Warning')
        ok = false;
    end
    if ok && isnan(step)
        warndlg('Time step is invalid!', 'Warning')
        ok = false;
    end
    if ok && merge + rectify + rectMerge == 0
        warndlg('You must select at least one option: Merge oblique images, Rectify oblique images, Rectify and merge oblique images!', 'Warning')
        ok = false;
    end
    if ok && isempty(selectedTypes)
        warndlg('You must select at least one image type for processing!', 'Warning')
        ok = false;
    end
    
    if ok
        xmlPath = strcat('Configuration[station=', station, ']/ImageProcessingConfig');
        
        removeNode(xml, xmlPath);
        
        processElement = createNode(xml, xmlPath);
        
        createLeave(xml, processElement, 'StartHour', sprintf('%d', get_start_hour(handles)))
        createLeave(xml, processElement, 'StartMinute', sprintf('%d', get_start_minute(handles)))
        createLeave(xml, processElement, 'EndHour', sprintf('%d', get_end_hour(handles)))
        createLeave(xml, processElement, 'EndMinute', sprintf('%d', get_end_minute(handles)))
        createLeave(xml, processElement, 'TimeStep', sprintf('%d', step))
        createLeave(xml, processElement, 'MergeOnly', sprintf('%s', get_merge_only(handles)))
        createLeave(xml, processElement, 'RectifyOnly', sprintf('%s', get_rectify_only(handles)))
        createLeave(xml, processElement, 'RectifyAndMerge',sprintf('%s', get_rectify_merge(handles)))
        isfalse = true;
        contents = get(handles.listboxProcessImageType, 'String');
        for i = 1:numel(types)
            for j = 1:numel(contents)
                if strcmpi(char(contents(j)),char(types(i)))
                    createLeave(xml, processElement, char(types(i)), sprintf('%s', 'true'))
                    isfalse = false;
                    break;
                end
            end
            
            if isfalse
                createLeave(xml, processElement, char(types(i)), sprintf('%s', 'false'))
            end
            isfalse = true;
        end
        idproc = load_idautomatic(handles.conn, station, type);
        idproc =  cell2mat(idproc);
        if ~isempty(idproc)
            status = update_automatic_params(handles.conn, station, idproc, ...
                'type', type, 'start_hour', get_start_hour(handles), ...
                'start_minute', get_start_minute(handles), 'end_hour', ...
                get_end_hour(handles), 'end_minute', get_end_minute(handles),...
                'step', step);
        else
            idval = cell2mat(load_max_idautomatic(handles.conn, station));
            if isnan(idval)
                idproc = 1;
            else
                idproc = idval + 1;
            end
            status = insert_automatic_params(handles.conn, idproc, station, ...
                type, get_start_hour(handles), get_start_minute(handles), ...
                get_end_hour(handles), get_end_minute(handles), step);
        end
        
        if status == 1
            warndlg('The image processing configuration has not been saved!', 'Failure')
        else
            xmlsave(handles.xmlfile, xml);
            warndlg('The image processing configuration has been saved!', 'Success')
            set(handles.buttonBuild, 'Enable', 'on')
        end
    end
    
    %%%% SAVE THUMBS CONFIGURATION
    strupload = get_upload_thumbs(handles);
    upload = eval(strupload);
   
    if upload
        width = get_thumb_width(handles);
        host = get_ftp_host(handles);
        user = get_ftp_user(handles);
        pass = get_ftp_pass(handles);
        rectified = eval(get_rectified(handles));
        oblique = eval(get_oblique(handles));
        mergedRectified = eval(get_merged_rectified(handles));
        mergedOblique = eval(get_merged_oblique(handles));
        selectedTypes = get_list_thumbs_type(handles);

        ok = true;
        if ok && isempty(host)
            warndlg('Data host is invalid!', 'Warning')
            ok = false;
        end
        if ok && isempty(user)
            warndlg('Username is invalid!', 'Warning')
            ok = false;
        end
        if ok && isempty(pass)
            warndlg('Password is invalid!', 'Warning')
            ok = false;
        end
        if ok && rectified + oblique + mergedRectified + mergedOblique == 0
            warndlg('You must select at least one option: Rectified, Oblique, Merged-rectified, Merged-oblique!', 'Warning')
            ok = false;
        end
        if ok && isempty(selectedTypes)
            warndlg('You must select at least one image type for processing!', 'Warning')
            ok = false;
        end
        if ok && isnan(width)
            warndlg('Thumbnail width is invalid!', 'Warning')
            ok = false;
        end
        
        if ok
            % Encrypt password
            pass = encrypt_aes(pass, handles.datapath);

            xmlPath = strcat('Configuration[station=', station, ']/ThumbnailsConfig');

            removeNode(xml, xmlPath);

            thumbsElement = createNode(xml, xmlPath);

            createLeave(xml, thumbsElement, 'Rectified', sprintf('%s', get_rectified(handles)))
            createLeave(xml, thumbsElement, 'Oblique', sprintf('%s', get_oblique(handles)))
            createLeave(xml, thumbsElement, 'MergedRectified', sprintf('%s', get_merged_rectified(handles)))
            createLeave(xml, thumbsElement, 'MergedOblique', sprintf('%s', get_merged_oblique(handles)))
            createLeave(xml, thumbsElement, 'ThumbWidth', sprintf('%d', width))
            createLeave(xml, thumbsElement, 'UploadFTPHost', sprintf('%s', host))
            createLeave(xml, thumbsElement, 'UploadFTPUser',sprintf('%s', user))
            createLeave(xml, thumbsElement, 'UploadFTPPass',sprintf('%s', pass))

            isfalse = true;
            contents = get(handles.listboxThumbsImageType, 'String');
            for i = 1:numel(types)
                for j = 1:numel(contents)
                    if strcmpi(char(contents(j)),char(types(i)))
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
            warndlg('The thumbs processing configuration has been saved!', 'Success')
        end
    end
    
    % Update handles structure
    guidata(hObject, handles);
catch e
    disp(e.message)
end


% --- Executes on button press in buttonBuild.
function buttonBuild_Callback(hObject, eventdata, handles)
% hObject    handle to buttonBuild (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if check_station(handles)
    station = get_station(handles);
    prompt = {'Image search step (min):', 'Image search error (min):'};
    title = 'Processing automatic options';
    num_lines = 1;
    default = {'0', '0'};

    answer = inputdlg(prompt, title, num_lines, default);
    if isempty(answer)
        return;
    end
    step = str2double(answer{1});
    error = str2double(answer{2});

    if isnan(step) || isnan(error)
        return;
    end
    if ispc
        h = gui_message('Generating process automatic might take several minutes...','Loading...');
        create_auto_exec('process', station, step, error)
        if ishandle(h)
            delete(h);
        end
    else
        mcrroot = uigetdir('.');
        if mcrroot
            h = gui_message('Generating process automatic might take several minutes...','Loading...');
            create_auto_exec('process', station, step, error, mcrroot);
            if ishandle(h)
                delete(h);
            end
        end
    end
end

% --- Executes on selection change in popupStation.
function popupStation_Callback(hObject, eventdata, handles)
% hObject    handle to popupStation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupStation contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupStation

try
    if check_station(handles)
        set(handles.buttonSave, 'Enable', 'on')
        set(handles.show_time, 'Enable', 'on')
        
        %reboot connection to the database if necessary
        [handles.conn status] = renew_connection_db(handles.conn);

        if status == 1
            return
        end
        
        station = get_station(handles);
        types = load_imagetype_name(handles.conn, station);
        
        handles = reload_types(handles);
        
        xml = loadXML(handles.xmlfile, 'Configuration', 'station', station);
        
        xmlPath = strcat('Configuration[station=', station, ']/ImageProcessingConfig');
        imageNodes = getNodes(xml, xmlPath);
        
        xmlPath = strcat('Configuration[station=', station, ']/ThumbnailsConfig');
        thumbNodes = getNodes(xml, xmlPath);
        
        if ~isempty(imageNodes)
            imageNode = imageNodes{1};
            
            val = getNodeVal(imageNode, 'StartHour');
            set(handles.popupStartHour, 'Value', str2double(val) + 1)
            
            val = getNodeVal(imageNode, 'StartMinute');
            set(handles.popupStartMinute, 'Value', str2double(val) + 1)
            
            val = getNodeVal(imageNode, 'EndHour');
            set(handles.popupEndHour, 'Value', str2double(val) + 1)
            
            val = getNodeVal(imageNode, 'EndMinute');
            set(handles.popupEndMinute, 'Value', str2double(val) + 1)
            
            val = getNodeVal(imageNode, 'TimeStep');
            set(handles.editTimeStep, 'String', val)
            
            val = getNodeVal(imageNode, 'MergeOnly');
            set(handles.checkboxMergeOnly, 'Value', eval(val))
            
            val = getNodeVal(imageNode, 'RectifyOnly');
            set(handles.checkboxRectifyOnly, 'Value', eval(val))
            
            val = getNodeVal(imageNode, 'RectifyAndMerge');
            set(handles.checkboxRectifyMerge, 'Value', eval(val))
            
            typesxml = cell(0);
            for k = 1:numel(types)
                val = getNodeVal(imageNode, char(types(k)));
                if ~isempty(val)
                    if eval(val)
                        typesxml{end+1} = char(types(k));
                    end
                end
            end
            
            set(handles.listboxProcessImageType, 'Value', 1, 'String', typesxml);
        end
        
        if ~isempty(thumbNodes)
            set(handles.checkboxUpload, 'Value', true)
            set(handles.editFTPHost, 'Enable', 'on')
            set(handles.editFTPUser, 'Enable', 'on')
            set(handles.editFTPPass, 'Enable', 'on')
            set(handles.checkboxRectified, 'Enable', 'on')
            set(handles.checkboxOblique, 'Enable', 'on')
            set(handles.checkboxMergedRectified, 'Enable', 'on')
            set(handles.checkboxMergedOblique, 'Enable', 'on')
            set(handles.editWidth, 'Enable', 'on')
            set(handles.popupThumbsImageType, 'Enable', 'on')
            set(handles.checkboxMergedOblique, 'Enable', 'on')
            set(handles.buttonAddThumbsType, 'Enable', 'on')
            set(handles.buttonRemoveThumbsType, 'Enable', 'on')
            set(handles.listboxThumbsImageType, 'Enable', 'on')
            
            thumbNode = thumbNodes{1};
            val = getNodeVal(thumbNode, 'Rectified');
            set(handles.checkboxRectified, 'Value', eval(val))
            
            val = getNodeVal(thumbNode, 'Oblique');
            set(handles.checkboxOblique, 'Value', eval(val))
            
            val = getNodeVal(thumbNode, 'MergedOblique');
            set(handles.checkboxMergedOblique, 'Value', eval(val))
            
            val = getNodeVal(thumbNode, 'MergedRectified');
            set(handles.checkboxMergedRectified, 'Value', eval(val))
            
            typesxml = cell(0);
            for k = 1:numel(types)
                val = getNodeVal(thumbNode, char(types(k)));
                if ~isempty(val)
                    if eval(val)
                        typesxml{end+1} = char(types(k));
                    end
                end
            end
            set(handles.listboxThumbsImageType, 'Value', 1, 'String', typesxml);
            
            val = getNodeVal(thumbNode, 'ThumbWidth');
            set(handles.editWidth, 'String', val)
                        
            if strcmpi(val, 'true')
                set(handles.editFTPHost, 'Enable', 'on')
                set(handles.editFTPUser, 'Enable', 'on')
                set(handles.editFTPPass, 'Enable', 'on')
            end
            
            val = getNodeVal(thumbNode, 'UploadFTPHost');
            set(handles.editFTPHost, 'String', val)
            
            val = getNodeVal(thumbNode, 'UploadFTPUser');
            set(handles.editFTPUser, 'String', val)
            
            val = getNodeVal(thumbNode, 'UploadFTPPass');
            val = decrypt_aes(val, handles.datapath);
            set(handles.editFTPPass, 'String', val)
            
        end
        
        % Update handles structure
        guidata(hObject, handles);
    else
        set(handles.popupStartHour, 'Value', 1)
        set(handles.popupStartMinute, 'Value', 1)
        set(handles.popupEndHour, 'Value', 1)
        set(handles.popupEndMinute, 'Value', 1)
        set(handles.editTimeStep, 'String', '')
        set(handles.checkboxMergeOnly, 'Value', 0)
        set(handles.checkboxRectifyOnly, 'Value', 0)
        set(handles.checkboxRectifyMerge, 'Value', 0)
        set(handles.popupProcessImageType,'Value',1,'String',{''});
        set(handles.listboxProcessImageType, 'String', '')
        set(handles.checkboxRectified, 'Value', 0)
        set(handles.checkboxOblique, 'Value', 0)
        set(handles.checkboxMergedRectified, 'Value', 0)
        set(handles.checkboxMergedOblique, 'Value', 0)
        set(handles.popupThumbsImageType,'Value',1,'String',{''});
        set(handles.listboxThumbsImageType, 'String', '')
        set(handles.editWidth, 'String', '')
        set(handles.checkboxUpload, 'Value', 0)
        set(handles.editFTPHost, 'String', '', 'Enable', 'off')
        set(handles.editFTPUser, 'String', '', 'Enable', 'off')
        set(handles.editFTPPass, 'String', '', 'Enable', 'off')
        set(handles.buttonSave, 'Enable', 'off')
        set(handles.buttonBuild, 'Enable', 'off')
        set(handles.show_time, 'Enable', 'off')
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
function startHour = get_start_hour(handles)
try
    value = get(handles.popupStartHour, 'Value');
    contents = cellstr(get(handles.popupStartHour, 'String'));
    startHour = str2double(contents{value});
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected end hour
function endHour = get_end_hour(handles)
try
    value = get(handles.popupEndHour, 'Value');
    contents = cellstr(get(handles.popupEndHour, 'String'));
    endHour = str2double(contents{value});
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected start minute
function startMinute = get_start_minute(handles)
try
    value = get(handles.popupStartMinute, 'Value');
    contents = cellstr(get(handles.popupStartMinute, 'String'));
    startMinute = str2double(contents{value});
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected end minute
function endMinute = get_end_minute(handles)
try
    value = get(handles.popupEndMinute, 'Value');
    contents = cellstr(get(handles.popupEndMinute, 'String'));
    endMinute = str2double(contents{value});
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected time step
function step = get_time_step(handles)
try
    step = str2double(get(handles.editTimeStep, 'String'));
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected option
function value = get_merge_only(handles)
try
    nvalue = get(handles.checkboxMergeOnly, 'Value');
    if nvalue == 1
        value = 'true';
    else
        value = 'false';
    end
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected option
function value = get_rectify_only(handles)
try
    nvalue = get(handles.checkboxRectifyOnly, 'Value');
    if nvalue == 1
        value = 'true';
    else
        value = 'false';
    end
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected option
function value = get_rectify_merge(handles)
try
    nvalue = get(handles.checkboxRectifyMerge, 'Value');
    if nvalue == 1
        value = 'true';
    else
        value = 'false';
    end
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected option
function value = get_rectified(handles)
try
    nvalue = get(handles.checkboxRectified, 'Value');
    if nvalue == 1
        value = 'true';
    else
        value = 'false';
    end
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected option
function value = get_oblique(handles)
try
    nvalue = get(handles.checkboxOblique, 'Value');
    if nvalue == 1
        value = 'true';
    else
        value = 'false';
    end
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected option
function value = get_merged_rectified(handles)
try
    nvalue = get(handles.checkboxMergedRectified, 'Value');
    if nvalue == 1
        value = 'true';
    else
        value = 'false';
    end
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected option
function value = get_merged_oblique(handles)
try
    nvalue = get(handles.checkboxMergedOblique, 'Value');
    if nvalue == 1
        value = 'true';
    else
        value = 'false';
    end
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected thumbnail scale
function value = get_thumb_width(handles)
try
    value = str2double(get(handles.editWidth, 'String'));
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected option
function value = get_upload_thumbs(handles)
try
    nvalue = get(handles.checkboxUpload, 'Value');
    if nvalue == 1
        value = 'true';
    else
        value = 'false';
    end
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected FTP host
function value = get_ftp_host(handles)
try
    value = get(handles.editFTPHost, 'String');
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected FTP user
function value = get_ftp_user(handles)
try
    value = get(handles.editFTPUser, 'String');
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected FTP password
function value = get_ftp_pass(handles)
try
    value = get(handles.editFTPPass, 'String');
catch e
    disp(e.message)
end


% --- Executes on button press in buttonAddProcessType.
function buttonAddProcessType_Callback(hObject, eventdata, handles)
% hObject    handle to buttonAddProcessType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    if check_ProcessType(handles)
        ProcessType = get_ProcessType(handles);
        % List of selected process type
        contents = get(handles.listboxProcessImageType, 'String');
        
        found = false;
        for i = 1:numel(contents)
            if strcmp(ProcessType, contents{i})
                found = true;
                break;
            end
        end
        
        % If chosen process type is not in the list of selected process type, append it
        if ~found
            contents{end+1} = ProcessType;
            set(handles.listboxProcessImageType, 'String', contents);
        end
    end
catch e
    disp(e.message)
end

% --- Executes on button press in buttonRemoveProcessType.
function buttonRemoveProcessType_Callback(hObject, eventdata, handles)
% hObject    handle to buttonRemoveProcessType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    % List of selected process type
    contents = get(handles.listboxProcessImageType, 'String');
    
    if ~isempty(contents)
        % Unselect a process type from the list
        index = get(handles.listboxProcessImageType, 'Value');
        new = cell(0);
        
        % Copy all the process type but the one to be unselected
        for i = 1:numel(contents)
            if i ~= index
                new{end+1} = contents{i};
            end
        end
        % Reload list
        set(handles.listboxProcessImageType, 'Value', 1, 'String', new);
        
    end
catch e
    disp(e.message)
end

% --- Executes on button press in buttonAddThumbsType.
function buttonAddThumbsType_Callback(hObject, eventdata, handles)
% hObject    handle to buttonAddThumbsType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    if check_ThumbsType(handles)
        ThumbsType = get_ThumbsType(handles);
        % List of selected thumbs type
        contents = get(handles.listboxThumbsImageType, 'String');
        
        found = false;
        for i = 1:numel(contents)
            if strcmp(ThumbsType, contents{i})
                found = true;
                break;
            end
        end
        
        % If chosen thumbs type is not in the list of selected thumbs type, append it
        if ~found
            contents{end+1} = ThumbsType;
            set(handles.listboxThumbsImageType, 'String', contents);
        end
    end
catch e
    disp(e.message)
end

% --- Executes on button press in buttonRemoveThumbsType.
function buttonRemoveThumbsType_Callback(hObject, eventdata, handles)
% hObject    handle to buttonRemoveThumbsType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    % List of selected thumbs type
    contents = get(handles.listboxThumbsImageType, 'String');
    
    if ~isempty(contents)
        % Unselect a thumbs type from the list
        index = get(handles.listboxThumbsImageType, 'Value');
        new = cell(0);
        
        % Copy all the thumbs type but the one to be unselected
        for i = 1:numel(contents)
            if i ~= index
                new{end+1} = contents{i};
            end
        end
        % Reload list
        set(handles.listboxThumbsImageType, 'Value', 1, 'String', new);
        
    end
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Check if there is a valid process type selected
function ok = check_ProcessType(handles)
try
    value = get(handles.popupProcessImageType, 'Value');
    ok = value ~= 1;
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Check if there is a valid thumbs type selected
function ok = check_ThumbsType(handles)
try
    value = get(handles.popupThumbsImageType, 'Value');
    ok = value ~= 1;
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected process type
function ProcessType = get_ProcessType(handles)
try
    value = get(handles.popupProcessImageType, 'Value');
    contents = cellstr(get(handles.popupProcessImageType, 'String'));
    ProcessType = contents{value};
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the selected thumbs type
function ThumbsType = get_ThumbsType(handles)
try
    value = get(handles.popupThumbsImageType, 'Value');
    contents = cellstr(get(handles.popupThumbsImageType, 'String'));
    ThumbsType = contents{value};
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the list of process types
function list = get_list_process_type(handles)
try
    list = get(handles.listboxProcessImageType, 'String');
catch e
    disp(e.message)
end

%--------------------------------------------------------------------------
% Returns the list of thumbs types
function list = get_list_thumbs_type(handles)
try
    list = get(handles.listboxThumbsImageType, 'String');
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
        
        set(handles.popupProcessImageType, 'String', strtype);
        set(handles.popupThumbsImageType, 'String', strtype);
    end
catch e
    disp(e.message)
end

% --- Executes on button press in show_time.
function show_time_Callback(hObject, eventdata, handles)
% hObject    handle to show_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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
