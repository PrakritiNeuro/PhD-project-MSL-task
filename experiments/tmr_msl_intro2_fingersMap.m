function [quit, data_saved, output_fpath] = tmr_msl_intro2_fingersMap(param_fpath, exp_phase, task_name)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [quit, data_saved, output_fpath] = tmr_msl_intro2_fingersMap(param_fpath, exp_phase, task_name)
% Introduction of the digits assosiated with each finger:
%   The verification is done for each hand, in a random order, and
%   continues till all four buttons were pressed correctly in a row
%   according to the digits presented on the screen (random order).
%
% INPUT
%   param_fpath     [string]    full path to the param file of the
%                               participant; if it doesn't exist the
%                               program throws an error
%   exp_phase       [string]    the phase of the experiment
%                               e.g., 'PreSleep', 'PostSleep'
%   task_name       [string]    task name, e.g., 'intro2_fingersMap'
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
    warning(param_fpath);
    warning("The param file was not found. Did you start the experiment via STIM?");
    error('ParamFileNotFound');
end

param_load = load(param_fpath);
param = param_load.param;
param.exp_phase = exp_phase;
param.task = task_name;

%% PRELOAD THE IMAGES

img_both = imread(fullfile(param.main_dpath, 'stimuli', 'both_hands.png'));
img_left = imread(fullfile(param.main_dpath, 'stimuli', 'left_hand.png'));
img_right = imread(fullfile(param.main_dpath, 'stimuli', 'right_hand.png'));

%% INIT

% Restrict input keys to the valid keys only
[keyCodes4input, ~] = ld_keys4input(param);
RestrictKeysForKbCheck(keyCodes4input);

% Hands
if strcmp(param.hands(1).desc, 'left')
    left = 1;
    right = 2;
else
    left = 2;
    right = 1;
end


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

%% TASK INSTRUCTIONS

% Instructions to show; '\n' indicates a new line
titleLine = 'KEY-FINGER MAPPING';
line1 = 'You will need to press a key according';
line2 = 'to the number presented on the screen:';

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
KbReleaseWait([]);

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

%% KEY-FINGER MAPPING

tasklog(end+1).desc = [param.task, '-start'];
tasklog(end).onset = GetSecs - timeStartTask;

try
    output_fpath = get_output_fpath(param);

    % Set the order of the hands via random sampling
    hands_rnd = randsample(1:numel(param.hands), numel(param.hands));

    for i_hand = 1:numel(hands_rnd)

        % Keys & digits of the hand
        % - are specific to the hand used in the current block
        digits4hand = param.hands(hands_rnd(i_hand)).digits;
        keys4hand = param.hands(hands_rnd(i_hand)).keys;
        digit2key_map = containers.Map(digits4hand, keys4hand);
        key2digit_map = containers.Map(keys4hand, digits4hand);
    
        % Image texture
        if hands_rnd(i_hand) == left
            hand_str = 'left';
            titleLine = 'LEFT-HAND';
            imageTexture = Screen('MakeTexture', window, img_left);
        elseif hands_rnd(i_hand) == right
            hand_str = 'right';
            titleLine = 'RIGHT-HAND';
            imageTexture = Screen('MakeTexture', window, img_right);
        end

        % Instructions
        line1 = 'Red cross: wait for the task to start';
        line2 = 'Green cross: do the task';
        footer = '... GET READY FOR THE TASK ...';
        
        % Draw the hand; the image is drawn in the center of the screen
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
            footer,...
            'center', screenSize(2)*0.9, gold);
        
        % Wait for release of all keys on keyboard
        KbReleaseWait([]);

        % --- LETS GO ...
    
        % Show on the screen
        Screen('Flip', window);

        tasklog(end+1).desc = hand_str;
        tasklog(end).onset = GetSecs - timeStartTask;

        % Wait for TTL key (='5') to start the task
        [quit, ~, ~, ~] = ld_keysWait4ttl();
        if quit
            data_saved = 0;
            output_fpath = [];
            clear_and_close();
            return;
        end
                        
        % Wait for release of all keys on keyboard
        KbReleaseWait([]);

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

        % --- PERFORMANCE BLOCK
                
        digits_rnd = randsample(digits4hand, numel(digits4hand));
        i_digit = 0;

        % Display black screen for transition
        Screen('FillRect', window, BlackIndex(window));
        Screen('Flip', window);
        WaitSecs(param.transScreenDur);
    
        % Save to the task log
        tasklog(end+1).desc = 'perf-start';
        tasklog(end).onset = GetSecs - timeStartTask;
    
        while i_digit < numel(digits_rnd)

            targetDigit = digits_rnd{i_digit+1};
            % Get the target key that corresponds to the digit
            targetKey = digit2key_map(targetDigit);
        
            % Create a message to display
            msg = ['PRESS ', targetDigit];

            % Wait for release of all keys on keyboard
            KbReleaseWait([]);

            tasklog(end+1).desc = ['target-', targetDigit];
            tasklog(end).onset = GetSecs - timeStartTask;
            
            % Display the target digit & read the keys until it is captured.
            %  Exits if the delay between consequitive keypresses if it
            %  exceeds the waitMax time or if the 'ESC' button is pressed.
            % 
            [quit, waitMaxPassed, targetKeyPressed, ~, keysPressed, timePressed] = ld_displayCrossAndReadKeys(...
                window, screenCenter, [], [], [], targetKey, param.waitMax, 'green', [], msg ...
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
                tasklog = recordInput2tasklog(...
                    timeStartTask, tasklog, timePressed, keysPressed, key2digit_map ...
                    );
            end
    
            if ~waitMaxPassed
                % Only the target key was pressed
                if targetKeyPressed && numel(keysPressed)
                    i_digit = i_digit + 1;

                else
                    % Set digits order using random sampling
                    digits_rnd = randsample(digits4hand, numel(digits4hand));
                    i_digit = 0;
                end
           
            % The waitMax time is over
            else
                % Save to the task log
                tasklog(end+1).desc = 'target-incomplete';
                tasklog(end).onset = GetSecs - timeStartTask;
                tasklog(end).value = 'time to respond passed';

                % Set digits order using random sampling
                digits_rnd = randsample(digits4hand, numel(digits4hand));
                i_digit = 0;

            end % IF waitMaxPassed

            % Display black screen for transition
            Screen('FillRect', window, BlackIndex(window));
            Screen('Flip', window);
            WaitSecs(param.transScreenDur);

        end

        % End of performance block
        tasklog(end+1).desc = 'perf-end';
        tasklog(end).onset = GetSecs - timeStartTask;
    
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

        % --- GO TO THE NEXT

        % Display black screen for transition
        Screen('FillRect', window, BlackIndex(window));
        Screen('Flip', window);
        WaitSecs(param.transScreenDur);

    end % FOR each hand
    
    % End session
    tasklog(end+1).desc = [param.task, '-end'];
    tasklog(end).onset = GetSecs - timeStartTask;

    % Save all, clear, & close
    data_saved = save_data(output_fpath, param, tasklog);
    clear_and_close();

% Something went wrong
catch ME
    disp(['ID: ' ME.identifier]);
    [data_saved] = quit_task(...
    'something went wrong', ME.identifier, ...
    tasklog, timeStartTask, output_fpath, param ...
    );

    rethrow(ME);
end

end

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
            tasklog = recordInput2tasklog(...
                timeStartTask, tasklog, timePressed, keysPressed ...
                );
        end

    % End rest block
    if ~quit
        tasklog(end+1).desc = 'rest-end';
        tasklog(end).onset = GetSecs - timeStartTask;
    end

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
function tasklog = recordInput2tasklog(...
    timeStartTask, tasklog, timePressed, keysPressed, key2digit_map ...
    )

    if nargin < 5, key2digit_map = []; end

    onsets2cell = num2cell(timePressed - timeStartTask);    
    inds_tasklog = (numel(tasklog)+1) : (numel(tasklog)+numel(keysPressed));
    [tasklog(inds_tasklog).desc] = deal('input');
    [tasklog(inds_tasklog).onset] = onsets2cell{:};
    [tasklog(inds_tasklog).value] = keysPressed{:};
    
    % Get digits if key2digit map is given
    if ~isempty(key2digit_map)
        digitsPressed = ld_keys2digits(keysPressed, key2digit_map);
        digitsPressed2cell = num2cell(digitsPressed);
        [tasklog(inds_tasklog).digit] = digitsPressed2cell{:};
    end
end


% --- Clear all and close
function clear_and_close()
    % Enable transmission of keypresses to Matlab
    ListenChar(0);
    % Reset input keys
    RestrictKeysForKbCheck([]);
    % Close all screens
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




