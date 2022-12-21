function [sequences, transitions, transitions_for_each_sequence] = get_sequences_info(keys, onsets, sequence, n_start_trial, n_sd, only_iso_seq)

% keys that are part a sequence at the very beginning or the very end of the block (head and tail, respectively) are not considered
% all vectors are oriented horizontally
% 
% INPUT
% keys                      a vector of keys
% onsets                    a vector of key onsets, i.e., the time that the key was presssed
% sequence      [integer]   a vector of numbers representing the sequence
% n_start_trial [integer]   the number of the first keys of the sequence to search for a trial; the default value is 2 keys
% n_sd          [integer]   the number of standard deviation; is used to exclude outliers
% only_iso_seq  [boolean]   1 - exclude sequences immediately before and after any error; the first sequences at the very beginning of each block are also excluded

% OUTPUT
% sequences     [cell array]
%   ....duration  	[double]    sequence duration; transition between sequences is not considered
%   ....transitions [double]    a vector of duraitons for the 1st, 2nd, 3rd, ... transitions within each sequence and between the sequences
%
% transitions
%   ...n     	[integer]   a vector of the number of the 1st, 2nd, 3rd, ... transitions within a sequence and between the sequences
%   ...n_out  	[integer]	a vector of the number of the outliers for the 1st, 2nd, 3rd, ... transitions within a sequence and between the sequences
%   ...mean  	[double]  	a vector of mean duration of the 1st, 2nd, 3rd, ... transitions within a sequence and between the sequences
%   ...sd   	[double]  	a vector of sd for the 1st, 2nd, 3rd, ... transitions within a sequence and between the sequences
%   ...min  	[double]  	a vector of min duration of the 1st, 2nd, 3rd, ... transitions within a sequence and between the sequences
%   ...max  	[double]  	a vector of max duration of the 1st, 2nd, 3rd, ... transitions within a sequence and between the sequences
%
% transitions_for_each_sequence [double]
%   a matrix with vectors of duration of the 1st, 2nd, 3rd, ... transitions within each sequence and between the sequences
%
% Ella Gabitov, 14 July, 2020

if numel(keys) ~= numel(onsets)
    error('The number of keys and the number of onsets do not match.');
end

if nargin < 4, n_start_trial = 2; end
if isempty(n_start_trial) || isnan(n_start_trial) || n_start_trial == 0, n_start_trial = 2; end

if nargin < 5, n_sd = 0; end
if isempty(n_start_trial), n_sd = 0; end

if nargin < 6, only_iso_seq = 0; end

trials = get_trials_info(keys, sequence, n_start_trial);
% trials{i}.type
% trials{i}.i_start
% trials{i}.i_end

trials{end+1}.type = 'end';  % add one extra trial at the end;

sequences = {};
single_transitions = [];
i_seq = 0;

for i_trial = 1 : numel(trials)-1
    
    transitions_tmp	= NaN(1, numel(sequence));
    trial_tmp       = trials{i_trial};
    
    if strcmp(trial_tmp.type, 'sequence')
        is_seq_of_int = true;
        
        % exclude the very first sequences in the block and sequences juxtaposed to errors
        % --------------------------------------------------------------------------------
        if only_iso_seq
            % the very first sequence in the block
            if i_trial == 1
                is_seq_of_int = false;
            % sequence immediately before the error
            elseif strcmp(trials{i_trial-1}.type, 'error')
                is_seq_of_int = false;
            % sequence immediately after the error
            elseif strcmp(trials{i_trial+1}.type, 'error')
                is_seq_of_int = false;
            end
        end
        
        if is_seq_of_int
            i_seq = i_seq + 1;

            onsets_tmp                  = onsets(trial_tmp.i_start:trial_tmp.i_end);
            sequences{i_seq}.duration   = onsets_tmp(end) - onsets_tmp(1);

            % transitions within the sequence
            % --------------------------------
            for i_trans = 1 : numel(onsets_tmp)-1
                transitions_tmp(i_trans) = onsets_tmp(i_trans+1) - onsets_tmp(i_trans);
            end

            % check for the transition between sequences
            % -------------------------------------------
            trial_next = trials{i_trial+1};
            if ~strcmp(trial_next.type, 'end')
                next_keys_tmp = keys(trial_next.i_start : trial_next.i_end);

                if numel(next_keys_tmp) >= n_start_trial && ...
                        contains(next_keys_tmp(1:n_start_trial), sequence(1:n_start_trial))
                    transitions_tmp(end) = onsets(trial_next.i_start) - onsets(trial_tmp.i_end);
                end

            end

            sequences{i_seq}.transitions = transitions_tmp;
            single_transitions(i_seq, :) = transitions_tmp;
            
        end % IF is sequence of interest
        
    end % IF is a sequence
        
end % FOR each trial

transitions_for_each_sequence   = [];
transitions                     = [];
if isempty(single_transitions)
    transitions.n      	= zeros(numel(sequence), 1);
    transitions.n_out	= zeros(numel(sequence), 1);
    transitions.mean    = nan(numel(sequence), 1);
    transitions.sd      = nan(numel(sequence), 1);
    transitions.min     = nan(numel(sequence), 1);
    transitions.max 	= nan(numel(sequence), 1);
else
    transitions.n = sum(~isnan(single_transitions), 1)';
    % remove outliers
    if ~isempty(n_sd) && n_sd > 0
        [~,~, data_no_outliers, ~, n_outliers] = f_remove_outliers(single_transitions, n_sd); 
    else
        data_no_outliers	= single_transitions;
        n_outliers          = zeros(1, numel(sequence));
    end
    
    transitions_for_each_sequence = data_no_outliers';

    transitions.n_out	= n_outliers';
    transitions.mean    = nanmean(data_no_outliers, 1)';
    % more than one sequence for analysis in the block
    if size(data_no_outliers,1) > 1
        transitions.sd      = nanstd(data_no_outliers)';
        transitions.min     = nanmin(data_no_outliers)';
        transitions.max 	= nanmax(data_no_outliers)';
    % only one sequence for analysis in the block
    else
        transitions.sd      = nan(numel(sequence), 1);
        transitions.min     = data_no_outliers';
        transitions.max 	= data_no_outliers';
    end
end
