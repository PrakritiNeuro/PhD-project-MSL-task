function [quit, data_saved, output_fpath] = ld_introFingerMapping(param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% returnCode = ld_introFingerMapping(param)
%
% Verifying if correct button is pressed for each finger
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

% Disable transmission of keypresses to Matlab
% To reenable keyboard input to Matlab, press CTRL+C
% This is the same as ListenChar(0)
ListenChar(2);

%% PRELOAD THE IMAGES

img_both = imread(fullfile(param.main_dpath, 'stimuli', 'both_hands.png'));
img_left = imread(fullfile(param.main_dpath, 'stimuli', 'left_hand.png'));
img_right = imread(fullfile(param.main_dpath, 'stimuli', 'right_hand.png'));

%% INIT

% Hands' indices
left = 1;
right = 2;

% Set the order of the hands via random sampling
hands_rnd = randsample(1:numel(param.hands), numel(param.hands));

% A structure with the task log
tasklog = struct('desc', {}, 'onset', [], 'value', {});

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
dest_rect = ld_get_dest_rect(imageTexture,screenSize, rectCenter);
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

% Wait for TTL or keyboard input to start the task
[quit, ~] = ld_keys_wait4ttl();
if quit
    data_saved = 0;
    output_fpath = '';
    clear_and_close();
    return;
end

% Display black screen for transition
Screen('FillRect', window, BlackIndex(window));
Screen('Flip', window);
pause(0.5);

%% KEY-FINGER MAPPING

% Time the task started; is used as time 0
timeStartTask = GetSecs;

tasklog(end+1).desc = [param.task, '-start'];
tasklog(end).onset = GetSecs - timeStartTask;

try
    output_fpath = get_output_fpath(param);

    for i_hand = 1:numel(hands_rnd)
        % Key-digit map
        digits = param.hands(hands_rnd(i_hand)).digits;
        keys = param.hands(hands_rnd(i_hand)).keys;
        digits2keys_map = containers.Map(digits, keys);
    
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
        
        % Draw the hand; the image is drawn in the center of the screen
        rectCenter = [screenCenter(1), screenCenter(2) * 1.2];
        dest_rect = ld_get_dest_rect(imageTexture,screenSize, rectCenter);
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

        tasklog(end+1).desc = hand_str;
        tasklog(end).onset = GetSecs - timeStartTask;

        % Wait for TTL or keyboard input to start the task
        [quit, ~] = ld_keys_wait4ttl();
        if quit
            data_saved = 0;
            output_fpath = [];
            clear_and_close();
            return;
        end
                        
        % Wait for release of all keys on keyboard
        KbReleaseWait;

        % Save to the task log
        tasklog(end+1).desc = 'rest-start';
        tasklog(end).onset = GetSecs - timeStartTask;
    
        [quit, ~, keysPressed, timePressed] = ld_displayCrossAndReadKeys(...
            window, screenCenter, param.introDurRest, [], [], [], [], 'red'...
            );
    
        % Save to the task log
        for i = 1:numel(keysPressed)
            tasklog(end+1).desc = 'keypress';
            tasklog(end).onset = timePressed(i) - timeStartTask;
            tasklog(end).value = keysPressed{i};
        end
    
        % End rest block
        tasklog(end+1).desc = 'rest-end';
        tasklog(end).onset = GetSecs - timeStartTask;
            
        % IF quit, save & close
        if quit
            data_saved = save_data(output_fpath, param, tasklog);
            clear_and_close();
            return;
        end
        
        digits_rnd = randsample(digits, numel(digits));
        i_digit = 0;

        % Display black screen for transition
        Screen('FillRect', window, BlackIndex(window));
        Screen('Flip', window);
        pause(0.5);
    
        % Save to the task log
        tasklog(end+1).desc = 'perf-start';
        tasklog(end).onset = GetSecs - timeStartTask;
    
        while i_digit < numel(digits_rnd)
            digit_next = digits_rnd{i_digit+1};
            % Get the target key that corresponds to the digit
            targetKey = digits2keys_map(digit_next);
            
            % Create a message to display
            msg = ['PRESS ', digit_next];

            % Wait for release of all keys on keyboard
            KbReleaseWait;
    
            % Display & read the keys until the target key is captured
            % Exits if 'Esc' is pressed
            [quit, targetKeyPressed, keysPressed, timePressed] = ld_displayCrossAndReadKeys(...
                window, screenCenter, [], [], targetKey, [], [], 'green', [], msg ...
                );
    
            % Save to the task log
            tasklog(end+1).desc = ['targetKey=', targetKey, '-keysPressed'];
            tasklog(end).onset = timePressed - timeStartTask;
            tasklog(end).value = keysPressed;
        
            % IF quit, save & close
            if quit
                data_saved = save_data(output_fpath, param, tasklog);
                clear_and_close();
                return;
            end
            
            no_errors = targetKeyPressed && numel(keysPressed) == 1;
            if no_errors
                i_digit = i_digit + 1;
            else
                % Set digits order using random sampling
                digits_rnd = randsample(digits, numel(digits));
                i_digit = 0;
            end

            % Display black screen for transition
            Screen('FillRect', window, BlackIndex(window));
            Screen('Flip', window);
            pause(0.5);

        end
    
        % End performance block
        tasklog(end+1).desc = 'perf-end';
        tasklog(end).onset = GetSecs - timeStartTask;
    
    end % FOR each hand
    
    % End session
    tasklog(end+1).desc = [param.task, '-end'];
    tasklog(end).onset = GetSecs - timeStartTask;

catch ME
    disp(['ID: ' ME.identifier]);
    rethrow(ME);
end

% Save all
data_saved = save_data(output_fpath, param, tasklog);

% Clear % close all
clear_and_close();

%% UTILS

    function output_fpath = get_output_fpath(param)
        i_name = 1;
        output_fpath = fullfile(param.output_dpath, ...
            [param.subject, '_',  param.exp_phase, '_', param.task '_', num2str(i_name), '.mat']);

        while exist(output_fpath, 'file')
            i_name = i_name+1;
        output_fpath = fullfile(param.output_dpath, ...
            [param.subject, '_',  param.exp_phase, '_param_', num2str(i_name), '.mat']);
        end
    end

    function dataSaved = save_data(output_fpath, param, tasklog)
        save(output_fpath, 'param', 'tasklog');
        dataSaved = 1;
    end

    function clear_and_close()
        % Enable transmission of keypresses to Matlab
        ListenChar(0);

        % Close all screens
        sca;
    end
end



