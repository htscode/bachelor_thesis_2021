# bachelor_thesis_2021
This is the repository for my bachelor thesis with the title "Processing fast event-related fMRI for artificial neural network applications". The thesis itself can be found under **Processing_fast_event_related_fMRI_data_for_Artificial_Neural_Network_Applications.pdf**

## MAIN PIPELINE 

Following the script of the main pipeline will be described, these are those scripts used to obtain the results presented in the Thesis. 
All files can be found in the folders cc_cluster_version and CNN. Further results obtained from the brute force optimization can be found in the folder brute_force_results.

![pipeline pictue](https://github.com/htscode/bachelor_thesis_2021/blob/master/images/structure_thesis.png)

### SPM preprocessing 

**slice init** - Initialises preprocessing, makes sure temporary RAM memory is used to increase the execution speed 

**slice_timing_corrected_fmri.m** - SPM preprocessing, including slice time correction,realignment, coregistration, normalization and smoothing

  - **slice_timing_corrected_fmri_job.m** - used in **slice_timing_corrected_fmri.m** for preprocessing raw fMRI scans
  - **batch_stats_fmri_job.m** -  used in **slice_timing_corrected_fmri.m** for single subject fMRI statsitics 

### Brute force optimization 

**brute_force_init.m**- Initializes brute force optimization for ROI variant, makes sure temporary RAM memory is used to increase the execution speed 

  - **brute_force_ROI.m** - calculates NSMD for a set range of time shifts  
      - **shifttrialsnew.m** -creates a new trial definition for every time shift
      - **voxeldiffROI.m** - computes NSMD for all time shift in every voxel of a ROI
     
## Find the best shift 

**findshift.m** - Finds the best shift from the brute force results using variance, mean and median 

### Shifting
**initshiftwithrest.m** - initializes shift with rest condition to optimization computation 
 - **shiftwithrest.m** - creates new trial definition based on a time shift input and incoorperates rest as a condition

### Normalization 

**normalize.m** - Normalizes preprocess fMRI scans to percent signal change [1], and apply SPM brain mask[3] 

### Create Dataset 

**createDataset.m** - creates a dataset from the normalized data, optionally with all runs or just the first 3 runs, according to the format of [1]

### CNN 

All files used for the convolutional neural network can be found in the folder CNN.

**3dcnn_fmri_ADAPTED.ipynb** - CNN implementation including training and testing [1] (adapted to run on Cedar)

**cnnpython.py** - CNN converted to python script to enable submission as a batch job [1]  (adapted to run on Cedar)

**saliencycalculation.ipynb** - Saliency map computation [1] (adapted to run on Cedar)

**saliency_map_basic.ipynb**  - Visualization of saliency maps and saving as NIfTI file (cannot be run on cedar, instead use a single hardware system)

**cnnrequirements.txt** - requirements for running the CNN script on the Cedar division of Compute Canada [2]

## Alternative versions brute force version 

**brute_force_ALL.m** - Brute force optimization variant using all brain voxel 
  - **allvoxeldiffnew.m** - NSMD calculation for all voxels brute force version
**brute_force.m** - Brute force optimization variant using one FFA voxel 
  - **voxeldifferencenew.m** - NSMD calculation for one voxel brute force version

## Alternative optimization 

**simulated_annealing.m** - Attempted unsuccessful simulated annealing with standard parameters 
 -**optimization.m** - used by **simulated_annealing.m** to enable optimization without a classical function 
 -**outfun.m** - to monitor simulated annealing 

## Single hardware system version 

The folder single_hardware_version includes single hardware system versions of the above presented. Note that these versions are for one participant only. 

It further includes the following files: 

**create_roi.m** - creates region of interest based on [4] 
  - used by **normalize.m* 
**downhillsimplex.m** - Downhill simplex optimization attempt 
**forbetterffa.m** - Attempted optimization of the FFA voxel used in single voxel brute force  

## Brute force results 

The folder brute_force_results has the results of **brute_force_ROI.m** for every participant

- To get results such as in '/images/brute_force_results.png': plot(timearray,results)
- To get variance such as in 'images/variance_brute_force_results.png': plot(timearray,variance(results'))
- To get mean or median as in 'images/mean_median_15_brute_force_results.png':  plot(timearray,mean(results,2))

## Files

**smallvolume_face_roi.mat** - Region of interest (indexes)
**roimnicord.mat** - MNI coordinates for region of interest
**smallbrainmask.nii** - resized brain mask 


## References 

[1] Vu, H., Kim, H.-C., Jung, M., \ Lee, J.-H. (2020). Fmri volume classification using a 3d convolutional neural network robust to shifted and scaled neuronal activations. NeuroImage, 117328. https://doi.org/10.1016/j.neuroimage.2020.  (GitHub: https://github.com/bsplku/3dcnn4fmri/tree/master/Python_code)

[2]  WestGrid (www.westgrid.ca) and Compute Canada Calcul Canada (www.computecanada.ca) 

[3] GitHub SPM12 package https://github.com/spm/spm12

[4] Neurosynth, term base meta analysis with the term 'face' https://neurosynth.org/analyses/terms/face/ 
