function [returnCode] = ld_verification(param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% returnCode = en_verification(param)
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
% EG March 9, 2015  
% Arnaud Boré 2016/05/30 Stim
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INIT
% CREATION OF THE WINDOW
[window, param.screenResolution] = createWindow(param);

logoriginal = [];

% Display instruction message
Screen('TextFont', window, 'Arial');
Screen('TextSize', window, param.textSize);
gold = [255, 215, 0, 255];

% Pre-experiment text
DrawFormattedText(window,'You will press all keys, in order, for each hand','center',100,gold);
DrawFormattedText(window,'Index Finger = 1, Major Finger = 2','center',200,gold);
DrawFormattedText(window,'Ring Finger = 3, Pinkie Finger = 4','center',300,gold);
DrawFormattedText(window,'... Are you ready to start? ...','center',400,gold);
Screen('Flip', window);

% Wait for TTL (or keyboard input) before starting
% FlushEvents('keyDown');
[~, ~, keyCode] = KbCheck(-1);
strDecoded = ld_convertKeyCode(keyCode, param.keyboard);
while isempty(strfind(strDecoded, '5'))
    [~, ~, keyCode] = KbCheck(-1);
    strDecoded = ld_convertKeyCode(keyCode, param.keyboard);
end

learning_sequence_a_or_b = [1;2];
learning_sequence_a_or_b = learning_sequence_a_or_b(...
    randperm(numel(learning_sequence_a_or_b)));

% LOOP: Learning sequences
for i = 1:numel(learning_sequence_a_or_b)
    if learning_sequence_a_or_b(i) == 1
        LeftOrRightHand = param.HandSoundSequenceAssociation.seqA.hand;
    elseif learning_sequence_a_or_b(i) == 2
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

    success = 0;

    message = {
                '1 = Index finger',...
                '2 = Middle finger',...
                '3 = Ring finger',...
                '4 = Little finger'
                };
    keySet = {1, 2, 3, 4};
    valueSet = {'Index finger', 'Middle finger', ...
        'Ring finger', 'Little finger'};
    finger_name = containers.Map(keySet,valueSet);

    timeStartExperience = GetSecs;

    % Display instruction message
    Screen('TextSize',window, 30);

    for j=1:4
        DrawFormattedText(window,message{j},650,100*j+50,gold);
    end

    verif = [1,2,3,4];
    Screen('DrawTexture',window,texture_hand,[], hand_position);



    Screen('Flip', window);
    pause(4);

    % Test all the buttons
    logoriginal{length(logoriginal)+1}{1} = num2str(GetSecs - timeStartExperience);
    logoriginal{length(logoriginal)}{2} = param.task;

    for nButton = 1:4
        while success == 0
            [quit, key, time] = displayMessage(param.keyboard, window, ...
                ['Press ' num2str(verif(nButton))],0,1,0,'gold',40);
            if quit break; end %#ok<SEPEX>

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

            if key == nButton
                success = 1;
            end
            logoriginal{length(logoriginal)+1}{1} = num2str(time - timeStartExperience);
            logoriginal{length(logoriginal)}{2} = 'rep';
            logoriginal{length(logoriginal)}{3} = num2str(key);
        end
        if quit break; end %#ok<SEPEX>
        success = 0;
    end
end
Screen('CloseAll');

% Save file.mat
i_name = 1;
output_file_name = [param.outputDir, param.subject,'_',param.task,'_' , num2str(i_name) ,'.mat'];
while exist(output_file_name,'file')
    i_name = i_name+1;
    output_file_name = [param.outputDir, param.subject,'_',param.task,'_' , num2str(i_name) ,'.mat'];
end
save(output_file_name, 'logoriginal', 'param'); 

returnCode = 0;