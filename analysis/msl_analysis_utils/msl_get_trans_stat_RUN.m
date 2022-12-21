
% Ella Gabitov, 14 January, 2019

data_path = ('H:\EG_tools4an\ML_code\MSL_AN\data_example.mat');
% contains two variables:
% (1) keys for each block
% (1) key onsets for each block
% in the given example, there are 14 blocks of training

sequence = [4 1 3 2 4];
n_start_trial = 2;          % the number of keys to recognize the beginning of a new trial; should be unique and not repeate again within a sequence

data_MSL = load(data_path);

%% USING get_keys_stat FUNCTION

% plot:
%   (1) the percentage of correct keys, i.e., accuracy
%   (2) the mean duration of all transitions, correct transitions & incorrect transitions
%   (3) the mean duration of transitions of sequences & errors

n_blocks            = size(data_MSL.keys,1);
all_accuracy        = NaN(1, n_blocks);
all_all_trans       = NaN(1, n_blocks); 
all_correct_trans   = NaN(1, n_blocks);
all_incorrect_trans = NaN(1, n_blocks);
all_seq_trans       = NaN(1, n_blocks);
all_err_trans       = NaN(1, n_blocks);

for i_block = 1:n_blocks
    
    keys    = data_MSL.keys(i_block, :);
    onsets  = data_MSL.onsets(i_block, :);
    [perf_duration,...
            all_trans,...
            correct_trans,...
            incorrect_trans,...
            sequence_trans,...
            btwn_sequence_trans,...
            error_trans,...
            btwn_error_trans...
            ]...
            = get_keys_stat(keys, onsets, sequence, n_start_trial);
        
    all_accuracy(i_block)           = correct_trans.n / all_trans.n * 100;
    all_all_trans(i_block)          = all_trans.trans_mean; 
    all_correct_trans(i_block)      = correct_trans.trans_mean;
    all_incorrect_trans(i_block)    = incorrect_trans.trans_mean;
    all_seq_trans(i_block)          = sequence_trans.trans_mean;
    all_err_trans(i_block)          = error_trans.trans_mean;

end

i_blocks = 1:n_blocks;

subplot(3, 1, 1);
plot(i_blocks, all_accuracy);
ylabel('Accuracy (% of correct keys)');

subplot(3, 1, 2);
plot(i_blocks, all_all_trans, i_blocks, all_correct_trans, i_blocks, all_incorrect_trans);
ylabel('Transition diration (sec)');
legend({'All','Correct', 'Incorrect'},'Location','northeast');

subplot(3, 1, 3);
plot(i_blocks, all_seq_trans, i_blocks, all_err_trans);
ylabel('Transition diration (sec)');
legend({'Sequence transitions','Error transitions'},'Location','northeast');

clearvars;






