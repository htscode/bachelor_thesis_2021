%% NORMALIZE
% normalize to PSC
% apply brain mask
% rename so that trial defintions is no longer needed

outpth = '';

scanpth = ''; %path to scans
%for each run
nsessions= 9;
subject=15;
for session = 1:nsessions
 fprintf('session: %02d \n',session);
 data = load(fullfile(outpth,sprintf('run%02d_optimization_def.mat',session)));
    famousonsets = data.onsets{1,1};
    unfamiliaronsets = data.onsets{1,2};
    scrambledonsets = data.onsets{1,3};
    rest = data.onsets{1,4};
    
    restidx=rest/2+1;
    famousidx = famousonsets/2+1;
    unfamiliaridx =  unfamiliaronsets/2+1;
    scrambledix = scrambledonsets/2+1;
    pathtoscans= fullfile(scanpth,sprintf('Sub%02d',subject),'FMRI',sprintf('Run_%02d',session));
    allscans = cellstr(spm_select('FPList',fullfile(scanpth,'Sub15','FMRI',sprintf('Run_%02d',session)),'^swafMR.*\.nii$'));
    
    restscanspth = allscans(restidx); 
    famousscanspth = allscans(famousidx);
    unfamiliarscanspth = allscans(unfamiliaridx);
    scrambledscanspth = allscans(scrambledix);
    
    restscans = zeros(length(restscanspth),79,95,79);
    for scan= 1:length(restscanspth)
        volume = spm_vol(restscanspth{scan,1});        
        [intensities ,coordinates]=spm_read_vols(volume);
        restscans(scan,:,:,:)=intensities;
    end
     restmean = squeeze(mean(restscans,1)); 
     %apply binariesed spm brain mask 
     volume = spm_vol('');        % binary brain mask 
     [braimaskintensities ,]=spm_read_vols(volume);
     brainmask = find(braimaskintensities == 0);
     
    
     
    for scan = 1: length(famousscanspth)      
        volume = spm_vol(famousscanspth{scan,1});  
        [intensities ,coordinates]=spm_read_vols(volume);
        pscvolume = ((intensities-restmean)./restmean)*100; %NANs possible

        %
        
        restzero = find(restmean == 0);
        pscvolume(restzero)=0;
        pscvolume( brainmask)=0;
        
        myvolume =struct('fname',sprintf('',subject,session,scan),'dim',volume.dim,'dt',volume.dt,'mat',volume.mat,'n',volume.n,'pinfo',volume.pinfo,'descrip','normalized');
        V=spm_write_vol(myvolume,pscvolume);    
        
     
        
    end  
    for scan = 1: length(scrambledscanspth)      
        volume = spm_vol(scrambledscanspth{scan,1});  
        [intensities ,coordinates]=spm_read_vols(volume);
        pscvolume = ((intensities-restmean)./restmean)*100; 
      
        restzero = find(restmean == 0);
        pscvolume(restzero)=0;
        pscvolume( brainmask)=0;
        
        myvolume =struct('fname',sprintf('',subject,session,scan),'dim',volume.dim,'dt',volume.dt,'mat',volume.mat,'n',volume.n,'descrip','normalized');
        V=spm_write_vol(myvolume,pscvolume);      
        
    end  
    for scan = 1: length(unfamiliarscanspth)      
        volume = spm_vol(unfamiliarscanspth{scan,1});  
        [intensities ,coordinates]=spm_read_vols(volume);
        pscvolume = ((intensities-restmean)./restmean)*100; 

       
        restzero = find(restmean == 0);
        pscvolume(restzero)=0;
        pscvolume( brainmask)=0;
        
        myvolume =struct('fname',sprintf('',subject,session,scan),'dim',volume.dim,'dt',volume.dt,'mat',volume.mat,'n',volume.n,'descrip','normalized');
        V=spm_write_vol(myvolume,pscvolume);      
        
    end  

end 


