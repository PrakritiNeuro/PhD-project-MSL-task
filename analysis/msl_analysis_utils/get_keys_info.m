function iscorrect_keys = get_keys_info(keys, sequence, n_start_trial)

% INPUT
% keys                      a vector of keys
% sequence      [integer]   a vector of numbers representing the sequence
% n_start_trial [integer]   the number of the first keys of the sequence to search for a trial; the default value is 2 keys
%
% OUTPUT
% iscorrect_keys  	[boolean] 	vector with 1 for correct key and 0 otherwise;
%                               all keys of correctly performed and completed or incomleted sequences are correct;
%                               keys within "head" and "tail" are also correct

% Ella Gabitov, 14 January, 2020

if nargin < 3, n_start_trial = 2; end
if isempty(n_start_trial) || isnan(n_start_trial) || n_start_trial == 0, n_start_trial = 2; end

trials = get_trials_info(keys, sequence, n_start_trial);
% trials{i}.type
% trials{i}.i_start
% trials{i}.i_end

iscorrect_keys = zeros(1, numel(keys));

for i_trial = 1 : numel(trials)
    
    trial_tmp = trials{i_trial};
    
    switch trial_tmp.type
        
        case {'head',...
              'sequence'...
              'tail'...
                }
            iscorrect_keys(trial_tmp.i_start:trial_tmp.i_end) = 1;
            
        case 'error'
            i_start_incorrect = trial_tmp.i_start;
            error_keys_tmp = keys(trial_tmp.i_start : trial_tmp.i_end);
            if numel(error_keys_tmp) >= n_start_trial
                if contains(error_keys_tmp(1:n_start_trial), sequence(1:n_start_trial))
                    n_correct = n_start_trial + 1;
                    while numel(error_keys_tmp)>= n_correct &&...
                            contains(error_keys_tmp(1:n_correct), sequence(1:n_correct))
                        n_correct = n_correct + 1;
                    end
                    n_correct = n_correct-1;
                    iscorrect_keys(trial_tmp.i_start:trial_tmp.i_start+(n_correct-1)) = 1;
                    i_start_incorrect = trial_tmp.i_start+n_correct;
                end
            end
            iscorrect_keys(i_start_incorrect:trial_tmp.i_end) = 0;
                                    
    end % SWITCH
        
end % FOR each trial

end

