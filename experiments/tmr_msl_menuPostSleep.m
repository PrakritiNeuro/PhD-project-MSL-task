function tmr_msl_menuPostSleep(exp_phase, param)
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
                       upper(strcat('Menu - ', exp_phase)),...
                       'Introduction - Sounds and Volume Adjustment',...
                       'Introduction - Key-Finger Mapping',...
                       'Introduction - Sequences', ...
                       'Introduction - Sound-Hand-Sequence',...
                       'Test', ...
                       'Quit'...
                       );

        param.exp_phase = exp_phase;
        switch choice
            case 1
                tmr_msl_intro1_sounds(param_fpath, exp_phase, 'intro1_sounds');
            case 2
                tmr_msl_intro2_fingersMap(param_fpath, exp_phase, 'intro2_fingersMap');
            case 3
                tmr_msl_intro3_handSeq(param_fpath, exp_phase, 'intro3_handSeq');
            case 4
                tmr_msl_intro4_soundHandSeq(param_fpath, exp_phase, 'intro4_soundHandSeq');
            case 5
                tmr_msl_task(param_fpath, 'test', 0, true);
            case 6
                break;
        end
    end
