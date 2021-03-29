function slice_init()
%% Initialise fMRI processing which includes slice time correction 
% Sets up all paths as well as a tmp folder to allow efficient computing
% Will automatically start sline_timing_corrected_fMRI.m  which completes
% fMRI processing including first level statistic
% In the end all results are copied to a chosen destination in a folder
% which indicated time and date of program execution
%
% Following field need to be set manually 
% paths: rawpth, scrpth, outpth, savepth 
% subjects: which subjects should be processed
% nrun:  number of runs a subject finished
%
% Note the current code is set up for a linux system, when a windows system
% is used cp! must be changed to xcopy 
%
% rough runtime estimate for one subject:  
% Usage as batchscript: yes
%% Set up SPM 

% add and initialise spm for fmri
addpath(''); %spm12
spm_jobman('initcfg');
spm('defaults', 'fMRI');

% set spm defaults
global defaults;
% allows for higher memory usage 
defaults.stats.maxmem = 2^33;
defaults.stats.resmem   = true;
% allows spm to run from the command line (without gui)
defaults.cmdline = true;

%% Set up paths

% Path to raw data
rawpth = '';   
% Patch to SPM (batch) scripts 
scrpth = '';  % <--- INSERT PATH TO WHERE YOU DOWNLOADED SPM12 BATCH SCRIPTS
% Where the results should be saved 
savepth = '';

fprintf('Paths were configured \n');
%% Assign processing variables

% subject(s) which should be processed 
subs =[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16];
% number of executed runs per subject
nrun = 9 ;

nsub =  length(subs); % enter the number of runs here
subdir={}; 

fprintf('Processesing variables were set \n');
%% Set up tmp (tempory file system on RAM) for faster computation

% folder in which data is held temporatily within /tmp 
folder = '/slice';
% path to tmp 
tmppth='/tmp';
% set up folder system in tmp 
tmpfolder = fullfile(tmppth,folder);
outfolder = fullfile(tmpfolder,'/out/');

% if not existing set up folder and copy scripts to there
if ~exist(tmpfolder)
    	eval(sprintf('!cp -R %s %s',scrpth,tmppth)); 
end

% open the before created folder
cd(tmpfolder);

% create an output folder
if ~exist(outfolder)
    	 eval(sprintf('!mkdir %s',outfolder));
end

% open the before created folder 
cd(outfolder)

% for every subject create a subfolder
for s = 1:nsub
    subdir{s}  = sprintf('Sub%02d',subs(s)); 
    fullsubdir = fullfile(outfolder,subdir{s});
    if ~exist(fullsubdir)
    	eval(sprintf('!mkdir %s',fullsubdir)); 
    end   
end

% copy raw data for every participant to tmp 

% copy functional data
for s = 1:nsub
    fullsubdir = fullfile(outfolder,subdir{s});
    fullsubfmridir = fullfile(fullsubdir,'FMRI');
    if ~exist(fullsubfmridir)
    	eval(sprintf('!mkdir %s',fullsubfmridir)); 
        eval(sprintf('!cp -r %s/* %s',fullfile(rawpth,subdir{s},'BOLD'),fullsubfmridir)); 
    end    
end

% copy structural data 
for s = 1:nsub
    fullsubdir = fullfile(outfolder,subdir{s});
    fullsubmridir = fullfile(fullsubdir,'SMRI');
    thepath = fullfile(rawpth,subdir{s},'T1');
    if ~exist(fullsubmridir)
    	eval(sprintf('!mkdir %s',fullsubmridir)); 
        eval(sprintf('!cp %s/* %s',fullfile(rawpth,subdir{s},'T1'),fullsubmridir)); 
   end    
end

fprintf('Tmp was set up \n');
%% Start processing script

% make sure to be in the right folder to use the correct version of the
% script and enable optimal computing 

cd(tmpfolder);
slice_timing_corrected_fmri;

fprintf('Processing was completed \n');
%% Copy the data from /tmp to a long(er) time storage

% leave tmp 
cd(savepth);

% get curret date and time and set up a folder to make sure no duplicates
% exist 
t = datetime('now');
strt= datestr(t,30);
resultsfoldername = strcat(strt,'/');

% copy everything to this folder 
if ~exist(resultsfoldername)
    	eval(sprintf('!mkdir %s',fullfile(savepth,resultsfoldername)));
        cd(outfolder)
        me= sprintf('!cp -r * %s',outfolder,fullfile(savepth,resultsfoldername));
        eval(me);
end

% make sure we left tmp 
cd(savepth);
fprintf('Everything was copied to storage \n ');
end 
