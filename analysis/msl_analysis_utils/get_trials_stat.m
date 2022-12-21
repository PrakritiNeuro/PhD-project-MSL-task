function [perf_duration,...
            n_keys,...
            sequences,...
            btwn_seq,...
            errors...
            ]...
            = get_trials_stat(keys, onsets, sequence, n_start_trial, n_sd)

% keys that are part a sequence at the very beginning or the very end of the block (head and tail, respectively) are not considered
% all trial durations are calculated considering only within-trial transtions
% 
% INPUT
%     keys                      a vector of keys
%     onsets                    a vector of key onsets, i.e., the time that the key was presssed
%     sequence      [integer]   a vector of numbers representing the sequence
%     n_start_trial [integer]   the number of the first keys of the sequence to search for a trial; the default value is 2 keys
%     n_sd          [integer]   the number of standard deviation; is used to exclude outliers

% OUTPUT
%     perf_duration  	[integer]    time between the first and the last presses key 
%     n_keys            [integer]
%     
%     sequences     
%       ...durations    [double]    vector of duraitons for each sequence
%       ....n           [integer]
%       ....n_out       [integer]   number of outliers
%       ....mean        [double]    transitions before or between sequences are not considered
%       ....sd          [double]    sd for sequences
%     
%     btwn_seq     
%       ...durations    [double]    vector of duraitons for each between-sequence transition
%       ....n           [integer]
%       ....n_out       [integer]   number of outliers
%       ....mean        [double]    only transitions between sequences or attempt to perform a sequence; such attempt is identified by the <n_start_trial> first keys of the sequence
%       ....sd          [double]
%     
%     errors
%       ...durations    [double]    vector of duraitons for each error
%       ....lengths     [integer]   vector with the number of keys for each error
%       ....n           [integer]
%       ....mean        [double]    transitions before or between errors are not considered
%       ....sd          [double]


% Ella Gabitov, 14 July, 2020

if numel(keys) ~= numel(onsets)
    error('The number of keys and the number of onsets do not match.');
end

if nargin < 4, n_start_trial = 2; end
if isempty(n_start_trial) || isnan(n_start_trial) || n_start_trial == 0, n_start_trial = 2; end

if nargin < 5, n_sd = 0; end
if isempty(n_start_trial), n_sd = 0; end

perf_duration = onsets(end) - onsets(1);
n_keys = numel(keys);

trials = get_trials_info(keys, sequence, n_start_trial);
% trials{i}.type
% trials{i}.i_start
% trials{i}.i_end

trials{end+1}.type  = 'end';  % add one extra trial at the end;

sequence_durations	= [];
btwn_seq_durations  = [];
error_durations     = [];
error_lengths       = [];

for i_trial = 1 : numel(trials)-1
    
    check_btwn_seq	= 0;
    trial_tmp       = trials{i_trial};
    
    switch trial_tmp.type
        
%         case 'head'
%             check_btwn_seq = 1;
            
        case 'sequence'
            check_btwn_seq      = 1;
            dur_tmp             = onsets(trial_tmp.i_end) - onsets(trial_tmp.i_start);
            sequence_durations  = [sequence_durations dur_tmp];
            
        case 'error'
            dur_tmp         = onsets(trial_tmp.i_end) - onsets(trial_tmp.i_start);
            error_durations = [error_durations dur_tmp];
            length_tmp      = trial_tmp.i_end - trial_tmp.i_start + 1;             
            error_lengths   = [error_lengths length_tmp];

                        
    end % SWITCH
    
    % transition between sequences  or attempt to perform a sequence
    if check_btwn_seq
        
        trial_next = trials{i_trial+1};
        if ~strcmp(trial_next.type, 'end')
            next_keys_tmp = keys(trial_next.i_start : trial_next.i_end);
            
            if numel(next_keys_tmp) >= n_start_trial && ...
                    contains(next_keys_tmp(1:n_start_trial), sequence(1:n_start_trial))
                dur_tmp             = onsets(trial_next.i_start) - onsets(trial_tmp.i_end);
                btwn_seq_durations  = [btwn_seq_durations dur_tmp];
            end
            
        end

    end % IF check for transition betweeen sequences
    
end % FOR each trial

% remove outliers
if ~isempty(sequence_durations) && ...
        ~isempty(n_sd) && n_sd > 0
    [~,~, data_no_outliers, ~, n_outliers] = f_remove_outliers(sequence_durations, n_sd); 
else
    data_no_outliers	= sequence_durations;
    n_outliers          = 0;
end
sequences.durations	= sequence_durations;
sequences.n         = numel(sequence_durations);	% # of sequences
sequences.n_out     = n_outliers; 
sequences.mean      = nanmean(data_no_outliers); 	% mean sequence duration
sequences.sd        = nanstd(data_no_outliers);   	% sd for sequences

errors.durations    = error_durations;
errors.lengths      = error_lengths;
errors.n            = numel(error_durations);  	% # of errors
errors.mean         = nanmean(error_durations);	% mean error duration
errors.sd           = nanstd(error_durations); 	% sd for errors

% remove outliers
if ~isempty(btwn_seq_durations) && ...
        ~isempty(n_sd) && n_sd > 0
    [~,~, data_no_outliers, ~, n_outliers] = f_remove_outliers(btwn_seq_durations, n_sd); 
else
    data_no_outliers = btwn_seq_durations;
    n_outliers = 0;
end
btwn_seq.durations  = btwn_seq_durations;
btwn_seq.n          = numel(btwn_seq_durations); 	% # of btwn_seq transitions
btwn_seq.n_out      = n_outliers; 
btwn_seq.mean       = nanmean(data_no_outliers); 	% mean btwn_seq duration
btwn_seq.sd         = nanstd(data_no_outliers);  	% sd for btwn_seq transitions

end
































