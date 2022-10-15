function [quit, timePressed] = wait4ttl()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [quit, timePressed] = wait4ttl()
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
%   timePressed     vector containing the time when the keys were pressed
%
%
% Ella Gabitov 13 October 2022
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[~, timePressed, keyCode, ~] = KbCheck(-3);
keyName = KbName(keyCode);
quit = any(contains(lower(keyName), 'esc'));

while ~quit && ~any(contains(keyName, '5'))
    [~, timePressed, keyCode, ~] = KbCheck(-3);
    keyName = KbName(keyCode);
    quit = any(contains(lower(keyName), 'esc'));
end

end
