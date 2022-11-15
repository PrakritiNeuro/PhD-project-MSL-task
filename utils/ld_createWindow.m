function [window, windowSize, screenCenter] = ld_createWindow(param)
% [window, screenResolution, screenCenter] = ld_createWindow(param)
%
% INPUT:
%   param           a structure with the number of window & screen parameters
%
% OUTPUT:
%   window
%   screenSize      a vector with the screen width and height, in pixels
%   screenCenter    a vector with the xCenter and yCenter
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'SuppressAllWarnings', 1);

% If you use two monitors
if param.twoMonitors 
    if max(Screen('Screens')) == 2
        whichScreen = 2;
    else
        whichScreen = 0;
        param.twoMonitors = 0; % Set twoMonitors to be false (1 monitor only)
    end
else
    screens = Screen('Screens');
    whichScreen = screens(1);
end

% disp(['whichScreen: ', num2str(whichScreen)]);

% Set the size of the display window
[width, height]=Screen('WindowSize', whichScreen);
if param.fullScreen
    windowRect = [];
else
    windowRect = [0, 0, width*0.6, height*0.6];
end

% Define black, white & gray
black = BlackIndex(whichScreen);
% white = WhiteIndex(whichScreen);
% grey = white / 2;

% Vertical flip of the screen if requested & open the window
if param.flipScreen
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask','AllViews','FlipHorizontal');
end

% Open window
[window, windowRect] = PsychImaging('OpenWindow', whichScreen, black, windowRect);
HideCursor;

% Set the blend funciton for the screen
Screen('BlendFunction',window,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA');

% Initial screen flip
Screen('Flip', window);

% Get the size of the on-screen window, in pixels
windowSize = [windowRect(3) - windowRect(1), windowRect(4) - windowRect(2)];

% Get the center coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);
screenCenter = [xCenter, yCenter];

end