function [quit, ttlKeyPressed] = ld_keys_wait4ttl()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [quit, ttlKeyPressed] = ld_keys_wait4ttl()
%
% Wait for the TTL or for the experimenter to initiate the task
%   TTL key = 5
%   ESC to exit
%
% INPUT:
%   currentKeyboard
%
% OUTPUT:
%   quit            exit before the end (esc)? (0: no; 1:yes)
%   ttlKeyPressed   1 - TTL key was pressed, 0 - otherwise
%
% Ella Gabitov 13 October 2022
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

quit = 0;
ttlKeyPressed = 0;
while ~quit && ~ttlKeyPressed
    % read keys, only one key at a time
    [~, keyCode, ~] = KbPressWait(-3);
    keyName = KbName(keyCode);
    if ~isempty(keyName)
        if ~iscell(keyName), keyName = {keyName}; end
        quit = any(contains(lower(keyName), 'esc'));
        ttlKeyPressed = any(contains(keyName, '5'));
    end
end

end
