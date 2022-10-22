 function [quit, targetKeyPressed, keysPressed, timePressed] = ld_keys_read(...
    timeStartReading, duration, nbKeys, targetKey, acceptTtl, waitMax)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [quit, keysPressed, timePressed] = ld_keys_read(...
%   timeStartReading, duration, nbKeys, targetKey, acceptTtl, waitMax)
%
% Record keys that have been pressed for a period of time. Reading at keys
% using KbCheck of the Psychtoolbox. (ESC to quit)
%
% INPUT
%   timeStartReading
%   duration            duration, in sec, before exiting; default - unlimited
%   nbKeys              number of keysPresses to press before exiting; default - unlimited
%   targetKey           key to be pressed to complete the task (default: no such key)
%   acceptTtl           0 - the value of TTL (='5') is not accepted 
%   waitMax             the maximum time to wait without any key pressed;default - unlimited
%
% OUTPUT
%   quit                boolean     exited before the end (ESC)? (0: no; 1: yes)
%   targetKeyPressed    boolean     1 - if the target key was pressed; 0 - otherwise    
%   keysPressed         {string}    a cell array containing all the key names that were pressed
%   timePressed         [int]       a vector containing the time when the keysPressed were pressed
%
% Vo An Nguyen 2007/04/24
% Ella Gabitov, October 2022
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Is used to check if the participant keeps pressing the buttons
if nargin < 6, waitMax = Inf; end

% 0 - discard the TTL input (='5'), 1 - otherwise
if nargin < 5, acceptTtl = 0; end 

% The target key to be pressed to complete the task
% Once this key is captured, the task is over
if nargin < 4 || isempty(targetKey)
    targetKey = 'no target key';
end

% limits the number of keys to complete the task
if nargin < 3 || nbKeys == 0 || isempty(nbKeys) || isnan(nbKeys)
    nbKeys = Inf;
end

% limits the duration of the task
if nargin < 2 || duration == 0 || isempty(duration) || isnan(duration)
    duration = Inf;
end

timeStartPrevious = timeStartReading;
countKeys = 1;

quit = 0;
targetKeyPressed = 0;
keysPressed = {};
timePressed = [];

while ~quit && ~targetKeyPressed && ...
        (countKeys <= nbKeys) && ...
        ((GetSecs - timeStartReading) < duration) && ...
        ((GetSecs - timeStartPrevious) < waitMax)

    [~, secs, keyCode, ~] = KbCheck(-3);
    keyName = KbName(keyCode);

    if ~isempty(keyName)
        if ~iscell(keyName), keyName = {keyName}; end
        
        countKeys = countKeys + 1;
        quit = any(contains(lower(keyName), 'esc'));
        ttlKeyPressed = any(contains(keyName, '5'));
        targetKeyPressed = any(contains(keyName, targetKey));

        if ~ quit && ...
                (~ttlKeyPressed || (ttlKeyPressed && acceptTtl))
            timePressed(end+1) = secs;
            keysPressed(end+1:(numel(keysPressed)+numel(keyName))) = keyName;
            timeStartPrevious = secs;
        end
        
        KbReleaseWait;
    end
end

end
