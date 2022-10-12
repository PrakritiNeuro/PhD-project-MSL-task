function [returnCode] = ld_mslTraining(param, phase_number, test)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% returnCode = ld_mslTraining(param)
%%
% param:            structure containing parameters (see en_parameters..m)
% returnCode:       error returned
%
%
% Vo An Nguyen 2010/10/07
% Arnaud Bore 2012/10/05, CRIUGM - arnaud.bore@gmail.com
% Arnaud Boré 2012/08/11 switch toolbox psychotoolbox 3.0
% `````````````````````````````````````````````````````````````````````
% Arnaud Bore 2014/10/31 
%                   CoRe project : 
%                        - add variable param.task to know what to do
% `````````````````````````````````````````````````````````````````````
% EG March 9, 2015
%
% Arnaud Boutin 2015/06/25
% - Edit "createWindow.m" to induce horizontal flip of the screen
% Search for "PsychImaging"
% Arnaud Bore 2016/02/06
% Thibault Vlieghe 2022/08/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 3; test=false; end


% INIT
% CREATION OF THE WINDOW
[window, param.screenResolution] = createWindow(param);

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

% loading param
durNoResponse = param.durNoResponse;
if ~test
    nbBlocks = param.nbMiniBlocks(phase_number) * 2;  % * 2 because there are two sequences
    maxNbBlocksSameSeq = param.maxNbMiniBlocksSameSeq;
    nbSeqPerBlock = param.nbSeqPerMiniBlock;
else
    nbBlocks = param.nbTestBlocks * 2;  % * 2 because there are two sequences
    maxNbBlocksSameSeq = param.maxNbTestBlocksSameSeq;
    nbSeqPerBlock = param.nbSeqPerTestBlock;
end
both_hands_keyboard_key_to_task_element = param.both_hands_keyboard_key_to_task_element;

white = param.white;

onset = struct(...                              % onset vector         
    'rest',     [], ...
    'seq',      [], ...
    'seqDur',   [] ...
    );

logoriginal = [];
duration = 0;
standard = 0;

% Display first instruction
Screen('TextFont',window,'Arial');
Screen('TextSize',window, param.textSize);
gold = [255,215,0,255];

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
    [audio_signal{index_sound}, frequency{index_sound}] = ...
        audioread(tmp_sound);
    audio_signal{index_sound} = repmat(audio_signal{index_sound}, number_channels);
end

% Generate mini blocks
sequence_a_or_b = [];
while length(sequence_a_or_b) < nbBlocks
    if length(sequence_a_or_b) < nbBlocks - 6  % 6 is purely arbitrary
        tmp_sequence_a_or_b = vertcat(ones(3,1), 2*ones(3,1));
    else
        number_mini_blocks = fix(abs(length(sequence_a_or_b) - nbBlocks) / 2);
        tmp_sequence_a_or_b = vertcat(ones(number_mini_blocks,1), ...
            2*ones(number_mini_blocks,1));
    end
    % randomize order
    tmp_sequence_a_or_b = tmp_sequence_a_or_b(randperm(numel(tmp_sequence_a_or_b)));
    % verify no uninterrupted sequence of the same 
    attempt_sequence_a_or_b = vertcat(sequence_a_or_b, tmp_sequence_a_or_b);
    longest_uninterrupted_sequence_len = max(diff(find([1,diff(attempt_sequence_a_or_b'),1])));
    if longest_uninterrupted_sequence_len <= maxNbBlocksSameSeq
        sequence_a_or_b = attempt_sequence_a_or_b;
    end
end

DrawFormattedText(window,'PERFORM THE SEQUENCE AS FAST','center',100,gold);
DrawFormattedText(window,'AND ACCURATE AS POSSIBLE','center',200,gold);
DrawFormattedText(window,'... The task will begin momentarily ...','center',500,gold); %%

Screen('Flip', window);

% Wait for TTL (or keyboard input) before starting
[quit, ~, keyCode] = KbCheck(-1);
strDecoded = ld_convertKeyCode(keyCode, param.keyboard);

while isempty(strfind(strDecoded, '5'))
    [~, ~, keyCode] = KbCheck(-1);
    strDecoded = ld_convertKeyCode(keyCode, param.keyboard);
end

param.time = fix(clock);
timeStartExperience = GetSecs;

logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
logoriginal{end}{2} = param.task;
logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
logoriginal{end}{2} = 'START';


% Display cross
logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
logoriginal{end}{2} = 'Rest';
onset.rest(length(onset.rest)+1) = GetSecs - timeStartExperience;
[quit, keysPressed, timePressed] = displayCross(window, param, param.durRest,0,0,'red',100);

if quit
    logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
    logoriginal{end}{2} = 'STOP MANUALLY';
    Screen('CloseAll')
    PsychPortAudio('Close', pahandle);
    savefile(param,logoriginal,onset);
    return;
end

% TASK
for i = 1:numel(sequence_a_or_b)
     %%% PRELOAD
    if sequence_a_or_b(i) == 1
        l_seqUsed = param.seqA;
        LeftOrRightHand = param.HandSoundSequenceAssociation.seqA.hand;
        tmp_sound = param.HandSoundSequenceAssociation.seqA.sound;
    elseif sequence_a_or_b(i) == 2
        l_seqUsed = param.seqB;
        LeftOrRightHand = param.HandSoundSequenceAssociation.seqB.hand;
        tmp_sound = param.HandSoundSequenceAssociation.seqB.sound;
    end

    index_sound = find(strcmp(param.sounds, tmp_sound));
    PsychPortAudio('FillBuffer', pahandle, audio_signal{index_sound}');
    
    if strcmp(LeftOrRightHand, 'left_hand')
        param.keyboard_key_to_task_element = param.left_hand_keyboard_key_to_task_element;
    elseif strcmp(LeftOrRightHand, 'right_hand')
        param.keyboard_key_to_task_element = param.right_hand_keyboard_key_to_task_element;
    end

    subject_has_picked_correct_sound = false;
    
    % LOGGING
    logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
    logoriginal{end}{2} = 'Practice_SoundChoice';
    if ~test
        logoriginal{end}{3} = ['MiniBlock', num2str(i)];
    else
        logoriginal{end}{3} = ['Block', num2str(i)];
    end

    while ~quit && ~subject_has_picked_correct_sound
        % display white cross for 200ms
        [quit, ~, ~] = displayCross(window, param,  0.2, ...
                                            0, 0, 'white', 100);
        if quit
            logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
            logoriginal{end}{2} = 'STOP MANUALLY';
            Screen('CloseAll')
            PsychPortAudio('Close', pahandle);
            savefile(param,logoriginal,onset);
            break;
        end
    
        % PLAY THE SOUND
        logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
        logoriginal{end}{2} = 'SoundPlayed';
        logoriginal{end}{3} = param.sounds{index_sound};
        PsychPortAudio('Start', pahandle, 1,0);
        PsychPortAudio('Stop', pahandle, 1);
    
        % Show both hands
        screen_width = param.screenResolution(1);
        screen_height = param.screenResolution(2);

        [left_image_hand, ~, left_alpha] = imread([param.rawDir 'stimuli' filesep 'left-hand_with-numbers.png']); % Left Hand
        left_image_height = size(left_image_hand,1);
        left_image_width = size(left_image_hand,2);
        left_hand_position = [round(screen_width/2 - left_image_width - 50) ...
                        round(screen_height/2 - left_image_height/2) ...
                        round(screen_width/2 - 50) ...
                        round(screen_height/2 + left_image_height/2)...
                        ];

        [right_image_hand, ~, right_alpha] = imread([param.rawDir 'stimuli' filesep 'right-hand_with-numbers.png']); % Right Hand
        right_image_height = size(right_image_hand,1);
        right_image_width = size(right_image_hand,2);
        right_hand_position = [round(screen_width/2 + 50) ...
            round(screen_height/2 - right_image_height/2) ...
            round(screen_width/2 + right_image_width + 50) ...
            round(screen_height/2 + right_image_height/2)...
            ];
        texture_left_hand = Screen('MakeTexture', window, left_image_hand);
        texture_right_hand = Screen('MakeTexture', window, right_image_hand);
        Screen('DrawTexture',window,texture_left_hand,[],left_hand_position);
        Screen('DrawTexture',window,texture_right_hand,[],right_hand_position);

        DrawFormattedText(window, '+', 'center', 'center', white);
        Screen('Flip', window);
        
        hand_chosen = 'unset';
        left_hand_key = 0;
        right_hand_key = 0;
        timeStartReading = GetSecs;
        [quit, key, timePressed] = ReadKeys(param.keyboard, timeStartReading, ...
                                           durNoResponse, 1, 0, 100);
        if quit
            logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
            logoriginal{end}{2} = 'STOP MANUALLY';
            Screen('CloseAll')
            PsychPortAudio('Close', pahandle);
            savefile(param,logoriginal,onset);
            break;
        end
        strDecoded = ld_convertKeyCode(key, param.keyboard);
        key = ld_convertOneKey(strDecoded);
        try
            key_task_value = both_hands_keyboard_key_to_task_element(key);
        catch ME
            switch ME.identifier
                case 'MATLAB:Containers:TypeMismatch'
                    key_task_value = 6;
                case 'MATLAB:Containers:Map:NoKey'
                    key_task_value = 6;
                otherwise
                    ME.identifier
                    rethrow(ME)
            end
        end
        disp("key_task_value")
        disp(key_task_value)
        if key_task_value == 1 % index
            try
                left_hand_key = param.left_hand_keyboard_key_to_task_element(key);
            catch ME
                switch ME.identifier
                    case 'MATLAB:Containers:Map:NoKey'
                        left_hand_key = 6;
                    case 'MATLAB:Containers:TypeMismatch'
                        left_hand_key = 6;
                    otherwise
                        ME.identifier
                        rethrow(ME)
                end
            end
            if left_hand_key == 1
                hand_chosen = 'left_hand';
            end
            try
                right_hand_key = param.right_hand_keyboard_key_to_task_element(key);
            catch ME
                switch ME.identifier
                    case 'MATLAB:Containers:Map:NoKey'
                        right_hand_key = 6;
                    case 'MATLAB:Containers:TypeMismatch'
                        right_hand_key = 6;
                    otherwise
                        ME.identifier
                        rethrow(ME)
                end
            end
            if right_hand_key == 1
                hand_chosen = 'right_hand';
            end
        end
        if strcmp(LeftOrRightHand, hand_chosen)
            subject_has_picked_correct_sound = true;
            break;
        end
    end

    if quit
        logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
        logoriginal{end}{2} = 'STOP MANUALLY';
        Screen('CloseAll')
        PsychPortAudio('Close', pahandle);
        savefile(param,logoriginal,onset);
        break;
    end
    onset.seq(end+1) = GetSecs - timeStartExperience;
    logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
    logoriginal{end}{2} = 'Practice_SequenceTyping';
    if ~test
        logoriginal{end}{3} = ['MiniBlock', num2str(i)];
    else
        logoriginal{end}{3} = ['Block', num2str(i)];
    end

    [quit, keysPressed, timePressed] = displayCross(...
        window, param,...
        100, nbSeqPerBlock*length(l_seqUsed),...
        0,'green',param.durNoResponse, true, l_seqUsed)
    
    onset.seqDur(end+1) = (GetSecs-timeStartExperience) - onset.seq(end);

    [keys_as_sequence_element,  keys_source_keyboard_value] = ...
        ld_convertMultipleKeys(keysPressed, param.keyboard, ...
        param.keyboard_key_to_task_element);

    % Find Good sequences
    str_keys = num2str(keys_as_sequence_element);
    str_l_seqUsed = num2str(l_seqUsed);

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

    if size(strfind(str_keys,str_l_seqUsed),2) == nbSeqPerBlock && ~test
        PsychPortAudio('Start', pahandle, 1,0);
        PsychPortAudio('Stop', pahandle, 1);
    end

    if quit
        logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
        logoriginal{end}{2} = 'STOP MANUALLY';
        Screen('CloseAll')
        PsychPortAudio('Close', pahandle);
        savefile(param,logoriginal,onset);
        break;
    end

    % display red cross
    onset.rest(length(onset.rest)+1) = GetSecs - timeStartExperience;
    logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
    logoriginal{end}{2} = 'Rest';
    if ~test && ~quit
        jittered_rest_duration = randi(param.JitterRangeBetweenMiniBlocks);
        [quit, ~, ~] = displayCross(window, param, jittered_rest_duration, ...
                                            0, 0, 'red', 100);
        logoriginal{end}{3} = 'jittered';
    elseif ~quit
        [quit, keysPressed, timePressed] = displayCross(window, param, param.durRest,0,0,'red',100);
    end

    if quit
        logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
        logoriginal{end}{2} = 'STOP MANUALLY';
        Screen('CloseAll')
        PsychPortAudio('Close', pahandle);
        savefile(param,logoriginal,onset);
        break;
    end

end

% Display cross
if ~quit
    onset.rest(length(onset.rest)+1) = GetSecs - timeStartExperience;
    logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
    logoriginal{end}{2} = 'Rest';
    [quit, keysPressed, timePressed] = displayCross(window, param, param.durRest,0,0,'red',100);
end


% Record end of task
logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
logoriginal{end}{2} = 'STOP';

% Save file
savefile(param, logoriginal, onset);

PsychPortAudio('Close', pahandle);
Screen('CloseAll');
disp('!!! FINISHED !!!');
returnCode = 0;

end

