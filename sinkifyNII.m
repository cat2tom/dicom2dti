% sinkifyNII Reorient principal eigenvector "automatically" around virtual axis
%            crossing the LV. Necessary for CrimsonLake reception.
%
% v1nii = sinkifyNII(b0nii,v1nii)
%
% INPUT:
%       b0nii			b0 NII volume
%
%       v1nii			v1 NII volume
%
% OUTPUT:
%       v1nii			processed V1 NII volume
% 
% TODO: 
%	* Axis currently "done" view_nii(b0nii) and a little interface, requires
%	  user input. Not always a good idea, but it certainly is a complex process.
%
%	! It is tight to NII. We need to consider old JHU format.
%
% AUTHORS:                  Ferran Poveda (ferran.poveda@uab.cat)
% CREATION DATE:            31/01/2013
function v1nii = sinkifyNII(b0nii,v1nii)

%% 1) Convert inputs to process them on Matlab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[b0,v11,v12,v13] = nii2matlab(b0nii,v1nii);

%% 2) Interactive selection of base (apex) and a top (center of the LV at basal
%     level) to define the virtual axis.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Open NII viewer
iNii = view_nii(b0nii)

% Open an interface to introduce top/base selections
inputOK = 0;

defaultanswer={'','','','','',''};
numlines=1;
name='MANDATORY';
prompt={'Base x:','Base y:','Base z:','Top x:','Top y:','Top z:'};
options.WindowStyle = 'normal';

while inputOK==0 % will not close until all values are correct!

	answ=inputdlg(prompt,name,numlines,defaultanswer,options);

	if ~isempty(answ)
		acc_status = 0;
		for i_ans=1:6
			[val status] = str2num(answ{i_ans});
			acc_status = acc_status + status;
		end
		if acc_status == 6
			inputOK=1;
		else
			defaultanswer = answ; % saves current input!
		end
	end

end

base = [str2num(cell2mat(answ(1,:))), str2num(cell2mat(answ(2,:))), str2num(cell2mat(answ(3,:)))];
top  = [str2num(cell2mat(answ(4,:))), str2num(cell2mat(answ(5,:))), str2num(cell2mat(answ(6,:)))];

% once selected, close the nii viewer too
close(iNii.fig)

%% 3) Compute the axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axisBase = base([2,1,3]);
axisTop  = top([2,1,3]);
axisVec = (top([2,1,3])-base([2,1,3]))';  
axisVec=axisVec./norm(axisVec);
% CODER'S DIOGENES: View that axis
% imshow(b0(:,:,axisBase(3)),[]), hold on, scatter(axisBase(1),axisBase(2)), plot([axisBase(1),axisBase(1)+axisVec(1)*100],[axisBase(2),axisBase(2)+axisVec(2)*100],'r-')

%% 4) Reorientation arround the axis:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% All pixels indexes
[ind]=find(ones(size(v11(:))));
[x,y,z]=ind2sub(size(v11),ind);
point=[y,x,z];

% Project onto axis (to find vec from axis to the point)
point=point-repmat(axisBase',1,size(point,1))';
pproj=FerProject(point,axisVec);
vec=point-pproj;
clear('x','y','z','point','ind');

% Get current eigenvector direction on the plane
vproj=([v11(:),v12(:),v13(:)]*null(axisVec'))*null(axisVec')';

% Cross product "current direction" vs "vec from axis to the point"
A=cross(vproj,vec);
clear('vproj','vec');

% Reorient given the sign of the cross product (in axis)
orient=sign(A(:,1)*axisVec(1)+A(:,2)*axisVec(2)+A(:,3)*axisVec(3));
res(:,1)=orient.*v11(:);
res(:,2)=orient.*v12(:);
res(:,3)=orient.*v13(:);
clear('orient','A');

[H W N]=size(v11);
v11p=reshape(res(:,1),H,W,N);
v12p=reshape(res(:,2),H,W,N);
v13p=reshape(res(:,3),H,W,N);
clear('res');

%% 5) Save results into the nii to return, (back to non-matlab coords)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[b0nii,v1nii] = matlab2nii(b0nii,v1nii,b0,v11p,v12p,v13p);
% /!\ Yes, I'm writting on the input variable, but this is a copy!

% CODERS DIOGENES: Save the processed nii!
%save_nii(v1nii,[seriesPath filesep 'dti_v1reoriented.nii']);

