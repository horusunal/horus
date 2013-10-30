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

% about = ['HORUS is an environmental monitorization tool designed ', ...
%          'to take images of a study zone by means of several ', ...
%          'interconnected cameras. HORUS rectifies, merges and transfers ', ...
%          'these images with the aim of studying the temporal and spatial ', ...
%          'evolution of the study zone. This tool was developed by the ', ...
%          'Universidad Nacional de Colombia (Medellín) and the Environmental ', ...
%          'Hydraulics Institute (IH Cantabria) and funded by the ', ...
%          'Spanish Agency for International Cooperation and Development', ...
%          '(AECID).'];

try
%     set(handles.editHORUS, 'String', about)
    set(handles.buttonConfigureCameras, 'TooltipString', ...
        sprintf('Opens a new interface where a user \ncan configure the hardware parameters \nof the cameras for capturing images \nand videos'))
    set(handles.buttonConfigureDatabase, 'TooltipString', ...
        sprintf('Opens a new interface where a user \ncan create the database schema and the \nHORUS admin user'))
    set(handles.buttonPathsEditor, 'TooltipString', ...
        sprintf('Opens a new interface where a user \ncan define the paths for the images in \nthe local computer (optional)'))
    set(handles.buttonDBEditor, 'TooltipString', ...
        sprintf('Opens a new interface where the HORUS \nadmin user can create a new station, \ncameras, GCPs, etc, after setting \nup the database first!'))
    set(handles.buttonCreateUser, 'TooltipString', ...
        sprintf('Opens a new interface where the HORUS \nadmin user can create a new HORUS user \nwith limited privileges'))
    set(handles.buttonGenCalibration, 'TooltipString', ...
        sprintf('Opens a new interface to configure the \nrectification parameters. Rectification \nis the process of converting an \noblique image into an map-style image'))
    set(handles.buttonROITool, 'TooltipString', ...
        sprintf('Opens a new interface to create a new \nROI (Region of Interest) associated to \na rectification. This allows to \nrectify only a portion of the image'))
    set(handles.buttonRectifyImages, 'TooltipString', ...
        sprintf('Opens a new interface where the user \ncan rectify a batch of oblique images \nwith the option of not inserting \nthem into the database'))
    set(handles.buttonGenFusion, 'TooltipString', ...
        sprintf('Opens a new interface where the user \ncan configure the fusion parameters. \nFusion is the process of merging \nthe images of several cameras into \na single continous image that \nspans the whole monitored zone'))
    set(handles.buttonMergingImages, 'TooltipString', ...
        sprintf('Opens a new interface where the user \ncan merge a batch of images with the \noption of not inserting them into \nthe database'))
    set(handles.buttonConfigureCapture, 'TooltipString', ...
        sprintf('Opens a new interface where the user \ncan configure the capture parameters \nlike initial time, final time, time \nbetween consecutive captures, and \ncan also generate a standalone \nprogram to run the capture automatically'))
    set(handles.buttonConfigureProcessing, 'TooltipString', ...
        sprintf('Opens a new interface where the user \ncan configure the image processing \nparameters and can also generate a \nstandalone program to run the processing \nautomatically'))
    set(handles.buttonConfigureSync, 'TooltipString', ...
        sprintf('Opens a new interface where the user \ncan configure the automatic synchronization \nof a local HORUS database \nwith a central HORUS database,  and can \nalso generate a standalone program to \nrun the synchronization automatically'))
    set(handles.buttonThumbnailsTool, 'TooltipString', ...
        sprintf('Opens a new interface where the user \ncan configure the thumbnail parameters. The \nthumbnails are the images \nthat are displayed in the web'))
    set(handles.buttonUploadHosting, 'TooltipString', ...
        sprintf('Opens a new interface where the user \ncan configure the upload of thumbnails \nautomatically to the web'))
    
    % Set HORUS paths
    if ~isdeployed
        root = fileparts(mfilename('fullpath'));
        handles.root = fileparts(root);
        addpath(genpath(handles.root));
    end

    % Put logo
    logo = imread('logoHORUS.png');
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
