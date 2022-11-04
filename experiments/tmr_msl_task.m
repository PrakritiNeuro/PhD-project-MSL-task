function [quit, data_saved, output_fpath] = tmr_msl_task(param_fpath, exp_phase, task_name, task_phase)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [quit, data_saved, output_fpath] = tmr_msl_intro4_soundHandSeq(param_fpath, exp_phase, task_name)
% Associatining each sequence with the sound:
%   Each sequence is associated with a different sound accoridng to the
%   sound-hand-triple generated at the beginning of the experiment (stored
%   in param.soundHandSeg). The task is repeated for each 
%   sound-hand-sequence until the sequence is performed correctly three
%   times in a row using the corresponding hand.
%
% INPUT
%   param_fpath     [string]    full path to the param file of the
%                               participant; if it doesn't exist the
%                               program throws an error
%   exp_phase       [string]    the phase of the experiment
%                               e.g., 'PreSleep', 'PostSleep'
%   task_name       [string]    task name, e.g., 'training', 'test'
%   task_phase      [int]       an index to indicate the phase for training
%
% OUTPUT
%   quit            [boolean]   1 - exit before compited; 0 - otherwise
%   data_saved      [boolean]   1 - data was saved; 0 - otherwise
%   output_fpath    [string]
%
% Vo An Nguyen 2009/03/26
% Arnaud Bore 2012/10/05, CRIUGM - arnaud.bore@gmail.com
% Arnaud Boré 2012/08/11 switch toolbox psychotoolbox 3.0
% Arnaud Boré 2014/10/31 Modification for two handed task
% Ella Gabitov, March 9, 2015  
% Arnaud Boré 2016/05/30 Stim
% Ella Gabitov, October 2022
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 4, task_phase = []; end

% Close all previously opened screens
sca;

% Here we call some default settings for setting up Psychtoolbox
% The number passed indicate a 'featureLevel':
%   0 - execute the AssertOpenGL command
%   1 - additionally execute KbName( UnifyKeyNames’) to provide a
%       consistent mapping of keyCodes to key names on all operating 
%       systems.
%   2 - additionally imply the execution of
%       Screen( ColorRange , window, 1, [], 1) to allow normalization of
%       the color scheme when requested
PsychDefaultSetup(2);

% Use unified key names
KbName('UnifyKeyNames');

% Disable transmission of keypresses to Matlab
% To reenable keyboard input to Matlab, press CTRL+C
% This is the same as ListenChar(0)
ListenChar(2);

%% LOAD TASK PARAMETERS

if ~exist(param_fpath, 'file')
    disp('--- ERROR: ParamFileNotFound');
    disp(param_fpath);
    disp('The param file was not found.');
    disp('Did you start the experiment via STIM?');
    error('ParamFileNotFound');
end

% Load the initial param structure
param_load = load(param_fpath);

% Get path to the param file of the experimental phase:
%   Contains sound volume levels
param_fpath = get_param_fpath(param_load.param, exp_phase);

if ~exist(param_fpath, 'file')
    disp('--- ERROR: ParamFileNotFound');
    disp(param_fpath);
    disp(['The param file for the ', exp_phase, ' phase was not found.']);
    disp('Did you adjust the volume of the sounds?');
    error('ParamFileNotFound');
end

% !!! ADD CHECK FOR THE PREVIOUS ATTEMPTS OF THE SAME TASK !!!

% Load the param file of the current experimental phase
param_load = load(param_fpath);
param = param_load.param;
param.exp_phase = exp_phase;

if ~isempty(task_phase)
    param.task = [task_name '_phase' num2str(task_phase)];
else
    param.task = task_name;
end

%% TASK PARAMETERS & ORDER OF THE SEQUNECES

switch task_name

    case 'training'
        nbBlocksPerSeq = param.trainNbBlocksPerSeq(task_phase);
        nbSeqPerBlock = param.trainNbSeqPerBlock;
        maxNbBlocksSameSeq = param.trainMaxNbBlocksSameSeq;
        durRest = param.trainDurRest;
        durRestBetween = param.trainDurRestBetween;
        playSoundAsFeedback = 1;

    case 'test'
        nbBlocksPerSeq = param.testNbBlocksPerSeq;
        nbSeqPerBlock = param.testNbSeqPerBlock;
        maxNbBlocksSameSeq = param.testMaxNbBlocksSameSeq;
        durRest = param.testDurRest;
        durRestBetween = param.testDurRestBetween;
        playSoundAsFeedback = 0;

end 

% Create a vector with indices of soundHandSeq triples
% - the length of the vector is equal to the shortest 
inds_soundHandSeq = repelem(1:numel(param.soundHandSeq), nbBlocksPerSeq);

% Set the order of the soundHandSeq triples pseudorandomly so that the
% maximum number of consequitive repetitions of the same tripple is
% respected
NbBlocksSameSeq = Inf;
while NbBlocksSameSeq > maxNbBlocksSameSeq
    inds_order_soundHandSeq = randsample(inds_soundHandSeq, numel(inds_soundHandSeq));

    % Get the maximum number of repetitions for the same tripple/sequence
    %   For repeated index, the difference is 0
    %   So, we need to:
    %   1. Calculate the differences between consequitive indices
    %   2. Find positions of non-zero values, which indicate change
    %   3. Get the largest interval between the non-zero values
    NbBlocksSameSeq = max(diff(find([1, diff(inds_order_soundHandSeq), 1])));
end

%% INITIALIZE SOUND DRIVER & PRELOAD SOUNDS
%   The order of the preloaded sounds is the same as the order of the
%   sounds in soundHandSeq tripples in the param file

nrchannels = 2;     % 2 channels for stereo output
device = [];        % default sound device 

% Perform basic initialization of the sound driver
InitializePsychSound;

% Open the audio 'device' with default mode [] (== Only playback),
% and a required latencyclass of 1 == standard low-latency mode, as well as
% default playback frequency and 'nrchannels' sound output channels.
% This returns a handle 'pahandle' to the audio device
pahandle = PsychPortAudio('Open', device, [], 1, [], nrchannels);

% Get the full paths to the sound files
% The order is the same as in soundHandSeq
wav_fpaths = cell(1, numel(param.soundHandSeq));
for i_sound = 1:numel(param.soundHandSeq)
    wav_fpaths{i_sound} = fullfile(param.main_dpath, 'stimuli', param.soundHandSeq(i_sound).sound);
end

% Read all sound files, create & fill a dynamic audiobuffer for each
buffer = [];
for i_sound=1:length(wav_fpaths)
    [audiodata, ~] = psychwavread(char(wav_fpaths(i_sound)));
    [~, ninchannels] = size(audiodata);
    audiodata = repmat(transpose(audiodata), nrchannels / ninchannels, 1);
    buffer(end+1) = PsychPortAudio('CreateBuffer', [], audiodata);
end

%% KEY SETTINGS

% Restrict input keys to the valid keys only
[keyCodes4input, ~] = ld_keys4input(param);
RestrictKeysForKbCheck(keyCodes4input);

%% INIT TASKLOG

% A structure with the task log
tasklog = struct('desc', {}, 'onset', [], 'value', {}, 'digit', []);
tasklog(end+1).desc = 'date and time the task started';
tasklog(end).value = datestr(now);

%% DISPLAY SETTINGS

[window, screenSize, screenCenter] = ld_createWindow(param);

% Text font settings
Screen('TextFont', window, 'Arial');
Screen('TextSize', window, param.textSize);
gold = [255, 215, 0, 255];

%% GENERAL TASK INSTRUCTIONS

% Instructions to show; '\n' indicates a new line
titleLine = upper(task_name);
line1 = 'Red cross: wait for the task to start';
line2 = 'Green cross: do the task';
line_center = 'Perform the sequence \nas fast and accurately as possible'; % is displayed in the middle
footer = '... GET READY FOR THE TASK ...';

% Draw instructions
DrawFormattedText(window, ...
    titleLine, ...
    'center', screenSize(2)*0.15, gold);
DrawFormattedText(window, ...
    [line1, '\n', line2],...
    'centerblock', screenSize(2)*0.25, gold);

DrawFormattedText(window, ...
    line_center,...
    'center', 'center', gold);

% Get ready for the task
DrawFormattedText(window, ...
    footer, ...
    'center', screenSize(2)*0.9, gold);

% Wait for release of all keys on keyboard
KbReleaseWait;

% Show on the screen
Screen('Flip', window);

% Wait for TTL key (='5') to start the task
[quit, secs, ~, ~] = ld_keysWait4ttl();
if quit
    data_saved = 0;
    output_fpath = '';
    clear_and_close();
    return;
end

% Time the task started; is used as time 0
timeStartTask = secs;

% Display black screen for transition
Screen('FillRect', window, BlackIndex(window));
Screen('Flip', window);
WaitSecs(param.transScreenDur);

%% THE TASK

tasklog(end+1).desc = [param.task, '-start'];
tasklog(end).onset = GetSecs - timeStartTask;

try
    output_fpath = get_output_fpath(param);
    % Add the order of the soundHandSeq tripples to the param structure
    param.inds_order_soundHandSeq = inds_order_soundHandSeq;
    
    % Save
    data_saved = save_data(output_fpath, param, tasklog);

    % Performance blocks info:
    %   - Duration: from the sound onset until the end of the block
    %   - The number of sequences completed
    perf_blocks = struct('dur', [], 'n_seq', []);

    % --- REST BLOCK - START

    % Show the red cross for a specified time, update the tasklog
    [quit, tasklog] = rest_block(...
    timeStartTask, ...
    window, screenCenter, durRest, ...
    tasklog ...
    );

    % If quit, save & close
    if quit
       [data_saved] = quit_task(...
         'interrupted by the experimenter', 'esc', ...
        tasklog, timeStartTask, output_fpath, param ...
        );
        return;
    end

    % Display black screen for transition
    Screen('FillRect', window, BlackIndex(window));
    Screen('Flip', window);
    WaitSecs(param.transScreenDur);

    % --- THE TASK
    % Note that the sequence is shown only after the first two keys are
    % pressed correctly using the correct hand. This is verified in the
    % WHILE loop below.
    % All the recorded keypresses are saved each time the block is
    % completed

    % Do for each block
    for i_block = 1:numel(inds_order_soundHandSeq)

        % --- BLOCK SETUP   

        % Get soundHandSeq info
        i_soundHandSeq = inds_order_soundHandSeq(i_block);
        sound2play = buffer(i_soundHandSeq);
        vol2play = param.soundHandSeq(i_soundHandSeq).device_volume;
        hand = param.soundHandSeq(i_soundHandSeq).hand;
        seq = param.soundHandSeq(i_soundHandSeq).seq;

        tasklog(end+1).desc = ['block', num2str(i_block)];
        tasklog(end+1).desc = param.soundHandSeq(i_soundHandSeq).sound;
        tasklog(end+1).desc = 'device volume';
        tasklog(end).value = num2str(vol2play);
        tasklog(end+1).desc = hand.desc;
        tasklog(end+1).desc = 'seq';
        tasklog(end).digit = seq;


        disp('');
        disp(['BLOCK ', num2str(i_block)]);
        disp('---');
        disp(upper([hand.desc, ' hand']));
        disp(upper(['sequence: ', num2str(seq)]));
        disp(upper(['Sound file name: ' param.soundHandSeq(i_soundHandSeq).sound]));
        disp(upper(['Device volume: ' num2str(vol2play)]));

        % Set sound to play
        PsychPortAudio('FillBuffer', pahandle, sound2play);
        PsychPortAudio('Volume', pahandle, vol2play);

        % Valid input key-digit map
        % - are specific to the hand used in the current block
        digits4hand = hand.digits;
        keys4hand = hand.keys;
        digit2key_map = containers.Map(digits4hand, keys4hand);
        key2digit_map = containers.Map(keys4hand, digits4hand);

        % keyCodes & keyNames of the hand
        [keyCodes4hand, keyNames4hand] = ld_keys4input(param, hand.desc);

        % Convert the first two elements of the sequence to keys.
        %   Is used to determine if the initiation of the block was
        %   successful, i.e., participant used the correct hand and started
        %   typing the correct sequence
        keysStartSeq = {};
        for i = 1:2
            keysStartSeq{i} = digit2key_map(num2str(seq(i)));
        end
        
        isCorrectStart = 0;     % Requires both correct hand & correct
                                % start of the sequence
        waitMaxPassed = 1;

        while ~isCorrectStart || waitMaxPassed
            
            % Wait for release of all keys on keyboard
            KbReleaseWait;
            
            % --- INIT PERFORMANCE BLOCK
        
            % Is used to calculate the duration of the performance block
            perf.start = GetSecs - timeStartTask;

            % Digits that correspond to keys pressed during the current
            % performance block; are used to determine performance accuracy
            digits_perf_block = [];

            % Save to the task log
            tasklog(end+1).desc = 'perf-start';
            tasklog(end).onset = perf.start;

            % Play the sound
            PsychPortAudio('Start', pahandle, 1, 0, 1); % repetitions = 1
                    
            % Read the first two keys to identify if the hand and the
            % sequence correspond to the sound. 
            [quit, waitMaxPassed, targetKeysPressed, invalidKeyPressed, keysPressed, timePressed] = ld_displayCrossAndReadKeys(...
                window, screenCenter, [], 2, keyNames4hand, keysStartSeq, param.waitMax, 'green' ...
                );

            % If quit, save & close
            if quit
                [data_saved] = quit_task(...
                'interrupted by the experimenter', 'esc', ...
                tasklog, timeStartTask, output_fpath, param ...
                );
                return;
            end

            % Record the captured keys into tasklog
            if ~isempty(keysPressed)
                [tasklog, digitsPressed] = recordInput2tasklog(...
                    timeStartTask, tasklog, timePressed, keysPressed, key2digit_map ...
                    );
            end

            % The waitMax time is over
            if waitMaxPassed
                tasklog(end+1).desc = 'perf-incomplete';
                tasklog(end).value = 'time to respond passed';
                tasklog(end).onset = GetSecs - timeStartTask;
                msg = num2str(seq);
                footer = '... DID YOU FORGET THE SEQUENCE? LETS TRY AGAIN ...';
            
            else
                % Correct start of the sequence performed using the correct hand
                if all(targetKeysPressed)
                    isCorrectStart = 1;
                    digits_perf_block = [digits_perf_block, digitsPressed];
                
                % Wrong hand
                elseif invalidKeyPressed
                    tasklog(end+1).desc = 'perf-incomplete';
                    tasklog(end).value = 'wrong hand';
                    tasklog(end).onset = GetSecs - timeStartTask;
                    msg = ['Use the ' hand.desc ' hand'];
                    footer = '... WRONG HAND. LETS TRY AGAIN ...';

                % Wrong start of the sequence
                else
                    tasklog(end+1).desc = 'perf-incomplete';
                    tasklog(end).value = 'wrong hand';
                    tasklog(end).onset = GetSecs - timeStartTask;
                    msg = num2str(seq);
                    footer = '... DID YOU FORGET THE SEQUENCE? LETS TRY AGAIN ...';
                end
            end % IF waitMax time

            % The block was not completed and needs to be repeated
            if ~isCorrectStart || waitMaxPassed

                % Display black screen for transition
                Screen('FillRect', window, BlackIndex(window));
                Screen('Flip', window);
                WaitSecs(param.transScreenDur);

                % --- TRY AGAIN

                [quit, tasklog] = try_again_hint(...
                        timeStartTask, ...
                        window, screenCenter, param.hintDur, msg, param.textSize, footer, param.textSize, ...
                        tasklog ...
                        );

                % If quit, save & close
                if quit
                    [data_saved] = quit_task(...
                    'interrupted by the experimenter', 'esc', ...
                    tasklog, timeStartTask, output_fpath, param ...
                    );
                    return;
                end

                % --- REST BETWEEN PERFORMANCE BLOCKS
                    
                % Rest duration is fixed
                if numel(durRestBetween) == 1
                    durRest_tmp = durRestBetween;
                % Jittered rest duration
                else
                    durRest_tmp = randi(durRestBetween);
                end
    
                % Show the red cross for a specified time, update the tasklog
                [quit, tasklog] = rest_block(...
                timeStartTask, ...
                window, screenCenter, durRest_tmp, ...
                tasklog ...
                );
    
                % If quit, save & close
                if quit
                    [data_saved] = quit_task(...
                    'interrupted by the experimenter', 'esc', ...
                    tasklog, timeStartTask, output_fpath, param ...
                    );
                    return;
                end

            end % IF the block was not completed
   
        end % WHILE

        % --- COMPLETE PERFORMANCE BLOCK AFTER INITIATED SUCCESSFULLY

        %   At that point, the performace for the current block was
        %   correctly initiated with the correct first two keys of the
        %   sequence using the correct hand. The sequence will be shown on
        % the screen  for the rest of the block
        msg = num2str(seq);

        % Read the remaining keypresses [nbSeqPerBlock * numel(seq) - 2]
        %   The block terminates before it is completed if the delay
        %   between consequitive keypresses exeeds the waitMax time, and
        %   also if the 'ESC'button is pressed.

        [quit, waitMaxPassed, ~, ~, keysPressed, timePressed] = ld_displayCrossAndReadKeys(...
            window, screenCenter, [], nbSeqPerBlock*numel(seq) - 2, [], [], param.waitMax, 'green', [], msg ...
            );

            % If quit, save & close
            if quit
                [data_saved] = quit_task(...
                'interrupted by the experimenter', 'esc', ...
                tasklog, timeStartTask, output_fpath, param ...
                );
                return;
            end

            % Record the captured keys into tasklog
            if ~isempty(keysPressed)
                [tasklog, digitsPressed] = recordInput2tasklog(...
                    timeStartTask, tasklog, timePressed, keysPressed, key2digit_map ...
                    );
            end

        % The waitMax time is over
        if waitMaxPassed
            tasklog(end+1).desc = 'perf-incomplete';
            tasklog(end).value = 'time to respond passed';
        else            
            % Is used to calculate the duration of the performance block
            tasklog(end+1).desc = 'perf-end';
        end

        perf.end = GetSecs - timeStartTask;
        tasklog(end).onset = perf.end;

        % --- PERFORMANCE BLOCK SUMMARY
        
        % Duration of the performance block
        perf_blocks(i_block).dur = perf.end - perf.start;

        % Digits pressed
        digits_perf_block = [digits_perf_block, digitsPressed];

        % The number of completed sequences
        n_seq = numel(strfind(digits_perf_block, seq));
        perf_blocks(i_block).n_seq = n_seq;

        % Play sound feedback, if required, when all sequence repetitions
        % are completed correctly
        if playSoundAsFeedback && (n_seq == nbSeqPerBlock)
            PsychPortAudio('Start', pahandle, 1, 0, 1); % repetitions = 1
        end

        disp([ num2str(i_block), ' BLOCKS COMPLETED']);
        disp(['Durations (secs) ' num2str([perf_blocks(:).dur])]);
        disp(['Sequences (n)    ' num2str([perf_blocks(:).n_seq])]);
        disp('---');

        % Update the number of completed blocks & save the data 
        param.nbBlocksCompleted = i_block;
        data_saved = save_data(output_fpath, param, tasklog);

        % Display black screen for transition
        Screen('FillRect', window, BlackIndex(window));
        Screen('Flip', window);
        WaitSecs(param.transScreenDur);

        % --- REST BETWEEN PERFORMANCE BLOCKS

        % Is not the end of the very last block
        if i_block < numel(inds_order_soundHandSeq)
            
            % Rest duration is fixed
            if numel(durRestBetween) == 1
                durRest_tmp = durRestBetween;
            % Jittered rest duration
            else
                durRest_tmp = randi(durRestBetween);
            end

            % Show the red cross for a specified time, update the tasklog
            [quit, tasklog] = rest_block(...
            timeStartTask, ...
            window, screenCenter, durRest_tmp, ...
            tasklog ...
            );

            % If quit, save & close
            if quit
                [data_saved] = quit_task(...
                'interrupted by the experimenter', 'esc', ...
                tasklog, timeStartTask, output_fpath, param ...
                );
                return;
            end

        end % IF is not the end of the very last block

        % --- GO TO THE NEXT BLOCK OR FINISH

        % Display black screen for transition
        Screen('FillRect', window, BlackIndex(window));
        Screen('Flip', window);
        WaitSecs(param.transScreenDur);
    
    end % FOR each task block

    % --- REST BLOCK - END

    % Show the red cross for a specified time, update the tasklog
    [quit, tasklog] = rest_block(...
    timeStartTask, ...
    window, screenCenter, durRest, ...
    tasklog ...
    );

    % If quit, save & close
    if quit
       [data_saved] = quit_task(...
         'interrupted by the experimenter', 'esc', ...
        tasklog, timeStartTask, output_fpath, param ...
        );
        return;
    end
    
    % End the task session
    tasklog(end+1).desc = [param.task, '-end'];
    tasklog(end).onset = GetSecs - timeStartTask;

    % Save all, clear, & close
    data_saved = save_data(output_fpath, param, tasklog);
    clear_and_close();

catch ME
    disp(['ID: ' ME.identifier]);
    [data_saved] = quit_task(...
    'something went wrong', ME.identifier, ...
    tasklog, timeStartTask, output_fpath, param ...
    );
    rethrow(ME);
end

end

%% UTILS

% --- Show the red cross for a specified time, & update the tasklog
function [quit, tasklog] = rest_block(...
        timeStartTask, ...
        window, screenCenter, durRest, ...
        tasklog ...
        )

    % record to tasklog
    tasklog(end+1).desc = 'rest-start';
    tasklog(end).onset = GetSecs - timeStartTask;

    [quit, ~, ~, ~, keysPressed, timePressed] = ld_displayCrossAndReadKeys(...
        window, screenCenter, durRest, [], [], [], [], 'red'...
        );

        % Record the captured keys into tasklog & save
        if ~isempty(keysPressed)
            [tasklog, ~] = recordInput2tasklog(...
                timeStartTask, tasklog, timePressed, keysPressed ...
                );
        end

    % End rest block
    if ~quit
        tasklog(end+1).desc = 'rest-end';
        tasklog(end).onset = GetSecs - timeStartTask;
    end

end


% --- Show the red cross for a specified time, & update the tasklog
function [quit, tasklog] = try_again_hint(...
        timeStartTask, ...
        window, screenCenter, hintDur, msg, msgTxtSize, footer, footerTxtSize, ...
        tasklog ...
        )

    % record to tasklog
    tasklog(end+1).desc = 'hint-start';
    tasklog(end).onset = GetSecs - timeStartTask;

    [quit, ~, ~, ~, keysPressed, timePressed] = ld_displayCrossAndReadKeys(...
        window, screenCenter, hintDur, [], [], [], [], ...
        'red', [], msg, 'gold', msgTxtSize, footer, 'gold', footerTxtSize ...
        );

        % Record the captured keys into tasklog & save
        if ~isempty(keysPressed)
            [tasklog, ~] = recordInput2tasklog(...
                timeStartTask, tasklog, timePressed, keysPressed ...
                );
        end

    % End hint dispay
    if ~quit
        tasklog(end+1).desc = 'hint-end';
        tasklog(end).onset = GetSecs - timeStartTask;
    end

end

% --- Get full path to the param file of the current experimental phase
function param_fpath = get_param_fpath(param, exp_phase)
    param_fpref = [param.subject, '_',  exp_phase, '_param_'];
    i_name = 0;
    file_exist = 1;
    while file_exist
        file_exist = exist(...
            fullfile(param.output_dpath, ...
            [param.subject, '_',  exp_phase, '_param_', num2str(i_name+1), '.mat']), ...
            'file' ...
            );
        i_name = i_name+1;
    end
    param_fpath = fullfile(param.output_dpath, [param_fpref, num2str(i_name-1), '.mat']);
end


% --- Get full path to save the output
function output_fpath = get_output_fpath(param)
    i_name = 1;
    output_fpath = fullfile(param.output_dpath, ...
        [param.subject, '_',  param.exp_phase, '_', param.task '_', num2str(i_name), '.mat']);

    while exist(output_fpath, 'file')
        i_name = i_name+1;
    output_fpath = fullfile(param.output_dpath, ...
        [param.subject, '_',  param.exp_phase, '_', param.task '_', num2str(i_name), '.mat']);
    end
end

% --- Save the output
function data_saved = save_data(output_fpath, param, tasklog)
    save(output_fpath, 'param', 'tasklog');
    data_saved = 1;
end


% --- Record input data into tasklog
function [tasklog, digitsPressed] = recordInput2tasklog(...
    timeStartTask, tasklog, timePressed, keysPressed, key2digit_map ...
    )

    if nargin < 5, key2digit_map = []; end

    onsets2cell = num2cell(timePressed - timeStartTask);    
    inds_tasklog = (numel(tasklog)+1) : (numel(tasklog)+numel(keysPressed));
    [tasklog(inds_tasklog).desc] = deal('input');
    [tasklog(inds_tasklog).onset] = onsets2cell{:};
    [tasklog(inds_tasklog).value] = keysPressed{:};
    
    digitsPressed = [];

    % Get digits if key2digit map is given
    if ~isempty(key2digit_map)
        digitsPressed = ld_keys2digits(keysPressed, key2digit_map);
        digitsPressed2cell = num2cell(digitsPressed);
        [tasklog(inds_tasklog).digit] = digitsPressed2cell{:};
    end
end


% --- Clear all and close
function clear_and_close()
    Priority(0);
    % Enable transmission of keyboard input to Matlab
    ListenChar(0);
    % Reset input keys
    RestrictKeysForKbCheck([]);
    % Clean & close audio facilities
    PsychPortAudio('DeleteBuffer');
    PsychPortAudio('Close');
    % Clean & close all screens
    sca;
end

% --- Quit task
function [data_saved] = quit_task(...
    quit_desc, quit_value, ...
    tasklog, timeStartTask, output_fpath, param ...
    )
    % Update tasklog
    tasklog(end+1).desc = quit_desc;
    tasklog(end).onset = GetSecs - timeStartTask;
    tasklog(end).value = quit_value;
    % Save, clear, & close
    data_saved = save_data(output_fpath, param, tasklog);
    clear_and_close();
end




