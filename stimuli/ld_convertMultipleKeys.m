function [keys_as_sequence_element, ...
    keys_source_keyboard_value] = ...
    ld_convertMultipleKeys(keys_source_keyboard_value, ...
    currentKeyboard, ...
    keyboard_key_to_task_element)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Map keys code according to the task mapping
% MRI compatible keyboard 
% 
%
%
%
%
%

for nbKeys = 1:length(keys_source_keyboard_value)
    strDecoded = ld_convertKeyCode(keys_source_keyboard_value(nbKeys), currentKeyboard);
    keys_source_keyboard_value(nbKeys) = ld_convertOneKey(strDecoded);
end

keys_as_sequence_element = keys_source_keyboard_value;
for nbKeys = 1:length(keys_as_sequence_element)
     try
        keys_as_sequence_element(nbKeys) = keyboard_key_to_task_element(keys_source_keyboard_value(nbKeys));
    catch ME
        switch ME.identifier
            case 'MATLAB:Containers:Map:NoKey'
                keys_as_sequence_element(nbKeys) = 0;
            otherwise
                ME.identifier
                rethrow(ME)
        end
    end
    
end