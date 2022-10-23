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
%
% Ella Gabitov, October 2022
%

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

end

%% STIM

% --- Executes just before stim is made visible.
function stim_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to stim (see VARARGIN)
    
    % get PsychHID linked and loaded on MS-Windows
    currentOS = lower(system_dependent('getos'));
    if contains(currentOS,'microsoft')
        LoadPsychHID
    end
    
    % Choose default command line output for stim
    handles.output = hObject;
    
    % Update handles structure
    guidata(hObject, handles);
    
    [main_dpath,~,~] = fileparts(which('stim.m'));
    
    % Add directories to the MATLAB path
    addpath(fullfile(main_dpath,'stimuli'));
    addpath(fullfile(main_dpath,'experiments'));
    addpath(fullfile(main_dpath,'utils'));
    addpath(fullfile(main_dpath,'analysis'));
    
    % Get parameters for the experiment from get_param....m
    param = tmr_msl_get_param();
    
    % set the path to the main directory
    param.main_dpath = main_dpath;
    
    % create and set the path to the output directory
    output_dpath = fullfile(main_dpath,'output');
    if ~exist(output_dpath, 'dir')
        mkdir(output_dpath) % create output dir
    end
    param.output_dpath = output_dpath;
    
    % Set param to application data collection
    % Is accessed in stim: param = getappdata(0,'...');
    % Should be removed when done using rmappdata
    setappdata(0,'param', param);
    
    setStimMenu(handles);

end

% --- Outputs from this function are returned to the command line.
function varargout = stim_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Get default command line output from handles structure
    varargout{1} = handles.output;
end

%% BUTTONS

% --- Executes on button press in buttonResults
function button_PreSleep_Callback(hObject, eventdata, handles)
    % hObject    handle to buttonStart (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    exp_phase = 'PreSleep';

    % Start experiment by doing the following:
    %   - Create soundHandSeq tripples, if needed
    %   - Add soundHandSeq & other info to the param structure
    %   - Save the parm structure for the subject
    param_fpath = start_experiment(handles);

    % Open the menu for the PreSleep experimental phase
    tmr_msl_menuPreSleep(exp_phase, param_fpath);

end


% --- Executes on button press in buttonResults
function button_PostSleep_Callback(hObject, eventdata, handles)
    % hObject    handle to buttonStart (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    exp_phase = 'PostSleep';

    % Start experiment by doing the following:
    %   - Create soundHandSeq tripples, if needed
    %   - Add soundHandSeq & other info to the param structure
    %   - Save the parm structure for the subject
    param_fpath = start_experiment(handles);
   
    % Open the menu for the PostSleep experimental phase
    tmr_msl_menuPostSleep(exp_phase, param_fpath);

end


% --- Executes on button press in buttonResults
function buttonResults_Callback(hObject, eventdata, handles)
    % hObject    handle to buttonStart (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    param = getappdata(0,'param');
    ld_runAnalysis(param.output_dpath)

end


% --- Executes on button press in buttonQuit.
function buttonQuit_Callback(hObject, eventdata, handles)
    % hObject    handle to buttonQuit (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    rmappdata(0, 'param');
    
    [main_dpath,~,~] = fileparts(which('stim.m'));
    
    % Remove directories from the MATLAB path
    rmpath(fullfile(main_dpath,'stimuli'));
    rmpath(fullfile(main_dpath,'experiments'));
    rmpath(fullfile(main_dpath,'utils'));
    rmpath(fullfile(main_dpath,'analysis'));
    
    % Clear & close all
    close all;
    clear;

end

%%  UTILITIES

% --- Is called when stim is opening
function setStimMenu(handles)

    % Get param from application data collection
    % Is defined in stim_ChooseDesign
    % Should be removed when done using rmappdata
    param = getappdata(0,'param');
    
    set(handles.dispOutputDir, 'String', param.output_dpath);
    set(handles.dispSeqA, 'String', num2str(param.seqs{1}));
    set(handles.dispSeqB, 'String', num2str(param.seqs{2}));
    
    if param.fullScreen
        set(handles.radiobuttonYesFullScreen, 'Value', 1);
    else
        set(handles.radiobuttonNoFullScreen, 'Value', 1);
    end
    
    if param.flipScreen
        set(handles.radiobuttonYesFlipScreen, 'Value', 1);
    else
        set(handles.radiobuttonNoFlipScreen, 'Value', 1);
    end
    
    if param.twoMonitors
        set(handles.radiobuttonYesTwoMonitors, 'Value', 1);
    else
        set(handles.radiobuttonNoTwoMonitors, 'Value', 1);
    end
end


% --- Is called on button press in PreSleep or PostSleep
% Those are separate sessions of the experiment
function param_fpath = start_experiment(handles)

    % Get param from application data collection
    % Is defined in stim_ChooseDesign
    % Should be removed when done using rmappdata
    param_default = getappdata(0,'param');
    
    subject = get(handles.editSubject, 'String');    
    param = param_default;
    param.subject = subject;

    soundHandSeq = [];
    param_fpath = fullfile(param_default.output_dpath, [subject '_param.mat']);
    % load existing param file
    if exist(param_fpath, 'file')
        param_load = load(param_fpath);
        if isfield(param_load.param, 'soundHandSeq')
            soundHandSeq = param_load.param.soundHandSeq;
        end
    end

    % Generate a new soundHandSeq tripple
    if isempty(soundHandSeq)
        soundHandSeq = getSoundHandSeq(param);
    end
    
    param.soundHandSeq = soundHandSeq;

    % Update sceen & monitors info
    param.fullScreen = get(handles.radiobuttonYesFullScreen, 'Value');
    param.flipScreen = get(handles.radiobuttonYesFlipScreen, 'Value');
    param.twoMonitors = get(handles.radiobuttonYesTwoMonitors, 'Value');
    
    save(param_fpath, 'param');
    setappdata(0,'param', param);

end


% --- Is used to create sound-hand-sequence association
% Is created only once for each participant when PreSleep
% of PostSleep button is pressed
function soundHandSeq = getSoundHandSeq(param)
    
    % Assumption: there is the same number of sounds, hands, and sequences

    inds_sounds = randsample(1:numel(param.sounds), numel(param.sounds));
    inds_hands = randsample(1:numel(param.hands), numel(param.hands));
    inds_seqs = randsample(1:numel(param.seqs), numel(param.seqs));

    soundHandSeq = [];
    for i = 1:numel(inds_sounds)
        soundHandSeq(i).sound = param.sounds{inds_sounds(i)};
        soundHandSeq(i).hand = param.hands(inds_hands(i));
        soundHandSeq(i).seq = param.seqs{inds_seqs(i)};
    end
    
end
