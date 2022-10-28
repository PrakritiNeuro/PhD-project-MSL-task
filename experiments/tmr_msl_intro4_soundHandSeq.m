function [quit, data_saved, output_fpath] = tmr_msl_intro4_soundHandSeq(param_fpath, exp_phase, task_name)
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
%   task_name       [string]    task name, e.g., 'intro4_soundHandSeq'
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

% Load the param file of the current experimental phase
param_load = load(param_fpath);
param = param_load.param;
param.exp_phase = exp_phase;
param.task = task_name;

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

if strcmp(param.hands(1).desc, 'left')
    left = 1;
    right = 2;
else
    left = 2;
    right = 1;
end

% index for index fingers:
%  Is used to play the sound during the instructions
indexFinger = 1;

keyPlay = {param.hands(left).keys{indexFinger}, param.hands(right).keys{indexFinger}};

%% PRELOAD THE IMAGES

img_both = imread(fullfile(param.main_dpath, 'stimuli', 'both_hands.png'));
img_left = imread(fullfile(param.main_dpath, 'stimuli', 'left_hand.png'));
img_right = imread(fullfile(param.main_dpath, 'stimuli', 'right_hand.png'));

%% INIT TASKLOG

% A structure with the task log
tasklog = struct('desc', {}, 'onset', [], 'value', {}, 'digit', []);
tasklog(end+1).desc = 'Date and time the task started';
tasklog(end).value = datestr(now);

%% DISPLAY SETTINGS

[window, screenSize, screenCenter] = ld_createWindow(param);

% Text font settings
Screen('TextFont', window, 'Arial');
Screen('TextSize', window, param.textSize);
gold = [255, 215, 0, 255];

%% GENERAL TASK INSTRUCTIONS

% Instructions to show; '\n' indicates a new line
titleLine = 'SOUND-HAND-SEQUENCE ASSOCIATION';
line1 = 'You will need to remember sound-hand-sequence association';
line2 = 'Perform the sequence in a comfortable pace as accurately as possible';

% Draw two hands; the image is drawn in the center of the screen
imageTexture = Screen('MakeTexture', window, img_both);
rectCenter = [screenCenter(1), screenCenter(2) * 1.2];
dest_rect = ld_getDrawRect(imageTexture,screenSize, rectCenter);
Screen('DrawTexture', window, imageTexture, [], dest_rect);

% Draw instructions
DrawFormattedText(window, ...
    titleLine, ...
    'center', screenSize(2)*0.15, gold);
DrawFormattedText(window, ...
    [line1, '\n', line2],...
    'centerblock', screenSize(2)*0.25, gold);

% Get ready for the task
DrawFormattedText(window, ...
    '... GET READY FOR THE TASK ...',...
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

%% SOUND-HAND-SEQUENCE INTRO

tasklog(end+1).desc = [param.task, '-start'];
tasklog(end).onset = GetSecs - timeStartTask;

try
    output_fpath = get_output_fpath(param);

    % Set the order of the soundHandSeq triples via random sampling
    inds_rnd = randsample(1:numel(param.soundHandSeq), numel(param.soundHandSeq));

    for i_rnd = 1:numel(inds_rnd)

        % Get soundHandSeq info
        i_soundHandSeq = inds_rnd(i_rnd);
        sound2play = buffer(i_soundHandSeq);
        vol2play = param.soundHandSeq(i_soundHandSeq).device_volume;
        hand = param.soundHandSeq(i_soundHandSeq).hand;
        seq = param.soundHandSeq(i_soundHandSeq).seq;

        tasklog(end+1).desc = param.soundHandSeq(i_soundHandSeq).sound;
        tasklog(end).value = ['device volume: ', num2str(vol2play)];
        tasklog(end+1).desc = hand.desc;
        tasklog(end).value = ['Seq: ', num2str(seq)];

        disp('---');
        disp(upper([hand.desc, ' hand: ', num2str(seq)]));
        disp(upper(['Sound file name: ' param.soundHandSeq(i_soundHandSeq).sound]));
        disp(upper(['Device volume: ' num2str(vol2play)]));

        % Set sound to play
        PsychPortAudio('FillBuffer', pahandle, sound2play);
        PsychPortAudio('Volume', pahandle, vol2play);

        % Set imageTexture of the hand
        if strcmp(hand.desc, 'left')
            imageTexture = Screen('MakeTexture', window, img_left);
        elseif strcmp(hand.desc, 'right')
            imageTexture = Screen('MakeTexture', window, img_right);
        end

        % Valid input key-digit map
        % - are specific to the hand used in the current block
        digits4hand = hand.digits;
        keys4hand = hand.keys;
        digit2key_map = containers.Map(digits4hand, keys4hand);
        key2digit_map = containers.Map(keys4hand, digits4hand);

        % keyCodes & keyNames of the hand
        [keyCodes4hand, keyNames4hand] = ld_keys4input(param, hand.desc);

        % Convert the first two elements of the sequence to keys
        %   Is used to determine if the initiation of the block was
        %   successful, i.e., participant used the correct hand and started
        %   typing the correct sequence
        keysStartSeq = {};
        for i = 1:2
            keysStartSeq{i} = digit2key_map(num2str(seq(i)));
        end

        % --- SOOUND-HAND-SEQUENCE INSTRUCTIONS

        titleLine = num2str(seq);
        line1 = 'Red cross: wait for the task to start';
        line2 = 'White cross: listen to the sound';
        line3 = 'Green cross: do the task';
        footer = '... GET READY FOR THE TASK ...';
        
        isCorrectStart = 0;     % Requires both correct hand & correct
                                % start of the sequence
        waitMaxPassed = 1;

        while ~isCorrectStart || waitMaxPassed

            % Draw the hand; the image is drawn in the center of the screen
            rectCenter = [screenCenter(1), screenCenter(2) * 1.2];
            dest_rect = ld_getDrawRect(imageTexture,screenSize, rectCenter);
            Screen('DrawTexture', window, imageTexture, [], dest_rect);
        
            % Draw instructions
            DrawFormattedText(window, ...
                titleLine, ...
                'center', screenSize(2)*0.15, gold);
            DrawFormattedText(window, ...
                [line1, '\n', line2 '\n' line3],...
                'centerblock', screenSize(2)*0.25, gold);
        
            % Get ready for the task
            DrawFormattedText(window, ...
                footer,...
                'center', screenSize(2)*0.9, gold);
            
            % Wait for release of all keys on keyboard
            KbReleaseWait;

            % --- LETS GO ...

            % Show on the screen
            Screen('Flip', window);
            WaitSecs(1);

            % Play the sound
            PsychPortAudio('Start', pahandle, 1, 0, 1); % repetitions = 1

            tasklog(end+1).desc = 'instructions-start';
            tasklog(end).onset = GetSecs - timeStartTask;
    
            % Wait for TTL key (='5') to start the task
            quit = 0;
            ttlKeyPressed = 0;
            while ~quit && ~ ttlKeyPressed
                [quit, ~, ttlKeyPressed, key2readPressed] = ld_keysWait4ttl(keyPlay);

                if quit
                    data_saved = 0;
                    output_fpath = [];
                    clear_and_close();
                    return;
                end

                if key2readPressed
                    % Play the sound
                    PsychPortAudio('Start', pahandle, 1, 0, 1); % repetitions = 1
                end
            end

            tasklog(end+1).desc = 'instructions-end';
            tasklog(end).onset = GetSecs - timeStartTask;
                        
            % Wait for release of all keys on keyboard
            KbReleaseWait;

            % --- REST BLOCK

            % Show the red cross for a specified time, update the tasklog
            [quit, tasklog] = rest_block(...
            timeStartTask, ...
            window, screenCenter, param.introDurRest, ...
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

            % --- INIT PERFORMANCE BLOCK
    
            % Save to the task log
            tasklog(end+1).desc = 'perf-start';
            tasklog(end).onset = GetSecs - timeStartTask;

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
                [tasklog, ~] = recordInput2tasklog(...
                    timeStartTask, tasklog, timePressed, keysPressed, key2digit_map ...
                    );
            end

            % The waitMax time is over
            if waitMaxPassed
                tasklog(end+1).desc = 'perf-incomplete';
                tasklog(end).value = 'time to respond passed';
                tasklog(end).onset = GetSecs - timeStartTask;
                footer = '... DID YOU FORGET THE SEQUENCE? LETS TRY AGAIN ...';
            
            else

                % Correct start of the sequence performed using the correct hand
                if all(targetKeysPressed)
                    isCorrectStart = 1;
                    msg = num2str(seq);
                
                % Wrong hand
                elseif invalidKeyPressed
                    tasklog(end+1).desc = 'perf-incomplete';
                    tasklog(end).value = 'wrong hand';
                    tasklog(end).onset = GetSecs - timeStartTask;
                    footer = '... WRONG HAND, LETS TRY AGAIN ...';

                % Wrong start of the sequence
                else
                    tasklog(end+1).desc = 'perf-incomplete';
                    tasklog(end).value = 'wrong hand';
                    tasklog(end).onset = GetSecs - timeStartTask;
                    footer = '... DID YOU FORGET THE SEQUENCE? LETS TRY AGAIN ...';
                end
            end % IF waitMax time


            % --- THE REST OF THE BLOCK AFTER SUCCESSFUL START

            if isCorrectStart && ~waitMaxPassed

                %   At that point, the performace for the current block was
                %   correctly initiated with the correct first two keys of the
                %   sequence using the correct hand. The sequence will be shown on
                % the screen  for the rest of the block
                msg = num2str(seq);
                count_seq = 0;
                i_element = 2; % the first two sequence elements are correct

                % Read the remaining keypresses, one key at a time. To complete
                % the block, the sequnce should be repeated correctly a given
                % number of time in a row. The block terminates before it is
                % completed if the delay between consequitive keypresses exeeds 
                % the waitMax time, and also if the 'ESC'button is pressed.

                while count_seq < param.introNbSeq
                    i_element = i_element +1;
                
                    % Read the remaining keypresses, one key at a time.
                    [quit, waitMaxPassed, ~, ~, keysPressed, timePressed] = ld_displayCrossAndReadKeys(...
                        window, screenCenter, [], 1, [], [], param.waitMax, 'green', [], msg ...
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
                        footer = '... TIME TO RESPOND IS OVER. LETS TRY AGAIN ...';
                        break;
                    end

                    % Correct sequence element
                    if numel(digitsPressed) == 1 && ...
                        digitsPressed == seq(i_element)     
                        % Sequence completed, count it
                        if i_element == numel(seq)
                            count_seq = count_seq + 1;
                            i_element = 0;
                        end
        
                    % Incorrect sequence element; reset sequence count
                    else
                        count_seq = 0;
                        i_element = 0;
                    end    
                end
            end % If performace initiation was successful

        end % WHILE performace initiation of the sequence failed or waitMax time passed
   
        tasklog(end+1).desc = 'perf-end';
        tasklog(end).onset = GetSecs - timeStartTask;

        % Display black screen for transition
        Screen('FillRect', window, BlackIndex(window));
        Screen('Flip', window);
        WaitSecs(param.transScreenDur);


        % --- REST BLOCK

        % Show the red cross for a specified time, update the tasklog
        [quit, tasklog] = rest_block(...
        timeStartTask, ...
        window, screenCenter, param.introDurRest, ...
        tasklog ...
        );

        % IF quit, save & close
        if quit
            [data_saved] = quit_task(...
            'interrupted by the experimenter', 'esc', ...
            tasklog, timeStartTask, output_fpath, param ...
            );
            return;
        end

        % --- GO TO NEXT

        % Display black screen for transition
        Screen('FillRect', window, BlackIndex(window));
        Screen('Flip', window);
        WaitSecs(param.transScreenDur);
    
    end % FOR each soundHandSequence triple
    
    % End session
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

% --- Show the red cross for a specified time & update the tasklog
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




