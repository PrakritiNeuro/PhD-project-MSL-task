function [quit, ttlKeyPressed, key2readPressed] = ld_keysWait4ttl(keys2read)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [quit, ttlKeyPressed] = ld_keysWait4ttl()
% [quit, ttlKeyPressed] = ld_keysWait4ttl(keys2read)
%
% Wait for a key to present the stimulus (e.g., play the sound) or the TTL
% key (sent from the scanner or pressed by the experimenter) to initiate
% the task
%   TTL key = 5
%   ESC to exit
%
% INPUT
%   keys2read       cell array with keys to read; other keys are ignored
%
% OUTPUT:
%   quit            exit before the end (esc)? (0: no; 1:yes)
%   ttlKeyPressed   1 - TTL key was pressed, 0 - otherwise
%   keyName         cell array with key names that were pressed      
%
% Ella Gabitov 13 October 2022
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 1, keys2read = []; end

quit = 0;
ttlKeyPressed = 0;
key2readPressed = 0;

while ~quit && ~ttlKeyPressed && ~key2readPressed
    [~, keyCode, ~] = KbPressWait([]);
    keyName = KbName(keyCode);
    if ~isempty(keyName)
        if ~iscell(keyName), keyName = {keyName}; end
        quit = any(contains(lower(keyName), 'esc'));
        ttlKeyPressed = any(contains(keyName, '5'));
        if ~isempty(keys2read)
            key2readPressed = any(contains(lower(keyName), lower(keys2read)));
        end
    end
end

end
