function [logoriginalFigure,logoriginal_explicit] = stim_display_logoriginal(logoriginal)
%This function plots the entries of logoriginal, output of stim motor task,
%for manual review of the raw data. It also returns logoriginal_explicit, a
%rearranged version of logoriginal much easier to review from the workspace
%
%   On the x-axis is the position of the event in logoriginal, its index.
%   On the y axis is the time stamp of the event, the recorded time when it
%   happened
%   The point shape (dot, triangle, star,...) indicates what is the event

%   Thibault Vlieghe, 2019/06/05, Montreal Neurological institute
%   thibault.vlieghe@mcgill.ca


logoriginal_explicit = cell(length(logoriginal),3);
for i = 1:length(logoriginal)
    logoriginal_explicit{i,1} = logoriginal{i}{1};
    logoriginal_explicit{i,2} = logoriginal{i}{2};
    if length(logoriginal{i}) > 2
        logoriginal_explicit{i,3} = logoriginal{i}{3};
    end
end

key = []; key_x = []; key_time = [];
% Start = []; Start_x = [];
Rest = []; Rest_x = [];
Practice = []; Practice_x = [];

for i = 1:length(logoriginal)
    if strcmp(logoriginal{i}{2}, 'rep')
        key(end+1) = str2double(logoriginal{i}{3});
        key_time(end+1) = str2double(logoriginal{1,i}(1));
        key_x(end+1) = i;
    elseif strcmp(logoriginal{i}{2},'Rest')
        Rest(end+1) = str2double(logoriginal{1,i}(1));
        Rest_x(end+1) = i;
    elseif strcmp(logoriginal{i}{2},'Practice')
        Practice(end+1) = str2double(logoriginal{1,i}(1));
        Practice_x(end+1) = i;
    elseif strcmp(logoriginal{i}{2},'STOP MANUALLY')
        Stop = str2double(logoriginal{1,i}(1))
        Stop_x = i;
    elseif strcmp(logoriginal{i}{2},'CRASH')
        Crash = str2double(logoriginal{1,i}(1))
        Crash_x = i;
    % else % if strcmp(logoriginal{i}{2},'Task') || strcmp(logoriginal{i}{2},'START')
%         Start(end+1) = str2double(logoriginal{1,i}(1));
%         Start_x(end+1) = i;
    end
end

logoriginalFigure = figure;
plot(key_x,key_time,'b.',Rest_x,Rest,'<',Practice_x,Practice,'>')
xlabel('logoriginal entry number')
ylabel('time (s)')
legend('keys','Resting period start','Practice: block start')
% key_x,key_time,'b.',
% logoriginalFigure.Position(3) = logoriginalFigure.Position(3)*1.8; % to
% resize the figure so it's 1.8 wider

% if length(timeStamp)<20;plot_options='b-o';else;plot_options = 'b.';end
% subplot(1,2,1); plot(timeStamp,plot_options)
% subplot(1,2,2); bar(key)