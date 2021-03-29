
addpath('');% path to functions
%% shift files to tmp 
addpath(''); %spm
subject=15;
tsvpth = sprintf('',subject); %tsvfiles
outpth = sprintf('',subject); %data 

thesispth = ''; %path to other scripts
scanpth = sprintf('',subject); %fMRI scans
folder ='/optimization';
nsession=9;
%% Set up tmp
tmppth= '/tmp';
tmpfolder = fullfile(tmppth,folder);
tsvfolder = fullfile(tmpfolder,'/tsv/');
outfolder = fullfile(tmpfolder,'/out/');
tmpscan = fullfile(tmpfolder,'/scans/');
if ~exist(tmpfolder)
    	%eval(sprintf('!cp -R %s %s',scanpth,tmppth)); 
        eval(sprintf('!mkdir %s',tmpfolder));
        eval(sprintf('!mkdir %s',outfolder));
        eval(sprintf('!mkdir %s',tsvfolder));
        
        eval(sprintf('!cp -R %s/. %s',tsvpth,tsvfolder));
        eval(sprintf('!cp -R %s/. %s',outpth,outfolder));  
        eval(sprintf('!cp -R %s/ %s',thesispth,tmpfolder)); 
        eval(sprintf('!mkdir %s',tmpscan)); 
    %select all scans
    for session =1:nsession
        pathtoscans= fullfile(scanpth,sprintf('Sub%02d',subject),'FMRI',sprintf('Run_%02d',session));
        %load all paths to individual scans
        allscans = cellstr(spm_select('FPList',fullfile(scanpth,'FMRI',sprintf('Run_%02d',session)),'^swfMR.*\.nii$'));
        cd(tmpscan);
        folder = sprintf('Run_%02d',session);
        eval(sprintf('!mkdir Run_%02d',session)); 
        %cd(sprintf('Run_%02d',session));
        for scan = 1:length(allscans)
            pathtoscancell =allscans(scan);
             eval(sprintf('!cp %s %s',pathtoscancell{1},folder)); 
        end    
        %cd('..');
    end 
    cd('..');
end

filename ='/tmp/paths.mat';
save( filename, 'tsvfolder', 'outfolder', 'tmpscan');
% 
cd(tmpfolder);

addpath('/tmp/optimization/Thesis');

 fprintf('Tmp was set up');


options = optimoptions(@simulannealbnd,'OutputFcn',@outfun,'MaxTime',3600,'TemperatureFcn',@temperaturefast, 'PlotFcn',{@saplotbestf,@saplotbestx,@saplotf,@saplotx,@saplotstopping,@saplottemperature});
%annealing 
[x,fval,exitFlag,output]=simulannealbnd(@optimization,7.25,4,10,options);

