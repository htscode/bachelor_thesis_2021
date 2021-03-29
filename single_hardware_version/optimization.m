

function myvoxeldifference = optimization(x)
%function [h,p,ci,stats,mniCoordinatesUsed,faceScansVoxelIntensity,scrambledScansVoxelIntensity,coordinates,famousscans,unfamiliarscans,scrambledscans,famous,scrambled,unfamiliar,results,associatedVoxels] = optimization(x)
fprintf('oooooooooooooooooooooooooooo \n');
%% paths

tsvpth ='';%trial definition
outpth = '';
addpath('');%spm path
%subjects =[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16];
subjects=15;
%% shift
shift = x;
nsessions = 9;
[famous,unfamiliar,scrambled,exfamous,exunfamiliar,exscrambled] = shifttrials(tsvpth,outpth,subjects,nsessions,shift);

%% path set up
% things needed: path to all scans
% old trial definition = tsvs
scanpth = '';
mnicoordinates = [38, -48,-18]; %h = 1 p =0.000062964 d:-1.98 

subjects=15;
[myvoxeldifference ,h,p,ci,stats,mniCoordinatesUsed,faceScansVoxelIntensity,scrambledScansVoxelIntensity,coordinates,famousscans,unfamiliarscans,scrambledscans]= voxeldifference(outpth,scanpth,subjects,mnicoordinates);



end
