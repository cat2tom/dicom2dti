% MRItoTractography script
%
%	Launch this script in other to do all the steps needed in order to get from
%	diffusion weighted MRI studies (DICOM format) to tractographies in
%	CrimsonLake.
%
%	Take into account that __you must set variables in the first segment__ of 
%	this script to be able tu run it (more exactly to make it work properly)
%
% TODO:
%	* My machine specific settings must be removed
%	* Could be interesting to auto-search for DTK and MRICron on typical paths
%   * Solve conversion into CL3. It shoudn't be -v12
%
% AUTHORS:                  Ferran Poveda (ferran.poveda@uab.cat)
% CREATION DATE:            31/01/2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all, 
close all,

%% 0) Configure the execution!       /!\ __YOU MUST CHANGE THIS__
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MRICron and DTK paths on your machine
if ismac
	MRICronToolsPath = '/Applications/MRICron';
	DTKToolsPath     = '/Applications/Diffusion Toolkit.app/Contents/MacOS';
elseif isunix
	MRICronToolsPath = '/usr/bin';
	DTKToolsPath     = '/usr/local/bin/dtk';
end

% DICOM folder to process
%dicom_folder = '/Volumes/INFO/fbeeper/Databases/SCANS/SantPau2012/Primer';
%dicom_folder = '/home/fbeeper/Escritorio/COR1';
dbMain = '/Users/fbeeper/Databases/SCANS/SantPau2012';
dicom_folder = uigetdir(dbMain,'Select DICOM directory to process)');
if ~isdir(dicom_folder) % pre-check (being conservative :P)
	error('Expected dicom_folder to be an existing directory.')
else
	if ~exist([dicom_folder filesep 'DICOMDIR'],'file')
		error('Expected dicom_folder to be a parent DICOM directory.')
	end
end

%% 1) Setting temporary path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%setenv('PATH', [getenv('PATH') ':' MRICronToolsPath])
%setenv('PATH', [getenv('PATH') ':' DTKToolsPath])
addToSystemPath(MRICronToolsPath);
addToSystemPath(DTKToolsPath);


%% 2) Convert diffusion-dicom to dti-nii
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dicom2dti(dicom_folder,'overwrite',1);



%% 3) Ask for DTI folder to run (DICOM folders may contain several DW studies,
%     we must choose only one to process at this point)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
seriesPath = uigetdir([dicom_folder 'dti'],'Select DTI parent directory)');
if sum(~seriesPath) || ~exist(seriesPath,'dir')
	error('/!\ you must select a directory!')
else
	d=dir([seriesPath filesep '*.nii*']);
	if isempty(d)
		error(['/!\ "' seriesPath '" does not seem to be a correct DTI dir' ])
	end
end



%% 4) Reorient to load into CrimsonLake
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load necessary NIIs
b0niiPath = [seriesPath filesep 'dti_b0.nii'];
v1niiPath = [seriesPath filesep 'dti_v1.nii'];
b0nii=load_nii(b0niiPath);
v1nii=load_nii(v1niiPath);

% Run reorientation!
v1nii_sink = sinkifyNII(b0nii,v1nii);


%% 5) Visualize this awesome creation!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%orthoDTIslicer(b0nii,v1nii);
%orthoDTIslicer(b0nii,v1nii_sink);


%% 6) Load it into CL3

[b0,v11,v12,v13] = nii2matlab(b0nii,v1nii_sink);
dLenght=200;
dSeedSampling=2500;
spacing=[1.38 1.38 1.5];
outputPath='/Users/fbeeper/Desktop/SantPau2012/Primer';
b0mask = (b0<300).*(b0>100);
JHUExportRawFiles(outputPath,b0mask,v11,-v12,v13,b0mask);

% run CL3 with this
if ismac
    oldDYLDPath=getenv('DYLD_FRAMEWORK_PATH');
    setenv('DYLD_FRAMEWORK_PATH','/usr/lib');% TODO: this is not!!!
    CL3exe = '/Volumes/INFO/fbeeper/Developement/CrimsonLake/CL3QTinBash';
else
    oldDYLDPath=getenv('LD_LIBRARY_PATH');
    setenv('LD_LIBRARY_PATH','');
    CL3exe = '/home/fbeeper/Developer/crimsonlake/CL3QTinBash';
end

system([CL3exe ' -source ' outputPath])


if ismac
    setenv('DYLD_FRAMEWORK_PATH',oldDYLDPath)
else
    setenv('LD_LIBRARY_PATH',oldDYLDPath)
end
