
% Ella Gabitov, 14 January, 2019

addpath('H:\EG_tools4an\ML_code\MSL_AN\help_func');

data_path = ('H:\EG_tools4an\ML_code\MSL_AN\data_example.mat');
% contains two variables:
% (1) keys for each block
% (1) key onsets for each block
% in the given example, there are 14 blocks of training

sequence        = [4 1 3 2 4];
n_start_trial   = 2; 	% the number of keys to recognize the beginning of a new trial; should be unique and not repeate again within a sequence
n_sd            = 2;	% the number of standard deviations; is used to exclude outliers             

data_MSL = load(data_path);

%% USING get_keys_stat FUNCTION

% plot:
%   (1) sequence duration for each block
%   (2) mean tapping pattern for each block

n_blocks                = size(data_MSL.keys,1);
n_sequences             = size(data_MSL.keys,2)/numel(sequence);
all_sequence_durations  = NaN(n_blocks, n_sequences);
all_tapping_patterns    = NaN(n_blocks, numel(sequence));

for i_block = 1:n_blocks
    
    keys = data_MSL.keys(i_block, :);
    onsets = data_MSL.onsets(i_block, :);
    
    [sequences, transitions] = get_sequences_info(keys, onsets, sequence, n_start_trial, n_sd);
    
    for i_seq = 1 : numel(sequences)
        all_sequence_durations(i_block, i_seq) = sequences{i_seq}.duration;
    end
    
    all_tapping_patterns(i_block, :) = transitions.mean;
    
end

subplot(2, 1, 1);
i_sequences = 1:n_sequences;
plot(i_sequences, all_sequence_durations(1, :), 'DisplayName','Block 1');
legend('-DynamicLegend');
hold all;
for i_block = 2 : n_blocks
    plot(i_sequences, all_sequence_durations(i_block, :), 'DisplayName', ['Block ' num2str(i_block)]);
end
ylabel('Sequence duration (sec)');
hold off;

subplot(2, 1, 2);
i_transitions = 1:numel(sequence);
plot(i_transitions, all_tapping_patterns(1, :), 'DisplayName','Block 1');
legend('-DynamicLegend');
hold all;
for i_block = 1 : n_blocks
    plot(i_transitions, all_tapping_patterns(i_block, :), 'DisplayName', ['Block ' num2str(i_block)]);
end
ylabel('Transition duration (sec)');
hold off;

clearvars;

rmpath('H:\EG_tools4an\ML_code\MSL_AN\help_func');



