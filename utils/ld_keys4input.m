function [keyCodes4input, keyNames4input] = ld_keys4input(param, hand_desc)
%[keyCodes4input, keyNames4input] = ld_getKeys4input(param)
% Returns keycodes of keys that are accepted as valid input
%   
% INPUT
%   param               structure with parameters for the experiment
%   hand_desc           string that indicates the hand: 'left' or 'right'
%                       if not given, keys of both hands are considered.
%                       'ESC' and TTL key are also included.
%
% OUTPUT
%   keyCodes4input      vector with valid keycodes for input
%   keyNames4input      vector with valid keynames for input

%
% Ella Gabitov October 2022
%

if nargin < 2, hand_desc = []; end

keyNames = KbName('keyNames');
keyCodes4input = [];

% Add escape key to exit
keyCodes4input = [keyCodes4input, find(strncmpi(keyNames, 'esc', 3))];
% Add TTL key to start the task
keyCodes4input = [keyCodes4input, find(strncmpi(keyNames, '5', 1))];

keys = {};
% Get keys for the specified hand
if ~isempty(hand_desc)
    i_hand = find(strcmp({param.hands.desc}, hand_desc));
    keys = param.hands(i_hand).keys;

% Get keys for both hands
else
    keys = [keys, param.hands.keys];    
end

for i_key = 1:numel(keys)
    if isletter(keys{i_key})
        keyCodes4input = [keyCodes4input, find(strcmpi(keyNames, keys{i_key}))];
    else
        keyCodes4input = [keyCodes4input, find(strncmpi(keyNames, keys{i_key}, 1))];
    end
end

keyNames4input = keyNames(keyCodes4input);

end
