function dtk_dtirecon(nifti_folder,fnii_name,...
                      dti_prefix,dtk_bvec_file,max_bval,is_siemens)


%% Check for .nii/.nii.gz file

dwi_basename = [nifti_folder filesep fnii_name];

if exist([dwi_basename '.nii'],'file')
    dwi_nii = [dwi_basename '.nii'];
elseif exist([dwi_basename '.nii.gz'],'file')
    dwi_nii = [dwi_basename '.nii.gz'];
else
	error(['/!\ Could not find ' dwi_basename '.nii/.nii.gz']);
end

%% Set the system call to DTK's dti_recon

if is_siemens
	siemens_reorient = ' -oc';
else
	siemens_reorient = '';
end

dtirec_cmd=['dti_recon' ...
			' "' dwi_nii '"' ...
			' "' dti_prefix '"' ...
			' -gm "' dtk_bvec_file '"' ...
			' -b ' num2str(max_bval) ...
			' -b0 auto' ...
			siemens_reorient ...
			' -ot nii'];

%% Run!
system(dtirec_cmd);

end
