function [quit, data_saved, output_fpath] = tmr_msl_intro3_handSeq(param_fpath, exp_phase, task_name)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [quit, data_saved, output_fpath] = tmr_msl_intro3_handSeq(param_fpath, exp_phase, task_name)
% Introduction of the sequences:
%   Each sequence is associated with a different hand accoridng to the
%   sound-hand-triple generated at the beginning of the experiment (stored
%   in param.soundHandSeg). The task is repeated for each hand-sequence
%   until the sequence is performed correctly three times in a row.
%
% INPUT
%   param       structure containing parameters (see get_param....m)
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
[keyCodes4check, ~] = ld_getKeys4check(param);
RestrictKeysForKbCheck(keyCodes4check);

% A structure with the task log
tasklog = struct('desc', {}, 'onset', [], 'value', {});
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
titleLine = 'INTRODUCTION OF THE SEQUENCES';
line1 = 'You will need to perform a sequence repeatedly';
line2 = 'in a comfortable pace as accurately as possible';

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
[quit, ~, ~] = ld_keysWait4ttl();
if quit
    data_saved = 0;
    output_fpath = '';
    clear_and_close();
    return;
end

% Display black screen for transition
Screen('FillRect', window, BlackIndex(window));
Screen('Flip', window);
WaitSecs(param.transScreenDur);

%% HAND-SEQUENCE INTRO

% Time the task started; is used as time 0
timeStartTask = GetSecs;

tasklog(end+1).desc = [param.task, '-start'];
tasklog(end).onset = GetSecs - timeStartTask;

try
    output_fpath = get_output_fpath(param);

    % Set the order of the soundHandSeq triples via random sampling
    inds_rnd = randsample(1:numel(param.soundHandSeq), numel(param.soundHandSeq));

    for i_rnd = 1:numel(inds_rnd)
        i_soundHandSeq = inds_rnd(i_rnd);
        hand = param.soundHandSeq(i_soundHandSeq).hand;
        seq = param.soundHandSeq(i_soundHandSeq).seq;

        if strcmp(hand.desc, 'left')
            imageTexture = Screen('MakeTexture', window, img_left);
        elseif strcmp(hand.desc, 'right')
            imageTexture = Screen('MakeTexture', window, img_right);
        end

        % Key-digit map
        digits = hand.digits;
        keys = hand.keys;
        key2digit_map = containers.Map(keys, digits);

        % --- HAND-SEQUENCE INSTRUCTIONS

        titleLine = num2str(seq);
        line1 = 'Red cross: wait for the task to start';
        line2 = 'Green cross: do the task';
        footer = '... GET READY FOR THE TASK ...';
        
        isCorrectHand = 0;

        while ~isCorrectHand

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
            KbReleaseWait;

            % --- LETS GO ...

            % The sequence is shown only after the first correct key is pressed
            % It should correspond to the first element of the sequence
            % using the corresponding hand
            msg = [];
            count_seq = 0;
            i_element = 0;

            % Show on the screen
            Screen('Flip', window);
    
            tasklog(end+1).desc = hand.desc;
            tasklog(end).onset = GetSecs - timeStartTask;
            tasklog(end).value = seq;
    
            % Wait for TTL key (='5') to start the task
            [quit, ~, ~] = ld_keysWait4ttl();
            if quit
                data_saved = 0;
                output_fpath = [];
                clear_and_close();
                return;
            end
                        
            % Wait for release of all keys on keyboard
            KbReleaseWait;

            % --- REST BLOCK

            % Show the red cross for a specified time, update the tasklog
            [quit, tasklog] = rest_block(...
            timeStartTask, ...
            window, screenCenter, param.introDurRest, ...
            tasklog, keys, key2digit_map ...
            );

            % IF quit, save & close
            if quit
                [data_saved] = quit_task(...
                'Interrupted by the experimenter', 'esc', ...
                tasklog, timeStartTask, output_fpath, param ...
                );
                return;
            end
            
            % --- PERFORMANCE BLOCK
    
            % Display black screen for transition
            Screen('FillRect', window, BlackIndex(window));
            Screen('Flip', window);
            WaitSecs(param.transScreenDur);
    
            % Save to the task log
            tasklog(end+1).desc = 'perf-start';
            tasklog(end).onset = GetSecs - timeStartTask;
    
            while count_seq < param.introNbSeq
                i_element = i_element +1;
                
                % Wait for release of all keys on keyboard
                KbReleaseWait;
        
                % Display the sequence & read one key at a time
                % Press 'ESC' to exit
                [quit, waitMaxPassed, ~, keysPressed, timePressed] = ld_displayCrossAndReadKeys(...
                    window, screenCenter, [], 1, [], param.maxTime2resp, [], 'green', [], msg ...
                    );

                % IF quit, save & close
                if quit
                [data_saved] = quit_task(...
                'Interrupted by the experimenter', 'esc', ...
                tasklog, timeStartTask, output_fpath, param ...
                );
                    return;
                end
        
                % Save to the task log
                if ~waitMaxPassed
                    tasklog(end+1).desc = 'digitPressed';
                    tasklog(end).onset = timePressed - timeStartTask;
                   
                    % Convert keys to digits
                    keyPressed = keysPressed{1}(1);
                
                    % Correct hand
                    if any(ismember(keys, keyPressed))
                        digitPressed = key2digit_map(keyPressed);
                        tasklog(end).value = digitPressed;
                        isCorrectHand = 1;
                        msg = num2str(seq);
                    % Wrong hand
                    else
                        tasklog(end).value = keysPressed{1};
                        footer = '... WRONG HAND, LETS TRY AGAIN ...';
                        break;
                    end
                end
    
                % Digit or key pressed
                disp(['Digit or key pressed: ' tasklog(end).value])
    
                % Correct sequence element
                if str2double(digitPressed) == seq(i_element)     
                    % Sequence completed, count it
                    if i_element == numel(seq)
                        count_seq = count_seq + 1;
                        i_element = 0;
                    end
                % Reset sequence count
                else
                    count_seq = 0;
                    i_element = 0;
                end
            end
                        
            % End performance block
            tasklog(end+1).desc = 'perf-end';
            tasklog(end).onset = GetSecs - timeStartTask;
   
        end % WHILE

        % Display black screen for transition
        Screen('FillRect', window, BlackIndex(window));
        Screen('Flip', window);
        WaitSecs(param.transScreenDur);

        % --- REST BLOCK

        % Show the red cross for a specified time, update the tasklog
        [quit, tasklog] = rest_block(...
        timeStartTask, ...
        window, screenCenter, param.introDurRest, ...
        tasklog, keys, key2digit_map ...
        );

        % IF quit, save & close
        if quit
            [data_saved] = quit_task(...
            'Interrupted by the experimenter', 'esc', ...
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

% Something went wrong
catch ME
    disp(['ID: ' ME.identifier]);
    [data_saved] = quit_task(...
        'Something went wrong', ME.identifier, ...
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
        tasklog, keys, key2digit_map ...
        )

    % Save to the task log
    tasklog(end+1).desc = 'rest-start';
    tasklog(end).onset = GetSecs - timeStartTask;

    [quit, ~, ~, keysPressed, timePressed] = ld_displayCrossAndReadKeys(...
        window, screenCenter, durRest, [], [], [], [], 'red'...
        );

    % Save to the task log
    for i = 1:numel(keysPressed)
        tasklog(end+1).desc = 'digitPressed';
        tasklog(end).onset = timePressed(i) - timeStartTask;            
        % convert key to digit, if possible
        keyPressed = keysPressed{i}(1);
        if any(ismember(keys, keyPressed))
            tasklog(end).value = key2digit_map(keyPressed);
        else
            tasklog(end).value = keysPressed{i};
        end
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



