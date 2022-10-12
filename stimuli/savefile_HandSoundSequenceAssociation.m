function savefile_HandSoundSequenceAssociation(param, HandSoundSequenceAssociation)

output_file_name = [param.outputDir, param.subject,'_',param.task, '.mat'];
if ~exist(output_file_name,'file')
    save(output_file_name, 'HandSoundSequenceAssociation');
end
