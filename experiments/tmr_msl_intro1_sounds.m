function [quit, data_saved, output_fpath] = tmr_msl_intro1_sounds(param_fpath, exp_phase, task_name)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [quit, data_saved, output_fpath] = tmr_msl_intro1_sounds(param_fpath, exp_phase, task_name)
%
% Adjust volume for each sound
%
% INPUT
%   param_fpath     [string]    full path to the param file of the
%                               participant; if it doesn't exist the
%                               program throws an error
%   exp_phase       [string]    the phase of the experiment
%                               e.g., 'PreSleep', 'PostSleep'
%   task_name       [string]    task name, e.g., 'intro1_sounds'
% 
% OUTPUT
%   quit            [boolean]   1 - exit before compited; 0 - otherwise
%   data_saved      [boolean]   1 - data was saved; 0 - otherwise
%   output_fpath    [string]
%
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
    warning(param_fpath);
    warning("The param file was not found. Did you start the experiment via STIM?");
    error('ParamFileNotFound');
end

param_load = load(param_fpath);
param = param_load.param;
param.exp_phase = exp_phase;
param.task = task_name;

%% INITIALIZE SOUND DRIVER & PRELOAD SOUNDS

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

%% INITIALIZE KEY SETTINGS

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

% Fingers' indices
indexFinger = 1;
middleFinger = 2;
ringFinger = 3; % Is not used in this task
littleFinger = 4;

keyPlay = {param.hands(left).keys{indexFinger}, param.hands(right).keys{indexFinger}};
keyInc = param.hands(right).keys{middleFinger};
keyDec = param.hands(left).keys{middleFinger};
keyNext = {param.hands(left).keys{littleFinger}, param.hands(right).keys{littleFinger}};

%% DISPLAY SETTINGS

[window, screenSize, ~] = ld_createWindow(param);

% Text font settings
Screen('TextFont', window, 'Arial');
Screen('TextSize', window, param.textSize);
gold = [255, 215, 0, 255];

%% TASK INSTRUCTIONS

% Instructions to show; '\n' indicates a new line
titleLine = 'ADJUST THE VOLUME';
line1 = 'Play: index finger, either hand';
line2 = 'Increase: right middle finger';
line3 = 'Decrease: left middle finger';
line4 = 'Next: little finger, either hand';

% Draw instructions
DrawFormattedText(window, titleLine, ...
    'center', screenSize(2)*0.15, gold);
DrawFormattedText(window, [line1, '\n', line2, '\n', line3, '\n', line4],...
    'centerblock', 'center', gold);
DrawFormattedText(window,'... GET READY FOR THE TASK ...',...
    'center', screenSize(2)*0.9, gold);

% Wait for release of all keys on keyboard
KbReleaseWait;

% Show on the screen
Screen('Flip', window);

% Wait for TTL key (='5') to start the task
[quit, ~, ~, ~] = ld_keysWait4ttl();
if quit
    data_saved = 0;
    output_fpath = [];
    clear_and_close();
    return;
end

% Display black screen for transition
Screen('FillRect', window, BlackIndex(window));
Screen('Flip', window);
WaitSecs(param.transScreenDur);

%% ADJUST THE VOLUME

output_fpath = get_output_fpath(param);

% Change in volume levels per keypress is calculated as a propotion of the
% current volume levels
vol_portion = 0.5;

try
    % The order of preloaded sounds in the buffer is the same as in soundHandSeq
    for i_sound = 1:length(buffer)
    
        % divice_volume determines the volume (0...1) to play the sound as a
        % proportion of the current device volume
        device_volume = 1;
    
        % Instructions to show; '\n' indicates a new line
        titleLine = ['ADJUST THE VOLUME OF SOUND ' num2str(i_sound)];
    
        % Draw instructions
        DrawFormattedText(window, titleLine, ...
            'center', screenSize(2)*0.15, gold);
        DrawFormattedText(window, [line1, '\n', line2, '\n', line3, '\n', line4],...
            'centerblock', 'center', gold);
        
        % Show on the screen
        Screen('Flip', window);
    
        quit = 0;
        go2next = 0;
        while ~quit && ~ go2next
            [~, keyCode, ~] = KbPressWait([]);
            keyName = KbName(keyCode);
    
            % Check the keys
            if ~isempty(keyName)    
                quit = any(contains(lower(keyName), 'esc'));
                go2next = any(contains(lower(keyName), lower(keyNext)));
    
                if quit
                    param.soundHandSeq(i_sound).device_volume = device_volume;
                    data_saved = save_data(output_fpath, param);
                    clear_and_close();
                    return;
                end
    
                % Save the volume levels for the sound and go to the next sound
                if go2next
                    param.soundHandSeq(i_sound).device_volume = device_volume;
                    data_saved = save_data(output_fpath, param);
                    
                    % Display black screen for transition
                    Screen('FillRect', window, BlackIndex(window));
                    Screen('Flip', window);
                    WaitSecs(param.transScreenDur);
    
                % Adjust the volume levels, if needed, and play the sound
                else
                    play_sound = any(contains(lower(keyName), lower(keyPlay)));
        
                    % Increase the volume
                    if any(contains(lower(keyName), lower(keyInc)))
                        vol_change = device_volume * vol_portion;
                        if (device_volume + vol_change) <= 1
                            device_volume = device_volume + vol_change;
                        end
                        play_sound = true; 
                
                    % Decrease the volume   
                    elseif any(contains(lower(keyName), lower(keyDec)))
                        vol_change = device_volume * vol_portion;
                        if (device_volume - vol_change) >= 0
                            device_volume = device_volume - vol_change;
                        end
                        play_sound = true;
                    end
    
                    % Play the sound
                    if play_sound
                        PsychPortAudio('FillBuffer', pahandle, buffer(i_sound));
                        PsychPortAudio('Volume', pahandle, device_volume)
                        PsychPortAudio('Start', pahandle, 1, 0, 1); % repetitions = 1
                    end
                end
            end % IF any key was pressed
    
        end % WHILE
    
    end

catch ME
    disp(['ID: ' ME.identifier]);
end

% Save all, clear, & close
data_saved = save_data(output_fpath, param);
clear_and_close();

end

%% utils

% --- Get full path to save the output
function output_fpath = get_output_fpath(param)
    i_name = 1;
    output_fpath = fullfile(param.output_dpath, ...
        [param.subject, '_',  param.exp_phase, '_param_', num2str(i_name), '.mat']);

    while exist(output_fpath, 'file')
        i_name = i_name+1;
    output_fpath = fullfile(param.output_dpath, ...
        [param.subject, '_',  param.exp_phase, '_param_', num2str(i_name), '.mat']);
    end
end

% --- Save the output
function dataSaved = save_data(output_fpath, param)
    save(output_fpath, 'param');
    dataSaved = 1;
end

% --- Clear and close all
function clear_and_close()
    Priority(0);
    % Enable transmission of keyboard input to Matlab
    ListenChar(0);
    % Reset keys for input
    RestrictKeysForKbCheck([]);
    % Clean & close audio facilities
    PsychPortAudio('DeleteBuffer');
    PsychPortAudio('Close');
    % Clean & close all screens
    sca;
end
