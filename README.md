# bachelor_thesis_2021
This is the repository for my bachelor thesis with the title "Processing fast event-related fMRI for artifical neural network applications". 

## MAIN PIPELINE 

Followingly the script of the main pipeline will be described, these are those scripts used to obtain the results presented in the Thesis. 
All files can be found in the folders cc_cluster_version and CNN. Furthe results obtained from the brute force optimization can be found in the folder brute_force_results.

PUT PIC 

### SPM preprocessing 

**slice init** - Initialises preprocessing, makes sure temporary RAM memory is used to increade the execution speed 

**slice_timing_corrected_fmri.m** - SPM preprocessing, including slice time correction,realignment, coregistration, normalization and smoothing

  - **slice_timing_corrected_fmri_job.m** - used in **slice_timing_corrected_fmri.m** for preprocessing raw fMRI scans
  - **batch_stats_fmri_job.m** -  used in **slice_timing_corrected_fmri.m** for single subject fMRI statsitics 

### Brute force optimization 

**brute_force_init.m**- Initialize brute force optimization for ROI variant, makes sure temporary RAM memory is used to increade the execution speed 

  - **brute_force_ROI.m** - calculate NSMD for a set range of time shifts  
      - **shifttrialsnew.m** -creates a new trial definition for every time shift
      - **voxeldiffROI.m** - compute NSMD for all time shift in every voxel of a ROI
      

### Shifting

**shiftwithrest.m** - creates new trial definition base on a time shift input and incoorperates rest as a condition

### Normalization 

**normalize.m* - Normalize preprocess fMRI scans to percent signal change [1], and apply SPM brain mask[3] 

### Create Dataset 

**createDataset.m** - creates a dataset from the normalized data, optinally with all runs or just the first 3 runs, according to the format of [1]

### CNN 

All files used for the convolutional neural network can be found in the folder CNN.

**3dcnn_fmri_ADAPTED.ipynb** - CNN implementation including training and testing [1] (adapted to run on Cedar)

**cnnpython.py** - CNN converted to python script to enable submission as a batch job [1]  (adapted to run on Cedar)

**saliencycalculation.ipynb** - Saliency map computation [1] (adapted to run on Cedar)

**saliency_map_basic.ipynb**  - Vizualization of saliency maps and saving as NIfTI file (cannot be run on cedar, instead use a single hardware system)

**cnnrequirements.txt** - requirements for running the CNN script on the Cedar division of Compute Canada [2]




## References 

[1] Vu, H., Kim, H.-C., Jung, M., \ Lee, J.-H. (2020). Fmri volume classifcation using
a 3d convolutional neural network robust to shifted and scaled neuronal activations. NeuroImage, 117328. https://doi.org/10.1016/j.neuroimage.2020.
117328 (GitHub: https://github.com/bsplku/3dcnn4fmri/tree/master/Python_code)

[2]  WestGrid (www.westgrid.ca) and Compute Canada Calcul Canada (www.computecanada.ca) 

[3] GitHub SPM12 package https://github.com/spm/spm12
