function ld_runAnalysis(i_Dir)
% 
% Run basic analysis
% 
% 
% Arnaud Bore 2016/02/06
if nargin < 1
    i_Dir = '';
end

%% SECTION 1: INPUT DATA FILE                                          

[fname,path]=uigetfile([ i_Dir   '*.mat'], 'Choose a file to analyse');
if fname == 0
    return;
end
load(strcat(path,fname));

if strfind(fname,'Condition_A')
    param.sequence = param.seqA; %#ok<NODEF>
    param.task = 'Task Sequence A';
elseif strfind(fname,'Condition_B')
    param.sequence = param.seqB; %#ok<NODEF>
    param.task = 'Task Sequence B';
elseif strfind(fname,'Condition_C')
    msgbox('Analysis for Condition_C have not been implemented yet')
    return
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SECTION 2: EXTRACT DATA FROM 'LOGORIGINAL' STRUCTURE 

data = NaN(param.nbBlocks, param.nbKeys);                                   % matrix of time values corresponding to key presses. Dimensions: TOTAL BlockS (all conditions) x KEY PRESSES PER Block
key = NaN(param.nbBlocks, param.nbKeys);                                    % matrix identifying which key was pressed (i.e., 1-4). Dimensions: TOTAL BlockS (all conditions) x KEY PRESSES PER Block
flag = '';                                                                  % used to separate rest periods (no key presses) from practice/training periods
noBlock = 1;                                                                % used as counter below; eventually will equal TOTAL BlockS (all conditions)
index = 1;                                                                  % used as counter in loop
counter = 1;

for nLine = 1:length(logoriginal) %#ok<USENS>
    if strcmp(logoriginal{nLine}{2}, 'Practice')                            % 'Practice' denotes a training Block is about to begin (data stored in next n cells where n corresponds to the number of key presses per Block)
        flag = 'Practice';
        stimulus.GO(counter) = str2double(logoriginal{nLine}{1});
    end % IF loop
    if strcmp(logoriginal{nLine}{2}, 'Rest')                                % 'Rest' denotes the periods in between training Blocks (no key presses)
        flag = 'Rest';
        if strcmp(logoriginal{nLine-1}{2}, 'START') 
            % DO NOTHING
        else
            stimulus.stop(counter) = str2double(logoriginal{nLine}{1});
            counter = counter + 1;
            if counter>param.nbBlocks;break;end % we have received the "stop"
            % signal corresponding to the last desired block. Following is
            % either willingly excluded blocks or an incomplete Block.
        end
    end % IF loop
         
    if strcmp(logoriginal{nLine}{2}, 'rep') && strcmp(flag, 'Practice')     % rep corresponds to single key press in the training Block
        data(noBlock,index) = str2double(logoriginal{nLine}{1});                 
        key(noBlock,index) = str2double(logoriginal{nLine}{3});
        index = index + 1;                                                  % counter
        if index > param.nbKeys
            if noBlock < param.nbBlocks                 % if counter = number of key presses within each Block
                index = 1;                                                      % reset counter
                noBlock = noBlock + 1;
            % else % noBlock >= param.nbBlocks
                % this means we have gathered all the data, if we find
                % more, this will be the last blocks that have not been
                % included, either deliberately, or the last block that is
                % excluded for being incomplete
            end
        end % IF loop
    end % IF loop
end % FOR loop
clear index; clear flag; clear nLine; clear counter;                        % tidy workspace

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SECTION 3: COMPUTING DEPENENT VARIABLES BLOCK DURATION AND STANDARD %%%
%%% DEVIATION OF THE INTERVAL BETWEEN KEY PRESSES                       %%%

index= 1;                                                                  
for i = 1:1:noBlock                                                        
    seq_results(1,1).BLduration(index) = data(i,size(data,2)) - data(i,1);
    seq_results(1,1).GOduration(index) = stimulus.stop(i) - stimulus.GO(i); 
    for nKey = 2:size(data,2)
        interval(nKey-1) = data(i,nKey) - data(i,nKey-1); %#ok<AGROW>
    end % FOR loop
    seq_results(1,1).standard(index) = std(interval);

    index= index+ 1;                                              
end % FOR loop 
clear index; clear i; clear interval; clear nKey;  % tidy workspace
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SECTION 4: COMPUTING DEPENDENT VARIABLES ACCURACY AND SEQ DURATION  %%%
%%%                                                                     %%%
%%% This section builds upon the previous section and adds two new      %%%
%%% dependent variables to the structure arrasys 'ctrl_results' and     %%%
%%% 'seq_results'. The variables computed in this section are described %%%
%%% below.                                                              %%%
%%%                                                                     %%%
%%% correct - 1 x n vector; number of correct sequences made within each%%%
%%% Block. For the CTRL condition, this is set to perfect in each Block %%%
%%% n = # of Blocks in the sequence or control condition (nBlock/2)      %%%
%%%                                                                     %%%
%%% SEQduration - 1 x n vector; computes the averaged time it takes to  %%%
%%% complete a CORRECT m-element sequence within each Block. This       %%%
%%% measure will be highly correlated with BLduration; however,         %%%
%%% SEQduration is only computed for a correct sequence, effectively    %%%
%%% adjusting for any fluctuations in speed caused by the errors        %%%
%%%                                                                     %%%
%%% This section of the code will NOT work if the following criterion is%%%
%%% not met: a five-element sequence with the number 3 appearing one    %%%
%%% time. If your paradigm does not fit this criterion, you can edit the%%%
%%% appropriate sections below or simply comment the entire secion out  %%%
%%% and proceed only with the dependnet variables listed in SECTION 3   %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

index = 1;
% used as counter in loop; used to count # of Blocks within a condition (SEQ or SEQ)
lenSeq = length(param.sequence);

seqduration = NaN(noBlock,(param.nbKeys/lenSeq));            % Preallocate; sets variable with dimensions TOTAL Block # x THE NUMBER OF SEQUENCE REPETITIONS WITHIN A GIVEN Block (I.E., KEY PRESSES / NUMBER OF ELEMENTS IN THE SEQUENCE)
                                                                           % Must allocate seqdurations with NaN; but this variable is dependent on CORRECT sequences; if errors are made, there are less seqduration within a given Block
seq_results(1,1).correct = zeros(1,noBlock);                             % Initialize; start with zero correct sequences; will sum in the code below

key3position = find(param.sequence == 3);
% Within the SEQ to be learned, find location of the element 3. 
% The selection of 3 is arbitrary but ASSUMES that element 3 only appears
% once in the sequence

RangeToCheck = 1-key3position:lenSeq-key3position ;
RangeToCheck(RangeToCheck==0)=[];
% range of values near key 3 to check in order to assess
% the validity of the sequence, e.g. [-2,-1,1,2]

for i = 1:1:noBlock                                                        % i is used as counter that spans both SEQ and SEQ conditions
    Loc3 = find(key(i,:) == 3);                                % Within each Block, find where button 3 was pressed
    for ii = 1:1:length(Loc3)                                      % for each time the three appears
        if Loc3(ii) <= param.nbKeys - (lenSeq - key3position) && (Loc3(ii) >= key3position) % Ensures that each time a 3 appears, there are enough subsequent key presses to verify if the correct sequence was executed (w/o this check, it is likely to receive error msg 'index exceeds matrix dimensions')
            if key(i,Loc3(ii) + RangeToCheck) == param.sequence(key3position + RangeToCheck)
              % if key(i,Loc3(ii)-2) == param.sequence(find(param.sequence ==3)-2) && key(i,Loc3(ii)-1) == param.sequence(find(param.sequence ==3)-1) && key(i,Loc3(ii)+1) == param.sequence(find(param.sequence ==3)+1) && key(i,Loc3(ii)+2) == param.sequence(find(param.sequence ==3)+2);
              % above line checks to make sure the appropriate sequence was executed; only valid for 5-element sequences. 
                seq_results(1,1).correct(index) = seq_results(1,1).correct(index) + 1; % if correct sequence, add value of 1 to the count of correct sequences
                seqduration(i,ii) = data(i,Loc3(ii)+(lenSeq-key3position)) - data(i,Loc3(ii)-(key3position - 1)); % if correct sequence, determine time it took to complete sequence           
            end % IF loop
        end % IF loop
        seq_results(1,1).SEQduration(index) = nanmean(seqduration(i,:)); % compute mean of seqduration within each Block (use NaN mean b/c NaN's will be present if errors were made)
        seq_results(1,1).SEQstandard(index) = nanstd(seqduration(i,:)); % compute mean of seqduration within each Block (use NaN mean b/c NaN's will be present if errors were made)
    end % FOR loop
    index = index + 1;                                            
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SECTION 5: DURATION OF 2-ELEMENT COMBINATIONS                       %%%
%%%                                                                     %%%
%%% Computes the interval between consecutive key presses w/in a        %%%
%%% CORRECT sequence; allows user to determine which two elements are   %%%
%%% 'easiest' or 'hardest' for participants to execute consecutively.   %%%
%%% Variables are saved to the seq.results cell.                        %%%
%%%                                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

index = 1;                                                                 % used as counter in loop; used to count # of Blocks
interval12 = NaN(noBlock,param.nbKeys/lenSeq);             % Preallocate; sets variable with dimensions # SEQ Blocks x THE NUMBER OF SEQUENCE REPETITIONS WITHIN A GIVEN Block (I.E., KEY PRESSES / NUMBER OF ELEMENTS IN THE SEQUENCE); interval12 = duration between 1st and 2nd elements in the seq
interval23 = NaN(noBlock,param.nbKeys/lenSeq);             % interval23 = duration between 2nd and 3rd elements in the seq
interval34 = NaN(noBlock,param.nbKeys/lenSeq);             % interval34 = duration between 3rd and 4th elements in the seq
interval45 = NaN(noBlock,param.nbKeys/lenSeq);             % interval45 = duration between 4th and 5th elements in the seq
interval51 = NaN(noBlock,param.nbKeys/lenSeq);             % interval51 = duration between 5th and 1st elements in the seq (from last element of sequence back to the first)
                                                                           % Must allocate seqdurations with NaN; but this variable is dependent on CORRECT sequences; if errors are made, there are less seqduration within a given Block

for i = 1:1:noBlock                                                  
    counter = 1;
    counter2 = 2;
    for ii = 1:1:param.nbKeys
        if ii+4 <= param.nbKeys % prevents error msg of exceeding matrix dimensions
            if key(i,ii) == param.sequence(1) && key(i,ii+1) == param.sequence(2) && key(i,ii+2) == param.sequence(3) && key(i,ii+3) == param.sequence(4) && key(i,ii+4) == param.sequence(5)
                interval12(index,counter) = data(i,ii+1) - data(i,ii);
                interval23(index,counter) = data(i,ii+2) - data(i,ii+1);
                interval34(index,counter) = data(i,ii+3) - data(i,ii+2); 
                interval45(index,counter) = data(i,ii+4) - data(i,ii+3); 
                if ii+5 <= param.nbKeys && key(i,ii+5) == param.sequence(1) % prevents error msg of exceeding matrix dimensions AND it makes sure that the first element of the sequence is pressed after the last elementof the preceeding sequence
                    interval51(index,counter2) = data(i,ii+5) - data(i,ii+4); 
                    counter2 = counter2 + 1; 
                end
                counter = counter + 1; 
            end
        end
    end
    clear counter; clear counter2;  % tidy workspace

    seq_results(1,1).Interval12(index) = nanmean(interval12(index,:));  % Compute mean - excludes NaNs
    seq_results(1,1).Interval23(index) = nanmean(interval23(index,:)); 
    seq_results(1,1).Interval34(index) = nanmean(interval34(index,:)); 
    seq_results(1,1).Interval45(index) = nanmean(interval45(index,:)); 
    seq_results(1,1).Interval51(index) = nanmean(interval51(index,:)); 
    index = index + 1;        
end
clear index; clear i; clear ii;  % tidy workspace
clear interval12; clear interval23; clear interval34; clear interval45; clear interval 51;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SECTION 6: GENERATE FIGURES                                         %%%
%%%                                                                     %%%
%%% Section will generate plots of the appropriate dependent variables  %%%
%%%                                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
%-------------------------------------------------------------------------
% Correct sequence - DURATION
figure; set(gcf,'Color','white'); box OFF; hold on;

%% Plot Block duration
subplot(2,2,1); 
errorbar(1:1:length(seq_results.GOduration),seq_results.GOduration, seq_results.standard); hold on;
xlabel('Blocks','FontName','Arial','FontSize',12);
ylabel('Block duration','FontName','Arial','FontSize',12); 
ylim([0 (max(seq_results.GOduration))+min(seq_results.GOduration)]);

%% Plot correct sequences duration
subplot(2,2,2); 
errorbar(1:1:length(seq_results.SEQduration),seq_results.SEQduration,seq_results.SEQstandard); 
hold on;
xlabel('Blocks','FontName','Arial','FontSize',12); 
ylabel('Correct Sequences duration','FontName','Arial','FontSize',12); 
ylim([0 (max(seq_results.SEQduration))+min(seq_results.GOduration)]);

%% Number of correct sequences
subplot(2,2,3);  plot(seq_results.correct,'bo','MarkerSize', 6);
xlabel('Blocks','FontName','Arial','FontSize',12);
ylabel('Correct Sequences','FontName','Arial','FontSize',12);
ylim([0 (max(seq_results.correct))+3]);

%% Plot Interkeys interval
subplot(2,2,4)
plot(seq_results.Interval12,'bo','MarkerSize', 6); hold on;
plot(seq_results.Interval23,'ro','MarkerSize', 6); hold on;
plot(seq_results.Interval34,'go','MarkerSize', 6); hold on;
plot(seq_results.Interval45,'ko','MarkerSize', 6); hold on;
plot(seq_results.Interval51,'co','MarkerSize', 6); hold on;

h = axis; 
text(h(2)*1.05, h(4)*0.60,'Elem12','Color','b','FontSize',10); 
text(h(2)*1.05, h(4)*0.55,'Elem23','Color','r','FontSize',10); 
text(h(2)*1.05, h(4)*0.50,'Elem34','Color','g','FontSize',10); 
text(h(2)*1.05, h(4)*0.45,'Elem45','Color','k','FontSize',10); 
text(h(2)*1.05, h(4)*0.40,'Elem51','Color','c','FontSize',10);
xlabel('Blocks','FontName','Arial','FontSize',12)
ylabel('Interkeys interval','FontName','Arial','FontSize',12);
ylim([0 (max([seq_results.Interval12, seq_results.Interval23, ...
              seq_results.Interval34, seq_results.Interval45, ...
              seq_results.Interval51]))])

%% Save figure: .fig and .png
saveas(gcf,[param.outputDir fname(1:end-3) 'fig']);
saveas(gcf,[param.outputDir fname(1:end-3) 'png']);

%% Save seq_results structure
 
save([param.outputDir fname(1:end-4) '_results.mat'],'seq_results');
