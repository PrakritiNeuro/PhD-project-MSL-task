 function [quit, keysPressed, timePressed] = readKeys(...
    timeStartReading, ...
    duration, ...
    nbKeys, ...
    acceptTtl, ...
    waitMax)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [quit, keysPressed, timePressed] = ReadKeys(currentKeyboard,
% timeStartReading ,duration, nbKeys, acceptTtl, waitMax);
%
% Record keys that have been pressed for a period of time. Reading at keys
% using KbCheck of the Psychtoolbox. (ESC to quit)
%
% INPUT
%   timeStartReading
%   duration            duration, in sec, before exiting; default - unlimited
%   nbKeys              number of keysPresses to press before exiting; default - unlimited
%   acceptTtl           0 - the value of TTL (='5') is not accepted 
%   waitMax             the maximum time to wait without any key pressed;default - unlimited
%
% OUTPUT
%   quit            boolean     exited before the end (ESC)? (0: no; 1: yes)
%   keysPressed     {string}    a cell array containing all the key names that were pressed
%   timePressed     [int]       a vector containing the time when the keysPressed were pressed
%
% Vo An Nguyen 2007/04/24
% Ella Gabitov, October 2022
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% is used to check if the participant keeps pressing the buttons
if nargin < 6, waitMax = Inf; end

% 0 - discard the TTL input (='5'), 1 - otherwise
if nargin < 5, acceptTtl = 0; end 

% limits the number of keys to complete the task
if nargin < 4 || nbKeys == 0 || isempty(nbKeys) || isnan(nbKeys)
    nbKeys = Inf;
end

% limits the duration of the task
if nargin < 3 || duration == 0 || isempty(duration) || isnan(duration)
    duration = Inf;
end

timeStartPrevious = timeStartReading;
keyCodePressedPrevious = zeros(1, 256);
index = 1;

quit = 0;
keysPressed = {};
timePressed = [];

while ~quit && ...
        (index <= nbKeys) && ...
        ((GetSecs - timeStartReading) < duration) && ...
        ((GetSecs - timeStartPrevious) < waitMax)

    [~, secs, keyCode, ~] = KbCheck(-3);
    keyCodePressed = keyCode & ~keyCodePressedPrevious;

    if any(keyCodePressed)
        keyName = KbName(keyCodePressed);
        if ~iscell(keyName), keyName = {keyName}; end
        quit = any(contains(lower(keyName), 'esc'));
        ttlKeyPressed = any(contains(keyName, '5'));
        if ~ quit && ...
                (~ttlKeyPressed || (ttlKeyPressed && acceptTtl)) && ...
                ~any(contains(lower(keyName), 'f'))                         % don't accept 'f'/'F' as a valid input value
            timePressed(end+1) = secs;
            keysPressed(end+1:(numel(keysPressed)+numel(keyName))) = keyName;
            timeStartPrevious = secs;
        end
    end
    keyCodePressedPrevious = keyCode;
end

end
