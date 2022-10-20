function savefile(param, logoriginal, onset, seq_info, seq_matrx)

if nargin<4, seq_info=[]; end %#ok<NASGU>
if nargin<5, seq_matrx=[]; end %#ok<NASGU>

i_name = 1;
output_file_name = [param.outputDir, param.subject,'_',param.task,'_' , num2str(i_name) ,'.mat'];
while exist(output_file_name,'file')
    i_name = i_name+1;
    output_file_name = [param.outputDir, param.subject,'_',param.task,'_' , num2str(i_name) ,'.mat'];
end

save(output_file_name, 'logoriginal', 'param','seq_info','seq_matrx');
% Write onset
f_onset = fopen([param.outputDir, param.subject, '_' , param.task ,'_onset.txt'], 'a');
fprintf(f_onset, '\n\n%s   %d-%d-%d %d:%d:%d\n', '%%% tache appr/vitesse %%%',param.time(1),param.time(2),param.time(3),param.time(4),param.time(5),param.time(6));
fprintf(f_onset, 'rest = [%s];\n', num2str(onset.rest,'%8.2f'));
fprintf(f_onset, 'seq = [%s];\n', num2str(onset.seq,'%8.2f'));
fprintf(f_onset, 'seqDur = [%s];\n', num2str(onset.seqDur,'%7.2f'));
fclose(f_onset);

