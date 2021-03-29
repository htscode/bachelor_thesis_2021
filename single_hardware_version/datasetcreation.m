allints = {};
alllabels = {};
alltest = {};
%test = ones(79,95,79);

outpth = ''; % path to trial definitons
addpath(''); %spm path

addpath('')% path to scripts

scanpth = ''; %scans
subjects=15;
nsessions = 1;
myshift = 5.2;
for run =1:9
    %get scans
    session= run;
    allscans = cellstr(spm_select('FPList',fullfile(scanpth,'FMRI',sprintf('Run_%02d',session)),'^swafMR.*\.nii$'));
   
    %%
    data = load(fullfile(outpth,sprintf('run%02d_optimization_def.mat',session)));
    facescanstarts =  data.onsets{1,1};
    unfamiliarscanstarts = data.onsets{1,2};
    scramblescanstarts = data.onsets{1,3};
    for scan = 1:length(allscans)
        % load scan 
           good = 0;
        volume = spm_vol(allscans{scan,1});
        % get intensity and coordinates of scan 
        [intensities ,coordinates]=spm_read_vols(volume);
        scanonset = scan-1;
        if ismember(scanonset,facescanstarts )
            label = 'face';%'famous';
            good = 1;
        elseif ismember(scanonset,unfamiliarscanstarts)
            label = 'face';% 'unfamiliar';
               good = 1;
        elseif ismember(scanonset, scramblescanstarts )
            label = 'scrambled';
              good = 1;
        end
        if good 
            dims = size(intensities);
            allints{scan} = intensities; 
            alllabels{scan} = label;
        end 
    end    
    alllabels =  alllabels(~cellfun('isempty',alllabels));
    allints =   allints(~cellfun('isempty', allints));
     filename = fullfile(outpth,sprintf('run%02ddataset.mat',session));
     save( filename, 'allints', 'alllabels');

%

end