
% Ella Gabitov, 14 January, 2019

data_path = ('...\MSL_AN\data_example.mat');
% contains two variables:
% (1) keys for each block
% (1) key onsets for each block
% in the given example, there are 14 blocks of training

sequence = [4 1 3 2 4];
n_start_trial = 2;          % the number of keys to recognize the beginning of a new trial; should be unique and not repeate again within a sequence

data_MSL = load(data_path);

%% USING get_trials_stat FUNCTION

% plot:
%   (1) the total performance duration
%   (2) the number of corrrect sequences and the total number of trials
%   (3) the percentage of correct sequences out of the total number of trials

n_blocks = size(data_MSL.keys,1);
all_perf_duration = NaN(1, n_blocks);
all_n_sequences = NaN(1, n_blocks); 
all_n_errors = NaN(1, n_blocks);

for i_block = 1:n_blocks
    keys = data_MSL.keys(i_block, :);
    onsets = data_MSL.onsets(i_block, :);
    [perf_duration,...
            n_keys,...
            sequences,...
            btwn_seq,...
            errors...
            ]...
            = get_trials_stat(keys, onsets, sequence, n_start_trial);
        
    all_perf_duration(i_block) = perf_duration;
    all_n_sequences(i_block) = sequences.n;
    all_n_errors(i_block) = errors.n;
end

i_blocks = 1:n_blocks;

subplot(3, 1, 1);
plot(i_blocks, all_perf_duration);
ylabel('Performance duration (sec)');

subplot(3, 1, 2);
all_n_trials = all_n_sequences + all_n_errors;
plot(i_blocks, all_n_trials, i_blocks, all_n_sequences);
ylabel('The # of trials / sequences');
legend({'All trials','Sequences'},'Location','northeast');

subplot(3, 1, 3);
accuracy_pc = all_n_sequences ./ all_n_trials * 100;
plot(i_blocks, accuracy_pc);
ylabel('Accuracy (% of sequences)');

clearvars;
