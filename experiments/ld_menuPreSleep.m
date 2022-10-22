function ld_menuPreSleep(exp_phase, param_fpath)
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
                       'Sound Volume Adjustment',...
                       'Introduction - Key-Finger Mapping',...
                       'Introduction - Sequences', ...
                       'Introduction - Sound-Hand-Sequence',...
                       'Training - Phase 1', ...
                       'Training - Phase 2', ...
                       'Training - Phase 3', ...
                       'Test', ...
                       'Quit'...
                       );

        switch choice
            case 1
                ld_adjustVolume(param_fpath, exp_phase, 'soundVolAdjustment');
            case 2
                ld_introFingerMapping(param_fpath, exp_phase, 'introFingerMapping');
            case 3
                ld_introHandSeq(param_fpath, exp_phase, 'introHandSeq');
            case 4
                ld_introSoundHandSeq(param_fpath, exp_phase, 'introSoundHandSeq');
            case 5
                ld_mslTraining(param_fpath, exp_phase, 'trainingPhase', 1);
            case 6
                ld_mslTraining(param_fpath, exp_phase, 'trainingPhase', 2);
            case 7
                ld_mslTraining(param_fpath, exp_phase, 'trainingPhase', 3);
            case 8 
                ld_mslTraining(param_fpath, 'test', 0, true);
            case 9
                break;
        end
    end
