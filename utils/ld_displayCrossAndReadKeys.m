function [quit, waitMaxPassed, targetKeysPressed, invalidKeyPressed, keysPressed, timePressed] = ld_displayCrossAndReadKeys(...
    window, screenCenter, duration, nbKeys, validKeys, targetKeys, waitMax, ...
    crossColor, crossSize, msg, msgColor, msgTxtSize, footer, footerColor, footerTxtSize ...
    )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [quit, waitMaxPassed, targetKeyPressed, invalidKeyPressed, keysPressed, timePressed] = ld_displayCrossAndReadKeys(...
%       window, screenCenter...
%       )
% [quit, waitMaxPassed, targetKeyPressed, invalidKeyPressed, keysPressed, timePressed] = ld_displayCrossAndReadKeys(...
%       window, screenCenter, duration, nbKeys, keys4input, targetKey, waitMax, ...
%       crossColor, crossSize, msg, msgColor, msgTxtSize, footer, footerColor, footerTxtSize ...
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
%   validKeys                   cell array with valid input keys; default - any key
%   targetKeys      [string]    keys to be pressed to complete the task (default: no such keys)
%   waitMax         [double]    the maximum time, in seconds, to wait
%                               without any key pressed (default -
%                               unlimited)
%   crossColor      [string]    the color of the cross:
%                               'red' or 'green' (default: white).
%   crossSize       [int]       font height ex: 20, 40, 60, 80, 100...
%                               (default: 100)
%   msg             [string]    A message to present above the cross
%   msgColor        [string]    the color of the message: (default: gray)
%   msgTxtSize      [string]    the text size of the message: (default: 60)
%   footer          [string]    A footer to present at the bottom of the screen
%   footerColor     [string]    the color of the footer: (default: the same as msgColor)
%   footerTxtSize   [string]    the text size of the message: (default: 60)
%
%   quit                boolean     exited before the end (ESC)? (0: no; 1: yes)
%   waitMaxPassed       boolean     WaitMax is over and no response? (0: no; 1: yes)
%   targetKeysPressed   [boolean]   an array with booleans: 1 - if the target key was pressed; 0 - otherwise    
%   keysPressed         {string}    a cell array containing all the key names that were pressed
%   timePressed         [int]       a vector containing the time when the keysPressed were pressed
%
%
%   Ella Gabitov, October 2022 (adapted from stim)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 15, footerTxtSize = 60; end
if nargin < 14, footerColor = []; end
if nargin < 13, footer = []; end
if nargin < 12, msgTxtSize = 60; end
if nargin < 11, msgColor = []; end
if nargin < 10, msg = []; end
if nargin < 9 || isempty(crossSize), crossSize = 100; end
if nargin < 8 || isempty(crossColor), crossColor = 'white'; end
if nargin < 7 || isempty(waitMax), waitMax = inf; end
if nargin < 6, targetKeys = []; end
if nargin < 5, validKeys = []; end
if nargin < 4 || isempty(nbKeys), nbKeys = inf; end
if nargin < 3 || isempty(duration), duration = inf; end

%% INIT

red = [255, 0, 0, 255];
green = [0, 255, 0, 255];
white = [255, 255, 255, 255];
black = [0, 0, 0, 0];
gray=round((white+black)/2);

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
    
    if ~isnumeric(msgColor)
        switch msgColor
            case 'red'
                msgColorCode = red;
            case 'green'
                msgColorCode = green;
            case 'white'
                msgColorCode = white;
            case 'gold'
                msgColorCode = gold;
            otherwise
                msgColorCode = gray;
        end
    elseif ~isempty(msgColor)
        msgColorCode = msgColor;
    else
        msgColorCode = gray;
    end

    msg_sy= screenCenter(2)-crossSize;
end

% Footer display settings
if ~isempty(footer)
    
    if ~isnumeric(footerColor)
        switch footerColor
            case 'red'
                footerColorCode = red;
            case 'green'
                footerColorCode = green;
            case 'white'
                footerColorCode = white;
            case 'gold'
                footerColorCode = gold;
            otherwise
                footerColorCode = gray;
        end
    elseif ~isempty(footerColor)
        footerColorCode = footerColor;
    else
        footerColorCode = gray;
    end

    footer_sy= screenCenter(2)*1.8;
end


%%

% Get initial font settings
[prevFontName,~,~] = Screen('TextFont', window, 'Arial');
prevTextSize = Screen('TextSize', window);

% Draw message
if ~isempty(msg)
    Screen('TextSize', window, msgTxtSize);
    DrawFormattedText(window, msg, 'center', msg_sy, msgColorCode);
end

% Draw cross
Screen('TextSize', window, crossSize);
DrawFormattedText(window, '+', 'center', 'center', crossColorCode);

% Draw cross
Screen('TextSize', window, footerTxtSize);
DrawFormattedText(window, footer, 'center', 'center', footerColorCode);

% Wait for release of all keys on keyboard
KbReleaseWait;

% Show on the screen
Screen('Flip', window);

% Read keys
timeStartReading = GetSecs;

[quit, waitMaxPassed, targetKeysPressed, invalidKeyPressed, keysPressed, timePressed] = ld_keysRead(...
    timeStartReading, duration, nbKeys, validKeys, targetKeys, 0, waitMax ...
    );

%% SET TO THE INITIAL PARAMETERS

Screen('TextFont', window, prevFontName);
Screen('TextSize', window, prevTextSize);

end
