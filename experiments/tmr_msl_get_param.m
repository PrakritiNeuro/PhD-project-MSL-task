function param = tmr_msl_get_param()
%get_param_stim_tmr_msl()
% get parameters for the TMR_MSL experiment
%
% Ella Gabitov, October 2022
%
%% THE PARADIGM

param = [];

% Intro
param.introNbSeq = 3;                       % nb of correct sequence repetitons required during intro tasks
param.introDurRest = 3;                     % Rest duration, in seconds, during intro tasks

% training
param.trainNbBlocksPerSeq = [30 25 25];     % number of mini-blocks for each sequence for each training phase
param.trainNbSeqPerBlock = 3;               % nb of sequences to complete per mini block during training
param.trainMaxNbBlocksSameSeq = 3;          % no more than X consecutive blocks with the same sequence
param.trainDurRest = 15;                    % Rest duration at the start & end of training
param.trainDurRestBetween = [1 5];          % lower and upper boundary of jittered rest between mini blocks

% test
param.testNbBlocksPerSeq = 3;               % number of test blocks for each sequence
param.testNbSeqPerBlock = 10;               % nb of sequences to complete per test block
param.testMaxNbBlocksSameSeq = 2;           % no more than X consecutive blocks with the same sequence
param.testDurRest = 15;                     % Rest duration at the start & end of training
param.testDurRestBetween = 15;              % Rest duration between performance blocks

%% SEQUENCES

% sequences to execute; verify the key-value mapping below
seqs = {};
seqs{end+1} = [2 4 1 3 4 2 3 1];
seqs{end+1} = [2 1 4 3 2 3 4 1];

param.seqs = seqs;

%% KEY-VALUE MAPPING

% For participants, each element in the sequence can be one of the four
% digits (1-4); each digit corresponds to a specific finger:
%   1 - the index finger
%   2 - the middle finger
%   3 - the ring finger
%   4 - the little finger

% Hands mapping
hands = [];

% DO NOT CHANGE THE ORGER OF THE DIGITS:
%   Keep it from the index to little finger

hands(end+1).desc = 'left';
hands(end).digits = {'1', '2', '3', '4'};   % digits from the index to little finger
hands(end).keys = {'4', '3', '2', '1'};     % Keys that correspond to each digit

hands(end+1).desc = 'right';
hands(end).digits = {'1', '2', '3', '4'};   % digits from the index to little finger
hands(end).keys = {'7', '8', '9', '0'};     % Keys that correspond to each digit

param.hands = hands;

%% SOUND

param.sounds = {'sound_shortest-1-100ms.wav', 'sound_shortest-3-100ms.wav'};

%% OTHER PARAMETERS

param.waitMax = 5;              % max time to wait for response, in seconds
param.fullScreen= 0;            % 0: subwindow, 1: whole desktop => see createWindow.m for modifications
param.flipScreen = 0;           % 0: don't flip, 1: flip monitor
param.twoMonitors = 0;          % 0: 1 monitor, 1: two monitors
param.textSize = 45;            % text size (in pixels)
param.transScreenDur = 0.5;     % time to present transition black screen between instructions or stimuli
param.hintDur = 3;              % time to present a hint if a wrong hand or wrong sequence

end
