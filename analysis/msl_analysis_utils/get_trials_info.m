function trials = get_trials_info(keys, sequence, n_start_trial)
% 
% INPUT
%   keys
%   sequence      [integer]     A vector of numbers representing the sequence
%   n_start_trial [integer]     The number of the first keys of the sequence to search for a trial; the default value is 2 keys
% 
% OUTPUT
%   trials
%       .type        [string]    Sequence / error/ head / tail
%       .i_start     [integer]
%       .i_end       [integer]

% Ella Gabitov, 14 July, 2020

if nargin < 3, n_start_trial = 2; end
if isempty(n_start_trial) || isnan(n_start_trial) || n_start_trial == 0, n_start_trial = 2; end

%% GET START INDECIES OF CORRECTLY PERFORMED AND COMPLETED SEQUENCES

ii_sequences = strfind(keys, sequence);   % indices of first keys of each sequence

% remove indices that overlap with the sequence
for i_trial = 1 : numel(ii_sequences) - 1
    if ii_sequences(i_trial) + numel(sequence) >  ii_sequences(i_trial+1)
        ii_sequences(i_trial+1) = NaN;
    end       
end
ii_sequences(isnan(ii_sequences)) = [];

%% GET START INDICES OF ALL TRIALS

ii_trials = strfind(keys, sequence(1:n_start_trial)); 	% indices of first keys of trial
ii_trials = [ii_trials numel(keys)+1];                  % add one extra trial at the end

% Update ii_trials:
% (1) add onsets for incorrect keys after a sequence between two trials
% (2) exclude onsets in the middle of a sequence
for i_sequence = 1 : numel(ii_sequences)
    start_seq   = ii_sequences(i_sequence);
    end_seq     = start_seq + numel(sequence) - 1;
    
    % exclude onsets in the middle of a sequence
    ii = (ii_trials > start_seq) & (ii_trials <= end_seq);
    ii_trials(ii) = NaN;
    
    % add onsets for incorrect keys after a sequence between two trials
    if ~any(ii_trials == end_seq+1)
        ii          = find(ii_trials < end_seq+1);
        ii_trials   = [ii_trials(1:ii(end)) (end_seq+1) ii_trials(ii(end)+1: end)];
    end
end
ii_trials(isnan(ii_trials))	= [];
ii_trials(end)              = [];    % remove one extra trial at the end;

% add a trial for the last keys after the last sequence
if ~isempty(ii_sequences)
    end_seq = ii_sequences(end) + numel(sequence) - 1;
    if end_seq < numel(keys) && ~any(ii_trials == end_seq+1)
        ii_trials = [ii_trials end_seq+1]; 
    end
end

%% TREAT THE FIRST TRIAL THAT CAN BE EITHER A SEQUENCE, ERROR OR HEAD

% not even a single trial; all keys are an error
if isempty(ii_trials)
    trials              = cell(1, 1);
    trials{1}.type      = 'error';
    trials{1}.i_start   = 1;
    trials{1}.i_end     = numel(keys);
    start_trial         = 1;
    
% there are keys before the first trial
elseif ii_trials(1) > 1
    ii_trials   = [1 ii_trials];
    trials      = cell(1, numel(ii_trials));
    
    % the first keys are part of a completed sequence
    if contains(sequence, keys(1:ii_trials(2)-1))
        trials{1}.type = 'head';
        
    % the first keys are an error
    else
        trials{1}.type = 'error';
    end
    
    trials{1}.i_start   = 1;
    trials{1}.i_end     = ii_trials(2) - 1;
    start_trial         = 2;
    
% the first key is the beginning of a trial
else
    trials      = cell(1, numel(ii_trials));
    start_trial = 1;
end

%% TREAT THE TRIALS

for i_trial = start_trial : numel(ii_trials)-1
    if any(ii_trials(i_trial)== ii_sequences)
        trials{i_trial}.type = 'sequence';
    else
        trials{i_trial}.type = 'error';
    end
    trials{i_trial}.i_start	= ii_trials(i_trial);
    trials{i_trial}.i_end   = ii_trials(i_trial+1) - 1;
end

%% TREAT THE LAST TRIAL THAT CAN BE EITHER a SEQUENCE, ERROR OR TAIL

if ~isempty(ii_trials)
    n_keys = numel(keys) - ii_trials(end) + 1; % number of keys in the last trial

    if any(ii_trials(end) == ii_sequences)
        trials{end}.type = 'sequence';

    elseif n_keys <= numel(sequence) &&...
            isequal(sequence(1:n_keys), keys(ii_trials(end):numel(keys)))
        trials{end}.type = 'tail';

    else
        trials{end}.type = 'error';
    end

    trials{end}.i_start	= ii_trials(end);
    trials{end}.i_end   = numel(keys); 
end

end

