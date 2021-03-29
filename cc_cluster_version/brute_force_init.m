function brute_force_init()
%% Find an optimal shift in time and monitor the mean squared difference of face and scrambled
%

%% clean
clear;
%% Set up pths
subject = 1; % put subject here
nsession = 9;

addpath(''); % path to scripts
addpath('');%spm path

% path to tsv files with trial definition
tsvpth = sprintf('...newtrial_definitions/sub%02d/',subject);
% path with the brute force script
thesispth = '';
% path to raw scans
scanpth = sprintf('.../data/Sub%02d/',subject);

%% Set up tmp
% use temporaty storage to optimize read and write opterations and therby
% time
% to do so all data and the scripts are copied to  /tmp and run there

tmppth= '/tmp';
folder ='/optimization';
% set up paths to create a folder structure in tmp
tmpfolder = fullfile(tmppth,folder);
tsvfolder = fullfile(tmpfolder,'/tsv/');
outfolder = fullfile(tmpfolder,'/out/');
tmpscan = fullfile(tmpfolder,'/scans/');

% create structure in tmp and copy trial data and script to there
if ~exist(tmpfolder)
    eval(sprintf('!mkdir %s',tmpfolder));
    eval(sprintf('!mkdir %s',outfolder));
    eval(sprintf('!mkdir %s',tsvfolder));
    
    eval(sprintf('!cp -R %s/. %s',tsvpth,tsvfolder));
    eval(sprintf('!cp -R %s/ %s',thesispth,tmpfolder));
    eval(sprintf('!mkdir %s',tmpscan));
    
    %cd('/tmp');
    
    for session = 1:nsession
        
        % copy data to tmp
        % select all scans (which have been before preprocessed with
        % slice_init, slice_timing_corrected_fmri
        allscans = cellstr(spm_select('FPList',fullfile(scanpth,'FMRI',sprintf('Run_%02d',session)),'^swafMR.*\.nii$'));%preprocessed fMRI scans
        cd(tmpscan)
        folder = sprintf('Run_%02d',session);
        eval(sprintf('!mkdir Run_%02d',session));
        
        % create folder for this run and copy the data
        for scan = 1:length(allscans)
            % to deal with cell structure
            pathtoscancell = allscans(scan);
            eval(sprintf('!cp %s %s',pathtoscancell{1},folder));
        end
    end
    cd('..');
end
fprintf('Set up tmp finished \n');
%% Starting brute force
% due to the nature of the script (using cd to access tmp) it can happen
% that the wrong version of brute_force is opened and thereby not run on
% tmp due to this a waiting loop was implemented

s = 1;
% use a folder only existent in tmp to make sure to be in tmp
path= 'trials/';
while s
    fprintf('in s \n');
    %tmp path 
    cd('/tmp/optimization/Thesis/');
    if exist(path) ~= 0
        fprintf('exists \n');
        s = 0;
    end
end

% start brute force
brute_force_ROI(subject,tsvfolder,outfolder,tmpscan);
end
