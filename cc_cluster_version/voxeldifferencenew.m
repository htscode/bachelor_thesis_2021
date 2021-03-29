
function [myvoxeldifference ,h,p,ci,stats,mniCoordinatesUsed,faceScansVoxelIntensity,scrambledScansVoxelIntensity,coordinates,famousscans,unfamiliarscans,scrambledscans]= voxeldifferencenew(outpth,scanpth,subjects,mnicoordinates)
%% Initialise arrays

sizecounters = zeros(6,1);

famousscans = zeros(208,1);
unfamiliarscans =zeros(208,1);
scrambledscans = zeros(208,1);
exfamousscans = zeros(208,1);
exunfamiliarscans = zeros(208,1);
exscrambledscans =zeros(208,1);


famousScansVoxelIntensity = zeros(208,1);
unfamiliarScansVoxelIntensity = zeros(208,1);
scrambledScansVoxelIntensity = zeros(208,1);

exfamousScansVoxelIntensity = zeros(208,1);
exunfamiliarScansVoxelIntensity = zeros(208,1);
exscrambledScansVoxelIntensity = zeros(208,1);

%% Extract intensities 

for session = 1:9
    %% load trials and scans
    % load file
    % this trial defintion was create before via shift trials
    data = load(fullfile(outpth,sprintf('run%02d_optimization_def.mat',session)));
    famousonsets = data.onsets{1,1};
    unfamiliaronsets = data.onsets{1,2};
    scrambledonsets = data.onsets{1,3};
    exfamousonsets = data.onsets{1,4};
    exunfamiliaronsets = data.onsets{1,5};
    exscrambledonsets = data.onsets{1,6};
    
    %select all scans of current session
    allscans = cellstr(spm_select('FPList',fullfile(scanpth,sprintf('Run_%02d',session)),'^swafMR.*\.nii$')); %a for slice correction
    %% get inensities 
    
    for scan = 1:length(allscans)
        % load scan 
        volume = spm_vol(allscans{scan,1});
        % get intensity and coordinates of scan 
        [intensities ,coordinates]=spm_read_vols(volume);
        inputmni = mnicoordinates;
        
        % this will find the nearest voxel to use 
        coordinatesVoxel=round(volume.mat\[inputmni 1]');
        
        % calculate intensity of this voxel         
        voxelIntensity = intensities(coordinatesVoxel(1),coordinatesVoxel(2),coordinatesVoxel(3));
        
        % get the mni coordinates of the used voxel center         
        mniCoordinatesUsedidx = sub2ind(volume.dim,coordinatesVoxel(1),coordinatesVoxel(2),coordinatesVoxel(3));
        mniCoordinatesUsed= coordinates(:,mniCoordinatesUsedidx);
        
        % calculate scan onset
        j = (scan-1)*2;
        
        % order according to condition and save scan onset and Intensitiy 
        if ismember(j,famousonsets)
            sizecounters(1) = sizecounters(1) +1;
            famousscans(sizecounters(1)) = j;
            famousScansVoxelIntensity(sizecounters(1)) = voxelIntensity;
        elseif ismember(j,unfamiliaronsets)
            sizecounters(2) = sizecounters(2) +1;
            unfamiliarscans(sizecounters(2)) = j;
            unfamiliarScansVoxelIntensity(sizecounters(2)) = voxelIntensity;        
        elseif ismember(j,scrambledonsets)
            sizecounters(3) = sizecounters(3) +1;
            scrambledscans(sizecounters(3)) = j;
            scrambledScansVoxelIntensity(sizecounters(3)) = voxelIntensity;           
        elseif ismember(j,exfamousonsets) 
            sizecounters(4) = sizecounters(4) +1;
            exfamousscans(sizecounters(4)) = j;
            exfamousScansVoxelIntensity(sizecounters(4)) =voxelIntensity;           
        elseif ismember(j,exunfamiliaronsets)    
            sizecounters(5) = sizecounters(5) +1;
            exunfamiliarscans(sizecounters(5)) = j;
            exunfamiliarScansVoxelIntensity(sizecounters(5)) = voxelIntensity;          
        elseif ismember(j,exscrambledonsets)  
            sizecounters(6) = sizecounters(6) +1;
            exscrambledscans(sizecounters(6)) = j;
            exscrambledScansVoxelIntensity(sizecounters(6)) = voxelIntensity;          
        end
        
    end
    
    
end
fprintf('Finished ordering intensities \n');
%% shrink arrays to appropriate size


famousscans = famousscans(1:sizecounters(1),1);
unfamiliarscans =unfamiliarscans(1:sizecounters(2),1);
scrambledscans = scrambledscans(1:sizecounters(3),1);

exfamousscans = exfamousscans(1:sizecounters(4),1);
exunfamiliarscans = exunfamiliarscans(1:sizecounters(5),1);
exscrambledscans = exscrambledscans(1:sizecounters(6),1);

famousScansVoxelIntensity = famousScansVoxelIntensity(1:sizecounters(1),1);
unfamiliarScansVoxelIntensity = unfamiliarScansVoxelIntensity(1:sizecounters(2),1);
scrambledScansVoxelIntensity = scrambledScansVoxelIntensity(1:sizecounters(3),1);

exfamousScansVoxelIntensity = exfamousScansVoxelIntensity(1:sizecounters(4),1);
exunfamiliarScansVoxelIntensity = exunfamiliarScansVoxelIntensity(1:sizecounters(5),1);
exscrambledScansVoxelIntensity = exscrambledScansVoxelIntensity(1:sizecounters(6),1);


%% Calculate mean squared difference at ffa

% combine unfamiliar and famous condition to face condition
faceScansVoxelIntensity = [famousScansVoxelIntensity;unfamiliarScansVoxelIntensity];

% calculate mean for face condition
meanface = mean(faceScansVoxelIntensity);

% calculate mean for scrambled condition 
meanscrambled = mean(scrambledScansVoxelIntensity);

% square to intensify difference
% negative to be useable with optimization algorithms 
myvoxeldifference = -(meanface - meanscrambled)^2;

% make a ttest
[h,p,ci,stats] = ttest2(faceScansVoxelIntensity,scrambledScansVoxelIntensity);

fprintf('Finished calcualting mean difference \n ')
end
