function [returnCode] = ld_introSeq(param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% returnCode = ld_introSeq(param)
%
% Introduction of the sequence(s).
% Exiting after x successful sequences in a row
%
% param:            structure containing parameters (see en_parameters.m)
% returnCode:       error returned
%
%
% Vo An Nguyen 2010/10/07
% Arnaud Bore 2012/10/05, CRIUGM - arnaud.bore@gmail.com
% Arnaud Bore 2014/10/31 
% Ella Gabitov, March 9, 2015 
% Arnaud Bore 2016/05/27
% Ella Gabitov, October 2022
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% DISPLAY SETTINGS

[window, screenSize, screenCenter] = ld_createWindow(param);

% defining local durations
show_hand_duration  = 3; % in seconds
show_instruction_duration = 3; % in seconds
red_cross_duration = 3; % in seconds

% randomize the order of the sequences
rnd_inds = randsample(1:numel(param.soundHandSeq), numel(param.soundHandSeq));

logoriginal = [];
quit = false;

timeStartExperience = GetSecs;

% font settings
Screen('TextFont', window, 'Arial');
Screen('TextSize', window, param.textSize); 

% colors for display
gold = [255, 215, 0, 255];
black = [0, 0, 0, 255];
white = [255, 255, 255, 255];

% Pre-experiment text
DrawFormattedText(window,'You will be presented with two sequences, one for each hand','center',100,gold);
DrawFormattedText(window,'You will need to perform each sequence repeatedly in a comfortable pace as accurately as possible','center',200,gold);
DrawFormattedText(window,'Please, stay still when you see the RED cross','center',300,gold);
DrawFormattedText(window,'Perform the sequence only when you see the GREEN cross and the sequence','center',400,gold);
DrawFormattedText(window,'If you make an error, just start the sequence from its first key','center',500,gold);
DrawFormattedText(window,'... GET READY FOR THE TASK ...','center',1000,gold);
Screen('Flip', window);

% Wait for TTL (or keyboard input) before starting
% FlushEvents('keyDown');
[~, ~, keyCode] = KbCheck(-1);
strDecoded = ld_convertKeyCode(keyCode, param.keyboard);
while ~any(contains(strDecoded, '5'))
    [~, ~, keyCode] = KbCheck(-1);
    strDecoded = ld_convertKeyCode(keyCode, param.keyboard);
end
Screen('FillRect', window, BlackIndex(window));

logoriginal{length(logoriginal)+1}{1} = num2str(GetSecs - timeStartExperience);
logoriginal{length(logoriginal)}{2} = param.task;
logoriginal{end+1}{1} = num2str(GetSecs - timeStartExperience);
logoriginal{end}{2} = 'START';


% LOOP: sequences
for i = 1:numel(rnd_inds)
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

    seq = param.soundHandSeq(rnd_inds(i)).seq;
    hand = param.soundHandSeq(rnd_inds(i)).hand;
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

    texture_hand = Screen('MakeTexture', window, img);

    Screen('DrawTexture',window,texture_hand,[],img_position);
    Screen('TextSize', window, param.crossSize);
    DrawFormattedText(window, '+', 'center', 'center', white);
    Screen('TextSize', window, param.textSize);
    Screen('Flip', window);
    
    pause(show_hand_duration)
    Screen('FillRect', window, BlackIndex(window));
    
    % showing the seqquence
    Screen('TextFont', window, 'Arial');
    Screen('TextSize', window, param.textSize);
    DrawFormattedText(window,'PERFORM THE SEQUENCE SLOWLY','center',100,gold);
    DrawFormattedText(window,'AND WITHOUT ANY ERRORS:','center',200,gold);
    DrawFormattedText(window,num2str(seq),'center',300,gold);
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
        logoriginal{end}{3} = hand;
        NbSeqOK = 0;
        while (NbSeqOK < param.nbSeqIntro)
    
            % Sequence
            seqOK = 0;
            index = 0;
            keyTmp = [];
            while seqOK == 0
                [quit, key, timePressed] = displayCross(...
                    window, param, 0,1,0,'green', 100, ...
                    true, seq);
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
                if index >= length(seq)
                    if keyTmp == seq
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