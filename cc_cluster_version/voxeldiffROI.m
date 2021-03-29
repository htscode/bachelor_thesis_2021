function [myvoxeldifference,faceScansVoxelIntensity,scrambledScansVoxelIntensity,coordinates,famousscans,unfamiliarscans,scrambledscans,famousscanplaces,unfamiliarscanplaces, scrambledscanplaces]= voxeldiffROI(outpth,scanpth,roiidx,roisize )
%%
nsession = 9;


sizecounters = zeros(6,1);

famousscans = zeros(208,1);
unfamiliarscans =zeros(208,1);
scrambledscans = zeros(208,1);
exfamousscans = zeros(208,1);
exunfamiliarscans = zeros(208,1);
exscrambledscans =zeros(208,1);

famousScansVoxelIntensity = zeros(208,roisize);
unfamiliarScansVoxelIntensity = zeros(208,roisize);
scrambledScansVoxelIntensity = zeros(208,roisize);

exfamousScansVoxelIntensity = zeros(208,roisize);
exunfamiliarScansVoxelIntensity = zeros(208,roisize);
exscrambledScansVoxelIntensity = zeros(208,roisize );




famousscanplaces = string.empty ;
unfamiliarscanplaces = string.empty;
scrambledscanplaces = string.empty;






for session = 1:nsession
    %load file
    fprintf('session: %02d \n ',session);
    data = load(fullfile(outpth,sprintf('run%02d_optimization_def.mat',session)));
    famousonsets = data.onsets{1,1};
    unfamiliaronsets = data.onsets{1,2};
    scrambledonsets = data.onsets{1,3};
    exfamousonsets = data.onsets{1,4};
    exunfamiliaronsets = data.onsets{1,5};
    exscrambledonsets = data.onsets{1,6};
    %select all scans
    %pathtoscans= fullfile(scanpth,sprintf('Run_%02d',session));
    %load all paths to individual scans
    allscans = cellstr(spm_select('FPList',fullfile(scanpth,sprintf('Run_%02d',session)),'^swafMR.*\.nii$')); %a for slice correction
    %%?? unsicher
    %%
   
    for scan = 1:length(allscans)
        % load scan 
        volume = spm_vol(allscans{scan,1});
        % get intensity and coordinates of scan 
        [intensities ,coordinates]=spm_read_vols(volume);
        
        
         rointensities=intensities(roiidx);
 
      
        j = (scan-1)*2;
        if ismember(j,famousonsets)
            sizecounters(1) = sizecounters(1) +1;
            famousscans(sizecounters(1)) = j;
            famousScansVoxelIntensity(sizecounters(1),:) = rointensities;
        elseif ismember(j,unfamiliaronsets)
           sizecounters(2) = sizecounters(2) +1;
            unfamiliarscans(sizecounters(2)) = j;
            unfamiliarScansVoxelIntensity(sizecounters(2),:) = rointensities;  
        elseif ismember(j,scrambledonsets)
           sizecounters(3) = sizecounters(3) +1;
            scrambledscans(sizecounters(3)) = j;
            scrambledScansVoxelIntensity(sizecounters(3),:) = rointensities; 
        elseif ismember(j,exfamousonsets)
            sizecounters(4) = sizecounters(4) +1;
            exfamousscans(sizecounters(4)) = j;
            exfamousScansVoxelIntensity(sizecounters(4),:) = rointensities;   
        elseif ismember(j,exunfamiliaronsets)            
            sizecounters(5) = sizecounters(5) +1;
            exunfamiliarscans(sizecounters(5)) = j;
            exunfamiliarScansVoxelIntensity(sizecounters(5),:) = rointensities;    
        elseif ismember(j,exscrambledonsets)            
            sizecounters(6) = sizecounters(6) +1;
            exscrambledscans(sizecounters(6)) = j;
            exscrambledScansVoxelIntensity(sizecounters(6),:) = rointensities;   
        end
        
    end
    
    
end
%% shrink


famousscans = famousscans(1:sizecounters(1),1);
unfamiliarscans = unfamiliarscans(1:sizecounters(2),1);
scrambledscans = scrambledscans(1:sizecounters(3),1);

exfamousscans = exfamousscans(1:sizecounters(4),1);
exunfamiliarscans = exunfamiliarscans(1:sizecounters(5),1);
exscrambledscans = exscrambledscans(1:sizecounters(6),1);

famousScansVoxelIntensity = famousScansVoxelIntensity(1:sizecounters(1),:);
unfamiliarScansVoxelIntensity = unfamiliarScansVoxelIntensity(1:sizecounters(2),:);
scrambledScansVoxelIntensity = scrambledScansVoxelIntensity(1:sizecounters(3),:);

exfamousScansVoxelIntensity = exfamousScansVoxelIntensity(1:sizecounters(4),:);
exunfamiliarScansVoxelIntensity = exunfamiliarScansVoxelIntensity(1:sizecounters(5),:);
exscrambledScansVoxelIntensity = exscrambledScansVoxelIntensity(1:sizecounters(6),:);



%% for finding out better voxels 

faceScansVoxelIntensity =cat(1,famousScansVoxelIntensity,unfamiliarScansVoxelIntensity);


meanface = mean(faceScansVoxelIntensity,1);

meanscrambled = mean(scrambledScansVoxelIntensity,1);
% %negative such that we can minimize
% %square entries
myvoxeldifference = squeeze(-(meanface - meanscrambled).^2);


end
