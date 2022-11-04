function [quit, waitMaxPassed, targetKeysPressed, invalidKeyPressed, keysPressed, timePressed] = ld_keysRead(...
    timeStartReading, duration, nbKeys, validKeys, targetKeys, acceptTtl, waitMax)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [quit, waitMaxPassed, targetKeyPressed, keysPressed, timePressed, invalidKeyPressed] = ld_keysRead(...
%   timeStartReading, duration, nbKeys, targetKey, acceptTtl, waitMax)
%
% Captures keys that have been pressed for a period of time, or a given
% number of keys, or until the target key is pressed. When keys4input is 
% provided, the function exits if invalid key is presssed.
% Press 'ESC' to exit.
%
% INPUT
%   timeStartReading
%   duration            duration, in sec, before exiting; default - unlimited
%   nbKeys              number of keysPresses to press before exiting; default - unlimited
%   validKeys           cell array with valid input keys; default - any key
%   targetKeys          keys to be pressed, in order, to complete the task (default: no such keys)
%   acceptTtl           0 - the value of TTL (='5') is not accepted 
%   waitMax             the maximum time to wait without any key pressed;default - unlimited
%
% OUTPUT
%   quit                boolean     exited before the end (ESC)? (0: no; 1: yes)
%   waitMaxPassed       boolean     WaitMax is over and no response? (0: no; 1: yes)
%   targetKeysPressed   [boolean]   an array with booleans: 1 - if the target key was pressed; 0 - otherwise    
%   keysPressed         {string}    a cell array containing all the key names that were pressed
%   timePressed         [int]       a vector containing the time when the keysPressed were pressed
%   invalidKeyPressed   boolean     1 - if key that is not in keys4input is pressed
%
% Vo An Nguyen 2007/04/24
% Ella Gabitov, October 2022
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Is used to check if the participant keeps pressing the buttons
if nargin < 7 || isempty(waitMax), waitMax = Inf; end

% 0 - discard the TTL input (='5'), 1 - otherwise
if nargin < 6 || isempty(waitMax), acceptTtl = 0; end 

% The target key to be pressed to complete the task
% Once this key is captured, the task is over
if nargin < 5 || isempty(targetKeys), targetKeys = {}; end

% Valid input keys
if nargin < 4, validKeys = []; end

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
countKeys = 0;

quit = 0;
waitMaxPassed = 0;
invalidKeyPressed = 0;

if isempty(targetKeys)
    targetKeysPressed = 0;
else
    if ~iscell(targetKeys)
        targetKeys = {targetKeys};
    end
    targetKeysPressed = zeros(1, numel(targetKeys));
end
i_targetKey = 1;

returnNow = quit || waitMaxPassed || all(targetKeysPressed) || invalidKeyPressed;

keysPressed = {};
timePressed = [];

disp('');
fprintf('Reading input keys: ');
while ~returnNow && ...
        (countKeys < nbKeys) && ...
        ((GetSecs - timeStartReading) < duration)

    [~, secs, keyCode, ~] = KbCheck([]);
    waitMaxPassed = waitMax < (secs - timeStartPrevious);
   
    keyCodePressed = keyCode & ~keyCodePressedPrevious; 
    % Key was pressed
    if any(keyCodePressed)
        keyName = KbName(keyCodePressed);
        fprintf([keyName, ' ']);
        quit = any(contains(lower(keyName), 'esc'));
        ttlKeyPressed = any(contains(keyName, '5'));
        if ~isempty(validKeys)
            invalidKeyPressed = ~all(contains(keyName, validKeys));
        end

        returnNow = quit || waitMaxPassed || invalidKeyPressed;

        if ~ returnNow && ...
                (~ttlKeyPressed || (ttlKeyPressed && acceptTtl))
            countKeys = countKeys + 1;
            
            % Only one key was pressed, check if it is a target
            if ~iscell(keyName) && ~isempty(targetKeys)
                % The next target key was pressed
                if contains(keyName, targetKeys{i_targetKey})
                    targetKeysPressed(i_targetKey) = 1;
                    i_targetKey = i_targetKey + 1;
                % The key is not a target, reset
                else
                    targetKeysPressed = zeros(1, numel(targetKeys));
                    i_targetKey = 1;
                end
            end
            
            % multiple keys are stored in a single cell
            timePressed(end+1) = secs;
            keysPressed{end+1} = keyName;

        end
        timeStartPrevious = secs;
    end 

    keyCodePressedPrevious = keyCode;
    returnNow = quit || waitMaxPassed || all(targetKeysPressed) || invalidKeyPressed;

end

fprintf('\n');

end
