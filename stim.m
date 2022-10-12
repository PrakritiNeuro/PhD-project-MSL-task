function varargout = stim(varargin)
% stim M-file for stim.fig
%      stim, by itself, creates a new stim or raises the existing
%      singleton*.
%
%      H = stim returns the handle to a new stim or the handle to
%      the existing singleton*.
%
%      stim('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in stim.M with the given input arguments.
%
%      stim('Property','Value',...) creates a new stim or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before stim_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to stim_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help stim

% Last Modified by GUIDE v2.5 31-Oct-2014 09:36:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @stim_OpeningFcn, ...
                   'gui_OutputFcn',  @stim_OutputFcn, ...
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


% --- Executes just before stim is made visible.
function stim_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to stim (see VARARGIN)

% Choose default command line output for stim
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes stim wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global EXPERIMENT;
global HOME;
EXPERIMENT = 'stim Project';
HOME = which('stim');
HOME = HOME(1:length(HOME)-6);

% Create Output directory if it doesn't exists
outputDir = strcat(HOME,'output');
if ~exist(outputDir, 'dir')
    mkdir(outputDir) % create output dir
end

% add stimuli/ and experiments/ to the MATLAB path
addpath(strcat(HOME,'stimuli'))
addpath(strcat(HOME,'experiments'))
addpath(strcat(HOME,'analysis'))

% --- TO RUN ONLY ONE DESIGN --- %
% --- should be removed if stim_ChooseDesign is used
% -----------------------------------------------------------------------
% design_desc = stim_ChooseDesign();%'IntR_1hand';
% Get parameters from paramters....m
run([HOME, 'experiments' filesep 'ld_parameters']);
% Set param to application data collection
% Is accessed in stim: param = getappdata(0,'...');
% Should be removed when done using rmappdata
setappdata(0,'param', param);
% -----------------------------------------------------------------------

setExperimentButton(handles);
pos = get(handles.uipanel_stim_Project, 'Position');
pos(2) = 2;
set(handles.uipanel_stim_Project, 'Position', pos);
set(handles.uipanel_stim_Project, 'Visible', 'On');

% --- Outputs from this function are returned to the command line.
function varargout = stim_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%%%%%%%%%%%
%  Buttons 
%%%%%%%%%%%
function associate_HandSoundSequence(subject, outputDir, param)

hand_possibilities = 1:length(param.hands);
sound_possibilities = 1:length(param.sounds);
hand_choice = randi(hand_possibilities);
sound_choice = randi(sound_possibilities);

HandSoundSequenceAssociation.seqA.hand = param.hands{hand_choice};
hand_possibilities(hand_possibilities==hand_choice) = [];
HandSoundSequenceAssociation.seqB.hand = param.hands{hand_possibilities(1)};

HandSoundSequenceAssociation.seqA.sound = param.sounds{sound_choice};
sound_possibilities(sound_possibilities==sound_choice) = [];
HandSoundSequenceAssociation.seqB.sound = param.sounds{sound_possibilities(1)};

param.task = 'HandSoundSequenceAssociation';

savefile_HandSoundSequenceAssociation(param, HandSoundSequenceAssociation);

% --- Executes on button press in PreSleep or PostSleep.
% Those are separate sessions of the experiment
function param = Start_experiment(D_EXPERIMENT,handles)

% Get param from application data collection
% Is defined in stim_ChooseDesign
% Should be removed when done using rmappdata
param = getappdata(0,'param');


param.numMonitor = get(handles.radiobuttonYesSecondMonitor, 'Value');
param.flipMonitor = get(handles.radiobuttonYesFlipMonitor, 'Value');

% Common parameters        
param.subject = get(handles.editSubject, 'String');

if ~exist(param.outputDir, 'dir')
    mkdir(param.outputDir) % create subject output dir
end
associate_HandSoundSequence(param.subject, param.outputDir, param)

load([param.outputDir, param.subject,'_','HandSoundSequenceAssociation',...
    '.mat'], 'HandSoundSequenceAssociation')

param.HandSoundSequenceAssociation = HandSoundSequenceAssociation;

param.outputDir = get(handles.editOutputDir, 'String');
param.fullscreen = get(handles.radiobuttonFullScreenYes, 'Value');

% Sequences
param.seqA = str2num(get(handles.editSeqA, 'String'));
param.seqB = str2num(get(handles.editSeqB, 'String'));


% --- Executes on button press in buttonResults
function button_PreSleep_Callback(hObject, eventdata, handles)
% hObject    handle to buttonStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global D_EXPERIMENT;
D_EXPERIMENT = 'PreSleep';
param = Start_experiment(D_EXPERIMENT,handles);
ld_menuPreSleep(param);


% --- Executes on button press in buttonResults
function button_PostSleep_Callback(hObject, eventdata, handles)
% hObject    handle to buttonStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global D_EXPERIMENT;
D_EXPERIMENT = 'PostSleep';
param = Start_experiment(D_EXPERIMENT,handles);
ld_menuPostSleep(param);


% --- Executes on button press in buttonResults
function buttonResults_Callback(hObject, eventdata, handles)
% hObject    handle to buttonStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
param = getappdata(0,'param');
ld_runAnalysis(param.outputDir)

% --- Executes on button press in buttonQuit.
function buttonQuit_Callback(hObject, eventdata, handles)
% hObject    handle to buttonQuit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rmappdata(0, 'param');
clear;
close;

%%%%%%%%%%%%%%%%%%
%  Utilities
%%%%%%%%%%%%%%%%%%

function setExperimentButton(handles)

% Buttons and panel properties
set(handles.button_PreSleep_Callback, 'FontWeight', 'normal');
set(handles.button_PostSleep_Callback, 'FontWeight', 'normal');
set(handles.uipanel_stim_Project, 'Visible', 'off');


% Get param from application data collection
% Is defined in stim_ChooseDesign
% Should be removed when done using rmappdata
param = getappdata(0,'param');

set(handles.editOutputDir, 'String',param.outputDir);
set(handles.editSeqA, 'String', num2str(param.seqA));
set(handles.editSeqB, 'String', num2str(param.seqB));

if param.fullscreen == 1
    set(handles.radiobuttonFullScreenYes, 'Value', 1);
else
    set(handles.radiobuttonFullScreenNo, 'Value', 1);
end

if param.numMonitor == 1
    set(handles.radiobuttonYesSecondMonitor, 'Value', 1);
else
    set(handles.radiobuttonNoSecondMonitor, 'Value', 1);
end

if param.flipMonitor == 1
    set(handles.radiobuttonYesFlipMonitor, 'Value', 1);
else
    set(handles.radiobuttonNoFlipMonitor, 'Value', 1);
end