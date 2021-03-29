function brute_force_ALL(subject,tsvfolder,outfolder,tmpscan)
%% Function to calculate mean square difference for the conditions facs and scrambled in a certain boundary
%

%% Set parameters
%set time scale
timescale = 0.1; %original dataset is in  seconds,seconds = 1
% upper and lowerboundary in seconds
lowerboundary = 0; % starting point of search
upperboundary = 10; % end point of search


nsessions = 9; %number of sessions/runs


i = lowerboundary;

%%  set up paths

tsvpth = tsvfolder;
outpth = outfolder;
scanpth = tmpscan;

% path to save to
savepth= '';

% add spm to the path to make sure spm functions can be used
addpath('');

%% pre allocate space

arraysize = 1+ (upperboundary-lowerboundary)/timescale;

timearray = zeros(1,arraysize);
results = zeros(arraysize,79,95,79);

faceintensities = zeros(arraysize,79,95,79);
nfaceintensities = zeros(1,arraysize);

scrambledintensities = zeros(arraysize,79,95,79);
nscrambledintensities = zeros(1,arraysize);

face = cell(1,arraysize);
scrambled =  cell(1,arraysize);
face{1,arraysize} = [];
scrambled{1,arraysize} = [];

%% Calculate mean squared difference of conditions at all shifttimes

while i <= upperboundary
    shift = i;
    index = round( i/timescale +1);
    fprintf('%02d \n',i);
    
    % shift trials and create a new trial definiton accoding to current
    % shift
    shifttrialsnew(tsvpth,outpth,subject,nsessions,shift);
    
    % calculate mean squared difference of face and scrambled stimuli at
    % current shift
    [myvoxeldifference,faceScansVoxelIntensity,scrambledScansVoxelIntensity,coordinates,famousscans,unfamiliarscans,scrambledscans,famousscanplaces,unfamiliarscanplaces, scrambledscanplaces]= allvoxeldiffnew(outpth,scanpth);
    
    % save all mean squared difference over timeshifts
    results(index,:,:,:)= myvoxeldifference;
    
    % keep track of time/timeshift for plotting
    timearray(index)=i;
    
    % keep track of some supplementary information
    faceintensities(index,:,:,:) = mean(faceScansVoxelIntensity,1);
    faceintsize = size(faceScansVoxelIntensity);
    nfaceintensities(index) = faceintsize(1);
    scrambledintensities(index,:,:,:) = mean(scrambledScansVoxelIntensity,1);
    scrambledintsize = size(scrambledScansVoxelIntensity);
    nscrambledintensities = scrambledintsize(1);
    
    % keep raw information of face and voxel intensities for later
    % calculations
    face{index} = {faceScansVoxelIntensity};
    scrambled{index} = {scrambledScansVoxelIntensity};
    
    i = i+timescale;
end

fprintf('Calculations finished \n');

%% Save results permanantly

% if not existent create folder for saving
if ~exist(savepth)
    eval(sprintf('!mkdir %s',savepth));
end

% Save information into a dated folder in a mat file
if  i >= upperboundary
    cd(savepth);
    
    % create a folder with the current date to make sure no problems occur
    % when running something multiple times
    
    t = datetime('now');
    strt= datestr(t,30);
    resultsfoldername = strcat(strt,'/');
    
    % create a file which via its filename indicates the parameters of the
    % current run
    if ~exist(resultsfoldername)
        eval(sprintf('!mkdir %s',fullfile(savepth,resultsfoldername)));
        cd(resultsfoldername)
        filename = sprintf('brute_force_p%02d_mni[%02d,%02d,%02d]_%.4fs_t%02d-%02d.mat',subject,mnicoordinates(1),mnicoordinates(2),...
            mnicoordinates(3), timescale,lowerboundary, upperboundary);
        save( filename, 'results', 'timearray', 'faceintensities','scrambledintensities','nfaceintensities','nscrambledintensities','face','scrambled');
    end
    cd(savepth);
    fprintf('Everything was saved \n');
end
end
