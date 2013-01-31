% dicom2dti Functionality to auto-convert DW DICOM scans to DTI NIFTI
%
% dicom2dti(dicom_folder,varargin)
%
% INPUT:
%       dicom_folder    This must be a DICOM folder with your DW-DICOM
%						/!\ I understand DICOM dirs as the ones that have the
%						DICOMDIR file and the DICOM folder, otherwise this
%						function will throw an error.
%       
% OPTIONS:
%       'siemens',bool		(OPTIONAL) Expects 1 for SIEMENS DICOMS, 0 otherwise 
%							It is thought for a SIEMENS reorientation in DTI
%							computation. Haven't tested it, but it is a 
%							dti_recon input!
%
%		'overwrite',bool	(OPTIONAL) Expects 1 if you want to overwrite past
%							conversions of this tool if they exist already.
%
% USAGE EXAMPLE:
%       dicom2dti('~/exampleDICOMfolder','overwrite',1);
%
% EXTERNAL REQUIREMENTS:
%		This function needs Diffusion ToolKit (DTK)
%			Available at:
%				http://trackvis.org/blog/tag/diffusion-toolkit/
%		And MRICron
%			Available at: 
%				https://www.nitrc.org/projects/mricron
%				http://www.mccauslandcenter.sc.edu/mricro/mricron/
%		Both accessible in your matlab-system path!
%
%		You can make them accessible simply doing:
%			setenv('PATH', [getenv('PATH') ':/<path_to_MRICron_tools>'])
%			setenv('PATH', [getenv('PATH') ':/<path_to_DTK_tools>'])
%
% TODO:
%		! This tool has been created and tested under LINUX and MAC OS. 
%		  Windows is neither supported nor tested (basically on the tool check).
%		  Consider 'where' as a substitution of 'which' in that platform.
%		
%		* It is possible to be more flexible, and get DICOM folders that doesn't
%		  have the DICOMDIR structure. It would be nice to control that.
%
%		* Add user-defined output folders capability.
%
%		! Each DICOM folder may contain several DW studies, they are separated
%		  in distinct DTI folder. Those folders shall be named more accordingly
%		  to the input data (DICOM series e.g.)
%
%
% AUTHORS:                  Ferran Poveda (ferran.poveda@uab.cat)
% CREATION DATE:            29/01/2013
function dicom2dti(dicom_folder,varargin)

%% Initialization! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Parse input
[is_siemens,overwrite] = processInput(dicom_folder,varargin{:});

% Define the "hard-coded" output folders (dicom-nii and dti-nii results)
nifti_folder = [dicom_folder 'nii'];
dti_folder   = [dicom_folder 'dti']; % this is parent folder for all DTI output
dti_prefix   = 'dti_';				 % this is the prefix of all DTI files

% Check for necessary tools (dcm2nii and dti_recon)
fprintf('\n\n1) Check for necessary tools (dcm2nii + dti_recon)...\n')
[cmd_out,dcm2nii_path]=system('which dcm2nii');
if cmd_out ~=0 && ~isempty(dcm2nii_path)
	ME = MException('dicom2nii:dti_recon', ...
		['/!\\ *dcm2nii* not found on your path.\n', ...
		 '    Check for MRICron availability on your system path!']);
	throw(ME);
end
[cmd_out,dtireco_path]=system('which dti_recon');
if cmd_out ~=0 && ~isempty(dcm2nii_path)
	ME = MException('dicom2nii:dti_recon', ...
		['/!\\ *dti_recon* not found on your path.\n', ...
		 '    Check for Diffusion Toolkit availability on your system path!']);
	throw(ME);
end

% Prepare output folders (if overwrite==1, existing contents will be erased)
fprintf('\n\n2) Preparing output folders...\n\n')

convertDICOM = 1;
if exist(nifti_folder,'dir')
	if overwrite
		fprintf('\tDeleting previous NIFTI files...')
		system(['rm ' nifti_folder filesep '*.*']);
	else
		d=dir([nifti_folder filesep '*.nii*']); % any nii is an evidence ;)
		if ~isempty(d)
			fprintf('\tDICOM files seem to be already converted!')
			convertDICOM = 0;
		end
	end
else
	system(['mkdir -p ' nifti_folder]);
end
fprintf('\n\tNIFTI folder:')
fprintf(['\n\t\t' nifti_folder '\n\n'])

computeDTI = 1;
if exist(dti_folder,'dir')==7
	if overwrite || convertDICOM % if DICOMs have changed, this must be recomp!
		fprintf('\tDeleting previous DTI files...')
		system(['rm -rf ' dti_folder filesep '*']); 
	else
		d=dir([dti_folder filesep '*']); % any folder in here is an evidence ;)
		if (numel(d)-2)>2
			fprintf('\tDTI files seem to be already computed!')
			computeDTI = 0;
		end
	end
else
	system(['mkdir -p ' dti_folder]);
end
fprintf('\n\tDTI folder:')
fprintf(['\n\t\t' dti_folder '\n'])

%% DICOM to NIFTI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n\n3) Converting DICOM to NIFTI...')
if convertDICOM

	% Create and run the system call to MRICron conversion
	try
		system(['dcm2nii' ...
				... %' -a y -c y -d n -e y -f y -g n -i n -n y -p y -v y' ...
				' -o ' nifti_folder ...
				... %' -r ' reorient_ortho ...
				... %' -x ' reorient_nii3D ...
				' ' dicom_folder ]);
	catch err
		% Never happened to me, but I'm controlling the possible exception!
		error('/!\ "dcm2nii" call failed :(');
	end
	% CODER'S DIOGENES SYNDROME: This is the same but with more parameters
	%reorient_ortho='y' % this is how we've been rolling
	%reorient_nii3D='y'

	% DICOM TO NIFTI conversion
	% system([dcm2nii_path ...
	% 		...%' -a y -c y -d n -e y -f y -g n -i n -n y -p y -v y' ...
	% 		' -o ' nifti_folder ...
	% 		' -r ' reorient_ortho ...
	% 		' -x ' reorient_nii3D ...
	% 		' ' dicom_folder ]);

	fprintf('DONE')

else
	fprintf(' /!\\ Using aready converted NIFTI files!')
end


%% NIFTI to DTI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n\n4) Computing DTI from NIFTI files...')
if computeDTI

	% Find the DW series names (could be either "nii" or "nii.gz")
	% /!\ In all my testing datasets those are identified with an "x" as prefix,
	% but I have to say that this is an empiric discovery, DCM2NII does not 
	% document it. And I'm not navigating its source to find out (no time)!
	[list]=dir([nifti_folder filesep 'x*.nii']);
	ext=4;
	if isempty(list)
		[list]=dir([nifti_folder filesep 'x*.nii.gz']);
		ext=7;
	end
	num_series = numel(list);
	fprintf(['There are ' num2str(num_series) ' series in this folder'])

	for series=1:num_series

		% Make a subfolder to put current series
		series_folder = [dti_folder filesep 's' num2str(series)];
		system(['mkdir -p ' series_folder]);
		
		fprintf(['Processing series #' num2str(series) '/' num2str(num_series)]);
		fnii_name=list(series).name(1:end-ext);
		
		% Controlling diffusion directions: Here I convert bvec file (dcm2nii 
		% output) format to the format DTK needs.
		[dtk_bvec_file,max_bval] = bvec2dtkdirs(nifti_folder,fnii_name);

		% Run DTK to obtain dti reconstruction
		try
			dtk_dtirecon(nifti_folder,fnii_name,[series_folder filesep dti_prefix],dtk_bvec_file,max_bval,is_siemens)
		catch err
			% Never happened to me, but I'm controlling the possible exception!
			error('/!\ "dti_recon" call failed :(');
		end
		% CODER'S DIOGENES SYNDROME: This is to check everything goes well :D
		% load nifti of v1 to see it
		%try
		%    u=load_nii([dti_folder filesep 's' series filesep dti_prefix '_v1.nii']);
		%    view_nii(u);
		%catch err
		%    display(err.message)
		%end
		%%view_nii(u)
		%pause
		
	end

	fprintf('DONE')

else
	fprintf(' /!\\ Using aready computed DTI files!')
end

fprintf('\n\n')



% processInput Input parser for dicom2dti (check inputs, set defaults)
%
% [is_siemens,overwrite] = processInput(dicom_folder,varargin)
%
% AUTHORS:                  Ferran Poveda (ferran.poveda@uab.cat)
% CREATION DATE:            29/01/2013
function [is_siemens,overwrite] = processInput(dicom_folder,varargin)

p = inputParser;

% Set default values
default_is_siemens = 0;
default_overwrite  = 0;

% Input rules
addRequired   (p, 'dicom_folder',						@(x)validateattributes(x,{'char'},{'nonempty'}, 'dicom2dti','dicom_folder'));
addParamValue (p, 'siemens',	  default_is_siemens,	@(x)validateattributes(x,{'numeric'},{'binary'},'dicom2dti','siemens'));
addParamValue (p, 'overwrite',	  default_overwrite,	@(x)validateattributes(x,{'numeric'},{'binary'},'dicom2dti','overwrite'));

% Run the parser
parse(p,dicom_folder,varargin{:});

% Custom check to validate that the DICOM folder is as I expect
if ~isdir(dicom_folder)
	error('Expected dicom_folder to be an existing directory.')
else
	if ~exist([dicom_folder filesep 'DICOMDIR'],'file')
		error('Expected dicom_folder to be a parent DICOM directory.')
	end
end
is_siemens   = p.Results.siemens;
overwrite    = p.Results.overwrite;


