function [keyCodes4check, keyNames4check] = ld_getKeys4check(param)
%[keyCodes4check, keyNames4check] = ld_getKeys4check(param)
% Returns keycodes of keys that are accepted as valid input
%   
% INPUT
%   param               structure with parameters for the experiment
%
% OUTPUT
%   keyCodes4check      vector with valid keycodes
%   keyNames4check      vector with valid keynames

%
% Ella Gabitov October 2022
%

keyNames = KbName('keyNames');
keyCodes4check = [];

% Escape key to exit
keyCodes4check = [keyCodes4check, find(strncmpi(keyNames, 'esc', 3))];

% TTL key to start the task
keyCodes4check = [keyCodes4check, find(strncmpi(keyNames, '5', 1))];

% Keys that correspond to fingers involved in the task
for i_hand = 1:2
    keys = param.hands(i_hand).keys;
    for i_key = 1:numel(keys)
        if isletter(keys{i_key})
            keyCodes4check = [keyCodes4check, find(strcmpi(keyNames, keys{i_key}))];
        else
            keyCodes4check = [keyCodes4check, find(strncmpi(keyNames, keys{i_key}, 1))];
        end
    end
end

keyNames4check = keyNames(keyCodes4check);
end