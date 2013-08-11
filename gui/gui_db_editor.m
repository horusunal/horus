function varargout = gui_db_editor(varargin)
% GUI_DB_EDITOR M-file for gui_db_editor.fig
%      GUI_DB_EDITOR, by itself, creates a new GUI_DB_EDITOR or raises the existing
%      singleton*.
%
%      H = GUI_DB_EDITOR returns the handle to a new GUI_DB_EDITOR or the handle to
%      the existing singleton*.
%
%      GUI_DB_EDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_DB_EDITOR.M with the given input arguments.
%
%      GUI_DB_EDITOR('Property','Value',...) creates a new GUI_DB_EDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_db_editor_OpeningFcn gets called.  An
%      unrecognized property namestation or invalid value makes property application
%      stop.  All inputs are passed to gui_db_editor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_db_editor

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
% Last Modified by GUIDE v2.5 30-Jul-2013 12:56:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @gui_db_editor_OpeningFcn, ...
    'gui_OutputFcn',  @gui_db_editor_OutputFcn, ...
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


% --- Executes just before gui_db_editor is made visible.
function gui_db_editor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_db_editor (see VARARGIN)

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
    % Type the insert or update "Station", "Camera" or "GCP"
    handles.typeInsert = 'Station';
    handles.typeUpdate = '';
    % measurement data
    handles.measurementdata = [];
    handles.sensordata = [];
    set(handles.btimportsensordata,'Visible','on');
    % Calendar
    handles.datebox=[];
    handles.xmlfile = 'path_info.xml';
    % Choose default command line output for gui_db_editor
    handles.output = hObject;
    
    % EditcameraM handles structure
    guidata(hObject, handles);
    
catch e
    disp(e.message)
end

% UIWAIT makes gui_db_editor wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_db_editor_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function SizeXText_Callback(hObject, eventdata, handles)
% hObject    handle to SizeXText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SizeXText as text
%        str2double(get(hObject,'String')) returns contents of SizeXText as a double

try
    %Check size X
    check_camera_data(handles,1)
    sizeX=str2double(get(handles.SizeXText,'String'));
    if isnan(sizeX) || mod(sizeX,1)~=0
        warndlg('The size X must be numeric and integer','Warning');
    end
catch e
    disp(e.message)
end

function SizeYText_Callback(hObject, eventdata, handles)
% hObject    handle to SizeYText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SizeYText as text
%        str2double(get(hObject,'String')) returns contents of SizeYText as a double

try
    %Check size Y
    check_camera_data(handles,1)
    sizeY=str2double(get(handles.SizeYText,'String'));
    if isnan(sizeY) || mod(sizeY,1)~=0
        warndlg('The size Y must be numeric and integer','Warning');
    end
catch e
    disp(e.message)
end

function ReferenceText_Callback(hObject, eventdata, handles)
% hObject    handle to ReferenceText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ReferenceText as text
%        str2double(get(hObject,'String')) returns contents of ReferenceText as a double

try
    %Check reference of the camera
    check_camera_data(handles,1)
    if isempty(get(handles.ReferenceText,'String'))
        warndlg('The reference cannot be empty','Warning');
    elseif size(get(handles.ReferenceText,'String'),2) > 100
        warndlg('The reference must not exceed 100 characters','Warning');
    end
catch e
    disp(e.message)
end


function IdcamText_Callback(hObject, eventdata, handles)
% hObject    handle to IdcamText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of IdcamText as text
%        str2double(get(hObject,'String')) returns contents of IdcamText as a double

try
    %Check the ID of the camera
    check_camera_data(handles,1)
    if isempty(get(handles.IdcamText,'String'))
        warndlg('The ID camera cannot be empty','Warning');
    elseif size(get(handles.IdcamText,'String'),2) > 10
        warndlg('The ID camera must not exceed 10 characters','Warning');
    end
catch e
    disp(e.message)
end

function NamestationText_Callback(hObject, eventdata, handles)
% hObject    handle to NamestationText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NamestationText as text
%        str2double(get(hObject,'String')) returns contents of NamestationText as a double

try
    %Check name of the station
    check_station_data(handles,1)
    if isempty(get(handles.NamestationText,'String'))
        warndlg('The name cannot be empty','Warning');
    elseif size(get(handles.NamestationText,'String'),2) > 45
        warndlg('The station name must not exceed 45 characters','Warning');
    end
catch e
    disp(e.message)
end

function AliasstationText_Callback(hObject, eventdata, handles)
% hObject    handle to AliasstationText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AliasstationText as text
%        str2double(get(hObject,'String')) returns contents of AliasstationText as a double

try
    %Check alias of the station
    check_station_data(handles,1)
    if isempty(get(handles.AliasstationText,'String'))
        warndlg('The alias cannot be empty','Warning');
    elseif size(get(handles.AliasstationText,'String'),2) > 5
        warndlg('The station alias must not exceed 5 characters','Warning');
    end
catch e
    disp(e.message)
end

function ElevationText_Callback(hObject, eventdata, handles)
% hObject    handle to ElevationText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ElevationText as text
%        str2double(get(hObject,'String')) returns contents of ElevationText as a double

try
    %Check Elevation of the station
    check_station_data(handles,1)
    elevation=str2double(get(handles.ElevationText,'String'));
    if isnan(elevation)
        warndlg('The elevation must be numeric','Warning');
    end
catch e
    disp(e.message)
end

function LatText_Callback(hObject, eventdata, handles)
% hObject    handle to LatText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LatText as text
%        str2double(get(hObject,'String')) returns contents of LatText as a double

try
    %Check latitude of the station
    check_station_data(handles,1)
    lat=str2double(get(handles.LatText,'String'));
    if isnan(lat)
        warndlg('The latitude must be numeric','Warning');
    end
catch e
    disp(e.message)
end

function LonText_Callback(hObject, eventdata, handles)
% hObject    handle to LonText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LonText as text
%        str2double(get(hObject,'String')) returns contents of LonText as a double

try
    %Check longitude of the station
    check_station_data(handles,1)
    lon=str2double(get(handles.LonText,'String'));
    if isnan(lon)
        warndlg('The longitude must be numeric','Warning');
    end
catch e
    disp(e.message)
end

function CountryText_Callback(hObject, eventdata, handles)
% hObject    handle to CountryText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CountryText as text
%        str2double(get(hObject,'String')) returns contents of CountryText as a double

try
    %Check Country of the station
    check_station_data(handles,1)
    if isempty(get(handles.CountryText,'String'))
        warndlg('The country cannot be empty','Warning');
    elseif size(get(handles.CountryText,'String'),2) > 45
        warndlg('The country must not exceed 45 characters','Warning');
    end
catch e
    disp(e.message)
end

function StateText_Callback(hObject, eventdata, handles)
% hObject    handle to StateText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StateText as text
%        str2double(get(hObject,'String')) returns contents of StateText as a double

try
    %Check state of the station
    check_station_data(handles,1)
    if isempty(get(handles.StateText,'String'))
        warndlg('The state cannot be empty','Warning');
    elseif size(get(handles.StateText,'String'),2) > 45
        warndlg('The state must not exceed 45 characters','Warning');
    end
catch e
    disp(e.message)
end

function CityText_Callback(hObject, eventdata, handles)
% hObject    handle to CityText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CityText as text
%        str2double(get(hObject,'String')) returns contents of CityText as a double

try
    %Check city of the station
    check_station_data(handles,1)
    if isempty(get(handles.CityText,'String'))
        warndlg('The city cannot be empty','Warning');
    elseif size(get(handles.CityText,'String'),2) > 45
        warndlg('The city must not exceed 45 characters','Warning');
    end
catch e
    disp(e.message)
end

function managerText_Callback(hObject, eventdata, handles)
% hObject    handle to managerText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of managerText as text
%        str2double(get(hObject,'String')) returns contents of managerText as a double

try
    %Check manager of the station
    
    if size(get(handles.managerText,'String'),2) > 45
        warndlg('The manager must not exceed 45 characters','Warning');
        set(handles.InsertButton,'Enable','off')
        set(handles.UpdateButton,'Enable','off')
        set(handles.DeleteButton,'Enable','off')
        return;
    end
    check_station_data(handles,1)
catch e
    disp(e.message)
end

function DescriptionText_Callback(hObject, eventdata, handles)
% hObject    handle to DescriptionText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DescriptionText as text
%        str2double(get(hObject,'String')) returns contents of DescriptionText as a double

try
    %Check description of the station
    
    if size(get(handles.DescriptionText,'String'),2) > 500
        warndlg('The description must not exceed 500 characters','Warning');
        set(handles.InsertButton,'Enable','off')
        set(handles.UpdateButton,'Enable','off')
        set(handles.DeleteButton,'Enable','off')
        return;
    end
    check_station_data(handles,1)
catch e
    disp(e.message)
end

function ZgcpText_Callback(hObject, eventdata, handles)
% hObject    handle to ZgcpText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ZgcpText as text
%        str2double(get(hObject,'String')) returns contents of ZgcpText as a double

try
    %Check Z of the gcp
    check_gcp_data(handles,1)
    z=str2double(get(handles.ZgcpText,'String'));
    if isnan(z)
        warndlg('The z must be numeric','Warning');
    end
catch e
    disp(e.message)
end

function YgcpText_Callback(hObject, eventdata, handles)
% hObject    handle to YgcpText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of YgcpText as text
%        str2double(get(hObject,'String')) returns contents of YgcpText as a double

try
    %Check Y of the gcp
    check_gcp_data(handles,1)
    y=str2double(get(handles.YgcpText,'String'));
    if isnan(y)
        warndlg('The y must be numeric','Warning');
    end
catch e
    disp(e.message)
end

function XgcpText_Callback(hObject, eventdata, handles)
% hObject    handle to XgcpText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of XgcpText as text
%        str2double(get(hObject,'String')) returns contents of XgcpText as a double

try
    %Check X of the gcp
    check_gcp_data(handles,1)
    x=str2double(get(handles.XgcpText,'String'));
    if isnan(x)
        warndlg('The x must be numeric','Warning');
    end
catch e
    disp(e.message)
end

function NamegcpText_Callback(hObject, eventdata, handles)
% hObject    handle to NamegcpText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NamegcpText as text
%        str2double(get(hObject,'String')) returns contents of NamegcpText as a double

try
    %Check name of the gcp
    check_gcp_data(handles,1)
    if isempty(get(handles.NamegcpText,'String'))
        warndlg('The GCP name cannot be empty','Warning');
    elseif size(get(handles.NamegcpText,'String'),2) > 10
        warndlg('The GCP name must not exceed 10 characters','Warning');
    end
catch e
    disp(e.message)
end

function IdgcpText_Callback(hObject, eventdata, handles)
% hObject    handle to IdgcpText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of IdgcpText as text
%        str2double(get(hObject,'String')) returns contents of IdgcpText as a double

try
    %Check ID of the gcp
    check_gcp_data(handles,1)
    idgcp=str2double(get(handles.IdgcpText,'String'));
    if isnan(idgcp)  || mod(idgcp,1)~=0
        warndlg('The ID GCP must be numeric and integer','Warning');
    end
catch e
    disp(e.message)
end

function namesensorText_Callback(hObject, eventdata, handles)
% hObject    handle to namesensorText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of namesensorText as text
%        str2double(get(hObject,'String')) returns contents of namesensorText as a double

try
    %Check reference of the camera
    check_sensor_data(handles,1)
    if isempty(get(handles.namesensorText,'String'))
        warndlg('The sensor name cannot be empty','Warning');
    elseif size(get(handles.namesensorText,'String'),2) > 45
        warndlg('The sensor name must not exceed 45 characters','Warning');
    end
catch e
    disp(e.message)
end

function XsensorText_Callback(hObject, eventdata, handles)
% hObject    handle to XsensorText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of XsensorText as text
%        str2double(get(hObject,'String')) returns contents of XsensorText as a double

try
    %Check X of the sensor
    check_sensor_data(handles,1)
    x=str2double(get(handles.XsensorText,'String'));
    if isnan(x)
        warndlg('The x must be numeric','Warning');
    end
catch e
    disp(e.message)
end

function YsensorText_Callback(hObject, eventdata, handles)
% hObject    handle to YsensorText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of YsensorText as text
%        str2double(get(hObject,'String')) returns contents of YsensorText as a double

try
    %Check Y of the sensor
    check_sensor_data(handles,1)
    y=str2double(get(handles.YsensorText,'String'));
    if isnan(y)
        warndlg('The y must be numeric','Warning');
    end
catch e
    disp(e.message)
end

function ZsensorText_Callback(hObject, eventdata, handles)
% hObject    handle to ZsensorText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ZsensorText as text
%        str2double(get(hObject,'String')) returns contents of ZsensorText as a double

try
    %Check Z of the sensor
    check_sensor_data(handles,1)
    z=str2double(get(handles.ZsensorText,'String'));
    if isnan(z)
        warndlg('The z must be numeric','Warning');
    end
catch e
    disp(e.message)
end

function descriptionsensorText_Callback(hObject, eventdata, handles)
% hObject    handle to descriptionmeasurementtypetext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of descriptionmeasurementtypetext as text
%        str2double(get(hObject,'String')) returns contents of descriptionmeasurementtypetext as a double

try
    %Check description of the sensor
    if size(get(handles.descriptionsensorText,'String'),2) > 500
        warndlg('The description must not exceed 500 characters','Warning');
        set(handles.InsertButton,'Enable','off')
        set(handles.UpdateButton,'Enable','off')
        set(handles.DeleteButton,'Enable','off')
        return;
    end
    check_sensor_data(handles,1)
catch e
    disp(e.message)
end

function paramnameText_Callback(hObject, eventdata, handles)
% hObject    handle to paramnameText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of paramnameText as text
%        str2double(get(hObject,'String')) returns contents of paramnameText as a double

try
    %Check name of the measurement type
    check_measurementtype_data(handles)
    if isempty(get(handles.paramnameText,'String'))
        warndlg('The name cannot be empty','Warning');
    elseif size(get(handles.paramnameText,'String'),2) > 45
        warndlg('The parameter name must not exceed 45 characters','Warning');
    end
catch e
    disp(e.message)
end

% --- Executes on selection change in DatatypeSelect.
function DatatypeSelect_Callback(hObject, eventdata, handles)
% hObject    handle to DatatypeSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns DatatypeSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DatatypeSelect

try
    
    %Check graph type of the measurement type
    check_measurementtype_data(handles)
    if ~isempty(handles.datebox)
        set(handles.UnitzText,'Enable','inactive')
        set(handles.AxiszText,'Enable','inactive')
        handles.datebox.setVisible(false)
        set(handles.timestampmeasurement,'visible','off')
    end
    if get(handles.DatatypeSelect,'value')<=1
        warndlg('must select a graph type','Warning');
    else
        datatype = get_datatype(handles);
        if strcmp(datatype,'matrix')
            set(handles.UnitzText,'Enable','on')
            set(handles.AxiszText,'Enable','on')
            handles = reload_time(handles);
            set(handles.timestampmeasurement,'visible','on')
            guidata(hObject, handles);
        end
    end
catch e
    disp(e.message)
end

% --- Executes on selection change in SensormeasurementSelect.
function SensormeasurementSelect_Callback(hObject, eventdata, handles)
% hObject    handle to SensormeasurementSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SensormeasurementSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SensormeasurementSelect

try
    if get(handles.SensormeasurementSelect,'value')<=1
        warndlg('must select a sensor','Warning');
        set(handles.paramnameText,'String','')
        set(handles.DatatypeSelect,'Value',1);
        set(handles.UnitxText,'String','')
        set(handles.UnityText,'String','')
        set(handles.UnitzText,'String','')
        set(handles.AxisxText,'String','')
        set(handles.AxisyText,'String','')
        set(handles.AxiszText,'String','')
    else
        set(handles.DatatypeSelect,'Value',1);
        if ~isempty(handles.datebox)
            handles.datebox.setVisible(false)
            set(handles.timestampmeasurement,'visible','off')
        end
    end
    %Check sensor of the measurement type
    check_measurementtype_data(handles)
catch e
    disp(e.message)
end

function UnitxText_Callback(hObject, eventdata, handles)
% hObject    handle to UnitxText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of UnitxText as text
%        str2double(get(hObject,'String')) returns contents of UnitxText as a double

try
    %Check unit x of the measurement type
    if size(get(handles.UnitxText,'String'),2) > 10
        warndlg('The unit x must not exceed 10 characters','Warning');
        set(handles.InsertButton,'Enable','off')
        set(handles.UpdateButton,'Enable','off')
        set(handles.DeleteButton,'Enable','off')
        return;
    end
    check_measurementtype_data(handles)
catch e
    disp(e.message)
end

function UnityText_Callback(hObject, eventdata, handles)
% hObject    handle to UnityText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of UnityText as text
%        str2double(get(hObject,'String')) returns contents of UnityText as a double

try
    %Check unit y of the measurement type
    if size(get(handles.UnityText,'String'),2) > 10
        warndlg('The unit y must not exceed 10 characters','Warning');
        set(handles.InsertButton,'Enable','off')
        set(handles.UpdateButton,'Enable','off')
        set(handles.DeleteButton,'Enable','off')
        return;
    end
    check_measurementtype_data(handles)
catch e
    disp(e.message)
end

function UnitzText_Callback(hObject, eventdata, handles)
% hObject    handle to UnitzText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of UnitzText as text
%        str2double(get(hObject,'String')) returns contents of UnitzText as a double

try
    %Check unit z of the measurement type
    if size(get(handles.UnitzText,'String'),2) > 10
        warndlg('The unit z must not exceed 10 characters','Warning');
        set(handles.InsertButton,'Enable','off')
        set(handles.UpdateButton,'Enable','off')
        set(handles.DeleteButton,'Enable','off')
        return;
    end
    check_measurementtype_data(handles)
catch e
    disp(e.message)
end

function AxisxText_Callback(hObject, eventdata, handles)
% hObject    handle to AxisxText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AxisxText as text
%        str2double(get(hObject,'String')) returns contents of AxisxText as a double

try
    %Check axis x of the measurement type
    if size(get(handles.AxisxText,'String'),2) > 35
        warndlg('The axis x must not exceed 35 characters','Warning');
        set(handles.InsertButton,'Enable','off')
        set(handles.UpdateButton,'Enable','off')
        set(handles.DeleteButton,'Enable','off')
        return;
    end
    check_measurementtype_data(handles)
catch e
    disp(e.message)
end

function AxisyText_Callback(hObject, eventdata, handles)
% hObject    handle to AxisyText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AxisyText as text
%        str2double(get(hObject,'String')) returns contents of AxisyText as a double

try
    %Check axis y of the measurement type
    if size(get(handles.AxisyText,'String'),2) > 35
        warndlg('The axis y must not exceed 35 characters','Warning');
        set(handles.InsertButton,'Enable','off')
        set(handles.UpdateButton,'Enable','off')
        set(handles.DeleteButton,'Enable','off')
        return;
    end
    check_measurementtype_data(handles)
catch e
    disp(e.message)
end

function AxiszText_Callback(hObject, eventdata, handles)
% hObject    handle to AxiszText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AxiszText as text
%        str2double(get(hObject,'String')) returns contents of AxiszText as a double

try
    %Check axis z of the measurement type
    if size(get(handles.AxiszText,'String'),2) > 60
        warndlg('The axis z must not exceed 60 characters','Warning');
        set(handles.InsertButton,'Enable','off')
        set(handles.UpdateButton,'Enable','off')
        set(handles.DeleteButton,'Enable','off')
        return;
    end
    check_measurementtype_data(handles)
catch e
    disp(e.message)
end


function DescriptionMeasurementTypeText_Callback(hObject, eventdata, handles)
% hObject    handle to DescriptionMeasurementTypeText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DescriptionMeasurementTypeText as text
%        str2double(get(hObject,'String')) returns contents of DescriptionMeasurementTypeText as a double

try
    %Check description of the station
    if size(get(handles.DescriptionMeasurementTypeText,'String'),2) > 500
        warndlg('The description must not exceed 500 characters','Warning');
        set(handles.InsertButton,'Enable','off')
        set(handles.UpdateButton,'Enable','off')
        set(handles.DeleteButton,'Enable','off')
        return;
    end
    check_measurementtype_data(handles)
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
    
    %reboot connection to the database if necessary
    [handles.conn status] = renew_connection_db(handles.conn);
    
    if status == 1
        return
    end
            
    if(strcmp(handles.typeUpdate,'Station'))
        
        % Enable object of the station
        set(handles.NamestationText,'Enable','on')
        set(handles.AliasstationText,'Enable','on')
        set(handles.ElevationText,'Enable','on')
        set(handles.LatText,'Enable','on')
        set(handles.LonText,'Enable','on')
        set(handles.CountryText,'Enable','on')
        set(handles.StateText,'Enable','on')
        set(handles.CityText,'Enable','on')
        set(handles.managerText,'Enable','on')
        set(handles.DescriptionText,'Enable','on')
        station = get_station(handles);
        if strcmp(station,'New station')
            % Reset some part of the GUI
            set(handles.NamestationText,'String','')
            set(handles.AliasstationText,'String','')
            set(handles.ElevationText,'String','')
            set(handles.LatText,'String','')
            set(handles.LonText,'String','')
            set(handles.CountryText,'String','')
            set(handles.StateText,'String','')
            set(handles.CityText,'String','')
            set(handles.managerText,'String','')
            set(handles.DescriptionText,'String','')
            
            set(handles.Camera1,'visible','off')
            set(handles.CameraSelect,'visible','off')
            set(handles.gcp1,'visible','off')
            set(handles.gcpSelect,'visible','off')
            set(handles.Sensor1,'visible','off')
            set(handles.SensorSelect,'visible','off')
            set(handles.MeasurementType1,'visible','off')
            set(handles.MeasurementtypeSelect,'visible','off')
            set(handles.ImagePathsGeneration,'visible','off')
            
            set(handles.UpdateButton,'visible','off')
            set(handles.InsertButton,'Enable','off')
            
            set(handles.Station,'Title','Station Insert')
            set(handles.Camera,'visible','off')
            set(handles.gcp,'visible','off')
            set(handles.Sensor,'visible','off')
            set(handles.MeasurementType,'visible','off')
            set(handles.Station,'visible','on')
            set(handles.InsertButton,'visible','on')
            set(handles.DeleteButton,'Enable','off')
            handles.typeInsert = 'Station';
            guidata(hObject, handles);
            
        elseif get(handles.StationSelect,'value')>1
            h=gui_message('Loading from database, this might take a while!',...
                'Loading');
                    
            info_station  = load_station_info(handles.conn, station);
            if ishandle(h)
                delete(h);
            end
            
            if isempty(info_station)
                warndlg('No information was found for this station!', 'Warning');
            else
            
                % Display information of the station
                set(handles.NamestationText,'String',char(info_station(1)))
                set(handles.AliasstationText,'String',char(info_station(2)))
                set(handles.ElevationText,'String',num2str(cell2mat(info_station(3)),17))
                set(handles.LatText,'String',num2str(cell2mat(info_station(4)),17))
                set(handles.LonText,'String',num2str(cell2mat(info_station(5)),17))
                set(handles.CountryText,'String',char(info_station(6)))
                set(handles.StateText,'String',char(info_station(7)))
                set(handles.CityText,'String',char(info_station(8)))
                set(handles.managerText,'String',char(info_station(9)))
                set(handles.DescriptionText,'String',char(info_station(10)))
                set(handles.NamestationText,'Enable','inactive')
                set(handles.AliasstationText,'Enable','inactive')

                set(handles.Station,'Title','Station Update')
                set(handles.Station,'visible','on')
                set(handles.UpdateButton,'visible','on')
                set(handles.UpdateButton,'Enable','off')
                set(handles.DeleteButton,'Enable','on')
            end
        else
            set(handles.DeleteButton,'Enable','off')
            reset_station(handles)
            
        end
    elseif(strcmp(handles.typeUpdate,'Camera'))
        
        reset_camera(handles)
        if get(handles.StationSelect,'value')>1
            % Initialize camera in popup menu
            set(handles.CameraSelect,'Value',1);
            set(handles.CameraSelect,'String',{''});
            
            station = get_station(handles);
            h=gui_message('Loading from database, this might take a while!',...
                'Loading');
            camera = load_cam_station(handles.conn, station);
            if ishandle(h)
                delete(h);
            end
            cameras = cell(0);
            cameras{1, 1}= 'Select the camera';
            cameras{2, 1} = 'New camera';
            j=3;
            for k = 1:length(camera)
                cameras{j, 1}=char(camera(k));
                j=j+1;
            end
            
            set(handles.CameraSelect,'String',cameras);
        else
            set(handles.CameraSelect,'Value',1);
            set(handles.CameraSelect,'String',{''});
        end
    elseif(strcmp(handles.typeUpdate,'GCP'))
        
        reset_gcp(handles)
        if get(handles.StationSelect,'value')>1
            % Initialize GCP in popup menu
            set(handles.gcpSelect,'Value',1);
            set(handles.gcpSelect,'String',{''});
            
            station = get_station(handles);
            h=gui_message('Loading from database, this might take a while!',...
                'Loading');
            gcp = load_gcp_station(handles.conn, station);
            if ishandle(h)
                delete(h);
            end
            gcps = cell(0);
            gcps{1, 1}= 'Select the GCP';
            gcps{2, 1} = 'New GCP';
            gcps{3, 1} = 'Import GCPs';
            gcps{4, 1} = 'Delete all GCPs';
            j=5;
            for k = 1:length(gcp)
                gcps{j, 1}=char(gcp(k));
                j=j+1;
            end
            set(handles.gcpSelect,'String',gcps);
        else
            set(handles.gcpSelect,'Value',1);
            set(handles.gcpSelect,'String',{''});
        end
        
    elseif(strcmp(handles.typeUpdate,'Sensor'))
        reset_sensor(handles)
        if get(handles.StationSelect,'value')>1
            % Initialize sensor in popup menu
            set(handles.SensorSelect,'Value',1);
            set(handles.SensorSelect,'String',{''});
            
            station = get_station(handles);
            h=gui_message('Loading from database, this might take a while!',...
                'Loading');
            sensor = load_sensor_station(handles.conn, station);
            if ishandle(h)
                delete(h);
            end
            sensors = cell(0);
            sensors{1, 1}= 'Select the sensor';
            sensors{2, 1} = 'New sensor';
            j=3;
            for k = 1:length(sensor)
                sensors{j, 1}=char(sensor(k));
                j=j+1;
            end
            
            set(handles.SensorSelect,'String',sensors);
        else
            set(handles.SensorSelect,'Value',1);
            set(handles.SensorSelect,'String',{''});
        end
    elseif(strcmp(handles.typeUpdate,'Measurementtype'))
        reset_measurementtype(handles)
        if get(handles.StationSelect,'value')>1
            % Initialize measurement type in popup menu
            set(handles.MeasurementtypeSelect,'Value',1);
            set(handles.MeasurementtypeSelect,'String',{''});
            
            station = get_station(handles);
            h=gui_message('Loading from database, this might take a while!',...
                'Loading');
            measurementtype = load_measurementtype_station(handles.conn, station);
            if ishandle(h)
                delete(h);
            end
            measurementtypes = cell(0);
            measurementtypes{1, 1}= 'Select the measurement type';
            measurementtypes{2, 1} = 'New measurement type';
            j=3;
            for k = 1:size(measurementtype,1)
                measurementtypes{j, 1}=[char(measurementtype(k,1)) ' - ' char(measurementtype(k,2))];
                j=j+1;
            end
            
            set(handles.MeasurementtypeSelect,'String',measurementtypes);
        else
            set(handles.MeasurementtypeSelect,'Value',1);
            set(handles.MeasurementtypeSelect,'String',{''});
        end
    elseif(strcmp(handles.typeUpdate,'ImagePath'))
        if get(handles.StationSelect,'Value')==1
            % Reset some part of the GUI
            set(handles.saveimagepath,'Enable','off');
            
            set(handles.txtcaptureimages,'String','');
            set(handles.txtresultimages,'String','');
            
        else
            set(handles.saveimagepath,'Enable','on');
            set(handles.txtcaptureimages,'Enable','on');
            set(handles.txtresultimages,'Enable','on');
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
                    set(handles.txtcaptureimages,'String','');
                else                   
                    set(handles.txtcaptureimages,'String',strtrim(val));
                end
                
                val = getNodeVal(paths, 'pathRectified');
                if ~isempty(val)
                    find = strfind(strtrim(val),'http://');
                    
                    if ~isdir(strtrim(val)) && isempty(find)
                        set(handles.txtresultimages,'String','')
                    else
                        parts = regexp(strtrim(val), ['\' filesep station], 'split');
                        set(handles.txtresultimages,'String',char(parts(1)));
                    end
                end

            else
                set(handles.txtcaptureimages,'String','');
                set(handles.txtresultimages,'String','')
                
                
            end
        end
    end
    % Update handles structure
    guidata(hObject, handles);

catch e
    disp(e.message)
end

% --- Executes on selection change in CameraSelect.
function CameraSelect_Callback(hObject, eventdata, handles)
% hObject    handle to CameraSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns CameraSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CameraSelect

try
    % Enable object of the camera
    set(handles.IdcamText,'Enable','on')
    set(handles.ReferenceText,'Enable','on')
    set(handles.SizeXText,'Enable','on')
    set(handles.SizeYText,'Enable','on')
    set(handles.StationcamText,'Enable','on')
    
    camera = get_camera(handles);
    if strcmp(camera,'New camera')
        % Reset some part of the GUI
        set(handles.IdcamText,'String','')
        set(handles.ReferenceText,'String','')
        set(handles.SizeXText,'String','')
        set(handles.SizeYText,'String','')
        set(handles.IdcamText,'Enable','on')
        set(handles.StationcamText,'Enable','inactive')
        set(handles.StationcamText,'String','');
        
        station = get_station(handles);
        set(handles.StationcamText,'String',station);
        
        set(handles.gcp1,'visible','off')
        set(handles.gcpSelect,'visible','off')
        set(handles.Sensor1,'visible','off')
        set(handles.SensorSelect,'visible','off')
        set(handles.MeasurementType1,'visible','off')
        set(handles.ImagePathsGeneration,'visible','off')
        set(handles.MeasurementtypeSelect,'visible','off')
        set(handles.UpdateButton,'visible','off')
        set(handles.InsertButton,'Enable','off')
        
        set(handles.gcp,'visible','off')
        set(handles.Station,'visible','off')
        set(handles.MeasurementType,'visible','off')
        set(handles.Sensor,'visible','off')
        set(handles.Camera,'Title','Camera Insert')
        set(handles.Camera,'visible','on')
        set(handles.InsertButton,'visible','on')
        set(handles.DeleteButton,'Enable','off')
        handles.typeInsert = 'Camera';
        guidata(hObject, handles);
        
    elseif get(handles.CameraSelect,'value')>1
        % Display information of the camera
        station = get_station(handles);
        
        %reboot connection to the database if necessary
        [handles.conn status] = renew_connection_db(handles.conn);

        if status == 1
            return
        end
        
        h=gui_message('Loading from database, this might take a while!',...
            'Loading');
        info_camera  = load_cam_info(handles.conn, station, camera);
        if ishandle(h)
            delete(h);
        end
        
        if isempty(info_camera)
            warndlg('No information was found for this camera!', 'Warning');
        else
        
            set(handles.IdcamText,'String',char(info_camera(1)))
            set(handles.StationcamText,'String',char(info_camera(2)))
            set(handles.ReferenceText,'String',char(info_camera(3)))
            set(handles.SizeXText,'String',num2str(cell2mat(info_camera(4)),17))
            set(handles.SizeYText,'String',num2str(cell2mat(info_camera(5)),17))

            set(handles.IdcamText,'Enable','inactive')
            set(handles.StationcamText,'Enable','inactive')
            set(handles.Camera,'Title','Camera Update')
            set(handles.Camera,'visible','on')
            set(handles.UpdateButton,'visible','on')
            set(handles.UpdateButton,'Enable','off')
            set(handles.DeleteButton,'Enable','on')
        end
        guidata(hObject, handles);
        
    else
        set(handles.DeleteButton,'Enable','off')
        reset_camera(handles)
    end
    
catch e
    disp(e.message)
end

% --- Executes on selection change in gcpSelect.
function gcpSelect_Callback(hObject, eventdata, handles)
% hObject    handle to gcpSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns gcpSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from gcpSelect

try
    % Enable object of the GCP
    set(handles.IdgcpText,'Enable','on')
    set(handles.NamegcpText,'Enable','on')
    set(handles.XgcpText,'Enable','on')
    set(handles.YgcpText,'Enable','on')
    set(handles.ZgcpText,'Enable','on')
    set(handles.StationgcpText,'Enable','on')
    
    gcp = get_gcp(handles);
    if strcmp(gcp,'New GCP')
        % Reset some part of the GUI
        set(handles.IdgcpText,'String','')
        set(handles.NamegcpText,'String','')
        set(handles.XgcpText,'String','')
        set(handles.YgcpText,'String','')
        set(handles.ZgcpText,'String','')
        set(handles.IdgcpText,'Enable','on')
        set(handles.StationgcpText,'Enable','inactive')
        set(handles.StationgcpText,'String','');
        
        station = get_station(handles);
        set(handles.StationgcpText,'String',station);
        
        set(handles.Camera1,'visible','off')
        set(handles.CameraSelect,'visible','off')
        set(handles.Sensor1,'visible','off')
        set(handles.SensorSelect,'visible','off')
        set(handles.MeasurementType1,'visible','off')
        set(handles.MeasurementtypeSelect,'visible','off')
        set(handles.UpdateButton,'visible','off')
        set(handles.InsertButton,'Enable','off')
        set(handles.ImagePathsGeneration,'visible','off')
        
        set(handles.Camera,'visible','off')
        set(handles.Station,'visible','off')
        set(handles.Sensor,'visible','off')
        set(handles.MeasurementType,'visible','off')
        set(handles.gcp,'Title','GCP Insert')
        set(handles.gcp,'visible','on')
        set(handles.InsertButton,'visible','on')
        set(handles.DeleteButton,'Enable','off')
        handles.typeInsert = 'GCP';
        guidata(hObject, handles);
        
    elseif strcmp(gcp,'Import GCPs')
        
        reset_gcp(handles)
        station = get_station(handles);
        set(handles.StationgcpText,'String',station);
        handles.typeInsert = 'GCP';
        set(handles.InsertButton,'visible','on')
        set(handles.UpdateButton,'visible','off')
        set(handles.DeleteButton,'Enable','off')
        % Select path of the file to import
        if ispc
            [filename, pathname] = ...
                uigetfile({'*.xls';'*.xlsx'},'File Selector');
        else
            [filename, pathname] = ...
                uigetfile({'*.xls'},'File Selector');
        end
        if filename ~= 0
            try
                [num txt handles.GCPdata] = xlsread(fullfile(pathname, filename));
                set(handles.InsertButton,'Enable','on')
            catch e
                disp(e.message);
            end
        else
            set(handles.InsertButton,'Enable','off')
        end
        guidata(hObject, handles);
        
    elseif strcmp(gcp,'Delete all GCPs')
        
        reset_gcp(handles)
        station = get_station(handles);
        set(handles.StationgcpText,'String',station);
        handles.typeInsert = 'GCP';
        set(handles.InsertButton,'visible','off')
        set(handles.UpdateButton,'visible','off')
        set(handles.DeleteButton,'Enable','on')
        guidata(hObject, handles);
        
    elseif get(handles.gcpSelect,'value')>1
        % Display information of the GCP
        station = get_station(handles);
        
        %reboot connection to the database if necessary
        [handles.conn status] = renew_connection_db(handles.conn);

        if status == 1
            return
        end
        
        h=gui_message('Loading from database, this might take a while!',...
            'Loading');
        info_gcp  = load_gcp_info(handles.conn, station, gcp);
        if ishandle(h)
            delete(h);
        end
        
        if isempty(info_gcp)
            warndlg('No information was found for this GCP!', 'Warning');
        else
            set(handles.IdgcpText,'String',num2str(cell2mat(info_gcp(1)),17))
            set(handles.StationgcpText,'String',char(info_gcp(2)))
            set(handles.NamegcpText,'String',char(info_gcp(3)))
            set(handles.XgcpText,'String',num2str(cell2mat(info_gcp(4)),17))
            set(handles.YgcpText,'String',num2str(cell2mat(info_gcp(5)),17))
            set(handles.ZgcpText,'String',num2str(cell2mat(info_gcp(6)),17))
            set(handles.IdgcpText,'Enable','inactive')
            set(handles.StationgcpText,'Enable','inactive')

            set(handles.gcp,'Title','GCP Update')
            set(handles.gcp,'visible','on')
            set(handles.UpdateButton,'visible','on')
            set(handles.UpdateButton,'Enable','off')
            set(handles.DeleteButton,'Enable','on')
        end
        % Update handles structure
        guidata(hObject, handles);
    else
        set(handles.DeleteButton,'Enable','off')
        reset_gcp(handles)
    end
    
catch e
    disp(e.message)
end

% --- Executes on selection change in SensorSelect.
function SensorSelect_Callback(hObject, eventdata, handles)
% hObject    handle to SensorSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SensorSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SensorSelect

try
    % Enable object of the sensor
    set(handles.namesensorText,'Enable','on')
    set(handles.stationsensorText,'Enable','on')
    set(handles.descriptionsensorText,'Enable','on')
    set(handles.XsensorText,'Enable','on')
    set(handles.YsensorText,'Enable','on')
    set(handles.ZsensorText,'Enable','on')
    
    sensor = get_sensor(handles);
    if strcmp(sensor,'New sensor')
        % Reset some part of the GUI
        set(handles.namesensorText,'String','')
        set(handles.stationsensorText,'String','')
        set(handles.descriptionsensorText,'String','')
        set(handles.XsensorText,'String','')
        set(handles.YsensorText,'String','')
        set(handles.ZsensorText,'String','')
        set(handles.stationsensorText,'Enable','inactive')
        set(handles.sensorvirtualYes,'Value',0)
        set(handles.sensorvirtualNo,'Value',1)
        
        station = get_station(handles);
        set(handles.stationsensorText,'String',station);
        
        set(handles.gcp1,'visible','off')
        set(handles.gcpSelect,'visible','off')
        set(handles.Camera1,'visible','off')
        set(handles.CameraSelect,'visible','off')
        set(handles.MeasurementType1,'visible','off')
        set(handles.MeasurementtypeSelect,'visible','off')
        set(handles.UpdateButton,'visible','off')
        set(handles.InsertButton,'Enable','off')
        set(handles.ImagePathsGeneration,'visible','off')
        
        set(handles.gcp,'visible','off')
        set(handles.Station,'visible','off')
        set(handles.Camera,'visible','off')
        set(handles.MeasurementType,'visible','off')
        set(handles.Sensor,'Title','Sensor Insert')
        set(handles.Sensor,'visible','on')
        set(handles.InsertButton,'visible','on')
        set(handles.DeleteButton,'Enable','off')
        handles.typeInsert = 'Sensor';
        guidata(hObject, handles);
        
    elseif get(handles.SensorSelect,'value')>1
        % Display information of the sensor
        station = get_station(handles);
        
        %reboot connection to the database if necessary
        [handles.conn status] = renew_connection_db(handles.conn);

        if status == 1
            return
        end
        
        h=gui_message('Loading from database, this might take a while!',...
            'Loading');
        info_sensor  = load_sensor_info(handles.conn, station, sensor);
        if ishandle(h)
            delete(h);
        end
        
        if isempty(info_sensor)
            warndlg('No information was found for this sensor!', 'Warning');
        else
        
            set(handles.namesensorText,'Enable','inactive')
            set(handles.stationsensorText,'Enable','inactive')
            set(handles.namesensorText,'String',char(info_sensor(1)))
            set(handles.stationsensorText,'String',char(info_sensor(2)))
            set(handles.XsensorText,'String',num2str(cell2mat(info_sensor(3))))
            set(handles.YsensorText,'String',num2str(cell2mat(info_sensor(4))))
            set(handles.ZsensorText,'String',num2str(cell2mat(info_sensor(5))))
            virtualYN = cell2mat(info_sensor(6));
            set(handles.sensorvirtualYes, 'Value', virtualYN)
            set(handles.sensorvirtualNo, 'Value', 1 - virtualYN)
            set(handles.descriptionsensorText,'String',char(info_sensor(7)))

            set(handles.Sensor,'Title','Sensor Update')
            set(handles.Sensor,'visible','on')
            set(handles.UpdateButton,'visible','on')
            set(handles.UpdateButton,'Enable','off')
            set(handles.DeleteButton,'Enable','on')
        end
        % Update handles structure
        guidata(hObject, handles);
    else
        set(handles.DeleteButton,'Enable','off')
        reset_sensor(handles)
    end
    
catch e
    disp(e.message)
end

% --- Executes on selection change in MeasurementtypeSelect.
function MeasurementtypeSelect_Callback(hObject, eventdata, handles)
% hObject    handle to MeasurementtypeSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MeasurementtypeSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MeasurementtypeSelect

try
    % Enable object of the sensor
    set(handles.paramnameText,'Enable','on')
    set(handles.DatatypeSelect,'Enable','on')
    set(handles.SensormeasurementSelect,'Enable','on')
    set(handles.UnitxText,'Enable','on')
    set(handles.UnityText,'Enable','on')
    set(handles.UnitzText,'Enable','inactive')
    set(handles.AxisxText,'Enable','on')
    set(handles.AxisyText,'Enable','on')
    set(handles.AxiszText,'Enable','inactive')
    set(handles.DescriptionMeasurementTypeText,'Enable','on')
    set(handles.ImportData,'Enable','on')
    
    measurementtype = get_measurementtype(handles);
    
    %reboot connection to the database if necessary
    [handles.conn status] = renew_connection_db(handles.conn);
    
    if status == 1
        return
    end
    
    if strcmp(measurementtype,'New measurement type')
        % measurement data
        handles.measurementdata=[];
        % Reset some part of the GUI
        set(handles.paramnameText,'String','')
        set(handles.UnitxText,'String','')
        set(handles.UnityText,'String','')
        set(handles.UnitzText,'String','')
        set(handles.AxisxText,'String','')
        set(handles.AxisyText,'String','')
        set(handles.AxiszText,'String','')
        set(handles.DescriptionMeasurementTypeText,'String','')
        set(handles.DatatypeSelect,'Value',1);
        set(handles.DatatypeSelect,'String',{'Selection data type','time series', 'matrix'});
        set(handles.SensormeasurementSelect,'Value',1);
        set(handles.SensormeasurementSelect,'String',{''});
        station = get_station(handles);
        h=gui_message('Loading from database, this might take a while!',...
            'Loading');
        sensor = load_sensor_station(handles.conn, station);
        if ishandle(h)
            delete(h);
        end
        sensors = cell(0);
        sensors{1, 1}= 'Select the sensor';
        j=2;
        for k = 1:length(sensor)
            sensors{j, 1}=char(sensor(k));
            j=j+1;
        end
        
        set(handles.SensormeasurementSelect,'String',sensors);
        
        set(handles.gcp1,'visible','off')
        set(handles.gcpSelect,'visible','off')
        set(handles.Camera1,'visible','off')
        set(handles.CameraSelect,'visible','off')
        set(handles.Sensor1,'visible','off')
        set(handles.SensorSelect,'visible','off')
        set(handles.UpdateButton,'visible','off')
        set(handles.InsertButton,'Enable','off')
        
        set(handles.gcp,'visible','off')
        set(handles.Station,'visible','off')
        set(handles.Camera,'visible','off')
        set(handles.Sensor,'visible','off')
        set(handles.MeasurementType,'Title','Measurement Type Insert')
        set(handles.MeasurementType,'visible','on')
        set(handles.InsertButton,'visible','on')
        set(handles.DeleteButton,'Enable','off')
        handles.typeInsert = 'Measurementtype';
        handles.insertMeasurement = true;
        guidata(hObject, handles);
    elseif get(handles.MeasurementtypeSelect,'value')>1
        % measurement data
        handles.measurementdata=[];
        % Display information of the sensor
        station = get_station(handles);
        h=gui_message('Loading from database, this might take a while!',...
            'Loading');
        parts = regexp(measurementtype, '\ - ', 'split');
        info_measurementtype  = load_measurementtype_info(handles.conn, station, char(parts(1)), char(parts(2)));
        if ishandle(h)
            delete(h);
        end
        
        if isempty(info_measurementtype)
            warndlg('No information was found for this measurement type!', 'Warning');
        else
            set(handles.DatatypeSelect,'Value',1);
            set(handles.DatatypeSelect,'String',{''});
            set(handles.SensormeasurementSelect,'Value',1);
            set(handles.SensormeasurementSelect,'String',{''});
            set(handles.paramnameText,'Enable','inactive')
            set(handles.DatatypeSelect,'Enable','inactive')
            set(handles.SensormeasurementSelect,'Enable','inactive')
            set(handles.paramnameText,'String',char(info_measurementtype(1,1)))
            if strcmpi(char(info_measurementtype(1,2)),'series')
                DatatypeSelect = 'time series';
            elseif strcmpi(char(info_measurementtype(1,2)),'matrix')
                DatatypeSelect = 'matrix';
            end
            set(handles.DatatypeSelect,'String',{DatatypeSelect})
            set(handles.SensormeasurementSelect,'String',{char(info_measurementtype(1,3))})
            set(handles.UnitxText,'String',char(info_measurementtype(1,4)))
            set(handles.UnityText,'String',char(info_measurementtype(1,5)))
            set(handles.AxisxText,'String',char(info_measurementtype(1,7)))
            set(handles.AxisyText,'String',char(info_measurementtype(1,8)))
            set(handles.DescriptionMeasurementTypeText,'String',char(info_measurementtype(1,10)))

            datatype = get_datatype(handles);
            if strcmp(datatype,'matrix')
                handles = reload_time(handles);
                set(handles.timestampmeasurement,'visible','on')
                set(handles.UnitzText,'Enable','on')
                set(handles.AxiszText,'Enable','on')
                set(handles.UnitzText,'String',char(info_measurementtype(1,6)))
                set(handles.AxiszText,'String',char(info_measurementtype(1,9)))
                guidata(hObject, handles);
            else
                if ~isempty(handles.datebox)
                    handles.datebox.setVisible(false)
                    set(handles.timestampmeasurement,'visible','off')
                end
                set(handles.UnitzText,'String','')
                set(handles.AxiszText,'String','')
            end

            set(handles.MeasurementType,'Title','Measurement Type Update')
            set(handles.MeasurementType,'visible','on')
            set(handles.UpdateButton,'visible','on')
            set(handles.UpdateButton,'Enable','off')
            set(handles.DeleteButton,'Enable','on')
            handles.insertMeasurement = false;
        end
    else
        set(handles.DeleteButton,'Enable','off')
        reset_measurementtype(handles)
    end
    guidata(hObject, handles);
    
catch e
    disp(e.message)
end

% --------------------------------------------------------------------
function EditstationM_Callback(hObject, eventdata, handles)
% hObject    handle to EditstationM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    set(handles.EditcameraM,'Enable','off')
    set(handles.EditgcpM,'Enable','off')
    set(handles.EditsensorM,'Enable','off')
    set(handles.EditmeasurementtypeM,'Enable','off')
    set(handles.EditGenerateImagePathsM,'Enable','off')
    
    reset_label(handles)
    
    %reboot connection to the database if necessary
    [handles.conn status] = renew_connection_db(handles.conn);
    
    if status == 1
        return
    end
    
    h=gui_message('Loading from database, this might take a while!',...
        'Loading');
    % Initialize stations in popup menu
    station=load_station(handles.conn);
    if ishandle(h)
        delete(h);
    end
    stations = cell(0);
    stations{1, 1}= 'Select the station';
    stations{2, 1} = 'New station';
    j=3;
    for k = 1:length(station)
        stations{j, 1}=char(station(k));
        j=j+1;
    end
    set(handles.StationSelect,'String',stations);
    
    reset_station(handles)
    set(handles.Station,'Visible','on')
    set(handles.DeleteButton,'visible','on')
    
    % Not display the other options, differents to the station
    set(handles.Camera1,'visible','off')
    set(handles.CameraSelect,'visible','off')
    set(handles.gcp1,'visible','off')
    set(handles.gcpSelect,'visible','off')
    set(handles.Sensor1,'visible','off')
    set(handles.SensorSelect,'visible','off')
    set(handles.MeasurementType1,'visible','off')
    set(handles.MeasurementtypeSelect,'visible','off')
    set(handles.ImagePathsGeneration,'visible','off')
    set(handles.Station1,'visible','on')
    set(handles.StationSelect,'visible','on')
    handles.typeUpdate = 'Station';
    
    
    set(handles.EditcameraM,'Enable','on')
    set(handles.EditgcpM,'Enable','on')
    set(handles.EditsensorM,'Enable','on')
    set(handles.EditmeasurementtypeM,'Enable','on')
    set(handles.EditGenerateImagePathsM,'Enable','on')
    
    guidata(hObject, handles);
    
catch e
    disp(e.message)
end

% --------------------------------------------------------------------
function EditcameraM_Callback(hObject, eventdata, handles)
% hObject    handle to EditcameraM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    set(handles.EditstationM,'Enable','off')    
    set(handles.EditgcpM,'Enable','off')
    set(handles.EditsensorM,'Enable','off')
    set(handles.EditmeasurementtypeM,'Enable','off')
    set(handles.EditGenerateImagePathsM,'Enable','off')
    
    reset_label(handles)
    set(handles.CameraSelect,'Value',1);
    set(handles.CameraSelect,'String',{''});
    % Initialize stations in popup menu
    
    %reboot connection to the database if necessary
    [handles.conn status] = renew_connection_db(handles.conn);
    
    if status == 1
        return
    end
    
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
    
    reset_camera(handles)
    set(handles.Camera,'visible','on')
    set(handles.DeleteButton,'visible','on')
    % Not display the other options, differents to the camera
    set(handles.gcp1,'visible','off')
    set(handles.gcpSelect,'visible','off')
    set(handles.Sensor1,'visible','off')
    set(handles.SensorSelect,'visible','off')
    set(handles.MeasurementType1,'visible','off')
    set(handles.MeasurementtypeSelect,'visible','off')
    set(handles.ImagePathsGeneration,'visible','off')
    set(handles.Station1,'visible','on')
    set(handles.StationSelect,'visible','on')
    set(handles.Camera1,'visible','on')
    set(handles.CameraSelect,'visible','on')
    handles.typeUpdate = 'Camera';
    
    set(handles.EditstationM,'Enable','on')
    set(handles.EditgcpM,'Enable','on')
    set(handles.EditsensorM,'Enable','on')
    set(handles.EditmeasurementtypeM,'Enable','on')
    set(handles.EditGenerateImagePathsM,'Enable','on')
    
    guidata(hObject, handles);
    
catch e
    disp(e.message)
end

% --------------------------------------------------------------------
function EditgcpM_Callback(hObject, eventdata, handles)
% hObject    handle to EditgcpM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    set(handles.EditstationM,'Enable','off')    
    set(handles.EditcameraM,'Enable','off')
    set(handles.EditsensorM,'Enable','off')
    set(handles.EditmeasurementtypeM,'Enable','off')
    set(handles.EditGenerateImagePathsM,'Enable','off')
    
    reset_label(handles)
    set(handles.gcpSelect,'Value',1);
    set(handles.gcpSelect,'String',{''});
    % Initialize stations in popup menu
    
    %reboot connection to the database if necessary
    [handles.conn status] = renew_connection_db(handles.conn);
    
    if status == 1
        return
    end
    
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
    
    reset_gcp(handles)
    set(handles.gcp,'visible','on')
    set(handles.DeleteButton,'visible','on')
    % Not display the other options, differents to the GCP
    set(handles.Camera1,'visible','off')
    set(handles.CameraSelect,'visible','off')
    set(handles.Sensor1,'visible','off')
    set(handles.SensorSelect,'visible','off')
    set(handles.MeasurementType1,'visible','off')
    set(handles.MeasurementtypeSelect,'visible','off')
    set(handles.ImagePathsGeneration,'visible','off')
    set(handles.Station1,'visible','on')
    set(handles.StationSelect,'visible','on')
    set(handles.gcp1,'visible','on')
    set(handles.gcpSelect,'visible','on')
    handles.typeUpdate = 'GCP';
    
    set(handles.EditstationM,'Enable','on')
    set(handles.EditcameraM,'Enable','on')
    set(handles.EditsensorM,'Enable','on')
    set(handles.EditmeasurementtypeM,'Enable','on')
    set(handles.EditGenerateImagePathsM,'Enable','on')
    
    guidata(hObject, handles);
    
catch e
    disp(e.message)
end

% --------------------------------------------------------------------
function EditsensorM_Callback(hObject, eventdata, handles)
% hObject    handle to EditsensorM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    set(handles.EditstationM,'Enable','off')    
    set(handles.EditcameraM,'Enable','off')
    set(handles.EditgcpM,'Enable','off')
    set(handles.EditmeasurementtypeM,'Enable','off')
    set(handles.EditGenerateImagePathsM,'Enable','off')
    
    reset_label(handles)
    set(handles.SensorSelect,'Value',1);
    set(handles.SensorSelect,'String',{''});
    
    %reboot connection to the database if necessary
    [handles.conn status] = renew_connection_db(handles.conn);
    
    if status == 1
        return
    end
    
    h=gui_message('Loading from database, this might take a while!',...
        'Loading');
    % Initialize stations in popup menu
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
    
    reset_sensor(handles)
    set(handles.Sensor,'visible','on')
    set(handles.DeleteButton,'visible','on')
    % Not display the other options, differents to the camera
    set(handles.gcp1,'visible','off')
    set(handles.gcpSelect,'visible','off')
    set(handles.Camera1,'visible','off')
    set(handles.CameraSelect,'visible','off')
    set(handles.MeasurementType1,'visible','off')
    set(handles.MeasurementtypeSelect,'visible','off')
    set(handles.ImagePathsGeneration,'visible','off')
    set(handles.Station1,'visible','on')
    set(handles.StationSelect,'visible','on')
    set(handles.Sensor1,'visible','on')
    set(handles.SensorSelect,'visible','on')
    handles.typeUpdate = 'Sensor';
    
    set(handles.EditstationM,'Enable','on')
    set(handles.EditcameraM,'Enable','on')
    set(handles.EditgcpM,'Enable','on')
    set(handles.EditmeasurementtypeM,'Enable','on')
    set(handles.EditGenerateImagePathsM,'Enable','on')
    
    guidata(hObject, handles);
    
catch e
    disp(e.message)
end

% --------------------------------------------------------------------
function EditmeasurementtypeM_Callback(hObject, eventdata, handles)
% hObject    handle to EditmeasurementtypeM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    set(handles.EditstationM,'Enable','off')    
    set(handles.EditcameraM,'Enable','off')
    set(handles.EditgcpM,'Enable','off')
    set(handles.EditsensorM,'Enable','off')
    set(handles.EditGenerateImagePathsM,'Enable','off')
    
    reset_label(handles)
    set(handles.MeasurementtypeSelect,'Value',1);
    set(handles.MeasurementtypeSelect,'String',{''});
    
    %reboot connection to the database if necessary
    [handles.conn status] = renew_connection_db(handles.conn);
    
    if status == 1
        return
    end
    
    h=gui_message('Loading from database, this might take a while!',...
        'Loading');
    % Initialize stations in popup menu
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
    
    reset_measurementtype(handles)
    set(handles.MeasurementType,'visible','on')
    set(handles.DeleteButton,'visible','on')
    % Not display the other options, differents to the measurement type
    set(handles.gcp1,'visible','off')
    set(handles.gcpSelect,'visible','off')
    set(handles.Camera1,'visible','off')
    set(handles.CameraSelect,'visible','off')
    set(handles.Sensor1,'visible','off')
    set(handles.SensorSelect,'visible','off')
    set(handles.ImagePathsGeneration,'visible','off')
    set(handles.Station1,'visible','on')
    set(handles.StationSelect,'visible','on')
    set(handles.MeasurementType1,'visible','on')
    set(handles.MeasurementtypeSelect,'visible','on')
    handles.typeUpdate = 'Measurementtype';
    
    set(handles.EditstationM,'Enable','on')
    set(handles.EditcameraM,'Enable','on')
    set(handles.EditgcpM,'Enable','on')
    set(handles.EditsensorM,'Enable','on')
    set(handles.EditGenerateImagePathsM,'Enable','on')
    
    guidata(hObject, handles);
    
catch e
    disp(e.message)
end

% --------------------------------------------------------------------
function EditGenerateImagePathsM_Callback(hObject, eventdata, handles)
% hObject    handle to EditGenerateImagePathsM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    set(handles.EditstationM,'Enable','off')    
    set(handles.EditcameraM,'Enable','off')
    set(handles.EditgcpM,'Enable','off')
    set(handles.EditsensorM,'Enable','off')
    set(handles.EditmeasurementtypeM,'Enable','off')
    
    reset_label(handles)
    
    %reboot connection to the database if necessary
    [handles.conn status] = renew_connection_db(handles.conn);
    
    if status == 1
        return
    end
    
    h=gui_message('Loading from database, this might take a while!',...
        'Loading');
    % Initialize stations in popup menu
    station=load_station(handles.conn);
    if ishandle(h)
        delete(h);
    end
    stations = cell(0);
    stations{1, 1}= 'Select the station';
    stations{2, 1} = 'New station';
    j=3;
    for k = 1:length(station)
        stations{j, 1}=char(station(k));
        j=j+1;
    end
    set(handles.StationSelect,'String',stations);
    reset_paths(handles)
    
    set(handles.ImagePathsGeneration,'visible','on')
    % Not display the other options, differents to the measurement type
    set(handles.MeasurementType,'visible','off')
    set(handles.gcp1,'visible','off')
    set(handles.gcpSelect,'visible','off')
    set(handles.Camera1,'visible','off')
    set(handles.CameraSelect,'visible','off')
    set(handles.Sensor1,'visible','off')
    set(handles.SensorSelect,'visible','off')
    set(handles.Station1,'visible','on')
    set(handles.StationSelect,'visible','on')
    set(handles.MeasurementType1,'visible','off')
    set(handles.MeasurementtypeSelect,'visible','off')
    set(handles.DeleteButton,'visible','off')
    handles.typeUpdate = 'ImagePath';
    
    set(handles.EditstationM,'Enable','on')
    set(handles.EditcameraM,'Enable','on')
    set(handles.EditgcpM,'Enable','on')
    set(handles.EditsensorM,'Enable','on')
    set(handles.EditmeasurementtypeM,'Enable','on')
    
    guidata(hObject, handles);
catch e
    disp(e.message)
end


% --- Executes on button press in InsertButton.
function InsertButton_Callback(hObject, eventdata, handles)
% hObject    handle to InsertButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    %reboot connection to the database if necessary
    [handles.conn status] = renew_connection_db(handles.conn);
    
    if status == 1
        return
    end
    if(strcmp(handles.typeInsert,'Station'))
        
        action=questdlg('Are you sure you want to insert information into the database?','Insert','No');
        if strcmp(action,'Yes')
            % Get information
            elevation=str2double(get(handles.ElevationText,'String'));
            lat=str2double(get(handles.LatText,'String'));
            lon=str2double(get(handles.LonText,'String'));
                       
            h=gui_message('Inserting in database, this might take a while!',...
                'Inserting');
            % Insert station into to database
            status = insert_station(handles.conn, get(handles.NamestationText,'String'), ...
                get(handles.AliasstationText,'String'), ...
                elevation, lat, lon, get(handles.CountryText,'String'), ...
                get(handles.StateText,'String'), get(handles.CityText,'String'), ...
                'responsible', get(handles.managerText,'String'), ...
                'description', get(handles.DescriptionText,'String'));
            % Add path of the station at the file with the paths
            if exist('path_info.xml', 'file')
                add_paths('path_info.xml',get(handles.NamestationText,'String'))
            end
            if ishandle(h)
                delete(h);
            end
            if status ==0
                createViews(handles.conn, get(handles.NamestationText,'String'));
                
                %%%%%%%%% INSERT DEFAULT IMAGE TYPES
                insert_imagetype(handles.conn, 'Snap', get(handles.NamestationText,'String'));
                insert_imagetype(handles.conn, 'Timex', get(handles.NamestationText,'String'));
                insert_imagetype(handles.conn, 'Var', get(handles.NamestationText,'String'));
                warndlg('Insert successful','Successful');
            else
                warndlg('Insert unsuccessful','Unsuccessful');
            end
            
            % Initialize stations in popup menu
            set(handles.StationSelect,'Value',1);
            set(handles.StationSelect,'String',{''});
            h=gui_message('Loading from database, this might take a while!',...
                'Loading');
            station=load_station(handles.conn);
            if ishandle(h)
                delete(h);
            end
            stations = cell(0);
            stations{1, 1}= 'Select the station';
            stations{2, 1} = 'New station';
            j=3;
            for k = 1:length(station)
                stations{j, 1}=char(station(k));
                j=j+1;
            end
            set(handles.StationSelect,'String',stations);
            set(handles.Station,'Visible','on')
        end
        
    elseif(strcmp(handles.typeInsert,'Camera'))
        
        action=questdlg('Are you sure you want to insert information into the database?','Insert','No');
        if strcmp(action,'Yes')
            % Get information
            id=get(handles.IdcamText,'String');
            sizeX=str2double(get(handles.SizeXText,'String'));
            sizeY=str2double(get(handles.SizeYText,'String'));
            station=get(handles.StationcamText,'String');
            reference=get(handles.ReferenceText,'String');
            h=gui_message('Inserting in database, this might take a while!',...
                'Inserting');
            % Insert camera into to database
            status = insert_camera(handles.conn, id, station, reference, sizeX, sizeY);
            if ishandle(h)
                delete(h);
            end
            if status ==0
                warndlg('Insert successful','Successful');
            else
                warndlg('Insert unsuccessful','Unsuccessful');
            end
            
            if get(handles.StationSelect,'value')>1
                % Initialize camera in popup menu
                set(handles.CameraSelect,'Value',1);
                set(handles.CameraSelect,'String',{''});
                
                station = get_station(handles);
                h=gui_message('Loading from database, this might take a while!',...
                    'Loading');
                camera = load_cam_station(handles.conn, station);
                if ishandle(h)
                    delete(h);
                end
                cameras = cell(0);
                cameras{1, 1}= 'Select the camera';
                cameras{2, 1} = 'New camera';
                j=3;
                for k = 1:length(camera)
                    cameras{j, 1}=char(camera(k));
                    j=j+1;
                end
                
                set(handles.CameraSelect,'String',cameras);
            else
                set(handles.CameraSelect,'Value',1);
                set(handles.CameraSelect,'String',{''});
            end
        end
        
    elseif(strcmp(handles.typeInsert,'GCP'))
        action=questdlg('Are you sure you want to insert information into the database?','Insert','No');
        if strcmp(action,'Yes')
            gcp = get_gcp(handles);
            station = get_station(handles);
            if strcmp(gcp,'Import GCPs')
                try
                    h=gui_message('Inserting in database, this might take a while!',...
                        'Inserting');
                    for i=1:size(handles.GCPdata,1)
                        if isnan(cell2mat(handles.GCPdata(i,1)))
                            continue
                        end
                        status(i)=insert_gcp(handles.conn, cell2mat(handles.GCPdata(i,1)), station, ...
                            char(handles.GCPdata(i,2)), cell2mat(handles.GCPdata(i,3)), ...
                            cell2mat(handles.GCPdata(i,4)), cell2mat(handles.GCPdata(i,5)));
                    end
                    if ishandle(h)
                        delete(h);
                    end
                    Successful=find(status==0);
                    warndlg([mat2str(size(Successful,2)) ' Inserts successful'],'Successful');
                catch e
                    warndlg('The file does not have the appropriate structure. Refer to the documentation.','Error');
                end
            else
                % Get information
                idgcp=str2double(get(handles.IdgcpText,'String'));
                x=str2double(get(handles.XgcpText,'String'));
                y=str2double(get(handles.YgcpText,'String'));
                z=str2double(get(handles.ZgcpText,'String'));
                h=gui_message('Inserting in database, this might take a while!',...
                    'Inserting');
                % Insert GCP into to database
                status = insert_gcp(handles.conn, idgcp, station, get(handles.NamegcpText,'String'), x, y, z);
                if ishandle(h)
                    delete(h);
                end
                if status ==0
                    warndlg('Insert successful','Successful');
                else
                    warndlg('Insert unsuccessful','Unsuccessful');
                end
                
            end
            if get(handles.StationSelect,'value')>1
                % Initialize GCP in popup menu
                set(handles.gcpSelect,'Value',1);
                set(handles.gcpSelect,'String',{''});
                
                station = get_station(handles);
                h=gui_message('Loading from database, this might take a while!',...
                    'Loading');
                gcp = load_gcp_station(handles.conn, station);
                if ishandle(h)
                    delete(h);
                end
                gcps = cell(0);
                gcps{1, 1}= 'Select the GCP';
                gcps{2, 1} = 'New GCP';
                gcps{3, 1} = 'Import GCPs';
                gcps{4, 1} = 'Delete all GCPs';
                j=5;
                for k = 1:length(gcp)
                    gcps{j, 1}=char(gcp(k));
                    j=j+1;
                end
                set(handles.gcpSelect,'String',gcps);
            else
                set(handles.gcpSelect,'Value',1);
                set(handles.gcpSelect,'String',{''});
            end
        end
    elseif(strcmp(handles.typeInsert,'Sensor'))
        
        action=questdlg('Are you sure you want to insert information into the database?','Insert','No');
        if strcmp(action,'Yes')
            % Get information
            name=get(handles.namesensorText,'String');
            station=get(handles.stationsensorText,'String');
            x=str2double(get(handles.XsensorText,'String'));
            y=str2double(get(handles.YsensorText,'String'));
            z=str2double(get(handles.ZsensorText,'String'));
            description=get(handles.descriptionsensorText,'String');
            
            if get(handles.sensorvirtualYes,'Value') == 1
                isvirtual = 1;
            else
                isvirtual = 0;
            end
            h=gui_message('Inserting in database, this might take a while!',...
                'Inserting');
            % Insert camera into to database
            status = insert_sensor(handles.conn, name, station, x, y, z, isvirtual, 'description', description);
            if ishandle(h)
                delete(h);
            end
            if status ==0
                warndlg('Insert successful','Successful');
                
                if ~isempty(handles.sensordata)
                    h=gui_message('Inserting in database, this might take a while!',...
                        'Inserting');
                    
                    dataall = handles.sensordata.data;
                    textdata = handles.sensordata.textdata;
                    date = datenum(dataall(:,1), dataall(:,2), dataall(:,3), ...
                        dataall(:,4), dataall(:,5), dataall(:,6));
                    for i = 7:length(textdata)
                        parts = regexp(char(textdata(i)), '\(', 'split');
                        paramname = char(parts(1));
                        unity1 = char(parts(2));
                        unity = unity1(1:end-1);
                        
                        status2 = insert_measurementtype(handles.conn, paramname,'series', ...
                            name, station, 'unity',unity);
                        if status2 ==0
                            if ~isempty(dataall(:,i))
                                idmeasurementtype  = load_idmeasurementtype(handles.conn, station, paramname, name);
                                idmeasurementtype = cell2mat(idmeasurementtype);
                                % Insert measurement into to database
                                try
                                    data = [];
                                    data = date;
                                    data(:,2) = dataall(:,i);
                                    status3 = insert_measurement(handles.conn, idmeasurementtype, ...
                                        data, 'series', station);
                                    
                                catch e
                                    warndlg('The file does not have the appropriate structure. Refer to the documentation.','Error');
                                end
                                
                                if status3 ==0
                                    warndlg('Insert data successful','Successful');
                                else
                                    warndlg('Insert data unsuccessful','Unsuccessful');
                                end
                                
                            end
                            warndlg('Insert measurement type successful','Successful');
                        else
                            warndlg('Insert measurement type unsuccessful','Unsuccessful');
                        end
                    end
                    if ishandle(h)
                        delete(h);
                    end
                end
                
            else
                warndlg('Insert unsuccessful','Unsuccessful');
            end
            
            if get(handles.StationSelect,'value')>1
                % Initialize camera in popup menu
                set(handles.SensorSelect,'Value',1);
                set(handles.SensorSelect,'String',{''});
                
                station = get_station(handles);
                h=gui_message('Loading from database, this might take a while!',...
                    'Loading');
                sensor = load_sensor_station(handles.conn, station);
                if ishandle(h)
                    delete(h);
                end
                sensors = cell(0);
                sensors{1, 1}= 'Select the sensor';
                sensors{2, 1} = 'New sensor';
                j=3;
                for k = 1:length(sensor)
                    sensors{j, 1}=char(sensor(k));
                    j=j+1;
                end
                
                set(handles.SensorSelect,'String',sensors);
            else
                set(handles.SensorSelect,'Value',1);
                set(handles.SensorSelect,'String',{''});
            end
        end
    elseif(strcmp(handles.typeInsert,'Measurementtype'))
        
        action=questdlg('Are you sure you want to insert information into the database?','Insert','No');
        if strcmp(action,'Yes')
            % Get information
            paramname=get(handles.paramnameText,'String');
            datatype = get_datatype(handles);
            sensor = get_sensor_measurementtype(handles);
            unitx=get(handles.UnitxText,'String');
            unity=get(handles.UnityText,'String');
            unitz=get(handles.UnitzText,'String');
            axisx=get(handles.AxisxText,'String');
            axisy=get(handles.AxisyText,'String');
            axisz=get(handles.AxiszText,'String');
            description=get(handles.DescriptionMeasurementTypeText,'String');
            station = get_station(handles);
            h=gui_message('Inserting in database, this might take a while!',...
                'Inserting');
            
            % Insert measurement type into to database
            status = insert_measurementtype(handles.conn, paramname,datatype, ...
                sensor, station, 'unitx',unitx,'unity',unity,'unitz',unitz, ...
                'axisnamex',axisx,'axisnamey',axisy,'axisnamez',axisz,'description',description);
            if status ==0
                if ~isempty(handles.measurementdata)
                    matrix = handles.measurementdata;
                    type  = load_idmeasurementtype(handles.conn, station, paramname, sensor);
                    type = cell2mat(type);
                    % Insert measurement into to database
                    try
                        if strcmp(datatype,'matrix')
                            timestamp=get_timestamp_calendar(handles);
                            status = insert_measurement(handles.conn, type, ...
                                matrix, datatype, station,'timestamp' ,timestamp);
                        else
                            status = insert_measurement(handles.conn, type, ...
                                matrix, datatype, station);
                        end
                    catch e
                        warndlg('The file does not have the appropriate structure. Refer to the documentation.','Error');
                    end
                    
                    if status ==0
                        warndlg('Insert data successful','Successful');
                    else
                        warndlg('Insert data unsuccessful','Unsuccessful');
                    end
                    
                end
                warndlg('Insert measurement type successful','Successful');
            else
                warndlg('Insert measurement type unsuccessful','Unsuccessful');
            end
            if ishandle(h)
                delete(h);
            end
            
            if get(handles.StationSelect,'value')>1
                % Initialize camera in popup menu
                set(handles.MeasurementtypeSelect,'Value',1);
                set(handles.MeasurementtypeSelect,'String',{''});
                
                station = get_station(handles);
                h=gui_message('Loading from database, this might take a while!',...
                    'Loading');
                measurementtype = load_measurementtype_station(handles.conn, station);
                if ishandle(h)
                    delete(h);
                end
                measurementtypes = cell(0);
                measurementtypes{1, 1}= 'Select the measurement type';
                measurementtypes{2, 1} = 'New measurement type';
                j=3;
                for k = 1:size(measurementtype,1)
                    measurementtypes{j, 1}=[char(measurementtype(k,1)) ' - ' char(measurementtype(k,2))];
                    j=j+1;
                end
                
                set(handles.MeasurementtypeSelect,'String',measurementtypes);
            else
                set(handles.MeasurementtypeSelect,'Value',1);
                set(handles.MeasurementtypeSelect,'String',{''});
            end
        end
    end
    % Update handles structure
    guidata(hObject, handles);
catch e
    disp(e.message)
end

% --- Executes on button press in UpdateButton.
function UpdateButton_Callback(hObject, eventdata, handles)
% hObject    handle to UpdateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    %reboot connection to the database if necessary
    [handles.conn status] = renew_connection_db(handles.conn);
    
    if status == 1
        return
    end
    
    if(strcmp(handles.typeUpdate,'Station'))
        action=questdlg('Are you sure you want to update the data?','Update','No');
        if strcmp(action,'Yes')
            % Get information
            elevation=str2double(get(handles.ElevationText,'String'));
            lat=str2double(get(handles.LatText,'String'));
            lon=str2double(get(handles.LonText,'String'));
            h=gui_message('Updating in database, this might take a while!',...
                'Updating');
            % Update station into to database
            status = update_station(handles.conn, get(handles.NamestationText,'String'), ...
                'elevation', elevation, 'lat',lat , 'lon', lon, ...
                'country',get(handles.CountryText,'String'), ...
                'state', get(handles.StateText,'String'), ...
                'city', get(handles.CityText,'String'), ...
                'responsible', get(handles.managerText,'String'), ...
                'description', get(handles.DescriptionText,'String'));
            if ishandle(h)
                delete(h);
            end
            if status ==0
                warndlg('Update successful','Successful');
            else
                warndlg('Update unsuccessful','Unsuccessful');
            end
        end
        
    elseif(strcmp(handles.typeUpdate,'Camera'))
        
        action=questdlg('Are you sure you want to update the data?','Update','No');
        if strcmp(action,'Yes')
            % Get information
            id=get(handles.IdcamText,'String');
            sizeX=str2double(get(handles.SizeXText,'String'));
            sizeY=str2double(get(handles.SizeYText,'String'));
            station=get(handles.StationcamText,'String');
            reference=get(handles.ReferenceText,'String');
            h=gui_message('Updating in database, this might take a while!',...
                'Updating');
            % Update camera into to database
            status = update_camera(handles.conn, id,station, ...
                'reference', reference, ...
                'sizeX', sizeX, ...
                'sizeY', sizeY);
            if ishandle(h)
                delete(h);
            end
            if status ==0
                warndlg('Update successful','Successful');
            else
                warndlg('Update unsuccessful','Unsuccessful');
            end
        end
        
    elseif(strcmp(handles.typeUpdate,'GCP'))
        
        action=questdlg('Are you sure you want to update the data?','Update','No');
        if strcmp(action,'Yes')
            % Get information
            x=str2double(get(handles.XgcpText,'String'));
            y=str2double(get(handles.YgcpText,'String'));
            
            z=str2double(get(handles.ZgcpText,'String'));
            h=gui_message('Updating in database, this might take a while!',...
                'Updating');
            % Update GCP into to database
            status = update_gcp(handles.conn, str2double(get(handles.IdgcpText,'String')), ...
                get(handles.StationgcpText,'String'), 'name', ...
                get(handles.NamegcpText,'String'), 'x', x, 'y', y, 'z', z);
            if ishandle(h)
                delete(h);
            end
            if status ==0
                warndlg('Update successful','Successful');
            else
                warndlg('Update unsuccessful','Unsuccessful');
            end
            if get(handles.StationSelect,'value')>1
                % Initialize GCP in popup menu
                set(handles.gcpSelect,'Value',1);
                set(handles.gcpSelect,'String',{''});
                
                station = get_station(handles);
                h=gui_message('Loading from database, this might take a while!',...
                    'Loading');
                gcp = load_gcp_station(handles.conn, station);
                if ishandle(h)
                    delete(h);
                end
                gcps = cell(0);
                gcps{1, 1}= 'Select the GCP';
                gcps{2, 1} = 'New GCP';
                gcps{3, 1} = 'Import GCPs';
                j=4;
                for k = 1:length(gcp)
                    gcps{j, 1}=char(gcp(k));
                    j=j+1;
                end
                set(handles.gcpSelect,'String',gcps);
            else
                set(handles.gcpSelect,'Value',1);
                set(handles.gcpSelect,'String',{''});
            end
        end
        
    elseif(strcmp(handles.typeUpdate,'Sensor'))
        
        action=questdlg('Are you sure you want to update the data?','Update','No');
        if strcmp(action,'Yes')
            % Get information
            name=get(handles.namesensorText,'String');
            station=get(handles.stationsensorText,'String');
            x=str2double(get(handles.XsensorText,'String'));
            y=str2double(get(handles.YsensorText,'String'));
            z=str2double(get(handles.ZsensorText,'String'));
            description=get(handles.descriptionsensorText,'String');
            if get(handles.sensorvirtualYes,'Value') == 1
                isvirtual = 1;
            else
                isvirtual = 0;
            end
            h=gui_message('Updating in database, this might take a while!',...
                'Updating');
            % Update sensor into to database
            status = update_sensor(handles.conn, name, station, ...
                'x', x, 'y', y, 'z', z, 'isvirtual', isvirtual, 'description', description);
            if ishandle(h)
                delete(h);
            end
            
            if ~isempty(handles.sensordata)
                dataall = handles.sensordata.data;
                textdata = handles.sensordata.textdata;
                date = datenum(dataall(:,1), dataall(:,2), dataall(:,3), ...
                    dataall(:,4), dataall(:,5), dataall(:,6));
                for i = 7:length(textdata)
                    parts = regexp(char(textdata(i)), '\(', 'split');
                    paramname = char(parts(1));
                    idmeasurementtype  = load_idmeasurementtype(handles.conn,station, paramname, name);
                    idmeasurementtype = cell2mat(idmeasurementtype);
                    h=gui_message('Inserting in database, this might take a while!',...
                        'Inserting');
                    % Insert measurement into to database
                    data = [];
                    data = date;
                    data(:,2) = dataall(:,i);
                    status2 = insert_measurement(handles.conn, idmeasurementtype, ...
                        data, 'series', station);
                    
                    if status2 ==0
                        warndlg('Insert data successful','Successful');
                    else
                        warndlg('Insert data unsuccessful','Unsuccessful');
                    end
                    if ishandle(h)
                        delete(h);
                    end
                end
            end
            
            
            
            if status ==0
                warndlg('Update successful','Successful');
            else
                warndlg('Update unsuccessful','Unsuccessful');
            end
        end
        
    elseif(strcmp(handles.typeUpdate,'Measurementtype'))
        
        action=questdlg('Are you sure you want to update the data?','Update','No');
        if strcmp(action,'Yes')
            % Get information
            paramname=get(handles.paramnameText,'String');
            sensor = get_sensor_measurementtype(handles);
            station = get_station(handles);
            datatype = get_datatype(handles);
            unitx=get(handles.UnitxText,'String');
            unity=get(handles.UnityText,'String');
            unitz=get(handles.UnitzText,'String');
            axisx=get(handles.AxisxText,'String');
            axisy=get(handles.AxisyText,'String');
            axisz=get(handles.AxiszText,'String');
            description=get(handles.DescriptionMeasurementTypeText,'String');
            
            h=gui_message('Updating in database, this might take a while!',...
                'Updating');
            % Update measurement type into to database
            status = update_measurementtype(handles.conn, paramname, sensor, station, ...
                'unitx',unitx,'unity',unity,'unitz',unitz, ...
                'axisnamex',axisx,'axisnamey',axisy,'axisnamez',axisz,'description',description);
            if ishandle(h)
                delete(h);
            end
            if ~isempty(handles.measurementdata)
                matrix = handles.measurementdata;
                type  = load_idmeasurementtype(handles.conn, station, paramname, sensor);
                type = cell2mat(type);
                h=gui_message('Inserting in database, this might take a while!',...
                    'Inserting');
                % Insert measurement into to database
                if strcmp(datatype,'matrix')
                    timestamp=get_timestamp_calendar(handles);
                    status = insert_measurement(handles.conn, type, ...
                        matrix, datatype, station,'timestamp' ,timestamp);
                else
                    status = insert_measurement(handles.conn, type, ...
                        matrix, datatype, station);
                end
                if status ==0
                    warndlg('Insert data successful','Successful');
                else
                    warndlg('Insert data unsuccessful','Unsuccessful');
                end
                if ishandle(h)
                    delete(h);
                end
            end
            
            if status ==0
                warndlg('Update successful','Successful');
            else
                warndlg('Update unsuccessful','Unsuccessful');
            end
        end
    end
    
    % Update handles structure
    guidata(hObject, handles);
    
catch e
    disp(e.message)
end

% --- Executes on button press in DeleteButton.
function DeleteButton_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    %reboot connection to the database if necessary
    [handles.conn status] = renew_connection_db(handles.conn);
    
    if status == 1
        return
    end
    
    if(strcmp(handles.typeUpdate,'Station'))
        action=questdlg('Are you sure you want to delete the data?','Delete','No');
        if strcmp(action,'Yes')
            h=gui_message('Deleting in database, this might take a while!',...
                'Deleting');
            % Delete station into to database
            statusI = delete_all_image_station(handles.conn, char(get(handles.NamestationText,'String')));
            
            if statusI ~= 0
                warndlg('There was a problem when trying to delete information on database for Image','Unsuccessful');
            end
            
            statusIT = delete_imagetype(handles.conn, char(get(handles.NamestationText,'String')));
            if statusIT ~= 0
                warndlg('There was a problem when trying to delete information on database for ImageType','Unsuccessful');
            end
            
            statusF = delete_fusion(handles.conn, char(get(handles.NamestationText,'String')));
            if statusF ~= 0
                warndlg('There was a problem when trying to delete information on database for Fusion','Unsuccessful');
            end
            statusS = delete_station(handles.conn, char(get(handles.NamestationText,'String')));
            
            statusV = delete_views(handles.conn, char(get(handles.NamestationText,'String')));  
            
            
            % Delete path of the station at the file with the paths
            if exist('path_info.xml', 'file')
                delete_paths('path_info.xml',char(get(handles.NamestationText,'String')))
            end
            
            if ishandle(h)
                delete(h);
            end
            if statusS == 0 && statusV == 0
                warndlg('Delete successful','Successful');
                reset_station(handles)
                if get(handles.StationSelect,'value')>1
                    % Initialize stations in popup menu
                    set(handles.StationSelect,'Value',1);
                    set(handles.StationSelect,'String',{''});
                    h=gui_message('Loading from database, this might take a while!',...
                        'Loading');
                    station=load_station(handles.conn);
                    if ishandle(h)
                        delete(h);
                    end
                    stations = cell(0);
                    stations{1, 1}= 'Select the station';
                    stations{2, 1} = 'New station';
                    j=3;
                    for k = 1:length(station)
                        stations{j, 1}=char(station(k));
                        j=j+1;
                    end
                    set(handles.StationSelect,'String',stations);
                else
                    set(handles.StationSelect,'Value',1);
                    set(handles.StationSelect,'String',{''});
                end
            else
                warndlg('There was a problem when trying to delete information on database for Station','Unsuccessful');
            end
        end
        
    elseif(strcmp(handles.typeUpdate,'Camera'))
        
        action=questdlg('Are you sure you want to delete the data?','Delete','No');
        if strcmp(action,'Yes')
            h=gui_message('Deleting in database, this might take a while!',...
                'Deleting');
            % Delete camera into to database
            status = delete_camera(handles.conn, get(handles.IdcamText,'String'), ...
                char(get(handles.StationcamText,'String')));
            if ishandle(h)
                delete(h);
            end
            if status ==0
                warndlg('Delete successful','Successful');
                reset_camera(handles)
                if get(handles.StationSelect,'value')>1
                    % Initialize camera in popup menu
                    set(handles.CameraSelect,'Value',1);
                    set(handles.CameraSelect,'String',{''});
                    station = get_station(handles);
                    h=gui_message('Loading from database, this might take a while!',...
                        'Loading');
                    camera = load_cam_station(handles.conn, station);
                    if ishandle(h)
                        delete(h);
                    end
                    cameras = cell(0);
                    cameras{1, 1}= 'Select the camera';
                    cameras{2, 1} = 'New camera';
                    j=3;
                    for k = 1:length(camera)
                        cameras{j, 1}=char(camera(k));
                        j=j+1;
                    end
                    set(handles.CameraSelect,'String',cameras);
                else
                    set(handles.CameraSelect,'Value',1);
                    set(handles.CameraSelect,'String',{''});
                end
            else
                warndlg('Delete unsuccessful','Unsuccessful');
            end
        end
        
    elseif(strcmp(handles.typeUpdate,'GCP'))
        
        action=questdlg('Are you sure you want to delete the data?','Delete','No');
        if strcmp(action,'Yes')
            gcp = get_gcp(handles);
            if strcmp(gcp,'Delete all GCPs')
                station = get_station(handles);
                h=gui_message('Deleting in database, this might take a while!',...
                    'Deleting');
                % Delete GCP into to database
                status = delete_all_gcp(handles.conn, station);
                if ishandle(h)
                    delete(h);
                end
            else
                h=gui_message('Deleting in database, this might take a while!',...
                    'Deleting');
                % Delete GCP into to database
                status = delete_gcp(handles.conn, str2double(get(handles.IdgcpText,'String')),...
                    char(get(handles.StationgcpText,'String')));
                if ishandle(h)
                    delete(h);
                end
            end
            if status ==0
                warndlg('Delete successful','Successful');
                reset_gcp(handles)
                if get(handles.StationSelect,'value')>1
                    % Initialize GCP in popup menu
                    set(handles.gcpSelect,'Value',1);
                    set(handles.gcpSelect,'String',{''});
                    station = get_station(handles);
                    h=gui_message('Loading from database, this might take a while!',...
                        'Loading');
                    gcp = load_gcp_station(handles.conn, station);
                    if ishandle(h)
                        delete(h);
                    end
                    gcps = cell(0);
                    gcps{1, 1}= 'Select the GCP';
                    gcps{2, 1} = 'New GCP';
                    gcps{3, 1} = 'Import GCPs';
                    gcps{4, 1} = 'Delete all GCPs';
                    j=5;
                    for k = 1:length(gcp)
                        gcps{j, 1}=char(gcp(k));
                        j=j+1;
                    end
                    set(handles.gcpSelect,'String',gcps);
                else
                    set(handles.gcpSelect,'Value',1);
                    set(handles.gcpSelect,'String',{''});
                end
            else
                warndlg('Delete unsuccessful','Unsuccessful');
            end
        end
        
    elseif(strcmp(handles.typeUpdate,'Sensor'))
        
        action=questdlg('Are you sure you want to delete the data?','Delete','No');
        if strcmp(action,'Yes')
            h=gui_message('Deleting in database, this might take a while!',...
                'Deleting');
            % Delete camera into to database
            status = delete_sensor(handles.conn, get(handles.namesensorText,'String'), ...
                char(get(handles.stationsensorText,'String')));
            if ishandle(h)
                delete(h);
            end
            if status ==0
                warndlg('Delete successful','Successful');
                reset_sensor(handles)
                if get(handles.StationSelect,'value')>1
                    % Initialize sensor in popup menu
                    set(handles.SensorSelect,'Value',1);
                    set(handles.SensorSelect,'String',{''});
                    station = get_station(handles);
                    h=gui_message('Loading from database, this might take a while!',...
                        'Loading');
                    sensor = load_sensor_station(handles.conn, station);
                    if ishandle(h)
                        delete(h);
                    end
                    sensors = cell(0);
                    sensors{1, 1}= 'Select the sensor';
                    sensors{2, 1} = 'New sensor';
                    j=3;
                    for k = 1:length(sensor)
                        sensors{j, 1}=char(sensor(k));
                        j=j+1;
                    end
                    set(handles.SensorSelect,'String',sensors);
                else
                    set(handles.SensorSelect,'Value',1);
                    set(handles.SensorSelect,'String',{''});
                end
            else
                warndlg('Delete unsuccessful','Unsuccessful');
            end
        end
        
    elseif(strcmp(handles.typeUpdate,'Measurementtype'))
        
        datatype = get_datatype(handles);
        action=questdlg({'Are you sure you want to delete the data?', ...
            ['It removes all ' datatype ' data']},'Delete','No');
        if strcmp(action,'Yes')
            % Get information
            paramname=get(handles.paramnameText,'String');
            sensor = get_sensor_measurementtype(handles);
            station = get_station(handles);
            
            h=gui_message('Deleting in database, this might take a while!',...
                'Deleting');
            % Delete camera into to database
            status = delete_measurementtype(handles.conn, paramname,sensor,station);
            if ishandle(h)
                delete(h);
            end
            if status ==0
                warndlg('Delete successful','Successful');
                reset_measurementtype(handles)
                
                if get(handles.StationSelect,'value')>1
                    % Initialize measurement type in popup menu
                    set(handles.MeasurementtypeSelect,'Value',1);
                    set(handles.MeasurementtypeSelect,'String',{''});
                    
                    station = get_station(handles);
                    h=gui_message('Loading from database, this might take a while!',...
                        'Loading');
                    measurementtype = load_measurementtype_station(handles.conn, station);
                    if ishandle(h)
                        delete(h);
                    end
                    measurementtypes = cell(0);
                    measurementtypes{1, 1}= 'Select the measurement type';
                    measurementtypes{2, 1} = 'New measurement type';
                    j=3;
                    for k = 1:size(measurementtype,1)
                        measurementtypes{j, 1}=[char(measurementtype(k,1)) ' - ' char(measurementtype(k,2))];
                        j=j+1;
                    end
                    
                    set(handles.MeasurementtypeSelect,'String',measurementtypes);
                else
                    set(handles.MeasurementtypeSelect,'Value',1);
                    set(handles.MeasurementtypeSelect,'String',{''});
                end
            else
                warndlg('Delete unsuccessful','Unsuccessful');
            end
        end
    end
    
    % Update handles structure
    guidata(hObject, handles);
    
catch e
    disp(e.message)
end

function check_station_data(handles,call)

try
    
    flag=1;
    % Check name of the station
    if isempty(get(handles.NamestationText,'String')) || size(get(handles.NamestationText,'String'),2) > 45
        set(handles.InsertButton,'Enable','off')
        set(handles.UpdateButton,'Enable','off')
        set(handles.DeleteButton,'Enable','off')
        flag=0;
    end
    % Check alias of the station
    if isempty(get(handles.AliasstationText,'String')) || size(get(handles.AliasstationText,'String'),2) > 5
        set(handles.InsertButton,'Enable','off')
        set(handles.UpdateButton,'Enable','off')
        set(handles.DeleteButton,'Enable','off')
        flag=0;
    end
    % Check elevation of the station
    elevation=str2double(get(handles.ElevationText,'String'));
    if isnan(elevation)
        set(handles.InsertButton,'Enable','off')
        set(handles.UpdateButton,'Enable','off')
        set(handles.DeleteButton,'Enable','off')
        flag=0;
    end
    % Check latitude of the station
    lat=str2double(get(handles.LatText,'String'));
    if isnan(lat)
        set(handles.InsertButton,'Enable','off')
        set(handles.UpdateButton,'Enable','off')
        set(handles.DeleteButton,'Enable','off')
        flag=0;
    end
    % Check longitude of the station
    lon=str2double(get(handles.LonText,'String'));
    if isnan(lon)
        set(handles.InsertButton,'Enable','off')
        set(handles.UpdateButton,'Enable','off')
        set(handles.DeleteButton,'Enable','off')
        flag=0;
    end
    % Check country of the station
    if isempty(get(handles.CountryText,'String')) || size(get(handles.CountryText,'String'),2) > 45
        set(handles.InsertButton,'Enable','off')
        set(handles.UpdateButton,'Enable','off')
        set(handles.DeleteButton,'Enable','off')
        flag=0;
    end
    % Check state of the station
    if isempty(get(handles.StateText,'String')) || size(get(handles.StateText,'String'),2) > 45
        set(handles.InsertButton,'Enable','off')
        set(handles.UpdateButton,'Enable','off')
        set(handles.DeleteButton,'Enable','off')
        flag=0;
    end
    if call == 1
        % Check city of the station
        if isempty(get(handles.CityText,'String')) || size(get(handles.CityText,'String'),2) > 45
            set(handles.InsertButton,'Enable','off')
            set(handles.UpdateButton,'Enable','off')
            set(handles.DeleteButton,'Enable','off')
            flag=0;
        end
    end
    if flag==1
        set(handles.InsertButton,'Enable','on')
        set(handles.UpdateButton,'Enable','on')
        if strcmpi(get(handles.UpdateButton,'Visible'),'on')
            set(handles.DeleteButton,'Enable','on')
        else
            set(handles.DeleteButton,'Enable','off')
        end
    end
    
catch e
    disp(e.message)
end

function check_camera_data(handles,call)

try
    
    flag=1;
    if(strcmp(handles.typeInsert,'Camera'))
        % Check ID of the camera
        if isempty(get(handles.IdcamText,'String')) || size(get(handles.IdcamText,'String'),2) > 10
            set(handles.InsertButton,'Enable','off')
            set(handles.UpdateButton,'Enable','off')
            set(handles.DeleteButton,'Enable','off')
            flag=0;
        end
    end
    % Check reference of the camera
    if isempty(get(handles.ReferenceText,'String')) || size(get(handles.ReferenceText,'String'),2) > 100
        set(handles.InsertButton,'Enable','off')
        set(handles.UpdateButton,'Enable','off')
        set(handles.DeleteButton,'Enable','off')
        flag=0;
    end
    % Check size X of the camera
    sizeX=str2double(get(handles.SizeXText,'String'));
    if isnan(sizeX) || mod(sizeX,1)~=0
        set(handles.InsertButton,'Enable','off')
        set(handles.UpdateButton,'Enable','off')
        set(handles.DeleteButton,'Enable','off')
        flag=0;
    end
    if call == 1
        % Check size Y of the camera
        sizeY=str2double(get(handles.SizeYText,'String'));
        if isnan(sizeY) || mod(sizeY,1)~=0
            set(handles.InsertButton,'Enable','off')
            set(handles.UpdateButton,'Enable','off')
            set(handles.DeleteButton,'Enable','off')
            flag=0;
        end
    end
    
    if flag==1
        set(handles.InsertButton,'Enable','on')
        set(handles.UpdateButton,'Enable','on')
        if strcmpi(get(handles.UpdateButton,'Visible'),'on')
            set(handles.DeleteButton,'Enable','on')
        else
            set(handles.DeleteButton,'Enable','off')
        end
    end
    
catch e
    disp(e.message)
end

function check_gcp_data(handles,call)

try
    
    flag=1;
    if(strcmp(handles.typeInsert,'GCP'))
        % Check ID of the GCP
        idgcp=str2double(get(handles.IdgcpText,'String'));
        if isnan(idgcp)  || mod(idgcp,1)~=0
            set(handles.InsertButton,'Enable','off')
            set(handles.UpdateButton,'Enable','off')
            set(handles.DeleteButton,'Enable','off')
            flag=0;
        end
    end
    % Check name of the GCP
    if isempty(get(handles.NamegcpText,'String')) || size(get(handles.NamegcpText,'String'),2) > 10
        set(handles.InsertButton,'Enable','off')
        set(handles.UpdateButton,'Enable','off')
        set(handles.DeleteButton,'Enable','off')
        flag=0;
    end
    % Check X of the GCP
    x=str2double(get(handles.XgcpText,'String'));
    if isnan(x)
        set(handles.InsertButton,'Enable','off')
        set(handles.UpdateButton,'Enable','off')
        set(handles.DeleteButton,'Enable','off')
        flag=0;
    end
    % Check Y of the GCP
    y=str2double(get(handles.YgcpText,'String'));
    if isnan(y)
        set(handles.InsertButton,'Enable','off')
        set(handles.UpdateButton,'Enable','off')
        set(handles.DeleteButton,'Enable','off')
        flag=0;
    end
    if call == 1
        % Check Z of the GCP
        z=str2double(get(handles.ZgcpText,'String'));
        if isnan(z)
            set(handles.InsertButton,'Enable','off')
            set(handles.UpdateButton,'Enable','off')
            set(handles.DeleteButton,'Enable','off')
            flag=0;
        end
    end
    if flag==1
        set(handles.InsertButton,'Enable','on')
        set(handles.UpdateButton,'Enable','on')
        if strcmpi(get(handles.UpdateButton,'Visible'),'on')
            set(handles.DeleteButton,'Enable','on')
        else
            set(handles.DeleteButton,'Enable','off')
        end
    end
    
catch e
    disp(e.message)
end

function check_sensor_data(handles,call)

try
    
    flag=1;
    
    % Check name of the sensor
    if isempty(get(handles.namesensorText,'String'))
        set(handles.InsertButton,'Enable','off')
        set(handles.UpdateButton,'Enable','off')
        set(handles.DeleteButton,'Enable','off')
        flag=0;
    end
    
    % Check X of the sensor
    x=str2double(get(handles.XsensorText,'String'));
    if isnan(x)
        set(handles.InsertButton,'Enable','off')
        set(handles.UpdateButton,'Enable','off')
        set(handles.DeleteButton,'Enable','off')
        flag=0;
    end
    % Check Y of the sensor
    y=str2double(get(handles.YsensorText,'String'));
    if isnan(y)
        set(handles.InsertButton,'Enable','off')
        set(handles.UpdateButton,'Enable','off')
        set(handles.DeleteButton,'Enable','off')
        flag=0;
    end
    if call == 1
        % Check Z of the sensor
        z=str2double(get(handles.ZsensorText,'String'));
        if isnan(z)
            set(handles.InsertButton,'Enable','off')
            set(handles.UpdateButton,'Enable','off')
            set(handles.DeleteButton,'Enable','off')
            flag=0;
        end
    end
    
    if flag==1
        set(handles.InsertButton,'Enable','on')
        set(handles.UpdateButton,'Enable','on')
        if strcmpi(get(handles.UpdateButton,'Visible'),'on')
            set(handles.DeleteButton,'Enable','on')
        else
            set(handles.DeleteButton,'Enable','off')
        end
    end
    
catch e
    disp(e.message)
end

function check_measurementtype_data(handles)

try
    
    flag=1;
    
    % Check name of the sensor
    if isempty(get(handles.paramnameText,'String')) || size(get(handles.paramnameText,'String'),2) > 45
        set(handles.InsertButton,'Enable','off')
        set(handles.UpdateButton,'Enable','off')
        set(handles.DeleteButton,'Enable','off')
        flag=0;
    end
    
    if get(handles.DatatypeSelect,'value')<=1 && handles.insertMeasurement == true
        set(handles.InsertButton,'Enable','off')
        set(handles.UpdateButton,'Enable','off')
        set(handles.DeleteButton,'Enable','off')
        flag=0;
    end
    
    if get(handles.SensormeasurementSelect,'value')<=1  && handles.insertMeasurement == true
        set(handles.InsertButton,'Enable','off')
        set(handles.UpdateButton,'Enable','off')
        set(handles.DeleteButton,'Enable','off')
        flag=0;
    end
    
    if flag==1
        set(handles.InsertButton,'Enable','on')
        set(handles.UpdateButton,'Enable','on')
        if strcmpi(get(handles.UpdateButton,'Visible'),'on')
            set(handles.DeleteButton,'Enable','on')
        else
            set(handles.DeleteButton,'Enable','off')
        end
    end
    
catch e
    disp(e.message)
end

%Get station
function station = get_station(handles)
try
    value = get(handles.StationSelect, 'Value');
    contents = cellstr(get(handles.StationSelect, 'String'));
    station = contents{value};
catch e
    disp(e.message)
end

%Get camera
function camera = get_camera(handles)
try
    value = get(handles.CameraSelect, 'Value');
    contents = cellstr(get(handles.CameraSelect, 'String'));
    camera = contents{value};
catch e
    disp(e.message)
end

%Get GCP
function gcp = get_gcp(handles)
try
    value = get(handles.gcpSelect, 'Value');
    contents = cellstr(get(handles.gcpSelect, 'String'));
    gcp = contents{value};
catch e
    disp(e.message)
end

%Get sensor
function sensor = get_sensor(handles)
try
    value = get(handles.SensorSelect, 'Value');
    contents = cellstr(get(handles.SensorSelect, 'String'));
    sensor = contents{value};
catch e
    disp(e.message)
end

%Get measurement type
function measurementtype = get_measurementtype(handles)
try
    value = get(handles.MeasurementtypeSelect, 'Value');
    contents = cellstr(get(handles.MeasurementtypeSelect, 'String'));
    measurementtype = contents{value};
catch e
    disp(e.message)
end

%Get measurement type
function datatype = get_datatype(handles)
try
    value = get(handles.DatatypeSelect, 'Value');
    contents = cellstr(get(handles.DatatypeSelect, 'String'));
    
    if strcmpi(contents{value},'time series')
        datatype = 'series';
    elseif strcmpi(contents{value},'matrix')
        datatype = 'matrix';
    end
    
catch e
    disp(e.message)
end

%Get sensor of measurement type
function sensor = get_sensor_measurementtype(handles)
try
    value = get(handles.SensormeasurementSelect, 'Value');
    contents = cellstr(get(handles.SensormeasurementSelect, 'String'));
    sensor = contents{value};
catch e
    disp(e.message)
end

%Reset information of the station
function reset_station(handles)

try
    
    set(handles.NamestationText,'Enable','inactive')
    set(handles.AliasstationText,'Enable','inactive')
    set(handles.ElevationText,'Enable','inactive')
    set(handles.LatText,'Enable','inactive')
    set(handles.LonText,'Enable','inactive')
    set(handles.CountryText,'Enable','inactive')
    set(handles.StateText,'Enable','inactive')
    set(handles.CityText,'Enable','inactive')
    set(handles.managerText,'Enable','inactive')
    set(handles.DescriptionText,'Enable','inactive')
    
    set(handles.NamestationText,'String','')
    set(handles.AliasstationText,'String','')
    set(handles.ElevationText,'String','')
    set(handles.LatText,'String','')
    set(handles.LonText,'String','')
    set(handles.CountryText,'String','')
    set(handles.StateText,'String','')
    set(handles.CityText,'String','')
    set(handles.managerText,'String','')
    set(handles.DescriptionText,'String','')
    
catch e
    disp(e.message)
end

%Reset information of the camera
function reset_camera(handles)

try
    
    set(handles.IdcamText,'Enable','inactive')
    set(handles.ReferenceText,'Enable','inactive')
    set(handles.SizeXText,'Enable','inactive')
    set(handles.SizeYText,'Enable','inactive')
    set(handles.StationcamText,'Enable','inactive')
    
    set(handles.IdcamText,'String','')
    set(handles.ReferenceText,'String','')
    set(handles.SizeXText,'String','')
    set(handles.SizeYText,'String','')
    set(handles.StationcamText,'String','');
    
catch e
    disp(e.message)
end

%Reset information of the GCP
function reset_gcp(handles)

try
    
    set(handles.IdgcpText,'Enable','inactive')
    set(handles.NamegcpText,'Enable','inactive')
    set(handles.XgcpText,'Enable','inactive')
    set(handles.YgcpText,'Enable','inactive')
    set(handles.ZgcpText,'Enable','inactive')
    set(handles.StationgcpText,'Enable','inactive')
    set(handles.StationgcpText,'String','');
    
    set(handles.IdgcpText,'String','')
    set(handles.NamegcpText,'String','')
    set(handles.XgcpText,'String','')
    set(handles.YgcpText,'String','')
    set(handles.ZgcpText,'String','')
    
catch e
    disp(e.message)
end

%Reset information of the Sensor
function reset_sensor(handles)

try
    
    set(handles.namesensorText,'Enable','inactive')
    set(handles.stationsensorText,'Enable','inactive')
    set(handles.descriptionsensorText,'Enable','inactive')
    set(handles.XsensorText,'Enable','inactive')
    set(handles.YsensorText,'Enable','inactive')
    set(handles.ZsensorText,'Enable','inactive')
    
    set(handles.namesensorText,'String','')
    set(handles.stationsensorText,'String','')
    set(handles.descriptionsensorText,'String','')
    set(handles.XsensorText,'String','')
    set(handles.YsensorText,'String','')
    set(handles.ZsensorText,'String','')
    
catch e
    disp(e.message)
end

%Reset information of the measurement type
function reset_measurementtype(handles)

try
    
    set(handles.paramnameText,'Enable','inactive')
    set(handles.DatatypeSelect,'Enable','inactive')
    set(handles.SensormeasurementSelect,'Enable','inactive')
    set(handles.UnitxText,'Enable','inactive')
    set(handles.UnityText,'Enable','inactive')
    set(handles.UnitzText,'Enable','inactive')
    set(handles.AxisxText,'Enable','inactive')
    set(handles.AxisyText,'Enable','inactive')
    set(handles.AxiszText,'Enable','inactive')
    set(handles.DescriptionMeasurementTypeText,'Enable','inactive')
    
    set(handles.paramnameText,'String','')
    set(handles.DatatypeSelect,'Value',1);
    set(handles.DatatypeSelect,'String',{''})
    set(handles.SensormeasurementSelect,'Value',1);
    set(handles.SensormeasurementSelect,'String',{''})
    set(handles.UnitxText,'String','')
    set(handles.UnityText,'String','')
    set(handles.UnitzText,'String','')
    set(handles.AxisxText,'String','')
    set(handles.AxisyText,'String','')
    set(handles.AxiszText,'String','')
    set(handles.DescriptionMeasurementTypeText,'String','')
    if ~isempty(handles.datebox)
        handles.datebox.setVisible(false)
        set(handles.timestampmeasurement,'visible','off')
    end
    
catch e
    disp(e.message)
end

%Reset information of the Image paths
function reset_paths(handles)

try
    
    set(handles.txtcaptureimages,'Enable','inactive')
    set(handles.txtresultimages,'Enable','inactive')
   
    set(handles.txtcaptureimages,'String','');
    set(handles.txtresultimages,'String','');
 
catch e
    disp(e.message)
end

%Reset labels
function reset_label(handles)

try
    set(handles.gcp,'visible','off')
    set(handles.Station,'visible','off')
    set(handles.Camera,'visible','off')
    set(handles.Sensor,'visible','off')
    set(handles.MeasurementType,'visible','off')
    set(handles.InsertButton,'visible','off')
    set(handles.StationSelect,'Value',1);
    set(handles.UpdateButton,'visible','off')
    if ~isempty(handles.datebox)
        handles.datebox.setVisible(false)
        set(handles.timestampmeasurement,'visible','off')
    end
catch e
    disp(e.message)
end

% --- Executes on button press in ImportData.
function ImportData_Callback(hObject, eventdata, handles)
% hObject    handle to ImportData (see GCBO)
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
    if filename ~= 0
        
        ind = strfind(filename,'.xlsx');
        ind2 = strfind(filename,'.xls');
        if ~isempty(ind) || ~isempty(ind2)
            [num txt matrix] = xlsread(fullfile(pathname, filename));
            handles.measurementdata=cell2mat(matrix);
        else
            mat = fullfile(pathname, filename);
            vars = whos('-file', mat);
            load(mat, vars(1).name);
            handles.measurementdata = eval(vars(1).name);
            
        end
        set(handles.UpdateButton,'Enable','on')
        
    end
    guidata(hObject, handles);
    
catch e
    disp(e.message)
end

function handles = reload_time(handles)
% Set time sliders
try
    
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
    
    timevec = datevec(now);
    handles.datebox.setCalendar(GregorianCalendar(timevec(1), timevec(2) - 1, ...
        timevec(3), timevec(4), timevec(5), timevec(6)));
    
    % Put the DateSpinnerComboBox object in a GUI panel
    [handles.hDatebox,hContainer] = javacomponent(handles.datebox,[0,0,160,20],handles.timestampmeasurementtext);
    
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
    
    time_max = now;
    time = get_timestamp_calendar(handles);
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
    tz = calObj.getTimeZone();
    tzOffset = tz.getRawOffset(); % Time Zone offset in millis
    
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

% --- Executes on key press with focus on CityText and none of its controls.
function CityText_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to CityText (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

try
    
    check_station_data(handles,0)
    if isempty(eventdata.Character)
        set(handles.InsertButton,'Enable','off')
        set(handles.UpdateButton,'Enable','off')
    end
    
catch e
    disp(e.message)
end

% --- Executes on key press with focus on SizeYText and none of its controls.
function SizeYText_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to SizeYText (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

try
    check_camera_data(handles,0)
    
    sizeY=str2double(eventdata.Character);
    if isnan(sizeY) || mod(sizeY,1)~=0
        set(handles.InsertButton,'Enable','off')
        set(handles.UpdateButton,'Enable','off')
    end
    
catch e
    disp(e.message)
end

% --- Executes on key press with focus on ZgcpText and none of its controls.
function ZgcpText_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to ZgcpText (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

try
    check_gcp_data(handles,0)
    
    z=str2double(eventdata.Character);
    if isnan(z)
        set(handles.InsertButton,'Enable','off')
        set(handles.UpdateButton,'Enable','off')
    end
catch e
    disp(e.message)
end

% --- Executes on key press with focus on ZsensorText and none of its controls.
function ZsensorText_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to ZsensorText (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

try
    check_sensor_data(handles,0)
    
    z=str2double(eventdata.Character);
    if isnan(z)
        set(handles.InsertButton,'Enable','off')
        set(handles.UpdateButton,'Enable','off')
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



function txtcaptureimages_Callback(hObject, eventdata, handles)
% hObject    handle to captureimages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of captureimages as text
%        str2double(get(hObject,'String')) returns contents of captureimages as a double




function txtresultimages_Callback(hObject, eventdata, handles)
% hObject    handle to resultimages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of resultimages as text
%        str2double(get(hObject,'String')) returns contents of resultimages as a double




% --- Executes on button press in btResultimagespath.
function btResultimagespath_Callback(hObject, eventdata, handles)
% hObject    handle to btResultimagespath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    % Select path
    path = uigetdir;
    if path ~= 0
        set(handles.txtresultimages,'String',path);
    end
catch e
    disp(e.message)
end


% --- Executes on button press in btcaptureimagespath.
function btcaptureimagespath_Callback(hObject, eventdata, handles)
% hObject    handle to btcaptureimagespath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    % Select path
    path = uigetdir;
    if path ~= 0
        set(handles.txtcaptureimages,'String',path);
    end
catch e
    disp(e.message)
end

% --- Executes on button press in saveimagepath.
function saveimagepath_Callback(hObject, eventdata, handles)
% hObject    handle to saveimagepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    flag = check_paths(handles);
    
    if flag
        
        %%%Mirar lo de la estacion
        station = get_station(handles);
        xml = loadXML(handles.xmlfile, 'config');
        xmlPath = strcat('config/paths/site[name=', station, ']');
        
        removeNode(xml, xmlPath);
        
        pathsElement = createNode(xml, xmlPath);
        
        createLeave(xml, pathsElement, 'pathOblique', sprintf('%s', get(handles.txtcaptureimages,'String')))
        try
            xmlsave(handles.xmlfile, xml);            
        catch e
            warndlg('Update unsuccessful','Unsuccessful');
        end
        
        [status, message] = set_paths(get(handles.txtresultimages,'String'), station);
        if status
            warndlg(message,'Unsuccessful');
        else
            warndlg(message,'Successful');
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
    find = strfind(get(handles.txtcaptureimages,'String'),'http://');
    if ~isdir(get(handles.txtcaptureimages,'String')) && isempty(find)
        set(handles.txtcaptureimages,'BackgroundColor',[1 0 0])
        flag=0;
    else
        set(handles.txtcaptureimages,'BackgroundColor',[1 1 1])
    end
    find = strfind(get(handles.txtresultimages,'String'),'http://');
    if ~isdir(get(handles.txtresultimages,'String')) && isempty(find)
        set(handles.txtresultimages,'BackgroundColor',[1 0 0])
        flag=0;
    else
        set(handles.txtresultimages,'BackgroundColor',[1 1 1])
    end
    
catch e
    disp(e.message)
end

    


% --- Executes on button press in btimportsensordata.
function btimportsensordata_Callback(hObject, eventdata, handles)
% hObject    handle to btimportsensordata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    
    % Select path of the file to import
    
    [filename, pathname] = ...
        uigetfile({'*.txt'},'File Selector');
    
    if filename ~= 0
        alldata = importdata(fullfile(pathname, filename), '\t');
        handles.sensordata = alldata;
        
        set(handles.UpdateButton,'Enable','on')
        
    end
    guidata(hObject, handles);
    
catch e
    disp(e.message)
end

% --- Executes on button press in sensorvirtualYes.
function sensorvirtualYes_Callback(hObject, eventdata, handles)
% hObject    handle to sensorvirtualYes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sensorvirtualYes

try
    check_sensor_data(handles,1)
    set(handles.sensorvirtualYes,'Value',1);
    set(handles.sensorvirtualNo,'Value',0);
catch e
    disp(e.message)
end

% --- Executes on button press in sensorvirtualNo.
function sensorvirtualNo_Callback(hObject, eventdata, handles)
% hObject    handle to sensorvirtualNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sensorvirtualNo

try
    check_sensor_data(handles,1)
    set(handles.sensorvirtualNo,'Value',1);
    set(handles.sensorvirtualYes,'Value',0);
catch e
    disp(e.message)
end
