function param = get_param_tmr_msl(varargin)
%get_param_stim_tmr_msl()
% get parameters for the TMR_MSL experiment
%
% Ella Gabitov, October 2022
%
%% THE PARADIGM

% training
nbMiniBlocks = [30 25 25];      % number of mini-blocks for each sequence for each training phase
nbSeqPerMiniBlock = 3;          % nb of sequences to complete per mini block during training

% test
nbSeqPerTestBlock = 10;         % nb of sequences to complete per test block
nbTestBlocks = 3;               % number of test blocks for each 

% sequences to execute; verify the key-value mapping below
seqs = {};
seqs{end+1} = [2 4 1 3 4 2 3 1];
seqs{end+1} = [2 1 4 3 2 3 4 1];


%% KEY-VALUE MAPPING

% For participants, each element in the sequence can be one of the four
% digits (1-4); each digit corresponds to a specific finger:
%   1 - the index finger
%   2 - the middle finger
%   3 - the ring finger
%   4 - the little finger

% set of keys for each digit from 1 to 4
% Do not change the order of the digits
keySet_left = {'4', '3', '2', '1'};
keySet_right = {'A', 'B', 'C', 'D'};

%%

param = struct(...
    'nbSeqIntro',       3, ...                              % nb of sequences for pre-training
    'nbMiniBlocks',     nbMiniBlocks, ...                   % a vector with the number of mini-blocks for each sequence for each training phase
    'nbSeqPerMiniBlock',nbSeqPerMiniBlock, ...              % nb of sequences to complete per mini block during training
    'nbTestBlocks',     nbTestBlocks, ...                   % number of test blocks for each sequence
    'nbSeqPerTestBlock',nbSeqPerTestBlock, ...              % nb of sequences to complete per test block
    'maxNbMiniBlocksSameSeq', 3, ...                        % no more than X consecutive trial with the same sequence (Training)
    'maxNbTestBlocksSameSeq',2, ...                         % no more than X consecutive trial with the same sequence (Test)
    'JitterRangeBetweenMiniBlocks', [1 5],...               % lower and upper boundary or jittered rest between mini blocks
    'durRest',          15,...                              % Duration of the Rest period
    'durNoResponse',    5,...                               % max response time duration in seconds
    'fullScreen',       1, ...                              % 0: subwindow, 1: whole desktop => see createWindow.m for modifications
    'flipScreen',       0, ...                              % 0: don't flip, 1: flip monitor
    'twoMonitors',      0, ...                              % 0: 1 monitor, 1: two monitors
    'screenResolution', [],...                              % initialized just after the windows is created
    'textSize',         40, ...                             % text size (in pixels)
    'crossSize',        100 ...                             % cross size (in pixels)
    );

param.seqs = seqs;
param.sounds = {'shortest-1-100ms.wav', 'shortest-3-100ms.wav'};
param.hands = {'left'; 'right'};

% Do not change the order of the digits
param.map_left = containers.Map(keySet_left, {1, 2, 3, 4});
param.map_right = containers.Map(keySet_right, {1, 2, 3, 4});

end
