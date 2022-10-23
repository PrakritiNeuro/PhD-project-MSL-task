 function [quit, waitMaxPassed, targetKeyPressed, keysPressed, timePressed] = ld_keysRead(...
    timeStartReading, duration, nbKeys, targetKey, acceptTtl, waitMax)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [quit, keysPressed, timePressed] = ld_keysRead(...
%   timeStartReading, duration, nbKeys, targetKey, acceptTtl, waitMax)
%
% Captures keys that have been pressed for a period of time, or a given
% number of keys, or intil the target key is pressed.
% Press 'ESC' to exit.
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
%   waitMaxPassed       boolean     WaitMax is over and no response? (0: no; 1: yes)
%   targetKeyPressed    boolean     1 - if the target key was pressed; 0 - otherwise    
%   keysPressed         {string}    a cell array containing all the key names that were pressed
%   timePressed         [int]       a vector containing the time when the keysPressed were pressed
%
% Vo An Nguyen 2007/04/24
% Ella Gabitov, October 2022
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Is used to check if the participant keeps pressing the buttons
if nargin < 6 || isempty(waitMax), waitMax = Inf; end

% 0 - discard the TTL input (='5'), 1 - otherwise
if nargin < 5 || isempty(waitMax), acceptTtl = 0; end 

% The target key to be pressed to complete the task
% Once this key is captured, the task is over
if nargin < 4, targetKey = []; end

% limits the number of keys to complete the task
if nargin < 3 || isempty(nbKeys)
    nbKeys = Inf;
end

% limits the duration of the task
if nargin < 2 || isempty(duration)
    duration = Inf;
end

% Maximum waiting time cannot be longer than duration
if duration < waitMax, waitMax = duration; end

timeStartPrevious = timeStartReading;
keyCodePressedPrevious = zeros(1, 256);
countKeys = 1;

quit = 0;
waitMaxPassed = 0;
targetKeyPressed = 0;
keysPressed = {};
timePressed = [];

while ~quit && ~waitMaxPassed && ~targetKeyPressed && ...
        (countKeys <= nbKeys) && ...
        ((GetSecs - timeStartReading) < duration)

    [~, secs, keyCode, ~] = KbCheck([]);
    waitMaxPassed = waitMax < (secs - timeStartPrevious);
   
    keyCodePressed = keyCode & ~keyCodePressedPrevious; 
    % Key was pressed
    if any(keyCodePressed)
        keyName = KbName(keyCodePressed);
        quit = any(contains(lower(keyName), 'esc'));

        % Interval within the waitMax time
        if ~waitMaxPassed
            countKeys = countKeys + 1;

            ttlKeyPressed = any(contains(keyName, '5'));
            if ~ quit && ...
                    (~ttlKeyPressed || (ttlKeyPressed && acceptTtl))
                % Only one key was pressed
                if ~iscell(keyName) && ~isempty(targetKey)
                    targetKeyPressed = contains(keyName, targetKey);
                end
                % multiple keys are stored in a single cell
                timePressed(end+1) = secs;
                keysPressed{end+1} = keyName;
            end
        end % If interval within the waitMax time

        timeStartPrevious = secs;
    end 

    keyCodePressedPrevious = keyCode;

end
