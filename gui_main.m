function varargout = gui_main(varargin)
%GUI_MAIN M-file for gui_main.fig
%      GUI_MAIN, by itself, creates a new GUI_MAIN or raises the existing
%      singleton*.
%
%      H = GUI_MAIN returns the handle to a new GUI_MAIN or the handle to
%      the existing singleton*.
%
%      GUI_MAIN('Property','Value',...) creates a new GUI_MAIN using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to gui_main_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      GUI_MAIN('CALLBACK') and GUI_MAIN('CALLBACK',hObject,...) call the
%      local function named CALLBACK in GUI_MAIN.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_main

% Last Modified by GUIDE v2.5 11-Oct-2013 22:06:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_main_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_main_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before gui_main is made visible.
function gui_main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for gui_main
handles.output = hObject;

about = ['HORUS is an environmental monitorization tool designed ', ...
         'to take images of a study zone by means of several ', ...
         'interconnected cameras. HORUS rectifies, merges and transfers ', ...
         'these images with the aim of studying the temporal and spatial ', ...
         'evolution of the study zone. This tool was developed by the ', ...
         'Universidad Nacional de Colombia (Medellín) and the Environmental ', ...
         'Hydraulics Institute (IH Cantabria) and funded by the ', ...
         'Spanish Agency for International Cooperation and Development', ...
         '(AECID).'];

try
    set(handles.editHORUS, 'String', about)
    % Set HORUS paths
    if ~isdeployed
        root = fileparts(mfilename('fullpath'));
        handles.root = fileparts(root);
        addpath(genpath(handles.root));
    end

    % Put logo
    logo = imread('LogoHorusMin.png');
    imshow(logo, 'Parent', handles.axesLogo)
    
catch e
    disp(e.message)
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_main wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_main_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in buttonConfigureCameras.
function buttonConfigureCameras_Callback(hObject, eventdata, handles)
% hObject    handle to buttonConfigureCameras (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gui_configure_cameras();


% --- Executes on button press in buttonConfigureCapture.
function buttonConfigureCapture_Callback(hObject, eventdata, handles)
% hObject    handle to buttonConfigureCapture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gui_configure_capture();

% --- Executes on button press in buttonConfigureProcessing.
function buttonConfigureProcessing_Callback(hObject, eventdata, handles)
% hObject    handle to buttonConfigureProcessing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gui_processing();

% --- Executes on button press in buttonConfigureDatabase.
function buttonConfigureDatabase_Callback(hObject, eventdata, handles)
% hObject    handle to buttonConfigureDatabase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gui_configure_database();

% --- Executes on button press in buttonDBEditor.
function buttonDBEditor_Callback(hObject, eventdata, handles)
% hObject    handle to buttonDBEditor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gui_db_editor();

% --- Executes on button press in buttonCreateUser.
function buttonCreateUser_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCreateUser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gui_create_user();

% --- Executes on button press in buttonUploadHosting.
function buttonUploadHosting_Callback(hObject, eventdata, handles)
% hObject    handle to buttonUploadHosting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gui_upload_hosting();

% --- Executes on button press in buttonConfigureSync.
function buttonConfigureSync_Callback(hObject, eventdata, handles)
% hObject    handle to buttonConfigureSync (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gui_configure_sync();

% --- Executes on button press in buttonROITool.
function buttonROITool_Callback(hObject, eventdata, handles)
% hObject    handle to buttonROITool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gui_roi_tool();

% --- Executes on button press in buttonThumbnailsTool.
function buttonThumbnailsTool_Callback(hObject, eventdata, handles)
% hObject    handle to buttonThumbnailsTool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gui_thumbnails_tool();

% --- Executes on button press in buttonMergingImages.
function buttonMergingImages_Callback(hObject, eventdata, handles)
% hObject    handle to buttonMergingImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gui_merging_images();

% --- Executes on button press in buttonGenCalibration.
function buttonGenCalibration_Callback(hObject, eventdata, handles)
% hObject    handle to buttonGenCalibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gui_gencalibration();

% --- Executes on button press in buttonRectifyImages.
function buttonRectifyImages_Callback(hObject, eventdata, handles)
% hObject    handle to buttonRectifyImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gui_rectify_images();

% --- Executes on button press in buttonGenFusion.
function buttonGenFusion_Callback(hObject, eventdata, handles)
% hObject    handle to buttonGenFusion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gui_genfusion();

% --- Executes on button press in buttonPathsEditor.
function buttonPathsEditor_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPathsEditor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

gui_paths_editor();


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
