function [myvoxeldifference ,h,p,ci,stats,mniCoordinatesUsed,faceScansVoxelIntensity,scrambledScansVoxelIntensity,coordinates,famousscans,unfamiliarscans,scrambledscans]= voxeldifference(outpth,scanpth,subjects,mnicoordinates)
%%
famousscans = [];
unfamiliarscans =[];
scrambledscans = [];
exfamousscans = [];
exunfamiliarscans = [];
exscrambledscans = [];
restscans = [];

famousScansVoxelIntensity = [];
exfamousScansVoxelIntensity = [];
unfamiliarScansVoxelIntensity = [];
exunfamiliarScansVoxelIntensity = [];
scrambledScansVoxelIntensity = [];
exscrambledScansVoxelIntensity = [];

sanityCheckNeatesMNI=[];
famousScansALLVoxelIntensity = [];
exfamousScansALLVoxelIntensity = [];
unfamiliarScansALLVoxelIntensity = [];
exunfamiliarScansALLVoxelIntensity = [];
scrambledScansALLVoxelIntensity = [];
exscrambledScansALLVoxelIntensity = [];

for session = 1:9
    %load file
    data = load(fullfile(outpth,sprintf('run%02d_optimization_def.mat',session)));
    famousonsets = data.onsets{1,1};
    unfamiliaronsets = data.onsets{1,2};
    scrambledonsets = data.onsets{1,3};
    exfamousonsets = data.onsets{1,4};
    exunfamiliaronsets = data.onsets{1,5};
    exscrambledonsets = data.onsets{1,6};
    %select all scans
    pathtoscans= fullfile(scanpth,sprintf('Sub%02d',subjects),'FMRI',sprintf('Run_%02d',session));
    %load all paths to individual scans
    allscans = cellstr(spm_select('FPList',fullfile(scanpth,'FMRI',sprintf('Run_%02d',session)),'^swfMR.*\.nii$'));
    %%
   
    for scan = 1:length(allscans)
        % load scan 
        volume = spm_vol(allscans{scan,1});
        % get intensity and coordinates of scan 
        [intensities ,coordinates]=spm_read_vols(volume);
        inputmni = mnicoordinates;
        coordinatesVoxel=round(volume.mat\[inputmni 1]');
        %todo try else
        idx=find(coordinates(1)==inputmni(1) & coordinates(2)==inputmni(2) & coordinates(3)==inputmni(3));
        
        voxelIntensity = intensities(coordinatesVoxel(1),coordinatesVoxel(2),coordinatesVoxel(3));
        mniCoordinatesUsedidx = sub2ind(volume.dim,coordinatesVoxel(1),coordinatesVoxel(2),coordinatesVoxel(3));
        mniCoordinatesUsed= coordinates(:,mniCoordinatesUsedidx);
        
      
        j = (scan-1)*2;
        if ismember(j,famousonsets)
            %famousscans(end+1) ={scan};
            famousscans(end+1) = j;
            famousScansVoxelIntensity(end+1) = voxelIntensity;
            %famousScansALLVoxelIntensity(:,end+1)=intensityComparison(:);
            %famousScansALLVoxelIntensity=[famousScansALLVoxelIntensity(:),intensityComparison(:)];
        elseif ismember(j,unfamiliaronsets)
            %famousscans(end+1) ={scan};
            unfamiliarscans(end+1) = j;
            unfamiliarScansVoxelIntensity(end+1) = voxelIntensity;            
            %unfamiliarScansALLVoxelIntensity(:,end+1)=intensityComparison(:);
        elseif ismember(j,scrambledonsets)
            %famousscans(end+1) ={scan};
            scrambledscans(end+1) = j;
            scrambledScansVoxelIntensity(end+1) = voxelIntensity;            
            %scrambledScansALLVoxelIntensity(:,end+1)=intensityComparison(:);
        elseif ismember(j,exfamousonsets)
            %famousscans(end+1) ={scan};            
            exfamousscans(end+1) = j;
            exfamousScansVoxelIntensity(end+1) =voxelIntensity;            
            %exfamousScansALLVoxelIntensity(:,end+1)=intensityComparison(:); 
        elseif ismember(j,exunfamiliaronsets)            
            exunfamiliarscans(end+1) = j;
            exunfamiliarScansVoxelIntensity(end+1) = voxelIntensity;            
            %exunfamiliarScansALLVoxelIntensity(:,end+1)=intensityComparison(:); 
        elseif ismember(j,exscrambledonsets)            
            exscrambledscans(end+1) = j;
            exscrambledScansVoxelIntensity(end+1) = voxelIntensity;                 
            %exscrambledScansALLVoxelIntensity(:,end+1)=intensityComparison(:);
        end
    end
    
    
end


%% make a ttest to test significance
faceScansVoxelIntensity = [famousScansVoxelIntensity,unfamiliarScansVoxelIntensity];
meanfamous = mean(famousScansVoxelIntensity);
meanunfamiliar = mean(unfamiliarScansVoxelIntensity);
meanface = mean(faceScansVoxelIntensity);

meanscrambled = mean(scrambledScansVoxelIntensity);
%negative such that we can minimize
%square
myvoxeldifference = -(meanface - meanscrambled)^2;

[h,p,ci,stats] = ttest2(faceScansVoxelIntensity,scrambledScansVoxelIntensity);
 

end
