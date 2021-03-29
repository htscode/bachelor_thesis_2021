%% for finding out better voxels
function bestffa = betterffa(currentffa,data)

sanityCheckNeatesMNI=[];
famousScansALLVoxelIntensity = [];
exfamousScansALLVoxelIntensity = [];
unfamiliarScansALLVoxelIntensity = [];
exunfamiliarScansALLVoxelIntensity = [];
scrambledScansALLVoxelIntensity = [];
exscrambledScansALLVoxelIntensity = [];

mnicoordinates = currentffa;

for scan = 1:length(allscans)
    % load scan
    volume = spm_vol(allscans{scan,1});
    % get intensity and coordinates of scan
    [intensities ,coordinates]=spm_read_vols(volume);
    inputmni = mnicoordinates;
    coordinatesVoxel=round(volume.mat\[inputmni 1]');
   
    idx=find(coordinates(1)==inputmni(1) & coordinates(2)==inputmni(2) & coordinates(3)==inputmni(3));
    
    voxelIntensity = intensities(coordinatesVoxel(1),coordinatesVoxel(2),coordinatesVoxel(3));
    mniCoordinatesUsedidx = sub2ind(volume.dim,coordinatesVoxel(1),coordinatesVoxel(2),coordinatesVoxel(3));
    mniCoordinatesUsed= coordinates(:,mniCoordinatesUsedidx);
   
    intensityComparison = [];
    associatedVoxels = [];
    for change = 1:3
        for dimension = 1:3
            if dimension == 1
                dim1change = -change;
            elseif dimension == 3
                dim1change = change;
            else
                dim1change = 0;
            end
            
            for dimension2 = 1:3
                if dimension2 == 1
                    dim2change = -change;
                elseif dimension2 == 3
                    dim2change = change;
                else
                    dim2change = 0;
                end
                for dimension3 = 1:3
                    if dimension3 == 1
                        dim3change = -change;
                    elseif dimension3 == 3
                        dim3change = change;
                    else
                        dim3change = 0;
                    end
                    associatedVoxels = [associatedVoxels;[coordinatesVoxel(1)+dim1change,coordinatesVoxel(2)+dim2change,coordinatesVoxel(3)+dim3change]];
                    intensityComparison(end+1) = intensities(coordinatesVoxel(1)+dim1change,coordinatesVoxel(2)+dim2change,coordinatesVoxel(3)+dim3change);
                    
                end
            end
            
        end
    end
    
    j = (scan-1)*2;
    if ismember(j,famousonsets)
        %famousscans(end+1) ={scan};
        %             famousscans(end+1) = j;
        %             famousScansVoxelIntensity(end+1) = voxelIntensity;
        famousScansALLVoxelIntensity(:,end+1)=intensityComparison(:);
        %famousScansALLVoxelIntensity=[famousScansALLVoxelIntensity(:),intensityComparison(:)];
    elseif ismember(j,unfamiliaronsets)
        %famousscans(end+1) ={scan};
        %unfamiliarscans(end+1) = j;
        %unfamiliarScansVoxelIntensity(end+1) = voxelIntensity;
        unfamiliarScansALLVoxelIntensity(:,end+1)=intensityComparison(:);
    elseif ismember(j,scrambledonsets)
        %famousscans(end+1) ={scan};
        %             scrambledscans(end+1) = j;
        %             scrambledScansVoxelIntensity(end+1) = voxelIntensity;
        scrambledScansALLVoxelIntensity(:,end+1)=intensityComparison(:);
    elseif ismember(j,exfamousonsets)
        %famousscans(end+1) ={scan};
        %             exfamousscans(end+1) = j;
        %             exfamousScansVoxelIntensity(end+1) =voxelIntensity;
        exfamousScansALLVoxelIntensity(:,end+1)=intensityComparison(:);
    elseif ismember(j,exunfamiliaronsets)
        %             exunfamiliarscans(end+1) = j;
        %             exunfamiliarScansVoxelIntensity(end+1) = voxelIntensity;
        exunfamiliarScansALLVoxelIntensity(:,end+1)=intensityComparison(:);
    elseif ismember(j,exscrambledonsets)
        %             exscrambledscans(end+1) = j;
        %             exscrambledScansVoxelIntensity(end+1) = voxelIntensity;
        exscrambledScansALLVoxelIntensity(:,end+1)=intensityComparison(:);
    end
    
end




for currentIntensitiy = 1:27*3
    meanface = mean(faceScansALLVoxelIntensity);
    stdface = std(faceScansALLVoxelIntensity);
    meanscrambled = mean(scrambledScansALLVoxelIntensity);
    stdcrambled = std(scrambledScansALLVoxelIntensity);
    %negative such that we can minimize
    %square
    myvoxeldifference = -(meanface - meanscrambled)^2;
    results{end+1}= [myvoxeldifference,meanface,meanscrambled,stdface,stdcrambled];
end

end