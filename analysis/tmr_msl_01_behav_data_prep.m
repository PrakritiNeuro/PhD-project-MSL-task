%% PREPARATION OF THE BEHAVIORAL DATA FOR ANALYSIS
% Ella Gabitov (gabitovella@gmail.com), 15 December 2022
%
[mfile_dpath, ~, ~] = fileparts(mfilename('fullpath'));
[main_dpath, ~, ~] = fileparts(mfile_dpath);

add2path = {...
    fullfile(main_dpath, 'analysis');
    };
for i = 1 : length(add2path)
    addpath(add2path{i});
end

% Path to the source (src) directory with the raw data
src_dpath = fullfile(main_dpath,'output');

% Path to the directory to save the results
res_dpath = fullfile(main_dpath, 'results');

%% Subjects for analysis 
% The data of each subject is stored in the directory with the same name as the subject identifier

% Get all subjects from the src directory
list_dir = dir(src_dpath);
subjects = {list_dir([list_dir(:).isdir]).name};
subjects(contains(subjects, '.')) = []; % Should not contain dots

% Specify subjects explicitly
% subjects = {...
%     'Subject1'...
%     'Subject2'...
%     'Subject3'...
%     };

%% Let's go!

for i_subj = 1 : length(subjects)
    subj = subjects{i_subj};
    src_subj_dpath = fullfile(src_dpath, subj);

    % List all matfile names
    list_dir = dir(fullfile(src_subj_dpath, [subj, '*.mat']));
    fnames = {list_dir.name};
    
    % All names of the listed files should contain subject indentifier
    if any(~contains(fnames, subj))
        disp('---');
        disp(subj);
        error('Some of the files do not correspond to the subject. CHECK!!!');
    end

    % Get only file names with training and test data
    fnames = fnames(contains(fnames, 'training') | contains(fnames, 'test'));

    for i_fname = 1 : length(fnames)
        src_fpath = fullfile(src_subj_dpath, fnames{i_fname});
        
        % Load the data
        data_loaded = load(src_fpath);
        tasklog = data_loaded.tasklog;

        % Prepare the data
        [blocks, rest] = f_tmr_msl_behav_data_prep(tasklog);

        % Save the results
        res_subj_dpath = fullfile(res_dpath, subj);
        if ~exist(res_subj_dpath, 'dir')
            mkdir(res_subj_dpath);
        end
        res_fpath = fullfile(res_subj_dpath, fnames{i_fname});
        save(res_fpath, 'blocks', 'rest');
        
    end
end

%% Clear the workspace

disp('---');
disp('DATA PREPARATION FOR THE ANALYSIS - DONE!!!');
disp(['The data is ready for the analysis in ', res_dpath]);

for i = 1 : length(add2path)
    rmpath(add2path{i});
end
clearvars;


