%%
% function to shift the label of trials according to a certain preset shift
% tsvpth = path to tsv file containing information about trials
% outpth = path to save to
% subjects =  array of subjects %todo change to mayb only one 
% nsession = number of fMRI sessions 
% shift = in seconds 

function [famous,unfamiliar,scrambled,exfamous,exunfamiliar,exscrambled] = shifttrials(tsvpth,outpth,subjects,nsessions,myshift)
for session = 1:nsessions 
    %% load trial info 
    path_to_onset=append(tsvpth,sprintf('sub-15_ses-mri_func_sub-15_ses-mri_task-facerecognition_run-%02d_events.tsv',session));
    data = tdfread(path_to_onset);
    %get trial onsets
    tsvallonsets = [data.onset];
    %get trial label
    tsvallconditions = [data.stim_type];
    %in order to take jittering into account
    tsvcross = [data.circle_duration];  
    tsvduration = [data.duration];
    %todo length might not always be 208 
    goodscans = zeros(1,208);
    scantrials = strings(1,208);
    scantrialonsets = zeros(1,208);
    %% Determine good and bad scans
    % bad scans are those who can't be assigned a definete label meaning
    % associated scans hold response to more than one condition
    
    %scan counter 
    i=1;    
    for trial = 1:length(tsvallonsets)  
        % if we deal with the last trial
        if trial == length(tsvallonsets)
            % we dont need to incorperate the jittering as no trial follows
            % todo: is this correct, currently these are discarded 
            shift = myshift;            
            while i <= length(goodscans)
                goodscans(i)= 3;
                scantrials(i)= tsvallconditions(trial);
                scantrialonsets(i) = tsvallonsets(trial)+shift;
                i = i+1;
            end
            break
        else
            %calculate personal shift by incorperating jittering of the
            %next trial
            % to the general shift a "personal" shift is added this shift
            % arrises due to the initial fixation period which also
            % incoorperates jittering 
            
            %based on the duration a stimulus is shown 
            presentationjittering = tsvduration(trial) - 800;
            shift = myshift + tsvcross(trial+1)+ presentationjittering; 
            %all scans which are finished before the next trial starts are
            %determined as good 
            while (i*2) < (tsvallonsets(trial+1)+shift) 
                goodscans(i)= 1; %1 = good
                scantrials(i)= tsvallconditions(trial);
                scantrialonsets(i) = tsvallonsets(trial)+shift;
                i = i+1;
            end
            %determine if a scan between two trials is good
            %a scan is accepted and determined as good when the next trial
            %is of the same condition or rest
            if tsvallconditions(trial) == tsvallconditions(trial+1) | (tsvallconditions(trial+1) == 'n')
                goodscans(i)= 1;
                scantrials(i)= tsvallconditions(trial);                
                scantrialonsets(i) = tsvallonsets(trial)+shift;
            else
                goodscans(i)= 0; %unnesessary/for clarification
                scantrials(i)= tsvallconditions(trial);
                scantrialonsets(i) = tsvallonsets(trial)+shift;
            end
            i = i+1;
        end
    end
    %% Create new trial definition incorperationg shift
    
    famous = [];
    unfamiliar = [];
    scrambled = [];   
    %save those who were determined as bad scans earlier according to their
    %old label 
    exfamous = [];
    exunfamiliar = [];
    exscrambled = [];
   
    %for all scans only add them to associated label if good 
    for m = 1:length(goodscans)
        % new trial onset is the scan onset
        j = (m-1)*2;
        if goodscans(m) == 1
            switch scantrials(m)
                case 'F'
                    famous(end+1) = j;              
                case 'U'
                    unfamiliar(end+1) = j;
                case 'S'
                    scrambled(end+1) = j;
            end
        elseif goodscans(m) == 0
            switch scantrials(m)
                case 'F'
                    exfamous(end+1) = j;
                case 'U'
                    exunfamiliar(end+1) = j;
                case 'S'
                    exscrambled(end+1) = j; 
            end
        end
    end
    %possibility to save new trial definition
    onsets = {famous,unfamiliar,scrambled,exfamous,exunfamiliar,exscrambled};
    durations= {0,0,0,0,0,0};
    names={'famous','unfamiliar','scrambled','exfamous','exunfamiliar','exscrambled'};
%   
    
    %(outpth)
   filename = fullfile(outpth,sprintf('run%02d_optimization_def.mat',session));
    save( filename, 'durations', 'names', 'onsets');
   
end
end