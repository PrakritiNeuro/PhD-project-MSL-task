function [draw_rect] = ld_getDrawRect(theTexture,screenSize, rectCenter)
%[draw_rect] = ld_getDrawRect(theTexture,screenSize, rectCenter)
% Set the size of the rectangle for the texture to be drawn. Is calculated
% as 50% of the screen height.
%
% INPUT
%   theTexture
%   screenSize  [width, height] in pixels
%   rectCenter  (x, y) coordinates that determines the location of the
%               rectangle, in pixels, to be drawn on the screen
%
% Ella Gabitov, October 2022
%
[img_width, img_height, ~] = size(theTexture);
img_ratio = img_width/img_height;
img_rect_height = screenSize(2)*0.5; 
img_rect_width = img_rect_height * img_ratio;
img_rect = [0 0 , img_rect_width, img_rect_width];
draw_rect = CenterRectOnPointd(img_rect, ...
    rectCenter(1), rectCenter(2));
end