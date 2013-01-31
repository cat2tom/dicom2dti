dicom2dti
=========

**TEMPORARY REPO*** with Matlab tools to process diffusion MRI studies (DICOM) into manageable DTI (NIFTI). 
As well as some supporting visualization and conversion tools to connect with my tractography software CrimsonLake.

This will soon be probably merged into [CrimsonLake](https://github.com/fbeeper/CrimsonLake) project, 
or [JHUToolbox](https://github.com/fbeeper/JHUToolbox).

Dependencies
============

You'll need [DTK](http://trackvis.org/dtk) and [MRICron](http://www.mccauslandcenter.sc.edu/mricro/mricron/) 
in order to run DICOM to DTI conversion. 

For all NIFTI handling you will need these 
[tools for NIfTI and ANALYZE image](http://www.mathworks.es/matlabcentral/fileexchange/8797).


Usage
=====

There is a [bootstrap](https://github.com/fbeeper/dicom2dti/blob/master/bootstrap.m) script for you to start
and go through all the steps that this tools cover.


:exclamation: There is no example data included in the repo (yet). You will need your own DICOM folder 
with a diffusion study to test it.
