%% Exporting voxels 

path_to_image = 'C:\Users\hater\Documents\BA\faceall\face_association-test_z_FDR_0.01.nii'; %%neurosynth face file

volume=spm_vol(path_to_image) ;
% % get intensity and coordinates of scan
% find maximum 
[intensities ,coordinates]=spm_read_vols(volume);
[mall,ind] = max(intensities,[],'all','linear');

mniCoordinatesUsedidx =ind ;
mniCoordinatesUsed= coordinates(:,mniCoordinatesUsedidx);

% get more of a roi
% only 1% of the hightest


[highvalues,highvalueidx] = sort(intensities(:), 'descend');
onepercent = round(0.001 * ind);
onepercentidx = highvalueidx(1:onepercent);


roimnicord = coordinates(:,onepercentidx);
% exclude left hemisphere (x value < 0)
save('roimnicord.mat','roimnicord');

% to exclude left hemisphere...not necessary here 
% lefthemisphereidx = find(roimnicord (1,:)<0);
% roimnicord(:,lefthemisphereidx) = [];

% as the stimuli in this case are neutral and therefore might not have an
% as strong amygdala activation and to focus on primary areas i further
% decided to exclude the frontal cortex aka all frontal parts(this is quite rigid better would
% be to have these regions as rois and be more exact in the exclusion)
% cut at: -15   (range ist(90,-120)...210/2 =105 90-105 = -15  )


frontalindx = find(roimnicord (2,:)>-15);
roimnicord(:,frontalindx ) = [];


%large brain

emptybrain = zeros(size(bild));
vvoxelcodidx=zeros(1,size(roimnicord,2));
for cord = 1: length(roimnicord)
    voxelcordidx(cord)=find(coordinates(1,:)==roimnicord(1,cord) & coordinates(2,:)==roimnicord(2,cord) & coordinates(3,:)==roimnicord(3,cord));      
end

emptybrain(voxelcordidx)= 1;
path_to_image2 = ''; % load mprage image to get parameters

bild2=niftiread(path_to_image2);
volume2=spm_vol(path_to_image2) ;
[intensities2 ,coordinates2]=spm_read_vols(volume2);
%actual sizte

emptybrain2 = zeros(size(bild2));
voxelcordidx2=zeros(1,size(roimnicord,2));
for cord = 1: length(roimnicord)
    voxelcordidx2(cord)=find(coordinates2(1,:)==roimnicord(1,cord) & coordinates2(2,:)==roimnicord(2,cord) & coordinates2(3,:)==roimnicord(3,cord));      
end

emptybrain2(voxelcordidx2)= 1;



myvolume2 =struct('fname','smallmytest.nii','dim',volume2.dim,'dt',volume2.dt,'mat',volume2.mat,'n',[1,1],'descrip','testing visualization2');
V2=spm_write_vol(myvolume2,emptybrain2);

save( '', 'voxelcordidx2');
