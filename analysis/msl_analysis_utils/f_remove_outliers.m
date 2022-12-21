function [data_mean, data_SD, data_no_outliers, outliers_N] = f_remove_outliers(data, SD_N)
% compute mean and standard deviation for data
% remove outliers; + / - SD_N 
% If data is a two-dimentional matrix (N*M) analyses are performed for each column
%
% INPUT
% ------
% data              - numeric data; may be a vector or a two-dimentional matrix (N*M)
% SD_N              - # of standard deviations for outliers criteria; any value below or 
%                     above mean + / - SD_N * SD is an outlier
%
% OUTPUT
% -------
% if data is a two-dimentional matrix (N*M), statistics is done for each column
% `````````````````````````````````````````````````````````````````````````````
% data_mean         - mean of the original data; a number or a vector with M elements
% data_SD           - SD for the original data; a number or a vector with M elements
% data_no_outliers  - the data without outliers
% outliers_N        - # of outliers that were exluded; a number or a vector with M elements 
%
%===========================================================================================
data_mean       = nanmean(data);
data_mean_mtrx  = ones(size(data, 1), 1) * data_mean;    % adjustment of # of mean values to the data size
data_SD         = nanstd(data);
data_SD_mtrx    = ones(size(data, 1), 1) * data_SD;        % adjustment of # of SD values to the data size

% remove outliers, i.e., replace by NaN
% -------------------------------------- 
data_no_outliers    = data;
are_outliers        = abs(data_no_outliers) > (data_mean_mtrx + SD_N * data_SD_mtrx);
outliers_N      	= sum(are_outliers == 1);

data_no_outliers(are_outliers)  = NaN;

end
