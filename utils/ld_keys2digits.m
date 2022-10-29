function digits = ld_keys2digits(keys, key2digit_map)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [digits, keys] = ld_keys2digits(keysPressed, key2digit_map)
% Converts input keys to digits, if possible
%   if the key is not in the key2digit_map, then the conversion is not
%   possible; in that case the value is NaN
%   Assumption: All keys are represented by their first character
%
% INPUT
%   keys            cell array with keys to convert
%   key2digit_map   a map to convert keys to digits
%
% OUTPUT:
%   digits      a vector of digits (1 to 4); if the key is not in the
%               key2digit_map, then the conversion is not possible; in that
%               case the value is NaN
%
% Ella Gabitov October 2022
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

digits = nan(1, numel(keys));
for i_key = 1:numel(keys)
    keyPressed = keys{i_key}(1);
    if key2digit_map.isKey(keyPressed)
        digits(i_key) = str2double(key2digit_map(keyPressed));
    end
end


end
