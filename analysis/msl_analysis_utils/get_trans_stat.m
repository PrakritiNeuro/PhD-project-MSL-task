function [perf_duration,...
            all_trans,...
            correct_trans,...
            incorrect_trans,...
            seq_trans,...
            btwn_seq_trans,...
            error_trans,...
            btwn_error_trans...
            ]...
            = get_trans_stat(keys, onsets, sequence, n_start_trial, n_sd)

% INPUT
%   keys                        A vector of keys
%   onsets                      A vector of key onsets, i.e., the time that the key was presssed
%   sequence      [integer]     A vector of numbers representing the sequence
%   n_start_trial [integer]     The number of the first keys of the sequence to search for a trial; the default value is 2 keys
%   n_sd          [double]      The number of standard deviations to identify outliers
% 
% OUTPUT
%   perf_duration  	[integer]    time between the first and the last keypress
%   all_trans                    
%   correct_trans  	            Transitions to any correct key from any (correct or incorrect) preceding keypress.
%                               Correct key is any key within the compete sequence or correctly initiated but incomplete sequence
%
%   incorrect_trans 	        Tranistions between two incorrect keys
%   seq_trans      	            Within-sequence transitions only
%   btwn_seq_trans 	            Between-sequence transitions; transitions from the
%                               Sequence to the next unsuccessful attemt to perform the sequence are also considered
%   btwn_error_trans            Within-error transitions only
%   error_trans                 Between-error transitions; transitions from the error to the following sequence are also considered
% 
%   for each <...>_trans structure the following fields are calculated:  
%       .n_trans        [integer]
%       .n_trans_out    [integer]   # of outliers
%       .trans_mean 	[double]    mean transition duration
%       .trans_sd 	    [double]
%       .trans_min	    [double]
%       .trans_max	    [double]
%
% Ella Gabitov, 14 July, 2020

if numel(keys) ~= numel(onsets)
    error('The number of keys and the number of onsets do not match.');
end

if nargin < 4, n_start_trial = 2; end
if isempty(n_start_trial) || isnan(n_start_trial) || n_start_trial == 0, n_start_trial = 2; end

if nargin < 5, n_sd = 0; end
if isempty(n_start_trial), n_sd = 0; end

perf_duration = onsets(end) - onsets(1);

%% ALL KEYS

transition_durations = diff(onsets);

% remove outliers
if ~isempty(transition_durations) && ...
        ~isempty(n_sd) && n_sd > 0
    [~,~, data_no_outliers, ~, n_outliers] = f_remove_outliers(transition_durations, n_sd); 
else
    data_no_outliers	= transition_durations;
    n_outliers          = 0;
end 

all_trans.n_trans     	= numel(transition_durations);
all_trans.n_trans_out	= n_outliers;
if ~isempty(data_no_outliers)
    all_trans.trans_mean	= nanmean(data_no_outliers); 	% mean transition duration
    all_trans.trans_sd   	= nanstd(data_no_outliers);  	% sd for transition durations
    all_trans.trans_min   	= nanmin(data_no_outliers);  	% min for transition durations
    all_trans.trans_max     = nanmax(data_no_outliers);  	% max for transition durations
else
    all_trans.trans_mean	= NaN;	% mean transition duration
    all_trans.trans_sd   	= NaN;	% sd for transition durations
    all_trans.trans_min   	= NaN;	% min for transition durations
    all_trans.trans_max     = NaN;	% max for transition durations
end

%% CORRECT & INCORRECT KEYS

iscorrect_keys                  = get_keys_info(keys, sequence, n_start_trial);
correct_transition_durations    = [];
incoorect_transition_durations  = [];
for i_trans = 1 : numel(iscorrect_keys)-1
    % any transition to the correct key is correct one
    if iscorrect_keys(i_trans+1)
        correct_transition_durations    = [correct_transition_durations onsets(i_trans+1) - onsets(i_trans)];
    else
        incoorect_transition_durations  = [incoorect_transition_durations onsets(i_trans+1) - onsets(i_trans)];
    end
end

% remove outliers
if ~isempty(correct_transition_durations) && ...
        ~isempty(n_sd) && n_sd > 0
    [~,~, data_no_outliers, ~, n_outliers] = f_remove_outliers(correct_transition_durations, n_sd); 
else
    data_no_outliers = correct_transition_durations;
    n_outliers = 0;
end 
correct_trans.n_trans   	= numel(correct_transition_durations);
correct_trans.n_trans_out 	= n_outliers;
if ~isempty(data_no_outliers)
    correct_trans.trans_mean	= nanmean(data_no_outliers); 	% mean transition duration
    correct_trans.trans_sd   	= nanstd(data_no_outliers);  	% sd for transition durations
    correct_trans.trans_min   	= nanmin(data_no_outliers);  	% min for transition durations
    correct_trans.trans_max     = nanmax(data_no_outliers);  	% max for transition durations
else
    correct_trans.trans_mean	= NaN;	% mean transition duration
    correct_trans.trans_sd   	= NaN;	% sd for transition durations
    correct_trans.trans_min   	= NaN;	% min for transition durations
    correct_trans.trans_max     = NaN;	% max for transition durations
end

% remove outliers
if ~isempty(incoorect_transition_durations) && ...
        ~isempty(n_sd) && n_sd > 0
    [~,~, data_no_outliers, ~, n_outliers] = f_remove_outliers(incoorect_transition_durations, n_sd); 
else
    data_no_outliers	= incoorect_transition_durations;
    n_outliers          = 0;
end
data_no_outliers = data_no_outliers';

incorrect_trans.n_trans    	= numel(incoorect_transition_durations);
incorrect_trans.n_trans_out	= n_outliers;
if ~isempty(data_no_outliers)
    incorrect_trans.trans_mean	= nanmean(data_no_outliers); 	% mean transition duration
    incorrect_trans.trans_sd   	= nanstd(data_no_outliers);  	% sd for transition durations
    incorrect_trans.trans_min  	= nanmin(data_no_outliers);  	% min for transition durations
    incorrect_trans.trans_max  	= nanmax(data_no_outliers);  	% max for transition durations
else
    incorrect_trans.trans_mean	= NaN;	% mean transition duration
    incorrect_trans.trans_sd   	= NaN;	% sd for transition durations
    incorrect_trans.trans_min  	= NaN;	% min for transition durations
    incorrect_trans.trans_max  	= NaN;	% max for transition durations
end

%% SEQUENCE & ERROR KEYS

trials = get_trials_info(keys, sequence, n_start_trial);
% trials{i}.type
% trials{i}.i_start
% trials{i}.i_end

trials{end+1}.type = 'end';  % add one extra trial at the end;

seq_trans_durations         = [];
btwn_seq_trans_durations    = [];

error_trans_durations       = [];
btwn_error_trans_durations 	= [];


for i_trial = 1 : numel(trials)-1
    
    is_seq      = 0;
    is_err      = 0;
    trial_tmp	= trials{i_trial};
    
    switch trial_tmp.type
        
%         case 'head'
%             check_btwn_seq = 1;
            
        case 'sequence'
            is_seq      = 1;
            onsets_tmp	= onsets(trial_tmp.i_start:trial_tmp.i_end);
            for i_trans = 1 : numel(onsets_tmp)-1
                seq_trans_durations = [seq_trans_durations onsets_tmp(i_trans+1) - onsets_tmp(i_trans)];
            end
            
        case 'error'
            is_err      = 1;
            onsets_tmp	= onsets(trial_tmp.i_start:trial_tmp.i_end);
            for i_trans = 1 : numel(onsets_tmp)-1
                error_trans_durations = [error_trans_durations onsets_tmp(i_trans+1) - onsets_tmp(i_trans)];
            end
                        
    end % SWITCH
    
    if is_seq
        trial_next = trials{i_trial+1};
        if ~strcmp(trial_next.type, 'end')
            next_keys_tmp = keys(trial_next.i_start : trial_next.i_end);
            
            % between sequences transition; transntions between a sequence and part of a sequence are also included
            if numel(next_keys_tmp) >= n_start_trial && ...
                    contains(next_keys_tmp(1:n_start_trial), sequence(1:n_start_trial))
                btwn_seq_trans_durations = [btwn_seq_trans_durations onsets(trial_next.i_start) - onsets(trial_tmp.i_end)];
            
            % transition between a sequence and an error
            else
                btwn_error_trans_durations = [btwn_error_trans_durations onsets(trial_next.i_start) - onsets(trial_tmp.i_end)];
            end
        end

    end % IF check for transition betweeen sequences
    
    if is_err
        trial_next = trials{i_trial+1};
        if ~strcmp(trial_next.type, 'end')
            btwn_error_trans_durations = [btwn_error_trans_durations onsets(trial_next.i_start) - onsets(trial_tmp.i_end)];
        end
    end
    
end % FOR each trial

trans_info = [];
trans_info{end+1} = all_trans;
trans_info{end+1} = correct_trans;
trans_info{end+1} = incorrect_trans;

% remove outliers

trans_durations = [];
trans_durations{end+1} = seq_trans_durations;
trans_durations{end+1} = btwn_seq_trans_durations;
trans_durations{end+1} = error_trans_durations;
trans_durations{end+1} = btwn_error_trans_durations;

for i_trans = 1 : numel(trans_durations)

    if ~isempty(trans_durations{i_trans}) && ...
            ~isempty(n_sd) && n_sd > 0
        [~,~, data_no_outliers, ~, n_outliers] = f_remove_outliers(trans_durations{i_trans}, n_sd); 
    else
        data_no_outliers    = trans_durations{i_trans};
        n_outliers          = 0;
    end

    trans_info{end+1}.n_trans  	= numel(trans_durations{i_trans});
    trans_info{end}.n_trans_out	= n_outliers;
    if ~isempty(data_no_outliers)
        trans_info{end}.trans_mean	= nanmean(data_no_outliers); 	% mean transition duration
        trans_info{end}.trans_sd 	= nanstd(data_no_outliers);   	% sd for transition durations
        trans_info{end}.trans_min	= nanmin(data_no_outliers);  	% min of transition durations
        trans_info{end}.trans_max  	= nanmax(data_no_outliers);  	% max of transition durations
    else
        trans_info{end}.trans_mean	= NaN; 	% mean transition duration
        trans_info{end}.trans_sd 	= NaN;	% sd for transition durations
        trans_info{end}.trans_min	= NaN;	% min of transition durations
        trans_info{end}.trans_max  	= NaN;	% max of transition durations
    end
end

%% SET NaN IF EMPTY

field_desc_arr = {'trans_mean', 'trans_sd', 'trans_min', 'trans_max'};
for trans_info_i=1:numel(trans_info)
    for field_i = 1 : numel(field_desc_arr)
        field_desc = field_desc_arr{field_i};
        if isempty(trans_info{trans_info_i}.(field_desc))
            trans_info{trans_info_i}.(field_desc) = NaN;
        end
    end
end

% set the updated key_info to the returned variables
% --------------------------------------------------
trans_info_i = 0;

trans_info_i        = trans_info_i + 1;
all_trans           = trans_info{trans_info_i};

trans_info_i        = trans_info_i + 1;
correct_trans       = trans_info{trans_info_i};

trans_info_i        = trans_info_i + 1;
incorrect_trans     = trans_info{trans_info_i};

trans_info_i        = trans_info_i + 1;
seq_trans           = trans_info{trans_info_i};

trans_info_i        = trans_info_i + 1;
btwn_seq_trans      = trans_info{trans_info_i};

trans_info_i        = trans_info_i + 1;
error_trans         = trans_info{trans_info_i};

trans_info_i        = trans_info_i + 1;
btwn_error_trans	= trans_info{trans_info_i};

end

