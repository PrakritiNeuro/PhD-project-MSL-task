function clocke_EN_arch(Ss_name,nbr) 
% *******************************
% PVT for psychotoolbox v3
% syntax: clocke(Ss_name,age,condition,nbr) 
% nbr = number of trials 
% Arnaud Boré : arnaud.bore@gmail.com
% *******************************
 if nargin == 0 ; nbr = 5; end

% INIT
% CREATION OF THE WINDOW
window = createWindow();

% Display instruction message
Screen('TextFont',window,'Arial');
Screen('TextSize',window, 40 );
gold = [255,215,0,255];

% LOG FILE
logfile = (['PVT' Ss_name '.mat']);

DrawFormattedText(window,'Veuillez appuyer sur une touche','center',100,gold);
DrawFormattedText(window,'dès que le compteur apparait.','center',200,gold);
DrawFormattedText(window,'Appuyez sur une touche pour commencer','center',300,gold);
Screen('Flip', window);

pause(0.1);
[keyIsDown,secs,keyCode] = KbCheck;
while isempty(find(keyCode))
    [keyIsDown,secs,keyCode] = KbCheck;
end

results.res = [];
results.hdr = Ss_name;

for ei = 1:nbr
    Screen('TextSize',window, 100 );
    
    DrawFormattedText(window,'+','center','center',gold);
    Screen('Flip', window);
    
%     Random waiting time
    pause(1+rand*8);
    
    DrawFormattedText(window,'+','center','center',[0,0,0,0]);
    Screen('Flip', window);
    t0 = GetSecs;
    for i = 1:1000
        DrawFormattedText(window,num2str(1000-i),'center','center',gold);
        Screen('Flip', window);

        [keyIsDown,secs,keyCode] = KbCheck;
		if ~isempty(find(keyCode)); break;end;
    end

    DrawFormattedText(window,['TR = ' num2str((secs-t0)*1000) ' ms'],'center','center',gold);
    results.res(ei) = (secs-t0)*1000;
    Screen('Flip', window);
    pause(1)
end
DrawFormattedText(window,'Merci','center','center',gold);
Screen('Flip', window);
pause(3);
Screen('CloseAll');

% cgtext('merci',0,0); cgflip(0,0,0);
% wait(2000);
moyenne_des_TR = mean(results.res(:))
save(logfile, 'results');   
end

