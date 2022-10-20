function ld_menuPreSleep(exp_phase, param)
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

        param.exp_phase = exp_phase;
        switch choice
            case 1
                param.task = 'soundVolAdjustment';
                ld_adjustVolume(param);
            case 2
                param.task = 'introFingerMapping';
                ld_introFingerMapping(param);
            case 3
                param.task = 'introSeq';
                ld_introSeq(param);
            case 4
                param.task = 'introSoundHandSeq';
                ld_introSoundHandSeq(param);
            case 5
                param.task = 'trainingPhase1';
                ld_mslTraining(param, 1);
            case 6
                param.task = 'trainingPhase2';
                ld_mslTraining(param, 2);
            case 7
                param.task = 'trainingPhase3';
                ld_mslTraining(param, 3);
            case 8 
                param.task = 'test';
                ld_mslTraining(param, 0, true);
            case 9
                break;
        end
    end
