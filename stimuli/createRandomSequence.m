function seq_matrx = createRandomSequence(nbSeqs, nbBlocks)

seq_matrx = [];
for i=1:nbBlocks
    seq_matrx = [seq_matrx randperm(nbSeqs)];
end


% function seq_matrx = createRandomSequence(nbSeqs, nbSeqs_in_a_row, init_seq_matrx)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % nbSeqs            the # of sequences
% % nbSeqs_in_a_row   # of repetitions of the same sequence in a row
% % init_seq_matrx    initial matrix with numbers that denote sequences 
% %                   from 1 to the # of sequences
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % create in_a_row_seqs to search for
% % -----------------------------------
% in_a_row_seqs = cell(1, nbSeqs);
% for seq_i = 1 : nbSeqs
%     in_a_row_str = num2str(repmat(seq_i, 1, nbSeqs_in_a_row));      % vector with sequence repetitions
%     in_a_row_str = in_a_row_str(find(~isspace(in_a_row_str)));      % remove spaces
%     in_a_row_seqs{seq_i} = in_a_row_str;
% end
% 
% seq_matrx = init_seq_matrx;
% seq_matrx = seq_matrx(randperm(numel(seq_matrx)));
% seq_matrx_str = num2str(seq_matrx);
% seq_matrx_str = seq_matrx_str(find(~isspace(seq_matrx_str)));       % remove spaces
% in_a_row_i = regexp(seq_matrx_str, in_a_row_seqs);
% in_a_row_i = in_a_row_i(~cellfun('isempty',in_a_row_i));            % remove empty cells
% 
% while ~isempty(in_a_row_i)
%     seq_matrx = init_seq_matrx;
%     seq_matrx = seq_matrx(randperm(numel(seq_matrx)));
%     seq_matrx_str = num2str(seq_matrx);
%     seq_matrx_str = seq_matrx_str(find(~isspace(seq_matrx_str)));   % remove spaces
%     in_a_row_i = regexp(seq_matrx_str, in_a_row_seqs);
%     in_a_row_i = in_a_row_i(~cellfun('isempty',in_a_row_i));        % remove empty cells
% end