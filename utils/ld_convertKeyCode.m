function keyName = ld_convertKeyCode(keyCode, currentKeyboard)
%
%
%
%
%
%

keyName = '';

if length(keyCode)>1
    keyCode = find(keyCode);
end

if length(keyCode) > 1
    for nKey=1:length(keyCode)
        keyName = strcat(keyName, currentKeyboard(keyCode(nKey)));
    end
elseif isempty(keyCode)
    return
else
    keyName = currentKeyboard(keyCode);
end

keyName = keyName{1};