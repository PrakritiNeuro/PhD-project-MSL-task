function [errorCode] = ld_introFingerMapping(param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% returnCode = ld_introFingerMapping(param)
%
% Verifying if correct button is pressed for each finger
%
% param:            structure containing parameters (see parameters.m)
% returnCode:       error returned
%
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

img_both = imread(fullfile(param.main_dpath, 'stimuli', 'both_hands.img'));
img_left = imread(fullfile(param.main_dpath, 'stimuli', 'left_hand.img'));
img_right = imread(fullfile(param.main_dpath, 'stimuli', 'right_hand.img'));

%% INIT

% Hands' indices
left = 1;
right = 2;

% Set the order of the hands via random sampling
hands_rnd = randsample(1:numel(param.hands), numel(param.hands));

% A structure with the task log
tasklog = struct('desc', {}, 'onset', [], 'value', {});

%% DISPLAY SETTINGS

[window, windowSize, screenCenter] = createWindow(param);

% Text font settings
Screen('TextFont', window, 'Arial');
Screen('TextSize', window, param.textSize);
gold = [255, 215, 0, 255];

%% TASK INSTRUCTIONS

% Instructions to show; '\n' indicates a new line
titleLine = 'KEY-FINGER MAPPING';
line1 = 'You will need to press a key according';
line2 = 'to the number presented on the screen:';

% Draw instructions
DrawFormattedText(window, ...
    titleLine, ...
    'center', screenSize(1)*0.1, gold);
DrawFormattedText(window, ...
    [line1, '\n', line2],...
    'centerblock', screenSize(1)*0.2, gold);

% Get ready for the task
DrawFormattedText(window, ...
    '... GET READY FOR THE TASK ...',...
    'center', screenSize(1)*0.8, gold);

% Draw two hands; the image is drawn in the center of the screen
imageTexture = Screen('MakeTexture', window, img_both);
Screen('DrawTexture', window, imageTexture, [], [], 0);

% Wait for release of all keys on keyboard
KbReleaseWait;

% Show on the screen
Screen('Flip', window);

% Wait for TTL or keyboard input to start the task
[quit, ~] = keys_wait4ttl();
if quit
    errorCode = save_and_close();
    return;
end

%% KEY-FINGER MAPPING

i_restBlock = 0;
i_perfBlock = 0;
for i_hand = 1:numel(hands_rnd)
    % Key-digit map
    digits = param(hands_rnd(i_hand)).digits;
    keys = param(hands_rnd(i_hand)).keys;
    digits2keys_map = containers.Map(digits, keys);

    if hands_rnd(i_hand) == left
        hand_str = 'LEFT-HAND';
        imageTexture = Screen('MakeTexture', window, img_left);
    elseif shands_rnd(i_hand) == right
        hand_str = 'RIGHT-HAND';
        imageTexture = Screen('MakeTexture', window, img_right);
    end

    line1 = 'Red cross: wait';
    line2 = 'Green cross: do the task';
    
    % Draw instructions
    DrawFormattedText(window, ...
        hand_str, ...
        'center', screenSize(1)*0.1, gold);
    DrawFormattedText(window, ...
        [line1, '\n', line2],...
        'centerblock', screenSize(1)*0.2, gold);

    % Draw the hand
    Screen('DrawTexture', window, imageTexture, [], [], 0);

    % Get ready for the task
    DrawFormattedText(window, ...
        '... GET READY FOR THE TASK ...',...
        'center', screenSize(1)*0.8, gold);
    
    % Wait for release of all keys on keyboard
    KbReleaseWait;

    % Show on the screen
    Screen('Flip', window);
    
    % Wait for TTL or keyboard input to start the task
    [quit, ~] = keys_wait4ttl();
    if quit
        errorCode = save_and_close();
        return;
    end
    
    % Wait for release of all keys on keyboard
    KbReleaseWait;

    % Time the task started; is used as time 0
    timeStartTask = GetSecs;

    tasklog(end+1).desc = [param.task, '-START'];
    tasklog(end).onset = GetSecs - timeStartTask;

    % Start rest block
    i_restBlock = i_restBlock + 1;
    rest_str = [hand_str,'-REST', num2str(i_restBlock)];
    
    % Save to the task log
    tasklog(end+1).desc = [rest_str, '-START'];
    tasklog(end).onset = GetSecs - timeStartTask;

    [quit, ~, keysPressed, timePressed] = displayCrossAndReadKeys(...
        window, screenCenter, param.introDurRest, [], [], [], [], 'red'...
        );

    % Save to the task log
    for i = 1:numel(keysPressed)
        tasklog(end+1).desc = [rest_str '-rep'];
        tasklog(end).onset = timePressed(i) - timeStartTask;
        tasklog(end).value = keysPressed{i};
    end

    % End rest block
    tasklog(end+1).desc = [rest_str, '-END'];
    tasklog(end).onset = GetSecs - timeStartTask;
        
    % IF quit, save & close
    if quit, break; end

    % Start performance block
    i_perfBlock = i_perfBlock + 1;
    perf_str = [hand_str, -'PERF', num2str(i_perfBlock)];

    digits_rnd = randsample(digits, numel(digits));
    count_success = 0;

    % Save to the task log
    tasklog(end+1).desc = [perf_str, '-START'];
    tasklog(end).onset = GetSecs - timeStartTask;

    while count_success < numel(digits_rnd)
        % Get the target key that corresponds to the digit
        targetKey = digits2keys_map(digits_rnd(i_digit));
        
        % Create a message to display
        msg = ['PRESS ', num2str(targetKey)];

        % Display & read the keys until the target key is captured
        % Exits if 'Esc' is pressed
        [quit, targetKeyPressed, keysPressed, timePressed] = displayCrossAndReadKeys(...
            window, screenCenter, [], [], targetKey, [], [], 'green', [], msg ...
            );

        % Save to the task log
        tasklog(end+1).desc = [perf_str, '-', targetKey];
        tasklog(end).onset = timePressed - timeStartTask;
        tasklog(end).value = keysPressed;
    
        % IF quit, save & close
        if quit, break; end
        
        no_errors = targetKeyPressed && numel(keysPressed) == 1;
        if no_errors
            count_success = count_success + 1;
        else
            % Set digits order using random sampling
            digits_rnd = randsample(digits, numel(digits));
            count_success = 0;
        end
    end

    % End performance block
    tasklog(end+1).desc = [perf_str, '-END'];
    tasklog(end).onset = GetSecs - timeStartTask;

end % FOR each hand

tasklog{end+1}{1} = num2str(GetSecs - timeStartTask);
tasklog{end}{2} = [param.task, '_END'];

%% UTILS

    function errorCode = save_and_close()

        % save file.mat
        i_name = 1;

        output_fpath = fullfile(param.output_dpath, ...
            [param.subject, '_',  param.exp_phase, '_param_', num2str(i_name), '.mat']);

        while exist(output_fpath, 'file')
            i_name = i_name+1;
        output_fpath = fullfile(param.outputDir, ...
            [param.subject, '_',  param.exp_phase, '_param_', num2str(i_name), '.mat']);
        end
        save(output_fpath, 'param');
                
        % Close the audio device
        if exist(pahandle, "var")
            % Wait until end of playback (1) then stop:
            PsychPortAudio('Stop', pahandle, 1);
            
            % Delete all dynamic audio buffers
            PsychPortAudio('DeleteBuffer');
            
            % Close the audio device
            PsychPortAudio('Close', pahandle);
        end

        % Enable transmission of keypresses to Matlab
        ListenChar(0);

        % Close all screens
        sca;




% Save file.mat
i_name = 1;
output_file_name = [param.outputDir, param.subject,'_',param.task,'_' , num2str(i_name) ,'.mat'];
while exist(output_file_name,'file')
    i_name = i_name+1;
    output_file_name = [param.outputDir, param.subject,'_',param.task,'_' , num2str(i_name) ,'.mat'];
end
save(output_file_name, 'tasklog', 'param'); 


        

        errorCode = 0;

    end

end



