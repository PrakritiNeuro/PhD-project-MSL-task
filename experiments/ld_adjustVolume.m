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

% Disable transmission of keypresses to Matlab
% To reenable keyboard input to Matlab, press CTRL+C
% This is the same as ListenChar(0)
ListenChar(2);

% set key names to the common naming scheme
KbName('UnifyKeyNames');

%% INITIALIZE SOUND DRIVER & PRELOAD SOUNDS

% Running on PTB-3? Abort otherwise.
AssertOpenGL;

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

% Read all sound files, create & fill one dynamic audiobuffer for
% each read soundfile
buffer = [];
for i_sound=1:length(wav_fpaths)
    [audiodata, ~] = psychwavread(char(wav_fpaths(i_sound)));
    [~, ninchannels] = size(audiodata);
    audiodata = repmat(transpose(audiodata), nrchannels / ninchannels, 1);
    buffer(end+1) = PsychPortAudio('CreateBuffer', [], audiodata);
end

%% 

window = createWindow(param);

% text font settings
Screen('TextFont', window, 'Arial');
Screen('TextSize', window, param.textSize);
gold = [255, 215, 0, 255];

%% DELETE???

hand_keyboard_key_to_task_element = containers.Map(keySet,valueSet);

sound_adjustment = zeros(length(param.sounds),1);
keySet = param.sounds;
valueSet = {0, 0};
sound_adjustment_explicit = containers.Map(keySet,valueSet);
% a duplicate of sound_adjustment, less easy to use in the program, but
% more explicit, for human readability purposes. So people can be certain
% if they look at the data in the future


%% GENERAL INSTRUCTIONS

% Fingers & corresponding keys
index = 1;
middle = 2;
little = 4;
keySet_left = param.map_left.keys;
keySet_right = param.map_right.keys;

keyPlay = {...
    keySet_left{cell2mat(param.map_left.values) == index}, ...
    keySet_right{cell2mat(param.map_right.values) == index}...
    };
keyInc = keySet_right(cell2mat(param.map_right.values) == middle);
keyDec = keySet_left(cell2mat(param.map_left.values) == middle);
keyNext = {...
    keySet_left{cell2mat(param.map_left.values) == little}, ...
    keySet_right{cell2mat(param.map_right.values) == little}...
    };

% Wait for release of all keys on keyboard
KbReleaseWait;

DrawFormattedText(window,'ADJUST THE VOLUME','center',100,gold);
DrawFormattedText(window,'To play the sound, use the index finger of either hand','center',300,gold);
DrawFormattedText(window,'To increase the volume, use the middle finger of your right hand','center',400,gold);
DrawFormattedText(window,'To decrease the volume, use the middle finger of your left hand','center',500,gold);
DrawFormattedText(window,'TO go to the next sound, use the little finger of either hand','center',600,gold);
DrawFormattedText(window,'... GET READY FOR THE TASK ...','center',1000,gold);
Screen('Flip', window);

% Wait for TTL or keyboard input to start the task
[quit, ~] = wait4ttl();
if quit
    errorCode = save_and_close();
    return;
end

%% ADJUST THE VOLUME

% DO YOU NEED TO COPY THE FILE?
% IS IT POSSIBLE TO SET VOLUME LEVELS VIA BUFFER OR YOU NEED A TEMP FILE?

% Change in volume levels per keypress, in dB
dbPerKeyPress = 5;

for i_sound = 1:length(buffer)
    % Change the volume of the sound, in dB, relative to the initial volume
    % levels of the sound; negative values indicate lower volume
    % The change is done in steps of +/-5 dB
    adjust_by = 0;

    % Wait for release of all keys on keyboard
    KbReleaseWait;

    % display instructions
    DrawFormattedText(window,['SOUND ' num2str(i_sound)],'center',100,gold);
    DrawFormattedText(window,'Play: index finger, either hand','center',300,gold);
    DrawFormattedText(window,'Increase: right middle finger','center',400,gold);
    DrawFormattedText(window,'Decrease: left middle finger','center',500,gold);
    DrawFormattedText(window,'Next: little finger, either hand','center',600,gold);
    Screen('Flip', window);

    % Check keys
    [~, ~, keyCode, ~] = KbCheck(-3);
    keyName = KbName(keyCode);
    quit = any(contains(lower(keyName), 'esc'));
    go2next = any(contains(lower(keyName), lower(keyNext)));

    while ~quit && ~ go2next
        
        play_sound = any(contains(lower(keyName), lower(keyPlay)));

        % Increase the volume
        if any(contains(lower(keyName), lower(keyInc)))
            adjust_by = adjust_by + dbPerKeyPress;
            play_sound = true; 
        % Decrease the volume   
        elseif any(contains(lower(keyName), lower(keyDec)))
            adjust_by = adjust_by + dbPerKeyPress;
            play_sound = true;
        end

        % change the volume using adjust_by
        % ??? ... ???

        % Play the sound
        if play_sound
            PsychPortAudio('FillBuffer', pahandle, buffer(i_sound));
            PsychPortAudio('Start', pahandle, 1, 0, 1); % repetitions = 1
        end

        % Check keys
        [~, ~, keyCode, ~] = KbCheck(-3);
        keyName = KbName(keyCode);
        quit = any(contains(lower(keyName), 'esc'));
        go2next = any(contains(lower(keyName), lower(keyNext)));

    end

    if quit
        errorCode = save_and_close();
        return;
    end

end


%% DELITE WHEN DONE ...

% 
%     while ~sound_adjusted
%         timeStartReading = GetSecs;
%         [quit, keysPressed, ~] = readKeys(timeStartReading, Inf, 1);
% 
%         if contains(param.map_left.vaues, key)
% 
%         try
%             key = hand_keyboard_key_to_task_element(key);
%         catch ME
%             switch ME.identifier
%                 case 'MATLAB:Containers:Map:NoKey'
%                     key = 'NaN';
%                 case 'MATLAB:Containers:TypeMismatch'
%                     key = 'NaN';
%                 otherwise
%                     ME.identifier
%                     rethrow(ME)
%             end
%         end
%         disp(key)
%         if key == 1
%             [y, Fs] = audioread(output_sound_fullpath);
%             y = repmat(y,n_channels);
% 
%             PsychPortAudio('FillBuffer', pahandle, y');
%             PsychPortAudio('Start', pahandle, 1,0);
%             PsychPortAudio('Stop', pahandle, 1);
%         elseif key == 2
%             if volume_adjustment_in_dB < 0
%                 volume_adjustment_in_dB = volume_adjustment_in_dB + 5;
%             end
%             command = horzcat('ffmpeg -loglevel quiet -y -i ', ...
%                 sound_i_fullpath,...
%                 ' -filter:a "volume=', num2str(volume_adjustment_in_dB), 'dB" ', ...
%                 output_sound_fullpath, ' -nostdin');
%             disp(command)
%             system(command);
%             [y, Fs] = audioread(output_sound_fullpath);
%             y = repmat(y,n_channels);
%             PsychPortAudio('FillBuffer', pahandle, y');
%             PsychPortAudio('Start', pahandle, 1,0);
%             PsychPortAudio('Stop', pahandle, 1);
%         elseif key == 3
%             volume_adjustment_in_dB = volume_adjustment_in_dB -5;
%             command = horzcat('ffmpeg -loglevel quiet -y -i ', ...
%                 sound_i_fullpath,...
%                 ' -filter:a "volume=', num2str(volume_adjustment_in_dB), 'dB" ', ...
%                 output_sound_fullpath, ' -nostdin');
%             disp(command)
%             system(command);
%             [y, Fs] = audioread(output_sound_fullpath);
%             y = repmat(y,n_channels);
%             PsychPortAudio('FillBuffer', pahandle, y');
%             PsychPortAudio('Start', pahandle, 1,0);
%             PsychPortAudio('Stop', pahandle, 1);
%         elseif key == 4
%             sound_adjusted = true;
%             sound_adjustment_explicit(sound_i) = ...
%                 volume_adjustment_in_dB;
%             sound_adjustment(index_sound) = volume_adjustment_in_dB;
%         end
%         if quit
%             break; 
%         end
%     end
% 
%% UTILS

    function errorCode = save_and_close()

        % save file.mat
        i_name = 1;
        output_fpath = fullfile(param.outputDir, ...
            [param.subject, '_', param.task, '_', num2str(i_name), '.mat']);

        while exist(output_fpath, 'file')
            i_name = i_name+1;
        output_fpath = fullfile(param.outputDir, ...
            [param.subject, '_', param.task, '_', num2str(i_name), '.mat']);

        end
        save(output_fpath, 'sound_adjustment', 'sound_adjustment_explicit');
                
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
        Screen('CloseAll');

        errorCode = 0;

    end

end
