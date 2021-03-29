%%
% function to shift the label of trials according to a certain preset shift
% tsvpth = path to tsv file containing information about trials
% outpth = path to save to
% subjects =  array of subjects %todo change to mayb only one 
% nsession = number of fMRI sessions 
% shift = in seconds 

function shiftwithrest(tsvpth,outpth,subject,nsessions,myshift)


for session = 1:nsessions 
    %% load trial info 
    path_to_onset=append(tsvpth,sprintf('sub-%02d_ses-mri_func_sub-%02d_ses-mri_task-facerecognition_run-%02d_events.tsv',subject,subject,session));
      
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
                goodscans(i)= 0;
                scantrials(i)= tsvallconditions(trial);
                scantrialonsets(i) = tsvallonsets(trial)+shift;
                i = i+1;
            end
            break
        elseif trial == 1
            shift = myshift + tsvcross(trial) ;
            while (i*2) < (tsvallonsets(trial)+shift) 
                goodscans(i)=0; %1 = good
                scantrials(i)= 0;
                scantrialonsets(i) = 0;
                i = i+1;
            end            
            durationjittering = 0;% tsvduration(trial)-0.8;
            shift = myshift + tsvcross(trial+1) + durationjittering; 
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
        else
            %calculate personal shift by incorperating jittering of the
            %next trial
            % to the general shift a "personal" shift is added this shift
            % arrises due to the initial fixation period which also
            % incoorperates jittering (before - tsvcross(trial+1)- 400(min
            % fixationperiod)
            
            %if the next trial is a a nan then we cant make use of the
            %standard paramaeter as the tsv file describes them somewhat
            %inaccurately 
            fixationperiod =  tsvcross(trial+1);
            if(tsvallconditions(trial+1) == 'n')
               fixationperiod = 0;
            end
                     
            
            durationjittering = 0;%;; tsvduration(trial)-0.8;
            
            shift = myshift +  fixationperiod + durationjittering; 
            %all scans which are finished before the next trial starts are
            %determined as good 
            while (i*2) < (tsvallonsets(trial+1)+shift) 
                %fprintf('cookie');
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
    rest = [];
    %save those who were determined as bad scans earlier according to their
    %old label 
    exfamous = [];
    exunfamiliar = [];
    exscrambled = [];
    exrest= [];
   
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
                case 'n'
                    rest(end+1) = j;
            end
        elseif goodscans(m) == 0
            switch scantrials(m)
                case 'F'
                    exfamous(end+1) = j;
                case 'U'
                    exunfamiliar(end+1) = j;
                case 'S'
                    exscrambled(end+1) = j; 
                case 'n'
                    exrest(end+1) = j;
            end
        end
    end
    % save new trial definition
    onsets = {famous,unfamiliar,scrambled,rest,exfamous,exunfamiliar,exscrambled,exrest};
    durations= {0,0,0,0,0,0,0,0,0};
    names={'famous','unfamiliar','scrambled','rest','exfamous','exunfamiliar','exscrambled','exrest'};

   filename = fullfile(outpth,sprintf('run_%02d_optimization_def.mat',session));
    save( filename, 'durations', 'names', 'onsets');
   
end
end
