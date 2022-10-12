function strDecoded = ld_convertKeyCode(keyCode, currentKeyboard)
%
%
%
%
%
%

strDecoded = '';

if length(keyCode)>1
    keyCode = find(keyCode);
end

if length(keyCode) > 1
    for nKey=1:length(keyCode)
        strDecoded = strcat(strDecoded, currentKeyboard(keyCode(nKey)));
    end
elseif isempty(keyCode)
    return
else
    strDecoded = currentKeyboard(keyCode);
end

strDecoded = strDecoded{1};