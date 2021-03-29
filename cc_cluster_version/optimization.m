

function myvoxeldifference = optimization(x)
fprintf('oooooooooooooooooooooooooooo \n');
fprintf('Starting FFA computations \n');
%subject =15;
%% paths

paths = load(''); %paths to file with essential paths 
tsvpth = paths.tsvfolder;
outpth = paths.outfolder;
scanpth = paths.tmpscan;
addpath('');%spm
subject=16;
%%
shift = x;
nsessions = 9;
[famous,unfamiliar,scrambled,exfamous,exunfamiliar,exscrambled] = shifttrials(tsvpth,outpth,subject,nsessions,shift);

fprintf('Calculated trials with new shift \n');

%% path set up
mnicoordinates = [38, -48,-18]; 
[myvoxeldifference ,h,p,ci,stats,mniCoordinatesUsed,faceScansVoxelIntensity,scrambledScansVoxelIntensity,coordinates,famousscans,unfamiliarscans,scrambledscans]= voxeldifference(outpth,scanpth,subject,mnicoordinates);



end
