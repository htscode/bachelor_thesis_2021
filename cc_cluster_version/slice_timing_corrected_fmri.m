
%% Set up SPM 
addpath(''); %spm 12
spm_jobman('initcfg');
spm('defaults', 'fMRI');

global defaults;
defaults.stats.maxmem = 2^33;
defaults.stats.resmem   = true;
defaults.cmdline = true;

fprintf('In fMRI preprocessing algorithm');

for s = 1:nsub

    % go to FMRI folder of a subject s
    swd = fullfile(outfolder,subdir{s},'FMRI');
    cd(swd);
    
    %% Preprocessing
    % slice time correction
    % realign
    % normalise and segment
    % Coregister
    % Smooth
    % resultisng nii's: ^swafMR.*\.nii
    
    % batch file
    jobfile = fullfile(tmpfolder,'slice_timing_corrected_fmri_job.m');
    
    % define inputs for spm job
    inputs  = cell(nrun+2,1);
    crun=1;
   for r = 1:nrun
       % raw images 
       inputs{r,crun} = cellstr(spm_select('FPList',fullfile(outfolder,subdir{s},'FMRI',sprintf('Run_%02d',r)),'^fMR.*\.nii$'));
   end   
   
   % structural T1 image
   inputs{10,crun} = cellstr(spm_select('FPList',fullfile(outfolder,subdir{s},'SMRI'),'^mprage.*\.nii$'));
   inputs{11,crun} = cellstr(spm_select('FPList',fullfile(outfolder,subdir{s},'SMRI'),'^mprage.*\.nii$'));
   spm_jobman('serial', jobfile, '', inputs{:}); 
   
    jobfile = fullfile(tmpfolder,'batch_stats_fmri_job.m');
    %% Statistics
    
    inputs = cell(nrun*3+1,1);
    index = 2; 
    
    %define satistics  path 
    statspath = fullfile(swd,'Stats');
    if ~exist(statspath)
    	eval(sprintf('!mkdir %s',statspath)); 
    end
    
    % define inputs for spm job
    inputs{1} = {fullfile(swd,'Stats')}; 
    
    % select the files for all sessions
    for session= 1:nrun       
        % select processed scans
        inputs{index} = cellstr(spm_select('FPList',fullfile(outfolder,subdir{s},'FMRI',sprintf('Run_%02d',session)),'^swafMR.*\.nii$')); 
        % select trial description
        inputs{index+1} = cellstr(fullfile(outfolder,subdir{s},'FMRI','Trials',sprintf('run_%02d_spmdef.mat',session)));
        % select extra regressors
        inputs{index+2} = cellstr(spm_select('FPList',fullfile(outfolder,subdir{s},'FMRI',sprintf('Run_%02d',session)),'^rp.*\.txt$')); 
        index = index+3;
    end


    spm_jobman('serial', jobfile, '', inputs{:});
end

