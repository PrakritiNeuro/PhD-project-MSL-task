function [errorCode] = ld_adjustVolume(param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% errorCode = ld_adjustVolume(param)
%
% Adjust volume for each sound
%
% INPUT
%   param       structure containing parameters (see get_param....m)
% 
% OUTPUT
%   errorCode   error code returned; 0 - no error
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

% Disable transmission of keypresses to Matlab
% To reenable keyboard input to Matlab, press CTRL+C
% This is the same as ListenChar(0)
ListenChar(2);

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

% Hands' indices
left = 1;
right = 2;

% Fingers' indices
indexFinger = 1;
middleFinger = 2;
ringFinger = 3; % Is not used in this task
littleFinger = 4;

keyPlay = {param.hands(left).keys(indexFinger), param.hands(right).keys(indexFinger)};
keyInc = param.hands(right).keys(middleFinger);
keyDec = param.hands(left).keys(middleFinger);
keyNext = {param.hands(left).keys(littleFinger), param.hands(right).keys(littleFinger)};

%% DISPLAY SETTINGS

[window, screenSize, ~] = createWindow(param);

% Text font settings
Screen('TextFont', window, 'Arial');
Screen('TextSize', window, param.textSize);
gold = [255, 215, 0, 255];

%% TASK INSTRUCTIONS

% Instructions to show; '\n' indicates a new line
titleLine = 'ADJUST THE VOLUME';
line1 = 'To play the sound, use the index finger of either hand';
line2 = 'To increase the volume, use the middle finger of your right hand';
line3 = 'To decrease the volume, use the middle finger of your left hand';
line4 = 'To go to the next sound, use the little finger of either hand';

% Draw instructions
DrawFormattedText(window, titleLine, ...
    'center', screenSize(1)*0.1, gold);
DrawFormattedText(window, [line1, '\n', line2, '\n', line3, '\n', line4],...
    'centerblock', 'center', gold);
DrawFormattedText(window,'... GET READY FOR THE TASK ...',...
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

%% ADJUST THE VOLUME

% Change in volume levels per keypress
% is a propotion of the initial device volume levels
vol_step = 0.1;

% The order of preloaded sounds in the buffer is the same as in soundHandSeq
for i_sound = 1:length(buffer)

    % divice_volume determines the volume (0...1) to play the sound as a
    % proportion of the current device volume
    divice_volume = 1;

    % Instructions to show; '\n' indicates a new line
    titleLine = ['ADJUST THE VOLUME OF SOUND ' num2str(i_sound)];
    line1 = 'Play: index finger, either hand';
    line2 = 'Increase: right middle finger';
    line3 = 'Decrease: left middle finger';
    line4 = 'Next: little finger, either hand';

    % Draw instructions
    DrawFormattedText(window, titleLine, ...
        'center', screenSize(1)*0.1, gold);
    DrawFormattedText(window, [line1, '\n', line2, '\n', line3, '\n', line4],...
        'centerblock', center, gold);

    % Wait for release of all keys on keyboard
    KbReleaseWait;
    
    % Show on the screen
    Screen('Flip', window);

    quit = 0;
    go2next = 0;
    while ~quit && ~ go2next
        % Read the keys
        [~, ~, keyCode, ~] = KbCheck(-3);
        keyName = KbName(keyCode);

        % Check the keys
        quit = any(contains(lower(keyName), 'esc'));
        go2next = any(contains(lower(keyName), lower(keyNext)));
        if quit
            errorCode = save_and_close();
            return;
        end

        % Save the volume levels for the sound and go to the next sound
        if go2next
            param.soundHandSeq(i_sound).divice_volume = divice_volume;
        
        % Adjust the volume levels, if needed, and play the sound
        else
            play_sound = any(contains(lower(keyName), lower(keyPlay)));

            % Increase the volume
            if any(contains(lower(keyName), lower(keyInc)))
                if (divice_volume + vol_step) <= 1
                    divice_volume = divice_volume + vol_step;
                end
                play_sound = true; 
            
            % Decrease the volume   
            elseif any(contains(lower(keyName), lower(keyDec)))
                if (divice_volume - vol_step) >= 0
                    divice_volume = divice_volume - vol_step;
                end
                play_sound = true;
            end

            % Play the sound
            if play_sound
                PsychPortAudio('FillBuffer', pahandle, buffer(i_sound));
                PsychPortAudio('Volume', pahandle, divice_volume)
                PsychPortAudio('Start', pahandle, 1, 0, 1); % repetitions = 1
            end

        end

    end % WHILE

end

% Save and close all
errorCode = save_and_close();

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

        errorCode = 0;

    end

end
