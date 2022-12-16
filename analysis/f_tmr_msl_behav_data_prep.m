function [blocks, rest] = f_tmr_msl_behav_data_prep(tasklog)
%F_TMR_MSL_DATA_PREP extracts data from the tasklog structure
% Ella Gabitov (gabitovella@gmail.com), 15 December 2022
%
%   INPUT
%       tasklog         [struct]
%           the output from the task with the following fields:
%           .desc
%           .onset
%           .value
%           .digit
%
%       nb_keys_start   [int]
%           the number of correct keys to initiate the block
%
%   OUTPUT
%       blocks
%       values
%       onsets
%

blocks = [];
blocks.info = table();
blocks.input_onsets = [];
blocks.input_digits = [];

rest = [];
rest.input_onsets = [];
rest.input_digits = [];

descs = {tasklog(:).desc};

%% Blocks

blocks.info.label = descs(contains(descs, 'block'))';
blocks.info.sound = descs(contains(descs, '.wav'))';
blocks.info.device_volume = {tasklog(strcmp(descs, 'device volume')).value}';
blocks.info.hand = descs(ismember(descs, {'left', 'right'}))';
blocks.info.seq = {tasklog(strcmp(descs, 'seq')).digit}';

%% Indices with block labels

inds = find(contains(descs, 'block'));
inds(end+1) = length(descs); % Add the index of the last recorded data

%% The number of attempts to initiate each block

blocks.info.nb_attempts(:) = 0; 
for i_block = 1 : length(inds)-1
    block_start = inds(i_block);
    block_end = inds(i_block+1) - 1;
    descs_tmp = descs(block_start:block_end);
    blocks.info.nb_attempts(i_block) = length(find(strcmp(descs_tmp, 'perf-start')));
end

%% Keys input: onsets & values

inds_perf_start = find(contains(descs, 'perf-start'));
inds_perf_end = find(contains(descs, 'perf-end'));

inds_rest_start = find(contains(descs, 'rest-start'));
inds_rest_end = find(contains(descs, 'rest-end'));

for i_block = 1 : length(inds)-1
    block_start = inds(i_block);
    block_end = inds(i_block+1);

    % Keys pressed during performance blocks
    %   - Start and end of performance after the block was successufly initiated
    %   - Successful block initiation corresponds to the last perf-start for the current block
    perf_start = inds_perf_start(inds_perf_start > block_start & inds_perf_start < block_end);
    perf_end = inds_perf_end((inds_perf_end > block_start) & (inds_perf_end < block_end));
    onsets = [tasklog(perf_start(end)+1 : perf_end(end)-1).onset];
    digits = [tasklog(perf_start(end)+1 : perf_end(end)-1).digit];
    blocks.input_onsets(i_block, 1:length(onsets)) = onsets;
    blocks.input_digits(i_block, 1:length(digits)) = digits;

    % Keys pressed during rest
    rest_start = inds_rest_start(inds_rest_start > block_start & inds_rest_start < block_end);
    rest_end = inds_rest_end((inds_rest_end > block_start) & (inds_rest_end < block_end));
    if ~isempty(tasklog(rest_start(end)+1 : rest_end(end)-1))
        onsets = [tasklog(rest_start(end)+1 : rest_end(end)-1).onset];
        digits = [tasklog(rest_start(end)+1 : rest_end(end)-1).digit];
        rest.input_onsets(i_block, 1:length(onsets)) = onsets;
        rest.input_digits(i_block, 1:length(digits)) = digits;
    end
end


    









