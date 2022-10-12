function [returnCode] = ld_intro(param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% returnCode = en_intro(param)
%
% introduction to the sequence. Exiting after x successful sequences in a
% row
%
% param:            structure containing parameters (see en_parameters.m)
% returnCode:       error returned
%
%
% Vo An Nguyen 2010/10/07
% Arnaud Bore 2012/10/05, CRIUGM - arnaud.bore@gmail.com
% Arnaud Bore 2014/10/31 
% EG March 9, 2015 
% Arnaud Bore 2016/05/27
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CREATION OF THE WINDOW
[window, param.screenResolution] = createWindow(param);

% defining local durations
show_hand_duration  = 3; % in seconds
show_instruction_duration = 3; % in seconds
red_cross_duration = 3; % in seconds


% % Get information about the task
% l_seqUsed = param.seqA;

NbSeqOK = 0;
logoriginal = [];
quit = false;

timeStartExperience = GetSecs;

% Display instruction message
Screen('TextFont', window, 'Arial');
Screen('TextSize', window, param.textSize); 
gold = [255, 215, 0, 255];
black = [0, 0, 0, 255];

% Pre-experiment text
DrawFormattedText(window,'PERFORM THE SEQUENCES SLOWLY','center',100,gold);
DrawFormattedText(window,'AND WITHOUT ANY ERRORS:','center',200,gold);
DrawFormattedText(window,'... Are you ready to continue? ...','center',600,gold);
Screen('Flip', window);

% Wait for TTL (or keyboard input) before starting
% FlushEvents('keyDown');
[~, ~, keyCode] = KbCheck(-1);
strDecoded = ld_convertKeyCode(keyCode, param.keyboard);
while isempty(strfind(strDecoded, '5'))
    [~, ~, keyCode] = KbCheck(-1);
    strDecoded = ld_convertKeyCode(keyCode, param.keyboard);
end
Screen('FillRect', window, BlackIndex(window));

logoriginal{length(logoriginal)+1}{1} = num2str(GetSecs - timeStartExperience);
logoriginal{length(logoriginal)}{2} = param.task;
logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
logoriginal{end}{2} = 'START';

learning_sequence_a_or_b = [1;2];
learning_sequence_a_or_b = learning_sequence_a_or_b(...
    randperm(numel(learning_sequence_a_or_b)));

% LOOP: Learning sequences
for i = 1:numel(learning_sequence_a_or_b)
    if quit
        logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
        logoriginal{end}{2} = 'STOP MANUALLY';
        Screen('CloseAll');
        % Save file.mat
        i_name = 1;
        output_file_name = [param.outputDir, param.subject, '_', param.task, '_', ...
                                                    num2str(i_name), '.mat'];
        while exist(output_file_name, 'file')
            i_name = i_name+1;
            output_file_name = [param.outputDir, param.subject, '_', param.task, ...
                                            '_' , num2str(i_name), '.mat'];
        end
        save(output_file_name, 'logoriginal', 'param');
        return;
    end

    if learning_sequence_a_or_b(i) == 1
        l_seqUsed = param.seqA;
        LeftOrRightHand = param.HandSoundSequenceAssociation.seqA.hand;
    elseif learning_sequence_a_or_b(i) == 2
        l_seqUsed = param.seqB;
        LeftOrRightHand = param.HandSoundSequenceAssociation.seqB.hand;
    end

    screen_width = param.screenResolution(1);
    screen_height = param.screenResolution(2);
    if strcmp(LeftOrRightHand, 'left_hand')
        [image_hand, ~, alpha] = imread([param.rawDir 'stimuli' filesep 'left-hand_with-numbers.png']); % Left Hand
        image_height = size(image_hand,1);
        image_width = size(image_hand,2);
        param.keyboard_key_to_task_element = param.left_hand_keyboard_key_to_task_element;
        hand_position = [round(screen_width/2 - image_width - 50) ...
            round(screen_height/2 - image_height/2) ...
            round(screen_width/2 - 50) ...
            round(screen_height/2 + image_height/2)...
            ];

    elseif strcmp(LeftOrRightHand, 'right_hand')
        [image_hand, ~, alpha] = imread([param.rawDir 'stimuli' filesep 'right-hand_with-numbers.png']); % Right Hand
        image_height = size(image_hand,1);
        image_width = size(image_hand,2);
        param.keyboard_key_to_task_element = param.right_hand_keyboard_key_to_task_element;
        hand_position = [round(screen_width/2 + 50) ...
            round(screen_height/2 - image_height/2) ...
            round(screen_width/2 + image_width + 50) ...
            round(screen_height/2 + image_height/2)...
            ];
    end

    texture_hand = Screen('MakeTexture', window, image_hand);

    Screen('DrawTexture',window,texture_hand,[],hand_position);
    Screen('TextSize', window, param.crossSize);
    DrawFormattedText(window, '+', 'center', 'center', param.white);
    Screen('TextSize', window, param.textSize);
    Screen('Flip', window);
    
    pause(show_hand_duration)
    Screen('FillRect', window, BlackIndex(window));
    
    % showing the seqquence
    Screen('TextFont', window, 'Arial');
    Screen('TextSize', window, param.textSize);
    DrawFormattedText(window,'PERFORM THE SEQUENCE SLOWLY','center',100,gold);
    DrawFormattedText(window,'AND WITHOUT ANY ERRORS:','center',200,gold);
    DrawFormattedText(window,num2str(l_seqUsed),'center',300,gold);
    Screen('Flip', window);
    pause(show_instruction_duration)
    
    % display red cross
    logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
    logoriginal{end}{2} = 'Rest';
    [quit, ~, ~] = displayCross(window, param, ...
                                        red_cross_duration, 0, 0, 'red', 100);
    if quit
        logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
        logoriginal{end}{2} = 'STOP MANUALLY';
        Screen('CloseAll');
        % Save file.mat
        i_name = 1;
        output_file_name = [param.outputDir, param.subject, '_', param.task, '_', ...
                                                    num2str(i_name), '.mat'];
        while exist(output_file_name, 'file')
            i_name = i_name+1;
            output_file_name = [param.outputDir, param.subject, '_', param.task, ...
                                            '_' , num2str(i_name), '.mat'];
        end
        save(output_file_name, 'logoriginal', 'param');
        return;
    end

    % subject must type sequence once correctly
    if ~quit
        % Testing number of good sequences entered
        logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
        logoriginal{end}{2} = 'Practice';
        logoriginal{end}{3} = LeftOrRightHand;
        NbSeqOK = 0;
        while (NbSeqOK < param.nbSeqIntro)
    
            % Sequence
            seqOK = 0;
            index = 0;
            keyTmp = [];
            while seqOK == 0
                [quit, key, timePressed] = displayCross(...
                    window, param, 0,1,0,'green', 100, ...
                    true, l_seqUsed);
                    if quit
                        logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
                        logoriginal{end}{2} = 'STOP MANUALLY';
                        Screen('CloseAll');
                        % Save file.mat
                        i_name = 1;
                        output_file_name = [param.outputDir, param.subject, '_', param.task, '_', ...
                                                                    num2str(i_name), '.mat'];
                        while exist(output_file_name, 'file')
                            i_name = i_name+1;
                            output_file_name = [param.outputDir, param.subject, '_', param.task, ...
                                                            '_' , num2str(i_name), '.mat'];
                        end
                        save(output_file_name, 'logoriginal', 'param');
                        return;
                    end

                strDecoded = ld_convertKeyCode(key, param.keyboard);
                key = ld_convertOneKey(strDecoded);

                try
                    key = param.keyboard_key_to_task_element(key);
                catch ME
                    switch ME.identifier
                        case 'MATLAB:Containers:Map:NoKey'
                            key = 0;
                        otherwise
                            ME.identifier
                            rethrow(ME)
                    end
                end

                disp(key)
                
                logoriginal{end+1}{1} = num2str(timePressed - timeStartExperience);
                logoriginal{end}{2} = 'rep';
                logoriginal{end}{3} = num2str(key);
    
                index = index + 1;
                keyTmp(index) = key;
                if index >= length(l_seqUsed)
                    if keyTmp == l_seqUsed
                        seqOK = 1;
                        NbSeqOK = NbSeqOK + 1;
                    else
                        keyTmp(1) = [];
                        index = index - 1;
                        NbSeqOK = 0;
                    end
                end
            end % End while loop: check if sequence is ok 
            if quit
                logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
                logoriginal{end}{2} = 'STOP MANUALLY';
                Screen('CloseAll');
                % Save file.mat
                i_name = 1;
                output_file_name = [param.outputDir, param.subject, '_', param.task, '_', ...
                                                            num2str(i_name), '.mat'];
                while exist(output_file_name, 'file')
                    i_name = i_name+1;
                    output_file_name = [param.outputDir, param.subject, '_', param.task, ...
                                                    '_' , num2str(i_name), '.mat'];
                end
                save(output_file_name, 'logoriginal', 'param');
                return;
            end
        end
    end
    % display red cross
    logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
    logoriginal{end}{2} = 'Rest';
    [quit, ~, ~] = displayCross(window, param, ...
                                        red_cross_duration, 0, 0, 'red', 100);

end


Screen('CloseAll');

% Save file.mat
i_name = 1;
output_file_name = [param.outputDir, param.subject, '_', param.task, '_', ...
                                            num2str(i_name), '.mat'];
while exist(output_file_name, 'file')
    i_name = i_name+1;
    output_file_name = [param.outputDir, param.subject, '_', param.task, ...
                                    '_' , num2str(i_name), '.mat'];
end
save(output_file_name, 'logoriginal', 'param');

returnCode = 0;