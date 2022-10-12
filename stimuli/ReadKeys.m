function [quit, keysPressed, timePressed] = ReadKeys(...
    currentKeyboard, ...
    timeStartReading, ...
    duration, ...
    nbKeys, ...
    accept_ttl, ...
    wait_max)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [quit, keysPressed, timePressed] = ReadKeys(timeStartReading ,duration, nbKeys);
%
% Record keys that have been pressed for a period of time. Reading at keys
% using KbCheck of the Psychtoolbox. (ESC to quit)
%
% INPUT:
%   timeStartReading
%   duration:       duration in sec before exiting (0 = no duration)
%   nbKeys:         number of keysPressed pressed before exiting (0 = unlimited)
%
% OUTPUT:
%   quit:           exited before the end (ESC)? (0: no   1:yes)
%   keysPressed:    vector containing all the keysPressed pressed
%   timePressed:    vector containing the time when the keysPressed were pressed
%
% Vo An Nguyen 2007/04/24
%
% 2008/02/14:   Add "previous" input parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 6, wait_max = 3600; end % Check if a subject keeps pressing button
if nargin < 5, accept_ttl = 0; end % If we need the 5 to answer question
if duration == 0, duration = 3600; end % Duration of ReadKey
if nbKeys == 0 
    nbKeys = 3600; 
end
last_event = timeStartReading;
quit = 0;
keysPressed = [];
timePressed = [];

    index = 1;
    KeysWereDown = ones(1,256);
    
    while (index <= nbKeys) && ...
        (GetSecs-timeStartReading < duration) && ...
        (quit == 0) && ...
        (wait_max > GetSecs - last_event)

        [keyIsDown, secs, keyCode] = KbCheck(-1);

        KeysPressed  = (keyCode==1) & (KeysWereDown==0);

        if ~isempty(find(KeysPressed))
            strDecoded = ld_convertKeyCode(keyCode, currentKeyboard);
            if contains(strDecoded, 'ESC') || contains(strDecoded, 'esc') || contains(strDecoded, 'Escape') % ESC6
                quit=1;
            elseif ~isempty(strfind(strDecoded, '5')) && ~accept_ttl
                 % Do not record (TTL)
            elseif ~isempty(strfind(strDecoded, 'F'))
                 % Do not record (F)
            else
                tmpKeys = find(KeysPressed);
                for i=1:length(tmpKeys)
                    timePressed(index) = secs;
                    keysPressed(index) = tmpKeys(i);
                    index = index + 1 ;
                end
                last_event = secs;
            end
        end
        KeysWereDown = keyCode;
    end
end
