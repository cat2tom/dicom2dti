% orthoDTIslicer Pedestrian visualization of DTI's mid-orthogonal planes
%                     This is a rapid implementation to check everything works.
%                     There is still a lot TODO here!
%
%                     I think Matlab can't work with this properly, 
%                     I'm not spending much time on it...
%					
%					  You may encounter Memory problems ploting with this tool 
%					  many times on a row. It seem Java's fault because I won't
%					  work even cleaning the environment and freeing memory.
%
% h = orthoDTIslicer(b0nii,v1nii)
%
% INPUT:
%       b0nii			b0 NII volume
%
%       v1nii			v1 NII volume
%
% OUTPUT:
%       h				Figure handle
%
% TODO: 
%	* User defined B0 slices
%	* User defined V1 spacings
%	* User defined V1 slice to show
%
% AUTHORS:                  Ferran Poveda (ferran.poveda@uab.cat)
% CREATION DATE:            31/01/2013
function h = orthoDTIslicer(b0nii,v1nii)

% Convert NIIs to Matlab coordinates I "understand"
[b0,v11,v12,v13] = nii2matlab(b0nii,v1nii);
clear('b0nii','v1nii') % no longer necessary in this function

h = figure

% CONE-GLIPH of V1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set places to put cone-gliphs
step = 2;
xslice = round(size(b0,1)/2);%40; 
yslice = 55;%round(size(b0,1)/2); % TODO: Un-hardcode!
zslice = round(size(b0,3)/2);
v_sliceX = 1:step:size(b0,2);%xslice-.5:xslice+.5;%
v_sliceY = yslice-.5:yslice+.5;%1:step:size(b0,1);
v_sliceZ = 1:step:size(b0,3);
[xc,yc,zc] = meshgrid(v_sliceX,v_sliceY,v_sliceZ);

% Location and samples (currently everthing gets passed, slower but less interp)
step = 1;
v_sliceX = 1:step:size(b0,2);
v_sliceY = 1:step:size(b0,1);
v_sliceZ = 1:step:size(b0,3);
[x,y,z] = meshgrid(v_sliceX,v_sliceY,v_sliceZ);
u = v11(v_sliceY,v_sliceX,v_sliceZ);
v = v12(v_sliceY,v_sliceX,v_sliceZ);
w = v13(v_sliceY,v_sliceX,v_sliceZ);

% NOT USED, IT IS DIOGENES: Trying to set color with B0
color=b0(v_sliceY,v_sliceX,v_sliceZ);


% Cone render
daspect([1.39,1.39,1.50]); % TODO: Un-hardcode! set to my dataset spacing!
hcones = coneplot(x,y,z,u,v,w,xc,yc,zc,color,1.3);
set(hcones,'EdgeColor','none')
camlight right; lighting phong
set(hcones,'FaceColor','red','DiffuseStrength',.8)
axis tight; %view(30,40); %axis off
camproj perspective; camzoom(1)



% B0 Volume slices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hold on

% prepare input info for the slicer (currently all gets passed, less interp)
step = 1;
v_sliceX = 1:step:size(b0,2);
v_sliceY = 1:step:size(b0,1);
v_sliceZ = 1:step:size(b0,3);
[x,y,z] = meshgrid(v_sliceX,v_sliceY,v_sliceZ);

% slices are defined already at the cone-gliph-render
%xslice = round(size(b0,2)/2); 
%yslice = round(size(b0,1)/2); 
%zslice = round(size(b0,3)/2);
hsurfaces = slice(x,y,z,b0,xslice,yslice,zslice);
set(hsurfaces,'FaceColor','interp','EdgeColor','none')
set(hsurfaces,'FaceAlpha',.9)
colormap('gray')
xlabel('y')
ylabel('x')
zlabel('z')
xlim([1,size(b0,2)]) % adjust view to full volume
ylim([1,size(b0,1)])
zlim([1,size(b0,3)])
hold on

% DIOGENES: This is ment to draw the virtual axis, but it is no longer
% applicable here. Maybe in the future.
%scatter3(axisBase(1),axisBase(2),axisBase(3),'r*')
%plot3([axisBase(1),axisTop(1)],[axisBase(2),axisTop(2)],[axisBase(3),axisTop(3)],'b-')
