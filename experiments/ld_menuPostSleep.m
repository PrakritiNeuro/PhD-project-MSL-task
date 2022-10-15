function ld_menuPostSleep(exp_phase, param)
%MENU_D_ONE Summary of this function goes here
%   Detailed explanation goes here
%
%
% Vo An Nguyen 2010/10/07
% Arnaud Bore 2012/10/05, CRIUGM - arnaud.bore@gmail.com
% Arnaud Bore 2014/10/31 
% Ella Gabitov, March 9, 2015     
% Arnaud Bore 2016/06/02
% Ella Gabitov, October 2022
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    nextMenu = 1;
    
    while nextMenu
        choice = menu(...
                       strcat('Menu - ', exp_phase),...
                       'Introduction - Finger Mapping',...
                       'Introduction - Sequences', ...
                       'Introduction - Sound-Hand-Sequence',...
                       'Test', ...
                       'Quit'...
                       );

        switch choice
            case 1
                param.task = [exp_phase, '_introFingerMapping'];
                ld_introFingerMapping(param);
            case 2
                param.task = [exp_phase, '_introSeq'];
                ld_introSeq(param);
            case 3
                param.task = [exp_phase, '_introSoundHandSeq'];
                ld_introSoundHandSeq(param);
            case 4
                param.task = [exp_phase, '_test'];
                ld_mslTraining(param, 0, true);
            case 5
                break;
        end
    end
