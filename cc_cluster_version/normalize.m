% we need to normalize  to percent signal change
savepth = '';
trialpth= ''; %trial definitions 

nsessions= 3; %number of sessions/runs used 
nsubjects = 16;
if ~exist(savepth)
       eval(sprintf('!mkdir %s',savepth));
end



addpath(''); % SPM12

for subject= 1:nsubjects
    fprintf('Normalizing data for subject %02d \n',subject);
    
    folder  = sprintf('sub%02d',subject);
    outpth = fullfile(savepth,folder);
    
    if ~exist(outpth)
        eval(sprintf('!mkdir %s',outpth));
    end
    
    scanpth =  sprintf('',subject); % path to processed scans 
    
    for session = 1:nsessions
        fprintf('session: %02d \n',session);
        data = load(fullfile( fullfile(trialpth,sprintf('sub%02d',subject)),sprintf('run_%02d_optimization_def.mat',session)));
        
        famousonsets = data.onsets{1,1};
        unfamiliaronsets = data.onsets{1,2};
        scrambledonsets = data.onsets{1,3};
        rest = data.onsets{1,4};
        
        restidx=rest/2+1;
        famousidx = famousonsets/2+1;
        unfamiliaridx =  unfamiliaronsets/2+1;
       scrambledidx = scrambledonsets/2+1;
        
        allscans = cellstr(spm_select('FPList',fullfile(scanpth,'FMRI',sprintf('Run_%02d',session)),'^swafMR.*\.nii$'));%added a for slice timing alligned scans        cd(tmpscan);
     
        %special case for subject 10 
        if subject == 10 && session == 9 
            fprintf('test');
            famousidx = famousidx( find(famousidx < length(allscans)));
            unfamiliaridx = unfamiliaridx( find(unfamiliaridx < length(allscans)));
           scrambledidx =scrambledidx( find(scrambledidx < length(allscans)));
            restidx =restidx( find(restidx < length(allscans)));
        end
        
        
        
        restscanspth = allscans(restidx);
        famousscanspth = allscans(famousidx);
        unfamiliarscanspth = allscans(unfamiliaridx);
        scrambledscanspth = allscans(scrambledidx);
        
        restscans = zeros(length(restscanspth),79,95,79);
        
        for scan= 1:length(restscanspth)
            volume = spm_vol(restscanspth{scan,1});
            [intensities ,coordinates]=spm_read_vols(volume);
            restscans(scan,:,:,:)=intensities;
        end
        restmean = squeeze(mean(restscans,1));
        
        volume = spm_vol('smallbrainmask.nii'); %SPM brain mask 
        [braimaskintensities ,]=spm_read_vols(volume);
        brainmask = find(braimaskintensities == 0);
        
        
        for scan = 1: length(famousscanspth)
            volume = spm_vol(famousscanspth{scan,1});
            [intensities ,coordinates]=spm_read_vols(volume);
            pscvolume = ((intensities-restmean)./restmean)*100; % this may lead to naans which should be fixed the brain mask 
            
            %
            
            restzero = find(restmean == 0);
            pscvolume(restzero)=0;
            pscvolume( brainmask)=0;
            
            myvolume = struct('fname',fullfile(outpth,sprintf('subject_%02d_run_%02d_famous_%02d.nii',subject,session,scan)),'dim',volume.dim,'dt',volume.dt,'mat',volume.mat,'n',volume.n,'pinfo',volume.pinfo,'descrip','normalized');
            V=spm_write_vol(myvolume,pscvolume);
            
            
            
        end
        for scan = 1: length(scrambledscanspth)
            volume = spm_vol(scrambledscanspth{scan,1});
            [intensities ,coordinates]=spm_read_vols(volume);
            pscvolume = ((intensities-restmean)./restmean)*100; 
            
            
            restzero = find(restmean == 0);
            pscvolume(restzero)=0;
            pscvolume( brainmask)=0;
            
            myvolume =struct('fname',fullfile(outpth,sprintf('subject_%02d_run_%02d_scrambled_%02d.nii',subject,session,scan)),'dim',volume.dim,'dt',volume.dt,'mat',volume.mat,'n',volume.n,'descrip','normalized');
            V=spm_write_vol(myvolume,pscvolume);
            
        end
        for scan = 1: length(unfamiliarscanspth)
            volume = spm_vol(unfamiliarscanspth{scan,1});
            [intensities ,coordinates]=spm_read_vols(volume);
            pscvolume = ((intensities-restmean)./restmean)*100; 
            
            
            
            restzero = find(restmean == 0);
            pscvolume(restzero)=0;
            pscvolume( brainmask)=0;
            
            myvolume =struct('fname',fullfile(outpth,sprintf('subject_%02d_run_%02d_unfamiliar_%02d.nii',subject,session,scan)),'dim',volume.dim,'dt',volume.dt,'mat',volume.mat,'n',volume.n,'descrip','normalized');
            V=spm_write_vol(myvolume,pscvolume);
            
        end
        
    end
    
end
