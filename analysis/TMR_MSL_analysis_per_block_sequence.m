%% MSL analysis of CL-TMR
%llazzouni@gmail.com, 25/11/2022

% Prakriti Gupta's PhD project 
% Created 22-11-2022; for pilot data behavioural analysis

% two sequences (A:2-4-1-3-4-2-3-1; B: 1-3-2-4-3-1-4-2)
% two hands (right and left hand used one at a time)
% nBlocks_training for 3 phases: 30, 25, 25 (for each hand)
% nBlocks_presleep test: 3 (for each hand)
% nBlocks_postsleep test: 3 (for each hand)

% clear all;
% close all;
maindir='C:\Users\llazzo\Documents\GitHub\stim_TMR_MSL';
addpath('C:\Users\llazzo\Documents\GitHub\stim_TMR_MSL\MSL_data_analysis');
inputFolder=([maindir filesep 'output\Subject 1']);
outputFolder=([maindir filesep 'output']);
filelist=dir([inputFolder filesep '*phase*.mat']);
%%

for sj=1:1%length(filelist)
    file_name=filelist(sj).name;
    load([inputFolder filesep file_name]);
    o_name=strrep(file_name, 'mat', 'xls')
    seq=[];
    %% identify blocks
     numberblck=param.nbBlocksCompleted;
    j=1;
    for i=1:length(tasklog)-1   
        for n=1:numberblck
            if contains(tasklog(i).desc,['block' num2str(n)])
              index_blk(j)=i;
              j=j+1;
            end
        end
    end
    %% Identify hand/sequence
    j=1;
    for i=1:length(tasklog)-1
    %     for n=1:numberblck
            if contains(tasklog(i).desc,'left')
                hand=1;
                index_hand(j)=i;
                block_hand(j)=1;
                seq.left=tasklog(i+1).digit';
                j=j+1;
            elseif contains(tasklog(i).desc,'right')
                 hand=2;
                index_hand(j)=i;
                 block_hand(j)=2;
                 seq.right=tasklog(i+1).digit';
                j=j+1;
            end
    %     end
    end
    MSL_log.block=block_hand;
    MSL_log.index=index_hand;
    MSL_log.index(end+1)=length(tasklog);
    
    
    %% Identify left hand input onset after Perforamce start (perf-start from desc)
      j=1; rt=1;
      for i=1:length(MSL_log.index)-1
        for k=MSL_log.index(1,i):MSL_log.index(1,i+1)
            if (contains(tasklog(k).desc,'perf-start')) & (MSL_log.block(i)==1)
                if (contains(tasklog(k+1).desc,'input')) && (contains(tasklog(k+2).desc,'input')) && (contains(tasklog(k+3).desc,'input'))
                    perfStart_left(j)=tasklog(k).onset;
                    perfStartInd_left(j)=k;
                    inputStart_left(j)=tasklog(k+1).onset;
                    MSL_log.leftInput(j)=inputStart_left(j);
                    j=j+1;
                else
                    k=k+1;
                end
            elseif (contains(tasklog(k).desc,'perf-start')) & (MSL_log.block(i)==2)
                if (contains(tasklog(k+1).desc,'input')) && (contains(tasklog(k+2).desc,'input')) && (contains(tasklog(k+3).desc,'input'))
                      perfStart_right(rt)=tasklog(k).onset;
                      perfStartInd_right(rt)=k;
                      inputStart_right(rt)=tasklog(k+1).onset;
                      MSL_log.rightInput(rt)=inputStart_right(rt);
                      rt=rt+1;
                else
                    k=k+1;
                end
            end
        end
      end
      %clear perfStart
      
      %% Identify left hand input onset before Performance end (perf-end from desc)
      j=1; rt=1;
      for  i=1:length(MSL_log.index)-1
        for k=MSL_log.index(1,i):MSL_log.index(1,i+1)
            if (contains(tasklog(k).desc,'perf-end')) & (MSL_log.block(i)==1)
                perfEnd_left(j)=tasklog(k).onset;
                perfInputEnd_left(j)=tasklog(k-1).onset;
                perfEndInd_left(j)=k;
                MSL_log.leftInputEnd(j)=perfInputEnd_left(j);
                j=j+1; 
            elseif (contains(tasklog(k).desc,'perf-end')) & (MSL_log.block(i)==2)
                perfEnd_right(rt)=tasklog(k).onset;
                perfInputEnd_right(rt)=tasklog(k-1).onset;
                perfEndInd_right(rt)=k;
                MSL_log.rightInputEnd(rt)=perfInputEnd_right(rt);
                rt=rt+1; 
            else 
                k=k+1;
            end
        end
      end
      %%
      MSL_log.blockL=find([MSL_log.block]==1);
      MSL_log.blockR=find([MSL_log.block]==2);
      MSL_log.leftInput=MSL_log.leftInput';
      MSL_log.leftInputEnd=MSL_log.leftInputEnd';
      MSL_log.rightInput=MSL_log.rightInput';
      MSL_log.rightInputEnd=MSL_log.rightInputEnd';
      MSL_log.blockL=MSL_log.blockL';
      MSL_log.blockR=MSL_log.blockR';
      o_table=table( MSL_log.blockL, MSL_log.leftInput, MSL_log.leftInputEnd, MSL_log.blockR, MSL_log.rightInput, MSL_log.rightInputEnd);
      o_table.Properties.VariableNames={'blockLeft' 'left_input_start' 'left_input_end' 'BlockRight' 'right_input_start' 'right_input_end'};
      o_table_seq=table(seq.left, seq.right);
      o_table_seq.Properties.VariableNames={'left' 'right'};

    
%       writetable(o_table, [outputFolder filesep o_name], 'Sheet', 1);
%       writetable(o_table_seq, [outputFolder filesep o_name], 'Sheet', 2);

      %clear o_table o_table_seq MSL_log
end

  %% 
% figure; bar(MSL_log.block*1000)
% hold on
% bar(perfStartInd_left)
% bar(perfStartInd_right)
% bar(perfInputEnd_left)
% bar(perfInputEnd_right)
% 






