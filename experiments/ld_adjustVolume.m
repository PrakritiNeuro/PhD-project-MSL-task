function [returnCode] = ld_adjustVolume(param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% returnCode = ld_adjustVolume(param)
%
% Adjusting volume for all sounds
%
% param:            structure containing parameters (see parameters.m)
% returnCode:       error returned
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INIT
% CREATION OF THE WINDOW
window = createWindow(param);

number_channels = param.number_channels;

% initializes sound driver...the 1 pushes for low latency
InitializePsychSound(1);
% opens sound buffer
pahandle = PsychPortAudio('Open', [], [], number_channels, []);

% play blank extremely low sound to avoid problem of first sound command not being played
pause(.1)
[audio_signal_tmp, frequency_tmp] = audioread(['stimuli\' 'no_sound.wav']);
audio_signal_tmp = repmat(audio_signal_tmp, number_channels);
PsychPortAudio('FillBuffer', pahandle, audio_signal_tmp');
PsychPortAudio('Start', pahandle, 1,0);
PsychPortAudio('Stop', pahandle, 1);
pause(.1)

% Display instruction message
Screen('TextFont', window, 'Arial');
Screen('TextSize', window, param.textSize);
gold = [255, 215, 0, 255];
keySet = {1, 2, 3, 4, 7, 8, 9, 0};
valueSet = {4, 3, 2, 1, 1, 2, 3, 4};
hand_keyboard_key_to_task_element = containers.Map(keySet,valueSet);

sound_adjustment = zeros(length(param.sounds),1);
keySet = param.sounds;
valueSet = {0, 0};
sound_adjustment_explicit = containers.Map(keySet,valueSet);
% a duplicate of sound_adjustment, less easy to use in the program, but
% more explicit, for human readability purposes. So people can be certain
% if they look at the data in the future

% Show instructions
for index_sound = 1:length(param.sounds)
    volume_adjustment_in_dB = 0;
    sound_i = param.sounds{index_sound};
    % Preload the sound
    sound_i_fullpath = ['stimuli\' sound_i];
    [y, Fs] = audioread(sound_i_fullpath);
    y = repmat(y, number_channels);
    % loads data into buffer
    PsychPortAudio('FillBuffer', pahandle, y');
    output_sound = ['sound' num2str(index_sound) '.wav'];
    output_sound_fullpath = ['stimuli\' output_sound];
    copyfile(sound_i_fullpath, output_sound_fullpath)

    % display instructions
    DrawFormattedText(window,['SOUND ' num2str(index_sound)],'center',100,gold);
    DrawFormattedText(window,'PRESS 1 = PLAY THE SOUND','center',200,gold);
    DrawFormattedText(window,'PRESS 2 = INCREASE THE SOUND VOLUME (+5dB)','center',300,gold);
    DrawFormattedText(window,'PRESS 3 = DECREASE THE SOUND VOLUME (-5dB)','center',400,gold);
    DrawFormattedText(window,'PRESS 4 = GO NEXT SOUND','center',500,gold);
    Screen('Flip', window);

    pause(.5)

    % Play the sound one first time
    PsychPortAudio('Start', pahandle, 1,0);
    PsychPortAudio('Stop', pahandle, 1,0);
    sound_adjusted = false;
    while ~sound_adjusted
        timeStartReading = GetSecs;
        [quit, key, timeTmp] = ReadKeys(param.keyboard, timeStartReading, ...
                                                        100, 1);
        strDecoded = ld_convertKeyCode(key, param.keyboard);
        key = ld_convertOneKey(strDecoded);

        try
            key = hand_keyboard_key_to_task_element(key);
        catch ME
            switch ME.identifier
                case 'MATLAB:Containers:Map:NoKey'
                    key = 'NaN';
                case 'MATLAB:Containers:TypeMismatch'
                    key = 'NaN';
                otherwise
                    ME.identifier
                    rethrow(ME)
            end
        end
        disp(key)
        if key == 1
            [y, Fs] = audioread(output_sound_fullpath);
            y = repmat(y,number_channels);

            PsychPortAudio('FillBuffer', pahandle, y');
            PsychPortAudio('Start', pahandle, 1,0);
            PsychPortAudio('Stop', pahandle, 1);
        elseif key == 2
            if volume_adjustment_in_dB < 0
                volume_adjustment_in_dB = volume_adjustment_in_dB + 5;
            end
            command = horzcat('ffmpeg -loglevel quiet -y -i ', ...
                sound_i_fullpath,...
                ' -filter:a "volume=', num2str(volume_adjustment_in_dB), 'dB" ', ...
                output_sound_fullpath, ' -nostdin');
            disp(command)
            system(command);
            [y, Fs] = audioread(output_sound_fullpath);
            y = repmat(y,number_channels);
            PsychPortAudio('FillBuffer', pahandle, y');
            PsychPortAudio('Start', pahandle, 1,0);
            PsychPortAudio('Stop', pahandle, 1);
        elseif key == 3
            volume_adjustment_in_dB = volume_adjustment_in_dB -5;
            command = horzcat('ffmpeg -loglevel quiet -y -i ', ...
                sound_i_fullpath,...
                ' -filter:a "volume=', num2str(volume_adjustment_in_dB), 'dB" ', ...
                output_sound_fullpath, ' -nostdin');
            disp(command)
            system(command);
            [y, Fs] = audioread(output_sound_fullpath);
            y = repmat(y,number_channels);
            PsychPortAudio('FillBuffer', pahandle, y');
            PsychPortAudio('Start', pahandle, 1,0);
            PsychPortAudio('Stop', pahandle, 1);
        elseif key == 4
            sound_adjusted = true;
            sound_adjustment_explicit(sound_i) = ...
                volume_adjustment_in_dB;
            sound_adjustment(index_sound) = volume_adjustment_in_dB;
        end
        if quit
            break; 
        end
    end

end


% Save file.mat
i_name = 1;
output_file_name = [param.outputDir, param.subject, '_', param.task, '_', ...
                                            num2str(i_name), '.mat'];
while exist(output_file_name, 'file')
    i_name = i_name+1;
    output_file_name = [param.outputDir, param.subject, '_', param.task, ...
                                    '_' , num2str(i_name), '.mat'];
end
save(output_file_name, 'sound_adjustment', 'sound_adjustment_explicit');

returnCode = 0;

PsychPortAudio('Close', pahandle);
Screen('CloseAll')
