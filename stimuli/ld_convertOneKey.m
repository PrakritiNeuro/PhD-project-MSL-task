function key = ld_convertOneKey(strDecoded)
%
%
%
%
%
%

key = 6;

if ~isempty(strfind(strDecoded, '1'))
    key = 1;
elseif ~isempty(strfind(strDecoded, '2'))
    key = 2;
elseif ~isempty(strfind(strDecoded, '3'))
    key = 3;
elseif ~isempty(strfind(strDecoded, '4'))
    key = 4;
elseif ~isempty(strfind(strDecoded, '7'))
    key = 7;
elseif ~isempty(strfind(strDecoded, '8'))
    key = 8;
elseif ~isempty(strfind(strDecoded, '9'))
    key = 9;
elseif ~isempty(strfind(strDecoded, '0'))
    key = 0;
end