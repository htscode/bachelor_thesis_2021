

function [famous,unfamiliar,scrambled,exfamous,exunfamiliar,exscrambled] = shifttrialsnew(tsvpth,outpth,subject,nsessions,myshift)
%%
% function to shift the label of trials according to a certain preset shift
% tsvpth = path to tsv file containing information about trials
% outpth = path to save to
% subjects =  array of subjects %todo change to mayb only one 
% nsession = number of fMRI sessions 
% myshift = in seconds 

for session = 1:nsessions 
    %% load trial info 
    path_to_onset=append(tsvpth,sprintf('sub-%02d_ses-mri_func_sub-%02d_ses-mri_task-facerecognition_run-%02d_events.tsv',subject,subject,session));
    data = tdfread(path_to_onset);
    %get trial onsets
    tsvallonsets = [data.onset];
    %get trial label
    tsvallconditions = [data.stim_type];
    %get fixation cross period (pre stimulus) 
    tsvcross = [data.circle_duration];  
    tsvduration = [data.duration];
    
    % create arrays for scans sorting 
    % determeines whether a scan is included,1, or excluded,0,
    goodscans = ones(1,208)*4 ;
    % save condition of scan 
    scancondition = strings(1,208);
    % save onset of trials
    %scantrialonsets = zeros(1,208);
    %% Determine good and bad scans
    % bad scans are those who can't be assigned a definete label meaning
    % associated scans hold response to more than one condition
    
    % scan counter 
    i=1;    
    
    for trial = 1:length(tsvallonsets)  
        % if we deal with the last trial
        if trial == length(tsvallonsets)
            % we dont need to incorperate the jittering as no trial follows
            % discard the last trials as we don't know what happenedafter
            % the last stimuli
            shift = myshift;            
            while i <= length(goodscans)
                % exclude scans = 0
                goodscans(i)= 0;
                % trial information
                scancondition(i)= tsvallconditions(trial);
                %scantrialonsets(i) = tsvallonsets(trial)+shift;
                i = i+1;
            end
            break
        % deal with the first trial sepperately to avoid a too long (and
        % thereby probably faulty) initial trial
        elseif trial == 1
            shift = myshift + tsvcross(trial) ;
            % exclude scans happening before new shifted trial onset
            while (i*2) < (tsvallonsets(trial)+shift) 
                goodscans(i)= 0; %1 = good
                scancondition(i)= 0;
                %scantrialonsets(i) = 0; 
                i = i+1;
            end            
            % here we one could take into account the jittering in the
            % presentation time, this is not done as the neccessity for it
            % is not completly certain 
            durationjittering = 0;
            % caclulate for every trial a "personal" shift taking into
            % account the fixation period 
            shift = myshift + tsvcross(trial+1) + durationjittering; 
            
            %all scans which are finished before the next trial starts are
            %determined as good 
            while (i*2) < (tsvallonsets(trial+1)+shift) 
                % save goodnes of scan
                goodscans(i)= 1; %1 = good
                % save condition
                scancondition(i)= tsvallconditions(trial);
                %scantrialonsets(i) = tsvallonsets(trial)+shift;
                i = i+1;
            end
            
            % determine if a (one) scan between two trials is good
            % a scan is accepted and determined as good when the next trial
            % is of the same condition or rest
            
            if tsvallconditions(trial) == tsvallconditions(trial+1) | (tsvallconditions(trial+1) == 'n')
                goodscans(i)= 1;
                scancondition(i)= tsvallconditions(trial);                
                %scantrialonsets(i) = tsvallonsets(trial)+shift;
            else
                goodscans(i)= 0; %unnesessary/for clarification
                scancondition(i)= tsvallconditions(trial);
                %scantrialonsets(i) = tsvallonsets(trial)+shift;
            end
            i = i+1;
        else
            
            % calculate personal shift by incorperating jittering of the
            % next trial
            % to the general shift a "personal" shift is added this shift
            % arrises due to the initial fixation period which also
            % incoorperates jittering (before - tsvcross(trial+1)- 400(min
            % fixationperiod)
            
            % if the next trial is a a nan then we cant make use of the
            % standard paramaeter as the tsv file describes them somewhat
            % inaccurately 
            fixationperiod =  tsvcross(trial+1);
            
            if(tsvallconditions(trial+1) == 'n')
               fixationperiod = 0;
            end
                     
            % here we one could take into account the jittering in the
            % presentation time, this is not done as the neccessity for it
            % is not completly certain 
            durationjittering = 0;
            
            % calculate personal shift 
            shift = myshift +  fixationperiod + durationjittering; 
            
            %all scans which are finished before the next trial starts are
            %determined as good 
            while (i*2) < (tsvallonsets(trial+1)+shift) 
                % goodnes of scan
                goodscans(i)= 1; %1 = good
                % condition of scan 
                scancondition(i)= tsvallconditions(trial);
                %scantrialonsets(i) = tsvallonsets(trial)+shift;
                i = i+1;
            end
            
            %determine if a scan between two trials is good
            %a scan is accepted and determined as good when the next trial
            %is of the same condition or rest
            if tsvallconditions(trial) == tsvallconditions(trial+1) | (tsvallconditions(trial+1) == 'n')
                goodscans(i)= 1;
                scancondition(i)= tsvallconditions(trial);                
                %scantrialonsets(i) = tsvallonsets(trial)+shift;
            else
                goodscans(i)= 0; %unnesessary/for clarification
                scancondition(i)= tsvallconditions(trial);
                %scantrialonsets(i) = tsvallonsets(trial)+shift;
            end
            i = i+1;
        end
    end
    %% Create new trial definition incorperationg shift
    % this new trial definition is scan based, meaning that every scan is
    % seen as an individual trial, the trial onset is then the scan onset 
    % the condition is the condition we determined above 
    % note that we are currently not making use of the rest scans
    % this, however, could easily be changed by adding another case 
    sizecounters = zeros(6,1);
    
    famous = zeros(1,50);
    unfamiliar = zeros(1,50);
    scrambled = zeros(1,50);   
    
    %save those who were determined as bad scans earlier according to the
    %label the would have if they haven't been excluded (which is the
    %condition of the previous trial/scan 
    
    exfamous = zeros(1,50);
    exunfamiliar = zeros(1,50);
    exscrambled = zeros(1,50);
   
    %built new trial definition and complete exclusion 
    for m = 1:length(goodscans)
        % new trial onset is the scan onset (starts at 0 then every 2 secs
        % a scan was started)
        j = (m-1)*2;
        % sort good trials/scans by condition indicated by first letter)
        if goodscans(m) == 1
            switch scancondition(m)
                case 'F'
                     sizecounters(1) = sizecounters(1) +1;
                    famous(sizecounters(1)) = j;              
                case 'U'
                     sizecounters(2) = sizecounters(2) +1;
                    unfamiliar(sizecounters(2)) = j;
                case 'S'
                     sizecounters(3) = sizecounters(3) +1;
                    scrambled(sizecounters(3)) = j;
                otherwise                     
            end
        % sort bad/excluded trials/scans by condition (indicated by first
        % letter)
        elseif goodscans(m) == 0
            switch scancondition(m)
                case 'F'
                     sizecounters(4) = sizecounters(4) +1;
                    exfamous(sizecounters(4)) = j;
                case 'U'
                     sizecounters(5) = sizecounters(5) +1;
                    exunfamiliar(sizecounters(5)) = j;
                case 'S'
                     sizecounters(6) = sizecounters(6) +1;
                    exscrambled(sizecounters(6)) = j; 
                otherwise 
                    
            end
        end
    end
    %% shrink 
    
    famous = famous(1,1:sizecounters(1));
    unfamiliar =unfamiliar(1,1:sizecounters(2));
    scrambled = scrambled(1,1:sizecounters(3));
    
    exfamous = exfamous(1,1:sizecounters(4));
    exunfamiliar= exunfamiliar(1,1:sizecounters(5));
    exscrambled= exscrambled(1,1:sizecounters(6));
    
    %% Save new trial definition 
    
    % create trial files according to  the classic spm trial definition mat file 
    
    onsets = {famous,unfamiliar,scrambled,exfamous,exunfamiliar,exscrambled};
    durations= {0,0,0,0,0,0};
    names={'famous','unfamiliar','scrambled','exfamous','exunfamiliar','exscrambled'};

   % save   
   filename = fullfile(outpth,sprintf('run%02d_optimization_def.mat',session));
   save( filename, 'durations', 'names', 'onsets');
   
end
end