%%
% Parameters for stim
%

currentOS = lower(system_dependent('getos'));

%% Keys = a b c d %%
param = struct(...
    'rawDir',           HOME, ... 
    'outputDir',        [HOME, 'output', filesep], ...      % output directory to save data (onset and .mat)
    'textSize',         40, ...                             % text size (in pixels)
    'crossSize',        100,...                             % cross size (in pixels)
    'number_channels',  2,...
    'gold',             [255,215,0,255], ...
    'white',            [255, 255, 255, 255], ...
    'LeftOrRightHand',  'unset',...                         % 1 = Left Hand, 2 = Right Hand
    'seqA',             [2 4 1 3 4 2 3 1], ...              % sequence A to execute
    'seqB',             [2 1 4 3 2 3 4 1], ...              % sequence B to execute
    'nbSeqIntro',       3, ...                              % nb of sequences for pre-training
    'nbSeqPerMiniBlock',3, ...                              % nb of sequences to complete per mini block during training
    'nbSeqPerTestBlock',10, ...                             % nb of sequences to complete per test block
    'nbMiniBlocks',     [30 25 25], ...                     % number of mini-blocks for each sequence for each training phase
    'nbTestBlocks',     3, ...                              % number of test blocks for each sequence
    'maxNbMiniBlocksSameSeq', 3, ...                        % no more than X consecutive trial with the same sequence (Training)
    'maxNbTestBlocksSameSeq',2, ...                         % no more than X consecutive trial with the same sequence (Test)
    'JitterRangeBetweenMiniBlocks', [1 5],...               % lower and upper boundary or jittered rest between mini blocks
    'durRest',          15,...                              % Duration of the Rest period
    'durNoResponse',    5,...                               % max response time duration in seconds
    'fullscreen',       0, ...                              % 0: subwindow, 1: whole desktop => see createWindow.m for modifications
    'numMonitor',       0, ...                              % 0: 1 monitor, 1: two monitors
    'flipMonitor',      0, ...                              % 0: don't flip, 1: flip monitor
    'screenResolution', [],...                              % initialized just after the windows is created
    'os',               currentOS...
    );

param.keyboard = KbName('KeyNames');

param.hands = {'left_hand'; 'right_hand'};
param.sounds = {'shortest-1-100ms.wav', 'shortest-3-100ms.wav'};

% For both hands, a sequence is performed with 1 being the Index Finger,
% 2 being the Middle Finger, 3 being the ring finger and 4 being the 
% little finger
% performing sequence 2 4 1 3, for example, would mean pressing
% middle finger, little finger, Index Finger and ring finger, in that order

% Assuming a usual keyboard, this would mean that key 1 on the keyboard is 
% the little finger, so 4 in terms of element of the sequence. Key 2 is the
% ring finger, so 3 as an element of the sequence, and so onF.
keySet = {1, 2, 3, 4};
valueSet = {4, 3, 2, 1};
left_hand_keyboard_key_to_task_element = containers.Map(keySet,valueSet);
%
keySet = {7, 8, 9, 0};
valueSet = {1, 2, 3, 4};
right_hand_keyboard_key_to_task_element = containers.Map(keySet,valueSet);

keySet = {1, 2, 3, 4, 7, 8, 9, 0};
valueSet = {4, 3, 2, 1, 1, 2, 3, 4};
both_hands_keyboard_key_to_task_element = containers.Map(keySet,valueSet);

param.left_hand_keyboard_key_to_task_element = left_hand_keyboard_key_to_task_element;
param.right_hand_keyboard_key_to_task_element = right_hand_keyboard_key_to_task_element;
param.both_hands_keyboard_key_to_task_element = both_hands_keyboard_key_to_task_element;

if strfind(currentOS,'microsoft')
    LoadPsychHID
    empties = cellfun('isempty',param.keyboard);
    param.keyboard(empties) = {'zzzzz'};
end