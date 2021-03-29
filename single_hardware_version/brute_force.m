
timescale=0.1; %original dataset is in  seconds,seconds = 1 
lowerboundary =0; %starting point of search
upperboundary =10;  %end point of search

results = [];
timearray = []; 
faceintesities = [];
scrambledintesities = [];
nfaceintensities = [];
nscrambledintensities = [];
i = lowerboundary;


mnicoordinates = [42,-50,-24]; 
subjects=15;

tsvpth =''; %trial definition
outpth = '';
addpath('');% add spm
addpath('');% path to scripts
scanpth = '';% path to raw scans

nsessions = 9;


while i <= upperboundary 
    shift = i;
    shifttrials(tsvpth,outpth,subjects,nsessions,shift);
    [myvoxeldifference ,h,p,ci,stats,mniCoordinatesUsed,faceScansVoxelIntensity,scrambledScansVoxelIntensity,coordinates,famousscans,unfamiliarscans,scrambledscans]= voxeldifference(outpth,scanpth,subjects,mnicoordinates);
    results(end+1)= myvoxeldifference;
    timearray(end+1)=i;
    faceintesities(end+1) = mean(faceScansVoxelIntensity);
    nfaceintensities(end+1) = length(faceScansVoxelIntensity);
    scrambledintesities(end+1) = mean(scrambledintesities);
    nscrambledintensities(end+1) = length(scrambledintesities);
    i = i+timescale;
end 


filename = fullfile(outpth,sprintf('brute_force_%02d-%02d.mat',lowerboundary, upperboundary));
save( filename, 'durations', 'names', 'onsets');
   