function [window, screenResolution] = createWindow(param)
    % % ---------- Window Setup ----------
    % % Opens a window.
    % 
    % % Screen is able to do a lot of configuration and performance checks on
    % % open, and will print out a fair amount of detailed information when
    % % it does.  These commands supress that checking behavior.
    % Disable error message be carreful    
    %Screen('Preference', 'SkipSyncTests', 1);
    %Screen('Preference', 'SkipSyncTests', 1);
    Screen('Preference', 'VisualDebugLevel', 3);
    Screen('Preference', 'SuppressAllWarnings', 1);
    % 
    % % Find out how many screens and use largest screen number.

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % If you use two monitors
    if param.numMonitor == 1 && max(Screen('Screens')) == 2
        whichScreen = 2;
    else
        whichScreen = 0;
        param.numMonitor = 0; % Set numMonitor back to 0 (1 monitor)
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
    HideCursor;
    % 
    % % Opens a graphics window on the main monitor (screen 0).  If you have
    % % multiple monitors connected to your computer, then you can specify
    % % a different monitor by supplying a different number in the second
    % % argument to OpenWindow, e.g. Screen('OpenWindow', 2).
    Screen('Preference', 'SkipSyncTests', whichScreen);
    Screen('Preference', 'SkipSyncTests', 1);
    
    if param.fullscreen == 1
        resolution = [];
    else
        resolution = [0 0 680 480];
    end
    
    %%%%%% Vertical flip of the screen
    if param.flipMonitor == 1
        PsychImaging('PrepareConfiguration');
        PsychImaging('AddTask','AllViews','FlipHorizontal');
        window = PsychImaging('OpenWindow', whichScreen, [], resolution);
    else
        window = Screen('OpenWindow', whichScreen, [], resolution); % full size window
    end
    %%%%%%
    Screen('FillRect', window, BlackIndex(window));

    screenResolution = Screen('Resolution', whichScreen);
    width = screenResolution.width;
    height = screenResolution.height;
    screenResolution = [width, height];

end