function varargout = gui_message(varargin)
% GUI_MESSAGE M-file for gui_message.fig
%      GUI_MESSAGE, by itself, creates a new GUI_MESSAGE or raises the existing
%      singleton*.
%
%      H = GUI_MESSAGE returns the handle to a new GUI_MESSAGE or the handle to
%      the existing singleton*.
%
%      GUI_MESSAGE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_MESSAGE.M with the given input arguments.
%
%      GUI_MESSAGE('Property','Value',...) creates a new GUI_MESSAGE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_message_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_message_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_message

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2011 HORUS
% Last Modified by GUIDE v2.5 22-Jan-2012 19:12:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_message_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_message_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
%     gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gui_message is made visible.
function gui_message_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_message (see VARARGIN)

% Parse input arguments
noptargs = numel(varargin);
if noptargs == 2
    message = varargin{1};
    title = varargin{2};
    set(handles.figure1, 'name', title)

    set(handles.message, 'String', message)
    
else
    % Stop timer
    stop(handles.tmr);
    delete(handles.tmr); % removes the timer from memory
    
end
delay_length = 0.2; % frame will be updated after 0.2 sec
gif_image = 'loading.gif';

[handles.im,handles.map] = imread(gif_image, 'frames', 'all'); % read all frames of a gif image
handles.len = size(handles.im, 4); % number of frames in the gif image
handles.h1 = imshow(handles.im(:, :, :, 1), handles.map); % loads the first image along with its colormap
handles.count = 1;% intialise counter to update the next frame
handles.tmr = timer('TimerFcn', {@TmrFcn,handles.logo},'BusyMode','Queue',...
    'ExecutionMode','FixedRate','Period',delay_length); % create a Timer Object
set(gcf,'CloseRequestFcn',{@CloseFigure,handles});

% Choose default command line output for gui_message
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
start(handles.tmr); % starts Timer

% UIWAIT makes gui_message wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_message_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function TmrFcn(src,event,handles)
%Timer Function to animate the GIF

try
    handles = guidata(handles);
    set(handles.h1,'CData',handles.im(:,:,:,handles.count)); % update the frame in the axis
    drawnow
    handles.count = handles.count + 1; % increment to next frame
    if handles.count > handles.len % if the last frame is achieved intialise to first frame
        handles.count = 1;
    end
    guidata(handles.logo, handles);
catch e
end

function CloseFigure(src,event,handles)
% Function CloseFigure(varargin)
% stop(handles.tmr);delete(handles.tmr);%removes the timer from memory
% closereq;
delete(handles.figure1)