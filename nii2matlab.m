% nii2matlab Prepare NII volumes to be treated in Matlab
%
% [b0,v11,v12,v13] = nii2matlab(b0nii,v1nii)
% 
% TODO:
%	* I'm not really confident of this flips yet... but it works
%	* I'm forcing to do the 2 conversions. Maybe just one have changed...
%
% AUTHORS:                  Ferran Poveda (ferran.poveda@uab.cat)
% CREATION DATE:            31/01/2013
function [b0,v11,v12,v13] = nii2matlab(b0nii,v1nii)

% Obtain matrixes from NIIs
b0=double(b0nii.img);
v1=double(v1nii.img);

% Convert coordinates to Matlab and split eigenvector components for my mental 
% health. It is way easier to access this adresses when volumes are separated.
v11=v1(:,:,:,2); 
v12=v1(:,:,:,1);
v13=v1(:,:,:,3);
