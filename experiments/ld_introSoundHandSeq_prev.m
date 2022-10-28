function [returnCode] = ld_introSoundHandSeq(param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% returnCode = ld_introSoundHandSeq(param)
%
% explained later
%
% param:            structure containing parameters (see en_parameters.m)
% returnCode:       error returned
%
%
% Thibault Vlieghe, 2022-08-03
% Ella Gabitov, October 2022
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CREATION OF THE WINDOW, initializing experiment
[window, param.screenResolution] = createWindow(param);

n_channels = numel(param.sounds); % one channel for each sound

% initializes sound driver...the 1 pushes for low latency
InitializePsychSound(1);
% opens sound buffer
pahandle = PsychPortAudio('Open', [], [], n_channels, []);

% play blank extremely low sound to avoid problem of first sound command not being played
pause(.1)
[audio_signal_tmp, ~] = audioread(['stimuli\' 'no_sound.wav']);
audio_signal_tmp = repmat(audio_signal_tmp, n_channels);
PsychPortAudio('FillBuffer', pahandle, audio_signal_tmp');
PsychPortAudio('Start', pahandle, 1,0);
PsychPortAudio('Stop', pahandle, 1);

pause(.1)

onset = struct(...     
    'rest',     [], ...
    'seq',      [], ...
    'seqDur',   [] ...
    );

% defining local durations
white_cross_before_sound_duration  = 0.2; % in seconds
sound_hand_delay = 2 ; % in seconds
show_hand_duration  = 3; % in seconds
red_cross_duration = 3; % in seconds

% randomize the order of the sequences
rnd_inds = randsample(1:numel(param.soundHandSeq), numel(param.soundHandSeq));

logoriginal = [];
quit = false;

% load sound volume adjustment in dB
i_name = 1;
output_file_name = [param.outputDir, param.subject, '_', 'Sound Volume Adjustment - PreSleep', '_', ...
                                            num2str(i_name), '.mat'];
while exist(output_file_name, 'file')
    i_name = i_name+1;
    output_file_name = [param.outputDir, param.subject, '_', 'Sound Volume Adjustment - PreSleep', ...
                                    '_' , num2str(i_name), '.mat'];
end
i_name = i_name-1;
output_file_name = [param.outputDir, param.subject, '_', 'Sound Volume Adjustment - PreSleep', ...
                                '_' , num2str(i_name), '.mat'];
load(output_file_name, 'sound_adjustment')
param.sound_adjustment = sound_adjustment;


% Preload the sound
audio_signal = cell(length(param.sounds),1);
frequency = cell(length(param.sounds),1);
for index_sound = 1:length(param.sounds)
    sound_i = param.sounds{index_sound};
    sound_i_fullpath = ['stimuli\' sound_i];
    tmp_sound = ['stimuli\' 'sound' num2str(index_sound) '.wav'];
    command = horzcat(...
        'ffmpeg -loglevel quiet -y -i ', sound_i_fullpath,...
        ' -filter:a "volume=', ...
        num2str(param.sound_adjustment(index_sound)), 'dB" ', ...
        tmp_sound, ' -nostdin');
    disp(command)
    system(command);
    [audio_signal{index_sound},  frequency{index_sound}] = ...
        audioread(tmp_sound);
    audio_signal{index_sound} = repmat(audio_signal{index_sound}, n_channels);
end

% Display first instruction
Screen('TextFont',window,'Arial');
Screen('TextSize',window, param.textSize);
gold = [255,215,0,255];
white = [255, 255, 255, 255];

DrawFormattedText(window,'ASSOCIATE THE SEQUENCE','center',100,gold);
DrawFormattedText(window,'WITH THE SOUND','center',200,gold);
DrawFormattedText(window,'... Get ready to start the task ...','center',300,gold);
Screen('Flip', window);

% Wait for TTL (or keyboard input) before starting
% FlushEvents('keyDown');
[~, ~, keyCode] = KbCheck(-1);
strDecoded = ld_convertKeyCode(keyCode, param.keyboard);
while ~contains(strDecoded, '5')
    [~, ~, keyCode] = KbCheck(-1);
    strDecoded = ld_convertKeyCode(keyCode, param.keyboard);
end

param.time = fix(clock);
timeStartExperience = GetSecs;

logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
logoriginal{end}{2} = param.task;
logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
logoriginal{end}{2} = 'START';

% LOOP: Associating sequence with sound
for i = 1:numel(rnd_inds)
    sound_fname = param.soundHandSeq(rnd_inds(i)).sound;
    hand = param.soundHandSeq(rnd_inds(i)).hand;
    seq = param.soundHandSeq(rnd_inds(i)).seq;
    map_keys = param.(['map_' hand]);
    ^^^
    % replace param.keyboard_key_to_task_element 
    % by map_keys in the code below

    switch hand
        case 'left'
            [img, ~, ~] = imread(fullfile(param.main_dpath, 'stimuli', 'left-hand_with-numbers.png'));
        case 'right'
            [img, ~, ~] = imread(fullfile(param.main_dpath, 'stimuli', 'right-hand_with-numbers.png'));
    end
    img_height = size(img,1);
    img_width = size(img,2);
    img_position = [round(screen_width/2 - img_width - 50) ...
        round(screen_height/2 - img_height/2) ...
        round(screen_width/2 - 50) ...
        round(screen_height/2 + img_height/2)...
        ];

    index_sound = find(strcmp(param.sounds, sound_fname));
    PsychPortAudio('FillBuffer', pahandle, audio_signal{index_sound}')

    screen_width = param.screenResolution(1);
    screen_height = param.screenResolution(2);
    
    ^^^
    % subject_has_completed_introNb_sequences
    % make this check more efficient
    subject_has_completed_introNb_sequences = false;
    while ~subject_has_completed_introNb_sequences && ~quit
        % display white cross for 200ms
        [quit, ~, ~] = displayCross(window, param, white_cross_before_sound_duration, ...
                                            0, 0, 'white');
        if quit
            logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
            logoriginal{end}{2} = 'STOP MANUALLY';
            savefile(param,logoriginal,onset);
            Screen('CloseAll');
            PsychPortAudio('Close', pahandle);
            return;
        end
    
        % PLAY THE SOUND
        logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
        logoriginal{end}{2} = 'SoundPlayed';
        logoriginal{end}{3} = param.sounds{index_sound};
        PsychPortAudio('Start', pahandle, 1, 0);
        PsychPortAudio('Stop', pahandle, 1);
        
        pause(sound_hand_delay)

        % Show hand that will be used
        texture_hand = Screen('MakeTexture', window, img);
        Screen('DrawTexture',window,texture_hand,[],img_position);
        DrawFormattedText(window, '+', 'center', 'center', white);
        Screen('Flip', window);
        pause(show_hand_duration)
        
        % record keys
        % display red cross
        logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
        logoriginal{end}{2} = 'Rest';
        [quit, ~, ~] = displayCross(window, param, red_cross_duration, ...
                                            0, 0, 'red');
        if quit
            logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
            logoriginal{end}{2} = 'STOPED MANUALLY';
            savefile(param,logoriginal,onset);
            Screen('CloseAll');
            PsychPortAudio('Close', pahandle);
            return;
        end
    
        if ~quit
            logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
            logoriginal{end}{2} = 'Practice';
            logoriginal{end}{3} = LeftOrRightHand;

            [quit, keysPressed, timePressed] = displayCross(...
                window, param, ...
                0,param.nbSeqPerMiniBlock*length(seq),...
                0,'green', param.durNoResponse, true, seq);
            
            [keys_as_sequence_element,  keys_source_keyboard_value] = ...
                ld_convertMultipleKeys(keysPressed, param.keyboard, ...
                param.keyboard_key_to_task_element);
    
            % Find Good sequences
            str_keys = num2str(keys_as_sequence_element);
            str_l_seqUsed = num2str(seq);
    
            % Display good sequences and total time
            disp([num2str(size(strfind(str_keys,str_l_seqUsed),2)) ' good sequences']);
            disp(num2str(round(10*onset.seqDur)/10));
    
            % Record Keys
            for nbKeys = 1:length(keys_as_sequence_element)
                logoriginal{end+1}{1} = num2str(timePressed(nbKeys) - timeStartExperience );
                logoriginal{end}{2} = 'rep';
                logoriginal{end}{3} = num2str(keys_as_sequence_element(nbKeys));
                logoriginal{end}{4} = num2str(keys_source_keyboard_value(nbKeys));
            end

            if quit
                logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
                logoriginal{end}{2} = 'STOPED MANUALLY';
                savefile(param,logoriginal,onset);
                Screen('CloseAll');
                PsychPortAudio('Close', pahandle);
                return;
            end

        else
            break
        end
        % display red cross
        logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
        logoriginal{end}{2} = 'Rest';
        [quit, ~, ~] = displayCross(window, param, red_cross_duration, ...
                                            0, 0, 'red');
        if quit
            logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
            logoriginal{end}{2} = 'STOPED MANUALLY';
            savefile(param,logoriginal,onset);
            Screen('CloseAll');
            PsychPortAudio('Close', pahandle);
            return;
        end
        Screen('TextSize',window, param.textSize);
        if size(strfind(str_keys,str_l_seqUsed),2) == param.nbSeqPerMiniBlock
            subject_has_completed_introNb_sequences = true;
            DrawFormattedText(window,'You got it right!','center','center',gold);
            Screen('Flip', window);
            pause(1)
            logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
            logoriginal{end}{2} = 'SoundPlayed';
            logoriginal{end}{3} = param.sounds{index_sound};
            PsychPortAudio('Start', pahandle, 1,0);
            PsychPortAudio('Stop', pahandle, 1);
            pause(3)
        else
            DrawFormattedText(window,'Let s try again','center','center',gold);
            Screen('Flip', window);
            pause(3)
        end
    end
    % jittered rest
    logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
    logoriginal{end}{2} = 'Rest';
    logoriginal{end}{3} = 'jittered';
    jittered_rest_duration = randi(param.JitterRangeBetweenMiniBlocks);
    [quit, ~, ~] = displayCross(window, param, jittered_rest_duration, ...
                                        0, 0, 'red');
    if quit
        logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
        logoriginal{end}{2} = 'STOPED MANUALLY';
        savefile(param,logoriginal,onset);
        Screen('CloseAll');
        PsychPortAudio('Close', pahandle);
        return;
    end
end

savefile(param,logoriginal,onset);
Screen('CloseAll');
PsychPortAudio('Close', pahandle);
% Save file.mat

returnCode = 0;

end
