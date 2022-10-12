function ld_menuPostSleep(param)
%MENU_D_ONE Summary of this function goes here
%   Detailed explanation goes here
%
%
% Vo An Nguyen 2010/10/07
% Arnaud Bore 2012/10/05, CRIUGM - arnaud.bore@gmail.com
% Arnaud Bore 2014/10/31 
% EG March 9, 2015     
% Arnaud Bore 2016/06/02
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global D_EXPERIMENT;
    nextMenu = 1;
    
    while nextMenu
        choice = menu(...
                       strcat('Menu - ', D_EXPERIMENT),...
                       'Finger Mapping',...
                       'Sequence Familiarization', ...
                       'Sound-Hand-Sequence Association',...
                       'Test', ...
                       'Quit'...
                       );
        sessionName = D_EXPERIMENT;  % 'PostSleep'

        switch choice
            case 1
                param.task = ['Finger Mapping - ', sessionName];
                ld_verification(param);
            case 2
                param.task = ['Sequence Familiarization - ', sessionName];
                ld_intro(param);
            case 3
                param.task = ['Sound-Hand-Sequence Association - ', sessionName];
                ld_sound_sequence_association(param);
            case 4
                param.task = ['Test - ', sessionName];
                ld_mslTraining(param, 0, true);
            case 5
                break;
        end
    end
