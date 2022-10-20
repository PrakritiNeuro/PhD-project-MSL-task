function [quit, timePressed] = keys_wait4ttl()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [quit, timePressed] = keys_wait4ttl()
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

quit = 0;
start_task = 0;
while ~quit && ~start_task
    [~, timePressed, keyCode, ~] = KbCheck(-3);
    keyName = KbName(keyCode);
    quit = any(contains(lower(keyName), 'esc'));
    start_task = any(contains(keyName, '5'));
end

end
