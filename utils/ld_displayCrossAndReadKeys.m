function [quit, waitMaxPassed, targetKeyPressed, keysPressed, timePressed] = ld_displayCrossAndReadKeys(...
    window, screenCenter, duration, nbKeys, targetKey, waitMax, flickeringFreq, crossColor, crossSize, msg ...
    )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [quit, keysPressed, timePressed] = ld_displayCrossAndReadKeys(...
%       window, screenCenter...
%       )
% [quit, keysPressed, timePressed] = ld_displayCrossAndReadKeys(...
%       window, screenCenter, duration, nbKeys, targetKey, waitMax, flickeringFreq, crossColor, crossSize, msg...
%       )
%
% Fixation cross is displayed and keys are captured using ld_keysRead
% function. Press ESC to exit.
%
% INPUT:
%   window                      Psychtoolbox window (required)
%   screenCenter    [int, int]  (x,y) coordinates of the screen center, in
%                               pixels (required)
%   duration        [double]    duration of the stimulus in secs (default: infinite)
%   nbKeys          [int]       number of keys pressed before exit (default: unlimited)
%   targetKey       [string]    key to be pressed to complete the task (default: no such key)
%   waitMax         [double]    the maximum time, in seconds, to wait
%                               without any key pressed (default -
%                               unlimited)
%   flickeringFreq  [int]       Cross blinking frequency in Hz (default: 0
%                               = static without blinking)
%   crossColor      [string]    the color of the cross:
%                               'red' or 'green' (default: white).
%   crossSize       [int]       font height ex: 20, 40, 60, 80, 100...
%                               (default: 100)
%   msg         [string]        A message to present above the cross
%
%   quit                boolean     exited before the end (ESC)? (0: no; 1: yes)
%   waitMaxPassed       boolean     WaitMax is over and no response? (0: no; 1: yes)
%   targetKeyPressed    boolean     1 - if the target key was pressed; 0 - otherwise    
%   keysPressed         {string}    a cell array containing all the key names that were pressed
%   timePressed         [int]       a vector containing the time when the keysPressed were pressed
%
%
%   Ella Gabitov, October 2022 (adapted from stim)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 10, msg = []; end
if nargin < 9 || isempty(crossSize), crossSize = 100; end
if nargin < 8 || isempty(crossColor), crossColor = 'white'; end
if nargin < 7 || isempty(flickeringFreq), flickeringFreq = 0; end
if nargin < 6 || isempty(waitMax), waitMax = inf; end
if nargin < 5, targetKey = []; end
if nargin < 4 || isempty(nbKeys), nbKeys = inf; end
if nargin < 3 || isempty(duration), duration = inf; end


%% INIT

keysPressed = [];
timePressed = [];

red = [255, 0, 0, 255];
green = [0, 255, 0, 255];
white = [255, 255, 255, 255];
gold = [255, 215, 0, 255];

switch crossColor
    case 'red'
        crossColorCode = red;
    case 'green'
        crossColorCode = green;
    otherwise
        crossColorCode = white;
end

% Message display settings
if ~isempty(msg)
    msgTxtSize = 60;
    msgColorCode = gold;
    msg_sy= screenCenter(2)-crossSize;
end

%%

% Get initial font settings
[prevFontName,~,~] = Screen('TextFont', window, 'Arial');
prevTextSize = Screen('TextSize', window);

% Static cross without flickering
if (flickeringFreq == 0)
    % Draw message
    if ~isempty(msg)
        Screen('TextSize', window, msgTxtSize);
        DrawFormattedText(window, msg, 'center', msg_sy, msgColorCode);
    end
    
    % Draw cross
    Screen('TextSize', window, crossSize);
    DrawFormattedText(window, '+', 'center', 'center', crossColorCode);

    % Wait for release of all keys on keyboard
    KbReleaseWait;

    % Show on the screen
    Screen('Flip', window);

    % Read keys
    timeStartReading = GetSecs;

    [quit, waitMaxPassed, targetKeyPressed, keysPressed, timePressed] = ld_keysRead(...
        timeStartReading, duration, nbKeys, targetKey, 0, waitMax);

 % Flickering cross
else
    quit = 0;
    timeStartTask = GetSecs;

    while ~quit && (GetSecs-timeStartTask) < duration
        % Draw message
        if ~isempty(msg)
            Screen('TextSize', window, msgTxtSize);
            DrawFormattedText(window, msg, 'center', msg_sy, msgColorCode);
        end
    
        % Draw cross
        Screen('TextSize', window, crossSize);
        DrawFormattedText(window, '+', 'center', 'center', crossColorCode);

        % Wait for release of all keys on keyboard
        KbReleaseWait;

        % Show on the screen
        Screen('Flip', window);

        % Read keys
        timeStartReading = GetSecs;
        [quit, waitMaxPassed, targetKeyPressed, keysTmp, timeTmp] = ld_keysRead(...
            timeStartReading, (1/flickeringFreq)/2);
        
        keysPressed = cat(2, keysPressed, keysTmp);
        timePressed = cat(2, timePressed, timeTmp);
        
        % Exit
        if quit, break; end

        % The task is over
        if GetSecs-timeStartTask >= duration, break; end    

        % Display black screen
        Screen('FillRect', window, BlackIndex(window));
        Screen('Flip', window);
        
        % read keys
        timeStartReading = GetSecs;
        [quit, targetKeyPressed, keysTmp, timeTmp] = ld_keys_read(...
            timeStartReading, (1/flickeringFreq)/2);
        keysPressed = cat(2, keysPressed, keysTmp);
        timePressed = cat(2, timePressed, timeTmp);

    end
end

Screen('TextFont', window, prevFontName);
Screen('TextSize', window, prevTextSize);

end
